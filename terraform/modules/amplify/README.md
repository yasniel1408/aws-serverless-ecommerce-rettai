# Amplify Module

Módulo para crear una aplicación AWS Amplify con deployment automático desde GitHub.

## Uso

```hcl
module "amplify" {
  source = "./modules/amplify"

  app_name             = "my-app"
  repository           = "https://github.com/user/repo"
  branch_name          = "main"
  github_access_token  = var.github_token
  domain_name          = "example.com"
  project_name         = "myproject"
  environment          = "prod"
  
  environment_variables = {
    NEXT_PUBLIC_API_URL = "https://api.example.com"
  }
}
```

## Variables

| Variable | Tipo | Default | Descripción |
|----------|------|---------|-------------|
| app_name | string | - | Nombre de la app Amplify (requerido) |
| repository | string | - | URL del repositorio GitHub (requerido) |
| branch_name | string | main | Rama a deployar |
| github_access_token | string | - | Token de GitHub (requerido, sensitive) |
| environment | string | - | Ambiente (requerido) |
| project_name | string | - | Nombre del proyecto (requerido) |
| domain_name | string | - | Dominio personalizado (requerido) |
| enable_auto_branch_creation | bool | false | Crear ramas automáticamente |
| enable_auto_build | bool | true | Build automático en push |
| framework | string | Next.js - SSG | Framework de la app |
| build_spec | string | "" | Build spec personalizado (YAML) |
| environment_variables | map(string) | {} | Variables de entorno |
| tags | map(string) | {} | Tags adicionales |

## Outputs

| Output | Descripción |
|--------|-------------|
| app_id | ID de la app Amplify |
| app_arn | ARN de la app |
| default_domain | Dominio por defecto de Amplify |
| branch_url | URL de la rama |
| custom_domain_url | URL del dominio personalizado |
| domain_association_status | Status de la asociación de dominio |

## Recursos Creados

- `aws_amplify_app`: Aplicación Amplify
- `aws_amplify_branch`: Rama principal
- `aws_amplify_domain_association`: Asociación de dominio personalizado

## Características

### Multi-App Support

El módulo está configurado para deployar múltiples apps Next.js desde un monorepo:

```yaml
applications:
  - appRoot: frontends/web-rettai       # App principal
  - appRoot: frontends/web-rettai-admin # App admin
```

### Routing Rules

Configurado para:
- `/` → web-rettai (SPA routing)
- `/admin` → web-rettai-admin (SPA routing con basePath)
- Fallback 404 → index.html (SPA support)

### Build Spec

Default build spec para Next.js con monorepo:

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
```

Puedes sobreescribirlo con `build_spec` variable.

## Integración con GitHub

### 1. Crear GitHub Personal Access Token

1. GitHub → Settings → Developer settings → Personal access tokens
2. Generate new token (classic)
3. Scopes necesarios:
   - `repo` (full control)
   - `admin:repo_hook` (webhooks)

### 2. Guardar token de forma segura

**Opción 1: Variable de entorno**
```bash
export TF_VAR_github_token="ghp_xxxxx"
```

**Opción 2: AWS Secrets Manager**
```hcl
data "aws_secretsmanager_secret_version" "github_token" {
  secret_id = "github-token"
}

module "amplify" {
  github_access_token = data.aws_secretsmanager_secret_version.github_token.secret_string
}
```

**Opción 3: terraform.tfvars (NO versionarlo)**
```hcl
github_token = "ghp_xxxxx"
```

## Deployment Flow

```
1. Push a GitHub (main branch)
   ↓
2. Amplify detecta cambio (webhook)
   ↓
3. Clone del repositorio
   ↓
4. Build de ambas apps (web-rettai y web-rettai-admin)
   ↓
5. Deploy automático
   ↓
6. URL disponible:
   - https://rettai.com/
   - https://rettai.com/admin
```

## Configuración Dominio Personalizado

Amplify creará un CNAME record que debe estar en Route53:

```
CNAME: _xxx.rettai.com → _xxx.acm-validations.aws
```

Esto se hace automáticamente si usas Route53.

## Environment Variables

Variables de entorno disponibles en build:

```hcl
environment_variables = {
  NEXT_PUBLIC_API_URL = "https://api.rettai.com"
  NODE_ENV            = "production"
  CUSTOM_VAR          = "value"
}
```

## Monorepo Structure

```
repo/
├── frontends/
│   ├── web-rettai/         → Deploy a /
│   └── web-rettai-admin/   → Deploy a /admin
└── terraform/
```

## Custom Rules

El módulo incluye reglas de routing para SPA:

```hcl
# Admin routes
/admin     → /admin/index.html (200)
/admin/*   → /admin/index.html (200)

# Main app fallback
/<*>       → /index.html (404-200)
```

## Stages

El módulo mapea environments a stages:

- `prod` → PRODUCTION
- `staging` → BETA
- `dev` → DEVELOPMENT

## Costos

- Amplify Hosting: Gratis hasta 1000 build minutos/mes
- Por encima: $0.01/build minuto
- Hosting: $0.15/GB transferido
- Storage: $0.023/GB/mes

## Troubleshooting

### Build falla

Ver logs en AWS Console → Amplify → App → Branch → Build logs

### Dominio no resuelve

Verificar en Route53 que el CNAME de validación esté creado.

### Apps no se despliegan correctamente

Verificar `build_spec` y estructura del monorepo.

## Notas

- Amplify maneja el SSL/TLS automáticamente
- No requiere S3 ni CloudFront manual
- Deployment automático en cada push
- Soporta preview branches
- Cache automático de node_modules
