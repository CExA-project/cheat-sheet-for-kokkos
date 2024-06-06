# Build

This document is intended for paper distribution of the cheat sheets.
The Markdown documents use commented pre-processor instructions to remove unprintable parts.
Then the documents are converted to LaTeX sources, which can be compiled as PDF documents.

## Setup

### Requirements

- GPP (General Pre-Processor);
- Pandoc;
- PDFLatex (from at least `texlive-latex-extra`); and
- Python 3.

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
docker build -t kokkos_cheat_sheet .
```

## Generate LaTeX files

Call the `convert.sh` script which pre-processes the input Markdown file and converts it to standalone LaTeX sources:

```sh
./convert.sh <file.md>
# or
docker run --rm -v $PWD:/work docker_cheat_sheet ./convert.sh <file.md>
```

Note that an additional `--user $UID:$GID` can be required to produce a file with your ownership on some systems.

## Build PDF document

Build the document with:

```sh
pdflatex <file.tex>
```

Note that calling `convert.sh` with `-b` automatically builds the generated file, but this option cannot be used when the script is executed with Docker.
