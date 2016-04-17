# NAME

HackaMol::Roles::SymopRole - fill your coordinates with symmetry operations

# VERSION

version 0.002

# DESCRIPTION

The goal of HackaMol::Roles::SymopRole is to simplify the application of 
symmetry operations.  This role is not loaded with the core; it 
must be applied as done in the synopsis.  This role is envisioned for 
instances of the HackaMol class, which provides builder. 

## Symmetry operations using copy and pasted from the PDB 

    my $symops = '
      REMARK 350 APPLY THE FOLLOWING TO CHAINS: A, B                                  
      REMARK 350   BIOMT1   1  1.000000  0.000000  0.000000        0.00000            
      REMARK 350   BIOMT2   1  0.000000  1.000000  0.000000        0.00000            
      REMARK 350   BIOMT3   1  0.000000  0.000000  1.000000        0.00000            
      REMARK 350   BIOMT1   2 -1.000000  0.000000  0.000000     -125.59400            
      REMARK 350   BIOMT2   2  0.000000 -1.000000  0.000000     -125.48300            
      REMARK 350   BIOMT3   2  0.000000  0.000000  1.000000        0.00000    
    '; # from pdb

     say $mol->tmax ; # says 0

     $bldr->apply_string_symops($mol,$symops);  # will add coordinates for each, even the identity op (the first three)

     $mol->tmax ;     # says 2
    

# METHODS

## set\_selections\_cr

two arguments: a string and a coderef

## select\_group

takes one argument (string) and returns a HackaMol::AtomGroup object containing the selected atoms. Priority: the select\_group method looks at 
selections\_cr first, then the common selections, and finally, if there were no known selections, it passes the argument to be processed
using regular expressions.

# ATTRIBUTES

## selections\_cr

isa HashRef\[CodeRef\] that is lazy with public Hash traits.  This attribute allows the user to use code references in the atom selections.
The list of atoms, contained in the role consuming object, will be passed to the code reference, and a list of atoms is the expected output
of the code reference, e.g.

    @new_atoms = &{$code_ref}(@atoms);

# SYNOPSIS 

       # load 2SIC from the the RCSB.org and pull out two groups: the enzyme (chain E) and  the inhibitor (chain I) 

       use HackaMol;
       use Moose::Util qw( ensure_all_roles ); #  to apply the role to the molecule object

       my $mol = HackaMol->new->pdbid_mol("2sic"); #returns HackaMol::Molecule

       ensure_all_roles($mol, 'HackaMol::Roles::SelectionRole') # now $mol has the select_group method;

       my $enzyme = $mol->select_group("chain E");
       my $inhib  = $mol->select_group("chain I");

# WARNING 

This is still under active development and may change or just not work.  I still need to add warnings to help with bad 
selections.  Let me know if you have problems or suggestions!

# AUTHOR

Demian Riccardi <demianriccardi@gmail.com>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2016 by Demian Riccardi.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
