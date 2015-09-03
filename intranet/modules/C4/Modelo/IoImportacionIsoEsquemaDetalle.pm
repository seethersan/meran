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
# along with Meran.  If not, see <http://www.gnu.org/licenses/>.package C4::Modelo::IoImportacionIsoEsquemaDetalle;
use strict;
use utf8;
use base qw(C4::Modelo::DB::Object::AutoBase2);
__PACKAGE__->meta->setup(
    table   => 'io_importacion_iso_esquema_detalle',
    columns => [
        id                          => { type => 'integer',     overflow => 'truncate', length => 11,   not_null => 1 },
        id_importacion_esquema      => { type => 'integer',     overflow => 'truncate', length => 11,   not_null => 1},
        campo_origen                => { type => 'character',   overflow => 'truncate', length => 3,    not_null => 1},
        subcampo_origen             => { type => 'character',   overflow => 'truncate', length => 1,    not_null => 1},
        campo_destino               => { type => 'character',   overflow => 'truncate', length => 3,    },
        subcampo_destino            => { type => 'character',   overflow => 'truncate', length => 1,    },
        nivel                       => { type => 'integer',     overflow => 'truncate', length => 2,   },
        ignorar                     => { type => 'integer',     overflow => 'truncate', length => 2,   not_null => 1, default => 0},
        orden                       => { type => 'integer',     overflow => 'truncate', length => 2, default => 0  },
        separador                   => { type => 'varchar', 	overflow => 'truncate', length => 32},
    ],
    relationships =>
    [
      esquema =>
      {
        class       => 'C4::Modelo::IoImportacionIsoEsquema',
         key_columns => {id_importacion_esquema => 'id' },
         type        => 'one to one',
       },
    ],
    primary_key_columns => [ 'id' ],
    unique_key          => ['id_importacion_esquema','campo_origen','subcampo_origen','campo_destino','subcampo_destino','orden']
);
sub agregar{
    my ($self)   = shift;
    my ($params) = @_;
    $self->setIdImportacionEsquema($params->{'id_importacion_esquema'});
    $self->setCampoOrigen($params->{'campo'});
    $self->setSubcampoOrigen(lc($params->{'subcampo'}));
    $self->save();
}
sub getDestino{
    my ($self) = shift;
    my $campo_origen = $self->getCampoOrigen;
    my $subcampo_origen = $self->getSubcampoOrigen;
    
    my @filtros;
    push(@filtros,(id_importacion_esquema => {eq => $self->getIdImportacionEsquema}));
    push (@filtros, (campo_origen => {eq =>$campo_origen}) );
    push (@filtros, (subcampo_origen => {eq =>$subcampo_origen}) );
    my $matches = C4::Modelo::IoImportacionIsoEsquemaDetalle::Manager->get_io_importacion_iso_esquema_detalle(query => \@filtros,);
    
    
    my $destino_string = "";
    foreach my $destino (@$matches){
    	if (C4::AR::Utilidades::validateString($destino->getCampoDestino)){
    	   $destino_string .= $destino->getCampoDestino."\$".(lc $destino->getSubcampoDestino)." ";
    	}
    }
    
    return $destino_string;
	
}
sub setIdImportacionEsquema {
    my ($self) = shift;
    my ($esquema) = @_;
    $self->id_importacion_esquema($esquema);
}
sub setCampoOrigen{
    my ($self)  = shift;
    my ($campo) = @_;
    $self->campo_origen($campo);
}
sub setSubcampoOrigen{
    my ($self)  = shift;
    my ($subcampo) = @_;
    $self->subcampo_origen($subcampo);
}
sub setCampoDestino{
    my ($self)  = shift;
    my ($campo) = @_;
    $self->campo_destino($campo);
}
sub setSubcampoDestino{
    my ($self)  = shift;
    my ($subcampo) = @_;
    $self->subcampo_destino($subcampo);
}
sub getId{
    my ($self) = shift;
    return ($self->id);
}
sub getIdImportacionEsquema {
    my ($self) = shift;
    return $self->id_importacion_esquema;
}
sub getCampoOrigen{
    my ($self)  = shift;
    return $self->campo_origen;
}
sub getSubcampoOrigen{
    my ($self)  = shift;
    return $self->subcampo_origen;
}
sub getCampoDestino{
    my ($self)  = shift;
    return $self->campo_destino;
}
sub getSubcampoDestino{
    my ($self)  = shift;
    return $self->subcampo_destino;
}
sub getNivel{
    my ($self)  = shift;
    return $self->nivel;
}
sub setNivel{
    my ($self)  = shift;
    my ($nivel) = @_;
    $self->nivel($nivel);
}
sub getIgnorar{
    my ($self)  = shift;
    return $self->ignorar;
}
sub getIgnorarFront{
    my ($self)  = shift;
    return (C4::AR::Utilidades::translateYesNo_fromNumber($self->ignorar));
}
sub setIgnorar{
    my ($self)  = shift;
    my ($value) = @_;
    $self->ignorar($value);
}
sub setIgnorarFront{
    my ($self)  = shift;
    my ($value) = @_;
    use C4::Modelo::IoImportacionIsoEsquemaDetalle::Manager;
    $value = C4::AR::Utilidades::translateYesNo_toNumber($value);
    my @filtros;
    push(@filtros,(id_importacion_esquema => {eq => $self->getIdImportacionEsquema}));
    push(@filtros,(campo_origen => {eq => $self->getCampoOrigen}));
    push(@filtros,(subcampo_origen => {eq => $self->getSubcampoOrigen}));
    my $detalle_esquema = C4::Modelo::IoImportacionIsoEsquemaDetalle::Manager->update_io_importacion_iso_esquema_detalle(
                                                                                                        where => \@filtros,
                                                                                                        set => { ignorar => $value },
    );    
}
sub getOrden{
    my ($self)  = shift;
    return ($self->orden);
}
sub setOrden{
    my ($self)  = shift;
    my ($orden) = @_;
    $self->orden($orden);
}
sub getSeparador{
    my ($self)  = shift;
    my $value = $self->separador; 
    chop($value); #quito el | agregado 
    return ($value); 
}
sub setSeparador{
    my ($self)  = shift;
    my ($separador) = @_;
    
    if (!C4::AR::Utilidades::validateString($separador)){
        $separador = " ";
    }
    $self->separador($separador."|"); # se agrega el | para delimitar el string (PROBLEMA DE STRINGS EN MYSQL: QUITA LOS ESPACIOS FINALES)
}
sub setNextOrden{
    my ($self)  = shift;
    
    use C4::Modelo::IoImportacionIsoEsquemaDetalle::Manager;
    
    my @filtros;
    push(@filtros,(id_importacion_esquema => {eq => $self->getIdImportacionEsquema}));
    push(@filtros,(campo_origen => {eq => $self->getCampoOrigen}));
    push(@filtros,(subcampo_origen => {eq => $self->getSubcampoOrigen}));
    my $detalle_esquema = C4::Modelo::IoImportacionIsoEsquemaDetalle::Manager->get_io_importacion_iso_esquema_detalle(
                                                                                                        query => \@filtros,
                                                                                                        sort_by => ['orden DESC'],
    );
    
    my $new_orden = $detalle_esquema->[0]->getOrden();
    $self->setOrden(++$new_orden);    
	
}
