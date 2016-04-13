HackaMol-Roles-SerialRole
========
Role the provides methods for cloning and serialization of HackaMol objects.

VERSION 0.001
============
       
Please see [HackaMol on MetaCPAN](https://metacpan.org/release/HackaMol) for formatted documentation.  The [HackaMol publication] (http://pubs.acs.org/doi/abs/10.1021/ci500359e) has a more complete description of the library ([pdf available from researchgate](http://www.researchgate.net/profile/Demian_Riccardi/publication/273778191_HackaMol_an_object-oriented_Modern_Perl_library_for_molecular_hacking_on_multiple_scales/links/550ebec60cf27526109e6ade.pdf )). 

Citation: J. Chem. Inf. Model., 2015, 55 (4), pp 721–726 
       
SYNOPSIS
========
```perl
       use HackaMol;
       use HackaMol::Roles::SerialRole;
       use Moose::Util qw( apply_all_roles );

       my $bldr = HackaMol->new;
       my $mol = $bldr->pdbid_mol('2cba');

       apply_all_roles($bldr, 'HackaMol::Roles::SerialRole');

       my $mol2 = $bldr->clone($mol);
       $bldr->serial_format('Sereal');
       $bldr->store('test.sereal',$mol);
       my $mol3 = $bldr->load('test.sereal', 'HackaMol::Molecule');
       $bldr->serial_format('YAML');
       $bldr->store('test.yaml',$mol);
       my $mol4 = $bldr->load('test.yaml','HackaMol::Molecule');
      
``` 

DESCRIPTION
============
The ability to serialize HackaMol objects allows users to save the state of an object, which is useful for future work or for sharing.  The serialization of HackaMol objects is not trivial since each class contains other objects, such as Math::Vector::Real, or potentially functions that the user has defined.  This role is under development and the goal is to have ways to use JSON, YAML, Sereal, and CBOR. Currently, Sereal and YAML work (using default settings).  This role seems to make the most sense using a builder class, such as HackaMol.pm.  Applying the role to the HackaMol::Molecule class felt awkward during testing. 
      
 
INSTALLATION
============
This role will install into the file directory of the HackaMol core, but the core does not depend on this Role as of this writing.  See the synopsis above for an example of how to apply the role to an instance of a HackaMol object.

Temporary NOTES
===============
Since this module does not depend on HackaMol, it may be adjusted for more general use and released into the Role:: namespace as Role::Serializable (thanks @kentfredric).  Doing this will likely improve the Role.



