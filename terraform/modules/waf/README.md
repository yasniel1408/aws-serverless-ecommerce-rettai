# WAF Module

Módulo para crear un Web ACL de AWS WAF v2 con reglas de seguridad configurables.

## Uso

```hcl
module "waf" {
  source = "./modules/waf"
  
  providers = {
    aws = aws.us_east_1  # Requerido para CloudFront
  }

  project_name            = "myproject"
  environment             = "prod"
  enable_core_rule_set    = true
  enable_known_bad_inputs = true
  enable_rate_limiting    = true
  rate_limit              = 2000
  enable_geo_blocking     = true
  blocked_countries       = ["CN", "RU", "KP"]
  
  tags = {
    SecurityLevel = "high"
  }
}
```

## Variables

| Variable | Tipo | Default | Descripción |
|----------|------|---------|-------------|
| project_name | string | - | Nombre del proyecto (requerido) |
| environment | string | - | Ambiente: dev, staging, prod (requerido) |
| enable_core_rule_set | bool | true | Habilitar AWS Managed Rules Core Rule Set |
| enable_known_bad_inputs | bool | true | Habilitar AWS Managed Rules Known Bad Inputs |
| enable_rate_limiting | bool | true | Habilitar rate limiting |
| rate_limit | number | 2000 | Límite de requests por IP en 5 minutos |
| enable_geo_blocking | bool | false | Habilitar bloqueo geográfico |
| blocked_countries | list(string) | [] | Códigos de países a bloquear (ISO 3166-1 alpha-2) |
| tags | map(string) | {} | Tags adicionales |

## Outputs

| Output | Descripción |
|--------|-------------|
| web_acl_id | ID del Web ACL |
| web_acl_arn | ARN del Web ACL |
| web_acl_name | Nombre del Web ACL |

## Reglas Incluidas

### 1. Core Rule Set (opcional)
Protección contra vulnerabilidades OWASP Top 10:
- SQL injection
- Cross-site scripting (XSS)
- Local file inclusion (LFI)
- Remote file inclusion (RFI)

### 2. Known Bad Inputs (opcional)
Bloquea patrones de entrada maliciosos conocidos.

### 3. Rate Limiting (opcional)
Limita el número de requests por IP en un período de 5 minutos.

### 4. Geo Blocking (opcional)
Bloquea tráfico de países específicos.

## Recursos Creados

- `aws_wafv2_web_acl`: Web ACL con reglas configurables

## Notas

- Para CloudFront, el WAF debe estar en la región `us-east-1`
- El scope es `CLOUDFRONT` por defecto
- Todas las reglas incluyen métricas de CloudWatch
- La acción por defecto es `allow`
