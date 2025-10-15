# Arquitectura AWS Serverless E-Commerce

```
┌─────────────────────────────────────────────────────────────────┐
│                         Internet Users                           │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         │ HTTPS
                         ▼
                ┌─────────────────┐
                │   Route53 DNS   │
                │  example.com    │
                └────────┬────────┘
                         │
                         │ A Record (Alias)
                         ▼
    ┌───────────────────────────────────────────┐
    │         AWS CloudFront (CDN)              │
    │  ┌─────────────────────────────────────┐  │
    │  │   WAF (Web Application Firewall)    │  │
    │  │  • Core Rule Set (OWASP)            │  │
    │  │  • Known Bad Inputs                 │  │
    │  │  • Rate Limiting (2000 req/5min)    │  │
    │  │  • Geo Blocking                     │  │
    │  └─────────────────────────────────────┘  │
    │                                            │
    │  ┌─────────────────────────────────────┐  │
    │  │   ACM Certificate (SSL/TLS)         │  │
    │  │   • Auto DNS Validation             │  │
    │  │   • TLS 1.2+ Only                   │  │
    │  └─────────────────────────────────────┘  │
    │                                            │
    │  • Edge Locations: Global                 │
    │  • Cache TTL: Configurable                │
    │  • Compression: Enabled                   │
    │  • IPv6: Enabled                          │
    └───────────────────┬───────────────────────┘
                        │
                        │ Origin Access Identity (OAI)
                        ▼
           ┌─────────────────────────┐
           │    S3 Bucket (Origin)   │
           │  • Private Access Only  │
           │  • Versioning Optional  │
           │  • Static Content       │
           └─────────────────────────┘

```

## Flujo de Solicitud

1. **Usuario** → Accede a `https://example.com`
2. **Route53** → Resuelve DNS y redirige a CloudFront
3. **CloudFront** → Recibe la solicitud
4. **WAF** → Evalúa las reglas de seguridad
   - ✅ Permitir si pasa las reglas
   - ❌ Bloquear si viola alguna regla
5. **CloudFront Cache** → 
   - ✅ Si existe en caché → Devuelve contenido
   - ❌ Si no existe → Solicita a S3
6. **S3** → Devuelve contenido (solo accesible vía OAI)
7. **CloudFront** → Cachea y devuelve al usuario
8. **Usuario** → Recibe contenido

## Componentes por Módulo

### 📦 Module: Route53
- Hosted Zone para el dominio
- Nameservers DNS

### 🛡️ Module: WAF
- Web ACL con reglas configurables
- Métricas CloudWatch
- 4 tipos de reglas opcionales

### 🗄️ Module: S3-Origin
- Bucket S3 privado
- Origin Access Identity (OAI)
- Bucket Policy automática
- Versionado opcional

### 🌐 Module: CloudFront
- Distribución CDN global
- Certificado SSL/TLS (ACM)
- Records DNS (A para apex y www)
- Custom error pages
- Integración con WAF

## Seguridad

```
Layer 1: WAF
├─ Rate Limiting
├─ Geo Blocking
├─ SQL Injection Protection
└─ XSS Protection

Layer 2: CloudFront
├─ HTTPS Only (redirect HTTP)
├─ TLS 1.2+ Minimum
└─ Signed URLs (opcional)

Layer 3: S3
├─ Private Bucket
├─ Block Public Access
└─ OAI Access Only
```

## Alta Disponibilidad

- **Route53**: 100% SLA DNS
- **CloudFront**: Edge locations globales con failover automático
- **S3**: 99.999999999% (11 9's) durability
- **WAF**: Escalado automático

## Regiones

```
us-east-1 (Virginia)
├─ WAF Web ACL (requerido para CloudFront)
├─ ACM Certificate (requerido para CloudFront)
└─ Route53 (Global service)

<tu-región>
└─ S3 Bucket (puede estar en cualquier región)

CloudFront
└─ Edge Locations (200+ globales)
```

## Costos Optimizados

- **Price Class 100**: Solo USA, Canadá, Europa (más económico)
- **WAF**: Solo reglas necesarias habilitadas
- **S3**: Acceso directo bloqueado, solo vía CloudFront
- **ACM**: Certificado SSL gratuito
