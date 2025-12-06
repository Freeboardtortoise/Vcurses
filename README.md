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

## documentation notation
### functions
``` <optional (struct pass type)><function name>(<arguments>) >> <return type>```
### \<arguments\>
```<argument type> <argument name>```
### return type
either none (no return value) or a Struct or a V standard type
### struct pass type
```<struct name>```


## Usage
* NB: dont use print() or println() functions EVER *
#### Import the module
```v
import freeboardtortoise.vcurses
```
#### Creating and initialising the terminal for vcurses
```v
Notation: vcurses.initialise() >> Screen
```
returns a private struct used by the rest of the api/module
_nb: when adding vcurses.initialise... before the program ends you must uninit the module_
#### uninitialising the terminal
```v
Notation: vcurses.uninit() >> none
```
#### Clearing the screen
```v
Notation: Screen.clear() >> none
```
returns nothing
#### Addstr
addstr is the function to add text to the screen or a buffer in a specific position
```v

Notation: Screen.addstr(string text, Pos pos, []string attributes) >> none
```
#### Write
write is the function used to add text to a screen or a buffer.
```v
Notation: Screen.write(string text) >> none
```
#### Move_cursor
move_cursor is the function to move the cursor to a position on the screen or in the buffer
```v
Notation: Screen.move_cursor(pos where) >> none
```
#### Rect
rect is the function to draw rectangles onto the screen in a certain position
_note: the default for this librarys rect function is to not fill the rect... an optional arg will later be added to fill the rect_
```v
Notation: Screen.rect(Pos TopLeft, Pos BottomRight, []string attributes) >> none
```
#### getting the screen_size
```v
Notation: Screen.size() >> Size
```

### Input
#### Getch
getch is the function to get one character of input from a user.
_nb: this doesnt extend to the arrow keys or function keys, soon will be added_
```v
Notation: Screen.getch() >> string
```
returns a string containing the charactor that was inputted


### Buffers
#### Creating a buffer
```
Notation: Buffer.new(string bufferName) >> Buffer
```
#### Writing to a buffer
```
Notation: Buffer.write(string text, []string attributes) >> none
```
#### Clearing a buffer
```
Notation: Buffer.clear() >> none
```
#### Move the buffer cursor
```
Notation: Buffer.move_cursor(Pos where) >> none
```
#### Adding a string to a specific place in the buffer
```v
Notation: Buffer.addstr(string text, Pos position, []string attributes) >> none
```
#### Add a rect to a buffer
```v
Notation: Buffer.rect(Pos pos, Pos pos, []string attributes) >> none
```
returns nothing
#### buffer size
```v
Notation: Buffer.size() >> Size
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
Notation: Screen.set_color_pair(string foregroundColor,string backgroundColor) >> none
```
or for a buffer
```v
Notation: Buffer.set_color_pair(string foregroundColor, string backgroundColor) >> none
```
## Attributes
attributes are a list of strings containing the color names that you want to add to the text as well as other things you would like to add to the text such as bold, italics and the like
### format
```["background color", "forground color", "any other attributes"]```

all attributes
| attributes   | what they do     |
| ----------   | ---------------- |
| bold         | bold text        |
| italic       | italic text      |
| highlight    | highlight text   |
| underline    | underline text   |
| dim          | make text lighter|
| blink        | make text blink  |
| reverse      | reverse text     |
| hidden       | hide text        |
| strikethrough| draw line through|
any order is allowed
note that attributes are case sensitive
italics is a bit fishy (terminal specific)

## Structs
### Pos
the pos struct has ```x``` and ```y``` values that are both ```int``` values
in order to make a Size you do the following ```vcurses.Pos{x:<x possition>, y:<y position>}``` adjust as needed
you can also make one like so ```vcurses.Pos{<x>, <y>} // replace <x> and <y> with their respective values```

### Size
the Size struct has two `int` values `width` and `height`
Create a Size struct: `vcurses.Size{<width>, <height>}`
Get values width and height from a size struct: ```size.width``` and ```size.height```



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
