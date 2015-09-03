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
# along with Meran.  If not, see <http://www.gnu.org/licenses/>.package C4::Modelo::CatEncabezadoItemOpac;
use strict;
use base qw(C4::Modelo::DB::Object::AutoBase2);
__PACKAGE__->meta->setup(
    table   => 'cat_encabezado_item_opac',
    columns => [
        idencabezado => { type => 'integer', overflow => 'truncate', not_null => 1 },
        itemtype     => { type => 'varchar', overflow => 'truncate', length => 4, not_null => 1 },
    ],
    primary_key_columns => [ 'idencabezado', 'itemtype' ],
);
sub agregar{
	my ($self)=shift;
	my ($data_hash) = @_;
	$self->setTipoDocumento($data_hash->{'tipo_documento'});
	$self->setIdEncabezado($data_hash->{'idencabezado'});
	
	$self->save();
}
sub getIdEncabezado{
    my ($self)=shift;
    return $self->idencabezado;
}
sub setIdEncabezado{
    my ($self) = shift;
    my ($idencabezado) = @_;
    $self->idencabezado($idencabezado);
}
sub getTipoDocumento{
    my ($self)=shift;
    return $self->itemtype;
}
sub setTipoDocumento{
    my ($self) = shift;
    my ($tipo_documento) = @_;
    $self->itemtype($tipo_documento);
}
1;
