#!/usr/bin/env perl

use warnings;
use strict;
use HackaMol;

my $mol = HackaMol->new->read_file_mol("t/lib/1L2Y_mod123.pdb");
apply_all_roles( $mol, 'HackaMol::Roles::SerialRole' );

$mol->store("t/lib/1L2Y_mod123.sereal");
$mol->serial_format("YAML");
$mol->store("t/lib/1L2Y_mod123.yaml");

