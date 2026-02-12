#!/usr/bin/env perl
use v5.38;
use utf8;
use experimental 'class';

use lib '../lib';
use P5::TUI::Tree;

# CRITICAL: Set UTF-8 encoding for output
binmode(STDOUT, ':encoding(UTF-8)');

say "=== P5::TUI::Tree Demo ===\n";

# Example 1: File system structure
say "Example 1: File System Structure";
say "-" x 80;

my $filesystem = P5::TUI::Tree->new(
    root => {
        label => '/home/user/project',
        color => { fg => 'cyan' },
        children => [
            {
                label => 'lib/',
                color => { fg => 'blue' },
                children => [
                    { label => 'Main.pm', color => { fg => 'white' } },
                    { label => 'Utils.pm', color => { fg => 'white' } },
                ]
            },
            {
                label => 't/',
                color => { fg => 'blue' },
                children => [
                    { label => '01-basic.t', color => { fg => 'green' } },
                    { label => '02-advanced.t', color => { fg => 'green' } },
                ]
            },
            { label => 'README.md', color => { fg => 'yellow' } },
            { label => 'Makefile.PL', color => { fg => 'white' } },
        ]
    }
);

my $lines = $filesystem->draw(width => 80, height => 20);
say for $lines->@*;

say "\n";

# Example 2: Organization hierarchy
say "Example 2: Organization Hierarchy";
say "-" x 80;

my $org = P5::TUI::Tree->new(
    root => {
        label => 'CEO - Alice Johnson',
        color => { fg => 'bright_cyan' },
        children => [
            {
                label => 'CTO - Bob Smith',
                color => { fg => 'bright_blue' },
                children => [
                    {
                        label => 'Engineering Manager - Carol White',
                        color => { fg => 'blue' },
                        children => [
                            { label => 'Senior Dev - David Brown', color => { fg => 'white' } },
                            { label => 'Junior Dev - Eve Davis', color => { fg => 'white' } },
                        ]
                    },
                    {
                        label => 'QA Manager - Frank Wilson',
                        color => { fg => 'blue' },
                        children => [
                            { label => 'QA Engineer - Grace Lee', color => { fg => 'white' } },
                        ]
                    },
                ]
            },
            {
                label => 'CFO - Henry Martinez',
                color => { fg => 'bright_green' },
                children => [
                    { label => 'Accountant - Ivy Chen', color => { fg => 'green' } },
                    { label => 'Accountant - Jack Taylor', color => { fg => 'green' } },
                ]
            },
        ]
    }
);

$lines = $org->draw(width => 80, height => 30);
say for $lines->@*;

say "\n";

# Example 3: Deeply nested structure
say "Example 3: Deeply Nested Structure";
say "-" x 80;

my $deep = P5::TUI::Tree->new(
    root => {
        label => 'Level 0',
        children => [
            {
                label => 'Level 1-A',
                children => [
                    {
                        label => 'Level 2-A',
                        children => [
                            {
                                label => 'Level 3-A',
                                children => [
                                    { label => 'Level 4-A (Deep!)' }
                                ]
                            }
                        ]
                    },
                    { label => 'Level 2-B' }
                ]
            },
            { label => 'Level 1-B' },
        ]
    }
);

$lines = $deep->draw(width => 80, height => 20);
say for $lines->@*;

say "\n";

# Example 4: Width truncation
say "Example 4: Width Truncation (narrow width)";
say "-" x 80;

my $truncated = P5::TUI::Tree->new(
    root => {
        label => 'This is a very long root node label that will be truncated',
        children => [
            { label => 'Short' },
            { label => 'Another extremely long child node label that definitely exceeds width' },
        ]
    }
);

$lines = $truncated->draw(width => 40, height => 10);
say for $lines->@*;

say "\n";

# Example 5: Height overflow
say "Example 5: Height Overflow";
say "-" x 80;

my $overflow = P5::TUI::Tree->new(
    root => {
        label => 'Root',
        children => [
            { label => 'Child 1' },
            { label => 'Child 2' },
            { label => 'Child 3' },
            { label => 'Child 4' },
            { label => 'Child 5' },
            { label => 'Child 6' },
            { label => 'Child 7' },
            { label => 'Child 8' },
            { label => 'Child 9' },
            { label => 'Child 10' },
        ]
    }
);

say "Limited to 6 lines (should show overflow indicator):";
$lines = $overflow->draw(width => 80, height => 6);
say for $lines->@*;

say "\n=== Demo Complete ===";
