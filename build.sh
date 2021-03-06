#!/usr/bin/env bash

# Delete generated assets
rm -rf output
mkdir output

# Set CSS styles source
css="pdf.css"
echo "Using CSS styles from $css"

# Define starting directory
base_dir="$(pwd)"

# Create folder for general assets
mkdir output/general

# Generate general assets
for doc in general/*.md; do

    # Generate assets as .pdf
    if [ -f $doc ]; then
        out="output/general/$(echo "$doc" | sed 's|/|-|g' | sed 's|.md|.pdf|')"
        echo "Generating document from $doc to $out"
        markdown-pdf "$doc" --out "$out" --cwd general --css-path "$css"
    fi
done

# Copy technical files used by Remark
cp -r "slide-files" "output/"

# Go through each module
for mod in module-*; do
    # Create folder for module
    mkdir "output/$mod"

    # Generate lesson plan .pdf
    doc="$mod/README.md"
    if [ -f $doc ]; then
        out="output/$mod/$mod.pdf"
        echo "Generating lesson plan from $doc to $out"
        markdown-pdf "$doc" --out "$out" --cwd "$mod" --css-path "$css"
    fi

    # Generate handouts as .pdf
    mkdir "output/$mod/handouts"
    for doc in $mod/handouts/*.md; do
        if [ -f $doc ]; then
            out="output/$mod/handouts/$(echo "$doc" | sed 's|/|-|g' | sed 's|.md|.pdf|')"
            echo "Generating handouts from $doc to $out"
            markdown-pdf "$doc" --out "$out" --cwd "$mod/handouts" --css-path "$css"
        fi
    done

    # Copy Remark presentation and generate .pdf copy with DeckTape
    doc="presentation.html"
    cd $mod
    if [ -f $doc ]; then
        # Generate .pdf
        out="../output/$mod/handouts/$mod-presentation.pdf"
        echo "Generating presentation from $mod/$doc to $out"
        decktape remark "$doc" "$out" --chrome-arg=--allow-file-access-from-files

        # Copy Remark presentation
        cp -r "slide-images" "../output/$mod/"
        cp "$doc" "../output/$mod/"
     fi
     cd $base_dir

done
