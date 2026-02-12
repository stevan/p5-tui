#!/usr/bin/env perl
use v5.38;
use utf8;
use experimental 'class';

use Test::More;
use lib '../lib';

BEGIN {
    use_ok('P5::TUI::TreeTable');
}

# Helper to strip ANSI color codes for easier testing
sub strip_ansi {
    my ($text) = @_;
    $text =~ s/\e\[[0-9;]*m//g;
    return $text;
}

# Helper to get data rows (skip header and borders)
sub get_data_row {
    my ($lines, $index) = @_;
    # Table structure: 0=top border, 1=header, 2=separator, 3+=data
    return strip_ansi($lines->[3 + $index]);
}

# Test 1: Flat format - Simple hierarchy
{
    my $tree = P5::TUI::TreeTable->new(
        format => 'flat',
        data => [
            [0, 'root'],
            [1, 'child1'],
            [1, 'child2'],
        ],
        column_spec => [
            { name => 'Tree', width => 10, align => 1 },
            { name => 'Name', width => 10, align => 1 },
        ]
    );

    my $lines = $tree->draw(width => 50, height => 10);
    ok(defined $lines, 'Flat format: simple hierarchy renders');
    is(ref $lines, 'ARRAY', 'Returns array reference');

    my $root = get_data_row($lines, 0);
    my $child1 = get_data_row($lines, 1);
    my $child2 = get_data_row($lines, 2);

    like($root, qr/●.*root/, 'Root node has node marker');
    like($child1, qr/├─●.*child1/, 'First child has branch');
    like($child2, qr/└─●.*child2/, 'Last child has last-branch');
}

# Test 2: Flat format - Deep nesting
{
    my $tree = P5::TUI::TreeTable->new(
        format => 'flat',
        data => [
            [0, 'root'],
            [1, 'level1'],
            [2, 'level2'],
            [3, 'level3'],
        ],
        column_spec => [
            { name => 'Tree', width => 20, align => 1 },
            { name => 'Name', width => 10, align => 1 },
        ]
    );

    my $lines = $tree->draw(width => 50, height => 10);
    ok(defined $lines, 'Flat format: deep nesting renders');

    my $d0 = get_data_row($lines, 0);
    my $d1 = get_data_row($lines, 1);
    my $d2 = get_data_row($lines, 2);
    my $d3 = get_data_row($lines, 3);

    like($d0, qr/●.*root/, 'Depth 0: root');
    like($d1, qr/└─●.*level1/, 'Depth 1: single child');
    like($d2, qr/└─●.*level2/, 'Depth 2: nested single child');
    like($d3, qr/└─●.*level3/, 'Depth 3: deeply nested child');
}

# Test 3: Flat format - Multiple siblings with continuation
{
    my $tree = P5::TUI::TreeTable->new(
        format => 'flat',
        data => [
            [0, 'root'],
            [1, 'child1'],
            [2, 'grandchild1'],
            [1, 'child2'],
        ],
        column_spec => [
            { name => 'Tree', width => 20, align => 1 },
            { name => 'Name', width => 15, align => 1 },
        ]
    );

    my $lines = $tree->draw(width => 50, height => 10);
    ok(defined $lines, 'Flat format: continuation lines render');

    my $root = get_data_row($lines, 0);
    my $child1 = get_data_row($lines, 1);
    my $grandchild = get_data_row($lines, 2);
    my $child2 = get_data_row($lines, 3);

    like($root, qr/●.*root/, 'Root');
    like($child1, qr/├─●.*child1/, 'Child1 has branch (not last)');
    like($grandchild, qr/│.*└─●.*grandchild1/, 'Grandchild with continuation');
    like($child2, qr/└─●.*child2/, 'Child2 has last-branch');
}

# Test 4: Nested format - Simple tree
{
    my $tree = P5::TUI::TreeTable->new(
        format => 'nested',
        data => {
            row => ['root'],
            children => [
                { row => ['child1'] },
                { row => ['child2'] },
            ]
        },
        column_spec => [
            { name => 'Tree', width => 15, align => 1 },
            { name => 'Name', width => 10, align => 1 },
        ]
    );

    my $lines = $tree->draw(width => 50, height => 10);
    ok(defined $lines, 'Nested format: simple tree renders');

    my $root = get_data_row($lines, 0);
    my $child1 = get_data_row($lines, 1);
    my $child2 = get_data_row($lines, 2);

    like($root, qr/●.*root/, 'Root node');
    like($child1, qr/├─●.*child1/, 'First child');
    like($child2, qr/└─●.*child2/, 'Last child');
}

# Test 5: Nested format - Deep hierarchy with multiple branches
{
    my $tree = P5::TUI::TreeTable->new(
        format => 'nested',
        data => {
            row => ['root'],
            children => [
                {
                    row => ['branch1'],
                    children => [
                        { row => ['leaf1'] },
                        { row => ['leaf2'] },
                    ]
                },
                {
                    row => ['branch2'],
                    children => [
                        { row => ['leaf3'] },
                    ]
                },
            ]
        },
        column_spec => [
            { name => 'Tree', width => 18, align => 1 },
            { name => 'Name', width => 10, align => 1 },
        ]
    );

    my $lines = $tree->draw(width => 50, height => 15);
    ok(defined $lines, 'Nested format: complex tree renders');

    my $root = get_data_row($lines, 0);
    my $branch1 = get_data_row($lines, 1);
    my $leaf1 = get_data_row($lines, 2);
    my $leaf2 = get_data_row($lines, 3);
    my $branch2 = get_data_row($lines, 4);
    my $leaf3 = get_data_row($lines, 5);

    like($root, qr/●.*root/, 'Root');
    like($branch1, qr/├─●.*branch1/, 'Branch1 (not last)');
    like($leaf1, qr/│.*├─●.*leaf1/, 'Leaf1 with continuation');
    like($leaf2, qr/│.*└─●.*leaf2/, 'Leaf2 with continuation');
    like($branch2, qr/└─●.*branch2/, 'Branch2 (last)');
    like($leaf3, qr/└─●.*leaf3/, 'Leaf3 (no continuation)');
}

# Test 6: Single node (edge case)
{
    my $tree = P5::TUI::TreeTable->new(
        format => 'flat',
        data => [
            [0, 'only'],
        ],
        column_spec => [
            { name => 'Tree', width => 10, align => 1 },
            { name => 'Name', width => 10, align => 1 },
        ]
    );

    my $lines = $tree->draw(width => 50, height => 10);
    ok(defined $lines, 'Single node renders');

    my $only = get_data_row($lines, 0);
    like($only, qr/●.*only/, 'Single node has no branch prefix');
}

# Test 7: Nested format - Single node (no children)
{
    my $tree = P5::TUI::TreeTable->new(
        format => 'nested',
        data => {
            row => ['lonely'],
        },
        column_spec => [
            { name => 'Tree', width => 10, align => 1 },
            { name => 'Name', width => 10, align => 1 },
        ]
    );

    my $lines = $tree->draw(width => 50, height => 10);
    ok(defined $lines, 'Nested single node renders');

    my $lonely = get_data_row($lines, 0);
    like($lonely, qr/●.*lonely/, 'Single node in nested format');
}

# Test 8: Multiple columns with tree
{
    my $tree = P5::TUI::TreeTable->new(
        format => 'flat',
        data => [
            [0, 'root', 'dir', '1024'],
            [1, 'child', 'file', '512'],
        ],
        column_spec => [
            { name => 'Tree', width => 12, align => 1 },
            { name => 'Name', width => 10, align => 1 },
            { name => 'Type', width => 8, align => 1 },
            { name => 'Size', width => 8, align => -1 },
        ]
    );

    my $lines = $tree->draw(width => 60, height => 10);
    ok(defined $lines, 'Multiple columns render');

    my $header = strip_ansi($lines->[1]);
    like($header, qr/Tree.*Name.*Type.*Size/, 'All column headers present');

    my $root = get_data_row($lines, 0);
    my $child = get_data_row($lines, 1);

    like($root, qr/●.*root.*dir.*1024/, 'Root row has all columns');
    like($child, qr/└─●.*child.*file.*512/, 'Child row has all columns');
}

# Test 9: Flat format - Last sibling detection across depth changes
{
    my $tree = P5::TUI::TreeTable->new(
        format => 'flat',
        data => [
            [0, 'root'],
            [1, 'a'],
            [2, 'a1'],
            [2, 'a2'],
            [1, 'b'],
            [1, 'c'],
        ],
        column_spec => [
            { name => 'Tree', width => 15, align => 1 },
            { name => 'Name', width => 10, align => 1 },
        ]
    );

    my $lines = $tree->draw(width => 50, height => 15);
    ok(defined $lines, 'Complex sibling structure renders');

    my $root = get_data_row($lines, 0);
    my $a = get_data_row($lines, 1);
    my $a1 = get_data_row($lines, 2);
    my $a2 = get_data_row($lines, 3);
    my $b = get_data_row($lines, 4);
    my $c = get_data_row($lines, 5);

    like($a, qr/├─●.*\ba\b/, 'Child "a" is not last');
    like($a1, qr/│.*├─●.*a1/, 'Grandchild "a1" is not last');
    like($a2, qr/│.*└─●.*a2/, 'Grandchild "a2" is last');
    like($b, qr/├─●.*\bb\b/, 'Child "b" is not last');
    like($c, qr/└─●.*\bc\b/, 'Child "c" is last');
}

# Test 10: Format validation
{
    eval {
        my $tree = P5::TUI::TreeTable->new(
            format => 'invalid',
            data => [],
            column_spec => [
                { name => 'Tree', width => 10, align => 1 },
            ]
        );
        $tree->draw(width => 50, height => 10);
    };
    like($@, qr/Unknown format/, 'Invalid format throws error');
}

# Test 11: Flat format - All same depth (multiple roots)
{
    my $tree = P5::TUI::TreeTable->new(
        format => 'flat',
        data => [
            [0, 'item1'],
            [0, 'item2'],
            [0, 'item3'],
        ],
        column_spec => [
            { name => 'Tree', width => 10, align => 1 },
            { name => 'Name', width => 10, align => 1 },
        ]
    );

    my $lines = $tree->draw(width => 50, height => 10);
    ok(defined $lines, 'Flat list (all same depth) renders');

    my $item1 = get_data_row($lines, 0);
    my $item2 = get_data_row($lines, 1);
    my $item3 = get_data_row($lines, 2);

    # All at depth 0, no parent, so just node markers
    like($item1, qr/●.*item1/, 'First item at depth 0');
    like($item2, qr/●.*item2/, 'Second item at depth 0');
    like($item3, qr/●.*item3/, 'Third item at depth 0');
}

# Test 12: Verify unicode characters (no ASCII fallback)
{
    my $tree = P5::TUI::TreeTable->new(
        format => 'flat',
        data => [
            [0, 'root'],
            [1, 'child'],
        ],
        column_spec => [
            { name => 'Tree', width => 10, align => 1 },
            { name => 'Name', width => 10, align => 1 },
        ]
    );

    my $lines = $tree->draw(width => 50, height => 10);

    # Join all lines and strip ANSI
    my $content = strip_ansi(join('', $lines->@*));

    like($content, qr/●/, 'Uses unicode node marker ●');
    like($content, qr/[├└]/, 'Uses unicode branch chars');
    like($content, qr/─/, 'Uses unicode horizontal line');
    like($content, qr/│/, 'Uses unicode vertical line');
}

# Test 13: Empty children in nested format
{
    my $tree = P5::TUI::TreeTable->new(
        format => 'nested',
        data => {
            row => ['parent'],
            children => []  # Empty children array
        },
        column_spec => [
            { name => 'Tree', width => 10, align => 1 },
            { name => 'Name', width => 10, align => 1 },
        ]
    );

    my $lines = $tree->draw(width => 50, height => 10);
    ok(defined $lines, 'Nested format with empty children renders');

    my $parent = get_data_row($lines, 0);
    like($parent, qr/●.*parent/, 'Parent renders even with empty children');
}

# Test 14: Column alignment preservation
{
    my $tree = P5::TUI::TreeTable->new(
        format => 'flat',
        data => [
            [0, 'a', '100'],
            [1, 'b', '200'],
            [2, 'c', '300'],
        ],
        column_spec => [
            { name => 'Tree', width => 15, align => 1 },
            { name => 'Name', width => 10, align => 1 },
            { name => 'Value', width => 10, align => -1 },
        ]
    );

    my $lines = $tree->draw(width => 60, height => 10);
    ok(defined $lines, 'Column alignment test renders');

    my $row0 = get_data_row($lines, 0);
    my $row1 = get_data_row($lines, 1);
    my $row2 = get_data_row($lines, 2);

    like($row0, qr/●.*a.*100/, 'Depth 0 has value');
    like($row1, qr/└─●.*b.*200/, 'Depth 1 has value');
    like($row2, qr/└─●.*c.*300/, 'Depth 2 has value');
}

# Test 15: Nested format - No children field (not just empty array)
{
    my $tree = P5::TUI::TreeTable->new(
        format => 'nested',
        data => {
            row => ['leaf'],
            # No 'children' key at all
        },
        column_spec => [
            { name => 'Tree', width => 10, align => 1 },
            { name => 'Name', width => 10, align => 1 },
        ]
    );

    my $lines = $tree->draw(width => 50, height => 10);
    ok(defined $lines, 'Nested format with no children key renders');

    my $leaf = get_data_row($lines, 0);
    like($leaf, qr/●.*leaf/, 'Leaf node without children key renders');
}

done_testing();
