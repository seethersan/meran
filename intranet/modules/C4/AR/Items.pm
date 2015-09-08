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
package C4::AR::Proveedores;
use strict;
require Exporter;
use DBI;
use C4::Modelo::AdqProveedor;
use C4::Modelo::AdqProveedor::Manager;
use vars qw(@EXPORT @ISA);
@ISA=qw(Exporter);
@EXPORT=qw(   
    &getItemsPorProveedor;
);
sub getItemsPorProveedor {
    use C4::Modelo::AdqItem;
    use C4::Modelo::AdqItem::Manager;
    my ($id_proveedor,$orden,$ini,$cantR,$inicial) = @_;
    my @filtros;
    my $itemTemp = C4::Modelo::AdqItem->new();
    push (@filtros, (or   => [   nombre => { like => '%'.$proveedor.'%'},]) );
    if (!defined $habilitados){
        $habilitados = 1;
    }
    push(@filtros, ( activo => { eq => $habilitados}));
 #   push(@filtros, ( es_socio => { eq => $habilitados}));
    my $ordenAux= $proveedorTemp->sortByString($orden);
    my $proveedores_array_ref = C4::Modelo::AdqProveedor::Manager->get_adq_proveedor(   query => \@filtros,
                                                                            sort_by => $ordenAux,
                                                                            limit   => $cantR,
                                                                            offset  => $ini,
     ); 
C4::AR::Debug::debug("|" . @filtros . "|");
    #Obtengo la cant total de socios para el paginador
    my $proveedores_array_ref_count = C4::Modelo::AdqProveedor::Manager->get_adq_proveedor_count( query => \@filtros,
                                                                     );
    if(scalar(@$proveedores_array_ref) > 0){
        return ($proveedores_array_ref_count, $proveedores_array_ref);
    }else{
        return (0,0);
    }
}
