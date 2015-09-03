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
# along with Meran.  If not, see <http://www.gnu.org/licenses/>.package C4::Modelo::BackgroundJob;
use strict;
use base qw(C4::Modelo::DB::Object::AutoBase2);
__PACKAGE__->meta->setup(
    table   => 'background_job',
    columns => [
        id      => { type => 'serial', overflow => 'truncate', not_null => 1 },
        name    => { type => 'varchar', overflow => 'truncate', length => 255, not_null => 0},
        jobID   => { type => 'varchar', overflow => 'truncate', length => 255, not_null => 0},
        progress=> { type => 'float', length => 11, overflow => 'truncate', not_null => 0},
        size    => { type => 'integer', overflow => 'truncate', not_null => 0},
        status  => { type => 'varchar', overflow => 'truncate', length => 255, not_null => 0},
        invoker => { type => 'varchar', overflow => 'truncate', length => 255, not_null => 0},
    ],
    primary_key_columns => [ 'id' ],
    unique_key => [ 'jobID' ],
);
use C4::Modelo::BackgroundJob::Manager;
    
sub getName{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->name));
}
    
sub setName{
    my ($self) = shift;
    my ($name) = @_;
    $self->name($name);
}
1;
