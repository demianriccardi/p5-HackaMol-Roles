#!/usr/bin/env perl
use warnings;
use strict;
use Test::More;
use Test::Warn;
use Test::Moose;
use HackaMol;        
use Moose::Util qw( ensure_all_roles );

my @attributes = qw(
  selections
);
my @methods = qw(
  select_group
);

my $mol = HackaMol->new->read_file_mol("t/lib/2sic.pdb");
ensure_all_roles($mol, 'HackaMol::Roles::SelectionRole');

map has_attribute_ok( $mol, $_ ), @attributes;
map can_ok (          $mol, $_ ), @methods;

done_testing();
