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
package C4::AR::OAI::ListMetadataFormats;
use strict;
use warnings;
use diagnostics;
use HTTP::OAI;
use base ("HTTP::OAI::ListMetadataFormats");
sub new {
    my ($class, $repository) = @_;
    my $self = $class->SUPER::new();
    $self->metadataFormat( HTTP::OAI::MetadataFormat->new(
        metadataPrefix    => 'oai_dc',
        schema            => 'http://www.openarchives.org/OAI/2.0/oai_dc.xsd',
        metadataNamespace => 'http://www.openarchives.org/OAI/2.0/oai_dc/'
    ) );
    $self->metadataFormat( HTTP::OAI::MetadataFormat->new(
        metadataPrefix    => 'marcxml',
        schema            => 'http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd',
        metadataNamespace => 'http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim'
    ) );
    return $self;
}
1;
