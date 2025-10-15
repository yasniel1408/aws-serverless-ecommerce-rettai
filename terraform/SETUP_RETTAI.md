# Setup para rettai.com

Guía rápida para desplegar la infraestructura usando tu dominio existente `rettai.com`.

## Información del Dominio

- **Dominio**: rettai.com
- **Hosted Zone ID**: Z002173930WUTNLQN6AQK
- **Estado**: Zona existente en Route53

## Pasos Rápidos

### 1. Usar la configuración pre-configurada

```bash
cd terraform

# Copiar configuración de rettai.com
cp terraform.tfvars.rettai terraform.tfvars

# O crear manualmente con estos valores:
cat > terraform.tfvars << 'EOF'
aws_region   = "us-east-1"
domain_name  = "rettai.com"
project_name = "ecommerce"
environment  = "prod"

# Usar zona existente
create_route53_zone      = false
existing_route53_zone_id = "Z002173930WUTNLQN6AQK"

# WAF habilitado con reglas básicas
enable_waf_core_rules    = true
enable_waf_bad_inputs    = true
enable_waf_rate_limit    = true
waf_rate_limit           = 2000
enable_waf_geo_blocking  = true
waf_blocked_countries    = ["CN", "RU", "KP"]

# S3
enable_s3_versioning = false

# CloudFront
cloudfront_price_class          = "PriceClass_100"
cloudfront_default_root_object  = "index.html"
cloudfront_enable_ipv6          = true
cloudfront_min_tls_version      = "TLSv1.2_2021"
cloudfront_default_ttl          = 3600
cloudfront_max_ttl              = 86400
cloudfront_min_ttl              = 0
cloudfront_create_www_alias     = true
EOF
```

### 2. Inicializar Terraform

```bash
terraform init
```

### 3. Ver el plan

```bash
terraform plan
```

Deberías ver aproximadamente estos recursos:
- ✅ WAF Web ACL (1)
- ✅ S3 Bucket + Policy + OAI (4)
- ✅ ACM Certificate + Validation (3)
- ✅ CloudFront Distribution (1)
- ✅ Route53 Records para rettai.com y www.rettai.com (2)
- ❌ **NO** crea nueva Hosted Zone (ya existe)

**Total: ~11 recursos**

### 4. Aplicar

```bash
terraform apply
```

Escribe `yes`. Tiempo estimado: 10-15 minutos.

### 5. Verificar

```bash
# Ver outputs
terraform output

# URLs creadas
terraform output custom_domain_url
# Resultado: https://rettai.com

# CloudFront domain
terraform output cloudfront_domain_name
```

## Dominios Creados

Después del deployment, tendrás:

- ✅ `https://rettai.com` → CloudFront Distribution
- ✅ `https://www.rettai.com` → CloudFront Distribution (alias)

Ambos apuntarán al mismo contenido del S3 bucket.

## Subir Contenido

```bash
# Obtener nombre del bucket
BUCKET=$(terraform output -raw s3_bucket_name)
echo $BUCKET
# Resultado: ecommerce-prod-origin

# Subir archivos
aws s3 cp ./dist/ s3://$BUCKET/ --recursive

# O subir un index.html de prueba
cat > index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Rettai E-Commerce</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body>
    <h1>🚀 Rettai E-Commerce Platform</h1>
    <p>Welcome to your serverless e-commerce platform!</p>
    <p>Powered by AWS CloudFront, WAF, and S3.</p>
</body>
</html>
EOF

aws s3 cp index.html s3://$BUCKET/
```

## Verificar el Despliegue

### Opción 1: CloudFront URL (inmediato)

```bash
CLOUDFRONT_URL=$(terraform output -raw cloudfront_domain_name)
curl -I https://$CLOUDFRONT_URL
```

### Opción 2: Dominio personalizado (puede tardar)

```bash
# Verificar resolución DNS
dig rettai.com
dig www.rettai.com

# Test con curl
curl -I https://rettai.com
curl -I https://www.rettai.com
```

**Nota**: El certificado SSL puede tardar 5-10 minutos en validarse.

## Recursos Creados para rettai.com

```
rettai.com (Hosted Zone: Z002173930WUTNLQN6AQK)
├── A Record: rettai.com → CloudFront
├── A Record: www.rettai.com → CloudFront
└── TXT Records: Validación ACM (temporales)

CloudFront Distribution
├── Origins: S3 bucket (ecommerce-prod-origin)
├── SSL/TLS: ACM Certificate para *.rettai.com
├── WAF: Web ACL con reglas de seguridad
└── Cache: TTL configurado

S3 Bucket: ecommerce-prod-origin
├── Private Access Only
├── OAI configured
└── Static content hosting

WAF Web ACL
├── Core Rule Set (OWASP)
├── Known Bad Inputs
├── Rate Limiting: 2000 req/5min
└── Geo Blocking: CN, RU, KP
```

## Invalidar Cache

Cuando actualices contenido en S3:

```bash
DISTRIBUTION_ID=$(terraform output -raw cloudfront_distribution_id)
aws cloudfront create-invalidation \
  --distribution-id $DISTRIBUTION_ID \
  --paths "/*"
```

## Costos Estimados

Para rettai.com con tráfico moderado:

- Route53 (existente): $0.50/mes
- CloudFront: ~$1-5/mes (primeros GB gratis)
- WAF: ~$5-6/mes base
- S3: ~$0.50/mes
- ACM: Gratis

**Total estimado**: $7-12/mes

## Siguientes Pasos

1. **CI/CD**: Automatizar deployment a S3
2. **Backend**: Añadir Lambda + API Gateway
3. **Database**: DynamoDB para productos
4. **Auth**: Cognito para usuarios
5. **Monitoring**: CloudWatch dashboards

## Troubleshooting

### Error: "Certificate validation timeout"
```bash
# Verificar records DNS
aws route53 list-resource-record-sets \
  --hosted-zone-id Z002173930WUTNLQN6AQK \
  --query "ResourceRecordSets[?Type=='CNAME']"
```

### Error: "Bucket already exists"
Cambia el `project_name` en terraform.tfvars:
```hcl
project_name = "rettai-ecommerce"  # Nombre único
```

### CloudFront muestra 403
```bash
# Verificar que el bucket tenga contenido
aws s3 ls s3://$(terraform output -raw s3_bucket_name)/
```

## Limpieza

Para destruir todos los recursos (excepto la hosted zone):

```bash
terraform destroy
```

Esto eliminará:
- CloudFront distribution
- WAF Web ACL
- S3 bucket y contenido
- ACM certificate
- Route53 records (A)

**NO** eliminará:
- Hosted Zone de rettai.com (ya existía)
