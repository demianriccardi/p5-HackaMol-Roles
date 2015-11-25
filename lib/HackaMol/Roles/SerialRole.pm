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

has 'store_format',    is => 'rw', isa => 'Str' , lazy => 1, default => 'SEREAL';
has 'store_carplevel', is => 'rw', isa => 'Num' , lazy => 1, default => 0;
has 'overwrite',       is => 'rw', isa => 'Bool', lazy => 1, default => 0;
has 'store_fn',        is => 'rw', isa =>  Path, predicate => 'has_store_fn';
has 'load_fn',         is => 'rw', isa =>  Path, predicate => 'has_load_fn';

# start simple, get something working and then make more sophisticated
# we will need to test if inserted functions are retained
# actually, HackaMol classes should have a flag if functions have been added to the
# object

sub freeze {

  my ($self, $structure) = @_ ;
  unless ($structure) {
    $structure = $self; 
    carp "self.freeze(self)" if $self->store_carplevel;
  }

  return (Sereal::Encoder->new->encode ($structure)) if uc($self->store_format) =~ m/SEREAL/;
  return (CBOR::XS->new->encode ($structure))        if uc($self->store_format) =~ m/CBOR/;
  return (JSON::XS->new->encode ($structure))        if uc($self->store_format) =~ m/JSON/;
  return (YMAL::XS::Dump ($structure))               if uc($self->store_format) =~ m/YAML/;

  carp "return 0; self.store_format is not supported: ", $self->store_format;
  return (0);

}

sub thaw {

  my ($self, $structure) = @_ ;
  unless ($structure) {
    carp "return 0; must pass serialized data as argument: store_format: ", $self->store_format;
    return(0);
  }
  
  return (Sereal::Decoder->new->decode ($structure)) if uc($self->store_format) =~ m/SEREAL/;
  return (CBOR::XS->new->decode ($structure))        if uc($self->store_format) =~ m/CBOR/;
  return (JSON::XS->new->decode ($structure))        if uc($self->store_format) =~ m/JSON/;
  return (YMAL::XS::Load ($structure))               if uc($self->store_format) =~ m/YAML/;
  
  carp "return 0; self.store_format is not supported: ", $self->store_format;
  return (0);
}

sub clone {
  my ($self, $structure) = @_ ;
  unless ($structure) {
    $structure = $self; 
    carp "self.freeze(self)" if $self->store_carplevel;
  }
  # a clone is a freeze and thaw
  my $serial = $self->freeze($structure);
  return $self->thaw($serial);
}

sub store{
  #return pdb contents downloaded from pdb.org
  my ($self,$structure, $filename) = @_;
  $filename = Path::Tiny->tempfile unless $filename;

  unless ($structure) {
    $structure = $self;
    carp "self.store(self,$filename)" if $self->store_carplevel;
  }

  if (-e $filename){
    unless($self->overwrite){
      croak "$filename exists.  set self.overwrite(1) to overwrite";
    }
    else {
      carp "overwriting $filename" if $self->store_carplevel;
    }
  }

  $self->store_fn($filename);
  
  my $serial = $self->freeze($structure);
  $filename->spew_raw($serial);  # write
  return (1);
}

sub load{
  #return HackaMol object loaded from a file 
  my ($self,$filename) = @_;
  unless ($filename) {
    croak "pass filename self.load(filename) or set self.load_fn(filename)" unless $self->has_load_fn;
  }
  else {
    carp "rewriting self.load_fn($filename)" if $self->has_load_fn;
    $self->load_fn($filename);
  }
  my $serial = $self->load_fn->openr_raw;
  my $object = $self->thaw($serial);   
  
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

=method getstore_pdbid 

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
                              
