#!/usr/bin/env perl
use v5.38;
use utf8;
use experimental 'class';

use lib '../lib';
use P5::TUI::Table;

# CRITICAL: Set UTF-8 encoding for output
binmode(STDOUT, ':encoding(UTF-8)');

say "=== Table with Tree Column ===\n";
say "Tree structure in first column, other columns stay aligned\n";

# File system example
my $filesystem = P5::TUI::Table->new(
    column_spec => [
        {
            name  => 'Tree',
            width => 15,
            align => 1,
            color => { fg => 'cyan' }
        },
        {
            name  => 'Name',
            width => 20,
            align => 1,
            color => { fg => 'white' }
        },
        {
            name  => 'Type',
            width => 10,
            align => 1,
            color => { fg => 'yellow' }
        },
        {
            name  => 'Size',
            width => 12,
            align => -1,
            color => { fg => 'green' }
        },
        {
            name  => 'Modified',
            width => '30%',
            align => 1,
            color => { fg => 'magenta' }
        },
    ],
    rows => [
        ['●', '/', 'dir', '-', '2024-01-15'],
        ['├─●', 'home', 'dir', '-', '2024-01-14'],
        ['│ ├─●', 'user', 'dir', '-', '2024-01-14'],
        ['│ │ ├─●', 'documents', 'dir', '-', '2024-01-13'],
        ['│ │ │ └─●', 'report.pdf', 'file', '2.4 MB', '2024-01-13'],
        ['│ │ └─●', 'downloads', 'dir', '-', '2024-01-12'],
        ['│ │   ├─●', 'image.png', 'file', '1.2 MB', '2024-01-12'],
        ['│ │   └─●', 'video.mp4', 'file', '45.8 MB', '2024-01-11'],
        ['│ └─●', 'alice', 'dir', '-', '2024-01-10'],
        ['├─●', 'etc', 'dir', '-', '2024-01-09'],
        ['│ ├─●', 'config.yml', 'file', '1.2 KB', '2024-01-09'],
        ['│ └─●', 'hosts', 'file', '845 B', '2024-01-08'],
        ['└─●', 'var', 'dir', '-', '2024-01-07'],
        ['  ├─●', 'log', 'dir', '-', '2024-01-07'],
        ['  │ └─●', 'system.log', 'file', '12.3 MB', '2024-01-07'],
        ['  └─●', 'cache', 'dir', '-', '2024-01-06'],
    ]
);

my $lines = $filesystem->draw(width => 100, height => 25);
say for $lines->@*;

say "\n" . "=" x 100 . "\n";

# Process hierarchy example
say "=== Process Tree ===\n";

my $process_tree = P5::TUI::Table->new(
    column_spec => [
        {
            name  => 'Tree',
            width => 12,
            align => 1,
            color => { fg => 'bright_blue' }
        },
        {
            name  => 'PID',
            width => 8,
            align => -1,
            color => { fg => 'yellow' }
        },
        {
            name  => 'Name',
            width => 20,
            align => 1,
            color => { fg => 'white' }
        },
        {
            name  => 'CPU%',
            width => 8,
            align => -1,
            color => { fg => 'green' }
        },
        {
            name  => 'Memory',
            width => 10,
            align => -1,
            color => { fg => 'cyan' }
        },
        {
            name  => 'Status',
            width => '30%',
            align => 1,
            color => { fg => 'magenta' }
        },
    ],
    rows => [
        ['●', '1', 'systemd', '0.1', '4.2 MB', 'running'],
        ['├─●', '234', 'networkd', '0.3', '8.1 MB', 'running'],
        ['├─●', '345', 'sshd', '0.0', '2.5 MB', 'listening'],
        ['│ ├─●', '1024', 'sshd', '0.2', '3.1 MB', 'session'],
        ['│ │ └─●', '1025', 'bash', '0.1', '1.8 MB', 'running'],
        ['│ │   └─●', '2048', 'vim', '1.2', '15.4 MB', 'running'],
        ['│ └─●', '1030', 'sshd', '0.1', '3.0 MB', 'session'],
        ['├─●', '456', 'postgresql', '2.5', '128 MB', 'running'],
        ['│ ├─●', '457', 'pg: writer', '0.8', '24 MB', 'running'],
        ['│ └─●', '458', 'pg: wal writer', '0.3', '12 MB', 'running'],
        ['└─●', '789', 'nginx', '1.1', '45 MB', 'running'],
        ['  ├─●', '790', 'worker', '0.5', '32 MB', 'running'],
        ['  └─●', '791', 'worker', '0.4', '30 MB', 'running'],
    ]
);

$lines = $process_tree->draw(width => 100, height => 20);
say for $lines->@*;

say "\n" . "=" x 100 . "\n";

# Git commit tree (the original inspiration!)
say "=== Git Commit Graph with Metadata ===\n";

my $git_commits = P5::TUI::Table->new(
    column_spec => [
        {
            name  => 'Graph',
            width => 10,
            align => 1,
            color => { fg => 'bright_cyan' }
        },
        {
            name  => 'Hash',
            width => 8,
            align => 1,
            color => { fg => 'yellow' }
        },
        {
            name  => 'Message',
            width => '40%',
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
            name  => 'Date',
            width => '30%',
            align => 1,
            color => { fg => 'magenta' }
        },
    ],
    rows => [
        ['●', 'a3f7b21', 'Merge branch feature', 'Alice', '2 hours ago'],
        ['├─●', '9e2f6a4', 'Implement dark theme', 'Carol', '4 hours ago'],
        ['│ └─●', '1c7d9b2', 'Add color palette', 'Carol', '6 hours ago'],
        ['├─●', 'd8c4091', 'Add authentication', 'Alice', '5 hours ago'],
        ['├─●', '2b5e8f3', 'Fix validation bug', 'Bob', '1 day ago'],
        ['│ ├─●', '4f8a1d3', 'Add v2 endpoints', 'David', '2 days ago'],
        ['│ └─●', 'b6c9e72', 'Update docs', 'Bob', '3 days ago'],
        ['└─●', 'e5a9f21', 'Bump to v1.2.0', 'Alice', '1 week ago'],
    ]
);

$lines = $git_commits->draw(width => 100, height => 15);
say for $lines->@*;

say "\n" . "=" x 100 . "\n";

# Different tree styles (like in the image)
say "=== Different Tree Styles ===\n";

my $styles = P5::TUI::Table->new(
    column_spec => [
        {
            name  => 'Normal',
            width => 12,
            align => 1,
            color => { fg => 'cyan' }
        },
        {
            name  => 'Rounded',
            width => 12,
            align => 1,
            color => { fg => 'green' }
        },
        {
            name  => 'Bold',
            width => 12,
            align => 1,
            color => { fg => 'yellow' }
        },
        {
            name  => 'Double',
            width => 12,
            align => 1,
            color => { fg => 'magenta' }
        },
        {
            name  => 'ASCII',
            width => 12,
            align => 1,
            color => { fg => 'white' }
        },
    ],
    rows => [
        ['●', '●', '●', '●', '*'],
        ['├─●', '╭─●', '┣─●', '╠═●', '+-*'],
        ['│ ├─●', '│ ╭─●', '┃ ┣─●', '║ ╠═●', '| +-*'],
        ['│ └─●', '│ ╰─●', '┃ ┗─●', '║ ╚═●', '| `-*'],
        ['└─●', '╰─●', '┗─●', '╚═●', '`-*'],
    ]
);

$lines = $styles->draw(width => 80, height => 12);
say for $lines->@*;

say "\n=== Key Insight ===";
say "Notice how ALL columns remain perfectly aligned regardless of tree depth!";
say "The tree structure is ONLY in the first column.";
