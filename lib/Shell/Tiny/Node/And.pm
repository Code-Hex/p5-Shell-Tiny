package Shell::Tiny::Node::And;
use strict;
use warnings;

use Shell::Tiny::Constants::Type;
use Shell::Tiny::Constants::Kind;

sub make {
    my $class = shift;
    my $left  = shift;
    my $right = shift;
    $left->set_parent(+{
        type  => Shell::Tiny::Constants::Type::AND,
        kind  => Shell::Tiny::Constants::Kind::AND,
    });
    $right->set_parent(+{
        type  => Shell::Tiny::Constants::Type::AND,
        kind  => Shell::Tiny::Constants::Kind::AND,
    });
    return bless +{
        left  => $left,
        right => $right,
        type  => Shell::Tiny::Constants::Type::AND,
        kind  => Shell::Tiny::Constants::Kind::AND,
        parent => +{
            type  => Shell::Tiny::Constants::Type::ROOT,
            kind  => Shell::Tiny::Constants::Kind::ROOT,
        }
    }, $class;
}

sub set_parent { $_[0]->{parent} = $_[1] }

sub left   { $_[0]->{left}    }
sub type   { $_[0]->{type}    }
sub kind   { $_[0]->{kind}    }
sub right  { $_[0]->{right}   }
sub parent { $_[0]->{parent}  }

1;