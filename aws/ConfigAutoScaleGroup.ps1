
try{
    $whatap_api_endpoint = 'api.whatap.io'
	$sns_push_name = 'whatap-serverdown-push'
    $profilename = 'whatapprofile'
	Write-Host "IAM User Access/SecretKey is required to setup SNS and ASG notification."
	Write-Host "refer to http://docs.aws.amazon.com/IAM/latest/UserGuide/access_permissions.html for IAM permission configuration"
	Write-Host "Your access information will be stored as profile - $profilename which will be delete when program ends."
    $accessKey= Read-Host 'Please input AccessKey'
    $secretKey= Read-Host 'Please input SecretKey'
    
	
    Set-AWSCredentials -AccessKey "$accessKey" -SecretKey "$secretKey" -StoreAs "$profilename"
    Set-AWSCredentials -ProfileName "$profilename"

    (new-object Net.WebClient).DownloadString("http://169.254.169.254/latest/dynamic/instance-identity/document") -match '"region" : "([\w\-]+)"'
    $region=$($matches[1])    
    set-defaultawsregion "$region" | out-null

    $autoscalegroups=get-asautoscalinggroup
    if (!$autoscalegroups){
		Read-Host 'Auto scale group not found. Please check your IAM permissions. Enter to close windows..'
        return
    }
    $idx=1
    foreach($autoscalegroup in $autoscalegroups){
        $description = ''
		$asnc = get-asnotificationconfiguration -AutoScalingGroupName $autoscalegroup.AutoScalingGroupName
		if ($asnc){
			$topicArn = $asnc.TopicArn
			if ($topicArn -like "*$sns_push_name" ){
				$description = ' => whatap sns feedback already configured'
			}
		}
		Write-Host "$idx) $($autoscalegroup.AutoScalingGroupName) $description"
		
        $idx = $idx +1
    }
    while($true){
        $selectedIdx= Read-Host 'Please select an auto scale group (q to quit)?'
		if ($selectedIdx -eq 'q' -or $selectedIdx -eq 'Q'){
			return
		}
        $selectedIdx= [convert]::ToInt32($selectedIdx, 10)
        if ( $selectedIdx -le $autoscalegroups.Count ){
            break
        }
    }
    $autoScaleGroupName = $autoscalegroups[$selectedIdx-1].AutoScalingGroupName
    $topicArn= New-SNSTopic -Name $sns_push_name
    Write-Host "Created Topic: $topicArn"
    (new-object Net.WebClient).DownloadString("http://169.254.169.254/latest/dynamic/instance-identity/document") -match '"accountId" : "([0-9]+)",'
    $accountId=$($matches[1])
    Connect-SNSNotification -TopicArn $topicArn -Protocol http -Endpoint "http://$whatap_api_endpoint/v1/aws/account/$accountId/asg/notification"
    $confirm_msg= $null
    while (!$confirm_msg){
        start-sleep -s 10
        $confirm_msg= (new-object Net.WebClient).DownloadString("http://$whatap_api_endpoint/v1/aws/account/$accountId/asg/confirm")
    }
    Confirm-SNSSubscription -TopicArn $topicArn -Token $confirm_msg

    write-asnotificationconfiguration -AutoScalingGroupName "$autoScaleGroupName" -TopicArn $topicArn -NotificationType autoscaling:EC2_INSTANCE_TERMINATE
	Read-Host 'Configuration Complete. Enter to close windows..'
}Finally{
    Clear-AWSCredentials -Profile $profilename
}
