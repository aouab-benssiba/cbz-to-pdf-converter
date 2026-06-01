#!/bin/bash

set -xe

# 1. Parse the -i and -o flags
while getopts "i:o:" opt; do
  case ${opt} in
    i ) folder=$OPTARG ;;
    o ) out_folder=$OPTARG ;;
    \? ) echo "Usage: $0 -i /path/to/input -o /path/to/output"; exit 1 ;;
  esac
done

# Ensure input folder was provided
if [ -z "$folder" ]; then
    echo "Error: Input folder (-i) is required."
    exit 1
fi

# If no output folder is provided, default to the input folder
if [ -z "$out_folder" ]; then
    out_folder="$folder"
fi

# Ensure output folder exists
mkdir -p "$out_folder"

# 2. Rename files to standard extensions safely (Handles spaces properly)
find "$folder" -type f -name "*.cbr" -execdir mv '{}' '{}'.rar \;
find "$folder" -type f -name "*.cbz" -execdir mv '{}' '{}'.zip \;

# 3. Convert all archives to PDF
find "$folder" -type f \( -name "*.rar" -o -name "*.zip" \) |
while read file; do
  TMP_FOLDER=$(mktemp -d)
  
  # Extract based on file type
  case "$file" in
    *.rar)
      unrar e "$file" "$TMP_FOLDER"
      ;;
    *.zip)
      unzip -j "$file" -d "$TMP_FOLDER"
      ;;
  esac
  
  cd "$TMP_FOLDER"
  
  # Find all images, convert them individually to small PDFs using up to 8 CPU cores
  ls -1 ./*jpg ./*jpeg ./*webp ./*tiff ./*png 2>/dev/null | pv -lep -s $(ls -1 ./*jpg ./*jpeg ./*webp ./*tiff ./*png 2>/dev/null | wc -l) | xargs -P 8 -I {} img2pdf {} -o {}.pdf
  
  # Merge all the single-page PDFs into one final volume
  pdftk *.pdf cat output combined.pdf
  
  # Get the clean original filename without the .rar/.zip extensions
  FILENM=$(basename "$file" | sed 's/.rar$//;s/.zip$//')
  
  # Move the finished PDF to your designated output folder (-o)
  cp "$TMP_FOLDER/combined.pdf" "$out_folder/${FILENM}.pdf"
  
  # Clean up temp files and delete the original archive
  rm -rf "$TMP_FOLDER"
  rm "$file"
done

echo "Conversion completed!"
