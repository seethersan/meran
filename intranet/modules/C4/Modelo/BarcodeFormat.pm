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
# along with Meran.  If not, see <http://www.gnu.org/licenses/>.package C4::Modelo::BarcodeFormat;
use strict;
use base qw(C4::Modelo::DB::Object::AutoBase2);
__PACKAGE__->meta->setup(
    table   => 'barcode_format',
    columns => [
        id              => { type => 'serial', overflow => 'truncate', length => 16 },
        id_tipo_doc     => { type => 'varchar', overflow => 'truncate', not_null => 1, length => 4 },
        format          => { type => 'varchar', overflow => 'truncate', not_null => 1, length => 255 },
        long            => { type => 'integer', overflow => 'truncate', not_null => 1 },
    ],
    primary_key_columns => [ 'id' ],
    unique_key => [ 'id_tipo_doc' ],
     
    relationships =>
    [
      ui => 
      {
        class       => 'C4::Modelo::CatRefTipoNivel3',
        key_columns => { id_tipo_doc => 'id_tipo_doc' },
        type        => 'one to one',
      },
    ]
);
sub agregar{
    my ($self) = shift;
    my ($params) = @_;
    $self->setId_tipo_doc($params-{'id_tipo_doc'});
    $self->setFormat($params-{'format'});
    $self->setLong($params-{'long'});
    return($self->save());
}
sub getId{
    my ($self) = shift;
    return ($self->id);
}
sub getId_tipo_doc{
    my ($self) = shift;
    return ($self->id_tipo_doc);
}
sub getFormat{
    my ($self) = shift;
    return ($self->format);
}
sub getLong{
    my ($self) = shift;
    return ($self->long);
}
sub setId_tipo_doc{
    my ($self)  = shift;
    my ($Id_tipo_doc) = @_;
    $self->id_tipo_doc($Id_tipo_doc);
    
}
sub setFormat{
    my ($self)  = shift;
    my ($Format) = @_;
    $self->format($Format);
    
}
sub setLong{
    my ($self)  = shift;
    my ($long) = @_;
    $self->long($long);
    
}
1;
