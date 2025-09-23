from pypdf import PdfMerger
import glob, os

def merge_pdfs(input_dir="output/pdf", pattern="*.pdf", out="output/execucao.pdf"):
    files = sorted(glob.glob(os.path.join(input_dir, pattern)))
    if not files:
        raise ValueError(f"Nenhum PDF encontrado em {input_dir}/{pattern}")
    os.makedirs(os.path.dirname(out), exist_ok=True)
    merger = PdfMerger()
    for f in files:
        merger.append(f)
    with open(out, "wb") as fp:
        merger.write(fp)
    merger.close()
    return out