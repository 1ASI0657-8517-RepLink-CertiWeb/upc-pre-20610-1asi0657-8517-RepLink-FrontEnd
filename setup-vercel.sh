#!/bin/bash

echo "🚀 CertiWeb Frontend - Setup para Vercel"
echo "========================================"
echo ""

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Verificar si vercel CLI está instalado
if ! command -v vercel &> /dev/null; then
    echo -e "${YELLOW}⚠️  Vercel CLI no está instalado${NC}"
    echo "Instalando Vercel CLI..."
    npm install -g vercel
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Error al instalar Vercel CLI${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ Vercel CLI instalado${NC}"
else
    echo -e "${GREEN}✅ Vercel CLI ya instalado${NC}"
fi

echo ""
echo "📋 Pasos para configurar el despliegue:"
echo ""

# Step 1
echo "1️⃣  Login en Vercel"
echo "   Ejecuta: vercel login"
echo ""

# Step 2
echo "2️⃣  Link del proyecto"
echo "   Ejecuta: vercel link"
echo "   - Set up and deploy? No (solo link)"
echo "   - Scope: Tu cuenta de Vercel"
echo "   - Link to existing project? Yes o No (según tu caso)"
echo ""

# Step 3
echo "3️⃣  Obtener IDs del proyecto"
echo "   Después de 'vercel link', busca en .vercel/project.json"
echo "   Necesitas: orgId y projectId"
echo ""

# Step 4
echo "4️⃣  Crear token de Vercel"
echo "   Ve a: https://vercel.com/account/tokens"
echo "   Crea un nuevo token y guárdalo"
echo ""

# Step 5
echo "5️⃣  Agregar secrets en GitHub"
echo "   Ve a: Settings → Secrets and variables → Actions"
echo "   Agrega:"
echo "   - VERCEL_TOKEN"
echo "   - VERCEL_ORG_ID"
echo "   - VERCEL_PROJECT_ID"
echo ""

# Step 6
echo "6️⃣  Configurar variables de entorno en Vercel"
echo "   Ve a: Vercel Dashboard → Settings → Environment Variables"
echo "   Agrega:"
echo "   - VITE_SERVER_BASE_PATH: https://upc-pre-20610-1asi0657-8517-replink.onrender.com/api/v1"
echo ""

# Step 7
echo "7️⃣  ¡Push a main para desplegar!"
echo "   git add ."
echo "   git commit -m 'Setup CI/CD pipeline'"
echo "   git push origin main"
echo ""

echo -e "${GREEN}📚 Para más detalles, lee: VERCEL-DEPLOYMENT.md${NC}"
echo ""

# Preguntar si quiere hacer el link ahora
read -p "¿Quieres ejecutar 'vercel link' ahora? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    vercel link
    
    if [ -f ".vercel/project.json" ]; then
        echo ""
        echo -e "${GREEN}✅ Proyecto linkeado exitosamente${NC}"
        echo ""
        echo "📝 Tus IDs de proyecto:"
        cat .vercel/project.json
        echo ""
        echo -e "${YELLOW}⚠️  Guarda estos IDs como secrets en GitHub${NC}"
    fi
fi

echo ""
echo "✨ Setup completado!"
