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
# along with Meran.  If not, see <http://www.gnu.org/licenses/>.package C4::Modelo::LogoUI;
use strict;
use base qw(C4::Modelo::DB::Object::AutoBase2);
__PACKAGE__->meta->setup(
    table   => 'logoUI',
    columns => [
        id              => { type => 'serial', overflow => 'truncate', length => 16 },
        nombre          => { type => 'varchar', overflow => 'truncate', not_null => 1, length => 256 },
        imagenPath      => { type => 'varchar', overflow => 'truncate', length => 255, not_null => 1 },
        ancho           => { type => 'varchar', overflow => 'truncate', length => 128 },
        alto            => { type => 'varchar', overflow => 'truncate', length => 128 },
    ],
    primary_key_columns => [ 'id' ],
);
sub agregar{
    my ($self) = shift;
    my ($data_hash) = @_;
    $self->setImagenPath($data_hash->{'imagenPath'});
    $self->setNombre('DEO-booklabels');
    $self->save();
}
sub getId{
    my ($self) = shift;
    return ($self->id);
}
sub getNombre{
    my ($self) = shift;
    return ($self->nombre);
}
sub setNombre{
    my ($self) = shift;
    my ($nombre) = @_;
    $self->nombre($nombre);
}
sub getAncho{
    my ($self) = shift;
    return $self->ancho;
}
sub setAncho{
    my ($self) = shift;
    my ($ancho) = @_;
    $self->ancho($ancho);
}
sub getAlto{
    my ($self) = shift;
    return $self->alto;
}
sub setAlto{
    my ($self) = shift;
    my ($alto) = @_;
    $self->alto($alto);
}
sub getImagenPath{
    my ($self) = shift;
    return $self->imagenPath;
}
sub setImagenPath{
    my ($self) = shift;
    my ($imagenPath) = @_;
    $self->imagenPath($imagenPath);
}
1;
