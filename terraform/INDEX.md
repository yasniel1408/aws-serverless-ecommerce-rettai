# 📖 Índice de Documentación

Toda la documentación de tu infraestructura Terraform para AWS.

## 🚀 Empezar Ahora

**→ [START_HERE.md](START_HERE.md)** ← **COMIENZA AQUÍ**

Guía rápida de 5 minutos para desplegar tu infraestructura en rettai.com.

---

## 📚 Documentación por Tema

### Para Deployment Inmediato

| Archivo | Descripción | Tiempo |
|---------|-------------|--------|
| **[START_HERE.md](START_HERE.md)** | 🎯 Tu guía rápida de inicio | 5 min |
| **[SETUP_RETTAI.md](SETUP_RETTAI.md)** | Guía completa para rettai.com | 15 min |
| **[DEPLOYMENT_FLOW.md](DEPLOYMENT_FLOW.md)** | Timeline y comandos detallados | 10 min |

### Para Entender la Arquitectura

| Archivo | Descripción |
|---------|-------------|
| **[ARCHITECTURE.md](ARCHITECTURE.md)** | Diagramas y flujos de la infraestructura |
| **[README.md](README.md)** | Documentación completa de módulos |
| **[QUICK_START.md](QUICK_START.md)** | Guía general (cualquier dominio) |

### Configuración

| Archivo | Propósito |
|---------|-----------|
| `terraform.tfvars.rettai` | ✅ Configuración lista para rettai.com |
| `terraform.tfvars.example` | Plantilla para otros dominios |
| `variables.tf` | Definición de todas las variables |
| `outputs.tf` | Outputs disponibles |
| `main.tf` | Configuración principal |

### Módulos Reutilizables

```
modules/
├── cloudfront/     → CDN + SSL/TLS + DNS
├── route53/        → Gestión de DNS
├── s3-origin/      → Storage privado + OAI
└── waf/            → Firewall y seguridad
```

Cada módulo tiene su propio `README.md` con documentación completa.

---

## 🎯 Flujo Recomendado

### Primera Vez (Setup Completo)

```
1. START_HERE.md          (Deployment rápido)
2. SETUP_RETTAI.md       (Detalles específicos)
3. ARCHITECTURE.md        (Entender la arquitectura)
```

### Troubleshooting

```
1. DEPLOYMENT_FLOW.md    (Verificar timeline)
2. START_HERE.md         (Sección troubleshooting)
3. modules/*/README.md   (Documentación del módulo)
```

### Personalización

```
1. README.md             (Ver todas las opciones)
2. variables.tf          (Variables disponibles)
3. modules/*/variables.tf (Opciones de cada módulo)
```

---

## 🔍 Búsqueda Rápida

### "¿Cómo hago para...?"

- **Desplegar por primera vez** → START_HERE.md
- **Usar mi dominio existente** → SETUP_RETTAI.md (ya configurado)
- **Ver qué se va a crear** → terraform plan
- **Subir mi aplicación** → START_HERE.md sección "Subir Tu Aplicación"
- **Cambiar configuración WAF** → terraform.tfvars variables waf_*
- **Invalidar cache** → START_HERE.md sección "Comandos Útiles"
- **Destruir todo** → START_HERE.md sección "Destruir Todo"
- **Añadir backend API** → Ver sección "Siguiente Paso"
- **Ver costos** → START_HERE.md sección "Costos Estimados"
- **Solucionar problemas** → DEPLOYMENT_FLOW.md sección "Troubleshooting"

### "¿Qué hace el módulo...?"

- **cloudfront** → modules/cloudfront/README.md
- **route53** → modules/route53/README.md
- **s3-origin** → modules/s3-origin/README.md
- **waf** → modules/waf/README.md

### "¿Dónde está...?"

- **Configuración de rettai.com** → terraform.tfvars.rettai
- **Todas las variables** → variables.tf
- **Outputs disponibles** → outputs.tf
- **Lógica principal** → main.tf
- **Diagramas** → ARCHITECTURE.md

---

## 📊 Estructura del Proyecto

```
terraform/
│
├── 📄 Documentación
│   ├── START_HERE.md ⭐         (Comienza aquí)
│   ├── SETUP_RETTAI.md          (Específico para tu dominio)
│   ├── DEPLOYMENT_FLOW.md       (Timeline detallado)
│   ├── ARCHITECTURE.md          (Diagramas)
│   ├── README.md                (Documentación completa)
│   ├── QUICK_START.md           (Guía general)
│   └── INDEX.md                 (Este archivo)
│
├── ⚙️ Configuración
│   ├── main.tf                  (Llamadas a módulos)
│   ├── variables.tf             (Definiciones)
│   ├── outputs.tf               (Outputs)
│   ├── terraform.tfvars.rettai  (Tu configuración)
│   └── terraform.tfvars.example (Plantilla)
│
└── 📦 Módulos Reutilizables
    ├── cloudfront/              (CDN + SSL + DNS)
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── README.md
    ├── route53/                 (DNS)
    ├── s3-origin/               (Storage)
    └── waf/                     (Firewall)
```

---

## 🚀 Quick Commands

```bash
# Deploy completo
cd terraform && cp terraform.tfvars.rettai terraform.tfvars && terraform init && terraform apply

# Ver estado
terraform output

# Subir contenido
aws s3 sync ./dist/ s3://$(terraform output -raw s3_bucket_name)/

# Invalidar cache
aws cloudfront create-invalidation \
  --distribution-id $(terraform output -raw cloudfront_distribution_id) \
  --paths "/*"

# Destruir todo
terraform destroy
```

---

## 💡 Tips

1. **Primera vez**: Lee START_HERE.md completo antes de ejecutar comandos
2. **Variables**: Todas las opciones están documentadas en variables.tf
3. **Módulos**: Son independientes y reutilizables en otros proyectos
4. **Troubleshooting**: Revisa DEPLOYMENT_FLOW.md si algo falla
5. **Costos**: Monitorea AWS Cost Explorer después del deployment

---

## 📞 Arquitectura de Soporte

```
Pregunta General → README.md
Deployment → START_HERE.md → SETUP_RETTAI.md
Problema → DEPLOYMENT_FLOW.md (Troubleshooting)
Arquitectura → ARCHITECTURE.md
Módulo específico → modules/{nombre}/README.md
```

---

**¿Listo?** → [START_HERE.md](START_HERE.md) 🚀
