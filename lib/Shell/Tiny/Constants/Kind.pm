package Shell::Tiny::Constants::Kind;
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
    ROOT    => 'ROOT',
    COMMAND => 'COMMAND',
    PIPE    => 'PIPE',
    AND     => 'AND',
    GROUP   => 'GROUP',
};

1;