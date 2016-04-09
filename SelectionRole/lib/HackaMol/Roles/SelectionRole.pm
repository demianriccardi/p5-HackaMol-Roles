package HackaMol::Roles::SelectionRole;

#ABSTRACT: Atom selections in molecules 
use Moose::Role;
use HackaMol::AtomGroup;
use Carp;

my %common_selections = (
    'backbone'    => sub {$_->record_name eq 'ATOM' and ($_->name eq 'N' or $_->name eq 'CA' or $_->name eq 'C')},
    'water'       => sub {$_->resname =~ m/HOH|TIP|H2O/ and $_->record_name eq 'HETATM' }, 
    'protein'     => sub {$_->record_name eq 'ATOM'},
    'ligands'     => sub {($_->resname !~ m/HOH|TIP|H2O/) and $_->record_name eq 'HETATM' }, 
    'metals'      => sub {my $atom = $_; grep {$atom->Z == $_} (3,4,11,12,19 .. 30, 37 .. 48, 55 .. 80) },
    'sidechains'  => sub {$_->record_name eq 'ATOM' and not ($_->name eq 'N' or $_->name eq 'CA' or $_->name eq 'C')}
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
    $method = _method($selection);
  }
  #grep { &{ sub{ $_%2 } }($_)} 1..10

  my $group = HackaMol::AtomGroup->new( 
                        atoms=>[ 
                          grep{&{$method}($_)}  $self->all_atoms 
                        ],
  ); 

  return($group);

}

sub _method{
  my $str = shift;
  print "$str not implemented yet"; return(sub{0});
  my @ands = split ('.and.',$str);
  my @ors  = map{[split ('.or.', $_)]}
  my ($attr,$val) = split(' ', $str);

  return $str;
}


1;
