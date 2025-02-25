# Specific print customizations

## Add print margins to the document

When the LaTeX file has been generated, you can add a print margin in the TEX file to allow a full-size print when the printer automatically crops the edges of the printing area.

See the `\printmargin` length and the other tuning lengths in the preamble of the generated file. Starting values are suggested.

## Add watermark and notes section

When the LaTeX file has been generated, you can add a watermark and/or a notes section at the end of the TEX file. The watermark contains the logo of CExA and of the Maison de la Simulation, aligned to the right. The notes section adds a section named Notes, and prints horizontal dotted lines down to the end of the page.

To add the watermark alone:

```tex
\watermark
```

To add the notes section alone:

```tex
\notessection
```

Note that anything after `\notessection` will be displayed on the next page.

To add the notes section, then the watermark at the bottom of the same page:

```tex
\notessection{\watermark}
```
