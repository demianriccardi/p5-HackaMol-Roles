# p5-HackaMol-Roles

This repository contains roles that can be applied to HackaMol objects, such as instances of 
HackaMol::Molecule or included in new classes.   

* SelectionRole      ->    https://metacpan.org/pod/HackaMol::Roles::SelectionRole
* SerialRole         ->    Not Released yet

#SYNOPSIS

For modules that are installed from CPAN:

````perl
       use HackaMol;
       use HackaMol::Roles::SomeSpecialRole;
       use Moose::Util qw( ensure_all_roles ); #  to apply the role to the molecule object

       my $mol = HackaMol->new->pdbid_mol("2sic"); #returns HackaMol::Molecule

       ensure_all_roles($mol, 'HackaMol::Roles::SomeSpecialRole') # now $mol has new behaviors!

       my $fancy_stuff = $mol->new_behavior(@args);
````

To load a role from a file:

````perl
       use HackaMol;
       use Module::Load;
       use Moose::Util qw( ensure_all_roles ); #  to apply the role to the molecule object

       load 'some/path/somespecialrole.pm';

       my $mol = HackaMol->new->pdbid_mol("2sic"); #returns HackaMol::Molecule

       ensure_all_roles($mol, 'HackaMol::Roles::SomeSpecialRole') # now $mol has new behaviors!

       my $fancy_stuff = $mol->new_behavior(@args);
```` 

#RepoROLES

  * SelectionRole

# AUTHOR

Demian Riccardi <demianriccardi@gmail.com>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2016 by Demian Riccardi.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

