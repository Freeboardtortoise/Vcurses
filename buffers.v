module vcurses
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
		buffer: [][]Cell{len: int(screen_size.height), init: []Cell{len: int(screen_size.width), init: 	Cell{char: ` `,  dirty: true, attr: []string{len: 10, init: ""}}}}  // 3 rows × 5 columns
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
    b.buffer[b.cursor_pos.y][b.cursor_pos.x].attr = attr

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
			b.buffer[b.cursor_pos.y][b.cursor_pos.x].attr[0] = b.bg
		} else {
			b.buffer[b.cursor_pos.y][b.cursor_pos.x].attr[1] = attr[0]
		}
		if attr[1] == "" {
			b.buffer[b.cursor_pos.y][b.cursor_pos.x].attr[1] = b.fg
    } else {
    	b.buffer[b.cursor_pos.y][b.cursor_pos.x].attr[1] = attr[1]
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
	b.refresh(mut screen)
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
			if b.buffer[i][j].char != screen.buffer.buffer[i][j].char ||
					b.buffer[i][j].attr != screen.buffer.buffer[i][j].attr
				{
				what_to_give := b.buffer[i][j]
				screen.buffer.buffer[i][j] = what_to_give
				screen.buffer.buffer[i][j].dirty = true
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
			if c.attr[0] == "" {
				c.attr[0] = b.bg
				c.dirty = true
			}
			if c.attr[1] == "" {
				c.attr[1] = b.fg
				c.dirty = true
				}
			}
		}
	return b
}
pub fn (buffer Buffer) size() Size {
	return buffer.screen_size
}
fn (mut buffer Buffer) refresh(mut screen Screen) Buffer {
	buffer.move_cursor(Pos{0,0})
	for row in buffer.buffer {
		screen.proper_write(row)
	}
	return buffer
}
