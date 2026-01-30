import json
import boto3
import logging

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize Bedrock client
bedrock_agent = boto3.client('bedrock-agent-runtime')
bedrock_runtime = boto3.client('bedrock-runtime')

def lambda_handler(event, context):
    try:
        # Parse the request body
        if 'body' in event:
            body = json.loads(event['body'])
        else:
            body = event
        
        query = body.get('query', '')
        
        if not query:
            return {
                'statusCode': 400,
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*',
                    'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
                    'Access-Control-Allow-Methods': 'POST,OPTIONS'
                },
                'body': json.dumps({
                    'error': 'Query parameter is required'
                })
            }
        
        logger.info(f"Processing query: {query}")
        
        # Query the Knowledge Base
        kb_response = bedrock_agent.retrieve_and_generate(
            input={
                'text': query
            },
            retrieveAndGenerateConfiguration={
                'type': 'KNOWLEDGE_BASE',
                'knowledgeBaseConfiguration': {
                    'knowledgeBaseId': 'BO2ZUTK4JD',  # ID real del Knowledge Base aje_conocimiento
                    'modelArn': 'arn:aws:bedrock:us-east-1::foundation-model/anthropic.claude-3-sonnet-20240229-v1:0'
                }
            }
        )
        
        # Extract response and sources
        response_text = kb_response['output']['text']
        citations = kb_response.get('citations', [])
        
        # Format sources
        sources = []
        for citation in citations:
            for reference in citation.get('retrievedReferences', []):
                sources.append({
                    'content': reference.get('content', {}).get('text', ''),
                    'location': reference.get('location', {}),
                    'metadata': reference.get('metadata', {})
                })
        
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
                'Access-Control-Allow-Methods': 'POST,OPTIONS'
            },
            'body': json.dumps({
                'query': query,
                'response': response_text,
                'sources_count': len(sources),
                'sources': sources[:3]  # Limit to first 3 sources
            })
        }
        
    except Exception as e:
        logger.error(f"Error processing request: {str(e)}")
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
                'Access-Control-Allow-Methods': 'POST,OPTIONS'
            },
            'body': json.dumps({
                'error': f'Internal server error: {str(e)}'
            })
        }
