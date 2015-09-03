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
# along with Meran.  If not, see <http://www.gnu.org/licenses/>.package C4::Modelo::AdqRecomendacion;
use strict;
use utf8;
use C4::AR::Permisos;
use C4::AR::Utilidades;
use C4::Modelo::UsrSocio;
use C4::Modelo::RefEstadoPresupuesto;
use base qw(C4::Modelo::DB::Object::AutoBase2);
__PACKAGE__->meta->setup(
    table   => 'adq_recomendacion',
    columns => [
        id                                  => { type => 'integer', overflow => 'truncate', not_null => 1 },
        usr_socio_id                        => { type => 'integer', overflow => 'truncate', not_null => 1},
        fecha                               => { type => 'varchar', overflow => 'truncate', length => 255, not_null => 1},
        activa                              => { type => 'integer', overflow => 'truncate', length => 4, not_null => 1},
        adq_ref_tipo_recomendacion_id       => { type => 'varchar', overflow => 'truncate', length => 50,not_null => 1},
    ],
    relationships =>
    [
      ref_usr_socio => 
      {
         class       => 'C4::Modelo::UsrSocio',
         key_columns => {usr_socio_id => 'nro_socio' },
         type        => 'one to many',
       },
      
      adq_ref_tipo_recomendacion_id => 
      {
        class       => 'C4::Modelo::AdqRefTipoRecomendacion',
        key_columns => {adq_ref_tipo_recomendacion_id => 'id' },
        type        => 'one to many',
      },
    ],
    
    primary_key_columns => [ 'id' ],
    unique_key          => ['id'],
);
sub desactivar{
    my ($self) = shift;
    $self->setActiva(0);
    $self->save();
}
sub activar{
    my ($self) = shift;
    $self->setActiva(1);
    $self->save();
}
sub eliminar{
    my ($self)      = shift;
    my ($params)    = @_;
    $self->delete();    
}
sub agregarRecomendacion{
    my ($self) = shift;
    my ($usr_socio_id) = @_;
    $self->setUsrSocioId($usr_socio_id);
   
    #$self->setAdqRefTipoRecomendacionId($params->{'adq_ref_tipo_recomendacion_id'});
    
    #$self->setUsrSocioId(1);
   
    $self->setAdqRefTipoRecomendacionId(1);
    
    $self->desactivar();
    $self->save();
}
sub setUsrSocioId{
    my ($self)  = shift;
    my ($socio) = @_;
    utf8::encode($socio);
    $self->usr_socio_id($socio);
}
sub setFecha{
    my ($self)  = shift;
    my ($fecha) = @_;
    $self->fecha($fecha);
}
sub setActiva{
    my ($self)  = shift;
    my ($valor) =  @_;
    $self->activa($valor);
}
sub setAdqRefTipoRecomendacionId{
    my ($self)  = shift;
    my ($valor) = @_;
    utf8::encode($valor);
    $self->adq_ref_tipo_recomendacion_id($valor);
}
sub getId{
    my ($self) = shift;
    return ($self->id);
}
sub getFecha{
    my ($self) = shift;
    return ($self->fecha);
}
sub getActiva{
    my ($self) = shift;
    return ($self->activa);
}
sub getUsrSocioId{
    my ($self) = shift;
    return ($self->usr_socio_id);
}
sub getAdqRefTipoRecomendacionId{
    my ($self) = shift;
    return ($self->adq_ref_tipo_recomendacion_id);
}
