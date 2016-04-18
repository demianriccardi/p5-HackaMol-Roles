use Modern::Perl;
use HackaMol;
use HackaMol::Roles::SymopRole;
use Moose::Util qw(ensure_all_roles);

my $bldr = HackaMol->new();
ensure_all_roles($bldr, 'HackaMol::Roles::SymopRole');

my $mol = $bldr->read_file_mol("t/lib/1QGT_kmeans.xyz");

my $symops = $bldr->in_fn("t/lib/1QGT_header.pdb")->slurp;

$bldr->apply_pdbstr_symops($symops,$mol); 

$mol->qcat_print(1);

$mol->print_xyz_ts([1 .. $mol->tmax], 'quick.xyz');


