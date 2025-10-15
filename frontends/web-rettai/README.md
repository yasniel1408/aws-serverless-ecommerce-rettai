# Web Rettai - Frontend Principal

Aplicación Next.js 14 para el sitio principal de Rettai E-Commerce.

## 🚀 Características

- ⚡ Next.js 14 con App Router
- 🎨 Tailwind CSS para estilos
- 📱 Responsive design
- 🌙 Dark mode support
- 📦 Static export para Amplify/S3

## 🛠️ Desarrollo Local

### Instalación

```bash
npm install
```

### Ejecutar en desarrollo

```bash
npm run dev
```

Abre [http://localhost:3000](http://localhost:3000)

### Build para producción

```bash
npm run build
```

Los archivos estáticos se generan en la carpeta `out/`

## 📦 Deployment

### Opción 1: AWS Amplify (Recomendado)

La aplicación está configurada para deployarse automáticamente en AWS Amplify.

### Opción 2: S3 + CloudFront Manual

```bash
# Build
npm run build

# Subir a S3
aws s3 sync out/ s3://tu-bucket/ --delete

# Invalidar cache de CloudFront
aws cloudfront create-invalidation \
  --distribution-id TU_DISTRIBUTION_ID \
  --paths "/*"
```

## 📁 Estructura

```
web-rettai/
├── app/
│   ├── globals.css       # Estilos globales
│   ├── layout.tsx        # Layout principal
│   └── page.tsx          # Página home
├── public/               # Archivos estáticos
├── next.config.js        # Configuración Next.js
├── tailwind.config.js    # Configuración Tailwind
└── package.json
```

## ⚙️ Configuración

### next.config.js

```js
output: 'export'        // Export estático
images: {
  unoptimized: true     // Para S3/Amplify
}
```

## 🔗 Rutas

- `/` - Página principal
- `/admin` - Redirige a la app de administración

## 🎨 Personalización

### Colores

Edita `tailwind.config.js` para cambiar el tema:

```js
theme: {
  extend: {
    colors: {
      // Tus colores personalizados
    }
  }
}
```

### Contenido

Edita `app/page.tsx` para modificar la página principal.

## 📝 Scripts Disponibles

```bash
npm run dev     # Desarrollo
npm run build   # Build producción
npm run start   # Servir build
npm run lint    # Linter
```

## 🌐 URLs

- **Desarrollo**: http://localhost:3000
- **Producción**: https://rettai.com
- **Admin**: https://rettai.com/admin
