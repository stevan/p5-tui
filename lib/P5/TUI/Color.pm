use v5.38;  # Designed for 5.42, testing on 5.38
use utf8;

package P5::TUI::Color;
use Exporter 'import';

our @EXPORT_OK = qw(colorize fg_code bg_code reset_code);

# ANSI color codes for 16 basic colors
my %FG_CODES = (
    black   => 30,
    red     => 31,
    green   => 32,
    yellow  => 33,
    blue    => 34,
    magenta => 35,
    cyan    => 36,
    white   => 37,

    bright_black   => 90,
    bright_red     => 91,
    bright_green   => 92,
    bright_yellow  => 93,
    bright_blue    => 94,
    bright_magenta => 95,
    bright_cyan    => 96,
    bright_white   => 97,
);

my %BG_CODES = (
    black   => 40,
    red     => 41,
    green   => 42,
    yellow  => 43,
    blue    => 44,
    magenta => 45,
    cyan    => 46,
    white   => 47,

    bright_black   => 100,
    bright_red     => 101,
    bright_green   => 102,
    bright_yellow  => 103,
    bright_blue    => 104,
    bright_magenta => 105,
    bright_cyan    => 106,
    bright_white   => 107,
);

sub fg_code($color) {
    return unless defined $color;
    return $FG_CODES{$color} // die "Unknown foreground color: $color";
}

sub bg_code($color) {
    return unless defined $color;
    return $BG_CODES{$color} // die "Unknown background color: $color";
}

sub reset_code() {
    return "\e[0m";
}

sub colorize($text, $fg = undef, $bg = undef) {
    return $text unless defined($fg) || defined($bg);

    my @codes;
    push @codes, fg_code($fg) if defined $fg;
    push @codes, bg_code($bg) if defined $bg;

    return $text unless @codes;

    my $code_str = join(';', @codes);
    return "\e[${code_str}m${text}\e[0m";
}

1;

__END__

=head1 NAME

P5::TUI::Color - ANSI color code utilities for terminal output

=head1 SYNOPSIS

    use v5.42;
    use P5::TUI::Color qw(colorize);

    # Simple foreground color
    say colorize("Hello", "red");

    # Foreground and background
    say colorize("Warning", "yellow", "black");

    # Bright colors
    say colorize("Error", "bright_red");

=head1 DESCRIPTION

This module provides utilities for applying ANSI color codes to terminal text.
It currently supports the 16 basic ANSI colors (8 standard + 8 bright variants)
for both foreground and background.

The API is designed to be extensible for future support of 256-color palette
and RGB/true color.

=head1 FUNCTIONS

=head2 colorize($text, $fg, $bg)

Applies color codes to the given text and returns the colorized string with
proper reset codes.

    my $colored = colorize("Hello", "green", "black");

Parameters:

=over 4

=item * C<$text> - The text to colorize

=item * C<$fg> - Foreground color name (optional)

=item * C<$bg> - Background color name (optional)

=back

Returns the text wrapped in ANSI color codes with automatic reset at the end.

=head2 fg_code($color)

Returns the ANSI code number for the given foreground color name.

    my $code = fg_code("red");  # Returns 31

=head2 bg_code($color)

Returns the ANSI code number for the given background color name.

    my $code = bg_code("blue");  # Returns 44

=head2 reset_code()

Returns the ANSI reset code (ESC[0m) to clear all formatting.

=head1 SUPPORTED COLORS

=head2 Standard Colors

black, red, green, yellow, blue, magenta, cyan, white

=head2 Bright Colors

bright_black, bright_red, bright_green, bright_yellow, bright_blue,
bright_magenta, bright_cyan, bright_white

=head1 FUTURE EXTENSIONS

The API is designed to support future extensions:

=over 4

=item * 256-color palette (0-255)

=item * RGB/true color (#RRGGBB or rgb(r,g,b))

=back

These will be added in future versions while maintaining backward compatibility.

=head1 REQUIRES

Perl 5.42 or later.

=cut
