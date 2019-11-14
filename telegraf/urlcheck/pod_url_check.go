package main

import (
	"fmt"
	"os"
	"os/exec"
	"regexp"
	"strings"
	"time"

	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes"
	k8srest "k8s.io/client-go/rest"
)

var kubeClient *kubernetes.Clientset

func getKubeClient() (*kubernetes.Clientset, error) {
	if kubeClient == nil {
		config, err := k8srest.InClusterConfig()
		if err != nil {
			return nil, err
		}
		clientset, err := kubernetes.NewForConfig(config)
		if err != nil {
			return nil, err
		}
		kubeClient = clientset
	}
	return kubeClient, nil
}

var config_template string = `
[global_tags]
  agent_pod = "$POD_NAME"
  ip = "$POD_IP"
[agent]
  interval = "$INTERVALs"
  round_interval = true
  metric_batch_size = 1000
  metric_buffer_limit = 10000
  collection_jitter = "0s"
  flush_interval = "$INTERVALs"
  flush_jitter = "0s"
  precision = ""
  hostname = ""
  omit_hostname = false

[[outputs.whatap]]
  license = "$WHATAP_LICENSE"
  pcode = $WHATAP_PROJECT_CODE
  servers = ["tcp://$WHATAP_HOST_IP:6600"]
`
var url_template string = `
[[inputs.http_response]]
    name_suffix = "$NAME"
    urls = [$URLS]
    response_timeout = "$TIMEOUTs"
    method = "GET"
    follow_redirects = false
`

func getPodsDummy() []*map[string]string {
	var pods []*map[string]string

	dummy_pod := map[string]string{}
	dummy_pod["NAME"] = "whatap"
	dummy_pod["URLS"] = "\"https://www.whatap.io/ko/docs/guides/\",\"https://www.whatap.io/ko/about-us/\""
	dummy_pod["TIMEOUT"] = fmt.Sprint(os.Getenv("TIMEOUT"))

	pods = append(pods, &dummy_pod)

	return pods
}

func getPods() (ret []*map[string]string, err error) {
	namespace := os.Getenv("NAMESPACE")
	fieldSelector := os.Getenv("FIELD_SELECTOR")
	ownerName := os.Getenv("OWNER_NAME")
	listOptions := metav1.ListOptions{}
	if len(fieldSelector) > 0 {
		listOptions.FieldSelector = fieldSelector
	}
	cli, err := getKubeClient()
	if err != nil {
		return
	}
	pods, err := cli.CoreV1().Pods(namespace).List(listOptions)
	if err != nil {
		return
	}

	if len(pods.Items) < 1 {
		err = fmt.Errorf("Pods not found for ", namespace, fieldSelector)
		return
	}

	pod_lookup := map[string][]string{}
	for _, pod := range pods.Items {
		var podGroupName string

		if len(pod.OwnerReferences) > 0 {
			if len(ownerName) > 0 {
				ownerFound := false
				for _, ownerRef := range pod.OwnerReferences {
					ownerFound = ownerRef.Name == ownerName
					if ownerFound {
						break
					}
				}
				if !ownerFound {
					continue
				}
			}

			podGroupName = fmt.Sprint(pod.OwnerReferences[0].Kind, " ", pod.OwnerReferences[0].Name)
		} else {
			podGroupName = fmt.Sprint(pod.Name)
		}

		if _, ok := pod_lookup[podGroupName]; !ok {
			pod_lookup[podGroupName] = []string{}
		}
		if len(pod.Status.PodIP) > 0 {
			pod_lookup[podGroupName] = append(pod_lookup[podGroupName], pod.Status.PodIP)
		}
	}

	for podGroupName, podIps := range pod_lookup {
		pod_variables := map[string]string{}
		pod_variables["NAME"] = podGroupName
		var b strings.Builder
		i := 0
		for _, podip := range podIps {
			if i == 0 {
				b.WriteString("\"")
			} else {
				b.WriteString(",\"")
			}
			b.WriteString("http://")
			b.WriteString(podip)
			b.WriteString(":")
			b.WriteString(os.Getenv("PROBE_HOST_PORT"))
			b.WriteString(os.Getenv("PROBE_URL_PATH"))
			b.WriteString("\"")
			i += 1
		}
		pod_variables["URLS"] = b.String()
		pod_variables["TIMEOUT"] = fmt.Sprint(os.Getenv("TIMEOUT"))
		ret = append(ret, &pod_variables)
	}

	return
}

func generateTelegrafConfig(configpath string) (ret bool) {
	ret = false
	f, err := os.Create(configpath)
	if err != nil {
		fmt.Println("config file open failed:", err.Error())
		return
	}
	defer f.Close()

	r := regexp.MustCompile(`\$([A-Z_\-]+)`)
	config_lines := "" + config_template
	matches := r.FindAllString(config_lines, -1)
	for _, v := range matches {
		rv := regexp.MustCompile(fmt.Sprint("\\", v))
		config_lines = rv.ReplaceAllString(config_lines, os.Getenv(v[1:]))
	}
	f.WriteString(config_lines)

	pod_access_list, e := getPods()
	if e != nil {
		fmt.Println("Cannot find pods ", e.Error())
		return
	}
	for _, pod_ip_port := range pod_access_list {
		http_lines := "" + url_template
		matches = r.FindAllString(http_lines, -1)
		for _, v := range matches {
			rv := regexp.MustCompile(fmt.Sprint("\\", v))
			http_lines = rv.ReplaceAllString(http_lines, (*pod_ip_port)[v[1:]])
		}
		f.WriteString(http_lines)
	}

	return
}

func reloadTelegraf() {

}
func startTelegraf(configfile string) (ret *os.Process) {
	commands := []string{"--config", configfile}

	telegraf_path := os.Getenv("TELEGRAF_PATH")
	cmd := exec.Command(telegraf_path, commands...)
	if cmd != nil {
		err := cmd.Start()
		if err != nil {
			fmt.Println("telegraf start failed:", err.Error())
			return
		}

		ret = cmd.Process
	}
	return
}

func main() {

	configfilepath := os.Getenv("TELEGRAF_CONFIG_PATH")
	generateTelegrafConfig(configfilepath)
	p := startTelegraf(configfilepath)
	for p != nil {
		if generateTelegrafConfig(configfilepath) {
			reloadTelegraf()
		}
		time.Sleep(1 * time.Second)
	}
}
