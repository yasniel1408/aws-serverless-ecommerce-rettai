# Frontends - Rettai E-Commerce

Aplicaciones Next.js para Rettai E-Commerce.

## 📁 Estructura

```
frontends/
├── web-rettai/           # Sitio principal (/)
│   ├── app/
│   ├── package.json
│   └── README.md
│
└── web-rettai-admin/     # Panel admin (/admin)
    ├── app/
    ├── package.json
    └── README.md
```

## 🚀 Apps Disponibles

### 1. web-rettai (Sitio Principal)

**URL**: https://rettai.com  
**Puerto Dev**: 3000

Landing page y catálogo de productos.

```bash
cd web-rettai
npm install
npm run dev
```

### 2. web-rettai-admin (Panel Administración)

**URL**: https://rettai.com/admin  
**Puerto Dev**: 3001

Dashboard administrativo para gestión de productos, órdenes y clientes.

```bash
cd web-rettai-admin
npm install
npm run dev
```

## 🛠️ Setup Rápido

### Instalar todas las dependencias

```bash
# Desde la carpeta frontends
npm run install:all
```

O manualmente:

```bash
cd web-rettai && npm install && cd ..
cd web-rettai-admin && npm install && cd ..
```

### Ejecutar en desarrollo

Terminal 1 (Main site):
```bash
cd web-rettai
npm run dev
```

Terminal 2 (Admin):
```bash
cd web-rettai-admin
npm run dev
```

URLs:
- Main: http://localhost:3000
- Admin: http://localhost:3001

## 📦 Build para Producción

### Build ambas apps

```bash
# Main site
cd web-rettai
npm run build

# Admin
cd web-rettai-admin
npm run build
```

Ambas apps generan static exports en su carpeta `out/`

## 🌐 Deployment

### Con AWS Amplify (Recomendado)

Amplify detectará ambas apps y las deployará automáticamente:
- `web-rettai` → `/`
- `web-rettai-admin` → `/admin`

### Manual con S3

```bash
# Main site
cd web-rettai
npm run build
aws s3 sync out/ s3://tu-bucket/ --delete

# Admin
cd web-rettai-admin
npm run build
aws s3 sync out/ s3://tu-bucket/admin/ --delete

# Invalidar CloudFront
aws cloudfront create-invalidation \
  --distribution-id $DIST_ID \
  --paths "/*" "/admin/*"
```

## 🔄 Arquitectura de Rutas

```
https://rettai.com/
├── /                    → web-rettai
├── /products           → web-rettai
├── /about              → web-rettai
└── /admin              → web-rettai-admin
    ├── /admin/products → web-rettai-admin
    ├── /admin/orders   → web-rettai-admin
    └── /admin/settings → web-rettai-admin
```

## 🎨 Stack Tecnológico

- **Framework**: Next.js 14 (App Router)
- **Styling**: Tailwind CSS
- **TypeScript**: Full type safety
- **Export**: Static (SSG)
- **Hosting**: AWS Amplify / S3 + CloudFront

## ⚙️ Configuraciones Importantes

### web-rettai (next.config.js)
```js
{
  output: 'export',
  basePath: '',        // Raíz del dominio
  trailingSlash: true
}
```

### web-rettai-admin (next.config.js)
```js
{
  output: 'export',
  basePath: '/admin',  // Subpath para admin
  trailingSlash: true
}
```

## 🔗 Navegación entre Apps

Desde el sitio principal al admin:
```tsx
<a href="/admin">Ir al Admin</a>
```

Desde admin al sitio principal:
```tsx
<a href="/">Ver Sitio</a>
```

## 📝 Scripts Globales

Puedes crear scripts en el `package.json` raíz:

```json
{
  "scripts": {
    "install:all": "cd web-rettai && npm install && cd ../web-rettai-admin && npm install",
    "dev:main": "cd web-rettai && npm run dev",
    "dev:admin": "cd web-rettai-admin && npm run dev",
    "build:all": "cd web-rettai && npm run build && cd ../web-rettai-admin && npm run build"
  }
}
```

## 🔮 Próximas Características

### web-rettai
- [ ] Catálogo de productos con DynamoDB
- [ ] Carrito de compras
- [ ] Checkout con Stripe
- [ ] Búsqueda de productos
- [ ] Filtros y categorías

### web-rettai-admin
- [ ] Autenticación con Cognito
- [ ] CRUD de productos
- [ ] Gestión de órdenes
- [ ] Analytics dashboard
- [ ] Gestión de inventario
- [ ] Configuración de la tienda

## 🚀 Deploy con Terraform + Amplify

Ver `terraform/modules/amplify/` para la configuración de infraestructura.

## 📖 Más Información

- [web-rettai/README.md](./web-rettai/README.md)
- [web-rettai-admin/README.md](./web-rettai-admin/README.md)
- [Next.js Docs](https://nextjs.org/docs)
- [AWS Amplify Docs](https://docs.amplify.aws/)
