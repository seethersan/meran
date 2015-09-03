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
# along with Meran.  If not, see <http://www.gnu.org/licenses/>.package C4::Modelo::CatControlSinonimoTema;
use strict;
use base qw(C4::Modelo::DB::Object::AutoBase2);
__PACKAGE__->meta->setup(
    table   => 'cat_control_sinonimo_tema',
    columns => [
        id   => { type => 'serial', overflow => 'truncate', not_null => 1 },
        tema => { type => 'varchar', overflow => 'truncate', length => 255, not_null => 1 },
    ],
    primary_key_columns => [ 'id', 'tema' ],
);
sub agregar{
    my ($self)=shift;
    my ($sinonimo,$id_tema)=@_;
    $self->setTema($sinonimo);
    $self->setId($id_tema);
    $self->save();
}
sub getId{
    my ($self)=shift;
    return ($self->id);
}
sub setId{
    my ($self)=shift;
    my ($id) = @_;
    return ($self->id($id));
}
sub getTema{
    my ($self)=shift;
    return ($self->tema);
}
sub setTema{
    my ($self)=shift;
    my ($tema) = @_;
    return ($self->tema($tema));
}
1;
