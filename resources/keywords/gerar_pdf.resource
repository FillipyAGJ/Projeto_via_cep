*** Settings ***
Resource    ../../config/config.resource
Resource    ../request/request.robot

*** Keywords ***

Gerar PDF deste teste
    [Arguments]    ${nome}    ${response}=None    ${status}=None    ${url}=None    ${metodo}=None    ${headers}=None    ${tempo_ms}=None
    Create Directory    output/pdf
    ${safe}=    Replace String    ${nome}    ${SPACE}    -
    ${out}=     Set Variable    output/pdf/${safe}.pdf

    ${pdf}=    Gerar PDF com log
    ...    nome_consulta=${nome}
    ...    response=${response}
    ...    status=${status}
    ...    url_utilizada=${url}
    ...    metodo=${metodo}
    ...    headers=${headers}
    ...    out=${out}
    ...    tempo_ms=${tempo_ms}

    Log To Console    PDF gerado: ${pdf}


Gerar PDF com log
    [Arguments]    ${nome_consulta}=${EMPTY}    ${status}=None    ${metodo}=None
    ...            ${url_utilizada}=None        ${headers}=None   ${response}=None
    ...            ${out}=None                  ${tempo_ms}=None

    IF    $out is None
        ${ts}=      Get Current Date    result_format=%Y%m%d-%H%M%S
        ${safe}=    Replace String    ${nome_consulta}    ${SPACE}    -
        ${out}=     Set Variable    output/pdf/${ts}_${safe}.pdf
    END

    @{parts}=    Create List
    Append To List    ${parts}    <div style="max-width:820px;margin:0 auto;font-family:Arial,Helvetica,sans-serif;">
    Append To List    ${parts}    <h2 style="text-align:center;color:#a00">==== Consulta: ${nome_consulta} ====</h2>

    Run Keyword If    $status is not None         Append To List    ${parts}    <p style="text-align:center"><b>Status:</b> ${status}</p>
    Run Keyword If    $url_utilizada is not None  Append To List    ${parts}    <p style="text-align:center"><b>URL:</b> ${url_utilizada}</p>
    Run Keyword If    $metodo is not None         Append To List    ${parts}    <p style="text-align:center"><b>Método:</b> ${metodo}</p>
    Run Keyword If    $tempo_ms is not None       Append To List    ${parts}    <p style="text-align:center"><b>Tempo de resposta:</b> ${tempo_ms} ms</p>

    # ---------- HEADERS ----------
    IF    $headers is not None
        ${is_response}=    Evaluate    hasattr($headers, "status_code") and hasattr($headers, "request")
        IF    ${is_response}
            ${hdrs}=    Set Variable    ${headers.request.headers}
        ELSE
            ${hdrs}=    Set Variable    ${headers}
        END
        ${ok}    ${pretty}=    Run Keyword And Ignore Error
        ...    Evaluate    __import__("json").dumps(dict($hdrs), ensure_ascii=False, indent=2)
        Run Keyword If    '${ok}'=='PASS'
        ...    Append To List    ${parts}    <h3>Headers</h3><pre style="background:#f5f5f5;padding:8px;border-radius:6px;white-space:pre-wrap;text-align:left">${pretty}</pre>
        Run Keyword If    '${ok}'!='PASS'
        ...    Append To List    ${parts}    <h3>Headers</h3><pre style="background:#f5f5f5;padding:8px;border-radius:6px;white-space:pre-wrap;text-align:left">${hdrs}</pre>
    END

    # ---------- RESPONSE ----------
    IF    $response is not None
        ${has_text}=    Evaluate    hasattr($response, "text")
        ${text}=        Run Keyword If    ${has_text}    Set Variable    ${response.text}    ELSE    Set Variable    ${response}
        ${ok}    ${maybe_json}=    Run Keyword And Ignore Error    Evaluate    __import__("json").loads($text)
        ${resp_txt}=    Run Keyword If    '${ok}'=='PASS'    Evaluate    __import__("json").dumps($maybe_json, ensure_ascii=False, indent=2)    ELSE    Set Variable    ${text}
        Append To List    ${parts}    <h3>Response</h3><pre style="background:#f5f5f5;padding:8px;border-radius:6px;white-space:pre-wrap;text-align:left">${resp_txt}</pre>
    END

    Append To List    ${parts}    <p style="text-align:center">Fim do log</p>
    Append To List    ${parts}    </div>

    ${html}=    Catenate    SEPARATOR=\n    @{parts}
    Html To Pdf    ${html}    ${out}
    RETURN    ${out}


Mesclar PDFs Da Execução
    ${pdf_dir}=    Set Variable    ${EXECDIR}${/}output${/}pdf
    Directory Should Exist    ${pdf_dir}
    ${arquivos}=   List Files In Directory    ${pdf_dir}    pattern=*.pdf    absolute=True
    Should Not Be Empty    ${arquivos}
    Sort List    ${arquivos}
    ${alvo}=      Set Variable    ${EXECDIR}${/}output${/}execucao.pdf
    # Algumas versões do RPA.PDF têm "Add Files To PDF", outras "Merge PDFs".
    # Tente esta primeiro:
    Run Keyword And Ignore Error    Add Files To PDF    ${arquivos}    ${alvo}
    ${status}    ${msg}=    Run Keyword And Ignore Error    Merge PDFs    ${arquivos}    ${alvo}
    Run Keyword If    '${status}'=='FAIL'    Fail    Não foi possível mesclar PDFs: ${msg}
    Log    PDFs mesclados em: ${alvo}

Mesclar PDFs Da Execução (Python)
    ${saida}=    Merge Pdfs    input_dir=output/pdf    pattern=*.pdf    out=output/execucao.pdf
    Log    PDFs mesclados em: ${saida}