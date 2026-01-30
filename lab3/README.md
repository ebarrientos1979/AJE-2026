# Lab 4: HTML Frontend

## 🎯 Objetivo
Crear una aplicación web HTML pura con Bootstrap que se conecte al API Gateway del Lab 3 y se despliegue en S3 como sitio web estático.

## 🏗️ Arquitectura
- **HTML + Bootstrap**: Interfaz moderna sin frameworks
- **JavaScript + AJAX**: Comunicación con API Gateway
- **S3 Static Website**: Hosting simple y económico
- **Config JSON**: URL del API Gateway configurable

## 📋 Prerequisitos
- AWS CLI configurado con profile `default`
- Terraform instalado
- Lab 3 desplegado (API Gateway funcionando)
- **¡No necesitas Node.js ni npm!**

## 🚀 Despliegue

### En Windows PowerShell:
```powershell
.\deploy.ps1
```

### En Linux/Mac:
```bash
./deploy.sh
```

### Despliegue manual:
```bash
# 1. Crear infraestructura S3
terraform init
terraform apply

# 2. Subir archivos
BUCKET_NAME=$(terraform output -raw bucket_name)
aws s3 cp index.html s3://$BUCKET_NAME/index.html --profile default
aws s3 cp app.js s3://$BUCKET_NAME/app.js --profile default
aws s3 cp config.json s3://$BUCKET_NAME/config.json --profile default
```

## ⚙️ Configuración

### Cambiar URL del API Gateway:
Edita `config.json`:
```json
{
  "apiGatewayUrl": "https://tu-nueva-url.execute-api.us-east-1.amazonaws.com/prod/query"
}
```

Luego sube solo el archivo de configuración:
```bash
aws s3 cp config.json s3://bucket-name/config.json --profile default
```

**¡No necesitas recompilar nada!**

## 🎨 Características de la UI

### Tecnologías:
- **Bootstrap 5.3**: Framework CSS moderno
- **Font Awesome**: Iconos vectoriales
- **Google Fonts**: Tipografía Inter
- **Vanilla JavaScript**: Sin dependencias

### Funcionalidades:
- 💬 **Chat en tiempo real**: Interfaz conversacional
- 🎨 **Diseño responsive**: Desktop y móvil
- 🚀 **Sugerencias rápidas**: Botones predefinidos
- ⚡ **Loading states**: Indicadores visuales
- 📚 **Fuentes de información**: Muestra documentos
- 🔄 **Manejo de errores**: Mensajes informativos

### Ejemplos de Preguntas:
- 🛒 "¿Qué productos de abarrotes tienen disponibles?"
- 💰 "¿Cuáles son los precios de los productos?"
- 🚚 "¿Cómo funciona el servicio de delivery?"
- 📝 "¿Cómo puedo hacer un pedido?"

## 📁 Estructura del Proyecto

```
├── index.html          # Página principal con Bootstrap
├── app.js             # JavaScript con AJAX
├── config.json        # Configuración del API Gateway
├── main.tf           # Infraestructura S3
├── outputs.tf        # Outputs de Terraform
├── deploy.sh         # Script Linux/Mac
└── deploy.ps1        # Script PowerShell
```

## 💰 Costos

### S3 Static Website:
- **Almacenamiento**: ~$0.023/GB/mes
- **Requests**: ~$0.0004/1000 requests
- **Transferencia**: ~$0.09/GB

**Costo estimado mensual**: < $1 USD

## 🔍 Troubleshooting

### Error de CORS:
- Verificar que el API Gateway tenga CORS habilitado
- Comprobar que la URL en `config.json` sea correcta

### App no carga:
```bash
# Verificar archivos en S3
aws s3 ls s3://bucket-name --profile default

# Verificar website configuration
aws s3api get-bucket-website --bucket bucket-name --profile default
```

### Actualizar solo configuración:
```bash
# Cambiar URL en config.json y subir
aws s3 cp config.json s3://bucket-name/config.json --profile default
```

## 🧹 Limpieza

```bash
# Eliminar recursos AWS
terraform destroy
```

## 🌐 URL Final

Después del despliegue:
```
http://aje-delivery-assistant-xxxxxxxx.s3-website-us-east-1.amazonaws.com
```

## ✅ Ventajas de HTML Puro

- 🚀 **Sin compilación**: Deploy inmediato
- 📦 **Sin dependencias**: No npm, no Node.js
- ⚡ **Carga rápida**: Archivos estáticos optimizados
- 🔧 **Fácil mantenimiento**: HTML/CSS/JS estándar
- 💰 **Súper económico**: Solo S3 hosting

**¡Interfaz moderna y funcional sin complicaciones!**
