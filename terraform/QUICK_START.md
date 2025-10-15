# Guía de Inicio Rápido

## Prerrequisitos

1. **Terraform instalado** (>= 1.0)
   ```bash
   terraform version
   ```

2. **AWS CLI configurado** con credenciales
   ```bash
   aws configure
   ```

3. **Dominio registrado** (puede ser de cualquier registrador)

## Paso 1: Configuración Inicial

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

Editar `terraform.tfvars` con tu configuración:

### Opción A: Usar Route53 Hosted Zone Existente (Recomendado)

```hcl
domain_name  = "rettai.com"
project_name = "mi-ecommerce"
environment  = "prod"

# Route53 - Usar zona existente
create_route53_zone      = false
existing_route53_zone_id = "Z002173930WUTNLQN6AQK"  # Tu hosted zone ID
```

### Opción B: Crear Nueva Route53 Hosted Zone

```hcl
domain_name  = "tu-dominio.com"
project_name = "mi-ecommerce"
environment  = "prod"

# Route53 - Crear nueva zona
create_route53_zone      = true
existing_route53_zone_id = ""
```

## Paso 2: Inicializar Terraform

```bash
terraform init
```

Este comando descarga los providers y prepara los módulos.

## Paso 3: Revisar el Plan

```bash
terraform plan
```

Revisa los recursos que se van a crear (aproximadamente 15 recursos).

## Paso 4: Aplicar la Infraestructura

```bash
terraform apply
```

Escribe `yes` cuando te lo pida. Este proceso tarda ~10-15 minutos.

**Nota**: La validación del certificado SSL puede tardar varios minutos.

## Paso 5: Configurar Nameservers

**Solo si creaste una nueva hosted zone** (`create_route53_zone = true`):

Después de aplicar, obtén los nameservers:

```bash
terraform output route53_nameservers
```

Configura estos nameservers en tu registrador de dominio. Ejemplo:

```
ns-123.awsdns-12.com
ns-456.awsdns-45.net
ns-789.awsdns-78.org
ns-012.awsdns-01.co.uk
```

**Importante**: Los cambios DNS pueden tardar hasta 48 horas en propagarse.

**Si usas una hosted zone existente**: Este paso no es necesario, tus nameservers ya están configurados.

## Paso 6: Subir Contenido al S3

```bash
# Obtener el nombre del bucket
BUCKET_NAME=$(terraform output -raw s3_bucket_name)

# Subir archivos
aws s3 cp ./tu-aplicacion/ s3://$BUCKET_NAME/ --recursive
```

## Paso 7: Verificar el Deployment

```bash
# Ver la URL de CloudFront
terraform output custom_domain_url

# O visitar directamente
echo "https://$(terraform output -raw cloudfront_domain_name)"
```

Espera ~15 minutos para que CloudFront distribuya el contenido.

## Comandos Útiles

### Ver todos los outputs
```bash
terraform output
```

### Ver recursos creados
```bash
terraform state list
```

### Actualizar infraestructura
```bash
terraform apply
```

### Destruir todo
```bash
terraform destroy
```

### Invalidar caché de CloudFront
```bash
DISTRIBUTION_ID=$(terraform output -raw cloudfront_distribution_id)
aws cloudfront create-invalidation --distribution-id $DISTRIBUTION_ID --paths "/*"
```

## Estructura de Archivos

```
terraform/
├── main.tf                    # Configuración principal
├── variables.tf               # Variables de entrada
├── outputs.tf                 # Outputs de la infraestructura
├── terraform.tfvars          # Tu configuración (no versionada)
├── terraform.tfvars.example  # Ejemplo de configuración
└── modules/                   # Módulos reutilizables
    ├── route53/
    ├── waf/
    ├── s3-origin/
    └── cloudfront/
```

## Personalización

### Cambiar TTL de caché

```hcl
cloudfront_default_ttl = 7200  # 2 horas
cloudfront_max_ttl = 172800    # 48 horas
```

### Deshabilitar geo-blocking

```hcl
enable_waf_geo_blocking = false
```

### Aumentar rate limit

```hcl
waf_rate_limit = 5000
```

### Usar distribución global

```hcl
cloudfront_price_class = "PriceClass_All"
```

## Troubleshooting

### Error: "Module not installed"
```bash
terraform init
```

### Error: "Certificate validation timeout"
Verifica que los nameservers estén configurados correctamente en tu registrador.

### Error: "Bucket name already exists"
Cambia el `project_name` en `terraform.tfvars` para generar un nombre único.

### CloudFront muestra error 403
El bucket S3 puede estar vacío. Sube contenido con `aws s3 cp`.

## Costos Estimados

- **Route53 Hosted Zone**: ~$0.50/mes
- **CloudFront**: Pay-as-you-go (primeros 10TB: $0.085/GB)
- **WAF**: ~$5/mes + $1 por millón de requests
- **S3**: ~$0.023/GB
- **ACM Certificate**: Gratis

**Costo mínimo estimado**: ~$6-10/mes sin tráfico significativo.

## Siguiente Paso

Una vez configurada la infraestructura, puedes:
1. Añadir más módulos (Lambda, API Gateway, DynamoDB)
2. Configurar CI/CD para deployment automático
3. Añadir monitoreo con CloudWatch
4. Implementar logs de acceso

Ver [README.md](README.md) para documentación completa de los módulos.
