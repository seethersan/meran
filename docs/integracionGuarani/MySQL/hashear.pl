#!/usr/bin/perl
# Meran - MERAN UNLP is a ILS (Integrated Library System) wich provides Catalog,
# Circulation and User's Management. It's written in Perl, and uses Apache2
# Web-Server, MySQL database and Sphinx 2 indexing.
# Copyright (C) 2009-2015 Grupo de desarrollo de Meran CeSPI-UNLP
# <desarrollo@cespi.unlp.edu.ar>
#
# This file is part of Meran.
#
# Meran is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Meran is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Meran.  If not, see <http://www.gnu.org/licenses/>.
use Digest::MD5 qw(md5_base64);
use MIME::Base64;
use Digest::SHA  qw(sha1 sha1_hex sha1_base64 sha256_base64 );
sub hashearPassword {
    my ($passMD5)=@_;
    my $passResult  = $passMD5;
    $passResult =~ s/([a-fA-F0-9][a-fA-F0-9])/chr(hex($1))/eg;
    $passResult = encode_base64($passResult);
    $passResult = substr $passResult, 0, -3;
    $passResult = sha256_base64($passResult);
    chomp $passResult;
    return $passResult;
}
sub addSlashes {
    $text = shift;
    ## Make sure to do the backslash first!
    $text =~ s/\\/\\\\/g;
    $text =~ s/'/\\'/g;
    $text =~ s/"/\\"/g;
    $text =~ s/\\0/\\\\0/g;
    return $text;
}
open(ARCHIVO,$ARGV[0]) || die("El archivo no abre");
open(ARCHIVO2,">salida") || die("El archivo no abre");
while ($line = <ARCHIVO>) {
	# Arma un arreglo a partir de una linea del archivo
	# Comenzando en el primer caraceter y usando el | como separador de campos
	
	@fields = split '\|',$line;
	@fields =  map { addSlashes($_) }  @fields;
	
	$fields[2]=hashearPassword($fields[2]);
	$linea=join '|',@fields;
	print ARCHIVO2 $linea; 
}
close ARCHIVO;
close ARCHIVO2;
$usuario=$ARGV[1];
$server=$ARGV[2];
$path=$ARGV[3];
system('scp salida '.$usuario.'@'.$server.':'.$path);
exit;
