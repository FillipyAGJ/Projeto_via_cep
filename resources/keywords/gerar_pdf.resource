*** Settings ***
Resource    ../../config/config.resource
Resource    ../request/request.robot

*** Keywords ***

Gerar PDF deste teste
<<<<<<< HEAD
    [Arguments]    ${nome}    ${cep}=None    ${response}=None    ${status}=None    ${url}=None    ${metodo}=None
    ...    ${headers}=None    ${tempo_ms}=None    ${mensagem}=None
=======
    [Arguments]    ${nome}=${None}    ${cep}=${None}    ${response}=${None}    ${status}=${None}    ${url}=${None}
    ...    ${metodo}=${None}    ${headers}=${None}    ${tempo_ms}=${None}
>>>>>>> f7c03bb9e180d45850c90b339ebc2fe37f54afa5
    Create Directory    output/pdf
    # Gera o nome do arquivo PDF
    ${safe_nome}=    Replace String    ${nome}    ${SPACE}    -
    ${pdf_nome}=     Set Variable    Tempo_CEP_${safe_nome}_${cep}.pdf
    ${pdf_path}=     Set Variable    output/pdf/${pdf_nome}
    
    # Gera o conteúdo do PDF
    ${out}=    Gerar PDF com log
    ...    nome_consulta=${nome}
    ...    cep=${cep}
    ...    response=${response}
    ...    status=${status}
    ...    url_utilizada=${url}
    ...    metodo=${metodo}
    ...    headers=${headers}
    ...    tempo_ms=${tempo_ms}
<<<<<<< HEAD
    ...    mensagem=${mensagem}
=======
    ...    out=${pdf_path}

    Attach File     ${pdf_path}    name=Relatório ${nome}    attachment_type=application/pdf

    Log    PDF gerado em: ${pdf_path}
    RETURN    ${pdf_path}
>>>>>>> f7c03bb9e180d45850c90b339ebc2fe37f54afa5



Gerar PDF com log
    [Arguments]    ${nome_consulta}=${EMPTY}    ${cep}=None    ${status}=None    ${metodo}=None
    ...            ${url_utilizada}=None        ${headers}=None   ${response}=None
    ...            ${out}=None                  ${tempo_ms}=None    ${mensagem}=None

    IF    $out is None
        ${ts}=      Get Current Date    result_format=%Y%m%d-%H%M%S
        ${safe}=    Replace String    ${nome_consulta}    ${SPACE}    -
        ${out}=     Set Variable    output/pdf/${ts}_${safe}.pdf
    END

    @{parts}=    Create List
    Append To List    ${parts}    <html><body style="font-family:Arial,Helvetica,sans-serif;max-width:820px;margin:0 auto;padding:20px;text-align:center">

    # ---------- CABEÇALHO ----------
    Append To List    ${parts}    <h2 style="text-align:center;color:#1757C2;margin-bottom:10px">${nome_consulta}</h2>

    # Corrigindo as condições - usando sintaxe correta do Robot Framework
    Run Keyword If    $status != None         Append To List    ${parts}    <p style="text-align:center"><b>Status:</b> ${status}</p>
    Run Keyword If    $url_utilizada != None  Append To List    ${parts}    <p style="text-align:center"><b>URL:</b> ${url_utilizada}</p>
    Run Keyword If    $cep != None            Append To List    ${parts}    <p style="text-align:center"><b>Massa de CEP:</b> ${cep}</p>
    Run Keyword If    $metodo != None         Append To List    ${parts}    <p style="text-align:center"><b>Método:</b> ${metodo}</p>
    Run Keyword If    $mensagem != None         Append To List    ${parts}    <p style="text-align:center"><b>Schema json de validação:</b> ${mensagem}</p>
    Run Keyword If    $tempo_ms != None       Append To List    ${parts}    <p style="text-align:center"><b>Tempo de resposta:</b> ${tempo_ms} ms</p>

    # Linha separadora após informações do teste
    Append To List    ${parts}    <hr style="border:none;border-top:2px solid #1757C2;margin:20px 0;width:80%;">

    # ---------- HEADERS ----------
    IF    $headers != None
        # Verificando se é um objeto response
        ${is_response}=    Run Keyword And Return Status    
        ...    Should Contain    ${headers.__class__.__name__}    Response
        
        IF    ${is_response}
            ${hdrs}=    Set Variable    ${headers.request.headers}
        ELSE
            ${hdrs}=    Set Variable    ${headers}
        END
        
        # Tentando converter para JSON formatado
        ${json_status}    ${json_headers}=    Run Keyword And Ignore Error
        ...    Evaluate    json.dumps(dict($hdrs), ensure_ascii=False, indent=4)    modules=json

        Append To List    ${parts}    <div style="margin:20px 0;text-align:left"><h3 style="text-align:center;color:#1757C2;">Headers</h3>
        
        IF    '${json_status}' == 'PASS'
            # Escapando HTML e adicionando quebras de linha explícitas
            ${json_escaped}=    Replace String    ${json_headers}    &    &amp;
            ${json_escaped}=    Replace String    ${json_escaped}    <    &lt;
            ${json_escaped}=    Replace String    ${json_escaped}    >    &gt;
            ${json_escaped}=    Replace String    ${json_escaped}    \n    <br/>
            Append To List    ${parts}    <div style="background:#f5f5f5;padding:15px;border-radius:6px;font-family:'Courier New',monospace;font-size:12px;white-space:pre-line;overflow-wrap:break-word;">${json_escaped}</div>
        ELSE
            ${hdrs_escaped}=    Replace String    ${hdrs}    &    &amp;
            ${hdrs_escaped}=    Replace String    ${hdrs_escaped}    <    &lt;
            ${hdrs_escaped}=    Replace String    ${hdrs_escaped}    >    &gt;
            Append To List    ${parts}    <div style="background:#f5f5f5;padding:15px;border-radius:6px;font-family:'Courier New',monospace;font-size:12px;">${hdrs_escaped}</div>
        END
        
        Append To List    ${parts}    </div>
        
        # Linha separadora após headers
        Append To List    ${parts}    <hr style="border:none;border-top:2px solid #1757C2;margin:20px 0;width:80%;">
    END

    # ---------- RESPONSE ----------
    IF    $response != None
        # Verificando se tem atributo text (objeto response)
        ${has_text_status}=    Run Keyword And Return Status    
        ...    Should Not Be Empty    ${response.text}
        
        IF    ${has_text_status}
            ${text}=    Set Variable    ${response.text}
        ELSE
            ${text}=    Set Variable    ${response}
        END
        
        # Verificando se é HTML baseado no conteúdo
        ${is_html}=    Run Keyword And Return Status    Should Contain    ${text}    <!DOCTYPE
        
        IF    ${is_html}
            # Extraindo apenas o conteúdo visível do HTML
            
            # Extraindo título
            ${title}=    Set Variable    ${EMPTY}
            ${title_start}=    Run Keyword And Return Status    Should Contain    ${text}    <title>
            IF    ${title_start}
                ${parts_title}=    Split String    ${text}    <title>    1
                ${title_part}=    Get From List    ${parts_title}    1
                ${parts_title_end}=    Split String    ${title_part}    </title>    1
                ${title}=    Get From List    ${parts_title_end}    0
            END
            
            # Extraindo conteúdo do body (tags h1, h2, h3, p)
            ${body_content}=    Set Variable    ${EMPTY}
            
            # Procurando por H1
            ${h1_matches}=    Get Regexp Matches    ${text}    <h1[^>]*>(.*?)</h1>    1
            FOR    ${h1}    IN    @{h1_matches}
                ${body_content}=    Catenate    ${body_content}    ${h1} 
            END
            
            # Procurando por H2
            ${h2_matches}=    Get Regexp Matches    ${text}    <h2[^>]*>(.*?)</h2>    1
            FOR    ${h2}    IN    @{h2_matches}
                ${body_content}=    Catenate    ${body_content}    ${h2} 
            END
            
            # Procurando por H3
            ${h3_matches}=    Get Regexp Matches    ${text}    <h3[^>]*>(.*?)</h3>    1
            FOR    ${h3}    IN    @{h3_matches}
                ${body_content}=    Catenate    ${body_content}    ${h3} 
            END
            
            # Procurando por P
            ${p_matches}=    Get Regexp Matches    ${text}    <p[^>]*>(.*?)</p>    1
            FOR    ${p}    IN    @{p_matches}
                ${body_content}=    Catenate    ${body_content}    ${p} 
            END
            
            # Montando o conteúdo final
            ${final_content}=    Set Variable    ${EMPTY}
            IF    '${title}' != '${EMPTY}'
                ${final_content}=    Catenate    ${final_content}    ${title} 
            END
            ${final_content}=    Catenate    ${final_content}    ${body_content}
            
            # Removendo espaços extras e limpando o conteúdo
            ${clean_content}=    Replace String Using Regexp    ${final_content}    \\s+    ${SPACE}
            ${clean_content}=    Strip String    ${clean_content}
            
            # Escapando HTML para exibição
            ${clean_content}=    Replace String    ${clean_content}    &    &amp;
            ${clean_content}=    Replace String    ${clean_content}    <    &lt;
            ${clean_content}=    Replace String    ${clean_content}    >    &gt;
            
            Append To List    ${parts}    <div style="margin:20px 0;text-align:left"><h3 style="text-align:center;color:#1757C2;">Response</h3><div style="background:#f5f5f5;padding:15px;border-radius:6px;font-size:14px;line-height:1.6;text-align:center;">${clean_content}</div></div>
        ELSE
            # Tentando fazer parse JSON
            ${json_status}    ${json_response}=    Run Keyword And Ignore Error    
            ...    Evaluate    json.loads("""${text}""")    modules=json
            
            IF    '${json_status}' == 'PASS'
                ${resp_txt}=    Evaluate    json.dumps($json_response, ensure_ascii=False, indent=4)    modules=json
                ${resp_escaped}=    Replace String    ${resp_txt}    \n    <br/>
                ${resp_escaped}=    Replace String    ${resp_escaped}    ${SPACE}${SPACE}    &nbsp;&nbsp;
                Append To List    ${parts}    <div style="margin:20px 0;text-align:left"><h3 style="text-align:center;color:#1757C2;">Response</h3><div style="background:#f5f5f5;padding:15px;border-radius:6px;font-family:'Courier New',monospace;font-size:12px;line-height:1.6;">${resp_escaped}</div></div>
            ELSE
                # Texto simples - limpando tags <br/> e formatando
                ${text_clean}=    Replace String    ${text}    <br/>    ${SPACE}
                ${text_clean}=    Replace String Using Regexp    ${text_clean}    \\s+    ${SPACE}
                ${text_clean}=    Strip String    ${text_clean}
                
                # Escapando HTML para exibição
                ${text_escaped}=    Replace String    ${text_clean}    &    &amp;
                ${text_escaped}=    Replace String    ${text_escaped}    <    &lt;
                ${text_escaped}=    Replace String    ${text_escaped}    >    &gt;
                
                Append To List    ${parts}    <div style="margin:20px 0;text-align:left"><h3 style="text-align:center;color:#1757C2;">Response</h3><div style="background:#f5f5f5;padding:15px;border-radius:6px;font-family:'Courier New',monospace;font-size:12px;text-align:center;">${text_escaped}</div></div>
            END
        END
    END

    # ---------- RODAPÉ ----------
    Append To List    ${parts}    <hr style="border:none;border-top:2px solid #1757C2;margin:20px 0;width:80%;">
    Append To List    ${parts}    <p style="text-align:center"><i>Fim do log</i></p>
    Append To List    ${parts}    </body></html>

    ${html}=    Catenate    SEPARATOR=\n    @{parts}
    Html To Pdf    ${html}    ${out}
    RETURN    ${out}