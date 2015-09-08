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
package C4::AR::OAI::ListRecords;
use strict;
use warnings;
use diagnostics;
use HTTP::OAI;
use C4::AR::OAI::ResumptionToken;
use C4::AR::OAI::Record;
use C4::AR::ExportacionIsoMARC;
use base ("HTTP::OAI::ListRecords");
sub new {
    my ($class, $repository, %args) = @_;
    my $self = HTTP::OAI::ListRecords->new(%args);
    my @bind=();
    my $token = new C4::AR::OAI::ResumptionToken( %args );
    my $dbh = C4::Context->dbh;
    my $sql = "SELECT * FROM indice_busqueda ";
    if($token->{from} && $token->{until}) {
              $sql.=" WHERE  timestamp >= ? AND timestamp < ? ";
              push(@bind,$token->{from});
              C4::AR::Debug::debug("OAI list records - from => ".$token->{from});
              push(@bind,$token->{until});
              C4::AR::Debug::debug("OAI list records - until => ".$token->{until});
     }
    $sql.=" ORDER BY timestamp ";
    if($repository->{meran_max_count}) {
              $sql.="LIMIT  ".$repository->{meran_max_count}." ";
    }
    
    if($token->{offset}){
                $sql.=" OFFSET ".$token->{offset};
    }
    my $sth = $dbh->prepare($sql);
    $sth->execute(@bind);
    my $pos = $token->{offset};
  C4::AR::Debug::debug("OAI => POS Ini = ".$pos);
    while ( my $record = $sth->fetchrow_hashref ) {
        #arma dinamicamente el  marcxml
        my $marc_record = MARC::Record->new_from_usmarc($record->{"marc_record"});
        $self->record(
          C4::AR::OAI::Record->new(
            $repository,
            $marc_record,
            $record->{"timestamp"},
            $record->{"id"},
            identifier      => $repository->{meran_identifier} . ':' . $record->{"id"},
            metadataPrefix  => $token->{metadata_prefix},
          )
        );
        $pos++;
    }
  C4::AR::Debug::debug("OAI => POS Fin = ".$pos);
  my $total = C4::Modelo::IndiceBusqueda::Manager->get_indice_busqueda_count();
  C4::AR::Debug::debug("OAI => CANT  = ".$total);
  
  if($pos < $total){
    $self->resumptionToken( new C4::AR::OAI::ResumptionToken(
        metadataPrefix  => $token->{metadata_prefix},
        from            => $token->{from},
        until           => $token->{until},
        offset          => $pos ) );
  }
    return $self;
}
1;
