package P5::TUI::TreeTable;
use v5.38;
use utf8;
use experimental 'class';

=head1 NAME

P5::TUI::TreeTable - Table with tree structure in first column

=head1 SYNOPSIS

    use P5::TUI::TreeTable;

    # Format 1: Flat array with depth as first element
    my $tree = P5::TUI::TreeTable->new(
        format => 'flat',
        data => [
            [0, 'root', 'dir', '1024'],
            [1, 'home', 'dir', '512'],
            [2, 'user', 'dir', '256'],
            [1, 'etc', 'dir', '128'],
        ],
        column_spec => [...]
    );

    # Format 2: Nested structure with row data
    my $tree = P5::TUI::TreeTable->new(
        format => 'nested',
        data => {
            row => ['root', 'dir', '1024'],
            children => [
                {
                    row => ['home', 'dir', '512'],
                    children => [
                        { row => ['user', 'dir', '256'] }
                    ]
                },
                { row => ['etc', 'dir', '128'] }
            ]
        },
        column_spec => [...]
    );

=head1 DESCRIPTION

TreeTable combines tree visualization with tabular data. The tree
structure appears only in the first column using unicode box-drawing
characters, while all other columns remain perfectly aligned.

=cut

class P5::TUI::TreeTable {
    use P5::TUI::Table;

    field $column_spec :param;  # Table column specification
    field $data        :param;  # Tree data (flat or nested format)
    field $format      :param = 'flat';  # 'flat' or 'nested'

    # Unicode tree characters (only unicode, no ASCII)
    my $BRANCH   = '├─';   # Branch to sibling
    my $LAST     = '└─';   # Last child branch
    my $VERTICAL = '│ ';   # Continuation line
    my $SPACE    = '  ';   # Empty space
    my $NODE     = '●';    # Node marker

=head2 draw

    my $lines = $tree->draw(width => 100, height => 40);

Generates the tree table and returns array of rendered lines.
Accepts same parameters as P5::TUI::Table->draw().

=cut

    method draw(%args) {
        my $rows = $self->_generate_rows();

        my $table = P5::TUI::Table->new(
            column_spec => $column_spec,
            rows => $rows
        );

        return $table->draw(%args);
    }

=head2 _generate_rows

Internal method that dispatches to format-specific row generator.

=cut

    method _generate_rows() {
        if ($format eq 'flat') {
            return $self->_from_flat();
        } elsif ($format eq 'nested') {
            return $self->_from_nested();
        } else {
            die "Unknown format: $format (must be 'flat' or 'nested')";
        }
    }

=head2 _from_flat

Processes flat format: [[depth, col1, col2, ...], ...]

The depth (first element) determines tree structure. A row is the last
sibling if the next row has equal or lesser depth.

=cut

    method _from_flat() {
        my @rows;
        my @continuation_stack;  # Track which depth levels still have siblings

        for my $i (0 .. $data->$#*) {
            my ($depth, @cols) = $data->[$i]->@*;

            # Truncate stack to current depth (we've moved back up the tree)
            splice(@continuation_stack, $depth);

            # Determine if this is the last sibling at its level
            my $is_last = $self->_is_last_at_depth($i, $depth);

            # Build tree prefix
            my $prefix = '';

            # Add vertical lines or spaces for each ancestor level
            for my $level (0 .. $depth - 1) {
                $prefix .= $continuation_stack[$level] ? $VERTICAL : $SPACE;
            }

            # Add branch character (except for root)
            if ($depth > 0) {
                $prefix .= $is_last ? $LAST : $BRANCH;
            }

            # Add node marker
            $prefix .= $NODE;

            # Add row with prefix + columns
            push @rows, [$prefix, @cols];

            # Update continuation stack: this level continues if not last
            $continuation_stack[$depth] = !$is_last;
        }

        return \@rows;
    }

=head2 _is_last_at_depth

Determines if a row at given index/depth is the last sibling.

Scans forward to find the next node that is either:
  - A sibling (same depth) → not last
  - An ancestor (shallower depth) → we are last
  - End of data → we are last

Children (deeper depth) are skipped since they don't affect sibling status.

=cut

    method _is_last_at_depth($index, $depth) {
        # Last row in array is always last sibling
        return 1 if $index == $data->$#*;

        # Scan forward for next node at same or shallower depth
        for my $i ($index + 1 .. $data->$#*) {
            my $next_depth = $data->[$i][0];

            # Found a sibling at same depth - we're not last
            return 0 if $next_depth == $depth;

            # Found ancestor (moved back up tree) - we were last
            return 1 if $next_depth < $depth;

            # next_depth > $depth means it's a descendant, keep scanning
        }

        # Reached end of data - we're last
        return 1;
    }

=head2 _from_nested

Processes nested format: { row => [...], children => [...] }

Recursively traverses the tree structure, tracking ancestor
continuation state to generate correct tree prefixes.

=cut

    method _from_nested() {
        my @rows;
        $self->_traverse($data, 0, [], \@rows, 1);
        return \@rows;
    }

=head2 _traverse

Recursive traversal helper for nested format.

Arguments:
  - $node: Current node { row => [...], children => [...] }
  - $depth: Current depth level (0 = root)
  - $ancestors: Array of booleans indicating which ancestor levels continue
  - $rows: Output array reference to accumulate rows
  - $is_last: Boolean indicating if this node is last among siblings

=cut

    method _traverse($node, $depth, $ancestors, $rows, $is_last) {
        # Build tree prefix
        my $prefix = '';

        # Add vertical lines or spaces for each ancestor
        for my $has_continuation ($ancestors->@*) {
            $prefix .= $has_continuation ? $VERTICAL : $SPACE;
        }

        # Add branch character (except for root)
        if ($depth > 0) {
            $prefix .= $is_last ? $LAST : $BRANCH;
        }

        # Add node marker
        $prefix .= $NODE;

        # Add row to output
        push $rows->@*, [$prefix, $node->{row}->@*];

        # Process children if present
        if (my $children = $node->{children}) {
            # New ancestor state: add current node's continuation
            my @new_ancestors = ($ancestors->@*, !$is_last);

            # Traverse each child
            for my $i (0 .. $children->$#*) {
                my $child = $children->[$i];
                my $child_is_last = ($i == $children->$#*);

                $self->_traverse(
                    $child,
                    $depth + 1,
                    \@new_ancestors,
                    $rows,
                    $child_is_last
                );
            }
        }
    }
}

1;

=head1 INPUT FORMATS

=head2 Flat Format

Array of arrays where first element is depth (integer):

    [
        [0, 'root', 'dir', '1024'],     # depth 0
        [1, 'home', 'dir', '512'],      # depth 1 (child of root)
        [2, 'user', 'dir', '256'],      # depth 2 (child of home)
        [2, 'alice', 'dir', '128'],     # depth 2 (sibling of user)
        [1, 'etc', 'dir', '64'],        # depth 1 (sibling of home)
    ]

=head2 Nested Format

Hierarchical structure with row data and optional children:

    {
        row => ['root', 'dir', '1024'],
        children => [
            {
                row => ['home', 'dir', '512'],
                children => [
                    { row => ['user', 'dir', '256'] },
                    { row => ['alice', 'dir', '128'] }
                ]
            },
            { row => ['etc', 'dir', '64'] }
        ]
    }

=head1 COLUMN SPECIFICATION

The column_spec parameter follows P5::TUI::Table format, but the first
column will contain the tree structure. Example:

    column_spec => [
        { name => 'Tree', width => 15, align => 1, color => { fg => 'cyan' } },
        { name => 'Name', width => 20, align => 1, color => { fg => 'white' } },
        { name => 'Type', width => 10, align => 1, color => { fg => 'yellow' } },
    ]

=head1 AUTHOR

Generated for P5::TUI framework

=cut
