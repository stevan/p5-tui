use v5.38;
use utf8;
use Test::More;

BEGIN {
    use_ok('P5::TUI::TreeChars', qw(:all));
}

# Set UTF-8 for test output
binmode(STDOUT, ':encoding(UTF-8)');
binmode(STDERR, ':encoding(UTF-8)');

subtest 'Tree characters' => sub {
    is(TREE_BRANCH, '├──', 'branch with siblings below');
    is(TREE_LAST,   '└──', 'last branch (no more siblings)');
    is(TREE_VERT,   '│   ', 'vertical continuation with spaces');
    is(TREE_SPACE,  '    ', 'empty space (4 spaces)');
};

subtest 'Character lengths' => sub {
    is(length(TREE_BRANCH), 3, 'branch is 3 chars');
    is(length(TREE_LAST),   3, 'last is 3 chars');
    is(length(TREE_VERT),   4, 'vert is 4 chars (includes spaces)');
    is(length(TREE_SPACE),  4, 'space is 4 chars');
};

subtest 'Can build simple tree' => sub {
    my @tree = (
        'Root',
        TREE_BRANCH . 'Child 1',
        TREE_VERT . TREE_LAST . 'Grandchild',
        TREE_LAST . 'Child 2',
    );

    is($tree[0], 'Root', 'root node');
    is($tree[1], '├──Child 1', 'first child');
    is($tree[2], '│   └──Grandchild', 'nested grandchild');
    is($tree[3], '└──Child 2', 'last child');
};

done_testing;
