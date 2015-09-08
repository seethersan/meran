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
use lib '/usr/local/koha/intranet/modules/';
use strict;
use C4::Context;
use C4::Biblio;
my $dbh=C4::Context->dbh;
my @tags=(
"020a", # INTERNATIONAL STANDARD BOOK NUMBER
"022a", # INTERNATIONAL STANDARD SERIAL NUMBER
"100a",	# MAIN ENTRY--PERSONAL NAME
"110a",	# MAIN ENTRY--CORPORATE NAME
"110b",	#   Subordinate unit
"110c",	#   Location of meeting
"111a", # MAIN ENTRY--MEETING NAME
"111c", #   Location of meeting
"130a", # MAIN ENTRY--UNIFORM TITLE 
"240a", # UNIFORM TITLE 
"245a", # TITLE STATEMENT
"245b", #   Remainder of title
"245c", #   Statement of responsibility, etc.
"245p", #   Name of part/section of a work
"246a", # VARYING FORM OF TITLE
"246b", #   Remainder of title
"260b", # PUBLICATION, DISTRIBUTION, ETC. (IMPRINT)
"440a", # SERIES STATEMENT/ADDED ENTRY--TITLE
"440p", #   Name of part/section of a work
"500a", # GENERAL NOTE
"505t", # FORMATTED CONTENTS NOTE (t is Title)
"511a", # PARTICIPANT OR PERFORMER NOTE
"520a", # SUMMARY, ETC.
"534a", # ORIGINAL VERSION NOTE 
"534k", #   Key title of original
"534t", #   Title statement of original
"586a", # AWARDS NOTE
"600a", # SUBJECT ADDED ENTRY--PERSONAL NAME 
"610a", # SUBJECT ADDED ENTRY--CORPORATE NAME
"611a", # SUBJECT ADDED ENTRY--MEETING NAME
"630a", # SUBJECT ADDED ENTRY--UNIFORM TITLE
"650a", # SUBJECT ADDED ENTRY--TOPICAL TERM
"651a", # SUBJECT ADDED ENTRY--GEOGRAPHIC NAME
"700a", # ADDED ENTRY--PERSONAL NAME
"710a", # ADDED ENTRY--CORPORATE NAME
"711a", # ADDED ENTRY--MEETING NAME
"720a", # ADDED ENTRY--UNCONTROLLED NAME
"730a", # ADDED ENTRY--UNIFORM TITLE
"740a", # ADDED ENTRY--UNCONTROLLED RELATED/ANALYTICAL TITLE
"752a", # ADDED ENTRY--HIERARCHICAL PLACE NAME
"800a", # SERIES ADDED ENTRY--PERSONAL NAME
"810a", # SERIES ADDED ENTRY--CORPORATE NAME
"811a", # SERIES ADDED ENTRY--MEETING NAME
"830a", # SERIES ADDED ENTRY--UNIFORM TITLE
"942k"  # Holdings Branch ?? Unique to NPL??
);
foreach my $this_tagid(@tags) {
	my $query="SELECT bibid,tag,tagorder,subfieldcode,subfieldorder,subfieldvalue FROM marc_subfield_table WHERE tag=? AND subfieldcode=?";
	my $sth=$dbh->prepare($query);
	my ($tag, $subfieldid);
	if ($this_tagid =~ s/(\D+)//) {
		$subfieldid = $1;
		$tag = $this_tagid;
	}
	$sth->execute($tag, $subfieldid);
	while (my $data=$sth->fetchrow_hashref()){
		MARCaddword($dbh,$data->{'bibid'},$data->{'tag'},$data->{'tagorder'},$data->{'subfieldcode'},$data->{'subfieldorder'},$data->{'subfieldvalue'});
	}
}
$dbh->disconnect();