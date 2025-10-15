# AWS Serverless E-Commerce Infrastructure

Infraestructura modular de Terraform para CloudFront con Route53 y WAF.

## Arquitectura de Módulos

```
terraform/
├── main.tf                 # Configuración principal y llamadas a módulos
├── variables.tf            # Variables de configuración
├── outputs.tf              # Outputs de la infraestructura
├── terraform.tfvars.example # Ejemplo de configuración
└── modules/
    ├── route53/           # Módulo de Route53
    ├── waf/               # Módulo de WAF
    ├── s3-origin/         # Módulo de S3 + OAI
    └── cloudfront/        # Módulo de CloudFront + ACM
```

## Módulos Disponibles

### 1. Route53 Module
Crea una hosted zone en Route53.

**Variables:**
- `domain_name`: Nombre del dominio
- `project_name`: Nombre del proyecto
- `environment`: Ambiente (dev, staging, prod)

**Outputs:**
- `zone_id`: ID de la hosted zone
- `name_servers`: Nameservers del dominio

### 2. WAF Module
Crea un Web ACL con reglas de seguridad configurables.

**Variables:**
- `enable_core_rule_set`: Habilitar AWS Managed Rules Core (default: true)
- `enable_known_bad_inputs`: Habilitar AWS Managed Bad Inputs (default: true)
- `enable_rate_limiting`: Habilitar rate limiting (default: true)
- `rate_limit`: Límite de requests por IP (default: 2000)
- `enable_geo_blocking`: Habilitar bloqueo geográfico (default: false)
- `blocked_countries`: Lista de códigos de países a bloquear

**Outputs:**
- `web_acl_id`: ID del Web ACL
- `web_acl_arn`: ARN del Web ACL

### 3. S3 Origin Module
Crea un bucket S3 con Origin Access Identity para CloudFront.

**Variables:**
- `bucket_name`: Nombre del bucket
- `enable_versioning`: Habilitar versionado (default: false)

**Outputs:**
- `bucket_id`: ID del bucket
- `bucket_regional_domain_name`: Domain name del bucket
- `oai_cloudfront_access_identity_path`: Path del OAI

### 4. CloudFront Module
Crea una distribución CloudFront con certificado ACM y DNS records.

**Variables:**
- `domain_name`: Dominio personalizado
- `origin_domain_name`: Domain name del origin (S3)
- `waf_web_acl_arn`: ARN del WAF
- `price_class`: Clase de precio (default: PriceClass_100)
- `default_root_object`: Objeto raíz (default: index.html)
- `enable_ipv6`: Habilitar IPv6 (default: true)
- `create_www_alias`: Crear alias www (default: true)

**Outputs:**
- `distribution_id`: ID de la distribución
- `distribution_domain_name`: Domain name de CloudFront
- `certificate_arn`: ARN del certificado ACM

## Uso

### 1. Inicializar Terraform

```bash
cd terraform
terraform init
```

### 2. Configurar Variables

Copiar el archivo de ejemplo y editarlo:

```bash
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars
```

Configuración mínima requerida:

```hcl
domain_name  = "tu-dominio.com"
project_name = "mi-proyecto"
environment  = "prod"
```

### 3. Validar y Planificar

```bash
terraform validate
terraform plan
```

### 4. Aplicar Infraestructura

```bash
terraform apply
```

### 5. Configurar Nameservers

Obtener los nameservers y configurarlos en tu registrador de dominio:

```bash
terraform output route53_nameservers
```

## Configuración Avanzada

### Personalizar WAF

```hcl
# Deshabilitar geo-blocking
enable_waf_geo_blocking = false

# Aumentar rate limit
waf_rate_limit = 5000

# Personalizar países bloqueados
waf_blocked_countries = ["CN", "RU", "KP", "IR"]
```

### Personalizar CloudFront

```hcl
# Usar distribución global
cloudfront_price_class = "PriceClass_All"

# Ajustar TTL
cloudfront_default_ttl = 7200
cloudfront_max_ttl = 172800

# Deshabilitar alias www
cloudfront_create_www_alias = false
```

### Habilitar Versionado S3

```hcl
enable_s3_versioning = true
```

## Reutilización de Módulos

Los módulos pueden ser reutilizados en otros proyectos:

```hcl
module "my_route53" {
  source = "./modules/route53"
  
  domain_name  = "otro-dominio.com"
  project_name = "otro-proyecto"
  environment  = "dev"
}

module "my_waf" {
  source = "./modules/waf"
  
  providers = {
    aws = aws.us_east_1
  }
  
  project_name         = "otro-proyecto"
  environment          = "dev"
  enable_rate_limiting = false
}
```

## Outputs

- `cloudfront_distribution_id`: ID de la distribución CloudFront
- `cloudfront_domain_name`: Dominio de CloudFront
- `custom_domain_url`: URL del dominio personalizado (https://tu-dominio.com)
- `route53_nameservers`: Nameservers para configurar en el registrador
- `waf_web_acl_arn`: ARN del WAF Web ACL
- `s3_bucket_name`: Nombre del bucket S3 origin
- `acm_certificate_arn`: ARN del certificado SSL

## Notas Importantes

- El certificado ACM y el WAF deben estar en `us-east-1` para CloudFront
- La validación del certificado ACM es automática vía DNS
- El bucket S3 está bloqueado públicamente y solo accesible vía CloudFront OAI
- Los módulos son independientes y pueden ser usados por separado
- Todos los módulos soportan tags personalizados vía variable `tags`

## Limpieza

Para destruir toda la infraestructura:

```bash
terraform destroy
```
