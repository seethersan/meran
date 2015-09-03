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
# along with Meran.  If not, see <http://www.gnu.org/licenses/>.package C4::Modelo::RepBusqueda;
use strict;
use base qw(C4::Modelo::DB::Object::AutoBase2);
__PACKAGE__->meta->setup(
    table   => 'rep_busqueda',
    columns => [
        idBusqueda      => { type => 'serial', overflow => 'truncate', not_null => 1 },
        nro_socio       => { type => 'varchar', overflow => 'truncate' , length => 16},
        fecha           => { type => 'varchar', overflow => 'truncate', length => 32, not_null => 1 },
        categoria_socio => { type => 'char', overflow => 'truncate', not_null => 1 , length => 2},
        agregacion_temp => { type => 'varchar', overflow => 'truncate' , length => 255},
        
    ],
    primary_key_columns => [ 'idBusqueda' ],
   
    relationships => [
         socio =>  {
            class       => 'C4::Modelo::UsrSocio',
            key_columns => { nro_socio => 'nro_socio' },
            type        => 'one to one',
      },
         
    ],
);
use C4::Date;
sub agregar{
    my ($self) = shift;
    my ($nro_socio) = @_;
    $self->setNro_socio($nro_socio);
    my $dateformat      = C4::Date::get_date_format();
    my $hoy             = C4::Date::format_date_in_iso(C4::Date::ParseDate("now"), $dateformat);
    $self->setFecha($hoy);
    $self->save();
}
sub getCategoria_socio_report{
   my ($self) = shift;
    if (C4::AR::Utilidades::validateString($self->categoria_socio)){
        return ($self->categoria_socio);
    }else{
        return(C4::AR::Filtros::i18n('Anonimo'));
    }
}
sub getIdBusqueda{
   my ($self) = shift;
   return ($self->idBusqueda);
}
sub getNro_socio{
   my ($self) = shift;
   return ($self->nro_socio);
}
sub getFecha{
   my ($self) = shift;
   return ($self->fecha);
}
sub getFecha_formateada {
    my ($self) = shift;
    my $dateformat = C4::Date::get_date_format();
    return C4::Date::format_date( $self->getFecha, $dateformat );
}
sub setNro_socio{
   my ($self) = shift;
   my ($nro_socio) = @_;
   $self->nro_socio($nro_socio);
}
sub setFecha{
   my ($self) = shift;
   my ($fecha) = @_;
   $self->fecha($fecha);
}
1;
