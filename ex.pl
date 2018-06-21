use strict;
use warnings;
use utf8;
use Data::Dumper;
use FindBin;
BEGIN { unshift @INC, "$FindBin::Bin/lib" }

use Shell::Tiny;

my $sh = Shell::Tiny->new;
my $ast = $sh->parse("(echo -n hello) | cat -n | pbcopy && pbpaste");
$sh->print($ast);
#print Dumper $sh;