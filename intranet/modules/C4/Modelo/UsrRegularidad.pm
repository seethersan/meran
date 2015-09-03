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
# along with Meran.  If not, see <http://www.gnu.org/licenses/>.package C4::Modelo::UsrRegularidad;
use base qw(C4::Modelo::DB::Object::AutoBase2);
__PACKAGE__->meta->setup
  (
    table   => 'usr_regularidad',
    columns => [
        id                      => { type => 'serial', overflow => 'truncate', not_null => 1, length => 11 },
        usr_estado_id           => { type => 'integer', overflow => 'truncate', not_null => 1, length => 1 },
        usr_ref_categoria_id    => { type => 'integer', overflow => 'truncate', length => 2, not_null => 1 },
        condicion                 => { type => 'integer', overflow => 'truncate', not_null => 1, length => 1 },
    ],
     relationships =>
    [
      estado => 
      {
        class       => 'C4::Modelo::UsrEstado',
        key_columns => { usr_estado_id => 'id_estado' },
        type        => 'one to one',
      },
      categoria => 
      {
        class       => 'C4::Modelo::UsrRefCategoriaSocio',
        key_columns => { usr_ref_categoria_id => 'id' },
        type        => 'one to one',
      },
    ],
    
    primary_key_columns => [ 'id' ],
    unique_key => [ 'usr_estado_id','usr_ref_categoria_id' ],
);
sub agregar{
    my ($self)=shift;
    my ($data_hash)=@_;
    #Asignando data...
    $self->setUsrEstadoId($data_hash->{'usr_estado_id'});
    $self->setUsrRefCategoriaId($data_hash->{'usr_ref_categoria_id'});
    $self->setCondicion($data_hash->{'Condicion'});
    $self->save();
}
sub getId{
    my ($self) = shift;
    return ($self->id);
}
sub getUsrEstadoId{
    my ($self) = shift;
    return ($self->usr_estado_id);
}
sub setUsrEstadoId{
    my ($self) = shift;
    my ($id) = @_;
    $self->usr_estado_id($id);
}
sub getUsrRefCategoriaId{
    my ($self) = shift;
    return ($self->usr_ref_categoria_id);
}
sub setUsrRefCategoriaId{
    my ($self) = shift;
    my ($id) = @_;
    $self->usr_ref_categoria_id($id);
}
sub getCondicion{
    my ($self) = shift;
    return ($self->condicion);
}
sub setCondicion{
    my ($self) = shift;
    my ($condicion) = @_;
    $self->condicion($condicion);
}
sub getRegularidad{
    my ($self) = shift;
    my $cond = $self->getCondicion;
    
    return $cond?C4::AR::Filtros::i18n("REGULAR"):C4::AR::Filtros::i18n("NO REGULAR");	
}
1;
