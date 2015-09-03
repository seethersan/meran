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
# along with Meran.  If not, see <http://www.gnu.org/licenses/>.package C4::Modelo::CatPortadaRegistro;
use strict;
use base qw(C4::Modelo::DB::Object::AutoBase2);
__PACKAGE__->meta->setup(
    table   => 'cat_portada_registro',
    columns => [
        id       => { type => 'serial', overflow => 'truncate'},
        isbn => { type => 'varchar', overflow => 'truncate', length => 50,not_null => 1},
        small => { type => 'varchar', overflow => 'truncate', length => 500},
        medium => { type => 'varchar', overflow => 'truncate', length => 500},
        large  => { type => 'varchar', overflow => 'truncate', length => 500},
    ],
    primary_key_columns => [ 'id' ],
);
sub getId{
    my ($self) = shift;
    return ($self->id);
}
sub setId{
    my ($self) = shift;
    my ($id) = @_;
    $self->id($id);
}
sub getIsbn{
    my ($self) = shift;
    return ($self->isbn);
}
sub setIsbn{
    my ($self) = shift;
    my ($isbn) = @_;
    $self->isbn($isbn);
}
sub getSmall{
    my ($self) = shift;
    return ($self->small);
}
sub setSmall{
    my ($self) = shift;
    my ($small) = @_;
    $self->small($small);
}
sub getMedium{
    my ($self) = shift;
    return ($self->medium);
}
sub setMedium{
    my ($self) = shift;
    my ($medium) = @_;
    $self->medium($medium);
}
sub getLarge{
    my ($self) = shift;
    return ($self->large);
}
sub setLarge{
    my ($self) = shift;
    my ($large) = @_;
    $self->large($large);
}
1;
