# Meran - MERAN UNLP is a ILS (Integrated Library System) wich provides Catalog,
# Circulation and User's Management. It's written in Perl, and uses Apache2
# Web-Server, MySQL database and Sphinx 2 indexing.
# Copyright (C) 2009-2015 Grupo de desarrollo de Meran CeSPI-UNLP
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
# along with Meran.  If not, see <http://www.gnu.org/licenses/>.
package C4::AR::ObjetoCacheMeran;
sub new{
    my $this=shift; #Cogemos la clase que somos o una referencia a la clase (si soy un objeto)
    my $class = ref($this) || $this; #Averiguo la clase a la que pertenezco
    my $self={};
    bless $self, $class; 
    return ($self);
}
sub get{
    my ($self,$parent,$key)= @_;
    # (defined $self->{$parent}->{$key})?C4::AR::Debug::debug("ObjetoCacheMeran => get => CACHED!!!!!!! key => ".$key." => valor ".$self->{$parent}->{$key}):C4::AR::Debug::debug("ObjetoCacheMeran => get => NOOOOOOT CACHED!!!!!!! key => ".$key);
    return ($self->{$parent}->{$key}||undef);
}
sub set{
    my ($self,$parent,$key,$valor)= @_;
    $self->{$parent}->{$key}=$valor; 
}
sub clean{
    $parent = shift; 
    $self->{$parent}={};
}
sub cleanAll{
    $self=shift;
    return CacheMeran->new;
}
1;
