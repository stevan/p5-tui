use v5.38;  # Designed for 5.42, testing on 5.38
use utf8;
use experimental 'class';

class P5::TUI::Tree {
    use P5::TUI::TreeChars qw(:all);
    use P5::TUI::Color qw(colorize);
    use Term::ReadKey;

    field $root :param;

    method draw(%args) {
        my $width = $args{width} // die "width parameter required";
        my $height = $args{height} // die "height parameter required";

        # Get terminal dimensions for percentage calculations
        my ($term_width, $term_height) = $self->_get_terminal_size();

        # Parse width and height (support both numbers and percentages)
        $width = $self->_parse_dimension($width, $term_width);
        $height = $self->_parse_dimension($height, $term_height);

        my @lines;

        # Render the tree recursively
        $self->_render_node($root, '', 1, \@lines, $width);

        # Handle height overflow
        if (scalar(@lines) > $height) {
            @lines = @lines[0 .. $height - 2];
            push @lines, '...';
        }

        return \@lines;
    }

    method _render_node($node, $indent, $is_root, $lines, $width) {
        # $indent represents the indentation BEFORE the branch/label
        # For root node, indent is empty
        # For children, indent contains the continuation lines (│   or spaces)

        my $label = $node->{label} // '';
        my $fg = $node->{color}{fg} // undef;
        my $bg = $node->{color}{bg} // undef;

        # Build the full prefix (indent + connector if not root)
        my $full_line = $indent;
        if (!$is_root) {
            # This shouldn't happen - we handle this in recursion
            die "Non-root node rendered without proper handling";
        }

        # Calculate available width for label
        my $prefix_len = length($full_line);
        my $available_width = $width - $prefix_len;

        # Truncate label if needed
        my $display_label = $self->_truncate_text($label, $available_width);

        # Apply color if specified
        $display_label = colorize($display_label, $fg, $bg) if defined($fg) || defined($bg);

        # Add the line
        push $lines->@*, $full_line . $display_label;

        # Render children if they exist
        my $children = $node->{children} // [];
        return unless @$children;

        my $child_count = scalar(@$children);
        for my $i (0 .. $child_count - 1) {
            my $child = $children->[$i];
            my $is_last_child = ($i == $child_count - 1);

            # Build the connector (├── or └──)
            my $connector = $is_last_child ? TREE_LAST : TREE_BRANCH;

            # Render child's label with connector
            my $child_label = $child->{label} // '';
            my $child_fg = $child->{color}{fg} // undef;
            my $child_bg = $child->{color}{bg} // undef;

            my $child_line = $indent . $connector;
            my $child_avail = $width - length($child_line);
            my $child_display = $self->_truncate_text($child_label, $child_avail);
            $child_display = colorize($child_display, $child_fg, $child_bg)
                if defined($child_fg) || defined($child_bg);

            push $lines->@*, $child_line . $child_display;

            # Build indent for grandchildren
            my $grandchild_indent = $indent;
            if ($is_last_child) {
                $grandchild_indent .= TREE_SPACE;
            } else {
                $grandchild_indent .= TREE_VERT;
            }

            # Recursively render grandchildren
            my $grandchildren = $child->{children} // [];
            if (@$grandchildren) {
                $self->_render_children($grandchildren, $grandchild_indent, $lines, $width);
            }
        }
    }

    method _render_children($children, $indent, $lines, $width) {
        my $child_count = scalar(@$children);
        for my $i (0 .. $child_count - 1) {
            my $child = $children->[$i];
            my $is_last_child = ($i == $child_count - 1);

            # Build the connector (├── or └──)
            my $connector = $is_last_child ? TREE_LAST : TREE_BRANCH;

            # Render child's label with connector
            my $child_label = $child->{label} // '';
            my $child_fg = $child->{color}{fg} // undef;
            my $child_bg = $child->{color}{bg} // undef;

            my $child_line = $indent . $connector;
            my $child_avail = $width - length($child_line);
            my $child_display = $self->_truncate_text($child_label, $child_avail);
            $child_display = colorize($child_display, $child_fg, $child_bg)
                if defined($child_fg) || defined($child_bg);

            push $lines->@*, $child_line . $child_display;

            # Build indent for grandchildren
            my $grandchild_indent = $indent;
            if ($is_last_child) {
                $grandchild_indent .= TREE_SPACE;
            } else {
                $grandchild_indent .= TREE_VERT;
            }

            # Recursively render grandchildren
            my $grandchildren = $child->{children} // [];
            if (@$grandchildren) {
                $self->_render_children($grandchildren, $grandchild_indent, $lines, $width);
            }
        }
    }

    method _truncate_text($text, $width) {
        return '' if $width < 1;

        my $text_len = length($text);

        if ($text_len <= $width) {
            return $text;
        }

        # Truncate with ellipsis
        if ($width > 3) {
            return substr($text, 0, $width - 3) . '...';
        } elsif ($width > 1) {
            return substr($text, 0, $width - 1) . '…';
        } else {
            return '…';
        }
    }

    method _get_terminal_size() {
        # Try to get terminal size, fallback to sensible defaults
        my ($term_width, $term_height, $x_pixels, $y_pixels);

        eval {
            local $SIG{__WARN__} = sub {};  # Suppress Term::ReadKey warnings
            ($term_width, $term_height, $x_pixels, $y_pixels) = GetTerminalSize();
        };

        # Fallback to reasonable defaults if GetTerminalSize fails
        $term_width  //= 80;
        $term_height //= 24;

        return ($term_width, $term_height);
    }

    method _parse_dimension($value, $terminal_size) {
        # If it's a percentage string like "50%", calculate based on terminal size
        if ($value =~ /^(\d+(?:\.\d+)?)%$/) {
            my $percent = $1;
            return int($terminal_size * $percent / 100);
        }

        # Otherwise, treat as absolute number
        return $value;
    }
}

1;

__END__

=head1 NAME

P5::TUI::Tree - Render hierarchical tree structures with Unicode tree drawing

=head1 SYNOPSIS

    use v5.42;
    use utf8;
    use experimental 'class';
    use P5::TUI::Tree;

    my $tree = P5::TUI::Tree->new(
        root => {
            label => 'Root',
            color => { fg => 'cyan', bg => undef },
            children => [
                {
                    label => 'Child 1',
                    children => [
                        { label => 'Grandchild 1' },
                        { label => 'Grandchild 2' },
                    ]
                },
                {
                    label => 'Child 2',
                    color => { fg => 'green' }
                },
            ]
        }
    );

    binmode(STDOUT, ':encoding(UTF-8)');

    my $lines = $tree->draw(width => 80, height => 20);
    say for $lines->@*;

=head1 DESCRIPTION

P5::TUI::Tree provides a simple way to render hierarchical tree structures
using Unicode tree drawing characters. Trees are non-interactive and designed
to be rendered inline in your terminal output.

=head1 CONSTRUCTOR

=head2 new(%params)

Creates a new Tree instance.

Required parameters:

=over 4

=item root

A hashref representing the root node of the tree. Each node can have:

=over 4

=item label

The text to display for this node (required)

=item color

Optional hashref with C<fg> (foreground) and C<bg> (background) color names.
See L<P5::TUI::Color> for supported color names.

=item children

Optional arrayref of child nodes (each is also a hashref with the same structure)

=back

=back

=head1 METHODS

=head2 draw(width => $width, height => $height)

Renders the tree constrained to the given dimensions and returns an arrayref
of strings (one per line).

Parameters:

=over 4

=item width

Maximum width in characters. Can be:

=over 4

=item * An absolute number: C<80>

=item * A percentage of terminal width: C<'80%'>

=back

=item height

Maximum height in lines. Can be:

=over 4

=item * An absolute number: C<20>

=item * A percentage of terminal height: C<'50%'>

=back

=back

Returns an arrayref of strings.

Behavior:

=over 4

=item * Labels are truncated with ellipsis (...) if they exceed available width

=item * If the tree exceeds available height, an overflow indicator (...) is shown

=item * Uses Unicode tree characters: ├── └── │

=back

=head1 EXAMPLE OUTPUT

    Root
    ├──Child 1
    │   ├──Grandchild 1
    │   └──Grandchild 2
    ├──Child 2
    └──Child 3

=head1 REQUIRES

Perl 5.42 or later with experimental class feature enabled.

Required modules:

=over 4

=item * L<Term::ReadKey> - For terminal size detection (percentage dimensions)

=item * L<P5::TUI::TreeChars> - Unicode tree drawing characters

=item * L<P5::TUI::Color> - ANSI color support

=back

=head1 SEE ALSO

L<P5::TUI::TreeChars>, L<P5::TUI::Color>, L<P5::TUI::Table>

=cut
