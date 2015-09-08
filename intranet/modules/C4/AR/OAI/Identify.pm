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
package C4::AR::OAI::Identify;
use strict;
use warnings;
use diagnostics;
use HTTP::OAI;
use C4::Context;
use base ("HTTP::OAI::Identify");
sub new {
    my ($class, $repository) = @_;
    my ($baseURL) = $repository->self_url() =~ /(.*)\?.*/;
    my $self = $class->SUPER::new(
        baseURL             => $baseURL,
        repositoryName      => C4::AR::Preferencias::getValorPreferencia("titulo_nombre_ui"),
        adminEmail          => C4::AR::Preferencias::getValorPreferencia("mailFrom"),
        MaxCount            => C4::AR::Preferencias::getValorPreferencia("OAI-PMH:MaxCount"),
        granularity         => 'YYYY-MM-DD',
        earliestDatestamp   => C4::Modelo::IndiceBusqueda::Manager->get_minimum_timestamp(),
    );
    $self->description(C4::AR::Preferencias::getValorPreferencia("OAI-PMH:archiveID"));
    $self->compression( 'gzip' );
    return $self;
}
1;