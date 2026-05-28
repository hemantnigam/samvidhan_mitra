import os
import time
import google.generativeai as genai

# 1. SETUP: Replace with your actual Gemini API Key
API_KEY = "YOUR_GEMINI_API_KEY"
genai.configure(api_key=API_KEY)

# 2. PDF PATH: The official Constitution PDF URL or local path
# You can download it first or point to a local file
PDF_PATH = "constitution_india_diglot.pdf" 

def upload_and_index():
    print(f"Uploading {PDF_PATH} to Gemini File API...")
    
    # Upload the file
    sample_file = genai.upload_file(path=PDF_PATH, display_name="Constitution of India (Diglot)")
    print(f"Uploaded file '{sample_file.display_name}' as: {sample_file.uri}")

    # Files must be processed before they can be used in a prompt.
    # We poll the state to ensure it's ready.
    print("Indexing file... (This may take 1-2 minutes for a large PDF)")
    while sample_file.state.name == "PROCESSING":
        print(".", end="", flush=True)
        time.sleep(5)
        sample_file = genai.get_file(sample_file.name)

    if sample_file.state.name == "FAILED":
        raise ValueError(f"File {sample_file.name} failed to process")

    print(f"\n\nSUCCESS!")
    print("-" * 30)
    print(f"FILE_URI: {sample_file.uri}")
    print("-" * 30)
    print("\nCopy the FILE_URI above and paste it into 'lib/utils/constants.dart' in your Flutter project.")

if __name__ == "__main__":
    if not os.path.exists(PDF_PATH):
        print(f"Error: Could not find {PDF_PATH}")
        print("Please download the PDF from: https://www.legislative.gov.in/static/uploads/2025/08/cb1b190ea633a1746368ed1fac35fb30.pdf")
        print(f"And save it as '{PDF_PATH}' in this folder.")
    elif API_KEY == "YOUR_GEMINI_API_KEY":
        print("Error: Please set your API_KEY in the script first.")
    else:
        upload_and_index()
