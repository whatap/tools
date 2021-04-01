# 사용법

## ansible-playbook 위치로 이동합니다.
```
  cd {play_book_home} 
  ex) cd install-whatap-infra-ansible
```

## 변수를 정의해 실행합니다. 
playbook에서 사용할 hostfile을 지정하고 변수로 whatap_license,whatap_server_host 지정해 playbook을 실행합니다.
```
  ansible-playbook -i {host_file_name} --e "whatap_license={whatap_license} whatap_server_host={whatap_server_host}" whatap.yml
  ex) ansible-playbook -i whatap_hosts --e "whatap_license=xxxxxxxxxxxxxxxxxxxxxxxxxx whatap_server_host=13.124.11.223/13.209.172.35" whatap.yml
```

## 에이전트 업데이트만 진행하는 것이 기본값 입니다. 
신규 설치할 경우 whatap.yml 내 updateonly 값을 false 로 변경 해 주세요.

whatap.yml
```
-     updateonly: true
+     updateonly: false
```
