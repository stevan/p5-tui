#!/usr/bin/env perl
use v5.38;
use utf8;
use experimental 'class';

use lib '../lib';
use P5::TUI::TreeTable;

# CRITICAL: Set UTF-8 encoding for output
binmode(STDOUT, ':encoding(UTF-8)');

say "=" x 100;
say "=== TreeTable: Flat Format ===";
say "=" x 100;
say "";

# Format 1: Flat array with depth as first element
my $flat_tree = P5::TUI::TreeTable->new(
    format => 'flat',
    data => [
        # [depth, name, type, size, modified]
        [0, '/', 'dir', '-', '2024-01-15'],
        [1, 'home', 'dir', '-', '2024-01-14'],
        [2, 'user', 'dir', '-', '2024-01-14'],
        [3, 'documents', 'dir', '-', '2024-01-13'],
        [4, 'report.pdf', 'file', '2.4 MB', '2024-01-13'],
        [4, 'notes.txt', 'file', '8.1 KB', '2024-01-12'],
        [3, 'downloads', 'dir', '-', '2024-01-12'],
        [4, 'image.png', 'file', '1.2 MB', '2024-01-12'],
        [4, 'video.mp4', 'file', '45.8 MB', '2024-01-11'],
        [2, 'alice', 'dir', '-', '2024-01-10'],
        [3, 'projects', 'dir', '-', '2024-01-10'],
        [1, 'etc', 'dir', '-', '2024-01-09'],
        [2, 'config.yml', 'file', '1.2 KB', '2024-01-09'],
        [2, 'hosts', 'file', '845 B', '2024-01-08'],
        [1, 'var', 'dir', '-', '2024-01-07'],
        [2, 'log', 'dir', '-', '2024-01-07'],
        [3, 'system.log', 'file', '12.3 MB', '2024-01-07'],
        [2, 'cache', 'dir', '-', '2024-01-06'],
    ],
    column_spec => [
        {
            name  => 'Tree',
            width => 18,
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
    ]
);

my $lines = $flat_tree->draw(width => 100, height => 30);
say for $lines->@*;

say "\n" . "=" x 100;
say "=== TreeTable: Nested Format ===";
say "=" x 100;
say "";

# Format 2: Nested structure with row data
my $nested_tree = P5::TUI::TreeTable->new(
    format => 'nested',
    data => {
        row => ['systemd', 1, '0.1%', '4.2 MB', 'running'],
        children => [
            {
                row => ['networkd', 234, '0.3%', '8.1 MB', 'running'],
            },
            {
                row => ['sshd', 345, '0.0%', '2.5 MB', 'listening'],
                children => [
                    {
                        row => ['sshd', 1024, '0.2%', '3.1 MB', 'session'],
                        children => [
                            {
                                row => ['bash', 1025, '0.1%', '1.8 MB', 'running'],
                                children => [
                                    {
                                        row => ['vim', 2048, '1.2%', '15.4 MB', 'running'],
                                    }
                                ]
                            }
                        ]
                    },
                    {
                        row => ['sshd', 1030, '0.1%', '3.0 MB', 'session'],
                        children => [
                            {
                                row => ['bash', 1031, '0.0%', '1.7 MB', 'running'],
                            }
                        ]
                    },
                ]
            },
            {
                row => ['postgresql', 456, '2.5%', '128 MB', 'running'],
                children => [
                    { row => ['pg: writer', 457, '0.8%', '24 MB', 'running'] },
                    { row => ['pg: wal writer', 458, '0.3%', '12 MB', 'running'] },
                ]
            },
            {
                row => ['nginx', 789, '1.1%', '45 MB', 'running'],
                children => [
                    { row => ['worker', 790, '0.5%', '32 MB', 'running'] },
                    { row => ['worker', 791, '0.4%', '30 MB', 'running'] },
                    { row => ['worker', 792, '0.3%', '28 MB', 'running'] },
                ]
            },
        ]
    },
    column_spec => [
        {
            name  => 'Tree',
            width => 15,
            align => 1,
            color => { fg => 'bright_blue' }
        },
        {
            name  => 'Process',
            width => 18,
            align => 1,
            color => { fg => 'white' }
        },
        {
            name  => 'PID',
            width => 8,
            align => -1,
            color => { fg => 'yellow' }
        },
        {
            name  => 'CPU',
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
    ]
);

$lines = $nested_tree->draw(width => 100, height => 30);
say for $lines->@*;

say "\n" . "=" x 100;
say "=== TreeTable: Git Commit Graph (Nested) ===";
say "=" x 100;
say "";

# Git commit graph using nested format
my $git_tree = P5::TUI::TreeTable->new(
    format => 'nested',
    data => {
        row => ['a3f7b21', 'Merge branch feature/dark-mode', 'Alice', '2 hours ago'],
        children => [
            {
                row => ['9e2f6a4', 'Implement dark theme toggle', 'Carol', '4 hours ago'],
                children => [
                    {
                        row => ['1c7d9b2', 'Add dark mode color palette', 'Carol', '6 hours ago'],
                    }
                ]
            },
            {
                row => ['d8c4091', 'Add user authentication system', 'Alice', '5 hours ago'],
                children => [
                    {
                        row => ['2b5e8f3', 'Fix validation bug in forms', 'Bob', '1 day ago'],
                        children => [
                            {
                                row => ['4f8a1d3', 'Add v2 API endpoints', 'David', '2 days ago'],
                            },
                            {
                                row => ['b6c9e72', 'Update API documentation', 'Bob', '3 days ago'],
                            }
                        ]
                    }
                ]
            },
        ]
    },
    column_spec => [
        {
            name  => 'Graph',
            width => 12,
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
    ]
);

$lines = $git_tree->draw(width => 110, height => 20);
say for $lines->@*;

say "\n" . "=" x 100;
say "=== TreeTable: Organization Chart (Flat) ===";
say "=" x 100;
say "";

# Organization chart using flat format
my $org_tree = P5::TUI::TreeTable->new(
    format => 'flat',
    data => [
        # [depth, name, title, department, reports]
        [0, 'Alice Johnson', 'CEO', 'Executive', '-'],
        [1, 'Bob Smith', 'CTO', 'Technology', '15'],
        [2, 'Carol White', 'VP Engineering', 'Engineering', '8'],
        [3, 'David Lee', 'Tech Lead', 'Backend', '4'],
        [3, 'Eve Brown', 'Tech Lead', 'Frontend', '4'],
        [2, 'Frank Green', 'VP Infrastructure', 'Ops', '7'],
        [1, 'Grace Davis', 'CFO', 'Finance', '5'],
        [2, 'Henry Wilson', 'Controller', 'Accounting', '3'],
        [2, 'Iris Martinez', 'Treasurer', 'Treasury', '2'],
        [1, 'Jack Taylor', 'CMO', 'Marketing', '8'],
        [2, 'Kelly Anderson', 'VP Marketing', 'Growth', '5'],
        [2, 'Leo Thomas', 'VP Sales', 'Sales', '3'],
    ],
    column_spec => [
        {
            name  => 'Tree',
            width => 15,
            align => 1,
            color => { fg => 'bright_green' }
        },
        {
            name  => 'Name',
            width => 20,
            align => 1,
            color => { fg => 'white' }
        },
        {
            name  => 'Title',
            width => '30%',
            align => 1,
            color => { fg => 'yellow' }
        },
        {
            name  => 'Department',
            width => 15,
            align => 1,
            color => { fg => 'cyan' }
        },
        {
            name  => 'Reports',
            width => 10,
            align => -1,
            color => { fg => 'magenta' }
        },
    ]
);

$lines = $org_tree->draw(width => 100, height => 20);
say for $lines->@*;

say "\n" . "=" x 100;
say "=== Key Features ===";
say "=" x 100;
say "";
say "✓ Two input formats: flat (depth-based) and nested (hierarchical)";
say "✓ Auto-generates tree prefixes with unicode box-drawing chars";
say "✓ All columns except first remain perfectly aligned";
say "✓ No ASCII fallback - unicode only for clean appearance";
say "✓ Works with any tabular data + hierarchy structure";
say "";
say "Use cases:";
say "  • File system browsers";
say "  • Process trees";
say "  • Git commit graphs";
say "  • Organization charts";
say "  • Any hierarchical data with attributes";
