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

## Custom syntax highlight

As explained in the [main page](README.md), the syntax highlight of Minted is provided by a custom package that has to be installed.
In order to use your favorite GUI LaTeX editor, you either need to install the package at user level (which may not work on recent systems, as this practice is [being discouraged](https://peps.python.org/pep-0668/)):

```sh
pip install --user .
```

or keep it in a virtual env, and open your LaTeX editor from the same terminal:

```sh
source venv/bin/activate

texstudio &
```
