# Web Rettai Admin - Panel de Administración

Aplicación Next.js 14 para el panel de administración de Rettai E-Commerce.

## 🚀 Características

- ⚡ Next.js 14 con App Router
- 🎨 Tailwind CSS con tema dark
- 📊 Dashboard con métricas
- 🔐 Interface administrativa
- 📦 Static export para Amplify/S3
- 🛣️ BasePath: `/admin`

## 🛠️ Desarrollo Local

### Instalación

```bash
npm install
```

### Ejecutar en desarrollo

```bash
npm run dev
```

Abre [http://localhost:3001](http://localhost:3001)

**Nota**: Corre en el puerto 3001 para no conflictuar con la app principal.

### Build para producción

```bash
npm run build
```

Los archivos estáticos se generan en `out/` con el prefix `/admin`

## 📦 Deployment

### Opción 1: AWS Amplify (Recomendado)

Configurado para deployarse en la ruta `/admin` de Amplify.

### Opción 2: S3 + CloudFront Manual

```bash
# Build
npm run build

# Subir a S3 en carpeta admin/
aws s3 sync out/ s3://tu-bucket/admin/ --delete

# Invalidar cache
aws cloudfront create-invalidation \
  --distribution-id TU_DISTRIBUTION_ID \
  --paths "/admin/*"
```

## 📁 Estructura

```
web-rettai-admin/
├── app/
│   ├── globals.css       # Estilos globales
│   ├── layout.tsx        # Layout principal
│   └── page.tsx          # Dashboard admin
├── public/               # Archivos estáticos
├── next.config.js        # Configuración Next.js
├── tailwind.config.js    # Configuración Tailwind
└── package.json
```

## ⚙️ Configuración

### next.config.js

```js
output: 'export'          // Export estático
basePath: '/admin'        // Todas las rutas bajo /admin
images: {
  unoptimized: true       // Para S3/Amplify
}
```

## 🎨 Dashboard

### Secciones Actuales

- 📦 Productos
- 🛒 Órdenes
- 👥 Clientes
- 💰 Ingresos

### Acciones Rápidas

- ➕ Nuevo Producto
- 📊 Ver Reportes
- ⚙️ Configuración

## 🔗 Rutas

- `/admin` - Dashboard principal
- Rutas futuras:
  - `/admin/products`
  - `/admin/orders`
  - `/admin/customers`
  - `/admin/settings`

## 📝 Scripts Disponibles

```bash
npm run dev     # Desarrollo (puerto 3001)
npm run build   # Build producción
npm run start   # Servir build (puerto 3001)
npm run lint    # Linter
```

## 🌐 URLs

- **Desarrollo**: http://localhost:3001
- **Producción**: https://rettai.com/admin

## 🔐 Próximos Pasos

1. Añadir autenticación (Cognito)
2. Conectar con API backend
3. Implementar CRUD de productos
4. Dashboard con datos reales
5. Gestión de órdenes
