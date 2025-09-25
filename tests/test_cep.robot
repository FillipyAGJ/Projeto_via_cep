*** Settings ***
Resource    ../config/config.resource
Resource    ../resources/keywords/keywords.resource
Resource    ../resources/keywords/gerar_pdf.resource

*** Test Cases ***
Executar teste em amostra
    [Template]    Testar CEP
    01001000    valido
    60751575    valido
    69900019    valido
    00000000    invalido
    abc123    malformado
    123    malformado

Executar Teste de JSON
    ${response}    ${status}    ${url_utilizada}    ${metodo}
    ...    ${headers}    Consulta CEP valido    01001000
    
    Log To Console    -- Body <${response.json()} >
    ${mensagem}    Validar JSON Por Schema    ${response.json()}    ${EXECDIR}/resources/data/schemas/cep_schema.json
    Log To Console    -- Mensagem validada <${mensagem}> --

    _Gerar PDF deste teste    Teste de schema json    01001000    ${response}    ${status}    ${url_utilizada}    ${None}    ${None}    ${None}    ${mensagem}