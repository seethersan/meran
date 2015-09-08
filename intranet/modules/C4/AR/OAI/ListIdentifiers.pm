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
package C4::AR::OAI::ListIdentifiers;
use strict;
use warnings;
use diagnostics;
use HTTP::OAI;
use C4::AR::OAI::ResumptionToken;
use base ("HTTP::OAI::ListIdentifiers");
sub new {
    my ($class, $repository, %args) = @_;
    my $self = HTTP::OAI::ListIdentifiers->new(%args);
    my $token = new C4::AR::OAI::ResumptionToken( %args );
    my $dbh = C4::Context->dbh;
    my $sql = "SELECT id
               FROM   cat_registro_marc_n1
               WHERE  id >= ? AND id <= ?
               LIMIT  " . $repository->{meran_max_count} . "
               OFFSET " . $token->{offset};
    my $sth = $dbh->prepare( $sql );
    $sth->execute( $token->{from}, $token->{until} );
    my $pos = $token->{offset};
    while ( my ($id) = $sth->fetchrow ) {
        $self->identifier( new HTTP::OAI::Header(
            identifier => $repository->{ meran_identifier} . ':' . $id,
            datestamp  => $id, 
        ) );
        $pos++;
    }
    $self->resumptionToken( new C4::AR::OAI::ResumptionToken(
        metadataPrefix  => $token->{metadata_prefix},
        from            => $token->{from},
        until           => $token->{until},
        offset          => $pos ) );
    return $self;
}
1;