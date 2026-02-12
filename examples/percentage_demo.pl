#!/usr/bin/env perl
use v5.38;
use utf8;
use experimental 'class';

use lib '../lib';
use P5::TUI::Table;

# CRITICAL: Set UTF-8 encoding for output
binmode(STDOUT, ':encoding(UTF-8)');

say "=== Percentage-based Table Demo ===\n";

my $table = P5::TUI::Table->new(
    column_spec => [
        { name => 'ID',     width => 5,    align => -1, color => { fg => 'cyan' } },
        { name => 'Name',   width => '50%', align => 1,  color => { fg => 'white' } },
        { name => 'Status', width => '50%', align => 1,  color => { fg => 'green' } }
    ],
    rows => [
        [1,  'Alice',   'Active'],
        [2,  'Bob',     'Inactive'],
        [3,  'Charlie', 'Pending'],
        [4,  'Diana',   'Active'],
        [5,  'Eve',     'Active'],
    ]
);

say "Using absolute dimensions (60x10):";
my $lines = $table->draw(width => 60, height => 10);
say for $lines->@*;

say "\n" . "=" x 60 . "\n";

say "Using percentage dimensions (80% width x 50% height of terminal):";
say "(Terminal defaults to 80x24 when size can't be detected)";
$lines = $table->draw(width => '80%', height => '50%');
say for $lines->@*;

say "\n" . "=" x 60 . "\n";

say "Using mixed: 50 fixed width x 50% height:";
$lines = $table->draw(width => 50, height => '50%');
say for $lines->@*;
