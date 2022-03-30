#!/usr/bin/env bash

awsAccountNo=
roleName=whatap-monitoring
maxSessionDuration=43200

cat >trust-policy.json <<EOL
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::$awsAccountNo:root"
            },
            "Action": "sts:AssumeRole",
            "Condition": {}
        }
    ]
}
EOL

aws iam create-role --role-name $roleName --assume-role-policy-document file://trust-policy.json
aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/ReadOnlyAccess --role-name $roleName
aws iam update-role --role-name $roleName --max-session-duration $maxSessionDuration
