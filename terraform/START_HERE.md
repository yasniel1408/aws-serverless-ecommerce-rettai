# 🚀 Inicio Rápido - Deploy para rettai.com

Este documento te guía paso a paso para desplegar tu infraestructura serverless.

## ✅ Pre-requisitos Verificados

- ✅ Dominio: **rettai.com**
- ✅ Route53 Zone ID: **Z002173930WUTNLQN6AQK**
- ✅ Zona DNS ya configurada y funcionando

## 📦 Recursos a Crear

Tu configuración creará **11 recursos** en AWS:

1. WAF Web ACL (reglas de seguridad)
2. S3 Bucket (almacenamiento de contenido)
3. S3 Bucket Policy (permisos)
4. S3 Public Access Block (seguridad)
5. CloudFront OAI (Origin Access Identity)
6. ACM Certificate (SSL/TLS para *.rettai.com)
7. ACM Validation Records (CNAME temporales)
8. CloudFront Distribution (CDN)
9. Route53 A Record (rettai.com → CloudFront)
10. Route53 A Record (www.rettai.com → CloudFront)

**NO** creará nueva hosted zone (usa la existente).

## 🎯 Comandos de Deployment

```bash
# 1. Ir al directorio de terraform
cd terraform

# 2. Copiar configuración de rettai.com
cp terraform.tfvars.rettai terraform.tfvars

# 3. Inicializar Terraform
terraform init

# 4. Ver plan (opcional pero recomendado)
terraform plan

# 5. Aplicar infraestructura
terraform apply

# Escribe 'yes' cuando te lo pida
# ⏱️ Tiempo estimado: 15-20 minutos
```

## ⏱️ Qué Esperar Durante el Deploy

```
[0-2 min]   Creando WAF, S3, solicitando certificado...
[2-10 min]  Validando certificado SSL (automático)...
[10-25 min] Desplegando CloudFront (global)...
[25-30 min] Creando records DNS...
✅ [30 min] LISTO!
```

## 📤 Subir Tu Aplicación

Una vez terminado el deployment:

```bash
# Obtener nombre del bucket
BUCKET=$(terraform output -raw s3_bucket_name)

# Opción 1: Subir una aplicación completa
aws s3 sync ./tu-app/dist/ s3://$BUCKET/ --delete

# Opción 2: Subir un index.html de prueba
cat > index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Rettai E-Commerce</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        body {
            font-family: system-ui, -apple-system, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
            text-align: center;
        }
        h1 { color: #0066cc; }
    </style>
</head>
<body>
    <h1>🚀 Rettai E-Commerce</h1>
    <p>Infraestructura serverless desplegada con éxito!</p>
    <p>Powered by AWS CloudFront, WAF, S3 y Terraform</p>
</body>
</html>
EOF

aws s3 cp index.html s3://$BUCKET/
```

## 🌐 Acceder a Tu Sitio

```bash
# Ver la URL
terraform output custom_domain_url

# Resultado: https://rettai.com
```

Abre en tu navegador:
- https://rettai.com
- https://www.rettai.com

Ambas URLs apuntarán al mismo contenido.

## 🔧 Comandos Útiles

```bash
# Ver todos los outputs
terraform output

# Ver estado de recursos
terraform state list

# Invalidar cache de CloudFront (después de actualizar contenido)
DIST_ID=$(terraform output -raw cloudfront_distribution_id)
aws cloudfront create-invalidation --distribution-id $DIST_ID --paths "/*"

# Ver logs/errores
terraform show
```

## 🧪 Verificar que Todo Funciona

```bash
# Test 1: Verificar CloudFront
curl -I https://$(terraform output -raw cloudfront_domain_name)

# Test 2: Verificar dominio personalizado
curl -I https://rettai.com

# Test 3: Verificar SSL
echo | openssl s_client -connect rettai.com:443 -servername rettai.com 2>/dev/null | grep 'Verify return code'
# Debe mostrar: Verify return code: 0 (ok)
```

## 📊 Costos Estimados

**Costo mensual aproximado:**
- Route53 Hosted Zone: $0.50 (ya lo tienes)
- CloudFront: $1-5/mes (primeros GB gratis)
- WAF: $5-6/mes
- S3: $0.50/mes
- ACM Certificate: $0 (gratis)

**Total: ~$7-12/mes** (sin tráfico alto)

## 🗑️ Destruir Todo (si necesitas)

```bash
# CUIDADO: Esto eliminará toda la infraestructura
terraform destroy

# Confirma con 'yes'
```

**Esto eliminará:**
- CloudFront distribution
- WAF
- S3 bucket y todo su contenido
- Certificado SSL
- Records A de rettai.com y www.rettai.com

**NO eliminará:**
- Tu hosted zone de Route53 (ya existía antes)

## 📚 Documentación Adicional

- **SETUP_RETTAI.md** → Guía completa específica para rettai.com
- **DEPLOYMENT_FLOW.md** → Timeline detallado del deployment
- **ARCHITECTURE.md** → Diagrama de arquitectura
- **README.md** → Documentación completa de módulos
- **QUICK_START.md** → Guía general

## 🆘 Troubleshooting Rápido

### Error: "Certificate validation timeout"
```bash
# Espera 10-15 minutos. La validación DNS es automática pero puede tardar.
# Verifica que los records CNAME se crearon:
aws route53 list-resource-record-sets \
  --hosted-zone-id Z002173930WUTNLQN6AQK \
  --query "ResourceRecordSets[?Type=='CNAME']"
```

### Error: "Bucket name already exists"
```bash
# El nombre del bucket debe ser único globalmente.
# Edita terraform.tfvars y cambia:
project_name = "rettai-ecommerce"  # O cualquier otro nombre único
```

### CloudFront muestra 403
```bash
# El bucket está vacío. Sube contenido:
echo "Hello Rettai" > index.html
aws s3 cp index.html s3://$(terraform output -raw s3_bucket_name)/
```

### No puedo acceder a https://rettai.com
```bash
# Espera 2-3 minutos después del deployment.
# Verifica que CloudFront esté "Deployed":
aws cloudfront get-distribution \
  --id $(terraform output -raw cloudfront_distribution_id) \
  --query 'Distribution.Status'
```

## 🎉 Siguiente Paso

Una vez que tu infraestructura frontend esté funcionando, puedes añadir:

1. **Backend API** → Módulo de API Gateway + Lambda
2. **Base de Datos** → Módulo de DynamoDB
3. **Autenticación** → Módulo de Cognito
4. **CI/CD** → GitHub Actions para deployment automático

¡Tu infraestructura modular está lista para crecer! 🚀

---

**¿Listo para empezar?**

```bash
cd terraform && cp terraform.tfvars.rettai terraform.tfvars && terraform init && terraform apply
```
