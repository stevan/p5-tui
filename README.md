# P5::TUI - Modern Perl 5 TUI Framework

A modern, composable Text User Interface (TUI) framework for Perl 5.42+ using the latest language features: experimental class system, subroutine signatures, and Unicode box drawing characters.

## Design Philosophy

Unlike traditional TUI frameworks with large widget hierarchies, P5::TUI embraces a **functional, composable approach**:

- **Non-interactive elements** that render inline, not fullscreen
- **draw()** methods return arrays of strings - you control where/how to print
- **Constrained rendering** - elements work within width/height limits
- **Unicode first** - Proper box drawing characters (┌─┬─┐), not ASCII art
- **Layout combinators** - Stack and concatenate rendered elements (coming soon)

## Current Status

✓ **Table** - Data tables with configurable columns, colors, and alignment
⏳ **Tree** - Coming soon
⏳ **Layout** - Horizontal/vertical stacking utilities - Coming soon

## Requirements

- Perl 5.42 or later (tested on 5.38 for compatibility)
- UTF-8 terminal support
- `use utf8;` in source files
- `binmode(STDOUT, ':encoding(UTF-8)')` for output

## Quick Start

```perl
use v5.42;
use utf8;
use experimental 'class';
use P5::TUI::Table;

# Configure UTF-8 output (CRITICAL!)
binmode(STDOUT, ':encoding(UTF-8)');

my $table = P5::TUI::Table->new(
    column_spec => [
        {
            name  => 'ID',
            width => 6,           # Fixed width in chars
            align => -1,          # Right-aligned (-1), left is 1
            color => { fg => 'cyan', bg => undef }
        },
        {
            name  => 'Name',
            width => '60%',       # Percentage of available space
            align => 1,           # Left-aligned
            color => { fg => 'white', bg => undef }
        },
        {
            name  => 'Status',
            width => '40%',
            align => 1,
            color => { fg => 'green', bg => undef }
        }
    ],
    rows => [
        [1, 'Alice Johnson', 'Active'],
        [2, 'Bob Smith', 'Inactive'],
        [42, 'Charlie Brown', 'Pending'],
    ]
);

# Render to array of strings
my $lines = $table->draw(width => 80, height => 12);

# Output
say for $lines->@*;
```

**Output:**

```
┌──────┬─────────────────────────────────────┬────────────────────────┐
│    ID│Name                                 │Status                  │
├──────┼─────────────────────────────────────┼────────────────────────┤
│     1│Alice Johnson                        │Active                  │
│     2│Bob Smith                            │Inactive                │
│    42│Charlie Brown                        │Pending                 │
└──────┴─────────────────────────────────────┴────────────────────────┘
```

## Module Reference

### P5::TUI::Table

Renders data tables with Unicode box drawing.

**Constructor:**

```perl
P5::TUI::Table->new(
    column_spec => \@columns,
    rows        => \@rows,
)
```

**Column Specification:**

Each column is a hashref with:

- `name` - Header text (empty string to hide all headers)
- `width` - Fixed number (`10`) or percentage (`"40%"`)
  - Percentages calculate from remaining space after fixed columns
- `align` - Alignment: `1` (left) or `-1` (right)
- `color` - Hashref: `{ fg => 'color', bg => 'color' }`

**Row Data:**

Arrayref of arrayrefs: `[ [val1, val2], [val1, val2], ... ]`

**Methods:**

- `draw(width => $w, height => $h)` - Returns arrayref of strings

**Behavior:**

- Headers shown only if at least one column has a name
- Content truncated with ellipsis (`…`) if too wide
- Overflow indicator (`...`) if too many rows for height
- Colors applied per column via ANSI codes

### P5::TUI::Color

ANSI color utilities supporting 16 basic colors.

**Functions:**

```perl
use P5::TUI::Color qw(colorize);

colorize($text, $fg, $bg)           # Apply colors
colorize("Error", "red")            # Foreground only
colorize("Warning", "yellow", "black")  # Both
colorize("Info", "bright_cyan")     # Bright variant
```

**Supported Colors:**

Standard: `black`, `red`, `green`, `yellow`, `blue`, `magenta`, `cyan`, `white`

Bright: `bright_black`, `bright_red`, `bright_green`, `bright_yellow`, `bright_blue`, `bright_magenta`, `bright_cyan`, `bright_white`

### P5::TUI::BoxChars

Unicode box drawing character constants.

```perl
use P5::TUI::BoxChars qw(:all);

# Lines
BOX_H    # ─ horizontal
BOX_V    # │ vertical

# Corners
BOX_TL   # ┌ top-left
BOX_TR   # ┐ top-right
BOX_BL   # └ bottom-left
BOX_BR   # ┘ bottom-right

# T-junctions
BOX_T_DOWN   # ┬ pointing down
BOX_T_UP     # ┴ pointing up
BOX_T_RIGHT  # ├ pointing right
BOX_T_LEFT   # ┤ pointing left

# Cross
BOX_CROSS    # ┼ intersection
```

## Examples

See `examples/table_demo.pl` for comprehensive demonstrations:

```bash
perl examples/table_demo.pl
```

Demonstrates:
1. Mixed fixed/percentage widths with colors
2. Table without headers (empty column names)
3. Overflow handling with many rows
4. Content truncation in narrow columns

## Project Structure

```
p5-tui/
├── lib/
│   └── P5/
│       └── TUI/
│           ├── Table.pm      # Data table element
│           ├── BoxChars.pm   # Unicode box drawing chars
│           └── Color.pm      # ANSI color utilities
├── examples/
│   └── table_demo.pl         # Comprehensive demo
└── README.md
```

## Modern Perl Features Used

This framework showcases Perl 5.42 features:

- ✓ **Experimental class system** (`use experimental 'class'`)
- ✓ **Field variables** with `:param` attribute
- ✓ **Method syntax** (`method name(%args) { ... }`)
- ✓ **Subroutine signatures** (`sub foo($bar, $baz) { ... }`)
- ✓ **Postfix dereferencing** (`$arrayref->@*`)
- ✓ **Unicode 16.0** support with `use utf8;`
- ⏳ **try/catch blocks** (planned)
- ⏳ **New builtins** (planned)

## Future Plans

### Additional Elements

- **Tree** - Hierarchical tree diagrams
- **ProgressBar** - Progress indicators
- **Box** - Simple bordered boxes with content
- **Sparkline** - Inline mini-charts

### Layout System

```perl
use P5::TUI::Layout qw(hstack vstack border pad align);

my $layout = vstack(
    border($table->draw(width => 60, height => 10)),
    hstack(
        $tree->draw(width => 30, height => 15),
        pad($box, left => 2),
        spacing => 2
    ),
    spacing => 1
);
```

Functions planned:
- `hstack(@elements, :$spacing)` - Horizontal concatenation
- `vstack(@elements, :$spacing)` - Vertical stacking
- `pad($element, :$top, :$bottom, :$left, :$right)` - Add padding
- `align($element, :$width, :$halign)` - Horizontal alignment
- `border($element, :$style)` - Add borders around any element

### Color Extensions

- 256-color palette support
- RGB/true color support (#RRGGBB)
- Color themes

## UTF-8 Requirements (Important!)

Perl 5.42 has strict UTF-8 requirements:

1. **Source files** with Unicode characters must use `use utf8;`
2. **File handles** printing Unicode must be configured:
   ```perl
   binmode(STDOUT, ':encoding(UTF-8)');
   binmode(STDERR, ':encoding(UTF-8)');
   ```
3. **Wide character warnings** will occur if you forget step 2!

See Perl 5.42's new `source::encoding` pragma for automatic handling.

## Contributing

This is an experimental framework exploring modern Perl features and composable design patterns. Contributions and ideas welcome!

## License

To be determined.

## Author

Created as an exploration of modern Perl 5.42 features and functional TUI design.
