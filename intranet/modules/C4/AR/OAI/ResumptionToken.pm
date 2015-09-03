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
# along with Meran.  If not, see <http://www.gnu.org/licenses/>.package C4::AR::OAI::ResumptionToken;
use strict;
use warnings;
use diagnostics;
use HTTP::OAI;
use base ("HTTP::OAI::ResumptionToken");
sub new {
    my ($class, %args) = @_;
    my $self = $class->SUPER::new(%args);
    my ($metadata_prefix, $offset, $from, $until);
    if ( $args{ resumptionToken } ) {
        ($metadata_prefix, $offset, $from, $until)
            = split( ':', $args{resumptionToken} );
    }
    else {
        $metadata_prefix = $args{ metadataPrefix };
        $from = $args{ from } || substr(C4::Modelo::IndiceBusqueda::Manager->get_minimum_timestamp(),0,10);  #Min ID - Solo Fecha
        $until = $args{ until };
        unless ( $until) {
            $until = substr(C4::Modelo::IndiceBusqueda::Manager->get_maximum_timestamp(),0,10); #Max ID - Solo Fecha
        }
        $offset = $args{ offset } || 0;
    }
    $self->{ metadata_prefix } = $metadata_prefix;
    $self->{ offset          } = $offset;
    $self->{ from            } = $from;
    $self->{ until           } = $until;
    $self->resumptionToken( join( ':', $metadata_prefix, $offset, $from, $until ));
    $self->cursor( $offset );
    return $self;
}
1;
