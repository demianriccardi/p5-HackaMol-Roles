use Modern::Perl;
use HackaMol;
use HackaMol::Roles::SerialRole;
use Time::HiRes qw(time);
use Moose::Util qw( apply_all_roles );


my $t1 = time;

my $mol = HackaMol->new->pdbid_mol('2cba');
apply_all_roles($mol, 'HackaMol::Roles::SerialRole');
my $t2 = time;

printf ("read: %10.2f\n", $t2 - $t1);
my $mol2 = $mol->clone;
my $t3 = time;
printf ("clone %10.2f\n", $t3- $t2);
#$mol2->print_pdb;
#print "\n";
#print $mol . "\n";
#print $mol2 . "\n";

$mol->serial_format('CBOR');
#$mol->serial_format('YAML');
$mol->serial_overwrite(1);
$mol->store('shit.ser');

my $t4 = time;
printf ("store: %10.2f\n", $t4 - $t3);

my $mol_load = $mol->load('shit.ser');

my $t5 = time;

printf ("load: %10.2f\n", $t5 - $t4);
$mol_load->print_xyz_ts([0 .. $mol_load->tmax], 'shit.xyz');

#use YAML::XS;
#print Dump $mol_load;


#my $encoder = Sereal::Encoder->new; #({...options...});
#my $out = $encoder->encode($mole);

#my $shit = sereal_encode_with_object($encoder, $mol);
#my $t3 = time;

#printf ("encode: %10.2f\n", $t3 - $t2);

#my $shit2;
#my $decoder = Sereal::Decoder->new;
#$decoder->decode($shit, $shit2);
#my $t4 = time;

#$shit2->print_pdb;

#my $shit2 = sereal_decode_with_object($shit);
#my $decoder = Sereal::Decoder->new({...options...}); 
#my $structure;
#$decoder->decode($blob, $structure); 

