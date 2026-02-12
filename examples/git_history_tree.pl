#!/usr/bin/env perl
use v5.38;
use utf8;
use experimental 'class';

use lib '../lib';
use P5::TUI::Tree;

# CRITICAL: Set UTF-8 encoding for output
binmode(STDOUT, ':encoding(UTF-8)');

say "=== Git Repository History (Branch-Centric View) ===\n";

# Simulate git data (in real use, you'd parse `git log`, `git branch`, etc.)
my $git_tree = P5::TUI::Tree->new(
    root => {
        label => 'my-awesome-project (5 branches, 47 commits)',
        color => { fg => 'bright_white' },
        children => [
            {
                label => 'main (HEAD) ← origin/main',
                color => { fg => 'bright_green' },
                children => [
                    {
                        label => 'a3f7b21: Merge pull request #42 (2 hours ago)',
                        color => { fg => 'cyan' },
                    },
                    {
                        label => 'd8c4091: Add user authentication system (5 hours ago)',
                        color => { fg => 'white' },
                        children => [
                            { label => 'Author: Alice Johnson <alice@example.com>', color => { fg => 'yellow' } },
                            { label => 'Files: +456 -23 (12 files)', color => { fg => 'green' } },
                        ]
                    },
                    {
                        label => '2b5e8f3: Fix validation bug in forms (1 day ago)',
                        color => { fg => 'white' },
                    },
                ]
            },
            {
                label => 'feature/dark-mode ← origin/feature/dark-mode (2 commits ahead)',
                color => { fg => 'bright_blue' },
                children => [
                    {
                        label => '9e2f6a4: Implement dark theme toggle (4 hours ago)',
                        color => { fg => 'white' },
                    },
                    {
                        label => '1c7d9b2: Add dark mode color palette (6 hours ago)',
                        color => { fg => 'white' },
                    },
                ]
            },
            {
                label => 'feature/api-v2 ← origin/feature/api-v2',
                color => { fg => 'bright_blue' },
                children => [
                    {
                        label => '4f8a1d3: Add v2 endpoints (2 days ago)',
                        color => { fg => 'white' },
                    },
                    {
                        label => 'b6c9e72: Update API documentation (3 days ago)',
                        color => { fg => 'white' },
                    },
                ]
            },
            {
                label => 'bugfix/memory-leak (local only, not pushed)',
                color => { fg => 'bright_magenta' },
                children => [
                    {
                        label => '7d3c4b8: Fix memory leak in cache (1 hour ago)',
                        color => { fg => 'red' },
                    },
                ]
            },
            {
                label => 'release/v1.2.0 ← origin/release/v1.2.0',
                color => { fg => 'bright_yellow' },
                children => [
                    {
                        label => 'e5a9f21: Bump version to 1.2.0 (1 week ago)',
                        color => { fg => 'white' },
                    },
                ]
            },
        ]
    }
);

my $lines = $git_tree->draw(width => 100, height => 40);
say for $lines->@*;

say "\n" . "=" x 100 . "\n";

# Alternative view: Show merge structure
say "=== Alternative View: Merge Relationships ===\n";

my $merge_tree = P5::TUI::Tree->new(
    root => {
        label => 'a3f7b21 (main, HEAD) Merge feature/dark-mode into main',
        color => { fg => 'bright_green' },
        children => [
            {
                label => '9e2f6a4 (feature/dark-mode) Implement dark theme toggle',
                color => { fg => 'bright_blue' },
                children => [
                    {
                        label => '1c7d9b2 Add dark mode color palette',
                        color => { fg => 'blue' },
                    }
                ]
            },
            {
                label => 'd8c4091 (main~1) Add user authentication',
                color => { fg => 'cyan' },
                children => [
                    {
                        label => '2b5e8f3 Fix validation bug',
                        color => { fg => 'white' },
                    }
                ]
            },
        ]
    }
);

$lines = $merge_tree->draw(width => 100, height => 20);
say for $lines->@*;

say "\n" . "=" x 100;
say "Legend: ";
say "  • Green = main/active branch";
say "  • Blue = feature branches";
say "  • Magenta = local branches (not pushed)";
say "  • Yellow = release branches";
say "  • Red = critical fixes";
