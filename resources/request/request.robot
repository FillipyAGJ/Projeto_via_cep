*** Settings ***
Resource    ../../config/config.resource
Library    String

*** Keywords ***
Get CEP
    [Arguments]    ${cep}
    ${endpoint}=    Replace String    ${ENDPOINT_CONSULTA_CEP}    :cep:    ${cep}
    ${response}=    GET    url=${BASE_URL}/${endpoint}    expected_status=any

    ${status}=         Set Variable    ${response.status_code}
    ${url_utilizada}=  Set Variable    ${response.url}
    ${metodo}=         Set Variable    ${response.request.method}
    ${headers}=        Set Variable    ${response.request.headers}

    RETURN    ${response}    ${status}    ${url_utilizada}    ${metodo}    ${headers}