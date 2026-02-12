#!/usr/bin/env perl
use v5.38;  # Designed for 5.42, testing on 5.38
use utf8;
use experimental 'class';

use lib '../lib';
use P5::TUI::Table;

# CRITICAL: Set UTF-8 encoding for output
binmode(STDOUT, ':encoding(UTF-8)');

# Simple example
my $table = P5::TUI::Table->new(
    column_spec => [
        { name => 'ID',     width => 5,    align => -1, color => { fg => 'cyan' } },
        { name => 'Name',   width => '50%', align => 1,  color => { fg => 'white' } },
        { name => 'Status', width => '50%', align => 1,  color => { fg => 'green' } }
    ],
    rows => [
        [1,  'Alice',   'Active'],
        [2,  'Bob',     'Inactive'],
        [42, 'Charlie', 'Pending'],
    ]
);

my $lines = $table->draw(width => 60, height => 10);
say for $lines->@*;
