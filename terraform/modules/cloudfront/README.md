# CloudFront Module

Módulo para crear una distribución CloudFront con certificado ACM, WAF y DNS records en Route53.

## Uso

```hcl
module "cloudfront" {
  source = "./modules/cloudfront"
  
  providers = {
    aws = aws.us_east_1  # Requerido para ACM
  }

  domain_name                   = "example.com"
  project_name                  = "myproject"
  environment                   = "prod"
  route53_zone_id               = module.route53.zone_id
  origin_domain_name            = module.s3_origin.bucket_regional_domain_name
  origin_id                     = "S3-origin"
  origin_access_identity_path   = module.s3_origin.oai_cloudfront_access_identity_path
  waf_web_acl_arn               = module.waf.web_acl_arn
  
  price_class                   = "PriceClass_100"
  default_root_object           = "index.html"
  enable_ipv6                   = true
  minimum_protocol_version      = "TLSv1.2_2021"
  default_ttl                   = 3600
  max_ttl                       = 86400
  min_ttl                       = 0
  create_www_alias              = true
  
  tags = {
    CDN = "cloudfront"
  }
}
```

## Variables

| Variable | Tipo | Default | Descripción |
|----------|------|---------|-------------|
| domain_name | string | - | Dominio personalizado (requerido) |
| project_name | string | - | Nombre del proyecto (requerido) |
| environment | string | - | Ambiente (requerido) |
| route53_zone_id | string | - | ID de la hosted zone (requerido) |
| origin_domain_name | string | - | Domain name del origin (requerido) |
| origin_id | string | - | ID del origin (requerido) |
| origin_access_identity_path | string | - | Path del OAI (requerido) |
| waf_web_acl_arn | string | - | ARN del WAF (requerido) |
| price_class | string | PriceClass_100 | Clase de precio de CloudFront |
| default_root_object | string | index.html | Objeto raíz por defecto |
| enable_ipv6 | bool | true | Habilitar IPv6 |
| minimum_protocol_version | string | TLSv1.2_2021 | Versión mínima de TLS |
| default_ttl | number | 3600 | TTL por defecto (segundos) |
| max_ttl | number | 86400 | TTL máximo (segundos) |
| min_ttl | number | 0 | TTL mínimo (segundos) |
| create_www_alias | bool | true | Crear alias www |
| tags | map(string) | {} | Tags adicionales |

## Outputs

| Output | Descripción |
|--------|-------------|
| distribution_id | ID de la distribución CloudFront |
| distribution_arn | ARN de la distribución |
| distribution_domain_name | Domain name de CloudFront |
| distribution_hosted_zone_id | Hosted zone ID de CloudFront |
| certificate_arn | ARN del certificado ACM |
| custom_domain_url | URL del dominio personalizado |

## Recursos Creados

- `aws_acm_certificate`: Certificado SSL/TLS
- `aws_route53_record`: Validación DNS del certificado
- `aws_acm_certificate_validation`: Validación del certificado
- `aws_cloudfront_distribution`: Distribución CDN
- `aws_route53_record`: Record A para el dominio principal
- `aws_route53_record`: Record A para www (opcional)

## Price Classes

| Clase | Regiones | Costo |
|-------|----------|-------|
| PriceClass_100 | USA, Canadá, Europa | Bajo |
| PriceClass_200 | PriceClass_100 + Asia, África, Oceanía | Medio |
| PriceClass_All | Todas las regiones | Alto |

## Características

- **HTTPS**: Certificado ACM gratuito con validación automática
- **Custom Domain**: Soporte para dominio personalizado y www
- **WAF Integration**: Protección con reglas de seguridad
- **SPA Support**: Error pages redirigidas a index.html
- **Compression**: Compresión automática habilitada
- **Caching**: TTL configurable para optimizar rendimiento

## Notas

- El certificado ACM debe estar en `us-east-1` para CloudFront
- La validación DNS es automática y puede tardar varios minutos
- Los cambios en CloudFront pueden tardar ~15 minutos en propagarse
- El dominio debe estar configurado en Route53 antes de crear la distribución
