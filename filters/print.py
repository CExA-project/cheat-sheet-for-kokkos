#!/usr/bin/env python

import pandocfilters as pf
import sys

def latex(s):
    return pf.RawBlock('latex', s)

def inlatex(s):
    return pf.RawInline('latex', s)

def tbl_alignment(s, v, threshold=10):
    aligns = {
        "AlignDefault": 'l',
        "AlignLeft": 'l',
        "AlignCenter": 'c',
        "AlignRight": 'r',
    }
    # compute the maximum size of each column
    col_sizes = [0] * len(s)
    for row in v:
        for index, col in enumerate(row):
            if col:
                size = 0

                for index_word, word in enumerate(col[0]['c']):
                    if word['t'] == "Str":
                        size += len(word['c'])

                col_sizes[index] = max(col_sizes[index], size)

    # make the column big if its size is over threshold
    aligments = []
    for index, e in enumerate(s):

        if col_sizes[index] >= threshold:
            aligments.append('X')
            continue

        aligments.append(aligns[e['t']])

    # if there are no big columns, make the first left one big
    if "X" not in aligments:
        try:
            aligments[aligments.index("l")] = "X"

        except ValueError:
            pass

    return ''.join(aligments)

    # # make last column larger
    # aligments = []
    # for i, e in enumerate(s):
    #     if i == len(s) - 1:
    #         aligments.append("X")
    #         continue
    #
    #     aligments.append(aligns[e['t']])
    #
    # return ''.join(aligments)

def tbl_headers(s):
    result = s[0][0]['c'][:]
    # Build the columns. Note how the every column value is bold.
    # We are still missing "\textbf{" for the first column
    # and a "}" for the last column.
    for i in range(1, len(s)):
        result.append(inlatex(r'} & \tblhead{'))
        result.extend(s[i][0]['c'])
    # Don't forget to close the last column's "\textbf{" before newline
    result.append(inlatex(r'} \\ \midrule'))
    # Put the missing "\textbf{" in front of the list
    result.insert(0, inlatex(r'\tblhead{'))
    return pf.Para(result)

def tbl_contents(s):
    result = []
    for row in s:
        para = []
        for col in row:
            if col:
                para.extend(col[0]['c'])
                para.append(inlatex(' & '))
        result.extend(para)
        result[-1] = inlatex(r' \\' '\n')
    return pf.Para(result)

def do_filter(k, v, f, m):
    if k == "Table":
        return [
                latex(r'\begin{tabularx}{\linewidth}{%s}' % tbl_alignment(v[1], v[4]) + '\n' r'\toprule'),
                tbl_headers(v[3]),
                tbl_contents(v[4]),
                latex(r'\bottomrule' '\n' r'\end{tabularx}'),
            ]


if __name__ == "__main__":
    pf.toJSONFilter(do_filter)
