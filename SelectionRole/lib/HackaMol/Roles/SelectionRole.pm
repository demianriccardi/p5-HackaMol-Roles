package HackaMol::Roles::SelectionRole;

#ABSTRACT: Atom selections in molecules 
use Moose::Role;
use HackaMol::AtomGroup;
use Carp;

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

  my $select_method = _method(@_);
  #grep { &{ sub{ $_%2 } }($_)} 1..10

  my $group = HackaMol::AtomGroup->new( 
                        atoms=>[ 
                          grep {$select_method} $self->all_atoms
                        ],
  ); 

  return($group);

}

sub _method{
  my $str = shift;
  return $str;
}


1;
