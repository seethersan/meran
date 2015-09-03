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
# along with Meran.  If not, see <http://www.gnu.org/licenses/>.package C4::Modelo::ImagenesNovedadesOpac;
use strict;
use base qw(C4::Modelo::DB::Object::AutoBase2);
__PACKAGE__->meta->setup(
    table   => 'imagenes_novedades_opac',
    columns => [
        id                  => { type => 'integer', overflow => 'truncate', length => 11, not_null => 1 },
        image_name          => { type => 'varchar', overflow => 'truncate', length => 255, not_null => 1},
        id_novedad          => { type => 'integer', overflow => 'truncate', length => 11, not_null => 1},
    ],
    primary_key_columns => [ 'id' ],
    
    relationships =>
    [
      novedad => 
      {
        class       => 'C4::Modelo::SysNovedad',
        key_columns => { id_novedad => 'id' },
        type        => 'many to one',
      },
    ]
);
=item
    Agrega una tupla en la tabla
=cut
sub saveImagenNovedad{
    my ($self) = shift;
    my ($image_name, $id_novedad) = @_;
    $self->setImageName($image_name);
    $self->setIdNovedad($id_novedad);
    $self->save();
}
sub setImageName{
    my ($self)   = shift;
    my ($image_name) = @_;
    #FIXME: hash del nombre de imagen
    
    $self->image_name($image_name);
    
}
sub setIdNovedad{
    my ($self) = shift;
    my ($id_novedad) = @_;
    $self->id_novedad($id_novedad);
    
}
sub getIdNovedad{
    my ($self) = shift;
    return ($self->id_novedad);
    
}
sub getImageName{
    my ($self)   = shift;
    return($self->image_name)
}
sub getId{
    my ($self)   = shift;
    return($self->id)
}
1;
