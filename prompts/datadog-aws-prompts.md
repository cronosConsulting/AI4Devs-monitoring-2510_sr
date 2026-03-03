# Prompts de Integración Datadog-AWS

## Descripción del ejercicio

Extender el código Terraform existente para configurar la integración de Datadog con AWS, instalar el agente Datadog en instancias EC2 y crear un dashboard de monitorización con métricas clave de la infraestructura.

---

## Prompt 1: Análisis del código Terraform base y planificación

### Contexto
El repositorio contenía código Terraform base con recursos AWS (EC2, S3, IAM, Security Groups) y una configuración inicial de Datadog. Necesitaba entender qué existía y qué faltaba por implementar.

### Prompt utilizado
```
Analiza el código Terraform existente en la carpeta tf/:
- provider.tf: proveedores AWS y Datadog
- main.tf: política IAM para Datadog + dashboard básico
- ec2.tf: instancias backend y frontend con user_data
- iam.tf: roles y perfiles de instancia
- s3.tf: bucket para código
- security_groups.tf: grupos de seguridad
- scripts/: scripts de user_data para instalar agente Datadog

Identifica qué hay que adaptar (región AWS, URL Datadog, API keys hardcodeadas)
y qué falta por crear (integración AWS-Datadog, dashboard ampliado).
Define tickets técnicos para completar el ejercicio.
```

### Resultado
Se identificaron los siguientes cambios necesarios:
- Cambiar región AWS de us-east-1 a eu-north-1
- Cambiar URL de Datadog de us5.datadoghq.com a datadoghq.eu
- Eliminar API keys hardcodeadas en scripts, usar variables de Terraform
- Añadir proveedor AWS en required_providers
- Crear recurso de integración AWS-Datadog
- Ampliar dashboard con más métricas
- Resolver duplicados entre main.tf y archivos separados

---

## Prompt 2: Configuración de proveedores y variables seguras

### Contexto
Los proveedores estaban configurados con regiones incorrectas y las API keys de Datadog estaban hardcodeadas en los scripts de user_data, lo cual es un riesgo de seguridad.

### Prompt utilizado
```
Adapta la configuración de Terraform para mi entorno:
- AWS región: eu-north-1 (donde tengo mis instancias EC2)
- Datadog site: datadoghq.eu (mi cuenta es EU)
- Añadir hashicorp/aws como required_provider
- Las variables datadog_api_key y datadog_app_key deben ser sensitive
- Crear terraform.tfvars para las claves (excluido de git)
- Los scripts de user_data deben recibir la API key como variable de templatefile,
  no hardcodeada
- Cambiar DD_SITE en los scripts a "datadoghq.eu"
- Cambiar instance_type de t2.micro/t2.medium a t3.micro (free tier en eu-north-1)
```

### Resultado
Se modificaron los siguientes archivos:
- `provider.tf`: proveedores AWS (eu-north-1) y Datadog (datadoghq.eu) con required_providers completo
- `variables.tf`: variables sensitive para API key y APP key
- `terraform.tfvars`: archivo con claves reales (excluido de git via .gitignore)
- `ec2.tf`: templatefile pasa datadog_api_key como variable, ambas instancias en t3.micro
- `scripts/backend_user_data.sh`: usa variable ${datadog_api_key} y DD_SITE="datadoghq.eu"
- `scripts/frontend_user_data.sh`: mismo tratamiento
- `main.tf`: limpiado de duplicados, solo contiene política IAM y data source

---

## Prompt 3: Integración AWS-Datadog con Terraform

### Contexto
Para que Datadog pueda leer métricas de AWS (CloudWatch, EC2), necesita un rol IAM con permisos y una integración configurada que conecte ambas plataformas.

### Prompt utilizado
```
Crea un archivo tf/datadog_integration.tf que configure:

1. Un rol IAM "DatadogIntegrationRole" que permita a la cuenta de Datadog
   (AWS account 464622532012) asumir el rol usando un external_id generado
   por el recurso datadog_integration_aws.

2. Attach de la política DatadogPolicy (ya existente en main.tf) al rol
   de integración.

3. El recurso datadog_integration_aws que registre la cuenta AWS en Datadog
   usando el account_id obtenido automáticamente con data.aws_caller_identity.

El account_id de AWS debe obtenerse dinámicamente, no hardcodeado.
```

### Resultado
Se creó `tf/datadog_integration.tf` con:
- `aws_iam_role.datadog_integration_role`: rol con trust policy hacia la cuenta de Datadog
- `aws_iam_role_policy_attachment.datadog_integration_policy`: permisos de CloudWatch
- `datadog_integration_aws.aws_integration`: registro de la cuenta AWS en Datadog
- `data.aws_caller_identity.current`: obtención dinámica del Account ID

---

## Prompt 4: Dashboard ampliado de Datadog

### Contexto
El dashboard original solo tenía 3 widgets básicos (CPU, Network In, Network Out). El ejercicio pedía un dashboard más completo con métricas relevantes de la infraestructura.

### Prompt utilizado
```
Amplía el dashboard de Datadog en tf/dashboard.tf con las siguientes secciones
agrupadas:

1. CPU Metrics: CPU Utilization por host (line chart)
2. System Metrics (Agent): Memory Usage %, Disk Usage %, System Load 1min
   (estas métricas vienen del agente Datadog instalado en las instancias)
3. Network Metrics: Network In y Network Out como area charts
4. Instance Status: Running Instances (query_value) y Status Check Failed (bars)

Usa group_definition para agrupar widgets por categoría.
Usa display_type apropiado para cada métrica (line, area, bars).
Layout type: ordered.
```

### Resultado
Se reemplazó `tf/dashboard.tf` con un dashboard completo organizado en 4 grupos con 8 widgets totales, incluyendo métricas tanto de CloudWatch (CPU, Network, Status) como del agente Datadog (Memory, Disk, Load).

---

## Prompt 5: Resolución de errores de Terraform

### Contexto
Al ejecutar `terraform init` y `terraform apply`, surgieron varios errores que había que resolver iterativamente.

### Prompts utilizados
```
Error: Duplicate resource, duplicate provider, duplicate variable entre main.tf
y los archivos separados (provider.tf, variables.tf, dashboard.tf).
¿Cómo limpio main.tf para eliminar los duplicados?
```

```
Error: t2.micro no es free tier en eu-north-1.
Error: S3 bucket "lti-project-code-bucket" ya existe (nombre global).
¿Qué cambios necesito?
```

### Resultado
- Se limpió `main.tf` dejando solo la política IAM y el data source de instancias
- Se cambió instance_type a `t3.micro` (free tier en eu-north-1)
- Se renombró el bucket S3 a `lti-project-code-bucket-vsl` para evitar conflicto de nombres globales

---

## Resumen de archivos generados/modificados

- `tf/provider.tf` - Proveedores AWS (eu-north-1) y Datadog (datadoghq.eu)
- `tf/variables.tf` - Variables sensitive para API keys
- `tf/terraform.tfvars` - Claves reales (excluido de git)
- `tf/main.tf` - Limpiado: solo política IAM y data source
- `tf/ec2.tf` - Instancias t3.micro con API key como variable
- `tf/dashboard.tf` - Dashboard ampliado con 4 grupos y 8 widgets
- `tf/datadog_integration.tf` - Nuevo: integración AWS-Datadog
- `tf/scripts/backend_user_data.sh` - API key como variable, site EU
- `tf/scripts/frontend_user_data.sh` - API key como variable, site EU
- `.gitignore` - Excluye *.tfvars, .terraform/, *.tfstate

## Comandos ejecutados

```bash
# Inicializar Terraform
cd tf/
terraform init

# Verificar plan
terraform plan

# Aplicar infraestructura
terraform apply

# Resultado: 17 recursos creados exitosamente
# - 2 instancias EC2 (t3.micro) con agente Datadog
# - Dashboard en Datadog con métricas de CPU, Memory, Disk, Network, Status
# - Integración AWS-Datadog configurada
# - S3 bucket, IAM roles, Security Groups
```

## Notas adicionales

- La región eu-north-1 (Estocolmo) usa t3.micro como free tier en lugar de t2.micro.
- Los nombres de buckets S3 son globales en AWS, por lo que se añadió sufijo "-vsl" para evitar conflictos.
- El recurso `datadog_integration_aws` genera un warning de deprecación sugiriendo usar `datadog_integration_aws_account`. Se mantuvo la versión actual por compatibilidad con el provider ~> 3.0.
- Las métricas del agente Datadog (memory, disk, load) pueden tardar varios minutos en aparecer tras el arranque de las instancias.
- Las API keys de Datadog nunca se suben al repositorio gracias al .gitignore que excluye *.tfvars.
