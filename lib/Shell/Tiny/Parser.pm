package Shell::Tiny::Parser;

=pod
WORD: [a-zA-Z0-9_-]+
SHLL: <GROP> | <PIPE> | <WORD>
PIPE: <WORD> '|' <PIPE> | <WORD> '|' <WORD>
ANDC: <WORD> '&&' <ANDC> | <WORD> '&&' <GROP> | <WORD> '&&' <WORD>
GROP: '(' <SHLL> ')'
=cut

use strict;
use warnings;

use Shell::Tiny::Node::SubShell;
use Shell::Tiny::Node::Command;
use Shell::Tiny::Node::Pipe;
use Shell::Tiny::Node::And;

sub new {
    my $class = shift;
    return bless +{
        utf8         => 0,
        allow_nonref => 0,
        max_size     => 0,
    } => $class;
}

sub parse {
    my ($self, $content) = @_;
    $content =~ s!\r\n?!\n!mg; # normalize linefeed

    $self->_parse() for $content;

    return $self->{root};
}

sub _parse {
    my $self = shift;

    $self->{root} = $self->_parse_shell();
    return if m!\G(?:\s*|#.*$/)*\z!msgc;
    $self->_error('Syntax Error');
}

sub _parse_shell {
    my $self = shift;

    my $left;
    goto RIGHT if $left = $self->_parse_sub_shell();
    goto RIGHT if $left = $self->_parse_pipe();
    return;
RIGHT:
    if (my $right = $self->_parse_and()) {
        return Shell::Tiny::Node::And->make($left, $right);
    }

    return $left;
}

sub _parse_sub_shell {
    my $self = shift;
    if (/\G(?:\s*)?\((?:\s*)?/mgc) {
        return unless my $shell = $self->_parse_shell();
        if (/\G(?:\s*)?\)(?:\s*)?/mgc) {
            return Shell::Tiny::Node::SubShell->make($shell);
        }
    }
    return;
}

sub _parse_pipe {
    my $self = shift;

    my $left = $self->_parse_identifier();
    return $left unless /\G(?:\s*)?\|(?:\s*)?/mgc;

    if (my $right = $self->_parse_pipe) {
        return Shell::Tiny::Node::Pipe->make($left, $right);
    }

    return;
}

sub _parse_and {
    my $self = shift;

    return unless /\G(?:\s*)?&&(?:\s*)?/mgc;

    if (my $right = $self->_parse_shell) {
        return $right;
    }
 
    return;
}

sub _parse_identifier {
    my $self = shift;
    if (/\G(?:\s*)?([a-zA-Z_-][0-9a-zA-Z_-]*)(?:\s*)?/mgc) {
        my $command = $1;
        my @args = /\G(?:\s*)?([a-zA-Z_-][0-9a-zA-Z_-]*)(?:\s*)?/gc;
        return Shell::Tiny::Node::Command->make($command, @args);
    }
    return;
}

#sub _make_info {
#    my $self = shift;
#    my %info = @_;
#    return +{
#        type => $info{type},
#        node => $info{node},
#        line => 
#    }
#}

sub _error {
    my ($self, $msg) = @_;

    my $src   = $_;
    my $line  = 1;
    my $start = pos $src || 0;
    while ($src =~ /$/smgco and pos $src <= pos) {
        $start = pos $src;
        $line++;
    }
    my $end = pos $src;
    my $len = pos() - $start;
    $len-- if $len > 0;

    my $trace = join "\n",
        "${msg}: line:$line",
        substr($src, $start || 0, $end - $start),
        (' ' x $len) . '^';
    die $trace, "\n";
}

1;