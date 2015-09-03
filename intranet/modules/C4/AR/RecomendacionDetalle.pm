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
# along with Meran.  If not, see <http://www.gnu.org/licenses/>.package C4::AR::RecomendacionDetalle;
use strict;
require Exporter;
use DBI;
use C4::Modelo::AdqRecomendacion;
use C4::Modelo::AdqRecomendacion::Manager;
use C4::Modelo::AdqRecomendacionDetalle;
use C4::Modelo::AdqRecomendacionDetalle::Manager;
use vars qw(@EXPORT @ISA);
@ISA=qw(Exporter);
@EXPORT=qw(  
    &agregarDetalleARecomendacion;
    &getDetalleRecomendacionPorId;
    &eliminarDetalleRecomendacion;
   
);
sub getDetalleRecomendacionPorId {
    my ($params) = @_;
    my $detalleTemp;
    my @filtros;
    if ($params){
        push (@filtros, ( id => { eq => $params}));
        $detalleTemp = C4::Modelo::AdqRecomendacionDetalle::Manager->get_adq_recomendacion_detalle( query => \@filtros );
        return $detalleTemp->[0]
    }
 
    return 0;
}
sub eliminarDetalleRecomendacion {
     my ($id_rec_det, $msg_object) = @_;
    
     my $msg_object= C4::AR::Mensajes::create();
    
     my $detalle = C4::AR::RecomendacionDetalle::getDetalleRecomendacionPorId($id_rec_det);
 
     eval {
         $detalle->eliminar();
         $msg_object->{'error'}= 0;
         C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'RC00', 'params' => []} ) ;
     };
 
     if ($@){
         #Se loguea error de Base de Datos
         &C4::AR::Mensajes::printErrorDB($@, 'B411','OPAC');
         #Se setea error para el usuario
         $msg_object->{'error'}= 1;
         C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'RC01', 'params' => []} ) ;
     }
     return ($msg_object);
}
sub agregarDetalleARecomendacion{
  my ($obj, $recom_id) = @_;
   
  my %datos_recomendacion;
  my $msg_object;
  $datos_recomendacion{'id_recomendacion'}      = $recom_id;
  $datos_recomendacion{'nivel_2'}               = $obj->{'idNivel2'};
  $datos_recomendacion{'autor'}                 = $obj->{'autor'};
  $datos_recomendacion{'titulo'}                = $obj->{'titulo'};
  $datos_recomendacion{'lugar_publicacion'}     = $obj->{'lugar_publicacion'};
  $datos_recomendacion{'editorial'}             = $obj->{'editorial'};
  $datos_recomendacion{'fecha'}                 = $obj->{'fecha'};
  $datos_recomendacion{'isbn_issn'}             = $obj->{'isbn_issn'};
  $datos_recomendacion{'cantidad_ejemplares'}   = $obj->{'cant_ejemplares'};
  $datos_recomendacion{'motivo_propuesta'}      = $obj->{'motivo_propuesta'};
  $datos_recomendacion{'comentarios'}           = $obj->{'comment'};
  $datos_recomendacion{'idNivel1'}              = $obj->{'catalogo_search_hidden'};
  $datos_recomendacion{'reservar'}              = $obj->{'reservar'} || 0;
  
  # checkeo de XSS
  foreach my $dato (%datos_recomendacion){
    if($dato =~ m/script/){
      C4::AR::Debug::debug("entro a la expresion regular");
      C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'B410', 'params' => []} ) ;
      $msg_object->{'error'}= 1;
    }
  }
  
  my $recomendacion_detalle = C4::Modelo::AdqRecomendacionDetalle->new(); 
  my $db = $recomendacion_detalle->db;
  if (!($msg_object->{'error'})){
           
          # entro si no hay algun error, todos los campos ingresados son validos
          $db->{connect_options}->{AutoCommit} = 0;
          $db->begin_work;
          eval{
                  $recomendacion_detalle->agregarRecomendacionDetalle(\%datos_recomendacion);
                     
                  $msg_object->{'error'} = 0;
                  C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'A001', 'params' => []});
                  $db->commit;
          };
          if ($@){
                  # TODO falta definir el mensaje "amigable" para el usuario informando que no se pudo agregar el proveedor
                  &C4::AR::Mensajes::printErrorDB($@, 'B410','OPAC');
                  $msg_object->{'error'}= 1;
                  C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'B410', 'params' => []} ) ;
                  $db->rollback;
              }
              $db->{connect_options}->{AutoCommit} = 1;
    }
    return ($msg_object,$recomendacion_detalle->getId());
}
END { }       # module clean-up code here (global destructor)
1;
__END__
