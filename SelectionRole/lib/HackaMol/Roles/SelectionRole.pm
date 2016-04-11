package HackaMol::Roles::SelectionRole;

#ABSTRACT: Atom selections in molecules 
use Moose::Role;
use HackaMol::AtomGroup;
use Carp;

my %common_selections = (
    'backbone'    => sub {grep { $_->record_name eq 'ATOM' and ($_->name eq 'N' or $_->name eq 'CA' or $_->name eq 'C')} @_},
    'water'       => sub {grep {$_->resname =~ m/HOH|TIP|H2O/ and $_->record_name eq 'HETATM' } @_ }, 
    'protein'     => sub {grep {$_->record_name eq 'ATOM'} @_ },
    'ligands'     => sub {grep {($_->resname !~ m/HOH|TIP|H2O/) and $_->record_name eq 'HETATM' } @_}, 
    'metals'      => sub {grep {my $atom = $_; grep {$atom->Z == $_} (3,4,11,12,19 .. 30, 37 .. 48, 55 .. 80) } @_ },
    'sidechains'  => sub {grep {$_->record_name eq 'ATOM' and 
                                not ($_->name eq 'N' or $_->name eq 'CA' or $_->name eq 'C')} @_},
    'test'        => sub {grep {($_->chain eq 'E' or ($_->resname eq 'TYR' and $_->chain eq 'I')) and $_->occ <= 1.0} @_},
);

has 'selections' => (
    traits    => ['Hash'],
    is        => 'ro',
    isa       => 'HashRef[CodeRef]',
    default   => sub { {} },
    handles   => {
        get_selection    => 'get',
        set_selection    => 'set',
        has_selections   => 'count',
        keys_selection   => 'keys',
        delete_selection => 'delete',
        has_selection    => 'exists',
    },
);

sub select_group{

  my $self = shift;
  my $selection = shift;
  my $method;
  if (exists($common_selections{$selection})) {
    $method = $common_selections{$selection};
  }
  else {
    $method = _regex_method($selection);
  }
  #grep { &{ sub{ $_%2 } }($_)} 1..10

  my $group = HackaMol::AtomGroup->new( 
                        atoms=>[ 
                          &{$method}($self->all_atoms) 
                        ],
  ); 

  return($group);

}

# $mol->select_group('(chain A .or. (resname TYR .and. chain B)) .and. occ .within. 1')
# becomes grep{($_->chain eq A or ($_->resname eq TYR and $_->chain eq 'B')) and $_->occ <= 1.0}

sub _regex_method{
  my $str = shift;
  #print "$str not implemented yet"; return(sub{0});
  #my @parenth = $str =~ /(\(([^()]|(?R))*\))/g    

  $str =~ s/(\w+)\s+([A-Za-z]+)/\$\_->$1 eq \'$2\'/g;
  $str =~ s/(\w+)\s+(\d+)/\$\_->$1 == $2/g;
  $str =~ s/(\w+)\s+\.within\.\s+(\d+)/\$\_->$1 <= $2/g;
  $str =~ s/(\w+)\s+\.beyond\.\s+(\d+)/\$\_->$1 >= $2/g;
  $str =~ s/\.and\./and/g;
  $str =~ s/\.or\./or/g;

  return (eval( "sub{ grep{ $str } \@_ }" ) );
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
must be applied as done above in the synopsis.  The main method is select_group, which uses regular expressions to convert 
a string argument to construct a method for filtering; a HackaMol::AtomGroup is returned. The select_group method operates 
atoms contained within the object to which the role is applied (i.e. $self->all_atoms).  The role is envisioned for 
instances of the HackaMol::Molecule class.

Some common selections are included for convenience:  backbone, sidechains, protein, water, ligands, and metals.  For new 
selections, the simplest selection will pair one attribute with one value separated by a space; for example, "chain E" will 
split the string and return all those that match (atom->chain eq 'E').  This will work for any attribute (e.g. atom->Z == 8).
Thus, 

      my $enzyme = $mol->select_group('chain E');

requires less perl know-how than the equivalent, 
      
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

      my $TYR_AE = $mol->select_group('(resname TYR .and. chain E) .or. (resname TYR .and. chain I)');

4. To select all atoms with occupancies between 0.5 and 0.95,

      my $occs = $mol->select_group('(occ .within. 0.95) .and. (occ .beyond. 0.5)');

The role also provides the an attribute with hash traits that can be used to create new selections.  For this hash, 
the key will be a simple string ("sidechains") and the value will be an anonymous subroutine.  
For example,

      $mol->set_selection("sidechains" => sub {grep { $_->record_name eq 'ATOM' and not 
                                                     ( $_->name eq 'N' or $_->name eq 'CA'
                                                       or $_->name eq 'C')
                                                    } @_ }
      );

=attr selections

isa HashRef[CodeRef] that is lazy with public Hash traits.  

=method select_group

takes one argument (string) and returns a HackaMol::AtomGroup object containing the selected atoms. 

=head1 WARNING 

This is still under active development and may change or just not work.  Let me know if you have problems or suggestions!

