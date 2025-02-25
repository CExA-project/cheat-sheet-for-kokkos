#!/usr/bin/env python
"""
Pandoc filter to fix tables that are by default rendered with `longtable` and
cannot be used in multicolumn environment.

See:
    https://pandoc-discuss.narkive.com/KRZgvqD0/latex-tables-using-tabular-instead-of-longtable
    https://stackoverflow.com/a/34077289/19422971
"""

import pandocfilters as pf

THRESHOLD_NORMAL = 15
THRESHOLD_CODE = 20


def latex(s):
    return pf.RawBlock("latex", s)


def inlatex(s):
    return pf.RawInline("latex", s)


def has_one_single_code(cell):
    if not cell["c"]:
        return False

    if len(cell["c"]) > 1:
        return False

    if cell["c"][0].get("t") == "Code":
        return True

    return False

def has_long_line(cell, threshold=THRESHOLD_NORMAL):
    size = 0

    for index_word, word in enumerate(cell["c"]):
        if word and "c" in word:
            size += len(word["c"])

    return size >= threshold

def tbl_alignment(s, h, v):
    aligns = {
        "AlignDefault": "l",
        "AlignLeft": "l",
        "AlignCenter": "c",
        "AlignRight": "r",
    }
    # detect columns with one single line of code
    one_single_code_cols = [False] * len(s)
    for row in [h] + v:
        for index_col, col in enumerate(row):
            if col:
                one_single_code_cols[index_col] |= has_one_single_code(col[0])

    # detect columns with long line
    long_line_cols = [False] * len(s)
    for row in [h] + v:
        for index_col, col in enumerate(row):
            if col:
                long_line_cols[index_col] |= has_long_line(col[0], threshold=THRESHOLD_CODE if one_single_code_cols[index_col] else THRESHOLD_NORMAL)

    # mark a left column as big if its size is over threshold
    alignments = []
    for index_col, e in enumerate(s):
        align = aligns[e["t"]]

        if align == "l" and long_line_cols[index_col]:
            alignments.append("X")
            continue

        alignments.append(align)

    # if there are no big columns, make the first left one big
    if "X" not in alignments:
        try:
            alignments[alignments.index("l")] = "X"

        except ValueError:
            pass

    return "".join(alignments)


def tbl_headers(s):
    result = s[0][0]["c"][:]
    # Build the columns. Note how the every column value is altered.
    # We are still missing "\tblhead{" for the first column
    # and a "}" for the last column.
    for i in range(1, len(s)):
        result.append(inlatex(r"} & \tblhead{"))
        result.extend(s[i][0]["c"])
    # Don't forget to close the last column's "\tblhead{" before newline
    result.append(inlatex(r"} \\ \midrule"))
    # Put the missing "\tblhead{" in front of the list
    result.insert(0, inlatex(r"\tblhead{"))
    return pf.Para(result)


def tbl_contents(s):
    result = []
    for row in s:
        para = []
        for col in row:
            if col:
                content = col[0]["c"]

                # un-escape pipe for code within a table
                for word in content:
                    if word["t"] == "Code" and "t" in word:
                        word["c"] = [term.replace(r"\|", "|") if type(term) is str else term for term in word["c"]]

                para.extend(content)

            para.append(inlatex(" & "))
        result.extend(para)
        result[-1] = inlatex(r" \\" "\n")
    return pf.Para(result)


def do_filter(k, v, f, m):
    if k == "Table":
        return [
            latex(
                r"\begin{tabularx}{\linewidth}{%s}" % tbl_alignment(v[1], v[3], v[4]) + "\n"
                r"\toprule"
            ),
            tbl_headers(v[3]),
            tbl_contents(v[4]),
            latex(r"\bottomrule" "\n" r"\end{tabularx}"),
        ]


if __name__ == "__main__":
    pf.toJSONFilter(do_filter)
