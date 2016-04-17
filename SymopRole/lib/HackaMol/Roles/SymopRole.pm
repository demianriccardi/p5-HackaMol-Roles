package HackaMol::Roles::SymopRole;

#ABSTRACT: Atom selections in molecules
use Moose::Role;
use Math::Vector::Real;
use Carp;

sub apply_string_symops {

  my $self   = shift;
  my $symops = shift;
  my $mol    = shift; 

  my $t = $mol->tmax+1;

  my %sym_op = (); # a hash to store them!
  foreach my $line ( grep {m/BIOMT|SMTRY/} split( '\n' , $symops ) ){
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

=head1 SYNOPSIS 

       # load 2SIC from the the RCSB.org and pull out two groups: the enzyme (chain E) and  the inhibitor (chain I) 

       use HackaMol;
       use Moose::Util qw( ensure_all_roles ); #  to apply the role to the molecule object

       my $mol = HackaMol->new->pdbid_mol("2sic"); #returns HackaMol::Molecule

       ensure_all_roles($mol, 'HackaMol::Roles::SelectionRole') # now $mol has the select_group method;

       my $enzyme = $mol->select_group("chain E");
       my $inhib  = $mol->select_group("chain I");

=head1 DESCRIPTION

The goal of HackaMol::Roles::SelectionRole is to simplify atom selections.  This role is not loaded with the core; it 
must be applied as done in the synopsis.  The method commonly used is select_group, which uses regular expressions to convert 
a string argument to construct a method for filtering; a HackaMol::AtomGroup is returned. The select_group method operates 
on atoms contained within the object to which the role is applied (i.e. $self->all_atoms).  The role is envisioned for 
instances of the HackaMol::Molecule class.

=head2 Common Selections: backbone, sidechains, protein, etc.

Some common selections are included for convenience:  backbone, sidechains, protein, water, ligands, and metals.  

    my $bb = $mol->select_group('backbone'); 

=head2 Novel selections using strings: e.g. 'chain E', 'Z 8', 'chain E .and. Z 6'

Strings are used for novel selections, the simplest selection being the pair of one attribute with one value separated by a space. 
For example, "chain E" will split the string and return all those that match (atom->chain eq 'E').  

      my $enzyme = $mol->select_group('chain E');

This will work for any attribute (e.g. atom->Z == 8). This approach requires less perl know-how than the equivalent, 
      
      my @enzyme_atoms = grep{$_->chain eq 'E'} $mol->all_atoms;
      my $enzyme = HackaMol::AtomGroup->new(atoms=>[@enzyme_atoms]); 

More complex selections are also straightforward using the following operators:

      .or.         matches if an atom satisfies either selection (separated by .or.)
      .and.        matches if an atom satisfies both selections (separated by .and.)             
      .within.     less than or equal to for numeric attributes
      .beyond.     greater than or equal to for numeric attributes
      .not.        everything but

More, such as .around. will be added as needs arise. Let's take a couple of examples. 

1. To select all the tyrosines from chain E,

      my $TYR_E = $mol->select_group('chain E .and. resname TYR');

2. To choose both chain E and chain I,

      my $two_chains = $mol->select_group('chain E .or. chain I');

Parenthesis are also supported to allow selection precedence.  

3. To select all the tyrosines from chain E along with all the tyrosines from chain I,

      my $TYR_EI = $mol->select_group('(resname TYR .and. chain E) .or. (resname TYR .and. chain I)');

4. To select all atoms with occupancies between 0.5 and 0.95,

      my $occs = $mol->select_group('(occ .within. 0.95) .and. (occ .beyond. 0.5)');

The common selections (protein, water, backbone, sidechains) can also be used in the selections.  For example, select 
chain I but not the chain I water molecules (sometimes the water molecules get the chain id),

      my $chain_I =  $mol->select_group('chain I .and. .not. water');

=head2 Extreme selections using code references. 

The role also provides the an attribute with hash traits that can be used to create, insanely flexible, selections using code references. 
As long as the code reference returns a list of atoms, you can do whatever you want.  For example, let's define a sidechains selection; the 
key will be a simple string ("sidechains") and the value will be an anonymous subroutine.  
For example,

      $mol->set_selection_cr("my_sidechains" => sub {grep { $_->record_name eq 'ATOM' and not 
                                                     ( $_->name eq 'N' or $_->name eq 'CA'
                                                       or $_->name eq 'C' or $_->name eq 'Flowers and sausages')
                                                    } @_ }
      );

Now $mol->select_group('my_sidechains') will return a group corresponding to the selection defined above.  If you were to rename 
"my_sidechains" to "sidechains", your "sidechains" would be loaded in place of the common selection "sidechains" because of the priority
described below in the select_group method.  

=attr selections_cr

isa HashRef[CodeRef] that is lazy with public Hash traits.  This attribute allows the user to use code references in the atom selections.
The list of atoms, contained in the role consuming object, will be passed to the code reference, and a list of atoms is the expected output
of the code reference, e.g.

    @new_atoms = &{$code_ref}(@atoms);

=method set_selections_cr

two arguments: a string and a coderef

=method select_group

takes one argument (string) and returns a HackaMol::AtomGroup object containing the selected atoms. Priority: the select_group method looks at 
selections_cr first, then the common selections, and finally, if there were no known selections, it passes the argument to be processed
using regular expressions.

=head1 WARNING 

This is still under active development and may change or just not work.  I still need to add warnings to help with bad 
selections.  Let me know if you have problems or suggestions!

