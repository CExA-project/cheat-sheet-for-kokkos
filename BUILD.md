# Build

This document is intended for paper distribution of the cheat sheets.
The Markdown documents use commented pre-processor instructions to remove unprintable parts.
Then the documents are converted to LaTeX sources, which can be compiled as PDF documents.

## Requirements

- GPP (General Pre-Processor);
- Python; and
- PDFLatex.

## Install dependencies

Note that it is worth to create a virtual environment for the project.
Install Python dependencies with Pip:

```sh
pip install -r requirements.txt
```

## Generate LaTeX files

Call the `convert.sh` script which pre-processes the input Markdown file and converts it to standalone LaTeX sources:

```sh
./convert.sh <file.md>
```

## Build PDF document

Build the document with:

```sh
pdflatex <file.tex>
```
