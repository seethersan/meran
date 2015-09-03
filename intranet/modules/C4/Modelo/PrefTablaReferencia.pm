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
# along with Meran.  If not, see <http://www.gnu.org/licenses/>.package C4::Modelo::PrefTablaReferencia;
use strict;
use base qw(C4::Modelo::DB::Object::AutoBase2);
__PACKAGE__->meta->setup(
    table   => 'pref_tabla_referencia',
    columns => [
        id                  => { type => 'serial', overflow => 'truncate'},
        nombre_tabla        => { type => 'varchar', overflow => 'truncate', length => 40, not_null => 1 },
        alias_tabla         => { type => 'varchar', overflow => 'truncate', length => 20, not_null => 1 },
        campo_busqueda      => { type => 'varchar', overflow => 'truncate', length => 255, not_null => 1 },
        client_title        => { type => 'varchar', overflow => 'truncate', length => 255},
        is_editable         => { type => 'integer', overflow => 'truncate', length => 1, not_null => 0, default => 1 },       
    ],
    primary_key_columns => [ 'id' ],
);
use C4::Modelo::PrefTablaReferencia::Manager;
sub getAliasForTable {
    my ($self) = shift;
    my ($nombre_tabla) = @_;
    my $db = C4::Modelo::PrefTablaReferencia::Manager->get_pref_tabla_referencia(
                                                                                query => [
                                                                                           nombre_tabla => { eq  => $nombre_tabla } ,
                                                                                         ],
                                                                            );
    return ($db->[0]->getAlias_tabla);
}
sub createFromAlias{
    my ($self)=shift;
    my $classAlias = shift;
    my $firstTable = C4::Modelo::CatAutor->new();
       
	return( $firstTable->createFromAlias($classAlias) );
}
sub getObjeto{
	my ($self)=shift;
    my $classAlias = shift;
    my $firstTable = C4::Modelo::CatAutor->new();
       
	return( $firstTable->createFromAlias($classAlias) );
}
sub getId{
    my ($self) = shift;
    return ($self->id);
}
sub getNombre_tabla{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->nombre_tabla));
}
sub setNombre_tabla{
    my ($self) = shift;
    my ($nombre_tabla) = @_;
    $self->nombre_tabla($nombre_tabla);
}
sub getAlias_tabla{
    my ($self) = shift;
    return ($self->alias_tabla);
}
sub setAlias_tabla{
    my ($self) = shift;
    my ($alias_tabla) = @_;
    $self->alias_tabla($alias_tabla);
}
sub getClient_title{
    my ($self) = shift;
    return ($self->client_title);
}
sub setClient_title{
    my ($self) = shift;
    my ($client_title) = @_;
    $self->client_title($client_title);
}
sub getCampo_busqueda{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->campo_busqueda));
}
sub obtenerValoresTablaRef{
	my ($self) = shift;
	my ($alias_tabla, $campo, $orden) = @_;
	
	my $ref = $self->createFromAlias($alias_tabla);
	if ($ref){
        my ($cantidad, $valores) = $ref->obtenerValoresCampo($campo, $orden);
        my $default_value = $ref->getDefaultValue($alias_tabla);
        C4::AR::Debug::debug("PrefTablaReferencia => obtenerValoresTablaRef => ".$default_value." para tabla => ".$alias_tabla);
		return ($cantidad, $valores, $default_value);
    }else{
        return 0;
    }
	
}
sub obtenerValorDeReferencia{
	my ($self) = shift;
	my ($alias_tabla, $campo , $id) = @_;
	
	my $ref=$self->createFromAlias($alias_tabla);
	if ($ref){
		my $valor=$ref->obtenerValorCampo($campo,$id);
		return $valor;
		}
	else {
	return 0;
	}
	
}
sub obtenerIdentTablaRef{
	my ($self) = shift;
	my ($alias_tabla) = @_;
	my $ref=$self->createFromAlias($alias_tabla);
	return ($ref->meta->primary_key);
}
sub getIsEditable{
    my ($self) = shift;
    return ($self->is_editable);
}
sub isEditable{
    my ($self) = shift;
    return ($self->is_editable == 1);
}
1;
