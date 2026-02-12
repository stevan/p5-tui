use v5.38;  # Designed for 5.42, testing on 5.38
use utf8;

package P5::TUI::BoxChars;
use Exporter 'import';

our @EXPORT_OK = qw(
    BOX_H BOX_V
    BOX_TL BOX_TR BOX_BL BOX_BR
    BOX_T_DOWN BOX_T_UP BOX_T_RIGHT BOX_T_LEFT
    BOX_CROSS
);

our %EXPORT_TAGS = (
    all => \@EXPORT_OK,
);

# Single-line box drawing characters (U+2500 range)

# Lines
use constant BOX_H => "\N{BOX DRAWINGS LIGHT HORIZONTAL}";      # ─
use constant BOX_V => "\N{BOX DRAWINGS LIGHT VERTICAL}";        # │

# Corners
use constant BOX_TL => "\N{BOX DRAWINGS LIGHT DOWN AND RIGHT}"; # ┌
use constant BOX_TR => "\N{BOX DRAWINGS LIGHT DOWN AND LEFT}";  # ┐
use constant BOX_BL => "\N{BOX DRAWINGS LIGHT UP AND RIGHT}";   # └
use constant BOX_BR => "\N{BOX DRAWINGS LIGHT UP AND LEFT}";    # ┘

# T-junctions
use constant BOX_T_DOWN  => "\N{BOX DRAWINGS LIGHT DOWN AND HORIZONTAL}";  # ┬
use constant BOX_T_UP    => "\N{BOX DRAWINGS LIGHT UP AND HORIZONTAL}";    # ┴
use constant BOX_T_RIGHT => "\N{BOX DRAWINGS LIGHT VERTICAL AND RIGHT}";   # ├
use constant BOX_T_LEFT  => "\N{BOX DRAWINGS LIGHT VERTICAL AND LEFT}";    # ┤

# Cross
use constant BOX_CROSS => "\N{BOX DRAWINGS LIGHT VERTICAL AND HORIZONTAL}"; # ┼

1;

__END__

=head1 NAME

P5::TUI::BoxChars - Unicode box drawing character constants

=head1 SYNOPSIS

    use v5.42;
    use utf8;
    use P5::TUI::BoxChars qw(:all);

    binmode(STDOUT, ':encoding(UTF-8)');

    # Draw a simple box
    say BOX_TL . (BOX_H x 10) . BOX_TR;
    say BOX_V . (' ' x 10) . BOX_V;
    say BOX_BL . (BOX_H x 10) . BOX_BR;

=head1 DESCRIPTION

This module provides constants for Unicode box drawing characters, specifically
the single-line box drawing set from the U+2500 range.

=head1 CONSTANTS

=head2 Lines

=over 4

=item BOX_H

Horizontal line: ─

=item BOX_V

Vertical line: │

=back

=head2 Corners

=over 4

=item BOX_TL

Top-left corner: ┌

=item BOX_TR

Top-right corner: ┐

=item BOX_BL

Bottom-left corner: └

=item BOX_BR

Bottom-right corner: ┘

=back

=head2 T-junctions

=over 4

=item BOX_T_DOWN

T-junction pointing down: ┬

=item BOX_T_UP

T-junction pointing up: ┴

=item BOX_T_RIGHT

T-junction pointing right: ├

=item BOX_T_LEFT

T-junction pointing left: ┤

=back

=head2 Cross

=over 4

=item BOX_CROSS

Four-way intersection: ┼

=back

=head1 EXPORTS

All constants can be exported individually or all at once with the C<:all> tag.

=head1 REQUIRES

Perl 5.42 or later with UTF-8 support enabled.

=cut
