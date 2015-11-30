package HackaMol::Roles::SerialRole;

#ABSTRACT: Role cloning and storing HackaMol objects
use Moose::Role;
use MooseX::Types::Path::Tiny qw/Path/;
use Sereal::Encoder;
use Sereal::Decoder;
use CBOR::XS;
use JSON::XS;
use YAML::XS;
use Carp;

has 'serial_format',    is => 'rw', isa => 'Str' , lazy => 1, default => 'SEREAL';
has 'serial_carplevel', is => 'rw', isa => 'Num' , lazy => 1, default => 0;
has 'serial_overwrite', is => 'rw', isa => 'Bool', lazy => 1, default => 0;
has 'serial_fn',        is => 'rw', isa =>  Path,  coerce=>1, predicate => 'has_serial_fn';

# start simple, get something working and then make more sophisticated
# we will need to test if inserted functions are retained
# actually, HackaMol classes should have a flag if functions have been added to the
# object

sub freeze {

  my $self = shift;
  unless (@_ == 1) {
    carp "serial_freeze> must pass one object as argument; return 0";
    return (0); 
  }
  my $structure = shift;

  return (Sereal::Encoder->new->encode ($structure)) if uc($self->serial_format) =~ m/SEREAL/;
#  return (CBOR::XS->new->encode ($structure))        if uc($self->serial_format) =~ m/CBOR/;
#  return (JSON::XS->new->encode ($structure))        if uc($self->serial_format) =~ m/JSON/;
  return (YAML::XS::Dump ($structure))               if uc($self->serial_format) =~ m/YAML/;

  carp "return 0; self.serial_format is not supported: ", $self->serial_format;
  return (0);

}

sub thaw {

  my $self = shift;
  unless (@_ == 1) {
    carp "serial_thaw> must pass one object as argument; return 0";
    return (0);
  }
  my $structure = shift;
  
  return (Sereal::Decoder->new->decode ($structure)) if uc($self->serial_format) =~ m/SEREAL/;
#  return (CBOR::XS->new->decode ($structure))        if uc($self->serial_format) =~ m/CBOR/;
#  return (JSON::XS->new->decode ($structure))        if uc($self->serial_format) =~ m/JSON/;
  return (YAML::XS::Load ($structure))               if uc($self->serial_format) =~ m/YAML/;
  
  carp "return 0; self.serial_format is not supported: ", $self->serial_format;
  return (0);
}

sub clone {
  my $self = shift;
  unless (@_ == 1) {
    carp "serial_clone> must pass one object as argument; return 0";
    return (0);
  }
  my $structure = shift;

  # a clone is a freeze and thaw
  my $serial = $self->freeze($structure);
  return $self->thaw($serial);
}

sub store{

  my $self = shift;
  unless (@_ == 2) {
    carp "serial_store> must pass two arguments: filename and object; return 0";
    return (0);
  }
  my ($filename,$structure) = (shift,shift);

  if (-e $filename){
    unless($self->serial_overwrite){
      carp "$filename exists.  set self.serial_overwrite(1) to overwrite";
      return (0);
    }
    else {
      carp "overwriting $filename" if $self->serial_carplevel;
    }
  }

  $self->serial_fn($filename);
  
  my $serial = $self->freeze($structure);
  $self->serial_fn->spew_raw($serial);  # write
  return (1);
}

sub load{
  my $self = shift;
  unless (@_ == 2) {
    carp "serial_load> must pass two arguments: filename and object class; return 0";
    return (0);
  }
  my ($filename,$class) = (shift,shift);

  carp "rewriting self.load_fn($filename)" if $self->has_serial_fn;
  $self->serial_fn($filename);

  my $serial = $self->serial_fn->slurp_raw;
  my $object = $self->thaw($serial);   

  bless($object,$class);  
  return ($object);
}

no Moose::Role;
1;

__END__

=head1 SYNOPSIS

   use HackaMol;

   my $pdb = $HackaMol->new->get_pdbid("2cba");
   print $pdb;

=head1 DESCRIPTION

FileFetchRole provides attributes and methods for pulling files from the internet.
Currently, the Role has one method and one attribute for interacting with the Protein Database.

=method get_pdbid 

fetches a pdb from pdb.org and returns the file in a string.

=method getserial_pdbid 

arguments: pdbid and filename for writing (optional). 
Fetches a pdb from pdb.org and stores it in your working directory unless {it exists and overwrite(0)}. If a filename is not
passed to the method, it will write to $pdbid.pdb. use get_pdbid to return contents

=attr overwrite    
 
isa lazy ro Bool that defaults to 0 (false).  If overwrite(1), then fetched files will be able to overwrite
those of same name in working directory.

=attr  pdbserver  

isa lazy rw Str that defaults to http://pdb.org/pdb/files/

=head1 SEE ALSO

=for :list
* L<http://www.pdb.org>
* L<LWP::Simple>
                              
