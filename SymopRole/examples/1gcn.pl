use Modern::Perl;
use HackaMol;
use HackaMol::Roles::SymopRole;
use Moose::Util qw(ensure_all_roles);

my $bldr = HackaMol->new();
ensure_all_roles($bldr, 'HackaMol::Roles::SymopRole');

my $mol = $bldr->pdbid_mol("1GCN");

my $symops = 
'
REMARK 290   SMTRY1   2 -1.000000  0.000000  0.000000       23.55000            
REMARK 290   SMTRY2   2  0.000000 -1.000000  0.000000        0.00000            
REMARK 290   SMTRY3   2  0.000000  0.000000  1.000000       23.55000            
REMARK 290   SMTRY1   3 -1.000000  0.000000  0.000000        0.00000            
REMARK 290   SMTRY2   3  0.000000  1.000000  0.000000       23.55000            
REMARK 290   SMTRY3   3  0.000000  0.000000 -1.000000       23.55000            
REMARK 290   SMTRY1   4  1.000000  0.000000  0.000000       23.55000            
REMARK 290   SMTRY2   4  0.000000 -1.000000  0.000000       23.55000            
REMARK 290   SMTRY3   4  0.000000  0.000000 -1.000000        0.00000            
REMARK 290   SMTRY1   5  0.000000  0.000000  1.000000        0.00000            
REMARK 290   SMTRY2   5  1.000000  0.000000  0.000000        0.00000            
REMARK 290   SMTRY3   5  0.000000  1.000000  0.000000        0.00000            
REMARK 290   SMTRY1   6  0.000000  0.000000  1.000000       23.55000            
REMARK 290   SMTRY2   6 -1.000000  0.000000  0.000000       23.55000            
REMARK 290   SMTRY3   6  0.000000 -1.000000  0.000000        0.00000            
REMARK 290   SMTRY1   7  0.000000  0.000000 -1.000000       23.55000            
REMARK 290   SMTRY2   7 -1.000000  0.000000  0.000000        0.00000            
REMARK 290   SMTRY3   7  0.000000  1.000000  0.000000       23.55000            
REMARK 290   SMTRY1   8  0.000000  0.000000 -1.000000        0.00000            
REMARK 290   SMTRY2   8  1.000000  0.000000  0.000000       23.55000            
REMARK 290   SMTRY3   8  0.000000 -1.000000  0.000000       23.55000            
REMARK 290   SMTRY1   9  0.000000  1.000000  0.000000        0.00000            
REMARK 290   SMTRY2   9  0.000000  0.000000  1.000000        0.00000            
REMARK 290   SMTRY3   9  1.000000  0.000000  0.000000        0.00000            
REMARK 290   SMTRY1  10  0.000000 -1.000000  0.000000        0.00000            
REMARK 290   SMTRY2  10  0.000000  0.000000  1.000000       23.55000            
REMARK 290   SMTRY3  10 -1.000000  0.000000  0.000000       23.55000            
REMARK 290   SMTRY1  11  0.000000  1.000000  0.000000       23.55000            
REMARK 290   SMTRY2  11  0.000000  0.000000 -1.000000       23.55000            
REMARK 290   SMTRY3  11 -1.000000  0.000000  0.000000        0.00000            
REMARK 290   SMTRY1  12  0.000000 -1.000000  0.000000       23.55000            
REMARK 290   SMTRY2  12  0.000000  0.000000 -1.000000        0.00000            
REMARK 290   SMTRY3  12  1.000000  0.000000  0.000000       23.55000            
';

print $symops;
$bldr->apply_pdbstr_symops($symops,$mol); 

$mol->qcat_print(1);

$mol->print_pdb_ts([1 .. $mol->tmax], 'quick.pdb');
#$mol->print_xyz_ts([1 .. $mol->tmax], 'quick.xyz');


