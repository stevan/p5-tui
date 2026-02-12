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

# Helper to get column widths from a rendered line
sub get_column_widths {
    my $line = shift;
    $line = strip_ansi($line);
    $line =~ s/^│//;  # Remove left border
    $line =~ s/│$//;  # Remove right border
    my @cols = split /│/, $line;
    return map { length($_) } @cols;
}

subtest 'Fixed widths only' => sub {
    my $table = P5::TUI::Table->new(
        column_spec => [
            { name => 'A', width => 5, align => 1, color => {} },
            { name => 'B', width => 10, align => 1, color => {} },
            { name => 'C', width => 15, align => 1, color => {} }
        ],
        rows => [ ['1', '2', '3'] ]
    );

    my $lines = $table->draw(width => 50, height => 10);
    my @widths = get_column_widths($lines->[1]);  # Header row

    is($widths[0], 5, 'column A width is 5');
    is($widths[1], 10, 'column B width is 10');
    is($widths[2], 15, 'column C width is 15');
};

subtest 'Percentage widths only' => sub {
    my $table = P5::TUI::Table->new(
        column_spec => [
            { name => 'A', width => '50%', align => 1, color => {} },
            { name => 'B', width => '50%', align => 1, color => {} }
        ],
        rows => [ ['1', '2'] ]
    );

    # Total width 40 - 3 borders (│A│B│) = 37 content space
    # 50% of 37 = 18.5 -> 18
    my $lines = $table->draw(width => 40, height => 10);
    my @widths = get_column_widths($lines->[1]);

    is($widths[0], 18, 'column A is ~50% of available space');
    is($widths[1], 18, 'column B is ~50% of available space');
};

subtest 'Mixed fixed and percentage widths' => sub {
    my $table = P5::TUI::Table->new(
        column_spec => [
            { name => 'A', width => 10, align => 1, color => {} },      # Fixed
            { name => 'B', width => '50%', align => 1, color => {} },    # Percentage of remaining
            { name => 'C', width => '50%', align => 1, color => {} }     # Percentage of remaining
        ],
        rows => [ ['1', '2', '3'] ]
    );

    # Total width 60 - 4 borders = 56 content space
    # Fixed column A = 10, leaving 46 for percentages
    # B and C should each get ~23 (50% of 46)
    my $lines = $table->draw(width => 60, height => 10);
    my @widths = get_column_widths($lines->[1]);

    is($widths[0], 10, 'fixed column A width is 10');
    ok($widths[1] >= 22 && $widths[1] <= 24, 'percentage column B is ~50% of remaining');
    ok($widths[2] >= 22 && $widths[2] <= 24, 'percentage column C is ~50% of remaining');
};

subtest 'All percentage columns with different ratios' => sub {
    my $table = P5::TUI::Table->new(
        column_spec => [
            { name => 'A', width => '20%', align => 1, color => {} },
            { name => 'B', width => '30%', align => 1, color => {} },
            { name => 'C', width => '50%', align => 1, color => {} }
        ],
        rows => [ ['1', '2', '3'] ]
    );

    my $lines = $table->draw(width => 60, height => 10);
    my @widths = get_column_widths($lines->[1]);

    # With 60 total width - 4 borders = 56 content
    # 20% = 11.2 -> 11
    # 30% = 16.8 -> 16
    # 50% = 28 -> 28
    ok($widths[0] >= 10 && $widths[0] <= 12, 'column A is ~20%');
    ok($widths[1] >= 15 && $widths[1] <= 18, 'column B is ~30%');
    ok($widths[2] >= 27 && $widths[2] <= 29, 'column C is ~50%');
};

done_testing;
