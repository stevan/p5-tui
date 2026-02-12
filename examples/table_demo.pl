#!/usr/bin/env perl
use v5.38;  # Testing on 5.38, but targeting 5.42
use utf8;
use experimental 'class';

use lib '../lib';
use P5::TUI::Table;

# Set UTF-8 encoding for output (CRITICAL for box drawing chars)
binmode(STDOUT, ':encoding(UTF-8)');
binmode(STDERR, ':encoding(UTF-8)');

say "=== P5::TUI::Table Demo ===\n";

# Example 1: Basic table with headers, mixed widths, and colors
say "Example 1: User Data Table";
say "-" x 80;

my $table1 = P5::TUI::Table->new(
    column_spec => [
        {
            name  => 'ID',
            width => 6,
            align => -1,  # Right-aligned
            color => { fg => 'cyan', bg => undef }
        },
        {
            name  => 'Name',
            width => '40%',  # Percentage of available space
            align => 1,      # Left-aligned
            color => { fg => 'white', bg => undef }
        },
        {
            name  => 'Email',
            width => '40%',
            align => 1,
            color => { fg => 'yellow', bg => undef }
        },
        {
            name  => 'Status',
            width => '20%',
            align => 1,
            color => { fg => 'green', bg => undef }
        }
    ],
    rows => [
        [1, 'Alice Johnson', 'alice@example.com', 'Active'],
        [2, 'Bob Smith', 'bob@example.com', 'Inactive'],
        [42, 'Charlie Brown', 'charlie@example.com', 'Pending'],
        [100, 'Diana Prince', 'diana@example.com', 'Active'],
        [999, 'Eve Anderson', 'eve@example.com', 'Active'],
    ]
);

my $lines1 = $table1->draw(width => 80, height => 12);
say for $lines1->@*;

say "\n";

# Example 2: Table without headers (empty column names)
say "Example 2: Table Without Headers";
say "-" x 80;

my $table2 = P5::TUI::Table->new(
    column_spec => [
        {
            name  => '',  # Empty name
            width => 15,
            align => 1,
            color => { fg => 'magenta', bg => undef }
        },
        {
            name  => '',  # Empty name
            width => '50%',
            align => 1,
            color => { fg => 'white', bg => undef }
        },
        {
            name  => '',  # Empty name
            width => '50%',
            align => -1,
            color => { fg => 'cyan', bg => undef }
        }
    ],
    rows => [
        ['Setting', 'theme', 'dark'],
        ['Option', 'language', 'Perl'],
        ['Config', 'version', '5.42'],
    ]
);

my $lines2 = $table2->draw(width => 60, height => 10);
say for $lines2->@*;

say "\n";

# Example 3: Table with overflow (more rows than fit in height)
say "Example 3: Table With Overflow Indicator";
say "-" x 80;

my @large_dataset = map {
    [
        $_,
        "User $_",
        "user${_}\@example.com",
        ($_ % 3 == 0) ? 'Active' : 'Inactive'
    ]
} (1..50);

my $table3 = P5::TUI::Table->new(
    column_spec => [
        {
            name  => 'ID',
            width => 6,
            align => -1,
            color => { fg => 'bright_cyan', bg => undef }
        },
        {
            name  => 'Username',
            width => '30%',
            align => 1,
            color => { fg => 'bright_white', bg => undef }
        },
        {
            name  => 'Email',
            width => '50%',
            align => 1,
            color => { fg => 'bright_yellow', bg => undef }
        },
        {
            name  => 'Status',
            width => '20%',
            align => 1,
            color => { fg => 'bright_green', bg => undef }
        }
    ],
    rows => \@large_dataset
);

my $lines3 = $table3->draw(width => 80, height => 12);
say for $lines3->@*;

say "\n";

# Example 4: Narrow table with truncation
say "Example 4: Narrow Table (content truncation with ellipsis)";
say "-" x 80;

my $table4 = P5::TUI::Table->new(
    column_spec => [
        {
            name  => 'ID',
            width => 4,
            align => -1,
            color => { fg => 'red', bg => undef }
        },
        {
            name  => 'Long Column Name That Will Be Truncated',
            width => 10,
            align => 1,
            color => { fg => 'blue', bg => undef }
        },
        {
            name  => 'Val',
            width => 6,
            align => -1,
            color => { fg => 'green', bg => undef }
        }
    ],
    rows => [
        [1, 'This is a very long text that will definitely be truncated', 12345],
        [2, 'Short', 42],
        [999, 'Another extremely long value here', 9],
    ]
);

my $lines4 = $table4->draw(width => 40, height => 10);
say for $lines4->@*;

say "\n";
say "=== Demo Complete ===";
