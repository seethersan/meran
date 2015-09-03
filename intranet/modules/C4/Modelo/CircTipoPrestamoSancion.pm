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
# along with Meran.  If not, see <http://www.gnu.org/licenses/>.package C4::Modelo::CircTipoPrestamoSancion;
use strict;
use base qw(C4::Modelo::DB::Object::AutoBase2);
__PACKAGE__->meta->setup(
    table   => 'circ_tipo_prestamo_sancion',
    columns => [
        tipo_sancion    => { type => 'integer', overflow => 'truncate', not_null => 1 },
        tipo_prestamo   => { type => 'character', overflow => 'truncate', length => 2, not_null => 1 }
    ],
    primary_key_columns => [ 'tipo_sancion', 'tipo_prestamo' ],
	
	relationships => [
	    ref_tipo_sancion => {
            class      => 'C4::Modelo::CircTipoSancion',
            column_map => { tipo_sancion => 'tipo_sancion' },
            type       => 'one to one',
        },
	    ref_tipo_prestamo => {
            class      => 'C4::Modelo::CircRefTipoPrestamo',
            column_map => { tipo_prestamo => 'id_tipo_prestamo' },
            type       => 'one to one',
        },
    ],
);
sub getTipo_prestamo{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->tipo_prestamo));
}
sub setTipo_prestamo{
    my ($self) = shift;
    my ($tipo_prestamo) = @_;
    $self->tipo_prestamo($tipo_prestamo);
}
sub getTipo_sancion{
    my ($self) = shift;
    return ($self->tipo_sancion);
}
sub setTipo_sancion{
    my ($self) = shift;
    my ($tipo_sancion) = @_;
    $self->tipo_sancion($tipo_sancion);
}
1;
