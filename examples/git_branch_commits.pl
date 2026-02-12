#!/usr/bin/env perl
use v5.38;
use utf8;
use experimental 'class';

use lib '../lib';
use P5::TUI::Table;

# CRITICAL: Set UTF-8 encoding for output
binmode(STDOUT, ':encoding(UTF-8)');

say "=== Git Branches with Recent Commits ===\n";

# Branch-first layout: branches as rows, commits as columns
my $branch_table = P5::TUI::Table->new(
    column_spec => [
        {
            name  => 'Branch',
            width => 20,
            align => 1,
            color => { fg => 'bright_cyan' }
        },
        {
            name  => 'Latest Commit',
            width => '30%',
            align => 1,
            color => { fg => 'yellow' }
        },
        {
            name  => '2nd Commit',
            width => '30%',
            align => 1,
            color => { fg => 'white' }
        },
        {
            name  => '3rd Commit',
            width => '30%',
            align => 1,
            color => { fg => 'white' }
        },
        {
            name  => 'Status',
            width => 12,
            align => 1,
            color => { fg => 'green' }
        },
    ],
    rows => [
        ['main (HEAD)', 'a3f7b21: Merge PR', 'd8c4091: Add auth', '2b5e8f3: Fix bug', '← origin'],
        ['feature/dark-mode', '9e2f6a4: Dark theme', '1c7d9b2: Palette', '', '2 ahead'],
        ['feature/api-v2', '4f8a1d3: API v2', 'b6c9e72: Update docs', '', 'synced'],
        ['bugfix/memory', '7d3c4b8: Fix leak', '', '', 'not pushed'],
        ['release/v1.2.0', 'e5a9f21: Bump v1.2', '', '', 'tagged'],
    ]
);

my $lines = $branch_table->draw(width => 130, height => 15);
say for $lines->@*;

say "\n" . "=" x 130 . "\n";

# Detailed view with more commit info
say "=== Branch Commit Details ===\n";

my $detailed = P5::TUI::Table->new(
    column_spec => [
        {
            name  => 'Branch',
            width => 18,
            align => 1,
            color => { fg => 'bright_green' }
        },
        {
            name  => 'Commit 1 (Latest)',
            width => '25%',
            align => 1,
            color => { fg => 'bright_yellow' }
        },
        {
            name  => 'Commit 2',
            width => '25%',
            align => 1,
            color => { fg => 'yellow' }
        },
        {
            name  => 'Commit 3',
            width => '25%',
            align => 1,
            color => { fg => 'white' }
        },
        {
            name  => 'Commit 4',
            width => '25%',
            align => 1,
            color => { fg => 'white' }
        },
    ],
    rows => [
        [
            'main',
            'a3f7b21 (2h ago)',
            'd8c4091 (5h ago)',
            '2b5e8f3 (1d ago)',
            '4f8a1d3 (2d ago)'
        ],
        [
            'feature/dark-mode',
            '9e2f6a4 (4h ago)',
            '1c7d9b2 (6h ago)',
            '',
            ''
        ],
        [
            'feature/api-v2',
            '4f8a1d3 (2d ago)',
            'b6c9e72 (3d ago)',
            '',
            ''
        ],
        [
            'bugfix/memory',
            '7d3c4b8 (1h ago)',
            '',
            '',
            ''
        ],
        [
            'release/v1.2.0',
            'e5a9f21 (1w ago)',
            '',
            '',
            ''
        ],
    ]
);

$lines = $detailed->draw(width => 140, height => 12);
say for $lines->@*;

say "\n" . "=" x 130 . "\n";

# Compact comparison
say "=== Quick Branch Comparison ===\n";

my $compact = P5::TUI::Table->new(
    column_spec => [
        {
            name  => 'Branch',
            width => 18,
            align => 1,
            color => { fg => 'cyan' }
        },
        {
            name  => 'HEAD',
            width => 10,
            align => 1,
            color => { fg => 'yellow' }
        },
        {
            name  => 'HEAD~1',
            width => 10,
            align => 1,
            color => { fg => 'white' }
        },
        {
            name  => 'HEAD~2',
            width => 10,
            align => 1,
            color => { fg => 'white' }
        },
        {
            name  => 'Commits',
            width => 8,
            align => -1,
            color => { fg => 'green' }
        },
        {
            name  => 'Behind/Ahead',
            width => 15,
            align => 1,
            color => { fg => 'magenta' }
        },
    ],
    rows => [
        ['main', 'a3f7b21', 'd8c4091', '2b5e8f3', '47', 'up to date'],
        ['feature/dark-mode', '9e2f6a4', '1c7d9b2', '', '2', '↑2 ahead'],
        ['feature/api-v2', '4f8a1d3', 'b6c9e72', '', '5', '↑1 ↓3'],
        ['bugfix/memory', '7d3c4b8', '', '', '1', 'local only'],
        ['release/v1.2.0', 'e5a9f21', '', '', '1', 'synced'],
    ]
);

$lines = $compact->draw(width => 100, height => 12);
say for $lines->@*;

say "\n=== Done ===";
