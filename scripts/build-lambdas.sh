#!/bin/bash
# Build script for Lambda functions

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TERRAFORM_DIR="$PROJECT_ROOT/terraform"
LAMBDAS_DIR="$PROJECT_ROOT/lambdas"

echo "🚀 Building Lambda functions..."
echo ""

# Create tmp directory
mkdir -p "$TERRAFORM_DIR/.terraform/tmp"

# Build Identity Lambda
echo "📦 Building Identity Lambda..."
cd "$LAMBDAS_DIR/identity"

if [ ! -d "node_modules" ]; then
    echo "  Installing dependencies..."
    npm install --production
fi

echo "  Creating ZIP package..."
cd src
zip -r "$TERRAFORM_DIR/.terraform/tmp/identity-lambda.zip" . -x "*.spec.ts" "*.test.ts" > /dev/null
cd ..

# Include node_modules if they exist
if [ -d "node_modules" ]; then
    zip -r "$TERRAFORM_DIR/.terraform/tmp/identity-lambda.zip" node_modules > /dev/null
fi

echo "  ✅ Identity Lambda built: $(du -h "$TERRAFORM_DIR/.terraform/tmp/identity-lambda.zip" | cut -f1)"
echo ""

# Build Inventory Lambda
echo "📦 Building Inventory Lambda..."
cd "$LAMBDAS_DIR/inventory"

if [ ! -d "node_modules" ]; then
    echo "  Installing dependencies..."
    npm install
fi

echo "  Building TypeScript..."
npm run build

echo "  Creating ZIP package..."
cd dist
zip -r "$TERRAFORM_DIR/.terraform/tmp/inventory-lambda.zip" . > /dev/null
cd ..

# Include node_modules in Lambda package
echo "  Including node_modules..."
zip -r "$TERRAFORM_DIR/.terraform/tmp/inventory-lambda.zip" node_modules > /dev/null

echo "  ✅ Inventory Lambda built: $(du -h "$TERRAFORM_DIR/.terraform/tmp/inventory-lambda.zip" | cut -f1)"
echo ""

echo "✨ All Lambda functions built successfully!"
echo ""
echo "Next steps:"
echo "  1. cd terraform"
echo "  2. terraform plan"
echo "  3. terraform apply"
