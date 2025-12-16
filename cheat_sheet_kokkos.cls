\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{cheat_sheet_kokkos}[2025/12/15 Cheat sheet for Kokkos class]

\LoadClass[
  10pt,
  a4paper,
  twoside
]{article}

% tweaking
\RequirePackage{etoolbox}

% fonts
\RequirePackage{lmodern}

\renewcommand{\familydefault}{\sfdefault}

% colors
\RequirePackage{xcolor}

%% base color
\definecolor{kokkos}{RGB}{30, 120, 152}

%% other colors
\colorlet{main}{kokkos!80}
\colorlet{lightmain}{kokkos!30}
\colorlet{dimmedmain}{kokkos!50}
\colorlet{lightgray}{gray!20}
\colorlet{darkgray}{gray!70!black}
\colorlet{alert}{red!70!cyan}
\colorlet{lightalert}{alert!20}
\colorlet{example}{cyan!80!gray!50}
\colorlet{lightexample}{example!30}

% links
\RequirePackage{hyperref}

\hypersetup{
  hidelinks,
}

% urls
\RequirePackage{url}

%% disable monospaced font for URLs
\urlstyle{same}

% listings
\RequirePackage{minted}

\setminted{
    autogobble,
    fontsize=\scriptsize,
    bgcolor=lightgray,
    breaklines,
    resetmargins,
    style=lovelace
}

\setmintedinline{
    bgcolor=\empty,
}

%% remove minted vertical margins
\makeatletter
\patchcmd{\minted@colorbg}{\medskip}{\smallskip}{}{}
\patchcmd{\endminted@colorbg}{\medskip}{\smallskip}{}{}
\makeatother

% page
\RequirePackage[hmargin=0.5cm, vmargin=0cm, includeheadfoot]{geometry}

% columns
\RequirePackage{multicol}

% computations
\RequirePackage{calc}

% tables
\RequirePackage{tabularray}

\NewTblrTheme{kokkostable}{
    \SetTblrInner{
        width=\linewidth,
        rowhead=1,
        row{odd}={bg=lightgray},
        row{1}={bg=lightmain},
        stretch=0,
        rowsep=3.6pt,
    }
}

\AtBeginEnvironment{tblr}{\smallskip}
\AtEndEnvironment{tblr}{\smallskip}

% text alignment
\RequirePackage{ragged2e}

% images
\RequirePackage{graphicx}

\graphicspath{{images/}}

% conditions
\RequirePackage{ifthen}

% headers and footers
\RequirePackage{fancyhdr}

\newlength{\headerheight}
\newlength{\footerheight}
\newlength{\headerheightreduction}
\newlength{\footerheightreduction}
\newlength{\horizontalskip}
\newlength{\printmargin}
\newlength{\printmarginwidth}
\newlength{\printmarginheight}
\newlength{\marginwidth}
\newlength{\marginwidthreduction}
\newlength{\footheight}
\newlength{\headerfooterskip}
\newlength{\headerfooterskipreduction}

%% print sizes tuning

%%% change here to add print margin
%%% This adds \printmargin on the outer horizontal margin (think two-sided
%%% document) and 0.75\printmargin on the top and bottom vertical
%%% margins in other words, this adds \printmargin horizontally and
%%% 1.5\printmargin vertically note that using this variable will certainly mess
%%% with the page layout! To counterbalance this, you can tune the other
%%% lengths defined below.
%%% a good first guess is 0.4cm
\setlength{\printmargin}{0cm}

%%% change here to reduce the effect of \printmargin on the outer horizontal
%%% margin for the text body only
%%% a good first guess is 0.2cm
\setlength{\marginwidthreduction}{0cm}

%%% change here to reduce the space between the text and the header/footer
%%% a good first guess is 0.2cm
\setlength{\headerfooterskipreduction}{0cm}

%%% change here to reduce the height of the header
%%% a good first guess is 0.2cm
\setlength{\headerheightreduction}{0cm}

%%% change here to reduce the height of the footer
%%% a good first guess is 0.2cm
\setlength{\footerheightreduction}{0cm}

%%% change here to put a factor ratio on text size
%%% change this value if nothing else helps!
%%% a good first guess is 0.95
\newcommand{\textratio}{1}

\fancypagestyle{kokkos}{%
    \setlength{\headerheight}{2cm - \headerheightreduction}
    \setlength{\footerheight}{0.5cm - \footerheightreduction}
    \setlength{\horizontalskip}{0.25cm}
    \setlength{\marginwidth}{0.5cm}
    \setlength{\headerfooterskip}{0.5cm - \headerfooterskipreduction}
    \setlength{\printmarginwidth}{\printmargin}
    \setlength{\printmarginheight}{0.75\printmargin}

    \renewcommand{\headrulewidth}{0pt}
    \renewcommand{\footrulewidth}{0pt}

    \newgeometry{
        inner=\marginwidth,
        outer=\marginwidth + \printmarginwidth - \marginwidthreduction,
        vmargin=0cm,
        includeheadfoot,
        headheight=\headerheight + \printmarginheight,
        headsep=\headerfooterskip,
        footskip=\headerfooterskip + \footerheight + \printmarginheight,
    }

    % set missing footheight
    \setlength{\footheight}{\footerheight + \printmarginheight}

    % set offsets for the header and footer blocks to have exactly the width of the page
    \fancyhfoffset[RE,LO]{\marginwidth}
    \fancyhfoffset[LE,RO]{\marginwidth + \printmarginwidth - \marginwidthreduction}

    \fancyhf{}

    \fancyhead{%
        % Add the title, the page number, and the version
        \setlength{\fboxsep}{0pt}%
        \colorbox{main}{%
            % logo with continuation
            \parbox[b][\headheight][b]{\headheight}{%
                % add left continuation of the logo
                \ifthenelse{\isodd{\value{page}}}{%
                }{%
                    \colorbox{lightmain}{%
                        \parbox[b][\headheight]{\printmargin}{~}%
                    }%
                }%
                \begin{minipage}[b][\headheight][b]{\headerheight}
                    % add top continuation of the logo
                    \colorbox{lightmain}{%
                        \parbox[b][\printmargin][b]{
                            0.575\headerheight% manual adjust logo height
                        }{~}%
                    }%
                    \vspace{-0.04cm} % manual adjust vertical gap
                    \\
                    \includegraphics[
                        height=\headerheight,
                    ]{images/kokkos_wire.pdf}%
                \end{minipage}
            }%
            % remove logo horizontal space
            \hspace{-\headheight}
            % title and page number
            \parbox[b][\headerheight][c]{\headwidth}{%
                \fancycenter{%
                    % add print margin
                    \ifthenelse{\isodd{\value{page}}}{%
                    }{%
                        \hspace{\printmarginwidth}%
                    }%
                    % add custom space for logo
                    \hspace{0.4\headerheight}
                    % title
                    {\Huge\bfseries{}\href{https://kokkos.org/kokkos-core-wiki}{\gettitle}}%
                    % page number
                    {\Large\bfseries\color{lightmain}\ :: page \thepage}%
                }{}{%
                    % version
                    \small\color{lightmain}v\input{VERSION}%
                    % add small margin
                    \hspace{\horizontalskip}
                    % add print margin
                    \ifthenelse{\isodd{\value{page}}}{%
                        \hspace{\printmarginwidth}%
                    }{}%
                }%
            }%
        }%
    }%

    \fancyfoot{%
        % Add the Kokkos wiki link
        \setlength{\fboxsep}{0pt}%
        \colorbox{main}{%
            \parbox[b][\footheight][t]{\headwidth}{%
                \parbox[t][\footerheight][c]{\headwidth}{%
                    % add print margin
                    \ifthenelse{\isodd{\value{page}}}{%
                    }{%
                        \hspace{\printmarginwidth}%
                    }%
                    % add small margin
                    \hspace{\horizontalskip}%
                    % link
                    \footnotesize\bfseries\color{lightmain}\strut\url{https://kokkos.org/kokkos-core-wiki}%
                }%
            }%
        }%
    }%
}

\pagestyle{kokkos}

% sections
\RequirePackage[nobottomtitles*]{titlesec}

\titleformat{\section}[display]
    {\Large\bfseries}
    {}
    {0pt}
    {\sectionstyle}

\titlespacing{\section}
    {0pt}
    {10pt}
    {5pt}

\titleformat{\subsection}[display]
    {\large\bfseries}
    {}
    {0pt}
    {\subsectionstyle}
    [\subsectionstyleextra]

\titlespacing{\subsection}
    {0pt}
    {8pt}
    {4pt}

\titleformat{\subsubsection}[display]
    {\normalsize\bfseries}
    {}
    {0pt}
    {\subsubsectionstyle}

\titlespacing{\subsubsection}
    {0pt}
    {5pt}
    {2.5pt}

\titleformat{\paragraph}[display]
    {\small\bfseries}
    {}
    {0pt}
    {\paragraphstyle}

\titlespacing{\paragraph}
    {0pt}
    {5pt}
    {2.5pt}

\newcommand{\sectionstyle}[1]{%
    \colorbox{main}{\parbox{\dimexpr\linewidth-2\fboxsep}{\strut#1}}%
}

\newcommand{\subsectionstyle}[1]{%
    \strut#1%
}

\newcommand{\subsectionstyleextra}{%
    \titleline{\color{main}\titlerule}%
}

\newcommand{\subsubsectionstyle}[1]{%
    #1%
}

\newcommand{\paragraphstyle}[1]{%
    {\color{main}#1}%
}

% kerning
\RequirePackage{microtype}

% remove section numbering
\setcounter{secnumdepth}{-\maxdimen}

% remove indentation
\setlength{\parindent}{0pt}

% widows and orphans
\widowpenalty10000
\clubpenalty10000

% reset maketitle
\makeatletter
\renewcommand\maketitle{
    \hypersetup{
        pdftitle=\@title,
        pdfauthor=\@author,
    }
}
\makeatother

% title command
\makeatletter
\def\gettitle{\@title}
\makeatother

% command to fill with dotted lines until the end of the page
\makeatletter
\newcommand{\dotcolumnfill}[1]{%
    % https://tex.stackexchange.com/a/319436
    \par
    \null
    \vskip -\ht\strutbox
    \xleaders \hb@xt@ \hsize {%
        \strut \cleaders \hb@xt@ .44em{\hss.\hss}\hfill
    }\vfill
    #1
    \vskip \ht\strutbox
    \break
}
\makeatother

% command to add notes section with dotted lines
\newcommand\notessection[1]{%
    \section{Notes}

    \vspace{1em}

    \dotcolumnfill{#1}
}

% command to add watermark with CExA and MDLS logos
\newcommand\watermark{%
    \begin{flushright}
        Brought to you by%
        \raisebox{-0.4\height}{%
            \hspace{1em}%
            \href{https://cexa-project.org}{\includegraphics[height=1cm]{cexa}}%
            \hspace{1em}%
            \href{https://mdls.fr}{\includegraphics[height=1cm]{maison_de_la_simulation}}%
        }%
    \end{flushright}
}
