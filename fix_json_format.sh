#!/bin/bash
# Fix JSON format in all documentation files

files="README.md docs/*.md"

for file in $files; do
    if [ -f "$file" ]; then
        echo "Fixing $file..."
        sed -i 's/"model_name"/"model_id"/g' "$file"
        sed -i 's/"model_type"/"operator"/g' "$file"  
        sed -i 's/"domain": {"type": "\([^"]*\)"}/"domain": "\1"/g' "$file"
        sed -i 's/"constraints"/"contracts"/g' "$file"
    fi
done

echo "JSON format fixes complete!"
