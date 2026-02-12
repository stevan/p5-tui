use v5.38;
use utf8;
use experimental 'class';
use Test::More;

BEGIN {
    use_ok('P5::TUI::Table');
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

subtest 'Simple 2x2 table with headers' => sub {
    my $table = P5::TUI::Table->new(
        column_spec => [
            { name => 'A', width => 5, align => 1, color => {} },
            { name => 'B', width => 5, align => 1, color => {} }
        ],
        rows => [
            ['foo', 'bar'],
            ['baz', 'qux']
        ]
    );

    my $lines = $table->draw(width => 20, height => 10);
    my @clean = map { strip_ansi($_) } $lines->@*;

    is($clean[0], '┌─────┬─────┐', 'top border');
    is($clean[1], '│A    │B    │', 'headers');
    is($clean[2], '├─────┼─────┤', 'separator');
    is($clean[3], '│foo  │bar  │', 'row 1');
    is($clean[4], '│baz  │qux  │', 'row 2');
    is($clean[5], '└─────┴─────┘', 'bottom border');
    is(scalar(@clean), 6, 'correct number of lines');
};

subtest 'Table without headers (empty names)' => sub {
    my $table = P5::TUI::Table->new(
        column_spec => [
            { name => '', width => 5, align => 1, color => {} },
            { name => '', width => 5, align => 1, color => {} }
        ],
        rows => [
            ['foo', 'bar'],
            ['baz', 'qux']
        ]
    );

    my $lines = $table->draw(width => 20, height => 10);
    my @clean = map { strip_ansi($_) } $lines->@*;

    is($clean[0], '┌─────┬─────┐', 'top border');
    is($clean[1], '│foo  │bar  │', 'row 1 (no header row)');
    is($clean[2], '│baz  │qux  │', 'row 2');
    is($clean[3], '└─────┴─────┘', 'bottom border');
    is(scalar(@clean), 4, 'fewer lines without headers');
};

subtest 'Single column table' => sub {
    my $table = P5::TUI::Table->new(
        column_spec => [
            { name => 'Col', width => 10, align => 1, color => {} }
        ],
        rows => [
            ['value1'],
            ['value2']
        ]
    );

    my $lines = $table->draw(width => 20, height => 10);
    my @clean = map { strip_ansi($_) } $lines->@*;

    is($clean[0], '┌──────────┐', 'top border');
    is($clean[1], '│Col       │', 'header');
    is($clean[2], '├──────────┤', 'separator');
    is($clean[3], '│value1    │', 'row 1');
    is($clean[4], '│value2    │', 'row 2');
    is($clean[5], '└──────────┘', 'bottom border');
};

subtest 'Empty table (no rows)' => sub {
    my $table = P5::TUI::Table->new(
        column_spec => [
            { name => 'A', width => 5, align => 1, color => {} },
            { name => 'B', width => 5, align => 1, color => {} }
        ],
        rows => []
    );

    my $lines = $table->draw(width => 20, height => 10);
    my @clean = map { strip_ansi($_) } $lines->@*;

    is($clean[0], '┌─────┬─────┐', 'top border');
    is($clean[1], '│A    │B    │', 'headers');
    is($clean[2], '├─────┼─────┤', 'separator');
    is($clean[3], '└─────┴─────┘', 'bottom border');
    is(scalar(@clean), 4, 'just borders and headers');
};

done_testing;
