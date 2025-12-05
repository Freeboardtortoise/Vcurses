# Vcurses
## What is Vcurses
Vcurses is a V exclusive TUI library for the programming language by the name of V
## Why is Vcurses a thing?
At the time of creating the package, Vcurses is the only TUI library that is fully native to the V econsystem
## why do you want to use vcurses
Because it saves you from wrestling with ancient C curses like a terminal-dwelling cryptid.
## Installing Vcurses
To install vcurses on your machine... run the following command in your terminal
```
 v install Freeboardtortoise.vcurses
```

## Usage
#### Import the module
```v
import freeboardtortoise.vcurses
```
#### Creating and initialising the terminal for vcurses
```v
mut screen := vcurses.initialise()
```
_nb: when adding vcurses.initialise... before the program ends you must uninit the module_
#### uninitialising the terminal
```v
vcurses.uninit()
```
#### Clearing the screen
```v
screen.clear()
```
#### Addstr
addstr is the function to add text to the screen or a buffer in a specific position
```v

screen.addstr("text to add", vcurses.Pos{x:0 , y:0 }, ["bg color", "fg color"]) // insert whatever x and y positions that are needed.
```
#### Write
write is the function used to add text to a screen or a buffer.
```v
screen.write("what to write")
```
#### Move_cursor
move_cursor is the function to move the cursor to a position on the screen or in the buffer
```v
screen.move_cursor(vcurses.Pos{x:0 , y:0 }) // insert whatever x and y positions that are needed.
```
#### Rect
rect is the function to draw rectangles onto the screen in a certain position
```v
screen.rect(vcurses.Pos{x:0,y:0}, vcurses.Pos{x:0,y:0}, ["bg color", "fg color"]) // change pos1 and pos2 to fit your needs
```

### Input
#### Getch
getch is the function to get one character of input from a user.
_nb: this doesnt extend to the arrow keys or function keys, soon will be added_
```v
data := screen.getch()
```

### Buffers
#### Creating a buffer
```v
buffer := Buffer.new("name of the buffer")
```
#### Writing to a buffer
```v
buffer.write("string to write to the buffer", ["bg color", "fg color"])
```
#### Clearing a buffer
```v
buffer.clear()
```
#### Move the buffer cursor
```v
buffer.move_cursor(vcurses.Pos{0,0}) // adjust to your liking
```
#### Adding a string to a specific place in the buffer
```v
buffer.addstr("string to add", vcurses.Pos{0,0}, ["bg color", "fg color"]) // adjust as needed
```
#### Add a rect to a buffer
```v
buffer.rect(vcurses.Pos{0,0}, vcurses.Pos{0,0}, ["bg color", "fg color"]) // adjust values to your liking
```
#### NOTE
an attribute arg \[3\] if the value is "" it will default to the current default color pair
### colors
| color names     |
| --------------- |
| black           |
| red             |
| green           |
| yellow          |
| blue            |
| magenta         |
| cyan            |
| white           |
| bright_black    |
| bright_red      |
| bright_green    |
| bright_yellow   |
| bright_blue     |
| bright_magenta  |
| bright_cyan     |
| bright_white    |

#### Set color pair
```v
screen.set_color_pair("foreground color","background color")
```
or for a buffer
```v
buffer.set_color_pair("foreground color", "background color")
```
## Example program
```v

module main
import freeboardtortoise.vcurses

fn main() {
    // Initialize the screen
    mut screen := vcurses.initialise()
    defer { vcurses.uninit() } // ensure cleanup

    // Clear the screen
    screen.clear()

    // Set a color pair and write text directly
    screen.set_color_pair("bright_white", "blue")
    screen.addstr("Welcome to Vcurses!", vcurses.Pos{0, 0}, ["bright_white","blue"])
    screen.move_cursor(vcurses.Pos{0,1})
    screen.write("Press any key to continue...", ["",""])

    // Create a buffer
    mut buf := vcurses.Buffer.new("demo")
    buf.set_color_pair("yellow", "magenta")
    buf.write("This text is in a buffer!", ["yellow","magenta"])
    buf.addstr(" At position (0,2)", vcurses.Pos{0,2}, ["cyan","black"])
    buf.rect(vcurses.Pos{0,4}, vcurses.Pos{20,6}, ["red","bright_black"]) // draw rectangle in buffer

    // Render buffer to the screen
    screen.show(buf)

    // Wait for user input
    _ := screen.getch()

    // Move cursor and write a final message
    screen.move_cursor(vcurses.Pos{0, 10})
    screen.write("Exiting... thanks for trying Vcurses!", ["",""])
}

```
