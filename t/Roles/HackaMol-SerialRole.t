#!/usr/bin/env perl

use warnings;
use strict;
use Test::More;
use Test::Warn;
use Test::Output;
use Test::Fatal qw(lives_ok dies_ok);
use Moose::Util qw(apply_all_roles);
use Test::Moose;
use HackaMol;

my @attributes = qw(
  serial_format
  serial_carplevel
  serial_overwrite
  serial_fn
);
my @methods = qw(
  has_serial_fn
  freeze
  thaw
  clone
  store
  load
);

my $mol = HackaMol->new->read_file_mol("t/lib/1L2Y_mod123.pdb");
apply_all_roles($mol, 'HackaMol::Roles::SerialRole');

map has_attribute_ok( $mol, $_ ), @attributes;
map can_ok( $mol, $_ ), @methods;

my $mol2 = $mol->clone;

foreach (0 .. $mol->tmax) {
  $mol->t($_);
  $mol2->t($_);
  cmp_ok(abs($mol->COM-$mol2->COM),'<','1E-10', "COM as a function of time: $_");

}

done_testing();
