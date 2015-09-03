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
# along with Meran.  If not, see <http://www.gnu.org/licenses/>.package C4::Modelo::CatControlSeudonimoTema;
use strict;
use base qw(C4::Modelo::DB::Object::AutoBase2);
__PACKAGE__->meta->setup(
    table   => 'cat_control_seudonimo_tema',
    columns => [
        id_tema             => { type => 'integer', overflow => 'truncate', not_null => 1 },
        id_tema_seudonimo   => { type => 'integer', overflow => 'truncate', not_null => 1 },
    ],
    primary_key_columns => [ 'id_tema', 'id_tema_seudonimo' ],
    relationships =>
        [
        tema => 
        {
            class       => 'C4::Modelo::CatTema',
            key_columns => { id_tema => 'id' },
            type        => 'one to one',
        },
        seudonimo => 
        {
            class       => 'C4::Modelo::CatTema',
            key_columns => { id_tema_seudonimo => 'id' },
            type        => 'one to one',
        },
        ],
    );
sub agregar{
    my ($self)=shift;
    my ($id_tema,$id_tema_seudonimo)=@_;
    $self->setIdTema($id_tema);
    $self->setIdTemaSeudonimo($id_tema_seudonimo);
    $self->save();
}
sub getIdTema{
    my ($self)=shift;
    return ($self->id_tema);
}
sub setIdTema{
    my ($self)=shift;
    my ($id_tema) = @_;
    return ($self->id_tema($id_tema));
}
sub getIdTemaSeudonimo{
    my ($self)=shift;
    return ($self->id_tema_seudonimo);
}
sub setIdTemaSeudonimo{
    my ($self)=shift;
    my ($id_tema_seudonimo) = @_;
    return ($self->id_tema_seudonimo($id_tema_seudonimo));
}
1;
