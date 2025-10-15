# Flujo de Deployment para rettai.com

## Arquitectura Implementada

```
┌─────────────────────────────────────────────────────────────────┐
│                         Internet Users                           │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         │ DNS Query
                         ▼
           ┌──────────────────────────────┐
           │  Route53 (EXISTENTE)         │
           │  Zone ID: Z002173930W...     │
           │  rettai.com                  │
           │  www.rettai.com              │
           └──────────┬───────────────────┘
                      │
                      │ A Record (Alias)
                      ▼
        ┌─────────────────────────────────┐
        │   CloudFront Distribution       │
        │   • SSL: *.rettai.com           │
        │   • WAF: Habilitado             │
        │   • Price Class: 100            │
        └────────┬────────────────────────┘
                 │
                 │ OAI
                 ▼
        ┌─────────────────┐
        │  S3 Bucket      │
        │  ecommerce-     │
        │  prod-origin    │
        └─────────────────┘
```

## Diferencia Clave

### ❌ Configuración Original (Crea Nueva Zona)
```hcl
create_route53_zone = true
existing_route53_zone_id = ""
```
→ Crea nueva hosted zone
→ Necesitas configurar nameservers en registrador
→ Propagación DNS: hasta 48 horas

### ✅ Configuración para rettai.com (Usa Zona Existente)
```hcl
create_route53_zone = false
existing_route53_zone_id = "Z002173930WUTNLQN6AQK"
```
→ Usa tu zona existente
→ **NO** necesitas cambiar nameservers
→ DNS funciona inmediatamente

## Recursos por Crear vs Reusar

| Recurso | Estado | Acción |
|---------|--------|--------|
| Route53 Hosted Zone | ✅ Existe | **REUSAR** (Z002173930WUTNLQN6AQK) |
| Route53 A Record (rettai.com) | ❌ No existe | **CREAR** |
| Route53 A Record (www.rettai.com) | ❌ No existe | **CREAR** |
| ACM Certificate | ❌ No existe | **CREAR** (*.rettai.com) |
| ACM Validation Records | ❌ No existe | **CREAR** (CNAME temporales) |
| CloudFront Distribution | ❌ No existe | **CREAR** |
| WAF Web ACL | ❌ No existe | **CREAR** |
| S3 Bucket | ❌ No existe | **CREAR** (ecommerce-prod-origin) |
| S3 Bucket Policy | ❌ No existe | **CREAR** |
| CloudFront OAI | ❌ No existe | **CREAR** |

## Timeline del Deployment

```
t=0min    terraform apply
  │
  ├─ WAF Web ACL creado (30s)
  ├─ S3 Bucket creado (10s)
  └─ ACM Certificate request (10s)
  
t=1min    Validación DNS
  │
  ├─ Records CNAME en Route53 (5s)
  └─ Esperando validación ACM (5-10min)
  
t=10min   Certificate validado ✅
  │
  └─ CloudFront Distribution (10-15min)
  
t=25min   CloudFront desplegado ✅
  │
  ├─ Records A en Route53 (5s)
  └─ Propagación final (1-2min)
  
t=30min   ✅ TODO LISTO
  │
  └─ https://rettai.com funcionando
```

## Comandos Step-by-Step

### 1. Preparación (1 minuto)
```bash
cd terraform
cp terraform.tfvars.rettai terraform.tfvars
terraform init
```

### 2. Verificación (30 segundos)
```bash
# Ver qué se va a crear
terraform plan | grep -E "will be created|Plan:"

# Deberías ver:
# Plan: 11 to add, 0 to change, 0 to destroy
```

### 3. Deployment (15-20 minutos)
```bash
# Aplicar infraestructura
terraform apply -auto-approve

# Monitorear progreso
watch -n 10 'terraform show | grep -i status'
```

### 4. Verificación SSL (esperar validación)
```bash
# Verificar estado del certificado
aws acm describe-certificate \
  --certificate-arn $(terraform output -raw acm_certificate_arn) \
  --region us-east-1 \
  --query 'Certificate.Status'

# Debe mostrar: "ISSUED"
```

### 5. Subir Contenido
```bash
BUCKET=$(terraform output -raw s3_bucket_name)

# Crear página de prueba
echo '<!DOCTYPE html>
<html>
<head><title>Rettai</title></head>
<body>
  <h1>🚀 Rettai E-Commerce</h1>
  <p>Infraestructura serverless con Terraform</p>
</body>
</html>' > index.html

# Subir a S3
aws s3 cp index.html s3://$BUCKET/
```

### 6. Testing
```bash
# Test directo CloudFront (inmediato)
curl -I https://$(terraform output -raw cloudfront_domain_name)

# Test dominio personalizado (1-2 min después)
curl -I https://rettai.com
curl -I https://www.rettai.com

# Verificar SSL
openssl s_client -connect rettai.com:443 -servername rettai.com < /dev/null 2>/dev/null | grep 'subject='
```

## Outputs Importantes

```bash
# Ver todos los outputs
terraform output

# Outputs clave:
terraform output cloudfront_distribution_id  # Para invalidaciones
terraform output cloudfront_domain_name      # Para testing
terraform output custom_domain_url           # URL final
terraform output s3_bucket_name              # Para subir contenido
terraform output waf_web_acl_arn            # Para monitoreo
```

## Troubleshooting en Tiempo Real

### Problema 1: Certificate validation stuck
```bash
# Verificar que los records CNAME existan
aws route53 list-resource-record-sets \
  --hosted-zone-id Z002173930WUTNLQN6AQK \
  --query "ResourceRecordSets[?Type=='CNAME']" \
  --output table
```

### Problema 2: CloudFront no accesible
```bash
# Verificar estado de la distribución
aws cloudfront get-distribution \
  --id $(terraform output -raw cloudfront_distribution_id) \
  --query 'Distribution.Status'

# Debe mostrar: "Deployed"
```

### Problema 3: 403 Forbidden
```bash
# Verificar contenido en S3
aws s3 ls s3://$(terraform output -raw s3_bucket_name)/

# Subir index.html si está vacío
echo "Hello" > index.html
aws s3 cp index.html s3://$(terraform output -raw s3_bucket_name)/
```

## Clean Up (Destruir Todo)

```bash
# Advertencia: Esto eliminará:
# - CloudFront distribution
# - WAF Web ACL
# - S3 bucket (y contenido)
# - ACM certificate
# - Route53 A records
#
# NO eliminará:
# - Hosted zone de rettai.com

terraform destroy -auto-approve
```

## Monitoreo Post-Deployment

### CloudWatch Metrics
```bash
# WAF metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/WAFV2 \
  --metric-name AllowedRequests \
  --dimensions Name=Rule,Value=ALL \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Sum
```

### CloudFront Logs (opcional)
Para habilitar logging, añadir a terraform.tfvars:
```hcl
# TODO: Añadir soporte de logging en módulo CloudFront
```

## Siguiente Fase: Backend

Una vez que la infraestructura frontend funcione, añadir:

1. **API Gateway** → Endpoints REST/HTTP
2. **Lambda Functions** → Lógica de negocio
3. **DynamoDB** → Base de datos
4. **Cognito** → Autenticación usuarios
5. **S3 + Lambda** → Procesamiento de imágenes
6. **SNS/SQS** → Notificaciones

Ver arquitectura completa en `ARCHITECTURE.md`.
