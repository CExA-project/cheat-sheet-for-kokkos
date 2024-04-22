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

## Pre-processor

Since Markdown does not have branching controls, we use pre-processor instructions, that are parsed by [GPP (Generic Preprocessor)](https://logological.org/gpp).
These instructions have the similar syntax as the C pre-processor ones, but are encapsulated within Markdown comments, so that the un-pre-processed file remains a valid Markdown file:

```md
<!--#PRE_PROCESSOR_INSTRUCTION-->
```

Note that there are *no spaces* between the Markdown comment symbol and the pre-processor instruction.
By instance, in order to display text only if the `PRINT` macro is defined:

```md
<!--#ifdef PRINT-->
Only visible in printed version!
<!--#endif-->
```

Reversely, in order to hide text if the `PRINT` macro is defined (which is the most common case):

```md
<!--#ifndef PRINT-->
Not visible in printed version!
<!--#endif-->
```

Passing macros to GPP is similar with passing macros to a C compiler:

```sh
gpp <file.md> -DPRINT
```

For now, the `PRINT` macro is used for print mode.

## Patching

Patches are used to keep specific adjustments in the final document that cannot be present in the source Markdown file.
Namely, such changes include manual page breaks, abbreviations, etc.
Large modification, however, such as the removal of an entire section, are better handled by the pre-processor discussed above.

A patch is associated with a converted file in the form `name.ext.diff`, and is stored under `patches/<mode>/name.ext.diff` (with `<mode>` being `print` for print mode).
If a patch file exists with the same name, then the patch is automatically applied when calling `convert.sh`.

The creation of the patch uses the following workflow:

```sh
./generate_patch.sh <file.md> start
# edit <file.tex> and perform specific adjustments
./generate_patch.sh <file.md> end
```

Any consecutive call to `generate_patch.sh` will cumulate the modifications.
