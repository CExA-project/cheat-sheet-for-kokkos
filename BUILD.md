# Build

This document is intended for paper distribution of the cheat sheets.
The Markdown documents use commented pre-processor instructions to remove unprintable parts.
Then the documents are converted to LaTeX sources, which can be compiled as PDF documents.

## Setup

### Requirements

- GPP (General Pre-Processor);
- Pandoc 2;
- PDFLatex (from at least `texlive-latex-extra`); and
- Python 3.

Note that Pandoc 2 is not available anymore on Ubuntu 24.04 !
In that case, please use the provided Docker image.

### Install dependencies

Note that it is worth to create a [virtual environment](https://packaging.python.org/en/latest/guides/installing-using-pip-and-virtual-environments/) for the project:

```sh
python3 -m venv .venv
```

which you can activate with:

```sh
source .venv/bin/activate
```

Install Python dependencies with Pip:

```sh
pip3 install -r requirements.txt
```

Or, without using a virtual environment:

```sh
pip3 install --user -r requirements.txt
```

### Docker image

A docker image containing all dependencies (minus LaTeX) is available:

```sh
sudo docker build -t kokkos_cheat_sheet .
```

## Generate LaTeX files

Call the `convert.sh` script which pre-processes the input Markdown file and converts it to standalone LaTeX sources:

```sh
./convert.sh <file.md>
# or
sudo docker run --rm -v $PWD:/work kokkos_cheat_sheet --user $UID:$GID ./convert.sh <file.md>
```

Note that `--user $UID:$GID` is required to produce a file with your ownership on some systems.

## Build PDF document

Build the document with:

```sh
pdflatex <file.tex>
```

Note that calling `convert.sh` with `-b` automatically builds the generated file, but this option cannot be used when the script is executed with Docker.
