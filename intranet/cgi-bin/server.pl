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
                                                                                                                             
use SOAP::Transport::HTTP;
SOAP::Transport::HTTP::CGI
  -> dispatch_to('Demo')
  -> handle;
package Demo;
use strict;
sub isRegularBorrower {
  my ($name,$documentnumber)= @_;
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("select borrowernumber from borrowers where documentnumber=?");
  $sth->execute($documentnumber);
  my $count= $sth->rows;
  if ($count) { # if $count <> 0 then exist a borrower with this $documentnumber
    my $bornum= $sth->fetchrow;
    my ($count,$issue)=borrissues($bornum);
    if ($count) { # if $count > 0 then the borrower had books in his possession
      return("1");
    } else { # if $count = 0 then the borrower hadn't books in his possession
      return("0");
    }
    $sth->finish;
  } else  { # if $count = 0 then then the borrower doesn't exist
    $sth->finish;
    return("-1");
  }
}
=item
borrissues
=cut
sub borrissues {
  my ($bornum)=@_;
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("Select *, issues.renewals as renewals2  
	from issues left join items  on items.itemnumber=issues.itemnumber 
	inner join  biblio on items.biblionumber=biblio.biblionumber 
	 where borrowernumber=?
	and issues.returndate is NULL order by date_due");
    $sth->execute($bornum);
  my @result;
  while (my $data = $sth->fetchrow_hashref) {
    push @result, $data;
  }
  $sth->finish;
  return(scalar(@result), \@result);
}
