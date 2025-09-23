*** Settings ***
Resource    ../../config/config.resource
Resource    ../request/request.robot

*** Variables ***
${CEP_SCHEMA_PATH}    ${CURDIR}/../../schemas/cep_schema.json

*** Keywords ***
Consulta CEP valido
    [Arguments]    ${cep}
    ${response}    ${status}    ${url_utilizada}    ${metodo}    ${headers}    Get CEP    ${cep}
    Should Be Equal As Integers    ${response.status_code}    200
    ${json}=    Set Variable    ${response.json()}
    Dictionary Should Contain Key    ${json}    logradouro
    Dictionary Should Contain Key    ${json}    bairro
    Dictionary Should Contain Key    ${json}    localidade
    Dictionary Should Contain Key    ${json}    uf
    Dictionary Should Contain Key    ${json}    cep
    RETURN    ${response}    ${status}    ${url_utilizada}    ${metodo}
    ...    ${headers}    

Valida CEP
    [Arguments]    ${cep}
    ${response}    ${status}    ${url_utilizada}    ${metodo}    ${headers}=    Get CEP    ${cep}

    IF    ${status} >= 400 and ${status} < 500
        Should Be True    $response.status_code >= 400 and $response.status_code < 500    msg=Esperava 4xx para CEP malformado
        RETURN    ${response}    ${status}    ${url_utilizada}    ${metodo}    ${headers}
    ELSE
        Should Be Equal As Integers    ${status}    200
        ${ok}    ${json}=    Run Keyword And Ignore Error    Evaluate    $response.json()
        Run Keyword If    '${ok}'!='PASS'    Fail    Esperava JSON no corpo, mas veio: ${response.text}

        Dictionary Should Contain Key    ${json}    erro
        ${erro}=       Evaluate    $json.get("erro")
        ${erro_bool}=  Evaluate    ($erro is True) or (isinstance($erro, str) and $erro.lower()=="true")
        Should Be True    ${erro_bool}    msg=Esperava {"erro": true}. Veio: ${response.text}

        RETURN    ${response}    ${status}    ${url_utilizada}    ${metodo}    ${headers}
    END

Consultar CEP e Validar Sucesso
    [Arguments]    ${cep}
    # Usa seu Get CEP, mantendo a mesma assinatura/retornos
    ${response}    ${status}    ${url_utilizada}    ${metodo}    ${headers}=    Get CEP    ${cep}

    # 200 esperado para CEP válido
    Should Be Equal As Integers    ${status}    200

    # Garante que veio JSON
    ${ok}    ${body}=    Run Keyword And Ignore Error    Evaluate    $response.json()
    Run Keyword If    '${ok}'!='PASS'    Fail    Esperava JSON no corpo, mas veio: ${response.text}

    # Em CEP válido, ViaCEP normalmente NÃO traz "erro": true
    Run Keyword If    'erro' in $body    Fail    Não esperava "erro" para CEP válido. Veio: ${response.text}

    # Validação formal do contrato (schema JSON)
    Validar JSON Por Schema    ${body}    ${CEP_SCHEMA_PATH}

    # Mantém a mesma convenção de retorno que você usa
    RETURN    ${response}    ${status}    ${url_utilizada}    ${metodo}    ${headers}
    
    
