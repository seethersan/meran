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
use strict;
use C4::Context;
use DBI;
my $dbh = C4::Context->dbh;
sub dosql {
	my ($dbh,$sql_cmd)=@_;
	my $sti=$dbh->prepare($sql_cmd);
	$sti->execute;
	if ($sti->err) {
		print "error : ".$sti->errstr." \n tried to execute : $sql_cmd\n";
		$sti->finish;
	}
}
my $sth=$dbh->prepare("show tables");
$sth->execute;
my %tables;
while (my ($table) = $sth->fetchrow) {
    $tables{$table}=1;
}
$dbh->do("delete from bibliothesaurus");
my $sti=$dbh->prepare("select count(*) from bibliosubject");
$sti->execute;
my ($total) = $sti->fetchrow_array;
$sti=$dbh->prepare("select subject from bibliosubject");
$sti->execute;
my $i;
my $search_sth = $dbh->prepare("select id,level,hierarchy from bibliothesaurus where stdlib=?");
my $insert_sth = $dbh->prepare("insert into bibliothesaurus (freelib,stdlib,category,level,hierarchy) values (?,?,?,?,?)");
while (my $line =$sti->fetchrow_hashref) {
	$i++;
	if ($i % 1000==0) {
		print "$i / $total\n";
	}
	my @hierarchy = split / - /,$line->{'subject'};
	my $rebuild = "";
	my $top_hierarchy = "";
	#---- if not a main authority field, search where to link
	for (my $hier=0; $hier<$#hierarchy+1 ; $hier++) {
		$rebuild .=$hierarchy[$hier];
		$search_sth->execute($rebuild);
		my ($id,$level,$hierarchy) = $search_sth->fetchrow_array;
		if (!$id) {
			$insert_sth->execute($rebuild,$rebuild,"",$hier,"$top_hierarchy");
			# search again, to find $id and buiild $top_hierarchy
			$search_sth->execute($rebuild);
			my ($id,$level,$hierarchy) = $search_sth->fetchrow_array;
			$top_hierarchy .="|" if ($top_hierarchy);
			$top_hierarchy .= "$id";
		} else {
			$top_hierarchy .="|" if ($top_hierarchy);
			$top_hierarchy .= "$id";
		}
		$rebuild .=" - ";
	}
}
