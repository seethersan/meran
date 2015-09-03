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
# along with Meran.  If not, see <http://www.gnu.org/licenses/>.package C4::Modelo::PrefTablaReferenciaRelCatalogo;
use strict;
use base qw(C4::Modelo::DB::Object::AutoBase2);
__PACKAGE__->meta->setup(
    table   => 'pref_tabla_referencia_rel_catalogo',
    columns => [
        id              => { type => 'serial', overflow => 'truncate'},
        alias_tabla     => { type => 'varchar', overflow => 'truncate', length => 32, not_null => 1 },
        tabla_referente => { type => 'varchar', overflow => 'truncate', length => 32, not_null => 1 },
        campo_referente => { type => 'varchar', overflow => 'truncate', length => 32, not_null => 1 },
        sub_campo_referente => { type => 'varchar', overflow => 'truncate', length => 32, not_null => 0, default => 'NULL' },
    ],
    primary_key_columns => [ 'id' ],
);
use C4::Modelo::PrefTablaReferenciaRelCatalogo::Manager;
sub getAll{
    my ($self) = shift;
    my ($limit,$offset)=@_;
    my $ref_valores = C4::Modelo::RefPais::Manager->get_pref_tabla_referencia_rel_catalogo( limit => $limit, offset => $offset);
    return ($ref_valores);
}
sub getAlias_tabla{
    my ($self) = shift;
        
    return ($self->alias_tabla);
}
sub getTabla_referente{
    my ($self) = shift;
        
    return ($self->tabla_referente);
}
sub getCampo_referente{
    my ($self) = shift;
    return ($self->campo_referente);
}
sub getSub_campo_referente{
    my ($self) = shift;
    return ($self->sub_campo_referente);
}
sub getReferente{
    my ($self) = shift;
    my $campo = $self->getCampo_referente;
    return ($campo);
}
1;
