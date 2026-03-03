# AI4Devs Monitoring - Integración Datadog con AWS

## Descripción

Extensión del código Terraform existente para implementar un canal de monitorización de Datadog en AWS. El proyecto configura la integración completa entre AWS y Datadog, instala el agente de monitorización en instancias EC2 y crea un dashboard para visualizar métricas clave de la infraestructura.

## Cambios realizados

### 1. Configuración de proveedores (`tf/provider.tf`)
- Región AWS configurada en `eu-north-1` (Estocolmo)
- Proveedor Datadog apuntando a la API EU (`datadoghq.eu`)
- Añadido `hashicorp/aws` como required provider junto a `DataDog/datadog`

### 2. Gestión segura de credenciales (`tf/variables.tf`, `tf/terraform.tfvars`)
- Variables `datadog_api_key` y `datadog_app_key` marcadas como `sensitive`
- Claves almacenadas en `terraform.tfvars` (excluido del repositorio via `.gitignore`)
- Eliminadas API keys hardcodeadas de los scripts de user_data

### 3. Integración AWS-Datadog (`tf/datadog_integration.tf`)
- Rol IAM `DatadogIntegrationRole` con trust policy hacia la cuenta de Datadog
- Permisos de lectura de CloudWatch, EC2, Logs y Tags
- Registro automático de la cuenta AWS en Datadog con `datadog_integration_aws`
- Account ID de AWS obtenido dinámicamente con `data.aws_caller_identity`

### 4. Agente Datadog en EC2 (`tf/scripts/`)
- Scripts de user_data modificados para recibir la API key como variable de Terraform
- `DD_SITE` configurado a `datadoghq.eu` para la región EU
- Agente Datadog v7 instalado automáticamente al arrancar las instancias

### 5. Dashboard de monitorización (`tf/dashboard.tf`)
Dashboard "EC2 Monitoring Dashboard - LTI Project" con 4 grupos de métricas:
- **CPU Metrics**: CPU Utilization por host
- **System Metrics (Agent)**: Memory Usage, Disk Usage, System Load
- **Network Metrics**: Network In/Out
- **Instance Status**: Running Instances, Status Check Failed

### 6. Limpieza y correcciones (`tf/main.tf`, `tf/ec2.tf`, `tf/s3.tf`)
- Eliminados recursos duplicados entre `main.tf` y archivos separados
- Instancias EC2 cambiadas a `t3.micro` (free tier en eu-north-1)
- Bucket S3 renombrado a `lti-project-code-bucket-vsl` (nombres globales únicos)

## Capturas de pantalla

### Dashboard en Datadog
*(Añadir captura del dashboard con las métricas)*

### Infraestructura en AWS
*(Añadir captura de las instancias EC2 en la consola AWS)*

## Arquitectura

```
┌─────────────────┐         ┌─────────────────────┐
│   AWS Account   │         │      Datadog EU      │
│                 │         │                      │
│  ┌───────────┐  │  IAM    │  ┌────────────────┐  │
│  │ EC2       │  │ Role    │  │  Integration   │  │
│  │ Backend   │──┼─────────┼──│  AWS-Datadog   │  │
│  │ (Agent)   │  │         │  └────────────────┘  │
│  └───────────┘  │         │                      │
│                 │         │  ┌────────────────┐  │
│  ┌───────────┐  │ Agent   │  │   Dashboard    │  │
│  │ EC2       │  │ Metrics │  │  EC2 Monitor   │  │
│  │ Frontend  │──┼─────────┼──│  - CPU         │  │
│  │ (Agent)   │  │         │  │  - Memory      │  │
│  └───────────┘  │         │  │  - Disk        │  │
│                 │         │  │  - Network     │  │
│  ┌───────────┐  │         │  │  - Status      │  │
│  │CloudWatch │──┼─────────┼──│                │  │
│  └───────────┘  │ AWS API │  └────────────────┘  │
└─────────────────┘         └─────────────────────┘
```

## Desafíos encontrados y soluciones

| Desafío | Solución |
|---------|----------|
| `t2.micro` no es free tier en eu-north-1 | Cambiado a `t3.micro` |
| Bucket S3 con nombre ya existente globalmente | Añadido sufijo `-vsl` al nombre |
| Duplicados entre `main.tf` y archivos separados | Limpiado `main.tf` dejando solo recursos únicos |
| API keys hardcodeadas en scripts | Uso de `templatefile()` con variables sensitive |
| Recurso `datadog_integration_aws` deprecado | Mantenido por compatibilidad, documentado el warning |

## Estructura de archivos Terraform

```
tf/
├── provider.tf              # Proveedores AWS y Datadog
├── variables.tf             # Variables (API keys sensitive)
├── terraform.tfvars         # Valores de variables (NO en git)
├── main.tf                  # Política IAM Datadog + data sources
├── ec2.tf                   # Instancias EC2 backend y frontend
├── dashboard.tf             # Dashboard Datadog con métricas
├── datadog_integration.tf   # Integración AWS-Datadog
├── iam.tf                   # Roles IAM para EC2
├── s3.tf                    # Bucket S3 para código
├── security_groups.tf       # Security groups
├── outputs.tf               # Outputs
└── scripts/
    ├── backend_user_data.sh  # Script de inicio backend + agente Datadog
    └── frontend_user_data.sh # Script de inicio frontend + agente Datadog
```

## Documentación de prompts

Los prompts utilizados para generar el código Terraform están documentados en:
📄 [`prompts/datadog-aws-prompts.md`](prompts/datadog-aws-prompts.md)
