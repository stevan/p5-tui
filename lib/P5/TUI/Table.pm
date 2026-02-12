use v5.38;  # Designed for 5.42, testing on 5.38
use utf8;
use experimental 'class';

class P5::TUI::Table {
    use P5::TUI::BoxChars qw(:all);
    use P5::TUI::Color qw(colorize);

    field $column_spec :param;
    field $rows :param;

    method draw(%args) {
        my $width = $args{width} // die "width parameter required";
        my $height = $args{height} // die "height parameter required";
        my @lines;

        # Calculate actual column widths
        my $col_widths = $self->_calculate_widths($width);

        # Determine if we should show headers
        my $has_headers = $self->_has_headers();

        # Build table structure
        if ($has_headers) {
            push @lines, $self->_render_top_border($col_widths);
            push @lines, $self->_render_header($col_widths);
            push @lines, $self->_render_separator($col_widths);
        } else {
            push @lines, $self->_render_top_border($col_widths);
        }

        # Calculate how many data rows we can fit
        my $header_lines = $has_headers ? 3 : 1;  # top border + header + separator OR just top border
        my $footer_lines = 1;  # bottom border
        my $available_rows = $height - $header_lines - $footer_lines;

        # Render data rows
        my $row_count = scalar $rows->@*;
        my $rows_to_render = $available_rows < $row_count ? $available_rows - 1 : $row_count;

        for my $i (0 .. $rows_to_render - 1) {
            push @lines, $self->_render_row($rows->[$i], $col_widths);
        }

        # Add overflow indicator if needed
        if ($rows_to_render < $row_count) {
            push @lines, $self->_render_overflow($col_widths);
        }

        # Bottom border
        push @lines, $self->_render_bottom_border($col_widths);

        return \@lines;
    }

    method _has_headers() {
        for my $col ($column_spec->@*) {
            return 1 if defined $col->{name} && $col->{name} ne '';
        }
        return 0;
    }

    method _calculate_widths($total_width) {
        my @widths;
        my $fixed_total = 0;
        my @percent_cols;

        # First pass: collect fixed widths and identify percentage columns
        for my $i (0 .. $column_spec->$#*) {
            my $col = $column_spec->[$i];
            my $w = $col->{width} // 10;

            if ($w =~ /^(\d+(?:\.\d+)?)%$/) {
                push @percent_cols, { idx => $i, percent => $1 };
                push @widths, 0;  # Placeholder
            } else {
                push @widths, $w;
                $fixed_total += $w;
            }
        }

        # Account for borders and separators: │ col │ col │
        # For N columns: 1 (left) + N-1 (separators) + 1 (right) = N+1 vertical bars
        my $border_overhead = scalar($column_spec->@*) + 1;
        my $available_for_content = $total_width - $border_overhead;
        my $remaining = $available_for_content - $fixed_total;

        # Second pass: calculate percentage-based widths
        for my $pc (@percent_cols) {
            my $w = int($remaining * $pc->{percent} / 100);
            $w = 1 if $w < 1;  # Minimum width of 1
            $widths[$pc->{idx}] = $w;
        }

        return \@widths;
    }

    method _render_top_border($widths) {
        my $line = BOX_TL;
        for my $i (0 .. $widths->$#*) {
            $line .= BOX_H x $widths->[$i];
            $line .= ($i < $widths->$#*) ? BOX_T_DOWN : BOX_TR;
        }
        return $line;
    }

    method _render_bottom_border($widths) {
        my $line = BOX_BL;
        for my $i (0 .. $widths->$#*) {
            $line .= BOX_H x $widths->[$i];
            $line .= ($i < $widths->$#*) ? BOX_T_UP : BOX_BR;
        }
        return $line;
    }

    method _render_separator($widths) {
        my $line = BOX_T_RIGHT;
        for my $i (0 .. $widths->$#*) {
            $line .= BOX_H x $widths->[$i];
            $line .= ($i < $widths->$#*) ? BOX_CROSS : BOX_T_LEFT;
        }
        return $line;
    }

    method _render_header($widths) {
        my $line = BOX_V;
        for my $i (0 .. $column_spec->$#*) {
            my $col = $column_spec->[$i];
            my $name = $col->{name} // '';
            my $width = $widths->[$i];
            my $align = $col->{align} // 1;
            my $fg = $col->{color}{fg} // undef;
            my $bg = $col->{color}{bg} // undef;

            my $text = $self->_fit_text($name, $width, $align);
            $text = colorize($text, $fg, $bg) if defined($fg) || defined($bg);

            $line .= $text . BOX_V;
        }
        return $line;
    }

    method _render_row($row, $widths) {
        my $line = BOX_V;
        for my $i (0 .. $column_spec->$#*) {
            my $col = $column_spec->[$i];
            my $value = $row->[$i] // '';
            my $width = $widths->[$i];
            my $align = $col->{align} // 1;
            my $fg = $col->{color}{fg} // undef;
            my $bg = $col->{color}{bg} // undef;

            my $text = $self->_fit_text($value, $width, $align);
            $text = colorize($text, $fg, $bg) if defined($fg) || defined($bg);

            $line .= $text . BOX_V;
        }
        return $line;
    }

    method _render_overflow($widths) {
        my $line = BOX_V;
        for my $i (0 .. $widths->$#*) {
            my $width = $widths->[$i];
            my $text = $self->_fit_text('...', $width, 0);  # Center the overflow indicator
            $line .= $text . BOX_V;
        }
        return $line;
    }

    method _fit_text($text, $width, $align) {
        # Get visual width (for now, assume 1 char = 1 width; TODO: handle wide chars)
        my $text_len = length($text);

        # Truncate if too long
        if ($text_len > $width) {
            if ($width > 1) {
                $text = substr($text, 0, $width - 1) . '…';
                return $text;
            } else {
                return '…';
            }
        }

        # Pad to width
        my $padding = $width - $text_len;

        if ($align == 1) {
            # Left align
            return $text . (' ' x $padding);
        } elsif ($align == -1) {
            # Right align
            return (' ' x $padding) . $text;
        } else {
            # Shouldn't happen based on our requirements, but default to left
            return $text . (' ' x $padding);
        }
    }
}

1;

__END__

=head1 NAME

P5::TUI::Table - Render data tables with Unicode box drawing

=head1 SYNOPSIS

    use v5.42;
    use utf8;
    use experimental 'class';
    use P5::TUI::Table;

    my $table = P5::TUI::Table->new(
        column_spec => [
            {
                name  => 'ID',
                width => 5,
                align => -1,  # Right-aligned
                color => { fg => 'cyan', bg => undef }
            },
            {
                name  => 'Name',
                width => '60%',  # Percentage of available space
                align => 1,      # Left-aligned
                color => { fg => 'white', bg => undef }
            },
            {
                name  => 'Status',
                width => '40%',
                align => 1,
                color => { fg => 'green', bg => undef }
            }
        ],
        rows => [
            [1, 'Alice', 'Active'],
            [2, 'Bob', 'Inactive'],
            [42, 'Charlie', 'Pending'],
        ]
    );

    binmode(STDOUT, ':encoding(UTF-8)');

    my $lines = $table->draw(width => 80, height => 20);
    say for $lines->@*;

=head1 DESCRIPTION

P5::TUI::Table provides a simple, composable way to render data tables using
Unicode box drawing characters. Tables are non-interactive and designed to be
rendered inline in your terminal output.

=head1 CONSTRUCTOR

=head2 new(%params)

Creates a new Table instance.

Required parameters:

=over 4

=item column_spec

An arrayref of hashrefs, where each hashref defines a column with:

=over 4

=item name

Column header text (can be empty string or undef to hide headers)

=item width

Either a fixed number (characters) or a percentage string (e.g., "50%").
Percentages are calculated from remaining space after fixed-width columns.

=item align

Text alignment: 1 for left-aligned, -1 for right-aligned

=item color

A hashref with C<fg> (foreground) and C<bg> (background) color names.
See L<P5::TUI::Color> for supported color names.

=back

=item rows

An arrayref of arrayrefs, where each inner arrayref represents a row of data.
Values should be strings and correspond to columns by position.

=back

=head1 METHODS

=head2 draw($width, $height)

Renders the table constrained to the given dimensions and returns an arrayref
of strings (one per line).

Parameters:

=over 4

=item width

Maximum width in characters (including borders)

=item height

Maximum height in lines (including borders and headers)

=back

Returns an arrayref of strings.

Behavior:

=over 4

=item * If column names are all empty/undef, headers are not rendered

=item * If content exceeds column width, it's truncated with ellipsis (…)

=item * If rows exceed available height, an overflow indicator (...) is shown

=back

=head1 REQUIRES

Perl 5.42 or later with experimental class feature enabled.

=head1 SEE ALSO

L<P5::TUI::BoxChars>, L<P5::TUI::Color>

=cut
