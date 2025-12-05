module vcurses
fn ansi_from_string(name string, is_bg bool) !string {
    code := match name.to_lower() {
        'black' { if is_bg { 40 } else { 30 } }
        'red' { if is_bg { 41 } else { 31 } }
        'green' { if is_bg { 42 } else { 32 } }
        'yellow' { if is_bg { 43 } else { 33 } }
        'blue' { if is_bg { 44 } else { 34 } }
        'magenta' { if is_bg { 45 } else { 35 } }
        'cyan' { if is_bg { 46 } else { 36 } }
        'white' { if is_bg { 47 } else { 37 } }
        'bright_black' { if is_bg { 100 } else { 90 } }
        'bright_red' { if is_bg { 101 } else { 91 } }
        'bright_green' { if is_bg { 102 } else { 92 } }
        'bright_yellow' { if is_bg { 103 } else { 93 } }
        'bright_blue' { if is_bg { 104 } else { 94 } }
        'bright_magenta' { if is_bg { 105 } else { 95 } }
        'bright_cyan' { if is_bg { 106 } else { 96 } }
        'bright_white' { if is_bg { 107 } else { 97 } }
        else { return error('unknown color: $name') }
    }
    return "\x1b[${code}m"
}

struct Attributes {
pub:
  bg string
  fg string
  bold bool
  italic bool
  highlight bool
  underline bool
}
fn get_attributes(atributes []string) Attributes {
  // color
  // [0] bg
  // [1] fg
  // [2] bold
  // [3] italic
  // [4] highlight
  // [5] underline
  // only returning ones that exist else returning false or ""
  return Attributes{
    bg: atributes[0] or { "" },
    fg: atributes[1] or { "" },
    bold: atributes.len > 2 && atributes[2] == "bold",
    italic: atributes.len > 3 && atributes[3] == "italic",
    highlight: atributes.len > 4 && atributes[4] == "highlight",
    underline: atributes.len > 5 && atributes[5] == "underline"
  }
}
