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
package C4::AR::AyudaMarc;
use strict;
use C4::Modelo::CatAyudaMarc;
use C4::Modelo::CatAyudaMarc::Manager;
use vars qw($VERSION @ISA @EXPORT);
@ISA = qw(Exporter);
@EXPORT = qw(
    getAyudaMarc
    getAyudaMarcById
    agregarAyudaMarc
    modificarAyudaMarc
    existeAyuda
    eliminarAyudaMarc
);
=item
    Lista las ayudas MARC cargadas en el sistema
    Ademas filtra por la UI actual
=cut
sub getAyudaMarc{
    use C4::Modelo::PrefUnidadInformacion;
    my @filtros;
    my $ui = C4::Modelo::PrefUnidadInformacion->getByCode(C4::AR::Preferencias::getValorPreferencia('defaultUI'));
    push(@filtros, ( ui => { eq => $ui->getId}));
    my $ayudasArrayRef      = C4::Modelo::CatAyudaMarc::Manager->get_cat_ayuda_marc( query => \@filtros ); 
    my $ayudasArrayRefCount = C4::Modelo::CatAyudaMarc::Manager->get_cat_ayuda_marc_count( query => \@filtros );
    if(scalar(@$ayudasArrayRef) > 0){
        return ($ayudasArrayRef, $ayudasArrayRefCount);
    }else{
        return (0,0);
    }
}
=item
    Obtiene la ayuda marc con el id recibido por parametro
    Ademas filtra por la UI actual.
    Si no hay ninguna ayuda con ese id, devuelce 0
=cut
sub getAyudaMarcById{
    my ($id) = @_;
    use C4::Modelo::PrefUnidadInformacion;
    my @filtros;
    my $ui = C4::Modelo::PrefUnidadInformacion->getByCode(C4::AR::Preferencias::getValorPreferencia('defaultUI'));
    push(@filtros, ( ui => { eq => $ui->getId}));
    push(@filtros, ( id => { eq => $id}));
    my $ayudasArrayRef = C4::Modelo::CatAyudaMarc::Manager->get_cat_ayuda_marc( query => \@filtros ); 
    if(scalar(@$ayudasArrayRef) > 0){
        return ($ayudasArrayRef->[0]);
    }else{
        return (0);
    }
}
=item
    Obtiene la ayuda marc para el campo recibido por parametro
    Ademas filtra por la UI actual.
    Si no hay ninguna ayuda con ese campo, devuelce 0
=cut
sub getAyudaMarcCampo{
    my ($campo) = @_;
    use C4::Modelo::PrefUnidadInformacion;
    my @filtros;
    my $ui = C4::Modelo::PrefUnidadInformacion->getByCode(C4::AR::Preferencias::getValorPreferencia('defaultUI'));
    push(@filtros, ( ui => { eq => $ui->getId}));
    push(@filtros, ( campo => { eq => $campo}));
    my $ayudasArrayRef = C4::Modelo::CatAyudaMarc::Manager->get_cat_ayuda_marc( query => \@filtros ); 
    if(scalar(@$ayudasArrayRef) > 0){
        return ($ayudasArrayRef);
    }else{
        return (0);
    }
}
sub existeAyuda{
    my ($params) = @_;
    my @filtros;
    push(@filtros, ( campo          => { eq => $params->{'campo'} } ));
    push(@filtros, ( subcampo       => { eq => $params->{'subcampo'} } ));
    my $ayudaMarcArray = C4::Modelo::CatAyudaMarc::Manager->get_cat_ayuda_marc(  
                                                                                query  =>  \@filtros, 
                                        );  
    if(scalar(@$ayudaMarcArray) > 0){
      return 1;
    }else{
      return 0;
    }
}
sub agregarAyudaMarc{
    my ($params)    = @_;
    my $ayudaMarc   = C4::Modelo::CatAyudaMarc->new();
    my $db          = $ayudaMarc->db;
    my $msg_object  = C4::AR::Mensajes::create();
    if(existeAyuda($params)){
        $msg_object->{'error'} = 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'AM02', 'params' => [$params->{'campo'}, $params->{'subcampo'}, $params->{'ejemplar'}]} ) ;
    } else {
        $db->{connect_options}->{AutoCommit} = 0;
        $db->begin_work;
        eval{
            $ayudaMarc->agregarAyudaMarc($params);
            $msg_object->{'error'} = 0;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'AM00', 'params' => []});
            $db->commit;
        };
        if($@){
            my $errorDB = $@;
            C4::AR::Mensajes::printErrorDB($@, 'AM01',"INTRA");
            $msg_object->{'error'}= 1;
            if($errorDB =~ 'Duplicate entry'){
                C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'AM01', 'params' => []} ) ;
            }else{
                C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'AM02', 'params' => [$params->{'campo'}, $params->{'subcampo'}]} ) ;
            } 
            $db->rollback;
       }
    }
   return ($msg_object);
}
sub modificarAyudaMarc{
    my ($params)    = @_;
    my $ayudaMarc   = getAyudaMarcById($params->{'idAyuda'});
    my $db          = $ayudaMarc->db;
    my $msg_object  = C4::AR::Mensajes::create();
    $db->{connect_options}->{AutoCommit} = 0;
    $db->begin_work;
    eval{
        $ayudaMarc->editarAyudaMarc($params);
        $msg_object->{'error'} = 0;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'AM00', 'params' => []});
        $db->commit;
    };
    if($@){
        C4::AR::Mensajes::printErrorDB($@, 'AM01',"INTRA");
        $msg_object->{'error'}= 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'AM02', 'params' => [$params->{'campo'}, $params->{'subcampo'}]} ) ;
        $db->rollback;
   }
   return ($msg_object);
}
sub eliminarAyudaMarc {
     my ($idAyuda)  = @_;
     my $msg_object = C4::AR::Mensajes::create();
     my $ayudaMarc  = getAyudaMarcById($idAyuda);
 
     eval {
         $ayudaMarc->delete();
         $msg_object->{'error'}= 0;
         C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'AM03', 'params' => []} ) ;
     };
 
     if ($@){
         #Se loguea error de Base de Datos
         &C4::AR::Mensajes::printErrorDB($@, 'B463','INTRA');
         #Se setea error para el usuario
         $msg_object->{'error'}= 1;
         C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'AM04', 'params' => []} ) ;
     }
 
     return ($msg_object);
}
END { }       # module clean-up code here (global destructor)
1;
__END__