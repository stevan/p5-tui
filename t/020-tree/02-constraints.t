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

subtest 'Width truncation with ellipsis' => sub {
    my $tree = P5::TUI::Tree->new(
        root => {
            label => 'This is a very long root label that will be truncated',
            children => [
                { label => 'Short' },
                { label => 'Another very long child label that exceeds width' },
            ]
        }
    );

    my $lines = $tree->draw(width => 30, height => 10);
    my @clean = map { strip_ansi($_) } $lines->@*;

    like($clean[0], qr/\.\.\./, 'root truncated with ellipsis');
    like($clean[0], qr/^This is a very long/, 'root starts correctly');

    like($clean[2], qr/\.\.\./, 'long child truncated');
    unlike($clean[1], qr/\.\.\./, 'short child not truncated');
};

subtest 'Height overflow indicator' => sub {
    my $tree = P5::TUI::Tree->new(
        root => {
            label => 'Root',
            children => [
                { label => 'Child 1' },
                { label => 'Child 2' },
                { label => 'Child 3' },
                { label => 'Child 4' },
                { label => 'Child 5' },
                { label => 'Child 6' },
                { label => 'Child 7' },
                { label => 'Child 8' },
            ]
        }
    );

    # Height of 5 should show root + 3 children + overflow indicator
    my $lines = $tree->draw(width => 80, height => 5);
    my @clean = map { strip_ansi($_) } $lines->@*;

    is(scalar(@clean), 5, 'limited to 5 lines');
    is($clean[0], 'Root', 'root shown');
    like($clean[-1], qr/\.\.\./, 'overflow indicator at end');
};

subtest 'All content fits (no truncation or overflow)' => sub {
    my $tree = P5::TUI::Tree->new(
        root => {
            label => 'Root',
            children => [
                { label => 'A' },
                { label => 'B' },
            ]
        }
    );

    my $lines = $tree->draw(width => 80, height => 10);
    my @clean = map { strip_ansi($_) } $lines->@*;

    is(scalar(@clean), 3, 'three lines');
    ok(!grep(/\.\.\./, @clean), 'no ellipsis anywhere');
};

done_testing;
