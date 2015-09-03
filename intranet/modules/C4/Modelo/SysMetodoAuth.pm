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
# along with Meran.  If not, see <http://www.gnu.org/licenses/>.package C4::Modelo::SysMetodoAuth;
use strict;
use base qw(C4::Modelo::DB::Object::AutoBase2);
__PACKAGE__->meta->setup(
    table   => 'sys_metodo_auth',
    columns => [
        id          => { type => 'serial', overflow => 'truncate', length => 12, not_null => 1 },
        metodo      => { type => 'varchar', overflow => 'truncate', length => 255, not_null => 1 },
        orden       => { type => 'integer', overflow => 'truncate', length => 12, not_null => 1 },
        enabled     => { type => 'integer', overflow => 'truncate', length => 12, default => 1, not_null => 1 },
    ],
    primary_key_columns => [ 'id' ],
    unique_key          => [ 'metodo' ],
);
sub agregarMetodo{
    my ($self)      = shift;
    my ($string)    = @_; 
    my $orden       = C4::Modelo::SysMetodoAuth::Manager->get_max_orden() + 1;
    
    $self->metodo($string);
    $self->enabled("0");
    $self->orden($orden);
    
    $self->save();
}
sub getMetodo{
    my ($self) = shift;
    return ($self->metodo);
}
sub setMetodo{
    my ($self) = shift;
    my ($string) = @_;    
    
    $self->metodo($string);
    $self->save();    
}
sub getOrden{
    my ($self) = shift;
    return ($self->orden);
}
sub setOrden{
    my ($self) = shift;
    my ($number) = @_;    
    
    $self->orden($number);
    $self->save();    
}
sub isEnabled{
    my ($self) = shift;
    return ($self->enabled);
}
sub enable{
    my ($self) = shift;
    $self->enabled("1");
    $self->save();    
}
sub disable{
    my ($self) = shift;
    $self->enabled("0"); 
    $self->save();     
}
1;
