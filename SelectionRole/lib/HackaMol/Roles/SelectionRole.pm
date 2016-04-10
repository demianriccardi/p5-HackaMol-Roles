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
  $str =~ s/(\w+)\s+\.beyond\.\s+(\d+)/\$\_->$1 > $2/g;
  $str =~ s/\.and\./and/g;
  $str =~ s/\.or\./or/g;

  return (eval( "sub{ grep{ $str } \@_ }" ) );
}


1;
