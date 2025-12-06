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
	dirty bool
	attr []string
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
		mut attribs_to_pass := ce.attr.clone()
		attributes := attributes_to_ansi(attribs_to_pass)
		print("${attributes}${ce.char.str()}\x1b[0m")
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

pub fn (mut screen Screen) rect(pos1 Pos, pos2 Pos, attr []string) Screen {
	mut buffer := screen.buffer
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
	buffer.write("╔", attr)
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

pub fn (screen Screen) size() Size {
	return screen.screen_size
}
