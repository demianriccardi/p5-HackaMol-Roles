use HackaMol;
use Module::Load;
use Moose::Util qw( ensure_all_roles );

load ('SelectionRole/lib/HackaMol/Roles/SelectionRole.pm'); #path to SelectionRole role

my $mol = HackaMol->new->pdbid_mol("2sic");
ensure_all_roles($mol, 'HackaMol::Roles::SelectionRole');

$mol->select_group('water')->print_pdb;
