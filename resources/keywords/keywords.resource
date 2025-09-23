*** Settings ***
Resource    ../../config/config.resource
Resource    ../request/request.robot
Resource    ./gerar_pdf.resource

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
    
    
Testar CEP
    [Arguments]    ${cep}    ${situacao}
    IF    $situacao == 'valido'
        Teste tempo CEP válido    ${cep}
    ELSE IF    $situacao == 'invalido'
        Teste CEP inexistente    ${cep}
    ELSE IF    $situacao == 'malformado'
        Teste tempo CEP malformado    ${cep}
    END

Teste tempo CEP válido
    [Arguments]    ${cep}
    ${response}    ${status}    ${url}    ${metodo}    ${headers}=    Get CEP    ${cep}
    ${secs}=    Evaluate    $response.elapsed.total_seconds()
    ${tempo_ms}=    Evaluate    int(round($secs * 1000))
    Should Be True    $secs < 2    msg=Tempo de resposta ${secs}s >= 2s

    # teardown gera o PDF com o tempo
    [Teardown]    _Gerar PDF deste teste    Tempo CEP válido ${cep}    ${response}    ${status}    ${url}    ${metodo}    ${headers}    ${tempo_ms}

Teste CEP inexistente
    [Arguments]    ${cep}
    ${response}    ${status}    ${url}    ${metodo}    ${headers}=    Valida CEP    ${cep}
    [Teardown]    _Gerar PDF deste teste    CEP inexistente ${cep}    ${response}    ${status}    ${url}    ${metodo}    ${headers}


Teste tempo CEP malformado
    [Arguments]    ${cep}
    ${response}    ${status}    ${url}    ${metodo}    ${headers}=    Get CEP    ${cep}
    ${secs}=    Evaluate    $response.elapsed.total_seconds()
    ${tempo_ms}=    Evaluate    int(round($secs * 1000))
    # mesmo sendo 4xx, ainda precisa ser rápido
    Should Be True    $secs < 2    msg=Tempo de resposta ${secs}s >= 2s (malformado)

    [Teardown]    _Gerar PDF deste teste    Tempo CEP malformado ${cep}    ${response}    ${status}    ${url}    ${metodo}    ${headers}    ${tempo_ms}