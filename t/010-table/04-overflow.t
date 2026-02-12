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

subtest 'Content truncation with ellipsis' => sub {
    my $table = P5::TUI::Table->new(
        column_spec => [
            { name => 'Col', width => 5, align => 1, color => {} }
        ],
        rows => [
            ['short'],
            ['this is way too long'],
        ]
    );

    my $lines = $table->draw(width => 20, height => 10);
    my @clean = map { strip_ansi($_) } $lines->@*;

    like($clean[3], qr/│short│/, 'short text not truncated');
    like($clean[4], qr/│this…│/, 'long text truncated with ellipsis');
};

subtest 'Header truncation' => sub {
    my $table = P5::TUI::Table->new(
        column_spec => [
            { name => 'Very Long Column Name', width => 8, align => 1, color => {} }
        ],
        rows => [ ['data'] ]
    );

    my $lines = $table->draw(width => 20, height => 10);
    my @clean = map { strip_ansi($_) } $lines->@*;

    like($clean[1], qr/│Very Lo…│/, 'header truncated with ellipsis');
};

subtest 'Row overflow indicator' => sub {
    my $table = P5::TUI::Table->new(
        column_spec => [
            { name => 'A', width => 5, align => 1, color => {} },
            { name => 'B', width => 5, align => 1, color => {} }
        ],
        rows => [
            ['r1', 'd1'],
            ['r2', 'd2'],
            ['r3', 'd3'],
            ['r4', 'd4'],
            ['r5', 'd5'],
            ['r6', 'd6'],
            ['r7', 'd7'],
            ['r8', 'd8'],
        ]
    );

    # Height of 8: top border (1) + header (1) + separator (1) + rows + bottom border (1)
    # = 4 for structure, leaving 4 for data rows
    # With 8 rows of data, we should see overflow indicator
    my $lines = $table->draw(width => 20, height => 8);
    my @clean = map { strip_ansi($_) } $lines->@*;

    is($clean[0], '┌─────┬─────┐', 'top border');
    is($clean[1], '│A    │B    │', 'header');
    is($clean[2], '├─────┼─────┤', 'separator');

    # Should have some data rows
    like($clean[3], qr/│r\d/, 'has data rows');

    # Should have overflow indicator before bottom border
    my $second_last = $clean[-2];
    like($second_last, qr/│\.\.\./, 'has overflow indicator');

    is($clean[-1], '└─────┴─────┘', 'bottom border');
};

subtest 'All rows fit (no overflow)' => sub {
    my $table = P5::TUI::Table->new(
        column_spec => [
            { name => 'A', width => 5, align => 1, color => {} }
        ],
        rows => [
            ['r1'],
            ['r2'],
        ]
    );

    # Height of 10 is plenty for 2 rows
    my $lines = $table->draw(width => 20, height => 10);
    my @clean = map { strip_ansi($_) } $lines->@*;

    # Should have all rows without overflow indicator
    is($clean[0], '┌─────┐', 'top border');
    is($clean[1], '│A    │', 'header');
    is($clean[2], '├─────┤', 'separator');
    is($clean[3], '│r1   │', 'row 1');
    is($clean[4], '│r2   │', 'row 2');
    is($clean[5], '└─────┘', 'bottom border');

    # No overflow indicator
    ok(!grep(/\.\.\./, @clean), 'no overflow indicator');
};

done_testing;
