use v5.38;
use utf8;
use Test::More;

BEGIN {
    use_ok('P5::TUI::Color', qw(colorize fg_code bg_code reset_code));
}

subtest 'Foreground codes' => sub {
    is(fg_code('black'),   30, 'black fg');
    is(fg_code('red'),     31, 'red fg');
    is(fg_code('green'),   32, 'green fg');
    is(fg_code('yellow'),  33, 'yellow fg');
    is(fg_code('blue'),    34, 'blue fg');
    is(fg_code('magenta'), 35, 'magenta fg');
    is(fg_code('cyan'),    36, 'cyan fg');
    is(fg_code('white'),   37, 'white fg');
};

subtest 'Bright foreground codes' => sub {
    is(fg_code('bright_black'),   90, 'bright black fg');
    is(fg_code('bright_red'),     91, 'bright red fg');
    is(fg_code('bright_green'),   92, 'bright green fg');
    is(fg_code('bright_yellow'),  93, 'bright yellow fg');
    is(fg_code('bright_blue'),    94, 'bright blue fg');
    is(fg_code('bright_magenta'), 95, 'bright magenta fg');
    is(fg_code('bright_cyan'),    96, 'bright cyan fg');
    is(fg_code('bright_white'),   97, 'bright white fg');
};

subtest 'Background codes' => sub {
    is(bg_code('black'),   40, 'black bg');
    is(bg_code('red'),     41, 'red bg');
    is(bg_code('green'),   42, 'green bg');
    is(bg_code('yellow'),  43, 'yellow bg');
    is(bg_code('blue'),    44, 'blue bg');
    is(bg_code('magenta'), 45, 'magenta bg');
    is(bg_code('cyan'),    46, 'cyan bg');
    is(bg_code('white'),   47, 'white bg');
};

subtest 'Bright background codes' => sub {
    is(bg_code('bright_black'),   100, 'bright black bg');
    is(bg_code('bright_red'),     101, 'bright red bg');
    is(bg_code('bright_green'),   102, 'bright green bg');
    is(bg_code('bright_yellow'),  103, 'bright yellow bg');
    is(bg_code('bright_blue'),    104, 'bright blue bg');
    is(bg_code('bright_magenta'), 105, 'bright magenta bg');
    is(bg_code('bright_cyan'),    106, 'bright cyan bg');
    is(bg_code('bright_white'),   107, 'bright white bg');
};

subtest 'Reset code' => sub {
    is(reset_code(), "\e[0m", 'reset code');
};

subtest 'Colorize function - foreground only' => sub {
    my $colored = colorize('Hello', 'red');
    is($colored, "\e[31mHello\e[0m", 'red text');

    $colored = colorize('World', 'bright_cyan');
    is($colored, "\e[96mWorld\e[0m", 'bright cyan text');
};

subtest 'Colorize function - foreground and background' => sub {
    my $colored = colorize('Error', 'white', 'red');
    is($colored, "\e[37;41mError\e[0m", 'white on red');

    $colored = colorize('Info', 'black', 'bright_yellow');
    is($colored, "\e[30;103mInfo\e[0m", 'black on bright yellow');
};

subtest 'Colorize function - no color' => sub {
    my $colored = colorize('Plain', undef, undef);
    is($colored, 'Plain', 'no color applied');
};

subtest 'Colorize function - background only' => sub {
    my $colored = colorize('Text', undef, 'blue');
    is($colored, "\e[44mText\e[0m", 'blue background only');
};

subtest 'Invalid color names' => sub {
    eval { fg_code('invalid') };
    like($@, qr/Unknown foreground color/, 'dies on invalid fg color');

    eval { bg_code('invalid') };
    like($@, qr/Unknown background color/, 'dies on invalid bg color');
};

done_testing;
