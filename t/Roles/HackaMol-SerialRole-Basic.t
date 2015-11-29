#!/usr/bin/env perl

use warnings;
use strict;
use Test::More;
use Test::Moose;
use Moose::Util qw(apply_all_roles);
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

is($bldr->serial_format, 'SEREAL', 'default serial_format: SEREAL');
$bldr->serial_format('YAML');
is($bldr->serial_format, 'YAML', 'change serial_format: YAML');
is($bldr->serial_carplevel, 0, 'serial_carplevel default: 0');
is($bldr->serial_overwrite, 0, 'serial_overwrite default: 0');
isnt($bldr->serial_fn, 'no filename');
$bldr->serial_fn("test.yaml");
is($bldr->serial_fn->stringify, 'test.yaml', 'set a filename');

done_testing();
