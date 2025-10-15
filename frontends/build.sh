#!/bin/bash

# Script para build de ambas aplicaciones

echo "📦 Building Rettai Frontends"
echo "============================"
echo ""

# Build main site
echo "🔨 Building web-rettai (Main Site)..."
cd web-rettai
npm run build
if [ $? -eq 0 ]; then
    echo "✅ web-rettai build successful"
    echo "   Output: web-rettai/out/"
else
    echo "❌ web-rettai build failed"
    exit 1
fi
cd ..

echo ""

# Build admin
echo "🔨 Building web-rettai-admin (Admin Panel)..."
cd web-rettai-admin
npm run build
if [ $? -eq 0 ]; then
    echo "✅ web-rettai-admin build successful"
    echo "   Output: web-rettai-admin/out/"
else
    echo "❌ web-rettai-admin build failed"
    exit 1
fi
cd ..

echo ""
echo "✅ All builds completed successfully!"
echo ""
echo "📁 Build outputs:"
echo "   - web-rettai/out/       → Deploy to /"
echo "   - web-rettai-admin/out/ → Deploy to /admin"
