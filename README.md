# 📦 Projeto ViaCEP - Testes Automatizados com Robot Framework + Allure

Este projeto realiza testes automatizados na API ViaCEP, com geração de relatórios em PDF e integração com o Allure Reports para uma visualização avançada.

---

## ✅ Pré-requisitos

Antes de iniciar, certifique-se de ter:

- **Python 3.10+**
- **pip 23.2.1+**
- **Google Chrome** (para testes web, se aplicável)
- **Java 8+** (necessário para Allure Reports)

---

## 📁 Estrutura do Projeto

```
Projeto_via_cep/
├── tests/                       # Casos de teste do Robot Framework
├── resources/                  # Schemas e palavras-chave reutilizáveis
├── libs/                       # Scripts Python auxiliares (ex: PDF, JSON Schema)
├── output/                     # Relatórios gerados (PDF, XML, HTML, Allure)
├── requirements.txt            # Dependências do projeto
├── start.bat                   # Execução rápida no Windows
```

---

## 📦 Instalação

Crie e ative um ambiente virtual:

```bash
python -m venv .venv
.venv\Scripts\activate  # Windows
# source .venv/bin/activate  # Linux/Mac
```

Instale as dependências:

```bash
pip install -r requirements.txt
```

## Instalando o allure ferramenta de relatório

Instale o Allure (caso ainda não tenha):

Acesse o link:

https://github.com/allure-framework/allure2/releases/tag/2.35.1


Baixar o .zip e colocar no PATH do sistema

---

## 🚀 Executando os Testes

Execute os testes e gere o relatório:

```bash
.\start.bat
```

> Isso executa os testes, gera PDFs com as consultas e salva tudo em `output/`.

---

## 📄 Visualizar os PDFs Gerados

Os PDFs ficam na pasta:

```
output/pdf/
```

Você pode mesclar os arquivos PDF gerados automaticamente com o comando (caso tenha ativado essa funcionalidade):

```bash
python libs/pdf_merge.py
```

---

## 📊 Visualizar o Allure Report

Após a execução dos testes:

```bash
allure serve output/allure-results
```

Ou, para gerar e manter localmente:

```bash
allure generate output/allure-results --clean -o output/allure-report
start output/allure-report/index.html  # Windows
```

---

## 📎 Anexos no Allure

O sistema já está configurado para anexar **PDFs dos testes** diretamente no Allure. Basta garantir que:

- O método `Adicionar PDF ao Relatório` esteja sendo chamado com o caminho correto.
- Os PDFs tenham sido gerados sem erros.

---

## 🛠 Manutenção

Para limpar os relatórios e começar do zero:

```bash
robot --outputdir output --log NONE --report NONE --output NONE --nostatusrc --test "Testes vazios"
```

Ou manualmente:

```bash
rmdir /s /q output
mkdir output\pdf output\allure-results
```

---

## 👤 Autor

Projeto mantido por Fillipy Antony Gabriel Jesuino