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

subtest 'Left alignment (align => 1)' => sub {
    my $table = P5::TUI::Table->new(
        column_spec => [
            { name => 'Left', width => 10, align => 1, color => {} }
        ],
        rows => [
            ['short'],
            ['x'],
        ]
    );

    my $lines = $table->draw(width => 20, height => 10);
    my @clean = map { strip_ansi($_) } $lines->@*;

    like($clean[1], qr/│Left\s+│/, 'header left-aligned');
    like($clean[3], qr/│short\s+│/, 'data left-aligned');
    like($clean[4], qr/│x\s+│/, 'single char left-aligned');
};

subtest 'Right alignment (align => -1)' => sub {
    my $table = P5::TUI::Table->new(
        column_spec => [
            { name => 'Right', width => 10, align => -1, color => {} }
        ],
        rows => [
            ['short'],
            ['x'],
        ]
    );

    my $lines = $table->draw(width => 20, height => 10);
    my @clean = map { strip_ansi($_) } $lines->@*;

    like($clean[1], qr/│\s+Right│/, 'header right-aligned');
    like($clean[3], qr/│\s+short│/, 'data right-aligned');
    like($clean[4], qr/│\s+x│/, 'single char right-aligned');
};

subtest 'Mixed alignment' => sub {
    my $table = P5::TUI::Table->new(
        column_spec => [
            { name => 'ID', width => 5, align => -1, color => {} },
            { name => 'Name', width => 10, align => 1, color => {} },
            { name => 'Value', width => 6, align => -1, color => {} }
        ],
        rows => [
            [1, 'Alice', 100],
            [42, 'Bob', 9],
        ]
    );

    my $lines = $table->draw(width => 40, height => 10);
    my @clean = map { strip_ansi($_) } $lines->@*;

    # Check that IDs are right-aligned
    like($clean[3], qr/│\s+1│/, 'ID 1 right-aligned');
    like($clean[4], qr/│\s+42│/, 'ID 42 right-aligned');

    # Check that names are left-aligned
    like($clean[3], qr/│Alice\s+│/, 'Name Alice left-aligned');
    like($clean[4], qr/│Bob\s+│/, 'Name Bob left-aligned');

    # Check that values are right-aligned
    like($clean[3], qr/│\s+100│/, 'Value 100 right-aligned');
    like($clean[4], qr/│\s+9│/, 'Value 9 right-aligned');
};

done_testing;
