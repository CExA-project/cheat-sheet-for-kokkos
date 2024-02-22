# Contributing

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
