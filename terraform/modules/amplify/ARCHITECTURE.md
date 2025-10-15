# Amplify Module - Architecture

## 🎯 Cómo Funciona

Este módulo crea **UNA SOLA aplicación de Amplify** que maneja AMBOS frontends desde un monorepo.

## 📦 Estructura de Recursos

```
modules/amplify/
├── app.tf        → Amplify App con build spec para monorepo
├── branch.tf     → Branch principal (main)
├── domain.tf     → Dominio personalizado (rettai.com)
├── variables.tf  → Variables de entrada
├── outputs.tf    → Outputs del módulo
└── versions.tf   → Provider requirements
```

## 🏗️ Arquitectura

### Una App, Dos Frontends

```
AWS Amplify App (rettai-prod)
│
├── Build Configuration (monorepo)
│   ├── frontends/web-rettai/        → Build app principal
│   └── frontends/web-rettai-admin/  → Build app admin
│
├── Deploy
│   ├── /              → web-rettai/out/
│   └── /admin         → web-rettai-admin/out/
│
└── Custom Routing Rules
    ├── /admin    → /admin/index.html
    ├── /admin/*  → /admin/index.html (SPA)
    └── /<*>      → /index.html (SPA fallback)
```

## 🔧 Build Spec (Monorepo)

```yaml
version: 1
applications:
  # App 1: Sitio Principal
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

  # App 2: Panel Admin
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

## 🌐 Routing

### Custom Rules en app.tf

```hcl
# Ruta /admin → App admin
custom_rule {
  source = "/admin"
  target = "/admin/index.html"
  status = "200"
}

# Subrutas /admin/* → App admin (SPA)
custom_rule {
  source = "/admin/*"
  target = "/admin/index.html"
  status = "200"
}

# Fallback → App principal (SPA)
custom_rule {
  source = "/<*>"
  target = "/index.html"
  status = "404-200"
}
```

### Cómo Amplify Sirve las Apps

1. **Request a `/`** → Sirve `web-rettai/out/index.html`
2. **Request a `/admin`** → Sirve `web-rettai-admin/out/index.html`
3. **Request a `/admin/products`** → Redirige a `/admin/index.html` (SPA)
4. **Request a `/products`** → Redirige a `/index.html` (SPA)

## 📁 Deploy Flow

```
1. Push a GitHub (main branch)
   ↓
2. Amplify detecta cambio (webhook)
   ↓
3. Build ambas apps en paralelo
   ├── Build web-rettai
   └── Build web-rettai-admin
   ↓
4. Merge artifacts
   ├── / → web-rettai/out/*
   └── /admin → web-rettai-admin/out/*
   ↓
5. Deploy a CloudFront
   ↓
6. Disponible en rettai.com
```

## 🎨 Configuración de next.config.js

### web-rettai (/)
```js
module.exports = {
  output: 'export',
  basePath: '',        // Raíz
  trailingSlash: true
}
```

### web-rettai-admin (/admin)
```js
module.exports = {
  output: 'export',
  basePath: '/admin',  // Subpath
  trailingSlash: true
}
```

## ✅ Por Qué Esta Arquitectura

### Ventajas

- ✅ **Una sola app de Amplify** → Más simple, menos costos
- ✅ **Mismo dominio** → rettai.com para todo
- ✅ **Un solo build pipeline** → CI/CD unificado
- ✅ **Compartir recursos** → Cache, SSL, CloudFront
- ✅ **Deploy atómico** → Ambas apps se despliegan juntas
- ✅ **Routing flexible** → Custom rules

### vs Dos Apps Separadas

| Aspecto | Una App (actual) | Dos Apps |
|---------|------------------|----------|
| Amplify Apps | 1 | 2 |
| CloudFront Distributions | 1 | 2 |
| Dominios | rettai.com | rettai.com + admin.rettai.com |
| Build | Paralelo en una app | Dos pipelines separados |
| Costo | Más bajo | ~2x más |
| Complejidad | Baja | Media |

## 🚀 Uso del Módulo

```hcl
module "amplify" {
  source = "./modules/amplify"

  app_name            = "rettai-prod"
  repository          = "https://github.com/user/repo"
  branch_name         = "main"
  github_access_token = var.github_token
  domain_name         = "rettai.com"
  project_name        = "rettai"
  environment         = "prod"
}
```

## 📊 Outputs

```hcl
output "app_id"              # ID de la app Amplify
output "default_domain"      # Domain de Amplify (xxx.amplifyapp.com)
output "branch_url"          # URL de la rama
output "custom_domain_url"   # https://rettai.com
```

## 🔄 Actualizar Contenido

```bash
# Hacer cambios en cualquier frontend
cd frontends/web-rettai
# o
cd frontends/web-rettai-admin

# Commit y push
git add .
git commit -m "Update feature"
git push

# Amplify automáticamente:
# 1. Detecta cambio
# 2. Build ambas apps
# 3. Deploy
# 4. ~5 min después está live
```

## 📝 Notas

- Amplify maneja automáticamente el merge de artifacts
- No necesitas configurar rutas manualmente
- El basePath en next.config.js es crucial
- Custom rules permiten SPA routing
- SSL/TLS automático para rettai.com
- CloudFront integrado, no necesitas configurarlo

## 🐛 Troubleshooting

### /admin no carga
- Verificar que web-rettai-admin tenga `basePath: '/admin'`
- Verificar que el build generó archivos en `out/`

### Custom rules no funcionan
- Verificar en AWS Console → Amplify → App → Rewrites and redirects
- El orden importa: admin rules primero, luego fallback

### Build falla
- Ver logs en Amplify Console
- Verificar package.json en cada app
- Verificar que npm ci funciona localmente
