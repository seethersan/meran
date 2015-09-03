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
# along with Meran.  If not, see <http://www.gnu.org/licenses/>.package C4::Modelo::CatEncabezadoCampoOpac;
use strict;
use C4::Modelo::CatEncabezadoItemOpac;
use utf8;
use base qw(C4::Modelo::DB::Object::AutoBase2);
__PACKAGE__->meta->setup(
    table   => 'cat_encabezado_campo_opac',
    columns => [
        idencabezado => { type => 'serial', overflow => 'truncate', not_null => 1 },
        nombre       => { type => 'varchar', overflow => 'truncate', length => 255, not_null => 1 },
        orden        => { type => 'integer', overflow => 'truncate', not_null => 1 },
        linea        => { type => 'integer', overflow => 'truncate', default => '0', not_null => 1 },
		visible      => { type => 'integer', overflow => 'truncate', default => '1', not_null => 1 },
        nivel        => { type => 'integer', overflow => 'truncate', not_null => 1 },
    ],
    primary_key_columns => [ 'idencabezado' ],
	relationships =>
    [
        cat_encabezado_item_opac => 
        {
            class       => 'C4::Modelo::CatEncabezadoItemOpac',
            key_columns => { idencabezado => 'idencabezado' },
            type        => 'one to one',
        },
	]
);
=item
  orden        => { type => 'integer', overflow => 'truncate', not_null => 1 },
        linea        => { type => 'integer', overflow => 'truncate', default => '0', not_null => 1 },
        visible      => { type => 'integer', overflow => 'truncate', default => '1', not_null => 1 },
        nivel        => { type => 'integer', overflow => 'truncate', not_null => 1 },
=cut
sub agregar{
	my ($self)=shift;
	my ($data_hash) = @_;
	$self->setNivel($data_hash->{'nivel'});
	$self->setOrden($data_hash->{'orden'});
	$self->setNombre($data_hash->{'nombre'});
	$self->save();
	$data_hash->{'idencabezado'}= $self->getIdEncabezado;
	my $db= $data_hash->{'db'};
	my $tipo_documentos_array_ref= $data_hash->{'tipo_documentos_array'};
	my $cant= scalar(@$tipo_documentos_array_ref);
 	for (my $i=0;$i<$cant;$i++){
		my  $cat_encabezado_item_opac_temp = C4::Modelo::CatEncabezadoItemOpac->new(db => $data_hash->{'db'});
		$data_hash->{'tipo_documento'}= $tipo_documentos_array_ref->[$i]->{'ID'};
		$cat_encabezado_item_opac_temp->agregar($data_hash);
 	}
}
sub modificar{
	my ($self)=shift;
	my ($data_hash) = @_;
	$self->setNivel($data_hash->{'nivel'});
	$self->setOrden($data_hash->{'orden'});
	$self->setNombre($data_hash->{'nombre'});
	$self->save();
}
sub getNivel{
    my ($self)=shift;
    return $self->nivel;
}
sub setNivel{
    my ($self) = shift;
    my ($nivel) = @_;
    $self->nivel($nivel);
}
sub setLinea{
    my ($self) = shift;
    my ($linea) = @_;
    $self->linea($linea);
}
sub getLinea{
    my ($self)=shift;
    return $self->linea;
}
sub getNombre{
    my ($self)=shift;
    return $self->nombre;
}
sub setNombre{
    my ($self) = shift;
    my ($nombre) = @_;
	utf8::encode($nombre);
    $self->nombre($nombre);
}
sub getOrden{
    my ($self)=shift;
    return $self->orden;
}
sub setOrden{
    my ($self) = shift;
    my ($orden) = @_;
    $self->orden($orden);
}
sub getIdEncabezado{
    my ($self)=shift;
    return $self->idencabezado;
}
sub setVisible{
    my ($self) = shift;
    my ($visible) = @_;
    $self->visible($visible);
}
sub getVisible{
	my ($self) = shift;
    return $self->visible;
}
sub cambiarNombre{
	my ($self)= shift;
	my ($nombre) = @_;
	$self->setNombre($nombre);
	$self->save();
}
sub cambiarLinea {
	my ($self)= shift;
	$self->setLinea(!$self->getLinea);
	$self->save();
}
sub cambiarVisibilidad {
	my ($self)= shift;
	$self->setVisible(!$self->getVisible);
	$self->save();
}
1;
