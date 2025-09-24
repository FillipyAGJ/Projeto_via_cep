*** Settings ***
Library    RequestsLibrary
Library    Collections
Library    RPA.PDF
Library    DateTime
Library    OperatingSystem
Library    AllureLibrary
Library    ../libs/schema_keywords.py
Library    ../libs/pdf_merge.py

*** Variables ***
${BASE_URL}    http://viacep.com.br
${ENDPOINT_CONSULTA_CEP}    ws/:cep:/json
