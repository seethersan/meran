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
# along with Meran.  If not, see <http://www.gnu.org/licenses/>.package C4::Modelo::IndiceBusqueda::Manager;
use strict;
use base qw(Rose::DB::Object::Manager);
use C4::Modelo::IndiceBusqueda;
sub object_class { 'C4::Modelo::IndiceBusqueda' }
__PACKAGE__->make_manager_methods('indice_busqueda');
sub get_maximum_timestamp {
    my ($class, %args) = @_;
    my $db = $args{'db'} || C4::Modelo::IndiceBusqueda->new()->db;
    my $sth = $db->dbh->prepare("SELECT MAX(timestamp) FROM indice_busqueda");
    $sth->execute();
    my  $max  = $sth->fetchrow;
    $sth->finish;
    return $max;
}
sub get_minimum_timestamp {
    my ($class, %args) = @_;
    my $db = $args{'db'} || C4::Modelo::IndiceBusqueda->new()->db;
    my $sth = $db->dbh->prepare("SELECT MIN(timestamp) FROM indice_busqueda");
    $sth->execute();
    my  $min  = $sth->fetchrow;
    $sth->finish;
    return $min;
}
1;
