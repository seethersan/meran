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
# along with Meran.  If not, see <http://www.gnu.org/licenses/>.package C4::Modelo::CatEstante;
use strict;
use C4::AR::Utilidades;
use base qw(C4::Modelo::DB::Object::AutoBase2);
__PACKAGE__->meta->setup(
    table   => 'cat_estante',
    columns => [
        id        => { type => 'integer', overflow => 'truncate', not_null => 1 },
        estante   => { type => 'varchar', overflow => 'truncate', length => 255 },
        tipo      => { type => 'varchar', overflow => 'truncate', length => 255 },
        padre     => { type => 'integer', overflow => 'truncate', default => '0', not_null => 1 },
    ],
    primary_key_columns => [ 'id' ],
    relationships => [
        estante_padre => {
            class       => 'C4::Modelo::CatEstante',
            key_columns => { padre => 'id' },
            type        => 'one to one',
        },
        contenido => {
            class       => 'C4::Modelo::CatContenidoEstante',
            key_columns => { id => 'id_estante' },
            type        => 'one to many',
        },
    ],
);
sub getId{
    my ($self) = shift;
    return ($self->id);
}
sub setId{
    my ($self) = shift;
    my ($id) = @_;
    $self->id($id);
}
sub getEstante{
    my ($self) = shift;
    my $estante = $self->estante;
    $estante =~ s/"/\'/g;
    return ($estante);
}
sub getEstanteStringEscaped{
    my ($self) = shift;
    my $estante = $self->estante;
    $estante = C4::AR::Utilidades::escapeData($estante);
    return ($estante);
}
sub setEstante{
    my ($self) = shift;
    my ($estante) = @_;
    $self->estante($estante);
}
sub getPadre{
    my ($self) = shift;
    return ($self->padre);
}
sub setPadre {
    my ($self) = shift;
    my ($padre) = @_;
    $self->padre($padre);
}
sub getTipo{
    my ($self) = shift;
    return ($self->tipo);
}
sub setTipo {
    my ($self) = shift;
    my ($tipo) = @_;
    $self->tipo($tipo);
}
sub getContenido{
    my ($self) = shift;
    return ($self->contenido);
}
sub clonar{
    my ($self) = shift;
    #Clonamos Estante
    my $nuevo_estante = C4::Modelo::CatEstante->new();
    $nuevo_estante->setEstante($self->getEstante());
    $nuevo_estante->setPadre($self->getPadre());
    $nuevo_estante->setTipo($self->getTipo());
    $nuevo_estante->save();
    #Clonamos Contenido
    my $contenido_estante = $self->getContenido();
    foreach my $contenido (@$contenido_estante)
    {
        my $nuevo_contenido = C4::Modelo::CatContenidoEstante->new();
        $nuevo_contenido->setId_estante($nuevo_estante->getId());
        $nuevo_contenido->setId2($contenido->getId2());
        $nuevo_contenido->save();
    }
    
    my $subestantes = C4::AR::Estantes::getSubEstantes($self->getId());
    foreach my $subestante (@$subestantes)
    {   #Clonamos el hijo y seteamos nuevo padre
        my $subestante_clonado = $subestante->clonar();
        $subestante_clonado->setPadre($nuevo_estante->getId);
        $subestante_clonado->save();
    }
    return $nuevo_estante;
}
1;
