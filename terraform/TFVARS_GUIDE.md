# Configuración de Archivos tfvars

## 📁 Estructura de Archivos

```
terraform/
├── terraform.tfvars         ❌ NO SE VERSIONA (tu configuración real)
├── terraform.tfvars.example ✅ SÍ SE VERSIONA (template)
└── .gitignore              ✅ Protege terraform.tfvars
```

## 🔐 Archivo Actual: terraform.tfvars

**Este es tu archivo de configuración real** que contiene:
- ✅ Tu token de GitHub
- ✅ Tu configuración de rettai.com
- ✅ Tu perfil AWS (mi-aws)
- ❌ **NO se sube a Git** (protegido por .gitignore)

### Contenido:
```hcl
aws_region   = "us-east-1"
aws_profile  = "mi-aws"
domain_name  = "rettai.com"
project_name = "rettai"
environment  = "dev"

github_repository = "https://github.com/yasniel1408/aws-serverless-ecommerce-rettai"
github_token      = "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"
```

## 📋 Archivo Template: terraform.tfvars.example

**Este es el template que se versiona en Git** que contiene:
- ✅ Valores de ejemplo
- ✅ Documentación de cada variable
- ✅ Se sube a Git para otros desarrolladores
- ❌ NO contiene datos sensibles

Otros desarrolladores pueden hacer:
```bash
cp terraform.tfvars.example terraform.tfvars
# Editar terraform.tfvars con sus propios valores
```

## 🚀 Uso con Terraform

### Desarrollo Local

```bash
cd terraform

# terraform.tfvars ya existe con tu configuración
terraform init
terraform plan
terraform apply
```

Terraform usa automáticamente `terraform.tfvars` (no necesitas especificarlo).

### Otros Desarrolladores

Si alguien clona el repo:

```bash
cd terraform

# Copiar el template
cp terraform.tfvars.example terraform.tfvars

# Editar con sus valores
nano terraform.tfvars
# Cambiar:
# - aws_profile a su perfil
# - github_repository a su fork
# - github_token a su token
# - domain_name si tienen otro dominio

# Usar
terraform init
terraform plan
```

## 🛡️ Protección Git

### .gitignore está configurado para:

```gitignore
# Ignora archivos con datos sensibles
*.tfvars
*.tfvars.json

# Permite archivos de ejemplo
!*.tfvars.example
```

### Verificar protección:

```bash
cd /Users/yasnielfajardo/Documents/PROYECTOS/YASCODE/aws-serverless-ecommerce

# Verificar que terraform.tfvars NO aparece
git status

# Deberías ver:
✅ terraform/terraform.tfvars.example (para versionar)
❌ terraform/terraform.tfvars (ignorado)
```

## 📝 Diferencias

| Aspecto | terraform.tfvars | terraform.tfvars.example |
|---------|------------------|--------------------------|
| Propósito | Tu config real | Template para otros |
| Git | ❌ NO se versiona | ✅ SÍ se versiona |
| Datos sensibles | ✅ Contiene token | ❌ Valores ejemplo |
| Usado por | Terraform (automático) | Copia manual → tfvars |
| Editar | Sí, cuando cambies config | No, es template |

## ⚙️ Variables Sensibles

Datos en `terraform.tfvars` que NO deben versionarse:

- 🔐 `github_token` - Personal Access Token
- 🔐 `aws_profile` - Perfil AWS local
- 🔐 Cualquier API key o secret

Datos en `terraform.tfvars.example` (safe para Git):

- ✅ Valores de ejemplo: "example.com", "ZXXXXX"
- ✅ Documentación: comentarios explicativos
- ✅ Estructura: todas las variables disponibles

## 🔄 Actualizar Configuración

### Cambiar tu configuración local:

```bash
cd terraform
nano terraform.tfvars
# Hacer cambios
terraform plan  # Verificar cambios
terraform apply # Aplicar
```

### Actualizar el template (para otros):

```bash
cd terraform
nano terraform.tfvars.example
# Actualizar documentación o añadir nuevas variables
git add terraform.tfvars.example
git commit -m "Update tfvars template"
```

## 🎯 Workflow Completo

### Tu workflow (dueño del repo):

1. Editas `terraform.tfvars` con tu config real
2. Terraform lo usa automáticamente
3. Nunca lo subes a Git (protegido)
4. Actualizas `terraform.tfvars.example` si añades variables

### Workflow de colaboradores:

1. Clonan el repo
2. `cp terraform.tfvars.example terraform.tfvars`
3. Editan `terraform.tfvars` con su config
4. Su archivo tampoco se sube a Git
5. Solo comparten cambios en código/módulos

## ✅ Checklist

Antes de hacer commit:

- [ ] `git status` no muestra `terraform.tfvars`
- [ ] `terraform.tfvars.example` tiene valores de ejemplo
- [ ] No hay tokens en archivos versionados
- [ ] `.gitignore` incluye `*.tfvars`

## 🚨 Si Expones el Token

1. Revoca inmediatamente en GitHub
2. Genera nuevo token
3. Actualiza `terraform.tfvars`
4. Verifica que NO está en git:
   ```bash
   git log --all --full-history --source --oneline -- terraform.tfvars
   ```

## 📚 Referencias

- Terraform usa `terraform.tfvars` automáticamente
- Archivos `*.example` son convención común
- `.gitignore` con `*.tfvars` protege secretos
