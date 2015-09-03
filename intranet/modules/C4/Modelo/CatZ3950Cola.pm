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
# along with Meran.  If not, see <http://www.gnu.org/licenses/>.package C4::Modelo::CatZ3950Cola;
use strict;
use base qw(C4::Modelo::DB::Object::AutoBase2);
__PACKAGE__->meta->setup(
    table   => 'cat_z3950_cola',
    columns => [
        id       => { type => 'serial', overflow => 'truncate', not_null => 1 },
        busqueda => { type => 'varchar', overflow => 'truncate', length => 255 },
        cola => { type => 'datetime' },
        comienzo => { type => 'datetime' },
        fin  => { type => 'datetime' },
    ],
    primary_key_columns => [ 'id' ],
    relationships => [
        resultados => {
            class       => 'C4::Modelo::CatZ3950Resultado',
            key_columns => {  id => 'cola_id' },
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
sub getBusqueda{
    my ($self) = shift;
    return ($self->busqueda);
}
sub setBusqueda{
    my ($self) = shift;
    my ($termino,$busqueda) = @_;
    
    my $busqueda_final='';
    if ($termino eq 'titulo') 		{$busqueda_final = '@attr 1=4 '.$busqueda;} 
    elsif ($termino eq 'autor') 	{$busqueda_final = '@attr 1=1003 '.$busqueda;} 
    elsif ($termino eq 'isbn') 		{$busqueda_final = '@attr 1=7 '.$busqueda;} 
    elsif ($termino eq 'issn') 		{$busqueda_final = '@attr 1=8 '.$busqueda;} 
    elsif ($termino eq 'termino')	{$busqueda_final = '@attr 1=1016 '.$busqueda;} 
    elsif ($termino eq 'pqf') 		{$busqueda_final = $busqueda;} 
    
    $self->busqueda($busqueda_final);
}
sub getComienzo{
    my ($self) = shift;
    return ($self->comienzo);
}
sub setComienzo{
    my ($self) = shift;
    my ($comienzo) = @_;
    $self->comienzo($comienzo);
}
sub getFin{
    my ($self) = shift;
    return ($self->fin);
}
sub setFin{
    my ($self) = shift;
    my ($fin) = @_;
    $self->fin($fin);
}
sub getCola{
    my ($self) = shift;
    return ($self->cola);
}
sub setCola{
    my ($self) = shift;
    my ($cola) = @_;
    $self->cola($cola);
}
sub getCantResultados {
    my ($self) = shift;
    my $res=$self->resultados;
    return (scalar(@$res));
}
1;
