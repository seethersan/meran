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
# along with Meran.  If not, see <http://www.gnu.org/licenses/>.package C4::Modelo::SysNovedadNoMostrar;
use strict;
use base qw(C4::Modelo::DB::Object::AutoBase2);
__PACKAGE__->meta->setup(
    table   => 'sys_novedad_no_mostrar',
    columns => [
        id_novedad      => { type => 'integer', overflow => 'truncate', not_null => 1, length => 16 },
        usuario_novedad => { type => 'varchar', overflow => 'truncate', not_null => 1, length => 16 },
    ],
    primary_key_columns => [ 'id_novedad', 'usuario_novedad' ],
);
sub agregar{
    my ($self) = shift;
    my (%params) = @_;
    my $usuario = C4::AR::Auth::getSessionNroSocio();
    $self->setIdNovedad($params{'id_novedad'});
    $self->setUsuarioNovedad($usuario);
    return($self->save());
}
sub getIdNovedad{
    my ($self) = shift;
    return ($self->id_novedad);
}
sub setIdNovedad{
    my ($self) = shift;
    my ($id_novedad) = @_;
    $self->id_novedad($id_novedad);
}
sub getUsuarioNovedad{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->usuario_novedad));
}
sub setUsuarioNovedad{
    my ($self) = shift;
    my ($usuario_novedad) = @_;
    $self->usuario_novedad($usuario_novedad);
}
1;
