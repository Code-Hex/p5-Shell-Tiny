package Shell::Tiny::Node::SubShell;
use strict;
use warnings;

use Shell::Tiny::Constants::Type;
use Shell::Tiny::Constants::Kind;

sub make {
    my $class = shift;
    my $node  = shift;
    return bless +{
        node => $node,
        type => Shell::Tiny::Constants::Type::GROUP,
        kind => Shell::Tiny::Constants::Kind::GROUP,
    }, $class;
}

sub node { $_[0]->{node} }
sub type { $_[0]->{type} }
sub kind { $_[0]->{kind} }

1;