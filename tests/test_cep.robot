*** Settings ***
Resource    ../config/config.resource
Resource    ../resources/keywords/keywords.resource
Resource    ../resources/keywords/gerar_pdf.resource

*** Test Cases ***
Executar teste em amostra
    [Template]    Testar CEP
    01001000    valido
    30140071    valido
    70040900    valido
    00000000    invalido
    abc123    malformado
    123    malformado

Smoke Import Schema Keyword
    ${body}=    Evaluate    {"cep":"01001-000","localidade":"São Paulo","uf":"SP"}
    Validar JSON Por Schema    ${body}    ${EXECDIR}/resources/data/schemas/cep_schema.json