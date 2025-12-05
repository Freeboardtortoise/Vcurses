# Vcurses
## What is Vcurses
Vcurses is a V exclusive TUI library for the programming language by the name of V
## Why is Vcurses a thing?
At the time of creating the package, Vcurses is the only TUI library that is fully native to the V ecosystem
## Why do you want to use Vcurses
Because it saves you from wrestling with ancient C curses like a terminal-dwelling cryptid.
## Installing Vcurses
To install vcurses on your machine... run the following command in your terminal
```
 v install Freeboardtortoise.vcurses
```

## Usage
* NB: dont use print() or println() functions EVER *
#### Import the module
```v
import freeboardtortoise.vcurses
```
#### Creating and initialising the terminal for vcurses
```v
mut screen := vcurses.initialise()
```
returns a private struct used by the rest of the api/module
_nb: when adding vcurses.initialise... before the program ends you must uninit the module_
#### uninitialising the terminal
```v
vcurses.uninit()
```
returns nothing
#### Clearing the screen
```v
screen.clear()
```
returns nothing
#### Addstr
addstr is the function to add text to the screen or a buffer in a specific position
```v

screen.addstr("text to add", vcurses.Pos{x:0 , y:0 }, ["bg color", "fg color"]) // insert whatever x and y positions that are needed.
```
returns nothing
#### Write
write is the function used to add text to a screen or a buffer.
```v
screen.write("what to write")
```
returns nothing
#### Move_cursor
move_cursor is the function to move the cursor to a position on the screen or in the buffer
```v
screen.move_cursor(vcurses.Pos{x:0 , y:0 }) // insert whatever x and y positions that are needed.
```
returns nothing
#### Rect
rect is the function to draw rectangles onto the screen in a certain position
_note: the default for this librarys rect function is to not fill the rect... an optional arg will later be added to fill the rect_
```v
screen.rect(vcurses.Pos{x:0,y:0}, vcurses.Pos{x:0,y:0}, ["bg color", "fg color"]) // change pos1 and pos2 to fit your needs
```
returns nothing
#### getting the screen_size
```v
screen.size()
```
returns a Size struct (see the Size struct under the Structs section)

### Input
#### Getch
getch is the function to get one character of input from a user.
_nb: this doesnt extend to the arrow keys or function keys, soon will be added_
```v
data := screen.getch()
```
returns a string containing the charactor that was inputted


### Buffers
#### Creating a buffer
```v
buffer := Buffer.new("name of the buffer")
```
returns a Buffer struct (see the Buffer struct under the Structs section)
#### Writing to a buffer
```v
buffer.write("string to write to the buffer", ["bg color", "fg color"])
```
returns nothing
#### Clearing a buffer
```v
buffer.clear()
```
returns nothing
#### Move the buffer cursor
```v
buffer.move_cursor(vcurses.Pos{0,0}) // adjust to your liking
```
returns nothing
#### Adding a string to a specific place in the buffer
```v
buffer.addstr("string to add", vcurses.Pos{0,0}, ["bg color", "fg color"]) // adjust as needed
```
returns nothing
#### Add a rect to a buffer
```v
buffer.rect(vcurses.Pos{0,0}, vcurses.Pos{0,0}, ["bg color", "fg color"]) // adjust values to your liking
```
returns nothing
#### buffer size
```v
buffer.size()
```
returns a Size struct (see the Size struct under the Structs section)
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
returns nothing
or for a buffer
```v
buffer.set_color_pair("foreground color", "background color")
```
returns nothing

## Structs
### Pos
the pos struct has ```x``` and ```y``` values that are both ```int``` values
in order to make a Size you do the following ```vcurses.Pos{x:<x possition>, y:<y position>}``` adjust as needed
you can also make one like so ```vcurses.Pos{<x>, <y>} // replace <x> and <y> with their respective values```

### Size
the Size struct has two ```int``` values ```width``` and ```height```
to create a Size struct do the following ```vcurses.Size{<width>, <height>}``` adjust as needed
to get values w and h from a size you do ```size.width``` and ```size.height```



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
