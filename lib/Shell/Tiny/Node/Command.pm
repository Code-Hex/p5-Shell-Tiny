package Shell::Tiny::Node::Command;
use strict;
use warnings;

use Shell::Tiny::Constants::Type;
use Shell::Tiny::Constants::Kind;

sub make {
    my $class    = shift;
    my $command  = shift;
    my @args     = @_;
    return bless +{
        command => $command,
        args    => [ @args ],
        type    => Shell::Tiny::Constants::Type::COMMAND,
        kind    => Shell::Tiny::Constants::Kind::COMMAND,
    }, $class;
}

sub command { $_[0]->{command} }
sub args    { $_[0]->{args}    }
sub type    { $_[0]->{type}    }
sub kind    { $_[0]->{kind}    }

1;