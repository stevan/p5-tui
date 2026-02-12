use v5.38;
use utf8;
use experimental 'class';
use Test::More;

BEGIN {
    use_ok('P5::TUI::Tree');
}

# Set UTF-8 for test output
binmode(STDOUT, ':encoding(UTF-8)');
binmode(STDERR, ':encoding(UTF-8)');

# Helper to strip ANSI color codes
sub strip_ansi {
    my $text = shift;
    $text =~ s/\e\[[0-9;]*m//g;
    return $text;
}

subtest 'Single node (no children)' => sub {
    my $tree = P5::TUI::Tree->new(
        root => { label => 'Root' }
    );

    my $lines = $tree->draw(width => 80, height => 10);
    my @clean = map { strip_ansi($_) } $lines->@*;

    is(scalar(@clean), 1, 'single line for single node');
    is($clean[0], 'Root', 'root node rendered');
};

subtest 'Root with two children' => sub {
    my $tree = P5::TUI::Tree->new(
        root => {
            label => 'Root',
            children => [
                { label => 'Child 1' },
                { label => 'Child 2' },
            ]
        }
    );

    my $lines = $tree->draw(width => 80, height => 10);
    my @clean = map { strip_ansi($_) } $lines->@*;

    is(scalar(@clean), 3, 'three lines total');
    is($clean[0], 'Root', 'root node');
    is($clean[1], '├──Child 1', 'first child with branch');
    is($clean[2], '└──Child 2', 'last child with last branch');
};

subtest 'Nested tree (grandchildren)' => sub {
    my $tree = P5::TUI::Tree->new(
        root => {
            label => 'Root',
            children => [
                {
                    label => 'Child 1',
                    children => [
                        { label => 'Grandchild 1' },
                        { label => 'Grandchild 2' },
                    ]
                },
                { label => 'Child 2' },
            ]
        }
    );

    my $lines = $tree->draw(width => 80, height => 10);
    my @clean = map { strip_ansi($_) } $lines->@*;

    is(scalar(@clean), 5, 'five lines total');
    is($clean[0], 'Root', 'root');
    is($clean[1], '├──Child 1', 'first child');
    is($clean[2], '│   ├──Grandchild 1', 'first grandchild');
    is($clean[3], '│   └──Grandchild 2', 'last grandchild');
    is($clean[4], '└──Child 2', 'second child');
};

subtest 'Three levels deep' => sub {
    my $tree = P5::TUI::Tree->new(
        root => {
            label => 'A',
            children => [
                {
                    label => 'B',
                    children => [
                        {
                            label => 'C',
                            children => [
                                { label => 'D' }
                            ]
                        }
                    ]
                }
            ]
        }
    );

    my $lines = $tree->draw(width => 80, height => 10);
    my @clean = map { strip_ansi($_) } $lines->@*;

    is($clean[0], 'A', 'root level');
    is($clean[1], '└──B', 'depth 1');
    is($clean[2], '    └──C', 'depth 2');
    is($clean[3], '        └──D', 'depth 3');
};

subtest 'Empty children array' => sub {
    my $tree = P5::TUI::Tree->new(
        root => {
            label => 'Root',
            children => []
        }
    );

    my $lines = $tree->draw(width => 80, height => 10);
    my @clean = map { strip_ansi($_) } $lines->@*;

    is(scalar(@clean), 1, 'just root node');
    is($clean[0], 'Root', 'root rendered');
};

done_testing;
