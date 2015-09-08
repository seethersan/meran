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
package C4::AR::Estantes;
use strict;
require Exporter;
use DBI;
use C4::AR::Utilidades;
use vars qw(@ISA @EXPORT);
=head1 NAME
C4::AR::Estantes- Funciones para manipular los estantes Virtuales
=head1 SYNOPSIS
  use C4::AR::Estantes;
=head1 DESCRIPTION
Este módulo provee funciones para manipular estantes virtuales, incluyendo la creación y el borrado de estantes, y el alta y baja de contenido de un estante.
=head1 FUNCTIONS
=over 2
=cut
@ISA = qw(Exporter);
@EXPORT = qw(
	&getListaEstantesPublicos
        &getEstante
        &getSubEstantes
        &borrarEstantes
        &borrarContenido
        &modificarEstante
        &agregarSubEstante
        &buscarNombreDuplicado
        &agregarEstante
	&buscarEstante
	&estaEnEstanteVirtual
);
sub getListaEstantesPublicos {
    use C4::Modelo::CatEstante;
    use C4::Modelo::CatEstante::Manager;
    my @filtros;
    push(@filtros, ( padre  => { eq => 0}, tipo  => { eq => 'public'} ));
    my $estantes_array_ref = C4::Modelo::CatEstante::Manager->get_cat_estante( query => \@filtros, sort_by => 'estante');
    return ($estantes_array_ref);
}
sub getSubEstantes {
    my ($id_estante) = @_;
    use C4::Modelo::CatEstante;
    use C4::Modelo::CatEstante::Manager;
    my @filtros;
    push(@filtros, ( padre  => { eq => $id_estante} ));
    my $estantes_array_ref = C4::Modelo::CatEstante::Manager->get_cat_estante( query => \@filtros, sort_by => 'estante');
    return ($estantes_array_ref);
}
sub getEstante {
    my ($id_estante,$orden) = @_;
    C4::AR::Debug::debug("EN ESTANTES.PM");
    C4::AR::Debug::debug($id_estante);
    C4::AR::Debug::debug("cuantos hay: ");
    use C4::Modelo::CatEstante;
    use C4::Modelo::CatEstante::Manager;
    my @filtros;
    push(@filtros, ( id  => { eq => $id_estante} ));
    
    my $estantes_array_ref = C4::Modelo::CatEstante::Manager->get_cat_estante( 
                                                                                query => \@filtros,
                                                                                #require_objects => ['contenido.nivel2.nivel1.IndiceBusqueda' ],
                                                                                # require_objects => [ 'contenido.nivel2'],
                                                                                );
    
    my $estante=  $estantes_array_ref->[0];
    return ($estante);
}
sub getEstanteConContenido {
    my ($id_estante,$orden) = @_;
    C4::AR::Debug::debug("EN ESTANTES.PM");
    C4::AR::Debug::debug($id_estante);
    C4::AR::Debug::debug("cuantos hay: ");
    use C4::Modelo::CatEstante;
    use C4::Modelo::CatEstante::Manager;
    my @filtros;
    push(@filtros, ( id  => { eq => $id_estante} ));
    
    my $estantes_array_ref = C4::Modelo::CatEstante::Manager->get_cat_estante( 
                                                                                query => \@filtros,
                                                                                #require_objects => ['contenido.nivel2.nivel1.IndiceBusqueda' ],
                                                                                with_objects => [ 'contenido.nivel2'],
                                                                                );
    
    my $estante=  $estantes_array_ref->[0];
    return ($estante);
}
sub borrarEstantes {
    my ($estantes_array_ref)=@_;
    my $msg_object= C4::AR::Mensajes::create();
    $msg_object->{'tipo'}="INTRA";
        foreach my $id_estante (@$estantes_array_ref){
          my ($estante) = C4::Modelo::CatEstante->new(id => $id_estante);
            $estante->load();
          my $db = $estante->db;
          $db->{connect_options}->{AutoCommit} = 0;
          $db->begin_work;
           eval {
           C4::AR::Estantes::_verificacionesParaBorrar($msg_object,$estante);
           if(!$msg_object->{'error'}){
            #No hay error
                C4::AR::Debug::debug("VAMOS A ELIMINAR EL ESTANTE");
                $estante->delete();
                 $db->commit;
                $msg_object->{'error'}= 0;
                C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'E004', 'params' => [Encode::decode_utf8($estante->getEstante)]} ) ;
                C4::AR::Debug::debug("EL ESTANTE SE ELIMINO CON EXITO");
            }
            };
        if ($@){
            C4::AR::Debug::debug("ERROR");
            &C4::AR::Mensajes::printErrorDB($@, '',"INTRA");
            $db->rollback;
            #Se setea error para el usuario
            $msg_object->{'error'}= 1;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'E003', 'params' => [Encode::decode_utf8($estante->getEstante)]} ) ;
        }
        $db->{connect_options}->{AutoCommit} = 1;
        $msg_object->{'error'}= 0;
        }
    return ($msg_object);
}
sub borrarContenido {
    my ($id_estante,$contenido_array_ref)=@_;
    C4::AR::Debug::debug("Antes de verificar");
    my $msg_object= C4::AR::Mensajes::create();
    $msg_object->{'tipo'}="INTRA";
    my ($estante) = C4::Modelo::CatEstante->new(id => $id_estante);
    $estante->load();
    use C4::Modelo::CatContenidoEstante;
    use C4::Modelo::CatContenidoEstante::Manager;
    my $db = $estante->db;
    $db->{connect_options}->{AutoCommit} = 0;
    $db->begin_work;
        foreach my $id2 (@$contenido_array_ref){
    	    C4::AR::Debug::debug("CONTENIDO ".$id2);
            my @filtros;
    	    push(@filtros, ( id_estante  => { eq => $id_estante} ));
    	    push(@filtros, ( id2  	 => { eq => $id2} ));
    	    my $contenido_estantes_array_ref = C4::Modelo::CatContenidoEstante::Manager->delete_cat_contenido_estante(db => $db,where => \@filtros);
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'E006'} ) ;
        }   
        C4::AR::Debug::debug("EL CONTENIDO SE ELIMINO CON EXITO");
        $db->commit;
        $msg_object->{'error'}= 0;
    $db->{connect_options}->{AutoCommit} = 1;
    return ($msg_object);
}
sub _verificacionesParaBorrar {
    my($msg_object,$estante)=@_;
    my $contenido = $estante->contenido;
    if (@$contenido){
    #El estante posee contenido
            $msg_object->{'error'}= 1;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'E001', 'params' => [Encode::decode_utf8($estante->getEstante)]} ) ;
            C4::AR::Debug::debug("Entro al if de contenido ");
      }
    my $subestantes = C4::AR::Estantes::getSubEstantes($estante->getId);
    if(@$subestantes) {
          $msg_object->{'error'}= 1;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'E002', 'params' => [Encode::decode_utf8($estante->getEstante)]} ) ;
            C4::AR::Debug::debug("Entro al if de subestantes");
        }
}
sub modificarEstante  {
    my ($id_estante,$valor)=@_;
    C4::AR::Debug::debug("Antes de verificar");
    my $msg_object= C4::AR::Mensajes::create();
    $msg_object->{'tipo'}="INTRA";
    my ($estante) = C4::Modelo::CatEstante->new(id => $id_estante);
    $estante->load();
    my $db = $estante->db;
    $db->{connect_options}->{AutoCommit} = 0;
    $db->begin_work;
    eval{
        C4::AR::Estantes::_verificacionesParaModificar($msg_object,$estante,$valor);
        if(!$msg_object->{'error'}){
            C4::AR::Debug::debug("VAMOS A MODIFICAR EL ESTANTE");
            $estante->setEstante($valor);
            $estante->save();
            $db->commit;
            $msg_object->{'error'}= 0;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'E007', 'params' => [$valor]} ) ;
            C4::AR::Debug::debug("ESTANTE MODIFICADO CON EXITO");
        }
        };
    if ($@){
        C4::AR::Debug::debug("ERROR");
        &C4::AR::Mensajes::printErrorDB($@, '',"INTRA");
        $db->rollback;
        #Se setea error para el usuario
        $msg_object->{'error'}= 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'E008', 'params' => [$estante->getEstante]} ) ;
    }
    $db->{connect_options}->{AutoCommit} = 1;
    return ($msg_object);
}
sub _verificacionesParaModificar {
    my($msg_object,$estante,$valor)=@_;
    if (C4::AR::Estantes::buscarNombreDuplicado($estante->getPadre,$estante,$valor)){
    #El estante posee contenido
            $msg_object->{'error'}= 1;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'E009', 'params' => [$valor]} ) ;
            C4::AR::Debug::debug("Entro al if de estante duplicado ");
      }
}
sub _verificacionesParaAgregar {
    my($msg_object,$estante,$valor)=@_;
    if (C4::AR::Estantes::buscarNombreDuplicado($estante->getId,0,$valor)){
    #El estante posee contenido
            $msg_object->{'error'}= 1;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'E010', 'params' => [$valor]} ) ;
            C4::AR::Debug::debug("Entro al if de estante duplicado ");
      }
}
sub _verificacionesParaAgregarContenido {
    my($msg_object,$estante,$id2)=@_;
	
	my $contenido = $estante->contenido;
	  if ($contenido){
        foreach my $contenido_estante (@$contenido){
	   if($contenido_estante->getId2 eq $id2){
		#El estante ya posee contenido
		$msg_object->{'error'}= 1;
		C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'E015', 'params' => [Encode::decode_utf8($estante->getEstante)]} ) ;
		C4::AR::Debug::debug("Entro al if de estante duplicado ");
	    }
         }
         }
}
sub buscarNombreDuplicado {
    my ($padre,$estante,$valor) = @_;
    my @filtros;
    if ($estante){push(@filtros, ( id  => { ne => $estante->getId} ));}
    push(@filtros, ( padre  => { eq => $padre} ));
    push(@filtros, ( estante  => { eq => $valor} ));
    my $estantes_array_ref = C4::Modelo::CatEstante::Manager->get_cat_estante( query => \@filtros, sort_by => 'estante');
    return ($estantes_array_ref->[0]);
}
sub buscarEstante {
    # Se buscan los estantes
    my ($estante, $ini, $cantR) = @_;
    my @filtros;
    push(@filtros, ( estante => { like => '%'.$estante.'%' }) );
    push(@filtros, ( tipo => { eq => 'public' }));
    my $estantes_array_ref = C4::Modelo::CatEstante::Manager->get_cat_estante( query => \@filtros, 
									       sort_by => 'estante',
									       limit   => $cantR,
									       offset  => $ini,);
    my $cant= C4::Modelo::CatEstante::Manager->get_cat_estante_count( query => \@filtros, 
									       sort_by => 'estante');
    C4::AR::Debug::debug("BUSQUEDA ESTANTE ==> ".$estante."  resultados: ".$cant." limit = ".$cantR." offset = ".$ini);
	if($cant > 0){
		return ($cant, $estantes_array_ref);
	}else{
		return ($cant, 0);
	}
}
sub getEstantesById2 {
    my ($id2, $ini, $cantR) = @_;
    my @filtros;
    push(@filtros, ( 'contenido.id2'    => { eq => $id2 }) );
    push(@filtros, ( 'tipo'             => { eq => 'public' }));
    my $estantes_array_ref = C4::Modelo::CatEstante::Manager->get_cat_estante( query => \@filtros, 
									       sort_by => 'estante',
 									       require_objects    => ['contenido'],
									       limit   => $cantR,
									       offset  => $ini,);
    my $cant = C4::Modelo::CatEstante::Manager->get_cat_estante_count( query => \@filtros, 
									      require_objects    => ['contenido'],
									       sort_by => 'estante');
    # C4::AR::Debug::debug("BUSQUEDA ESTANTES de ID2 ==> ".$id2."  resultados: ".$cant." limit = ".$cantR." offset = ".$ini);
	if($cant > 0){
		return ($cant, $estantes_array_ref);
	}else{
		return ($cant, 0);
	}
}
sub estaEnEstanteVirtual {
    my ($id2) = @_;
    my @filtros;
    push(@filtros, ( 'contenido.id2' => { eq => $id2 }) );
    push(@filtros, ( 'tipo' => { eq => 'public' }));
    my $cant = C4::Modelo::CatEstante::Manager->get_cat_estante_count( query => \@filtros,require_objects    => ['contenido'],);
    return ($cant > 0);
}
sub agregarSubEstante  {
    my ($id_estante,$valor)=@_;
    C4::AR::Debug::debug("Antes de verificar");
    my $msg_object= C4::AR::Mensajes::create();
    $msg_object->{'tipo'}="INTRA";
    my ($estante) = C4::Modelo::CatEstante->new(id => $id_estante);
    $estante->load();
    my $db = $estante->db;
    $db->{connect_options}->{AutoCommit} = 0;
    $db->begin_work;
    eval{
        C4::AR::Estantes::_verificacionesParaAgregar($msg_object,$estante,$valor);
        if(!$msg_object->{'error'}){
            C4::AR::Debug::debug("VAMOS A AGREGAR EL SUBESTANTE");
            my $nuevo_estante = C4::Modelo::CatEstante->new(db => $db);
            $nuevo_estante->setEstante($valor);
            $nuevo_estante->setPadre($estante->getId);
            $nuevo_estante->setTipo('public');
            $nuevo_estante->save();
            $db->commit;
            $msg_object->{'error'}= 0;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'E011', 'params' => [$valor]} ) ;
            C4::AR::Debug::debug("SUBESTANTE AGREGADO CON EXITO");
        }
        };
    if ($@){
        C4::AR::Debug::debug("ERROR");
        &C4::AR::Mensajes::printErrorDB($@, '',"INTRA");
        $db->rollback;
        #Se setea error para el usuario
        $msg_object->{'error'}= 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'E012', 'params' => [$valor]} ) ;
    }
    $db->{connect_options}->{AutoCommit} = 1;
    return ($msg_object);
}
sub agregarEstante  {
    my ($valor)=@_;
    C4::AR::Debug::debug("Antes de verificar");
    my $msg_object= C4::AR::Mensajes::create();
    $msg_object->{'tipo'}="INTRA";
    my ($estante) = C4::Modelo::CatEstante->new(id => 0);
    my $db = $estante->db;
    $db->{connect_options}->{AutoCommit} = 0;
    $db->begin_work;
    eval{
        C4::AR::Estantes::_verificacionesParaAgregar($msg_object,$estante,$valor);
        if(!$msg_object->{'error'}){
            C4::AR::Debug::debug("VAMOS A AGREGAR EL ESTANTE");
            my $nuevo_estante = C4::Modelo::CatEstante->new(db => $db);
            $nuevo_estante->setEstante($valor);
            $nuevo_estante->setPadre($estante->getId);
            $nuevo_estante->setTipo('public');
            $nuevo_estante->save();
            $db->commit;
            $msg_object->{'error'}= 0;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'E011', 'params' => [$valor]} ) ;
            C4::AR::Debug::debug("ESTANTE AGREGADO CON EXITO");
        }
        };
    if ($@){
        C4::AR::Debug::debug("ERROR");
        &C4::AR::Mensajes::printErrorDB($@, '',"INTRA");
        $db->rollback;
        #Se setea error para el usuario
        $msg_object->{'error'}= 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'E012', 'params' => [$valor]} ) ;
    }
    $db->{connect_options}->{AutoCommit} = 1;
    return ($msg_object);
}
sub agregarContenidoAEstante {
    my ($id_estante,$id2)=@_;
    C4::AR::Debug::debug("Antes de verificar");
    my $msg_object= C4::AR::Mensajes::create();
    $msg_object->{'tipo'}="INTRA";
  C4::AR::Debug::debug("Cargando estante ".$id_estante);
    my $estante = C4::AR::Estantes::getEstante($id_estante);
     C4::AR::Debug::debug("Cargando estante ".$estante->getEstante);
    my $db = $estante->db;
    $db->{connect_options}->{AutoCommit} = 0;
    $db->begin_work;
    eval{
        C4::AR::Estantes::_verificacionesParaAgregarContenido($msg_object,$estante,$id2);
        if(!$msg_object->{'error'}){
            C4::AR::Debug::debug("VAMOS A AGREGAR CONTENIDO AL ESTANTE");
            my $nuevo_contenido_estante = C4::Modelo::CatContenidoEstante->new(db => $db);
            $nuevo_contenido_estante->setId_estante($id_estante);
            $nuevo_contenido_estante->setId2($id2);
            $nuevo_contenido_estante->save();
            $db->commit;
            $msg_object->{'error'}= 0;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'E014', 'params' => [Encode::decode_utf8($estante->getEstante)]} ) ;
            C4::AR::Debug::debug("CONTENIDO AGREGADO CON EXITO AL ESTANTE");
        }
        };
    if ($@){
        C4::AR::Debug::debug("ERROR");
        &C4::AR::Mensajes::printErrorDB($@, '',"INTRA");
        $db->rollback;
        #Se setea error para el usuario
        $msg_object->{'error'}= 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'E013', 'params' => [Encode::decode_utf8($estante->getEstante)]} ) ;
    }
    $db->{connect_options}->{AutoCommit} = 1;
    return ($msg_object);
    }
sub clonarEstante  {
    my ($id_estante)=@_;
    my $msg_object= C4::AR::Mensajes::create();
    $msg_object->{'tipo'}="INTRA";
    my ($estante) = C4::Modelo::CatEstante->new(id => $id_estante);
    $estante->load();
    my $db = $estante->db;
    $db->{connect_options}->{AutoCommit} = 0;
    $db->begin_work;
    eval{
            my $nuevo_estante =  $estante->clonar();
            $db->commit;
            $msg_object->{'error'}= 0;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'E016', 'params' => [$nuevo_estante->getEstante]} ) ;
        };
    if ($@){
        C4::AR::Debug::debug("ERROR");
        &C4::AR::Mensajes::printErrorDB($@, '',"INTRA");
        $db->rollback;
        #Se setea error para el usuario
        $msg_object->{'error'}= 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'E017', 'params' => [$estante->getEstante]} ) ;
    }
    $db->{connect_options}->{AutoCommit} = 1;
    return ($msg_object);
}
1;
