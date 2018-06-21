package Shell::Tiny;
use 5.008001;
use strict;
use warnings;
use Shell::Tiny::Parser;
use Shell::Tiny::Executor;

our $VERSION = "0.01";

sub new {
    my $class = shift;
    return bless +{
    }, $class;
}

sub parse {
    my $self = shift;
    my $str = shift;
    return Shell::Tiny::Parser->new->parse($str);
}

sub print {
    my $self = shift;
    my $ast = shift;
    Shell::Tiny::Executor->dump($ast, 0);
}


1;
__END__

=encoding utf-8

=head1 NAME

Shell::Tiny - It's new $module

=head1 SYNOPSIS

    use Shell::Tiny;

=head1 DESCRIPTION

Shell::Tiny is ...

=head1 LICENSE

Copyright (C) K.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

K E<lt>x00.x7f@gmail.comE<gt>

=cut

