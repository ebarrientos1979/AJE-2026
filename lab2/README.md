# Lab 3: Bedrock RAG API

## 🎯 Objetivo
Crear una API REST que consulte el Knowledge Base de Bedrock `aje_conocimiento` usando Claude 3.5 Sonnet para responder preguntas.

## 🏗️ Arquitectura
- **Lambda Function**: Procesa consultas RAG con timeout de 29 segundos
- **API Gateway**: Expone endpoint REST público con CORS
- **Bedrock Knowledge Base**: Fuente de conocimiento (`aje_conocimiento`)
- **Claude 3.5 Sonnet v2**: Modelo de generación de respuestas
- **IAM Roles**: Permisos para acceder a Bedrock y Knowledge Base

## 📋 Prerequisitos
- Terraform instalado
- AWS CLI configurado con profile `default`
- Knowledge Base `aje_conocimiento` creado en Bedrock
- Python 3.9+ para pruebas

## 🚀 Despliegue

### 1. Desplegar infraestructura:
```bash
./deploy.sh
```

### 2. O manualmente:
```bash
# Inicializar Terraform
terraform init

# Revisar plan
terraform plan

# Aplicar cambios
terraform apply
```

## 🧪 Pruebas

### Prueba automatizada:
```bash
python3 test_api.py
```

### Prueba manual con curl:
```bash
# Obtener URL del API
API_URL=$(terraform output -raw api_url)

# Hacer consulta
curl -X POST $API_URL \
  -H "Content-Type: application/json" \
  -d '{"query": "¿Qué productos de abarrotes tienen disponibles?"}'
```

### Ejemplos de consultas:
```bash
# Consulta sobre productos
curl -X POST $API_URL \
  -H "Content-Type: application/json" \
  -d '{"query": "¿Cuáles son los precios de los productos?"}'

# Consulta sobre delivery
curl -X POST $API_URL \
  -H "Content-Type: application/json" \
  -d '{"query": "¿Cómo funciona el servicio de delivery?"}'
```

## 📊 Estructura de Respuesta

```json
{
  "query": "¿Qué productos tienen disponibles?",
  "response": "Basado en la información disponible en AJE Delivery...",
  "sources_count": 3,
  "sources": [
    {
      "content": "Texto del documento relevante...",
      "location": {
        "type": "WEB",
        "webLocation": {
          "url": "https://www.ajedelivery.pe/..."
        }
      },
      "metadata": {
        "source": "web_crawler",
        "timestamp": "2026-01-30"
      }
    }
  ]
}
```

## ⚙️ Configuración Técnica
- **Timeout**: 29 segundos
- **Memory**: 512 MB
- **Runtime**: Python 3.9
- **Modelo**: `anthropic.claude-3-5-sonnet-20241022-v2:0`
- **Region**: us-east-1
- **Profile**: default

## 📁 Archivos del Proyecto
- `main.tf` - Configuración de Terraform
- `outputs.tf` - Outputs del despliegue
- `lambda_function.py` - Código de la función Lambda
- `test_api.py` - Script de pruebas
- `deploy.sh` - Script de despliegue automático

## 🔍 Troubleshooting

### Error: Knowledge Base no encontrado
```bash
# Verificar que existe el Knowledge Base
aws bedrock-agent list-knowledge-bases --profile default --region us-east-1
```

### Error: Permisos insuficientes
```bash
# Verificar permisos del usuario
aws iam list-attached-user-policies --user-name user-terraform --profile default
```

### Error: Timeout en Lambda
- El timeout está configurado a 29 segundos
- Si persiste, verificar la conectividad con Bedrock

## 🧹 Limpieza
```bash
# Eliminar recursos
terraform destroy
```

## 📝 Logs
```bash
# Ver logs de Lambda
aws logs tail /aws/lambda/bedrock-rag-agent --follow --profile default --region us-east-1
```
