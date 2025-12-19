# Cheat sheets for Kokkos

This repository contains printable cheat-sheets for Kokkos, typed in LaTeX.

## Requirements

- PDFLatex (from at least `texlive-latex-extra`);
- Python 3; and
- Pygments.

## Local dependencies

The syntax highlight uses a custom theme that must be installed with:

```sh
pip install .
```

<details>

<summary>Note that you should use a virtual env to install it.</summary>

```sh
virtualenv --python python<x.y> $PWD/venv
source venv/bin/activate
pip install .
```

with `<x.y>` the version of Python.
Note you have to `source` each time you want to use it.

</details>

If you cannot install this dependency, you may not be able to build the document.
To circumvent this, you can remove the `kokkoshighlight` class option in LaTeX files.

## Build

Build all documents with:

```sh
make
```

## Resources

- Full documentation: https://kokkos.org/kokkos-core-wiki/index.html
- GitHub sources: https://github.com/kokkos
- Tutorials: https://github.com/kokkos/kokkos-tutorials


