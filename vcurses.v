module vcurses

import os
import time

pub struct Pos {
pub mut:
	x int
	y int
}
pub struct Size {
pub:
	width int
	height int
}
pub struct Screen {
	screen_size Size
mut:
	cursor_pos Pos
	buffer Buffer
}

struct Cell {
mut:
	char rune
	fg string
	bg string
	dirty bool
}


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

// Reads the current cursor position from the terminal.
// Returns (row, col)

fn get_cursor_pos() (int, int) {
    // default fallback
    mut row, mut col := 1, 1

    // try sending cursor query
    os.fd_write(1, '\x1b[6n')

    mut buf := []u8{cap: 64}

    for _ in 0..100 {  // limit loop to avoid infinite read
        s, n := os.fd_read(0, 1)
        if n == 0 { continue }
        buf << s[0]
        if s[0] == `R` { break }
    }

    res := buf.bytestr()
    if res.contains('[') && res.contains('R') {
        start := res.index('[') or { return row, col }
        end := res.index('R') or { return row, col }
        coords := res[start + 1 .. end]
        parts := coords.split(';')
        if parts.len == 2 {
            row = parts[0].int()
            col = parts[1].int()
        }
    }

    return row, col
}


// Gets terminal size by moving the cursor far away and reading the clamped position


fn get_size() Size {
    obserdly_long_number := 99999
    os.fd_write(1, '\x1b[${obserdly_long_number};${obserdly_long_number}H')

    mut row, mut col := get_cursor_pos()
    if row < 1 { row = 24 }      // fallback height
    if col < 1 { col = 80 }      // fallback width

    return Size{width: col, height: row}
}





pub fn initialise() Screen {
	print("initialising vcurses")
	time.sleep(1000)
	os.system('clear')
	enable_raw_mode()
	size := get_size()
	mut output := Screen{
		cursor_pos: Pos{0,0},
		screen_size: size
		buffer: Buffer.new("main")
	}
	time.sleep(1000)
	time.sleep(1000)
	return output
}
pub fn (mut screen Screen) clear() Screen {
	os.system('clear')
	screen.buffer.clear()
	screen.buffer.display(mut screen)
	return screen
}
pub fn (mut screen Screen) write(text string, attr []string) Screen{
	//attr [0] == bg
	//attr [1] == fg
	screen.buffer.write(text, attr)
	screen.buffer.display(mut screen)
	os.flush()
	return screen
}

fn (mut screen Screen) proper_write(c []Cell) Screen {
  for ce in c {
		fg := ansi_from_string(ce.fg, false) or { "" }
		bg := ansi_from_string(ce.bg, true) or { "" }
		print("${fg}${bg}${ce.char.str()}\x1b[0m")
    screen.cursor_pos.x++

    // handle wrapping
  	if screen.cursor_pos.x >= int(screen.screen_size.width) {
      screen.cursor_pos.x = 0
      screen.cursor_pos.y++
  	}

    // optional: wrap vertically
    if screen.cursor_pos.y >= int(screen.screen_size.height) {
      screen.cursor_pos.y = 0
    }
  }
  os.flush()
  return screen
}

pub fn (mut screen Screen) move_cursor(pos Pos) Screen {
	print("\x1b[${pos.y+1};${pos.x+1}H")
	screen.cursor_pos = pos
	return screen
}

fn readchar() string {
	mut b := u8(0)
	C.read(0, &b, 1) // read one byte from stdin
  return b.ascii_str()
}

fn enable_raw_mode() {
  os.system("stty raw -echo")
  os.flush()
}

fn disable_raw_mode() {
    os.system("stty sane")
}

pub fn (mut screen Screen) rect(pos1 Pos, pos2 Pos, fill bool, attr []string) Screen {
	// attributes
	initial_spot := screen.buffer.cursor_pos
	screen.buffer.move_cursor(pos1)
	screen.buffer.write("╔", attr)
	screen.buffer.write("=".repeat(pos2.x - pos1.x), attr) // the top peices like -
	screen.buffer.write("╗", attr)
	screen.buffer.move_cursor(Pos{pos1.x, pos2.y})
	screen.buffer.write("╚", attr)
	screen.buffer.write("=".repeat(pos2.x - pos1.x), attr)
	screen.buffer.write("╝",attr)

	for i := pos1.y + 1; i < pos2.y; i++ {
		screen.buffer.move_cursor(Pos{pos1.x, i})
		screen.buffer.write("║", attr)
		screen.buffer.write(" ".repeat(pos2.x - pos1.x), attr)
		screen.buffer.write("║",attr)
	}
	screen.buffer.move_cursor(initial_spot)
	return screen
}
pub fn (mut screen Screen) getch() string {
	mut ch := readchar() // or os.input() and take first byte
	return ch
}
pub fn uninit() {
	disable_raw_mode()
	os.system('clear')
}
fn (mut screen Screen) add_cells(text []Cell, pos Pos, attr []string) Screen {
	screen.buffer.add_cells(text, pos, attr)
	screen.buffer.display(mut screen)
	return screen
}
pub fn (mut screen Screen) addstr(text string, pos Pos, attr []string) Screen {
	screen.buffer.addstr(text, pos, attr)
	screen.buffer.display(mut screen)
	return screen
}
fn (mut screen Screen) propper_addstr(text Cell, pos Pos) Screen{
	screen.move_cursor(pos)
	screen.proper_write([text])
	return screen
}
pub fn (mut screen Screen) set_color_pair(fg string, bg string) Screen{
	screen.buffer.set_color_pair(fg, bg)
	screen.buffer.display(mut screen)
	return screen
}





/* Buffers
what is a buffer

a buffer is a screen that saveable and stuff
*/
struct Buffer {
	name string
	screen_size Size
	mut:
		buffer [][]Cell
		cursor_pos Pos
		bg string
		fg string
}

pub fn Buffer.new(name string) Buffer {
	screen_size := get_size()
	mut b := Buffer{
		buffer: [][]Cell{len: int(screen_size.height), init: []Cell{len: int(screen_size.width), init: 	Cell{char: ` `, fg: "", bg: "", dirty: true}}}  // 3 rows × 5 columns
		cursor_pos: Pos{0,0},
		name: name,
		screen_size: screen_size
		fg: ""
		bg: ""
	}
	return b
}
pub fn (mut b Buffer) write(text string, attr []string) Buffer {
	for letter in text.runes() {
    b.buffer[b.cursor_pos.y][b.cursor_pos.x].char = letter
    b.buffer[b.cursor_pos.y][b.cursor_pos.x].dirty = true
    if attr[0] == "" {
			b.buffer[b.cursor_pos.y][b.cursor_pos.x].bg = b.bg
		} else {
			b.buffer[b.cursor_pos.y][b.cursor_pos.x].bg = attr[0]
		}
		if attr[1] == "" {
			b.buffer[b.cursor_pos.y][b.cursor_pos.x].fg = b.fg
    } else {
    	b.buffer[b.cursor_pos.y][b.cursor_pos.x].fg = attr[1]
    }
    b.cursor_pos.x++;
    if b.cursor_pos.x >= b.screen_size.width {
			b.cursor_pos.x = 0
			b.cursor_pos.y += 1
    } if b.cursor_pos.y >= b.screen_size.height {
			b.cursor_pos.y = 0
			b.cursor_pos.x = 0
    }
	}
	return b
}

fn (mut b Buffer) write_cells(text []Cell, attr []string) Buffer {
	for letter in text {
    b.buffer[b.cursor_pos.y][b.cursor_pos.x] = letter
    b.buffer[b.cursor_pos.y][b.cursor_pos.x].dirty = true
    //changing bg and fg
		if attr[0] == "" {
			b.buffer[b.cursor_pos.y][b.cursor_pos.x].bg = b.bg
		} else {
			b.buffer[b.cursor_pos.y][b.cursor_pos.x].bg = attr[0]
		}
		if attr[1] == "" {
			b.buffer[b.cursor_pos.y][b.cursor_pos.x].fg = b.fg
    } else {
    	b.buffer[b.cursor_pos.y][b.cursor_pos.x].fg = attr[1]
    }
    b.cursor_pos.x++;
    if b.cursor_pos.x >= b.screen_size.width {
			b.cursor_pos.x = 0
			b.cursor_pos.y += 1
    } if b.cursor_pos.y >= b.screen_size.height {
			b.cursor_pos.y = 0
			b.cursor_pos.x = 0
    }
	}
	return b
}

pub fn (mut b Buffer) clear() Buffer {
	b.cursor_pos = Pos{0,0}
	size := b.screen_size
	for row in 0..size.height {
		for col in 0..size.width {
			if b.buffer[row][col].char != ` ` {
				b.buffer[row][col].char = ` `
				b.buffer[row][col].dirty = true
			}
		}
	}
	return b
}
pub fn (mut b Buffer) move_cursor(pos Pos) Buffer {
	b.cursor_pos = pos
	return b
}

pub fn (mut b Buffer) addstr(text string, pos Pos, attr []string) Buffer {
	b = b.move_cursor(pos)
	b = b.write(text, attr)
	return b
}
fn (mut b Buffer) add_cells(text []Cell, pos Pos, attr []string) Buffer {
	b = b.move_cursor(pos)
	b = b.write_cells(text, attr)
	return b
}

fn (mut b Buffer) display(mut screen Screen) Buffer {
	for i := 0; i < b.screen_size.height; i++ {
		for j := 0; j < b.screen_size.width; j++ {
			if b.buffer[i][j].dirty == true {
				what_to_give := b.buffer[i][j]
				screen.propper_addstr(what_to_give, Pos{j,i})
				b.buffer[i][j].dirty = false
			}
		}
	}
	return b
}
fn (mut screen Screen) change_buffer(b Buffer) Screen {
	for i := 0; i < b.screen_size.height; i++ {
		for j := 0; j < b.screen_size.width; j++ {
			if b.buffer[i][j].char != screen.buffer.buffer[i][j].char {
				what_to_give := b.buffer[i][j]
				screen.propper_addstr(what_to_give, Pos{j,i})
			}
		}
	}
	return screen
}

pub fn (mut screen Screen) show(buffer Buffer) Screen {
	screen.change_buffer(buffer)
	screen.buffer.display(mut screen)
	return screen
}

pub fn (mut buffer Buffer) rect(pos1 Pos, pos2 Pos, attr []string) Buffer {
	initial_spot := buffer.cursor_pos
	mut npos1 := pos1
	mut npos2 := pos2
	// error checking for incorrect buffer sizes
	if npos1.x > npos2.x {
		npos1, npos2 = npos2, npos1
	}
	if npos1.y > npos2.y {
		npos1, npos2 = npos2, npos1
	}
	if npos1.x > buffer.screen_size.width {
		npos1.x = buffer.screen_size.width
	}
	if npos2.x > buffer.screen_size.width {
		npos2.x = buffer.screen_size.width
	}
	if npos1.y > buffer.screen_size.height {
		npos1.y = buffer.screen_size.height
	}
	if npos2.y > buffer.screen_size.height {
		npos2.y = buffer.screen_size.height
	}
	if npos1.x < 0 {
		npos1.x = 0
	}
	if npos1.y < 0 {
		npos1.y = 0
	}
	if npos2.x < 0 {
		npos2.x = 0
	}
	if npos2.y < 0 {
		npos2.y = 0
	}
	// actual stuff
	buffer.move_cursor(npos1)
	buffer.write("╔",attr)
	buffer.write("=".repeat(npos2.x - npos1.x - 2), attr) // the top peices like -
	buffer.write("╗",attr)
	buffer.move_cursor(Pos{npos1.x, npos2.y - 1})
	buffer.write("╚",attr)
	buffer.write("=".repeat(npos2.x - npos1.x - 2),attr)
	buffer.write("╝",attr)

	for i := npos1.y + 1; i < npos2.y - 1; i++ {
		buffer.move_cursor(Pos{npos1.x, i})
		buffer.write("║",attr)
		buffer.write(" ".repeat(npos2.x - pos1.x - 2),attr)
		buffer.write("║",attr)
	}
	buffer.move_cursor(initial_spot)
	return buffer
}

pub fn (mut b Buffer) set_color_pair(fg string, bg string) Buffer{
	b.bg = bg
	b.fg = fg
	for mut row in b.buffer {
		for mut c in row {
			if c.bg == "" {
				c.bg = b.bg
				c.dirty = true
			}
			if c.fg == "" {
				c.fg = b.fg
				c.dirty = true
				}
			}
		}
	return b
}
