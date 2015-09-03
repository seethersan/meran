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
# along with Meran.  If not, see <http://www.gnu.org/licenses/>.package C4::Modelo::AdqProveedorMoneda;
use strict;
use utf8;
use C4::AR::Permisos;
use C4::AR::Utilidades;
use base qw(C4::Modelo::DB::Object::AutoBase2);
__PACKAGE__->meta->setup(
    table   => 'adq_ref_proveedor_moneda',
    columns => [
        adq_proveedor_id    => { type => 'integer', overflow => 'truncate', length => 11, not_null => 1 },
        adq_ref_moneda_id   => { type => 'integer', overflow => 'truncate', length => 11, not_null => 1},
    ],
    relationships =>
        [
          moneda_ref => 
          {
            class       => 'C4::Modelo::RefAdqMoneda',
            key_columns => { adq_ref_moneda_id => 'id' },
            type        => 'one to one',
          },
          proveedor_ref => 
          {
            class       => 'C4::Modelo::AdqProveedor',
            key_columns => { adq_proveedor_id => 'id' },
            type        => 'one to one',
          },
      ],
    primary_key_columns => [ 'adq_proveedor_id' ,'adq_ref_moneda_id'],
);
sub eliminar{
    my ($self)      = shift;
    my ($params)    = @_;
    $self->delete();    
}
sub agregarMonedaProveedor{
    my ($self) = shift;
    my ($data) = @_;
    $self->setProveedorId($data->{'id_proveedor'});
    $self->setMonedaId($data->{'id_moneda'});
    $self->save();
}
sub setProveedorId{
    my ($self)         = shift;
    my ($id_proveedor) = @_;
    $self->adq_proveedor_id($id_proveedor);
}
sub setMonedaId{
    my ($self)      = shift;
    my ($id_moneda) = @_;
    $self->adq_ref_moneda_id($id_moneda);
}
1;
