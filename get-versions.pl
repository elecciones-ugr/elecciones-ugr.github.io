#!/usr/bin/env perl

use strict;
use warnings;

use v5.12;

use JSON;
use Git;
use File::Slurp::Tiny qw(read_file);

my $file = shift || die "Usage: $0 <fichero> [git directory] [Baseline file (not in repo)]\n";
my $dir = shift || ".";

my $repo = Git->repository (Directory => $dir);

my @revs = reverse $repo->command('rev-list', '--all', '--', $file);
my @data;
my @columns =  qw( Pilar Indalecio );
say "Escrutado;",join(";",@columns);


for my $commit ( @revs[9..$#revs] ) {
  my $file_contents = $repo->command('show',"$commit:$file" );
  my @row = extract_data( $file_contents);
  say join(";",@row);
}


#Extract data from JSON
sub extract_data {
  my $file_contents = shift;
  my $user_data = decode_json( $file_contents);
  my %porcentajes;
  for my $c ( keys %{$user_data->{'Resultados'}} ) {
    if ( $c =~ /ARANDA/ ) {
      $porcentajes{'Pilar'} = $user_data->{'Resultados'}->{$c}->{'Total'};
    } else {
      $porcentajes{'Indalecio'} = $user_data->{'Resultados'}->{$c}->{'Total'};
    }
  }
  return ( $user_data->{'Escrutado'} || 100, $porcentajes{'Pilar'}, $porcentajes{'Indalecio'} );
}

