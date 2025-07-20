import os
import glob
from fpdf import FPDF
import textwrap

def convert_graydon_talks_to_pdf():
    # Get all .md files from graydon_talks directory
    md_files = glob.glob('graydon_talks/*.md')
    md_files.sort()  # Sort files in order
    
    if not md_files:
        print("No markdown files found in graydon_talks/ directory")
        return
    
    # Create PDF with better formatting
    pdf = FPDF()
    pdf.set_auto_page_break(auto=True, margin=15)
    pdf.add_page()
    pdf.set_font("Helvetica", size=10)
    
    # Process each file
    for md_file in md_files:
        filename = os.path.basename(md_file)
        print(f"Processing {filename}...")
        
        with open(md_file, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Split content into manageable chunks
        lines = content.split('\n')
        
        for line in lines:
            # Handle empty lines
            if not line.strip():
                pdf.ln(4)
                continue
            
            # Handle very long lines by wrapping them
            if len(line) > 80:
                wrapped_lines = textwrap.wrap(line, width=80)
                for wrapped_line in wrapped_lines:
                    # Encode to handle special characters
                    try:
                        encoded_line = wrapped_line.encode('latin1', 'replace').decode('latin1')
                        pdf.multi_cell(0, 5, encoded_line)
                    except Exception as e:
                        print(f"Encoding error: {e}")
                        pdf.multi_cell(0, 5, "[encoding error]")
            else:
                try:
                    encoded_line = line.encode('latin1', 'replace').decode('latin1')
                    pdf.multi_cell(0, 5, encoded_line)
                except Exception as e:
                    print(f"Encoding error: {e}")
                    pdf.multi_cell(0, 5, "[encoding error]")
        
        # Add separator between files
        pdf.add_page()
    
    # Save PDF
    output_path = "graydon_talks_combined.pdf"
    pdf.output(output_path)
    print(f"Successfully converted {len(md_files)} .md files to {output_path}")

if __name__ == "__main__":
    convert_graydon_talks_to_pdf()