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
# along with Meran.  If not, see <http://www.gnu.org/licenses/>.package C4::AR::PedidoCotizacionDetalle;
use strict;
require Exporter;
use DBI;
use C4::Modelo::AdqPedidoCotizacionDetalle;
use C4::Modelo::AdqPedidoCotizacionDetalle::Manager;
use vars qw(@EXPORT @ISA);
@ISA=qw(Exporter);
@EXPORT=qw(  
    &existeEjemplarEnPedidoCotizacion;
    &addPedidoCotizacionDetalle;
    &getPedidoCotizacionConDetallePorId;
    &getPedidosCotizacionPorPadre;
    &getCantRenglonesByPedidoPadre;
);
=item
    Esta funcion devuelve un bool, verifica que el ejemplar no este en el mismo pedido cotizacion_detalle
    Parametros: (id del ejemplar a chequear, id del pedido_cotizacion padre)
        HASH { id_ejemplar, id_pedido_cotizacion, $db }
=cut
sub existeEjemplarEnPedidoCotizacion{
    my ($id_ejemplar, $id_pedido_cotizacion, $db) = @_;
    my @filtros;
    my $db            = $db;
    push (@filtros, ( adq_pedido_cotizacion_id => { eq => $id_pedido_cotizacion}));
    push (@filtros, (cat_nivel2_id => { eq => $id_ejemplar}));
    
    my $ejemplares_array  = C4::Modelo::AdqPedidoCotizacionDetalle::Manager->get_adq_pedido_cotizacion_detalle(   
                                                                    db => $db,
                                                                    query => \@filtros,
                                                                );
    if(scalar(@$ejemplares_array) > 0){
        return 1;
    }else{
        return 0;
    }
}
=item
    Esta funcion devuelve la cantidad de renglones de un pedido
    Parametros: (El id del pedido_cotizacion padre)
        HASH { id_pedido_cotizacion }
=cut
sub getCantRenglonesByPedidoPadre{
    my ($params, $db) = @_;
    my @filtros;
    my $db            = $db;
    push (@filtros, ( adq_pedido_cotizacion_id => { eq => $params}));
    
    my $pedidos_cotizacion_array  = C4::Modelo::AdqPedidoCotizacionDetalle::Manager->get_adq_pedido_cotizacion_detalle(   
                                                                    db => $db,
                                                                    query => \@filtros,
                                                                );
    return @$pedidos_cotizacion_array;
}
=item
    Esta funcion agrega un pedido cotizacion
    Parametros: (El id es AUTO_INCREMENT y la fecha CURRENT_TIMESTAMP)
        HASH { id_pedido_cotizacion, cantidades_ejemplares }
=cut
sub addPedidoCotizacionDetalle{
    my ($params)            = @_;
    my $pedido_cotizacion   = C4::Modelo::AdqPedidoCotizacionDetalle->new();
    my $msg_object          = C4::AR::Mensajes::create();
    my $db                  = $pedido_cotizacion->db;
   
    if (!($msg_object->{'error'})){
          # entro si no hay algun error, todos los campos ingresados son validos
          $db->{connect_options}->{AutoCommit} = 0;
          $db->begin_work;
          eval{
       
              $pedido_cotizacion->addPedidoCotizacionDetalle($params);
              
              $msg_object->{'error'} = 0;
              C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'A001', 'params' => []});
              $db->commit;
           };
           if ($@){
           # TODO falta definir el mensaje "amigable" para el usuario informando que no se pudo agregar el proveedor
               &C4::AR::Mensajes::printErrorDB($@, 'B410',"OPAC");
               $msg_object->{'error'}= 1;
               C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'B410', 'params' => []} ) ;
               $db->rollback;
           }
          $db->{connect_options}->{AutoCommit} = 1;
    }
    return ($msg_object);
}
=item
    Esta funcion devuelve el pedido_cotizacion_detalle por su id
    Parametros: id_pedido_cotizacion_detalle
=cut
sub getPedidoCotizacionConDetallePorId{
    my ($params) = @_;
    my @filtros;
    my $db                           = C4::Modelo::AdqPedidoCotizacionDetalle->new()->db;
    push (@filtros, ( id => { eq => $params}));
    
    my $pedido_cotizacion            = C4::Modelo::AdqPedidoCotizacionDetalle::Manager->get_adq_pedido_cotizacion_detalle(   
                                                                    db => $db,
                                                                    query => \@filtros,
                                                                );
    return $pedido_cotizacion->[0];
}
=item
    Esta funcion devuelve los pedidos_cotizacion_detalle que tengan el pedido_cotizacion (padre) 
    con el id recibido como parametro
    Parametros: id_pedido_cotizacion (padre)
=cut
sub getPedidosCotizacionPorPadre{
    my ($params) = @_;
    my @filtros;
    my $db = C4::Modelo::AdqPedidoCotizacionDetalle->new()->db;
    push (@filtros, ( adq_pedido_cotizacion_id => { eq => $params}));
    
    my $pedido_cotizacion            = C4::Modelo::AdqPedidoCotizacionDetalle::Manager->get_adq_pedido_cotizacion_detalle(   
                                                                    db => $db,
                                                                    query => \@filtros,
                                                                );
    return $pedido_cotizacion;
}
END { }       # module clean-up code here (global destructor)
1;
__END__
