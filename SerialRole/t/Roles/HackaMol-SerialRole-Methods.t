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


my $bldr = new HackaMol;
apply_all_roles($bldr, 'HackaMol::Roles::SerialRole');
$bldr->serial_overwrite(1);

my $mol = $bldr->load("t/lib/1L2Y_mod123.sereal",'HackaMol::Molecule');

foreach my $format (qw/seReal yaMl/)
{
# test a biological molecule with multiple coordinates per atom
  $bldr->serial_format($format);
  my $mol2 = $bldr->clone($mol);

  #they look the same
  foreach (0 .. $mol2->tmax) {
    $mol->t($_);
    $mol2->t($_);
    cmp_ok(abs($mol->COM-$mol2->COM),'<','1E-10', "Cloned molecule same COM as a function of time: $_");
  }

  #make different

  #the COM of mol should change with one heavy atom substitution
  foreach (0 .. $mol2->tmax) {
    $mol->t($_);
    $mol2->t($_);
    $mol2->translate(-5*$mol2->COM);
    cmp_ok(abs($mol->COM-$mol2->COM),'>','1E-1', "Cloned molecule is different after changing atom, COM as a function of time: $_");
  }
# test storage
  my $hgmol = $bldr->read_file_mol("t/lib/Hg.2-18w.xyz");
  $bldr->store('t/lib/Hg.2-18w.'.lc($format),$hgmol);
}

done_testing();
