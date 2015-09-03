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
# along with Meran.  If not, see <http://www.gnu.org/licenses/>.package C4::Modelo::IndiceBusqueda;
use strict;
use base qw(C4::Modelo::DB::Object::AutoBase2);
__PACKAGE__->meta->setup(
    table   => 'indice_busqueda',
    columns => [
        id              => { type => 'serial', overflow => 'truncate', not_null => 1 },
        titulo          => { type => 'text', overflow => 'truncate' },
        autor           => { type => 'text', overflow => 'truncate' },
        string          => { type => 'text', overflow => 'truncate', not_null => 1},
        marc_record     => { type => 'text', overflow => 'truncate', not_null => 1},
        timestamp       => { type => 'timestamp', not_null => 1 },
        hits            => { type => 'integer', default => '0', not_null => 1 },
        promoted        => { type => 'integer', default => '0', not_null => 1 }
    ],
    primary_key_columns => [ 'id' ],
    relationships => [
        nivel1 => {
            class       => 'C4::Modelo::CatRegistroMarcN1',
            key_columns => { id => 'id' },
            type        => 'one to one',
        },
    ],
);
sub getId{
    my ($self)  = shift;
    return $self->id;
}
sub setId{
    my ($self)  = shift;
    my ($id)   = @_;
    $self->id($id);
}
sub hit{
    my ($self)  = shift;
    $self->hits($self->hits+1);
    $self->save();
}
sub getTimestamp{
    my ($self)  = shift;
    return $self->timestamp;
}
sub getAutor{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->autor));
}
sub setAutor{
    my ($self)          = shift;
    my ($autor)   = @_;
    $self->autor($autor);
}
sub getTitulo{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->titulo));
}
sub setTitulo{
    my ($self)          = shift;
    my ($titulo)   = @_;
    $self->titulo($titulo);
}
sub getMarcRecord{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->marc_record));
}
sub getMarcRecordObject{
    my ($self) = shift;
    return (MARC::Record->new_from_usmarc($self->getMarcRecord()));
}
sub setMarcRecord{
    my ($self)          = shift;
    my ($marc_record)   = @_;
    $self->marc_record($marc_record);
}
sub getString{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->string));
}
sub setString{
    my ($self)          = shift;
    my ($string)   = @_;
    $self->string($string);
}
sub getPromoted{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->promoted));
}
sub setPromoted{
    my ($self)          = shift;
    my ($promoted)   = @_;
    $self->promoted($promoted);
}
=head2 sub generarIndice
    Genera el índice para este nivel 1
    Actualiza el registro de Gener
    Retorna la referencia a un arreglo de objetos
=cut
sub generarIndice {
    my ($self) = shift;
}
1;
