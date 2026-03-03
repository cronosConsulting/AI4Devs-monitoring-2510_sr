#!/bin/bash
yum update -y
yum install -y docker

# Instalar agente Datadog
export DD_AGENT_MAJOR_VERSION=7
export DD_API_KEY='${datadog_api_key}'
export DD_SITE="datadoghq.eu"
bash -c "$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script.sh)"

service docker start

# Descargar y descomprimir el frontend desde S3
aws s3 cp s3://lti-project-code-bucket/frontend.zip /home/ec2-user/frontend.zip
unzip /home/ec2-user/frontend.zip -d /home/ec2-user/

cd /home/ec2-user/frontend
docker build -t lti-frontend .
docker run -d -p 3000:3000 lti-frontend

echo "Timestamp: ${timestamp}"