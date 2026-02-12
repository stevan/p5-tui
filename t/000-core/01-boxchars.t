use v5.38;
use utf8;
use Test::More;

BEGIN {
    use_ok('P5::TUI::BoxChars', qw(:all));
}

# Set UTF-8 for test output
binmode(STDOUT, ':encoding(UTF-8)');
binmode(STDERR, ':encoding(UTF-8)');

subtest 'Lines' => sub {
    is(BOX_H, '─', 'horizontal line');
    is(BOX_V, '│', 'vertical line');
};

subtest 'Corners' => sub {
    is(BOX_TL, '┌', 'top-left corner');
    is(BOX_TR, '┐', 'top-right corner');
    is(BOX_BL, '└', 'bottom-left corner');
    is(BOX_BR, '┘', 'bottom-right corner');
};

subtest 'T-junctions' => sub {
    is(BOX_T_DOWN,  '┬', 'T-junction pointing down');
    is(BOX_T_UP,    '┴', 'T-junction pointing up');
    is(BOX_T_RIGHT, '├', 'T-junction pointing right');
    is(BOX_T_LEFT,  '┤', 'T-junction pointing left');
};

subtest 'Cross' => sub {
    is(BOX_CROSS, '┼', 'four-way intersection');
};

subtest 'Can build simple box' => sub {
    my $box = BOX_TL . (BOX_H x 5) . BOX_TR . "\n"
            . BOX_V . (' ' x 5) . BOX_V . "\n"
            . BOX_BL . (BOX_H x 5) . BOX_BR;

    my @lines = split /\n/, $box;
    is($lines[0], '┌─────┐', 'top line');
    is($lines[1], '│     │', 'middle line');
    is($lines[2], '└─────┘', 'bottom line');
};

done_testing;
