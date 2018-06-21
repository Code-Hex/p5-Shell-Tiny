package Shell::Tiny::Constants::Type;
use strict;
use warnings;
use parent qw/Exporter/;

our @EXPORT_OK = qw(
    ROOT
    COMMAND
    PIPE
    AND
    GROUP
);

use constant {
    ROOT    => 0,
    COMMAND => 1,
    PIPE    => 2,
    AND     => 3,
    GROUP   => 4,
};

1;