from pygments.style import Style
from pygments.token import (
    Token,
    Comment,
    Keyword,
    Name,
    String,
    Generic,
    Number,
    Operator,
)


class Colors:
    main = "4b93ad"
    lightmain = "bcd7e0"
    dimmedmain = "8fbccc"
    darkmain = "18607a"
    gray = "808080"
    lightgray = "e6e6e6"
    darkgray = "595959"
    alert = "b34c4c"
    lightalert = "f0dcdct"
    example = "def2fa"
    lightexample = "def2fa"


class KokkosStyle(Style):
    styles = {
        Token: "",
        Comment: f"italic #{Colors.gray}",
        Comment.Preproc: f"italic #{Colors.main}",
        Comment.PreprocFile: f"italic #{Colors.darkgray}",
        Keyword: f"bold #{Colors.main}",
        Name: "",
        Name.Builtin: f"#{Colors.darkgray}",
        Name.Class: f"bold #{Colors.dimmedmain}",
        Name.Function: f"#{Colors.dimmedmain}",
        String: f"#{Colors.darkmain}",
        Generic: f"#{Colors.darkmain}",
        Number: f"#{Colors.darkmain}",
        Operator: f"#{Colors.darkgray}",
    }
