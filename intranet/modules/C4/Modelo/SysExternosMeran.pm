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
# along with Meran.  If not, see <http://www.gnu.org/licenses/>.package C4::Modelo::SysExternosMeran;
use strict;
use base qw(C4::Modelo::DB::Object::AutoBase2);
__PACKAGE__->meta->setup(
    table   => 'sys_externos_meran',
    columns => [
        id              => { type => 'serial', overflow => 'truncate', length => 16 },
        id_ui           => { type => 'varchar', overflow => 'truncate', not_null => 1, length => 4 },
        url             => { type => 'varchar', overflow => 'truncate', not_null => 1, length => 255 },
    ],
    primary_key_columns => [ 'id' ],
     
    relationships =>
    [
      ui => 
      {
        class       => 'C4::Modelo::PrefUnidadInformacion',
        key_columns => { id_ui => 'id_ui' },
        type        => 'one to one',
      },
    ]
);
sub agregar{
    my ($self) = shift;
    my ($params) = @_;
    $self->setId_iu($params-{'id_ui'});
    $self->setUrl($params-{'url'});
    return($self->save());
}
sub add{
    my ($self) = shift;
    my ($url, $id_ui) = @_;
    $self->id_ui($id_ui);
    $self->url($url);
}
sub edit{
    my ($self) = shift;
    my ($url, $id_ui) = @_;
    $self->id_ui($id_ui);
    $self->url($url);
}
sub getId{
    my ($self) = shift;
    return ($self->id);
}
sub getId_ui{
    my ($self) = shift;
    return ($self->id_ui);
}
sub getUrl{
    my ($self) = shift;
    return ($self->url);
}
sub setId_ui{
    my ($self)  = shift;
    my ($id_ui) = @_;
    $self->id_ui($id_ui);
}
sub setUrl{
    my ($self)  = shift;
    my ($url) = @_;
    $self->url($url);
}
1;