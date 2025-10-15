#!/bin/bash

# Script para desarrollo local de ambas frontends

echo "🚀 Iniciando Frontends de Rettai E-Commerce"
echo "==========================================="
echo ""

# Verificar si las dependencias están instaladas
check_deps() {
    local app=$1
    if [ ! -d "$app/node_modules" ]; then
        echo "📦 Instalando dependencias para $app..."
        cd $app && npm install && cd ..
    else
        echo "✅ Dependencias de $app ya instaladas"
    fi
}

echo "📦 Verificando dependencias..."
check_deps "web-rettai"
check_deps "web-rettai-admin"
echo ""

echo "🌐 Iniciando servidores de desarrollo..."
echo ""
echo "Main Site:  http://localhost:3000"
echo "Admin Panel: http://localhost:3001"
echo ""
echo "Presiona Ctrl+C para detener ambos servidores"
echo ""

# Ejecutar ambas apps en paralelo
cd web-rettai && npm run dev &
PID1=$!

cd ../web-rettai-admin && npm run dev &
PID2=$!

# Esperar a que terminen (Ctrl+C)
wait $PID1 $PID2
