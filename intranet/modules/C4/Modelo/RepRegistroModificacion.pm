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
# along with Meran.  If not, see <http://www.gnu.org/licenses/>.package C4::Modelo::RepRegistroModificacion;
use strict;
use base qw(C4::Modelo::DB::Object::AutoBase2);
__PACKAGE__->meta->setup(
    table   => 'rep_registro_modificacion',
    columns => [
        idModificacion  => { type => 'serial', overflow => 'truncate', not_null => 1 },
        operacion       => { type => 'varchar', overflow => 'truncate', length => 15 },
        fecha           => { type => 'date' },
        responsable     => { type => 'varchar', overflow => 'truncate', length => 16, not_null => 1 },
        nota            => { type => 'text', overflow => 'truncate' },
        tipo            => { type => 'varchar', overflow => 'truncate', length => 15 },
        timestamp       => { type => 'timestamp', not_null => 1 },
        agregacion_temp => { type => 'varchar', overflow => 'truncate', length => 255 },
    ],
    primary_key_columns => [ 'idModificacion' ],
   relationships => [
    socio_responsable => {
            class       => 'C4::Modelo::UsrSocio',
            key_columns => { responsable => 'nro_socio' },
            type        => 'one to one',
    },
   ]
);
sub getIdModificacion{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->idModificacion));
}
sub getNumero{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->numero));
}
sub getNota{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->nota));
}
sub getTipo{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->tipo));
}
sub getOperacion{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->operacion));
}
sub getFecha{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->fecha));
}
1;
