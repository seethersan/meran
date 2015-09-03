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
# along with Meran.  If not, see <http://www.gnu.org/licenses/>.package C4::Modelo::CatControlSeudonimoAutor;
use strict;
use base qw(C4::Modelo::DB::Object::AutoBase2);
__PACKAGE__->meta->setup(
    table   => 'cat_control_seudonimo_autor',
    columns => [
        id_autor            => { type => 'integer', overflow => 'truncate', not_null => 1 },
        id_autor_seudonimo  => { type => 'integer', overflow => 'truncate', not_null => 1 },
    ],
    primary_key_columns => [ 'id_autor', 'id_autor_seudonimo' ],
    relationships =>
    [
      autor => 
      {
        class       => 'C4::Modelo::CatAutor',
        key_columns => { id_autor => 'id' },
        type        => 'one to one',
      },
      seudonimo => 
      {
        class       => 'C4::Modelo::CatAutor',
        key_columns => { id_autor_seudonimo => 'id' },
        type        => 'one to one',
      },
    ],
);
sub agregar{
    my ($self)=shift;
    my ($id_autor,$id_autor_seudonimo)=@_;
    $self->setIdAutor($id_autor);
    $self->setIdAutorSeudonimo($id_autor_seudonimo);
    $self->save();
}
sub getIdAutor{
    my ($self)=shift;
    return ($self->id_autor);
}
sub setIdAutor{
    my ($self)=shift;
    my ($id_autor) = @_;
    return ($self->id_autor($id_autor));
}
sub getIdAutorSeudonimo{
    my ($self)=shift;
    return ($self->id_autor_seudonimo);
}
sub setIdAutorSeudonimo{
    my ($self)=shift;
    my ($id_autor_seudonimo) = @_;
    return ($self->id_autor_seudonimo($id_autor_seudonimo));
}
1;
