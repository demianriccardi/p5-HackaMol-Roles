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


my $bldr = new HackaMol;
apply_all_roles($bldr, 'HackaMol::Roles::SerialRole');

map has_attribute_ok( $bldr, $_ ), @attributes;
map can_ok( $bldr, $_ ), @methods;

my $mol = $bldr->load("t/lib/1L2Y_mod123.sereal");
bless($mol,'HackaMol::Molecule');
my $mol2 = $bldr->clone($mol);

#they look the same
foreach (0 .. $mol2->tmax) {
  $mol->t($_);
  $mol2->t($_);
  cmp_ok(abs($mol->COM-$mol2->COM),'<','1E-10', "Cloned molecule same COM as a function of time: $_");
}

#make different
$mol->get_atoms(0)->change_symbol("Hg");

#they look the same
foreach (0 .. $mol2->tmax) {
  $mol->t($_);
  $mol2->t($_);
  cmp_ok(abs($mol->COM-$mol2->COM),'>','1E-1', "Cloned molecule is different after changing atom, COM as a function of time: $_");
}

done_testing();
