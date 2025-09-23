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
    try:
        validate(instance=body, schema=schema, cls=Draft7Validator)
    except js_exceptions.ValidationError as e:
        raise AssertionError(
            f"JSON não corresponde ao schema: {e.message}\n"
            f"Path: {'/'.join([str(p) for p in e.path])}"
        )