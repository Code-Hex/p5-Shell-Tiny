package Shell::Tiny::Executor;
use strict;
use warnings;

use Shell::Tiny::Node::SubShell;
use Shell::Tiny::Node::Command;
use Shell::Tiny::Node::Pipe;
use Shell::Tiny::Node::And;

sub new {
    my $class = shift;
    return bless +{}, $class;
}

sub walk {
    my $self     = shift;
    my $ast      = shift;
    my $callback = shift;

}

=pod
$self->dump($ast, 0)
=cut

sub dump {
    my $self  = shift;
    my $ast   = shift;
    my $depth = shift;

    if (is_and($ast) || is_pipe($ast)) {
        printf "|%s %s\n", '----'x($depth+1), ref $ast;
        $self->dump($ast->left, $depth + 1) if $ast->left;
        $self->dump($ast->right, $depth + 1) if $ast->right;
        return;
    }
    if (is_grp($ast)) {
        die "Unexpected node" unless $ast->node;
        printf "|%s %s\n", '----'x($depth+1), ref $ast;
        $self->dump($ast->node, $depth + 1);
        return;
    }
    if (is_cmd($ast)) {
        printf "|%s %s (cmd=%s, args=%s)\n",
                '----'x($depth+1),
                ref $ast,
                $ast->command,
                @{ $ast->args } ? '[' . join(', ', @{ $ast->args }) . ']' : 'nothing';
        return;
    }
    die "Unexpected";
}

# utils
sub is_and  { ref($_[0]) =~ /Shell::Tiny::Node::And/      }
sub is_pipe { ref($_[0]) =~ /Shell::Tiny::Node::Pipe/     }
sub is_cmd  { ref($_[0]) =~ /Shell::Tiny::Node::Command/  }
sub is_grp  { ref($_[0]) =~ /Shell::Tiny::Node::SubShell/ }

1;