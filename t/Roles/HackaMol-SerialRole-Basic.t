#!/usr/bin/env perl

use warnings;
use strict;
use Test::More;
use Test::Warn;
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
apply_all_roles( $bldr, 'HackaMol::Roles::SerialRole' );

map has_attribute_ok( $bldr, $_ ), @attributes;
map can_ok( $bldr, $_ ), @methods;

is( $bldr->serial_format,    'SEREAL', 'default serial_format: SEREAL' );
is( $bldr->serial_carplevel, 0,        'serial_carplevel default: 0' );
is( $bldr->serial_overwrite, 0,        'serial_overwrite default: 0' );
isnt( $bldr->serial_fn, 'no filename' );
$bldr->serial_fn("test.yaml");
is( $bldr->serial_fn->stringify, 'test.yaml', 'set a filename' );
is( $bldr->freeze,       0, 'freeze without argument returns 0' );
is( $bldr->thaw,         0, 'thaw without argument returns 0' );
is( $bldr->clone,        0, 'clone without argument returns 0' );
is( $bldr->store,        0, '0, store without two arguments returns 0' );
is( $bldr->store($bldr), 0, '1, store without two arguments returns 0' );
is( $bldr->store( $bldr, $bldr, $bldr ),
    0, '3, store without two arguments returns 0' );
is( $bldr->load,        0, '0, store without two arguments returns 0' );
is( $bldr->load($bldr), 0, '1, store without two arguments returns 0' );
is( $bldr->load( $bldr, $bldr, $bldr ),
    0, '3, store without two arguments returns 0' );

my $format = 'foo';
$bldr->serial_format($format);
is( $bldr->serial_format, $format, "set serial_format: $format" );
my $struct = $bldr->freeze($bldr);
is( $struct, 0, 'unsupported serial format thaws to 0' );
my $bldr2 = $bldr->thaw($struct);
is( $bldr2, 0, 'unsupported serial format thaws to 0' );

$bldr->serial_format("YAML");
my $store0 = $bldr->store('test.yaml',$bldr);
is( $store0, 1, 'store returns one if made it to the end' );
my $store1 = $bldr->store('test.yaml',$bldr);
is( $store1, 0, 'store returns zero if file exists and overwrite(0)' );

#test warnings
$bldr->serial_format("foo");
$bldr->serial_carplevel(1);

warning_is { $bldr->clone } (
    "serial_clone> must pass one object as argument; return 0",
    "carp: clone arguments"
);
warning_is { $bldr->store } (
    "serial_store> must pass two arguments: filename and object; return 0",
    "carp: store arguments"
);
warning_is { $bldr->load } (
    "serial_load> must pass two arguments: filename and object class; return 0",
    "carp: load arguments"
);
warning_is { $bldr->freeze } (
    "serial_freeze> must pass one object as argument; return 0",
    "carp: freeze arguments"
);
warning_is { $bldr->thaw } (
    "serial_thaw> must pass one object as argument; return 0",
    "carp: thaw arguments"
);
warning_is { $bldr->freeze($bldr) } (
    "return 0; self.serial_format is not supported: $format",
    "carp: freeze format unsupported"
);
warning_is { $bldr->thaw($struct) } (
    "return 0; self.serial_format is not supported: $format",
    "carp: thaw format unsupported"
);

$bldr->serial_format("YAML");
warning_is {$bldr->store('test.yaml',$bldr)} (
    "test.yaml exists.  set self.serial_overwrite(1) to overwrite",
    "carp: file exists and overwrite(0)"
);
$bldr->serial_overwrite(1);
warning_is {$store1 = $bldr->store('test.yaml',$bldr)} (
    "overwriting test.yaml",
    "carp: when overwriting file"
);

is( $store1, 1, 'overwrite successful' );
unlink('test.yaml');

done_testing();
