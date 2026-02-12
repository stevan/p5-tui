use v5.38;  # Designed for 5.42, testing on 5.38
use utf8;

package P5::TUI::TreeChars;
use Exporter 'import';

our @EXPORT_OK = qw(
    TREE_BRANCH TREE_LAST TREE_VERT TREE_SPACE
);

our %EXPORT_TAGS = (
    all => \@EXPORT_OK,
);

# Tree drawing characters

# Branch with more siblings below: ├──
use constant TREE_BRANCH => "\N{BOX DRAWINGS LIGHT VERTICAL AND RIGHT}"
                          . "\N{BOX DRAWINGS LIGHT HORIZONTAL}"
                          . "\N{BOX DRAWINGS LIGHT HORIZONTAL}";

# Last branch (no more siblings): └──
use constant TREE_LAST => "\N{BOX DRAWINGS LIGHT UP AND RIGHT}"
                        . "\N{BOX DRAWINGS LIGHT HORIZONTAL}"
                        . "\N{BOX DRAWINGS LIGHT HORIZONTAL}";

# Vertical line for continuation: │  (with spaces)
use constant TREE_VERT => "\N{BOX DRAWINGS LIGHT VERTICAL}"
                        . "   ";

# Empty space (no vertical line):     (4 spaces)
use constant TREE_SPACE => "    ";

1;

__END__

=head1 NAME

P5::TUI::TreeChars - Unicode tree drawing character constants

=head1 SYNOPSIS

    use v5.42;
    use utf8;
    use P5::TUI::TreeChars qw(:all);

    binmode(STDOUT, ':encoding(UTF-8)');

    # Draw a simple tree
    say 'Root';
    say TREE_BRANCH . 'Child 1';
    say TREE_VERT . TREE_LAST . 'Grandchild';
    say TREE_LAST . 'Child 2';

=head1 DESCRIPTION

This module provides constants for Unicode tree drawing characters, used for
rendering hierarchical tree structures in terminal output.

=head1 CONSTANTS

=over 4

=item TREE_BRANCH

Branch with more siblings below: ├──

=item TREE_LAST

Last branch (no more siblings): └──

=item TREE_VERT

Vertical line for continuation: │   (with trailing spaces)

=item TREE_SPACE

Empty space (no vertical line): four spaces

=back

=head1 EXPORTS

All constants can be exported individually or all at once with the C<:all> tag.

=head1 EXAMPLE TREE

    Root
    ├── Child 1
    │   ├── Grandchild 1
    │   └── Grandchild 2
    ├── Child 2
    └── Child 3

=head1 REQUIRES

Perl 5.42 or later with UTF-8 support enabled.

=head1 SEE ALSO

L<P5::TUI::Tree>, L<P5::TUI::BoxChars>

=cut
