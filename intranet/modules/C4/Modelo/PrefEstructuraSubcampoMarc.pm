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
# along with Meran.  If not, see <http://www.gnu.org/licenses/>.package C4::Modelo::PrefEstructuraSubcampoMarc;
use strict;
use base qw(C4::Modelo::DB::Object::AutoBase2);
__PACKAGE__->meta->setup(
    table   => 'pref_estructura_subcampo_marc',
    columns => [
        nivel              => { type => 'integer', overflow => 'truncate', default => '0', not_null => 1 },
        obligatorio        => { type => 'integer', overflow => 'truncate', default => '0', not_null => 1 },
        campo              => { type => 'character', overflow => 'truncate', length => 3, not_null => 1 },
        subcampo           => { type => 'character', overflow => 'truncate', length => 3, not_null => 1 },
        liblibrarian       => { type => 'character', overflow => 'truncate', length => 255, not_null => 1 },
        libopac            => { type => 'character', overflow => 'truncate', length => 255, not_null => 1 },
        repetible          => { type => 'integer', overflow => 'truncate', default => '0', not_null => 1 },
        descripcion        => { type => 'character', overflow => 'truncate', length => 255, default => ''},
        mandatory          => { type => 'integer', overflow => 'truncate', default => '0', not_null => 1 },
        kohafield          => { type => 'character', overflow => 'truncate', length => 40 },
    ],
    primary_key_columns => [ 'campo', 'subcampo' ],
    relationships =>
    [
        camposBase => 
        {
            class       => 'C4::Modelo::PrefEstructuraCampoMarc',
            key_columns => { campo => 'campo' },
            type        => 'one to one',
        },
    ]
);
sub getCampo{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->campo));
}
sub setCampo{
    my ($self) = shift;
    my ($campo) = @_;
    $self->campo(C4::AR::Utilidades::trim($campo));
}
sub getSubcampo{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->subcampo));
}
sub getNivel{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->nivel));
}
sub setSubcampo{
    my ($self) = shift;
    my ($subcampo) = @_;
    $self->subcampo(C4::AR::Utilidades::trim($subcampo));
}
sub getObligatorio{
    my ($self) = shift;
    return ($self->obligatorio);
}
sub setObligatorio{
    my ($self) = shift;
    my ($obligatorio) = @_;
    $self->obligatorio(C4::AR::Utilidades::trim($obligatorio));
}
sub getLiblibrarian{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->liblibrarian));
}
sub setLiblibrarian{
    my ($self) = shift;
    my ($liblibrarian) = @_;
    $self->liblibrarian(C4::AR::Utilidades::trim($liblibrarian));
}
sub getRepetible{
    my ($self) = shift;
    return ($self->repetible);
}
sub setRepetible{
    my ($self) = shift;
    my ($repetible) = @_;
    $self->repetible(C4::AR::Utilidades::trim($repetible));
}
sub getDescripcion{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->descripcion));
}
sub setDescripcion{
    my ($self) = shift;
    my ($descripcion) = @_;
    $self->descripcion(C4::AR::Utilidades::trim($descripcion));
}
sub getLibopac{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->libopac));
}
sub setLibopac{
    my ($self) = shift;
    my ($opac) = @_;
    $self->libopac(C4::AR::Utilidades::trim($opac));
}
1;