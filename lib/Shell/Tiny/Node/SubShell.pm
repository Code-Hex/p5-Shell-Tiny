package Shell::Tiny::Node::SubShell;
use strict;
use warnings;

use Shell::Tiny::Constants::Type;
use Shell::Tiny::Constants::Kind;

sub make {
    my $class = shift;
    my $node  = shift;
    $node->set_parent(+{
        type => Shell::Tiny::Constants::Type::GROUP,
        kind => Shell::Tiny::Constants::Kind::GROUP,
    });
    return bless +{
        node => $node,
        type => Shell::Tiny::Constants::Type::GROUP,
        kind => Shell::Tiny::Constants::Kind::GROUP,
        parent => +{
            type  => Shell::Tiny::Constants::Type::ROOT,
            kind  => Shell::Tiny::Constants::Kind::ROOT,
        }
    }, $class;
}

sub set_parent { $_[0]->{parent} = $_[1] }

sub node    { $_[0]->{node}   }
sub type    { $_[0]->{type}   }
sub kind    { $_[0]->{kind}   }
sub parent  { $_[0]->{parent} }

1;