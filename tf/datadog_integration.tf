# Rol IAM para que Datadog acceda a tu cuenta AWS
resource "aws_iam_role" "datadog_integration_role" {
  name = "DatadogIntegrationRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::464622532012:root"
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "sts:ExternalId" = datadog_integration_aws.aws_integration.external_id
          }
        }
      }
    ]
  })
}

# Política con permisos que Datadog necesita para leer métricas de AWS
resource "aws_iam_role_policy_attachment" "datadog_integration_policy" {
  role       = aws_iam_role.datadog_integration_role.name
  policy_arn = aws_iam_policy.datadog_policy.arn
}

# Integración AWS-Datadog
resource "datadog_integration_aws" "aws_integration" {
  account_id = data.aws_caller_identity.current.account_id
  role_name  = "DatadogIntegrationRole"
}

# Obtener el Account ID de AWS automáticamente
data "aws_caller_identity" "current" {}