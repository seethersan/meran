#!/usr/bin/perl
# Meran - MERAN UNLP is a ILS (Integrated Library System) wich provides Catalog,
# Circulation and User's Management. It's written in Perl, and uses Apache2
# Web-Server, MySQL database and Sphinx 2 indexing.
# Copyright (C) 2009-2013 Grupo de desarrollo de Meran CeSPI-UNLP 
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
use CGI::Session;
use C4::Context;
use Digest::MD5 qw(md5 md5_hex md5_base64);
open (L,">/tmp/sql_fotos.sql");
open(ARCHIVO,$ARGV[0]) || die("El archivo no abre");
my $dbh = C4::Context->dbh;
my $pictures_dir = C4::Context->config('picturesdir');
my $line;
my @fields;
while ($line = <ARCHIVO>) {
    # Arma un arreglo a partir de una linea del archivo
    @fields = split(/\|/,$line);
    my $nro_documento = $fields[2];
    my $foto =  $fields[4];
    my $file_name = md5_hex($foto).".jpg";
    #print "nro_documento:: ".$nro_documento."\n";
    #print "foto:: ".$foto."\n\n\n";
    my $out = $dbh->prepare("SELECT * from usr_persona where nro_documento= ? ;");
    $out->execute($nro_documento);
    if ($out->rows) {
        my $datos=$out->fetchrow_hashref;
            if (length($foto) > 150 ){
            #Hay foto o es muy chica? 
                open(my $out, '>:raw', $pictures_dir.'/'.$file_name) or die "Unable to open: $!";
                print $out pack('H*',$foto);
                close($out);
                print L "UPDATE usr_persona SET foto= '$file_name' where id_persona=$datos->{'id_persona'} ;\n";
            }
    }
}
