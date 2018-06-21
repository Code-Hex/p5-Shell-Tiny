package Shell::Tiny::Node::Pipe;
use strict;
use warnings;

use Shell::Tiny::Constants::Type;
use Shell::Tiny::Constants::Kind;

sub make {
    my $class = shift;
    my $left  = shift;
    my $right = shift;
    return bless +{
        left  => $left,
        right => $right,
        type  => Shell::Tiny::Constants::Type::PIPE,
        kind  => Shell::Tiny::Constants::Kind::PIPE,
    }, $class;
}

sub left  { $_[0]->{left}  }
sub type  { $_[0]->{type}  }
sub kind  { $_[0]->{kind}  }
sub right { $_[0]->{right} }

1;