*** Settings ***
Resource    ../config/config.resource
Resource    ../resources/keywords/keywords.resource
Resource    ../resources/keywords/gerar_pdf.resource
Variables    ../resources/data/cep_valido.yaml
Variables    ../resources/data/cep_invalido.yaml

*** Test Cases ***
 
Teste tempo CEP válido
    ${response}    ${status}    ${url}    ${metodo}    ${headers}=    Get CEP    ${cep}
    ${secs}=    Evaluate    $response.elapsed.total_seconds()
    ${tempo_ms}=    Evaluate    int(round($secs * 1000))
    Should Be True    $secs < 2    msg=Tempo de resposta ${secs}s >= 2s

    # teardown gera o PDF com o tempo
    [Teardown]    _Gerar PDF deste teste    Tempo CEP válido ${cep}    ${response}    ${status}    ${url}    ${metodo}    ${headers}    ${tempo_ms}

Teste CEP inexistente
    ${response}    ${status}    ${url}    ${metodo}    ${headers}=    Valida CEP    ${cep_invalido}
    [Teardown]    _Gerar PDF deste teste    CEP inexistente ${cep_invalido}    ${response}    ${status}    ${url}    ${metodo}    ${headers}


Teste tempo CEP malformado
    ${response}    ${status}    ${url}    ${metodo}    ${headers}=    Get CEP    ${cep_malformado}
    ${secs}=    Evaluate    $response.elapsed.total_seconds()
    ${tempo_ms}=    Evaluate    int(round($secs * 1000))
    # mesmo sendo 4xx, ainda precisa ser rápido
    Should Be True    $secs < 2    msg=Tempo de resposta ${secs}s >= 2s (malformado)

    [Teardown]    _Gerar PDF deste teste    Tempo CEP malformado ${cep_malformado}    ${response}    ${status}    ${url}    ${metodo}    ${headers}    ${tempo_ms}

Teste CEP malformado ${cep_malformado_2}
        ${response}    ${status}    ${url}    ${metodo}    ${headers}=    Valida CEP    ${cep_malformado_2}
    [Teardown]    _Gerar PDF deste teste    CEP malformado ${cep_malformado_2}    None    ${status}    ${url}    ${metodo}    ${headers}

Smoke Import Schema Keyword
    ${body}=    Evaluate    {"cep":"01001-000","localidade":"São Paulo","uf":"SP"}
    Validar JSON Por Schema    ${body}    ${EXECDIR}/resources/data/schemas/cep_schema.json