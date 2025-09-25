
from robot.api.deco import keyword
from jsonschema import validate, Draft7Validator, exceptions as js_exceptions
import json, os

@keyword('Validar JSON Por Schema')
def validar_json_por_schema(body, schema_path):
    """Valida um dicionário JSON `body` contra um schema em `schema_path`."""
    if isinstance(body, str):
        body = json.loads(body)
    path = os.path.abspath(schema_path)
    with open(path, 'r', encoding='utf-8') as f:
        schema = json.load(f)
    
    # Convertendo o schema para string JSON formatada
    schema_content = json.dumps(schema, ensure_ascii=False, indent=2)
    
    try:
        # Tentando validar
        validate(instance=body, schema=schema, cls=Draft7Validator)
        
        # Se não houver exceção, validação bem-sucedida
        resultado = {
            'sucesso': True,
            'mensagem': 'JSON validado com sucesso',
            'schema_content': schema_content,  # Schema completo
            'body_validado': json.dumps(body, ensure_ascii=False, indent=2),
            'schema_path': os.path.basename(schema_path)  # Apenas o nome do arquivo
        }
        return resultado
        
    except js_exceptions.ValidationError as e:
        # Em caso de falha, retorna dicionário com erro
        resultado = {
            'sucesso': False,
            'mensagem': f"JSON não corresponde ao schema: {e.message}",
            'erro': e.message,
            'path_erro': '/'.join([str(p) for p in e.path]) if e.path else 'root',
            'schema_content': schema_content,  # Schema completo
            'body_validado': json.dumps(body, ensure_ascii=False, indent=2),
            'schema_path': os.path.basename(schema_path)  # Apenas o nome do arquivo
        }
        return resultado