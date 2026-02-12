#!/usr/bin/env perl
use v5.38;
use utf8;
use experimental 'class';

use lib '../lib';
use P5::TUI::Tree;

# CRITICAL: Set UTF-8 encoding for output
binmode(STDOUT, ':encoding(UTF-8)');

my $tree = P5::TUI::Tree->new(
    root => {
        label => 'Root',
        children => [
            { label => 'Child 1' },
            {
                label => 'Child 2',
                children => [
                    { label => 'Grandchild 1' },
                    { label => 'Grandchild 2' },
                ]
            },
            { label => 'Child 3' },
        ]
    }
);

my $lines = $tree->draw(width => 80, height => 20);
say for $lines->@*;
