import fitz  # PyMuPDF
import json
import os
import re

def process_constitution(pdf_path, output_json):
    if not os.path.exists(pdf_path):
        print(f"Error: {pdf_path} not found.")
        return

    doc = fitz.open(pdf_path)
    content = []
    
    print(f"Processing {pdf_path}...")
    
    current_article = None
    current_text = ""

    # Simple regex to find "Article 123" or "अनुच्छेद 123"
    # Note: Diglot PDF has both English and Hindi.
    article_pattern = re.compile(r'(Article\s+\d+|अनुच्छेद\s+\d+)', re.IGNORECASE)

    for page in doc:
        text = page.get_text()
        lines = text.split('\n')
        
        for line in lines:
            line = line.strip()
            if not line: continue
            
            match = article_pattern.search(line)
            if match:
                # Save previous article
                if current_article:
                    content.append({
                        "id": current_article,
                        "text": current_text.strip()
                    })
                
                current_article = match.group(0)
                current_text = line + "\n"
            else:
                if current_article:
                    current_text += line + " "
                else:
                    # Capture preamble or start of doc
                    current_text += line + " "

    # Final article
    if current_article:
        content.append({
            "id": current_article,
            "text": current_text.strip()
        })

    with open(output_json, 'w', encoding='utf-8') as f:
        json.dump(content, f, ensure_ascii=False, indent=2)
    
    print(f"Successfully created {output_json} with {len(content)} entries.")

if __name__ == "__main__":
    # Point to the PDF you downloaded
    PDF_NAME = "constitution_india_diglot.pdf"
    process_constitution(PDF_NAME, "../assets/constitution.json")
