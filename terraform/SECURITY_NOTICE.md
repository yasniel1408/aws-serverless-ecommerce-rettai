# ⚠️ IMPORTANTE: Seguridad del GitHub Token

## 🔐 Token Configurado

El GitHub token está configurado en `terraform.tfvars.rettai`:

```hcl
github_token = "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"
```

## ⚠️ ADVERTENCIA DE SEGURIDAD

**NUNCA SUBAS ESTE ARCHIVO A GIT**

El archivo `terraform.tfvars.rettai` contiene:
- ❌ GitHub Personal Access Token (sensible)
- ❌ Configuración de infraestructura privada

## ✅ Protección Configurada

### 1. GitIgnore Configurado

```gitignore
# En terraform/.gitignore y raíz del repo
*.tfvars          # Ignora TODOS los archivos .tfvars
*.tfvars.json     # También los JSON
!*.tfvars.example # Excepto los .example
```

### 2. Verificar que está ignorado

```bash
# Verificar que no se va a subir
cd /Users/yasnielfajardo/Documents/PROYECTOS/YASCODE/aws-serverless-ecommerce
git status

# NO debería aparecer:
# - terraform.tfvars
# - terraform.tfvars.rettai
```

### 3. Si ya lo subiste por error

```bash
# Remover del historial de git
git rm --cached terraform/terraform.tfvars.rettai
git rm --cached terraform/terraform.tfvars
git commit -m "Remove sensitive tfvars files"

# Regenerar token en GitHub
# GitHub → Settings → Developer settings → Personal access tokens
# → Revoke old token → Generate new token
```

## 🔄 Rotar Token (Recomendado)

Si sospechas que el token fue expuesto:

### 1. Revocar token actual

```bash
# GitHub → Settings → Developer settings → Personal access tokens
# Encuentra: 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
# Click "Delete" o "Revoke"
```

### 2. Generar nuevo token

```bash
# GitHub → Settings → Developer settings → Personal access tokens
# Generate new token (classic)
# Scopes: repo, admin:repo_hook
```

### 3. Actualizar en terraform.tfvars

```bash
cd terraform
nano terraform.tfvars.rettai
# Actualizar github_token = "ghp_NUEVO_TOKEN"
```

## 📋 Checklist de Seguridad

Antes de hacer commit:

- [ ] `*.tfvars` está en `.gitignore`
- [ ] `git status` no muestra archivos `.tfvars`
- [ ] Solo se versionan archivos `.tfvars.example`
- [ ] El token no está en ningún archivo versionado
- [ ] No hay tokens en scripts o documentación

## 🔍 Verificar Archivos a Commitear

```bash
# Ver qué archivos se van a subir
git status

# Ver contenido de los archivos staged
git diff --cached

# Asegúrate de NO ver:
# - Tokens (ghp_...)
# - Contraseñas
# - API keys
# - Secrets
```

## 🚨 Si Expones el Token

1. **INMEDIATAMENTE** revoca el token en GitHub
2. Genera uno nuevo
3. Actualiza `terraform.tfvars.rettai`
4. Verifica que `.gitignore` funciona
5. NO hagas `terraform apply` hasta rotar el token

## 💡 Mejores Prácticas

### Opción 1: Variable de Entorno (Más Seguro)

```bash
# En lugar de guardarlo en tfvars
export TF_VAR_github_token="ghp_..."

# En terraform.tfvars.rettai
# Comentar la línea:
# github_token = "..."
```

### Opción 2: AWS Secrets Manager

```bash
# Guardar en AWS Secrets Manager
aws secretsmanager create-secret \
  --name github-token \
  --secret-string "ghp_..." \
  --profile mi-aws

# Usar en Terraform
data "aws_secretsmanager_secret_version" "github_token" {
  secret_id = "github-token"
}

module "amplify" {
  github_access_token = data.aws_secretsmanager_secret_version.github_token.secret_string
}
```

### Opción 3: HashiCorp Vault

Para equipos, usa Vault para gestionar secrets.

## 📚 Referencias

- [GitHub Token Security](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)
- [Terraform Sensitive Variables](https://www.terraform.io/language/values/variables#suppressing-values-in-cli-output)
- [Git Secrets Prevention](https://git-scm.com/book/en/v2/Git-Tools-Credential-Storage)

## ✅ Estado Actual

- ✅ Token configurado en `terraform.tfvars.rettai`
- ✅ Archivo protegido por `.gitignore`
- ✅ No se versionará en git
- ⚠️  Revisar periódicamente y rotar el token
- ⚠️  No compartir el archivo con nadie

## 🎯 Próximos Pasos

1. Verificar que `.gitignore` funciona:
   ```bash
   git status # No debe aparecer terraform.tfvars*
   ```

2. Hacer commit solo de archivos seguros:
   ```bash
   git add .
   git status # Verificar QUÉ se va a subir
   git commit -m "Add infrastructure"
   ```

3. Después del primer deploy, considera rotar el token como medida de seguridad adicional.
