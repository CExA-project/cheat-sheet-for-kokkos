# Contributing

## Versioning

The cheat sheet version is a combination of the Kokkos version and the timestamp when doing a release:

```
4.2.0.20240226
^ ^ ^ ^
| | | + Cheat sheet generation date in the form YYYYMMDD
| | +-- Kokkos patch version
| +---- Kokkos minor version
+------ Kokkos major version
```

The version is stored in the `VERSION` file.

## Custom syntax highlight

### Use a GUI LaTeX editor

As explained in the [main page](README.md), the syntax highlight theme for Minted is provided by a custom package that has to be installed.
In order to use your favorite GUI LaTeX editor, you either need to install the package at user level (which may not work on recent systems, as this practice is [being discouraged](https://peps.python.org/pep-0668/)):

```sh
pip install --user .
```

or keep it in a virtual env, and open your LaTeX editor from the same terminal:

```sh
source venv/bin/activate

texstudio &
```

### Disable custom syntax highlight

If the custom style cannot be used, comment out the `kokkoshighlight` class option in the LaTeX files you want to build.
The style would fallback to `friendly`:

```latex
\documentclass[
    %...
    %kokkoshighlight,
]{./cheat_sheet_kokkos}
```

## Print mode

In order to print the file with a printer that cannot print the entire area of the paper, you can enable the print mode.
This mode is suited for A3 printing on a foldable booklet.
It adds extra internal and external margins, and takes care of possible small miss-alignments of the page with the printer:

```latex
\documentclass[
    %...
    print,
]{./cheat_sheet_kokkos}
```

The margins can be adjusted within the class file `cheat_sheet_kokkos.cls`.
