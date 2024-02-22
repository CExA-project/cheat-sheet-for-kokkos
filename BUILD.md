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
docker build .
```

## Generate LaTeX files

Call the `convert.sh` script which pre-processes the input Markdown file and converts it to standalone LaTeX sources:

```sh
./convert.sh <file.md>
# or
sudo docker run -v $PWD:/work --user $UID:$GID docker_cheat_sheet ./convert.sh <file.md>
```

Note that the `--user $UID:$GID` is required to produce a file with your ownership.

## Build PDF document

Build the document with:

```sh
pdflatex <file.tex>
```
