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
# along with Meran.  If not, see <http://www.gnu.org/licenses/>.package C4::Modelo::PrefEstructuraCampoMarc;
use strict;
use base qw(C4::Modelo::DB::Object::AutoBase2);
__PACKAGE__->meta->setup(
    table   => 'pref_estructura_campo_marc',
    columns => [
        campo                   => { type => 'character', overflow => 'truncate', length => 3, not_null => 1 },
        liblibrarian            => { type => 'character', overflow => 'truncate', length => 255, not_null => 1 },
        repeatable              => { type => 'integer', overflow => 'truncate', default => '0', not_null => 1 },
        descripcion             => { type => 'character', overflow => 'truncate', length => 255 , default => ''},
        nivel                   => { type => 'character', overflow => 'truncate', length => 255,default => '0',  not_null => 1 },
        mandatory               => { type => 'integer', overflow => 'truncate', default => '0', not_null => 1 },
        indicador_primario      => { type => 'character', overflow => 'truncate', length => 255, default => '0', not_null => 1 },
        indicador_secundario    => { type => 'character', overflow => 'truncate', length => 255, default => '0', not_null => 1 },
    ],
    primary_key_columns => [ 'campo' ],
);
use C4::AR::Utilidades;
sub getCampo{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->campo));
}
sub setCampo{
    my ($self) = shift;
    my ($campo) = @_;
    $self->campo(C4::AR::Utilidades::trim($campo));
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
sub getIndicadorPrimario{
    my ($self) = shift;
    if(!$self->indicador_primario =~ /\s+/){
        return C4::AR::Filtros::i18n('NO TIENE');
    }else{
        return (C4::AR::Utilidades::trim($self->indicador_primario));
    }
}
sub getIndicadorSecundario{
    my ($self) = shift;
    
    if(!$self->indicador_secundario =~ /\s+/){
        return C4::AR::Filtros::i18n('NO TIENE');
    }else{
        return (C4::AR::Utilidades::trim($self->indicador_secundario));
    }
}
sub setIndicadorPrimario{
    my ($self) = shift;
    my ($ip) = @_;
    $self->indicador_primario(C4::AR::Utilidades::trim($ip));
}
sub setIndicadorSecundario{
    my ($self) = shift;
    my ($is) = @_;
    $self->indicador_secundario(C4::AR::Utilidades::trim($is));
}
sub getNivel{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->nivel));
}
sub getRepeatable{
    my ($self) = shift;
    return ($self->repeatable);
}
sub setRepeatable{
    my ($self) = shift;
    my ($repeatable) = @_;
    $self->repeatable(C4::AR::Utilidades::trim($repeatable));
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
sub getMandatory{
    my ($self) = shift;
    return ($self->mandatory);
}
sub setMandatory{
    my ($self) = shift;
    my ($mandatory) = @_;
    $self->mandatory(C4::AR::Utilidades::trim($mandatory));
}
1;