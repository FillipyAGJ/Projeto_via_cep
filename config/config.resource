*** Settings ***
Library    RequestsLibrary
Library    Collections
Library    RPA.PDF
Library    DateTime
Library    OperatingSystem
Library    ../libs/schema_keywords.py

*** Variables ***
${BASE_URL}    http://viacep.com.br
${ENDPOINT_CONSULTA_CEP}    ws/:cep:/json
