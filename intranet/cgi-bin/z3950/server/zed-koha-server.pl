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
use DBI;
use Net::Z3950::OID;
use Net::Z3950::SimpleServer;
use MARC::Record;
use C4::Context;
use C4::Biblio;
use strict;
my @bib_list;		## Stores the list of biblionumbers in a query 
			## I should eventually move this to different scope
my $handler = Net::Z3950::SimpleServer->new(INIT => \&init_handler,
					    SEARCH => \&search_handler,
					    FETCH => \&fetch_handler);
$handler->launch_server("zed-koha-server.pl", @ARGV);
sub init_handler {
        my $args = shift;
        my $session = {};
	
	# FIXME: I should force use of my database name 
        $args->{IMP_NAME} = "Zed-Koha";
        $args->{IMP_VER} = "1.40";
        $args->{ERR_CODE} = 0;
        $args->{HANDLE} = $session;
        if (defined($args->{PASS}) && defined($args->{USER})) {
            printf("Received USER/PASS=%s/%s\n", $args->{USER},$args->{PASS});
        }
}
sub run_query {		## Run the query and store the biblionumbers: 
	my ($sql_query, $query, $args) = @_;
		my $dbh = C4::Context->dbh;
       	my $sth_get = $dbh->prepare("$sql_query");
       	## Send the query to the database:
       	$sth_get->execute($query);
	my $count = 0;
	while(my ($data)=$sth_get->fetchrow_array) {
		
		## Store Biblioitem info for later
		$bib_list[$count] = "$data";
  
  		## Implement count:
       		$count ++;
       	}
       	$args->{HITS} = $count;
       	print "got search: ", $args->{RPN}->{query}->render(), "\n";
}
sub search_handler {		
    	my($args) = @_;
	## Place the user's query into a variable 
	my $query = $args->{QUERY};
	
	## The actual Term
	my $term = $args->{term};
	$term =~ s| |\%|g;
        $term .= "\%";         ## Add the wildcard to search term
	$_ = "$query";
             	   
                ## Strip out the junk and call the mysql query subroutine:
	if (/1=7/) {         	## isbn
		$query =~ s|\@attrset 1.2.840.10003.3.1 \@attr 1=7 ||g;
		$query  =~ s|"||g;
		$query =~ s| |%|g;
	
		## Bib-1 Structure Attributes:
		$query =~ s|\@attr||g;
		$query =~ s|4=100||g;   ## date (un-normalized)
		$query =~ s|4=101||g;   ## name (normalized)
		$query =~ s|4=102||g;   ## sme (un-normalized)
		$query =~ s|4=1||g;	## Phrase
                $query =~ s|4=2||g;	## Keyword
                $query =~ s|4=3||g;	## Key 
                $query =~ s|4=4||g;	## year 
		$query =~ s|4=5||g;	## Date (normalized)
		$query =~ s|4=6||g;	## word list
       		$query =~ s|5=100||g;	## truncation
		$query =~ s|5=1||g;	## truncation
	        $query =~ s|\@and ||g;
		$query =~ s|2=3||g;
		$query =~ s|,|%|g;	## replace commas with wildcard
		$query .= "\%";         ## Add the wildcard to search term
	 	$query .= "\%";         ## Add the wildcard to search term
		print "The term was:\n";
		print "$term\n";        
		print "The query was:\n";        
		print "$query\n";
		my $sql_query = "SELECT marc_biblio.bibid FROM marc_biblio RIGHT JOIN biblioitems ON marc_biblio.biblionumber = biblioitems.biblionumber WHERE biblioitems.isbn LIKE ?";
		&run_query($sql_query, $query, $args);
	} 
        elsif (/1=1003/) {	## author
        	$query =~ s|\@attrset||g;
		$query =~ s|1.2.840.10003.3.1||g;
		$query =~ s|1=1003||g;
 
               ## Bib-1 Structure Attributes:
                $query =~ s|\@attr ||g;
	        $query =~ s|4=100||g;  ## date (un-normalized)
		$query =~ s|4=101||g;  ## name (normalized)
		$query =~ s|4=102||g;  ## sme (un-normalized)
                $query =~ s|4=1||g;    ## Phrase
                $query =~ s|4=2||g;    ## Keyword
                $query =~ s|4=3||g;    ## Key
                $query =~ s|4=4||g;    ## year
                $query =~ s|4=5||g;    ## Date (normalized)
                $query =~ s|4=6||g;    ## word list
		$query =~ s|5=100||g;   ## truncation
                $query =~ s|5=1||g;     ## truncation
		
		$query =~ s|2=3||g;
		$query =~ s|"||g;
        	$query =~ s| |%|g;
		$query .= "\%";		## Add the wildcard to search term
		print "$query\n";
		my $sql_query = "SELECT marc_biblio.bibid FROM marc_biblio RIGHT JOIN biblio ON marc_biblio.biblionumber = biblio.biblionumber WHERE biblio.author LIKE ?";
                &run_query($sql_query, $query, $args);
        } 
	elsif (/1=4/) {      	## title
        	$query =~ s|\@attrset||g;
		$query =~ s|1.2.840.10003.3.1||g;
		$query =~ s|1=4||g;
        	$query  =~ s|"||g;
 		$query  =~ s| |%|g;
		
		## Bib-1 Structure Attributes:
                $query =~ s|\@attr||g;
                $query =~ s|4=100||g;  ## date (un-normalized)
		$query =~ s|4=101||g;  ## name (normalized)
		$query =~ s|4=102||g;  ## sme (un-normalized)
		$query =~ s|4=1||g;    ## Phrase
                $query =~ s|4=2||g;    ## Keyword
                $query =~ s|4=3||g;    ## Key
                $query =~ s|4=4||g;    ## year
                $query =~ s|4=5||g;    ## Date (normalized)
                $query =~ s|4=6||g;    ## word list
		$query =~ s|5=100||g;   ## truncation
		$query =~ s|5=1||g;     ## truncation
		
		$query =~ s|2=3||g;
		#$query =~ s|\@and||g;
		$query .= "\%";         ## Add the wildcard to search term
		print "The term was:\n";
                print "$term\n";
                print "The query was:\n";
                print "$query\n";
		my $sql_query = "SELECT marc_biblio.bibid FROM marc_biblio RIGHT JOIN biblio ON marc_biblio.biblionumber = biblio.biblionumber WHERE biblio.title LIKE ?";
        	&run_query($sql_query, $query, $args);
	}
	elsif (/1=21/) {         ## subject 
                $query =~ s|\@attrset 1.2.840.10003.3.1 \@attr 1=21 ||g;
                $query  =~ s|"||g;
                $query  =~ s| |%|g;
              
		## Bib-1 Structure Attributes:
                $query =~ s|\@attr ||g;
                $query =~ s|4=100||g;  ## date (un-normalized)
		$query =~ s|4=101||g;  ## name (normalized)
		$query =~ s|4=102||g;  ## sme (un-normalized)
						
                $query =~ s|4=1||g;    ## Phrase
                $query =~ s|4=2||g;    ## Keyword
                $query =~ s|4=3||g;    ## Key
                $query =~ s|4=4||g;    ## year
                $query =~ s|4=5||g;    ## Date (normalized)
                $query =~ s|4=6||g;    ## word list
		$query =~ s|5=100||g;   ## truncation
		$query =~ s|5=1||g;     ## truncation
		
		$query .= "\%";         ## Add the wildcard to search term
                print "$query\n";
		my $sql_query = "SELECT marc_biblio.bibid FROM marc_biblio RIGHT JOIN biblio ON marc_biblio.biblionumber = biblio.biblionumber WHERE biblio.subject LIKE ?";
                &run_query($sql_query, $query, $args);
        }
	elsif (/1=1016/) {       ## any 
                $query =~ s|\@attrset 1.2.840.10003.3.1 \@attr 1=1016 ||g;
                $query  =~ s|"||g;
                $query  =~ s| |%|g;
                
		## Bib-1 Structure Attributes:
                $query =~ s|\@attr||g;
		$query =~ s|4=100||g;  ## date (un-normalized)
		$query =~ s|4=101||g;  ## name (normalized)
		$query =~ s|4=102||g;  ## sme (un-normalized)
						
                $query =~ s|4=1||g;    ## Phrase
                $query =~ s|4=2||g;    ## Keyword
                $query =~ s|4=3||g;    ## Key
                $query =~ s|4=4||g;    ## year
                $query =~ s|4=5||g;    ## Date (normalized)
                $query =~ s|4=6||g;    ## word list
                $query =~ s|5=100||g;   ## truncation
		$query =~ s|5=1||g;     ## truncation
		
		$query .= "\%";         ## Add the wildcard to search term
                print "$query\n";
		my $sql_query = "SELECT bibid FROM marc_word WHERE word LIKE?";
                &run_query($sql_query, $query, $args);
        }
}
sub fetch_handler {
        my ($args) = @_;
        # warn "in fetch_handler";      ## troubleshooting
        my $offset = $args->{OFFSET};
        $offset -= 1;                   ## because $args->{OFFSET} 1 = record #1
        chomp (my $bibid = $bib_list[$offset]); ## Not sure about this
				## print "the bibid is:$bibid\n";
				my $dbh = C4::Context->dbh;
				my $MARCRecord = &MARCgetbiblio($dbh,$bibid);
				$MARCRecord->leader('     nac  22     1u 4500');
		## Set the REP_FORM
		$args->{REP_FORM} = &Net::Z3950::OID::unimarc;
		
		## Return the record string to the client 
			$args->{RECORD} = $MARCRecord->as_usmarc();
}
package Net::Z3950::RPN::Term;
sub render {
    my $self = shift;
    return '"' . $self->{term} . '"';
}
package Net::Z3950::RPN::And;
sub render {
    my $self = shift;
    return '(' . $self->[0]->render() . ' AND ' .
                 $self->[1]->render() . ')';
}
package Net::Z3950::RPN::Or;
sub render {
    my $self = shift;
    return '(' . $self->[0]->render() . ' OR ' .
                 $self->[1]->render() . ')';
}
package Net::Z3950::RPN::AndNot;
sub render {
    my $self = shift;
    return '(' . $self->[0]->render() . ' ANDNOT ' .
                 $self->[1]->render() . ')';
}
