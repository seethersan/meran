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
use strict;
use CGI qw(:standard);
use DBI;
use Text::ParseWords;
use C4::Date;
my $dateformat = C4::Date::get_date_format();
my $dbh = DBI->connect('DBI:mysql:Econo', 'kohaadmin', '');
open (L,">>cambioregularidad");
open(ARCHIVO,$ARGV[0]) || die("El archivo no abre");
my $line;
my @fields;
my $regular=0;
my $anterior='';
my $upgrade='';
my ($ucardnumber,$usurname,$ufirstname,$udateofbirth,$usex,$ustreetaddress,$ucity,$uzipcode,$uphone,$uemailaddress,$ustudentnumber,$udocumentnumber,$udocumenttype,$uregular);
my ($cardnumber,$surname,$firstname,$dateofbirth,$sex,$streetaddress,$city,$zipcode,$phone,$emailaddress,$studentnumber,$documentnumber,$documenttype);
my $paso=0;
while ($line = <ARCHIVO>) {
@fields = split(/\|/,$line);
$cardnumber = join(" ", split(" ",$fields[1]));
$cardnumber =~ tr/0-9//cd;
$surname = join(" ", split(" ",$fields[3]));
$surname=~ s/\'//g;
$firstname = join(" ", split(" ",$fields[4]));
$firstname=~ s/\'//g;
$documenttype = ($fields[20] eq '')?'NULL':'"'.$fields[20].'"';
$documentnumber = ($fields[6] eq '')?'NULL':'"'.(split(/\./,$fields[6]))[0].'"';
$dateofbirth= ($fields[5] eq '')?'NULL':'"'.format_date_in_iso($fields[5],$dateformat).'"';
$sex= $fields[6];
$sex =~ tr/12/MF/;
$streetaddress= "CALLE: ".(($fields[7])?$fields[7]:"-")." NUMERO: ".(($fields[8])?$fields[8]:"-")." PISO: ".(($fields[9])?$fields[9]:"-")." DPTO: ".(($fields[10])?$fields[10]:"-");
$city= ($fields[12] eq '')?'NULL':'"'.$fields[12].'"';
$zipcode= ($fields[13] eq '')?'NULL':'"'.$fields[13].'"';
$phone= ($fields[14] eq '')?'NULL':'"'.$fields[14].'"';
$emailaddress= ($fields[15] eq '')?'NULL':'"'.$fields[15].'"';
$studentnumber= ($fields[17] eq '')?'NULL':'"'.$fields[17].'"';
$fields[19]=~ tr/SN/10/;
if ($anterior eq $cardnumber){
	$regular= $regular ||$fields[19];
	($ucardnumber,$usurname,$ufirstname,$udateofbirth,$usex,$ustreetaddress,$ucity,$uzipcode,$uphone,$uemailaddress,$ustudentnumber,$udocumentnumber,$udocumenttype,$uregular)=($cardnumber,$surname,$firstname,$dateofbirth,$sex,$streetaddress,$city,$zipcode,$phone,$emailaddress,$studentnumber,$documentnumber,$documenttype,$regular);
	$paso=1;
      }
else{
	if ($anterior ne ""){
		if ($paso eq 0){
			($ucardnumber,$usurname,$ufirstname,$udateofbirth,$usex,$ustreetaddress,$ucity,$uzipcode,$uphone,$uemailaddress,$ustudentnumber,$udocumentnumber,$udocumenttype,$uregular)=($cardnumber,$surname,$firstname,$dateofbirth,$sex,$streetaddress,$city,$zipcode,$phone,$emailaddress,$studentnumber,$documentnumber,$documenttype,$fields[19]);
			$paso=2;
		}#if paso==0
		my $out = $dbh->prepare("select * from persons where cardnumber = ?");
		$out->execute($anterior);
		if ($out->rows) {
			my $datos=$out->fetchrow_hashref;
			if ($datos->{'regular'} ne $regular){
			print("update persons set regular= ".$regular." where (cardnumber = ".$anterior.");\n");
			}
			}
		else{#no existe lo tengo que agregar
			print("insert into persons (cardnumber, surname, firstname, dateofbirth, sex, streetaddress, city, zipcode, phone, emailaddress, studentnumber, documentnumber, documenttype, branchcode, categorycode, regular) values (".$ucardnumber.",'".$usurname."','".$ufirstname."',".$udateofbirth.",'".$usex."','".$ustreetaddress."',".$ucity.",".$uzipcode.",".$uphone.",".$uemailaddress.",".$ustudentnumber.",".$udocumentnumber.",".$udocumenttype.",'DEO','ES',".$fields[19].");\n");
		} #else
		if ($paso){
			($ucardnumber,$usurname,$ufirstname,$udateofbirth,$usex,$ustreetaddress,$ucity,$uzipcode,$uphone,$uemailaddress,$ustudentnumber,$udocumentnumber,$udocumenttype,$uregular)=($cardnumber,$surname,$firstname,$dateofbirth,$sex,$streetaddress,$city,$zipcode,$phone,$emailaddress,$studentnumber,$documentnumber,$documenttype,$regular);
		} #if $paso
	}#if anterior ne ""
	else{
	($ucardnumber,$usurname,$ufirstname,$udateofbirth,$usex,$ustreetaddress,$ucity,$uzipcode,$uphone,$uemailaddress,$ustudentnumber,$udocumentnumber,$udocumenttype,$uregular)=($cardnumber,$surname,$firstname,$dateofbirth,$sex,$streetaddress,$city,$zipcode,$phone,$emailaddress,$studentnumber,$documentnumber,$documenttype,$fields[19]);
	$paso=1;
	}
}
$anterior=$cardnumber;
$regular=$fields[19];
}#while
if ($anterior eq $cardnumber){
	$regular= $regular ||$uregular;
}
($ucardnumber,$usurname,$ufirstname,$udateofbirth,$usex,$ustreetaddress,$ucity,$uzipcode,$uphone,$uemailaddress,$ustudentnumber,$udocumentnumber,$udocumenttype,$uregular)=($cardnumber,$surname,$firstname,$dateofbirth,$sex,$streetaddress,$city,$zipcode,$phone,$emailaddress,$studentnumber,$documentnumber,$documenttype,$regular);
	my $out = $dbh->prepare("select * from persons where cardnumber = ?");
	$out->execute($anterior);
		if ($out->rows) {
			print("update persons set regular= ".$regular." where (cardnumber = ".$anterior.");\n");}
		else{#no existe lo tengo que agregar
		    print("insert into persons (cardnumber, surname, firstname, dateofbirth, sex, streetaddress, city, zipcode, phone, emailaddress, studentnumber, documentnumber, documenttype, branchcode, categorycode, regular) values (".$ucardnumber.",'".$usurname."','".$ufirstname."',".$udateofbirth.",'".$usex."','".$ustreetaddress."',".$ucity.",".$uzipcode.",".$uphone.",".$uemailaddress.",".$ustudentnumber.",".$udocumentnumber.",".$udocumenttype.",'DEO','ES',".$regular.");\n");
		    #print $anterior."\n";
		}
	
close L;
exit;