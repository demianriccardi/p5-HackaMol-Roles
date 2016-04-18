package HackaMol::Roles::CGRole;

#ABSTRACT: Coarse-grain your molecules
use Moose::Role;
use Math::Vector::Real;
use Math::Vector::Real::kdTree;
use Math::Vector::Real::Neighbors;
use Carp;

has 'beads' => (
    is      => 'rw',
    isa     => 'Int',
    default => 1,
);

has 'rcut' => (
    is      => 'rw',
    isa     => 'Num',
    default => 7.5,
);

sub kmeans {
    my $self   = shift;
    my $mol    = shift;
    my $nbeads = shift;
    my $rcut   = shift;

    my $tree =
      Math::Vector::Real::kdTree->new( map { $_->xyz } $mol->all_atoms );
    my @means;

    while ($nbeads) {
        @means = $tree->k_means_start($nbeads);
        @means = $tree->k_means_loop(@means);
        my @ineigh = Math::Vector::Real::Neighbors->neighbors(@means);
        my @dist =
          map { $means[$_]->dist( $means[ $ineigh[$_] ] ) } 0 .. $#ineigh;
        if ( grep { $_ < $rcut } @dist ) {
            $nbeads--;
            next;
        }
        else {
            last;
        }
    }

    return HackaMol::Molecule->new( atoms =>
          [ map { HackaMol::Atom->new( Z => 80, coords => [$_] ) } @means, ] );

}

no Moose::Role;

1;

__END__

=head1 DESCRIPTION

The goal of HackaMol::Roles::CGRole is to provide methods and attributes to 
simplify the coarse-graining of molecules. This role is not loaded with the 
core; it must be applied as done in the synopsis.  This role is envisioned for 
instances of the HackaMol class, which provides builder. 

=head1 SYNOPSIS 

=method kmeans_mol 

takes three arguments: 

      1. 
      3. the molecule with the initial coordinates


=head1 WARNING 

This is still under active development and may change or just not work.  I still need to add warnings to help with bad 
selections.  Let me know if you have problems or suggestions!

