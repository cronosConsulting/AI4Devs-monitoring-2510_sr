#!/bin/bash
# Instalar agente Datadog
export DD_AGENT_MAJOR_VERSION=7
export DD_API_KEY='${datadog_api_key}'
export DD_SITE="datadoghq.eu"
bash -c "$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script.sh)"

yum update -y
yum install -y docker
service docker start

# Descargar y descomprimir el backend desde S3
aws s3 cp s3://lti-project-code-bucket/backend.zip /home/ec2-user/backend.zip
unzip /home/ec2-user/backend.zip -d /home/ec2-user/

cd /home/ec2-user/backend
docker build -t lti-backend .
docker run -d -p 8080:8080 lti-backend

echo "Timestamp: ${timestamp}"