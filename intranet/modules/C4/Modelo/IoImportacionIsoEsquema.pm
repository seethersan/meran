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
# along with Meran.  If not, see <http://www.gnu.org/licenses/>.package C4::Modelo::IoImportacionIsoEsquema;
use strict;
use utf8;
use base qw(C4::Modelo::DB::Object::AutoBase2);
__PACKAGE__->meta->setup(
    table   => 'io_importacion_iso_esquema',
    columns => [
        id                        => { type => 'integer', overflow => 'truncate', length => 11, not_null => 1 },
        nombre                    => { type => 'varchar',     overflow => 'truncate', length => 255,  not_null => 1},
        descripcion               => { type => 'text', overflow => 'truncate'},
    ],
    relationships =>
    [
      detalle =>
      {
         class       => 'C4::Modelo::IoImportacionIsoEsquemaDetalle',
         key_columns => {id => 'id_importacion_esquema' },
         type        => 'one to many',
       },
    ],
    primary_key_columns => [ 'id' ],
    unique_key          => ['id'],
);
sub agregar{
    my ($self)   = shift;
    my ($params) = @_;
    $self->setNombre($params->{'nombre'});
    $self->setDescripcion($params->{'descripcion'});
    $self->save();
}
sub setNombre{
    my ($self) = shift;
    my ($nombre) = @_;
    utf8::encode($nombre);
    $self->nombre($nombre);
}
sub setDescripcion{
    my ($self)  = shift;
    my ($descripcion) = @_;
    $self->descripcion($descripcion);
}
sub getId{
    my ($self) = shift;
    return ($self->id);
}
sub getNombre{
    my ($self) = shift;
    return $self->nombre;
}
sub getDescripcion{
    my ($self)  = shift;
    return $self->descripcion;
}
sub getDetalleSubcamposByCampoDestino{
    my ($self)  = shift;
    my ($campo) = @_;
    require C4::Modelo::IoImportacionIsoEsquemaDetalle;
    require C4::Modelo::IoImportacionIsoEsquemaDetalle::Manager;
    my @filtros;
    push(@filtros,(id_importacion_esquema   => { eq => $self->getId }));
    push(@filtros,(campo_destino            => { eq => $campo}));
    my $detalleTemp = C4::Modelo::IoImportacionIsoEsquemaDetalle->new();
    my $ordenAux= $detalleTemp->sortByString('orden');
    my $detalle_completo = C4::Modelo::IoImportacionIsoEsquemaDetalle::Manager->get_io_importacion_iso_esquema_detalle(
                                                                                        query => \@filtros,
                                                                                        distinct => 1,
                                                                                        select => [ 'subcampo_destino' ],
                                                                                        );
    ########### FIXME!
    return $detalle_completo;
}
sub getDetalleByCampoSubcampoDestino{
    my ($self)  = shift;
    my ($campo,$subcampo) = @_;
    require C4::Modelo::IoImportacionIsoEsquemaDetalle;
    require C4::Modelo::IoImportacionIsoEsquemaDetalle::Manager;
    my @filtros;
    push(@filtros,(id_importacion_esquema   => { eq => $self->getId }));
    push(@filtros,(campo_destino            => { eq => $campo}));
    push(@filtros,(subcampo_destino         => { eq => $subcampo }));
    my $detalleTemp = C4::Modelo::IoImportacionIsoEsquemaDetalle->new();
    my $ordenAux= $detalleTemp->sortByString('orden');
    my $detalle_completo = C4::Modelo::IoImportacionIsoEsquemaDetalle::Manager->get_io_importacion_iso_esquema_detalle(
                                                                                        query => \@filtros,
                                                                                        sort_by => $ordenAux,
     );
    return $detalle_completo;
}
sub getDetalleDestino{
    my ($self)  = shift;
    require C4::Modelo::IoImportacionIsoEsquemaDetalle;
    require C4::Modelo::IoImportacionIsoEsquemaDetalle::Manager;
    my @filtros;
    push(@filtros,(id_importacion_esquema   => { eq => $self->getId }));
    push(@filtros,(campo_destino            => { ne => undef}));
    push(@filtros,(subcampo_destino         => { ne => undef}));
    my $detalleTemp = C4::Modelo::IoImportacionIsoEsquemaDetalle->new();
    my $ordenAux= $detalleTemp->sortByString('orden');
    my $detalle_completo = C4::Modelo::IoImportacionIsoEsquemaDetalle::Manager->get_io_importacion_iso_esquema_detalle(
                                                                                        distinct => 1,
                                                                                        select => [ 'campo_destino','subcampo_destino' ],
                                                                                        query => \@filtros,
                                                                                        sort_by => $ordenAux,
     );
    return $detalle_completo;
}
sub getDetalleByCampoSubcampoOrigen{
    my ($self)  = shift;
    my ($campo,$subcampo) = @_;
    require C4::Modelo::IoImportacionIsoEsquemaDetalle;
    require C4::Modelo::IoImportacionIsoEsquemaDetalle::Manager;
    my @filtros;
    push(@filtros,(id_importacion_esquema   => { eq => $self->getId }));
    push(@filtros,(campo_origen            => { eq => [lc($campo),uc($campo)]}));
    push(@filtros,(subcampo_origen            => { eq => $subcampo}));
    push(@filtros,(campo_destino            => { ne => undef}));
    my $detalleTemp = C4::Modelo::IoImportacionIsoEsquemaDetalle->new();
    my $ordenAux= $detalleTemp->sortByString('orden');
    my $detalle_completo = C4::Modelo::IoImportacionIsoEsquemaDetalle::Manager->get_io_importacion_iso_esquema_detalle(
                                                                                        query => \@filtros,
                                                                                        distinct => 1,
                                                                                        select => ['campo_destino', 'subcampo_destino' ],
                                                                                        );
    ########### FIXME!
    return $detalle_completo->[0];
}