package Shell::Tiny::Executor;
use strict;
use warnings;

use POSIX ":sys_wait_h";

use Shell::Tiny::Node::SubShell;
use Shell::Tiny::Node::Command;
use Shell::Tiny::Node::Pipe;
use Shell::Tiny::Node::And;

sub new {
    my $class = shift;
    return bless +{
        stdin     => \*STDIN,
        stdout    => \*STDOUT,
        commands  => +[],
    }, $class;
}

sub traverse {
    my $self = shift;
    my $ast  = shift;
    if (is_pipe($ast)) {
        $self->traverse($ast->left) if $ast->left;
        $self->traverse($ast->right) if $ast->right;
        return if parent_is_pipe($ast);
        $self->execute;
        return;
    }
    if (is_and($ast)) {
        $self->traverse($ast->left) if $ast->left;
        $self->traverse($ast->right) if $ast->right;
        return;
    }
    if (is_grp($ast)) {
        die "Unexpected node" unless $ast->node;
        $self->traverse($ast->node);
        return;
    }
    if (is_cmd($ast)) {
        $self->append($ast->command, @{ $ast->args });
        $self->execute if parent_is_root($ast);
        return;
    }
    die "Unexpected";
}

sub append {
    my $self = shift;
    push @{ $self->{commands} }, [ @_ ];
}

sub clear {
    my $self = shift;
    $self->{commands} = +[];
}

use Data::Dumper;

sub execute {
    my $self = shift;
    my $commands = $self->{commands};
    my $pipes = $self->pipes;
    print Dumper $pipes;
    print Dumper $commands;
    for (my $i = 0; $i < @{ $self->{commands} }; $i++) {
        my $cmd = $self->{commands}->[$i];
        if (my $pid = fork) {
            close $pipes->[$i + 1]{writer}; # next out handle
            close $pipes->[$i]{reader}; # in handle
        } else {
            defined $pid or die "Could not fork: ".$!;
            close $pipes->[$i]{writer}; # out handle
            close $pipes->[$i + 1]{reader}; # next in handle

            open STDIN, '<&', $pipes->[$i]{reader}; # in handle
            open STDOUT, '>&', $pipes->[$i + 1]{writer}; # next out handle
            open STDERR, '>&', $pipes->[$i + 1]{writer}; # next out handle

            exec @$cmd;
        }
    }
    1 while wait != -1;
}

sub pipes {
    my $self = shift;
    my $commands = $self->{commands};
    my @pipes;
    for (my $i = 1; $i <= @$commands; $i++) {
        pipe my ($reader, $writer);
        select $writer;
        $| = 1;
        select STDOUT;
        if ($i == 1) {
            push @pipes, +{
                reader => *STDIN,
                writer => $writer,
            }, +{
                reader => $reader,
                writer => *STDOUT,
            };
        } else {
            $pipes[$i - 1]->{writer} = $writer;
            push @pipes, +{
                reader => $reader,
                writer => *STDOUT,
            };
        }
    }
    return \@pipes;
}

sub dump {
    my $self  = shift;
    my $ast   = shift;
    my $depth = shift;

    if (is_pipe($ast)) {
        printf "%s %s\n", '|----'x($depth+1), ref $ast;
        $self->dump($ast->left, $depth + 1) if $ast->left;
        $self->dump($ast->right, $depth + 1) if $ast->right;
        return;
    }
    if (is_and($ast)) {
        printf "%s %s\n", '|----'x($depth+1), ref $ast;
        $self->dump($ast->left, $depth + 1) if $ast->left;
        $self->dump($ast->right, $depth + 1) if $ast->right;
        return;
    }
    if (is_grp($ast)) {
        die "Unexpected node" unless $ast->node;
        printf "%s %s\n", '|----'x($depth+1), ref $ast;
        $self->dump($ast->node, $depth + 1);
        return;
    }
    if (is_cmd($ast)) {
        printf "%s %s (cmd=%s, args=%s)\n",
                '|----'x($depth+1),
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

sub parent_is_root { $_[0]->parent->{type} == Shell::Tiny::Constants::Type::ROOT     }
sub parent_is_and  { $_[0]->parent->{type} == Shell::Tiny::Constants::Type::AND      }
sub parent_is_pipe { $_[0]->parent->{type} == Shell::Tiny::Constants::Type::PIPE     }
sub parent_is_cmd  { $_[0]->parent->{type} == Shell::Tiny::Constants::Type::COMMAND  }
sub parent_is_grp  { $_[0]->parent->{type} == Shell::Tiny::Constants::Type::GROUP    }

sub make_pipe {
    pipe my ($in, $out);

    # same $out->autoflush(1) in IO::Handle where select to select :D
    select $out;
    $| = 1;
    select STDOUT;

    return +{
        in  => $in,
        out => $out
    };
}

1;