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
# along with Meran.  If not, see <http://www.gnu.org/licenses/>.package C4::Modelo::IndiceSugerencia;
use strict;
use base qw(C4::Modelo::DB::Object::AutoBase2);
__PACKAGE__->meta->setup(
    table   => 'indice_sugerencia',
    columns => [
        id              => { type => 'serial', overflow => 'truncate', not_null => 1 },
        keyword         => { type => 'text', overflow => 'truncate', not_null => 1 },
        trigrams        => { type => 'text', overflow => 'truncate', not_null => 1 },
        freq            => { type => 'integer', default => '0', not_null => 1 },
    ],
    primary_key_columns => [ 'id' ],
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
sub getKeyword{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->keyword));
}
sub setKeyword{
    my ($self)          = shift;
    my ($keyword)   = @_;
    $self->keyword($keyword);
}
sub getTrigrams{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->trigrams));
}
sub setTrigrams{
    my ($self)          = shift;
    my ($trigrams)   = @_;
    $self->trigrams($trigrams);
}
sub getFreq{
    my ($self)  = shift;
    return $self->freq;
}
sub setFreq{
    my ($self)  = shift;
    my ($freq)   = @_;
    $self->freq($freq);
}
1;
