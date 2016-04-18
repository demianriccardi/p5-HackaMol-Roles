package HackaMol::Roles::SymopRole;

#ABSTRACT: Fill your coordinates using symmetry operations
use Moose::Role;
use Math::Vector::Real;
use Carp;

sub apply_pdbstr_symops {

  my $self   = shift;
  my $symops = shift;
  my $mol    = shift; 

  my $t = $mol->tmax+1;

  my %sym_op = (); # a hash to store them!
  #this regex may be general enough to work on entire pdb
  foreach my $line ( grep { m/REMARK 350\s+(BIOMT|SMTRY)\d+\s+\d+/ } split( '\n' , $symops ) ){
    my @entries = split(' ', $line);
    push @{$sym_op{$entries[3]}}, V(@entries[4,5,6,7]);
  }


  foreach my $symop (sort {$a<=>$b} keys %sym_op){
    my @mat_d = @{$sym_op{$symop}};
    my $cx = V(map{$_->[0]} @mat_d); 
    my $cy = V(map{$_->[1]} @mat_d);
    my $cz = V(map{$_->[2]} @mat_d);
    my $dxyz = V(map{$_->[3]} @mat_d);

    foreach my $atom ($mol->all_atoms){
        my ($x,$y,$z) = @{$atom->xyz};
        my $xyz_new = $x*$cx + $y*$cy + $z*$cz + $dxyz;  
        $atom->set_coords($t,$xyz_new);
    }   
    $t++; 
  }

}

no Moose::Role;

1;

__END__

=head1 DESCRIPTION

The goal of HackaMol::Roles::SymopRole is to simplify the application of 
symmetry operations.  This role is not loaded with the core; it 
must be applied as done in the synopsis.  This role is envisioned for 
instances of the HackaMol class, which provides builder. 

=head1 SYNOPSIS 

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

       $bldr->apply_pdbstr_symops($symops,$mol);  # will add coordinates for each, even the identity op (the first three)

       $mol->tmax ;     # says 2


       my $enzyme = $mol->select_group("chain E");
       my $inhib  = $mol->select_group("chain I");


=method apply_pdbstr_symops 

takes two arguments: 

      1. a string with one or more symmetry operations.  As the name of the method suggests, the method works for strings formatted as in a
         typical protein databank file.  It will filter for lines containing the SMTRY or BIOMT pattern.

      2. the molecule with the initial coordinates

The method applies the symmetry operators and adds the coordinates to each atom of the molecule.

=head1 WARNING 

This is still under active development and may change or just not work.  I still need to add warnings to help with bad 
selections.  Let me know if you have problems or suggestions!

