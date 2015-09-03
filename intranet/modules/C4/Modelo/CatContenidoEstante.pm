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
# along with Meran.  If not, see <http://www.gnu.org/licenses/>.package C4::Modelo::CatContenidoEstante;
use strict;
use base qw(C4::Modelo::DB::Object::AutoBase2);
__PACKAGE__->meta->setup(
    table   => 'cat_contenido_estante',
    columns => [
        id_estante  => { type => 'integer', overflow => 'truncate', not_null => 1 },
        id2         => { type => 'integer', overflow => 'truncate', not_null => 1 },
    ],
  primary_key_columns => [ 'id_estante','id2' ],
    relationships => [
        estante  => {
            class       => 'C4::Modelo::CatEstante',
            key_columns => { id_estante => 'id' },
            type        => 'one to one',
        },
        nivel2  => {
            class       => 'C4::Modelo::CatRegistroMarcN2',
            key_columns => { id2 => 'id' },
            type        => 'one to one',
        },
    ],
);
use C4::Modelo::CatEstante;
sub getId2{
    my ($self) = shift;
    return ($self->id2);
}
sub setId2{
    my ($self) = shift;
    my ($id2) = @_;
    $self->id2($id2);
}
sub getId_estante{
    my ($self) = shift;
    return ($self->id_estante);
}
sub setId_estante{
    my ($self) = shift;
    my ($id_estante) = @_;
    $self->id_estante($id_estante);
}
1;
