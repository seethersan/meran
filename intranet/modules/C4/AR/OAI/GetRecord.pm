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
package C4::AR::OAI::GetRecord;
use strict;
use warnings;
use diagnostics;
use HTTP::OAI;
use C4::AR::OAI::Record;
use MARC::Crosswalk::DublinCore;
use C4::AR::Nivel1;
use base ("HTTP::OAI::GetRecord");
sub new {
    my ($class, $repository, %args) = @_;
    my $self = HTTP::OAI::GetRecord->new(%args);
    my $prefix = $repository->{meran_identifier} . ':';
    my ($id1) = $args{identifier} =~ /^$prefix(.*)/;
    
    my $nivel1 = C4::AR::Nivel1::getNivel1FromId1($id1);
    unless ( $nivel1 ) {
        return HTTP::OAI::Response->new(
            requestURL  => $repository->self_url(),
            errors      => [ new HTTP::OAI::Error(
                code    => 'idDoesNotExist',
                message => "There is no record with this identifier",
                ) ] ,
        );
    }
    
    $self->record( C4::AR::OAI::Record->new($repository, $nivel1->getMarcRecord , $nivel1->getId, %args ));
    return $self;
}
1;