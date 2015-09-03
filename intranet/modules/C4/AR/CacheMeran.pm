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
# along with Meran.  If not, see <http://www.gnu.org/licenses/>.package C4::AR::CacheMeran;
use C4::AR::ObjetoCacheMeran;
use vars qw($CACHE @EXPORT $VERSION);
$VERSION = 0.01;
=head1 NAME
CacheMeran - Módulo de Cache de Meran
=head1 SYNOPSIS
    use C4::AR::CacheMeran;
    C4::AR::CacheMeran::obtener($clave_interna [, $clave_maestra])
    C4::AR::CacheMeran::setear($clave_interna, $valor [,$clave_maestra])
    C4::AR::CacheMeran::limpiar ([,$clave_maestra])
=head1 DESCRIPTION
    Este módulo maneja una estructura interna que tiene un objeto que cachea cosas
    para evitar consultas innecesarias a la bdd optimizando el funcionamiento de Meran.
    El esquema que utiliza es el de una hash de dos niveles, donde hay un primer nivel 
    que se puede especificar o no cuando se invoca a las funciones.
    
    En el caso de que no se haga se utilizará como clave a el par 
    modulo_llamador::funcion_llamadora y dentro de ella un utilizará una segunda 
    clave que si es obligatoria.
=cut
@EXPORT=qw(nueva obtener setear limpiar borrar);
=head1 FUNCIONES
=over
=item B<sub nueva>
    Función que Genera una cache nueva, para invocarla C4::AR::CacheMeran::nueva()
=cut
sub nueva{
    $CACHE=undef;
    $CACHE= C4::AR::ObjetoCacheMeran->new;
    
}
=item B<sub obtener>
    Función que recibe uno u opcionalmente dos parámetros, el primero indica la 
    clave que estoy intentando recuperar dentro del arreglo de valores que se 
    corresponde con la funcion que la llama. En el caso de explicitar un segundo
    parámetro no se buscará en el arreglo de valores de la funcion llamadora sino 
    en la que explicitamente se invoca en el llamado
    Para invocarla  C4::AR::CacheMeran::obtener($clave_interna [, $clave_maestra])
=cut
sub obtener{
    my ($key,$parent)= @_;
    $parent= ($parent || ( caller(1) )[3]);  
    return ($CACHE->get($parent,$key)||undef);
}
=item B<sub setear>
    Función que recibe dos u opcionalmente tres parámetros, el primero indica la 
    clave que estoy intentando setear dentro del arreglo de valores que se 
    corresponde con la funcion que la llama y la segunda el valor que se seteará. 
    En el caso de explicitar un tercer parámetro no se seteara en el arreglo de 
    valores de la funcion llamadora sino en la que explicitamente se invoca en el
    llamado
    Para invocarla  C4::AR::CacheMeran::setear($clave_interna, $valor [, $clave_maestra])
=cut
sub setear{
    my ($key,$valor,$parent)= @_;
    $parent= ($parent || ( caller(1) )[3]);  
    $CACHE->set($parent,$key,$valor); 
}
=item B<sub limpiar>
    Función que limpia una rama entera de la cache. Puede recibir un parámetro
    que indica la rama o directamente limpiar la rama de la función que la invoca.
    Para invocarla C4::AR::CacheMeran::limpiar([$clave_maestra])
=cut
sub limpiar{
    $parent= ($shift || ( caller(1) )[3]);  
    $CACHE->clean($parent);
}
=item B<sub borrar>
    
    Función que limpia la cache.
=cut
sub borrar{
    C4::AR::CacheMeran::nueva();
}
BEGIN{
      C4::AR::CacheMeran::nueva();
};
END { }       # module clean-up code here (global destructor)
1;
