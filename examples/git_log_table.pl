#!/usr/bin/env perl
use v5.38;
use utf8;
use experimental 'class';

use lib '../lib';
use P5::TUI::Table;

# CRITICAL: Set UTF-8 encoding for output
binmode(STDOUT, ':encoding(UTF-8)');

say "=== Git Log (Table View) ===\n";

# Simulate git log data
my $git_log = P5::TUI::Table->new(
    column_spec => [
        {
            name  => 'Graph',
            width => 8,
            align => 1,
            color => { fg => 'cyan' }
        },
        {
            name  => 'Hash',
            width => 8,
            align => 1,
            color => { fg => 'yellow' }
        },
        {
            name  => 'Author',
            width => 12,
            align => 1,
            color => { fg => 'green' }
        },
        {
            name  => 'Date',
            width => 14,
            align => 1,
            color => { fg => 'magenta' }
        },
        {
            name  => 'Message',
            width => '40%',
            align => 1,
            color => { fg => 'white' }
        },
        {
            name  => 'Refs',
            width => '20%',
            align => 1,
            color => { fg => 'bright_cyan' }
        },
    ],
    rows => [
        ['*', 'a3f7b21', 'Alice', '2 hours ago', 'Merge pull request #42', 'HEAD -> main, origin/main'],
        ['*', '9e2f6a4', 'Carol', '4 hours ago', 'Implement dark theme toggle', 'origin/feature/dark-mode'],
        ['*', 'd8c4091', 'Alice', '5 hours ago', 'Add user authentication system', ''],
        ['*', '1c7d9b2', 'Carol', '6 hours ago', 'Add dark mode color palette', ''],
        ['*', '2b5e8f3', 'Bob', '1 day ago', 'Fix validation bug in forms', ''],
        ['*', '4f8a1d3', 'David', '2 days ago', 'Add v2 API endpoints', 'feature/api-v2'],
        ['*', 'b6c9e72', 'Bob', '3 days ago', 'Update API documentation', ''],
        ['*', '7d3c4b8', 'Eve', '3 days ago', 'Fix memory leak in cache', ''],
        ['*', 'e5a9f21', 'Alice', '1 week ago', 'Bump version to 1.2.0', 'tag: v1.2.0'],
        ['*', '3a8c5d1', 'Bob', '1 week ago', 'Update dependencies', ''],
        ['*', 'f9b2e4c', 'Carol', '2 weeks ago', 'Refactor auth module', ''],
        ['*', '6d7a1b9', 'Alice', '2 weeks ago', 'Add integration tests', ''],
        ['*', 'c8f3d2a', 'David', '3 weeks ago', 'Initial commit', 'tag: v1.0.0'],
    ]
);

my $lines = $git_log->draw(width => 120, height => 20);
say for $lines->@*;

say "\n" . "=" x 120 . "\n";

# Alternative: Git log with graph visualization
say "=== Git Log with Merge Graph ===\n";

my $git_graph = P5::TUI::Table->new(
    column_spec => [
        {
            name  => 'Graph',
            width => 15,
            align => 1,
            color => { fg => 'cyan' }
        },
        {
            name  => 'Commit',
            width => 50,
            align => 1,
            color => { fg => 'white' }
        },
        {
            name  => 'Author',
            width => 12,
            align => 1,
            color => { fg => 'green' }
        },
        {
            name  => 'When',
            width => '25%',
            align => 1,
            color => { fg => 'magenta' }
        },
    ],
    rows => [
        ['*', 'a3f7b21 Merge feature/dark-mode', 'Alice', '2 hours ago'],
        ['|\\', '', '', ''],
        ['| *', '9e2f6a4 Implement dark theme', 'Carol', '4 hours ago'],
        ['| *', '1c7d9b2 Add color palette', 'Carol', '6 hours ago'],
        ['|/', '', '', ''],
        ['*', 'd8c4091 Add authentication', 'Alice', '5 hours ago'],
        ['*', '2b5e8f3 Fix validation bug', 'Bob', '1 day ago'],
        ['*', '4f8a1d3 Add v2 endpoints', 'David', '2 days ago'],
        ['*', 'b6c9e72 Update docs', 'Bob', '3 days ago'],
        ['*', 'e5a9f21 Bump to v1.2.0', 'Alice', '1 week ago'],
    ]
);

$lines = $git_graph->draw(width => 100, height => 15);
say for $lines->@*;

say "\n" . "=" x 120 . "\n";

# Compact view
say "=== Compact Git Log ===\n";

my $compact = P5::TUI::Table->new(
    column_spec => [
        {
            name  => 'Hash',
            width => 7,
            align => 1,
            color => { fg => 'yellow' }
        },
        {
            name  => 'Message',
            width => '60%',
            align => 1,
            color => { fg => 'white' }
        },
        {
            name  => 'By',
            width => 10,
            align => 1,
            color => { fg => 'cyan' }
        },
        {
            name  => 'When',
            width => '40%',
            align => 1,
            color => { fg => 'green' }
        },
    ],
    rows => [
        ['a3f7b21', 'Merge pull request #42', 'Alice', '2 hours ago'],
        ['9e2f6a4', 'Implement dark theme toggle', 'Carol', '4 hours ago'],
        ['d8c4091', 'Add user authentication system', 'Alice', '5 hours ago'],
        ['1c7d9b2', 'Add dark mode color palette', 'Carol', '6 hours ago'],
        ['2b5e8f3', 'Fix validation bug in forms', 'Bob', '1 day ago'],
        ['4f8a1d3', 'Add v2 API endpoints', 'David', '2 days ago'],
        ['b6c9e72', 'Update API documentation', 'Bob', '3 days ago'],
        ['7d3c4b8', 'Fix memory leak in cache', 'Eve', '3 days ago'],
    ]
);

$lines = $compact->draw(width => 100, height => 15);
say for $lines->@*;

say "\n=== Done ===";
