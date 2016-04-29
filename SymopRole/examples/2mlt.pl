use Modern::Perl;
use HackaMol;
use HackaMol::Roles::SymopRole;
use HackaMol::Roles::SelectionRole;
use Moose::Util qw(ensure_all_roles);

my $bldr = HackaMol->new();
ensure_all_roles($bldr, 'HackaMol::Roles::SymopRole');

my $mol = $bldr->pdbid_mol("2MLT");

my $symops_bio = 
'
REMARK 350   BIOMT1   2  1.000000  0.000000  0.000000        0.00000            
REMARK 350   BIOMT2   2  0.000000 -1.000000  0.000000        0.00000            
REMARK 350   BIOMT3   2  0.000000  0.000000 -1.000000       42.21100  
';

$bldr->apply_pdbstr_symops($symops_bio,$mol); 

$mol->qcat_print(1);

$mol->print_pdb_ts([0 .. $mol->tmax], '2mlt_tetramer.pdb');
#$mol->print_xyz_ts([1 .. $mol->tmax], 'quick.xyz');

ensure_all_roles($mol, 'HackaMol::Roles::SelectionRole');

my $chain_A = $mol->select_group("chain A");
my $chain_B = $mol->select_group("chain B");
$chain_A->print_pdb("2mlt_A.pdb");
$chain_B->print_pdb("2mlt_B.pdb");

