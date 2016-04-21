#!/usr/bin/env perl
use warnings;
use strict;
use Test::More;
use Test::Warn;
use Test::Moose;
use HackaMol;
use Moose::Util qw( ensure_all_roles );

my @attributes = qw(
);
my @methods = qw(
  apply_pdbstr_symops
);

my $bldr = HackaMol->new;
#my $mol = HackaMol->new->read_file_mol("t/lib/2sic.pdb");
ensure_all_roles( $bldr, 'HackaMol::Roles::SymopRole' );

map has_attribute_ok( $bldr, $_ ), @attributes;
map can_ok( $bldr, $_ ), @methods;

done_testing();
