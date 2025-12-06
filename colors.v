module vcurses
fn ansi_from_string(name string, is_bg bool) string {
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
        else { return "" }
    }
    return "\x1b[${code}m"
}
fn attributes_to_ansi(attributes []string) string {
	mut ansi := ""
	fg := ansi_from_string(attributes[0], false)
	bg := ansi_from_string(attributes[1], true)
	ansi += fg + bg
	for attribute in attributes {
		if attribute == "bold" { ansi += "\x1b[1m" }
		if attribute == "italic" { ansi += "\x1b[3m" }
		if attribute == "highlight" { ansi += "\x1b[7m" }
		if attribute == "underline" { ansi += "\x1b[4m" }
		if attribute == "dim" { ansi += "\x1b[2m" }
		if attribute == "blink" { ansi += "\x1b[5m" }
		if attribute == "reverse" { ansi += "\x1b[7m" }
		if attribute == "hidden" { ansi += "\x1b[8m" }
		if attribute == "strikethrough" { ansi += "\x1b[9m" }
	}
	return ansi
}
