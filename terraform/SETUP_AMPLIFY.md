# 🚀 Setup Actualizado para rettai.com con Amplify

## Cambio Principal: Amplify en vez de S3

La arquitectura ha cambiado para usar **AWS Amplify** que:
- ✅ Deploya automáticamente desde GitHub
- ✅ Maneja el hosting de ambas apps (main y admin)
- ✅ SSL/TLS automático
- ✅ CloudFront integrado
- ✅ CI/CD automático

**NO necesitas**: S3, CloudFront manual, subir archivos manualmente

## 📋 Prerrequisitos

### 1. Repositorio GitHub

Sube tu código a GitHub:

```bash
cd /Users/yasnielfajardo/Documents/PROYECTOS/YASCODE/aws-serverless-ecommerce
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/TU-USUARIO/aws-serverless-ecommerce.git
git push -u origin main
```

### 2. GitHub Personal Access Token

1. Ve a GitHub → Settings → Developer settings → Personal access tokens
2. Generate new token (classic)
3. Selecciona scopes:
   - ✅ `repo` (full control)
   - ✅ `admin:repo_hook`
4. Copia el token generado

### 3. Configurar Token

```bash
export TF_VAR_github_token="ghp_tu_token_aqui"
```

## 🎯 Arquitectura

```
GitHub Repository
    ↓ (Push)
AWS Amplify
    ├── web-rettai/ → https://rettai.com/
    └── web-rettai-admin/ → https://rettai.com/admin
    ↓
CloudFront (Automático)
    ↓
Route53 (rettai.com)
```

## ⚙️ Configuración

Edita `terraform/terraform.tfvars.rettai`:

```hcl
# Cambiar esto con tu repositorio
github_repository = "https://github.com/TU-USUARIO/aws-serverless-ecommerce"
github_branch     = "main"

# El token se pasa por variable de entorno
# export TF_VAR_github_token="ghp_xxxxx"
```

## 🚀 Deployment

### 1. Preparar Terraform

```bash
cd terraform
cp terraform.tfvars.rettai terraform.tfvars

# Editar terraform.tfvars con tu repo
nano terraform.tfvars
```

### 2. Inicializar y Aplicar

```bash
# Inicializar
terraform init

# Ver plan
terraform plan

# Aplicar
terraform apply
```

### 3. Esperar Deployment

Amplify tardará ~5-10 minutos en:
1. Clonar el repositorio
2. Build de web-rettai
3. Build de web-rettai-admin
4. Deploy de ambas apps
5. Configurar dominio personalizado

## 🌐 Acceder

Una vez completado:

```bash
# Ver URLs
terraform output

# Acceder
https://rettai.com/        # Main site
https://rettai.com/admin   # Admin panel
```

## 🔄 CI/CD Automático

Después del deployment inicial, cada push a GitHub:

```bash
git add .
git commit -m "Update frontend"
git push
```

Amplify detectará el cambio y:
1. Build automático
2. Deploy automático
3. ~5 minutos después estará live

## 📦 Recursos Creados

- ✅ Amplify App
- ✅ Amplify Branch (main)
- ✅ Domain Association (rettai.com + www)
- ❌ NO S3 (Amplify maneja todo)
- ❌ NO CloudFront manual (Amplify lo incluye)

## 💰 Costos

- Amplify Build: Gratis hasta 1000 min/mes
- Amplify Hosting: Gratis hasta 15GB transferidos/mes
- Route53: $0.50/mes (ya lo tienes)
- WAF: Deshabilitado por defecto (Amplify tiene protección básica)

**Total**: ~$0.50/mes (solo Route53)

## 🛠️ Troubleshooting

### Build falla

Ver logs en AWS Console:
```
AWS Amplify → Apps → rettai-prod → main branch → Build logs
```

### Dominio no resuelve

```bash
# Verificar CNAME en Route53
aws route53 list-resource-record-sets \
  --hosted-zone-id Z002173930WUTNLQN6AQK \
  --query "ResourceRecordSets[?Type=='CNAME']"
```

### Token no válido

```bash
# Verificar token
echo $TF_VAR_github_token

# Si está vacío, exportar de nuevo
export TF_VAR_github_token="ghp_xxxxx"
```

## 📝 Estructura del Monorepo

Amplify espera esta estructura:

```
aws-serverless-ecommerce/
├── frontends/
│   ├── web-rettai/          → Deploy a /
│   │   ├── package.json
│   │   ├── next.config.js
│   │   └── app/
│   └── web-rettai-admin/    → Deploy a /admin
│       ├── package.json
│       ├── next.config.js
│       └── app/
└── terraform/
```

## 🔧 Build Spec

Amplify usa este build spec (automático):

```yaml
version: 1
applications:
  - appRoot: frontends/web-rettai
    frontend:
      phases:
        preBuild:
          commands:
            - npm ci
        build:
          commands:
            - npm run build
      artifacts:
        baseDirectory: out
        files:
          - '**/*'
  
  - appRoot: frontends/web-rettai-admin
    frontend:
      phases:
        preBuild:
          commands:
            - npm ci
        build:
          commands:
            - npm run build
      artifacts:
        baseDirectory: out
        files:
          - '**/*'
```

## ✨ Próximos Pasos

1. ✅ Deployar infraestructura con Terraform
2. Push código a GitHub
3. Esperar build automático
4. Acceder a https://rettai.com
5. Desarrollar features y hacer push
6. Amplify auto-deploya

## 🎉 Ventajas vs S3

| S3 Manual | Amplify |
|-----------|---------|
| Build local | Build en la nube |
| `aws s3 sync` manual | Git push automático |
| Invalidación manual | Cache automático |
| Sin CI/CD | CI/CD integrado |
| Sin preview | Preview branches |
| Más setup | Zero config |

## 📚 Más Info

- [Terraform Module Amplify](modules/amplify/README.md)
- [AWS Amplify Docs](https://docs.amplify.aws/)
- [Amplify Pricing](https://aws.amazon.com/amplify/pricing/)
