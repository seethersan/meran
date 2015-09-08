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
package C4::AR::ControlAutoridades;
use strict;
require Exporter;
use C4::Date;
use vars qw(@EXPORT @ISA);
@ISA=qw(Exporter);
@EXPORT=qw(	
		t_insertSinonimosAutor
		t_insertSinonimosTemas 
		t_insertSinonimosEditoriales
		t_insertSeudonimosAutor 
		t_insertSeudonimosTemas
		t_insertSeudonimosEditoriales 
		t_eliminarSinonimosAutor 
		t_eliminarSinonimosTema 
		t_eliminarSinonimosEditorial 
		t_eliminarSeudonimosAutor
		t_eliminarSeudonimosTema 
		t_eliminarSeudonimosEditorial
		t_updateSinonimosAutores
		t_updateSinonimosEditoriales
		t_updateSinonimosTemas
		traerSeudonimosAutor 
		traerSeudonimosTemas 
		traerSeudonimosEditoriales 
		traerSinonimosAutor 
		traerSinonimosTemas 
		traerSinonimosEditoriales 
		search_temas
		search_autores
		search_editoriales
);
sub search_temas{
	my ($tema)=@_; 
    my @filtros;
    push(@filtros, ( nombre => { like => '%'.$tema.'%'}) );
    my $temas_array_ref = C4::Modelo::CatTema::Manager->get_cat_tema(
        query => \@filtros,
        sort_by => 'nombre ASC',
        limit   => C4::AR::Preferencias::getValorPreferencia("limite_resultados_autocompletables"),
    );
    return (scalar(@$temas_array_ref), $temas_array_ref);
    #my $dbh = C4::Context->dbh;
    #my $sth=$dbh->prepare("	SELECT id, nombre
}
=head2
    sub search_autores
=cut
sub search_autores{
    my ($autor) = @_;
    my @filtros;
    my @filtros_or;
    push(@filtros_or, ( completo => { like => $autor.'%'}) );
    push(@filtros_or, ( nombre => { like => $autor.'%'}) );
    push(@filtros_or, ( apellido => { like => $autor.'%'}) );
    push(@filtros, (or => \@filtros_or) );
    
    use C4::AR::Preferencias;
    my $limit = C4::AR::Preferencias::getValorPreferencia('limite_resultados_autocompletables') || 20;
    
    my $autores_array_ref = C4::Modelo::CatAutor::Manager->get_cat_autor(
                                        query   => \@filtros,
                                        select  => ['*'],
                                        sort_by => 'completo ASC',
                                        limit   => $limit,
                                        offset  => 0,
                                     );
    return (scalar(@$autores_array_ref), $autores_array_ref);
}
sub search_editoriales{
	my ($editorial)=@_; 
    my @filtros;
    push(@filtros, ( editorial => { like => '%'.$editorial.'%'}) );
    my $editoriales_array_ref = C4::Modelo::CatEditorial::Manager->get_cat_editorial(
        query => \@filtros,
        sort_by => 'editorial ASC',
        limit   => C4::AR::Preferencias::getValorPreferencia("limite_resultados_autocompletables"),
    );
    return (scalar(@$editoriales_array_ref), $editoriales_array_ref);
}
sub traerSinonimosAutor{
    my ($autor)=@_;
    use C4::Modelo::CatControlSinonimoAutor::Manager;
    my @filtros;
    push(@filtros, ( id => { eq => $autor}) );
    
    my $sinonimos_autor = C4::Modelo::CatControlSinonimoAutor::Manager->get_cat_control_sinonimo_autor(
                                                                                    query => \@filtros,
                                                                                    );
    return (scalar(@$sinonimos_autor), $sinonimos_autor);
}
sub traerSinonimosTemas{
    my ($autor)=@_;
    use C4::Modelo::CatControlSinonimoTema::Manager;
    my @filtros;
    push(@filtros, ( id => { eq => $autor}) );
    
    my $sinonimos_tema = C4::Modelo::CatControlSinonimoTema::Manager->get_cat_control_sinonimo_tema(
                                                                                    query => \@filtros,
                                                                                    sort_by => 'tema ASC',
                                                                                    );
    return (scalar(@$sinonimos_tema), $sinonimos_tema);
}
sub traerSinonimosEditoriales{
    my ($editorial)=@_;
    use C4::Modelo::CatControlSinonimoEditorial::Manager;
    my @filtros;
    push(@filtros, ( id => { eq => $editorial}) );
    
    my $sinonimos_editorial = C4::Modelo::CatControlSinonimoEditorial::Manager->get_cat_control_sinonimo_editorial(
                                                                                    query => \@filtros,
                                                                                    sort_by => 'editorial ASC',
                                                                                    );
    return (scalar(@$sinonimos_editorial), $sinonimos_editorial);
}
sub t_insertSinonimosAutor {
	my($sinonimos_arrayref, $idAutor)=@_;
	my $msg_object= C4::AR::Mensajes::create();
    my $sinonimo_dbo = C4::Modelo::CatControlSinonimoAutor->new();
    my $db = $sinonimo_dbo->db;
	$db->{connect_options}->{AutoCommit} = 0;
  	$db->begin_work;
	
	eval{
        foreach my $sinonimo (@$sinonimos_arrayref){
			my $sinonimo_temp = C4::Modelo::CatControlSinonimoAutor->new(db => $db);
            $sinonimo_temp->agregar($sinonimo->{'text'},$idAutor);
			C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U393', 'params' => []} ) ;
		}
        $db->commit;
	};
	if ($@){
		#Se loguea error de Base de Datos
		&C4::AR::Mensajes::printErrorDB($@, 'B437',"INTRA");
		$msg_object->{'error'} = 1;
		#Se setea error para el usuario
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U391', 'params' => []} ) ;
		$db->rollback;
	}
  
	$db->{connect_options}->{AutoCommit} = 1;
		
	return ($msg_object)
}
sub t_insertSinonimosTemas {
    my($sinonimos_arrayref, $idTema)=@_;
    my $msg_object= C4::AR::Mensajes::create();
    my $sinonimo_dbo = C4::Modelo::CatControlSinonimoTema->new();
    my $db = $sinonimo_dbo->db;
 	$db->begin_work;
	$db->{connect_options}->{AutoCommit} = 0;
    eval{
        foreach my $sinonimo (@$sinonimos_arrayref){
			my $sinonimo_temp = C4::Modelo::CatControlSinonimoTema->new(db => $db);
            $sinonimo_temp->agregar($sinonimo->{'text'},$idTema);
			C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U393', 'params' => []});
        }
        $db->commit;
    };
	if ($@){
		#Se loguea error de Base de Datos
		&C4::AR::Mensajes::printErrorDB($@, 'B438',"INTRA");
		$msg_object->{'error'} = 1;
		#Se setea error para el usuario
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U391', 'params' => []} ) ;
		$db->rollback;
	}
  
	$db->{connect_options}->{AutoCommit} = 1;
    return ($msg_object)
}
sub t_insertSinonimosEditoriales {
    my($sinonimos_arrayref, $idEditorial)=@_;
    use C4::Modelo::CatControlSinonimoEditorial;
    my $msg_object= C4::AR::Mensajes::create();
    my $sinonimo_dbo = C4::Modelo::CatControlSinonimoEditorial->new();
    my $db = $sinonimo_dbo->db;
 	$db->begin_work;
	$db->{connect_options}->{AutoCommit} = 0;
    eval{
        foreach my $sinonimo (@$sinonimos_arrayref){
			$sinonimo_dbo = C4::Modelo::CatControlSinonimoEditorial->new(db => $db);
            $sinonimo_dbo->agregar($sinonimo->{'text'},$idEditorial);
			C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U393', 'params' => [$sinonimo->{'text'}]});
        }
        $db->commit;
    };
   if ($@){
		#Se loguea error de Base de Datos
		&C4::AR::Mensajes::printErrorDB($@, 'B439',"INTRA");
		$msg_object->{'error'} = 1;
		#Se setea error para el usuario
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U391', 'params' => []} ) ;
		$db->rollback;
	}
  
	$db->{connect_options}->{AutoCommit} = 1;
    
    return ($msg_object)
}
sub t_updateSinonimosAutores {
	my($idSinonimo, $nombre, $nombreViejo)=@_;
    my $msg_object= C4::AR::Mensajes::create();
	eval {
		my $sinonimo_autor= getSinonimoAutor($idSinonimo, $nombreViejo);
        $sinonimo_autor->load();
		$sinonimo_autor->agregar($nombre,$idSinonimo);
		C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U395', 'params' => [$nombre]});
	};
	if ($@){
		#Se loguea error de Base de Datos
		&C4::AR::Mensajes::printErrorDB($@, 'B443',"INTRA");
        $msg_object->{'error'} = 1;
		#Se setea error para el usuario
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'CA605', 'params' => [$nombre]} ) ;
    }
	
	return ($msg_object)
}
sub getSinonimoAutor{
	my($idSinonimo, $autor)=@_;
	
	my @filtros;
    push(@filtros, ( id => { eq => $idSinonimo}) );
	push(@filtros, ( autor => { eq => $autor}) );
    
    my $sinonimos_autores = C4::Modelo::CatControlSinonimoAutor::Manager->get_cat_control_sinonimo_autor(
                                                                                    query => \@filtros,
                                                                         );
	if(scalar(@$sinonimos_autores) > 0){
		return ($sinonimos_autores->[0]);
	}else{
		return 0;
	}
}
sub getSinonimoTema{
	my($idSinonimo, $tema)=@_;
	
	my @filtros;
    push(@filtros, ( id => { eq => $idSinonimo}) );
	push(@filtros, ( tema => { eq => $tema}) );
    
    my $sinonimos_temas = C4::Modelo::CatControlSinonimoTema::Manager->get_cat_control_sinonimo_tema(
                                                                                    query => \@filtros,
                                                                         );
	if(scalar(@$sinonimos_temas) > 0){
		return ($sinonimos_temas->[0]);
	}else{
		return 0;
	}
}
sub getSinonimoEditorial{
	my($idSinonimo, $editorial)=@_;
	
	my @filtros;
    push(@filtros, ( id => { eq => $idSinonimo}) );
	push(@filtros, ( editorial => { eq => $editorial}) );
    
    my $sinonimos_editoriales = C4::Modelo::CatControlSinonimoEditorial::Manager->get_cat_control_sinonimo_editorial(
                                                                                    query => \@filtros,
                                                                         );
	if(scalar(@$sinonimos_editoriales) > 0){
		return ($sinonimos_editoriales->[0]);
	}else{
		return 0;
	}
}
sub t_updateSinonimosTemas {
    
    my($idSinonimo, $nombre, $nombreViejo)=@_;
    use C4::Modelo::CatControlSinonimoTema;
    my $msg_object= C4::AR::Mensajes::create();
    
    eval {
		my $sinonimo_tema = getSinonimoTema($idSinonimo, $nombreViejo);
		$sinonimo_tema->load();
		$sinonimo_tema->agregar($nombre,$idSinonimo);
		C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U395', 'params' => [$nombre]});
    };
   
	if ($@){
		#Se loguea error de Base de Datos
		&C4::AR::Mensajes::printErrorDB($@, 'B444',"INTRA");
        $msg_object->{'error'} = 1;
		#Se setea error para el usuario
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'CA605', 'params' => [$nombre]} ) ;
    }
    
    return ($msg_object)
}
sub t_updateSinonimosEditoriales {
    
    my($idSinonimo, $nombre, $nombreViejo)=@_;
    use C4::Modelo::CatControlSinonimoEditorial;
    my $msg_object= C4::AR::Mensajes::create();
    
    eval {
		my $sinonimo_editorial = getSinonimoEditorial($idSinonimo, $nombreViejo);
		$sinonimo_editorial->load();
		$sinonimo_editorial->agregar($nombre,$idSinonimo);
		C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U395', 'params' => [$nombre]});
    };
	if ($@){
		#Se loguea error de Base de Datos
		&C4::AR::Mensajes::printErrorDB($@, 'B444',"INTRA");
        $msg_object->{'error'} = 1;
		#Se setea error para el usuario
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'CA605', 'params' => [$nombre]} ) ;
    }
    return ($msg_object)
}
sub t_eliminarSinonimosAutor {
	
	my($idAutor,$sinonimo)=@_;
	my $msg_object= C4::AR::Mensajes::create();
	
	eval {
        use C4::Modelo::CatControlSinonimoAutor::Manager;
        my @filtros;
        push(@filtros, ( id => { eq => $idAutor}) );
        push(@filtros, ( autor => { eq => $sinonimo}) );
		C4::Modelo::CatControlSinonimoAutor::Manager->delete_cat_control_sinonimo_autor( where => \@filtros);
		C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U310', 'params' => [$sinonimo]});
	};
 	if ($@){
		#Se loguea error de Base de Datos
		&C4::AR::Mensajes::printErrorDB($@, 'B440',"INTRA");
        $msg_object->{'error'} = 1;
		#Se setea error para el usuario
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'CA604', 'params' => [$sinonimo]} ) ;
    }
	return ($msg_object)
}
sub t_eliminarSinonimosTema {
    
    my($idTema,$sinonimo)=@_;
    my $msg_object= C4::AR::Mensajes::create();
    
    eval {
        use C4::Modelo::CatControlSinonimoTema::Manager;
        my @filtros;
        push(@filtros, ( id => { eq => $idTema}) );
        push(@filtros, ( tema => { eq => $sinonimo}) );
        C4::Modelo::CatControlSinonimoTema::Manager->delete_cat_control_sinonimo_tema( where => \@filtros);
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U310', 'params' => [$sinonimo]});
    };
    if ($@){
		#Se loguea error de Base de Datos
		&C4::AR::Mensajes::printErrorDB($@, 'B441',"INTRA");
        $msg_object->{'error'} = 1;
		#Se setea error para el usuario
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'CA604', 'params' => [$sinonimo]} ) ;
    }
	
    return ($msg_object)
}
sub t_eliminarSinonimosEditorial {
	
    
    my($idEditorial,$sinonimo)=@_;
	my $msg_object= C4::AR::Mensajes::create();
    
    eval {
        use C4::Modelo::CatControlSinonimoEditorial::Manager;
        my @filtros;
        push(@filtros, ( id => { eq => $idEditorial}) );
        push(@filtros, ( editorial => { eq => $sinonimo}) );
        C4::Modelo::CatControlSinonimoEditorial::Manager->delete_cat_control_sinonimo_editorial( where => \@filtros);
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U310', 'params' => [$sinonimo]});
    };
    if ($@){
		#Se loguea error de Base de Datos
		&C4::AR::Mensajes::printErrorDB($@, 'B442',"INTRA");
        $msg_object->{'error'} = 1;
		#Se setea error para el usuario
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'CA604', 'params' => [$sinonimo]} ) ;
    }
    
    return ($msg_object)
}
sub traerSeudonimosAutor{
    my ($autor)=@_;
    use C4::Modelo::CatControlSeudonimoAutor::Manager;
    my @filtros;
    push(@filtros, ( id_autor => { eq => $autor}) );
    
    my $sinonimos_autor = C4::Modelo::CatControlSeudonimoAutor::Manager->get_cat_control_seudonimo_autor(
                                                                                    query => \@filtros,
                                                                                    require_objects => ['seudonimo','autor'],
                                                                                    );
    return (scalar(@$sinonimos_autor), $sinonimos_autor);
}
sub traerSeudonimosTema{
  my ($idTema)=@_;
    use C4::Modelo::CatControlSeudonimoTema::Manager;
    my @filtros;
    push(@filtros, ( id_tema => {eq => $idTema} ) );
    my $seudonimos_tema = C4::Modelo::CatControlSeudonimoTema::Manager->get_cat_control_seudonimo_tema(
                                                                                    query => \@filtros,
                                                                                    require_objects => ['tema','seudonimo'],
                                                                                   );
    return (scalar(@$seudonimos_tema), $seudonimos_tema);
}
sub traerSeudonimosEditoriales{
  my ($idEditorial)=@_;
    use C4::Modelo::CatControlSeudonimoEditorial::Manager;
    my @filtros;
    push(@filtros, ( id_editorial => {eq => $idEditorial} ) );
    my $seudonimos_editorial = C4::Modelo::CatControlSeudonimoEditorial::Manager->get_cat_control_seudonimo_editorial(
                                                                                    query => \@filtros,
                                                                                    require_objects => ['editorial','seudonimo'],
                                                                                   );
    return (scalar(@$seudonimos_editorial), $seudonimos_editorial);
}
sub t_insertSeudonimosAutor {
    my($seudonimos_arrayref, $idAutor)=@_;
    my $msg_object= C4::AR::Mensajes::create();
	my $seudonimo = C4::Modelo::CatControlSeudonimoAutor->new();
	my $db= $seudonimo->db;
	$db->{connect_options}->{AutoCommit} = 0;
 	$db->begin_work;
    
    eval {
        foreach my $seudonimo (@$seudonimos_arrayref){
            my $seudonimo_temp = C4::Modelo::CatControlSeudonimoAutor->new(db => $db);
			my $id_autor_seudonimo = $seudonimo->{'ID'};
			$seudonimo_temp->agregar($idAutor, $id_autor_seudonimo);
			C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U392', 'params' => []});
        }
		$db->commit;
    };
    if ($@){
        #Se loguea error de Base de Datos
		&C4::AR::Mensajes::printErrorDB($@, 'B437',"INTRA");
        $msg_object->{'error'} = 1;
		#Se setea error para el usuario
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U390', 'params' => []} ) ;
		$db->rollback;
    }
	 $db->{connect_options}->{AutoCommit} = 1;
    return ($msg_object)
}
sub t_eliminarSeudonimosAutor {
	
	my($idAutor,$seudonimo)=@_;
        my $msg_object= C4::AR::Mensajes::create();
    my ($error,$codMsg,$message);
    my ($error,$codMsg,$message);
        my $msg_object= C4::AR::Mensajes::create();
    my ($error,$codMsg,$message);
    my ($error,$codMsg,$message);
	eval {
		use C4::Modelo::CatControlSeudonimoAutor::Manager;
        my @filtros;
        push (@filtros,( id_autor => {eq => $idAutor} ) );
        push (@filtros,( id_autor_seudonimo => {eq => $seudonimo}) );
        C4::Modelo::CatControlSeudonimoAutor::Manager->delete_cat_control_seudonimo_autor( where => \@filtros,);
		$msg_object->{'error'}= 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U309', 'params' => []} ) ;
	};
	if ($@){
		#Se setea error para el usuario
        $msg_object->{'error'}= 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'CA603', 'params' => []} ) ;
	}
    return ($msg_object);
}
=item
Esta fucion elimina el $seudonimo del autor pasado por parametro
=cut
sub t_insertSeudonimosTemas {
  	my($seudonimos_arrayref, $idTema)=@_;
 	my $msg_object= C4::AR::Mensajes::create();
	my $seudonimo = C4::Modelo::CatControlSeudonimoTema->new();
	my $db= $seudonimo->db;
	$db->{connect_options}->{AutoCommit} = 0;
 	$db->begin_work;
	eval {
	
		foreach my $seudonimo (@$seudonimos_arrayref){
			my $seudonimo_temp = C4::Modelo::CatControlSeudonimoTema->new( db => $db );
			$seudonimo_temp->agregar($idTema,$seudonimo->{'ID'});
			C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U392', 'params' => []});
		}
		$db->commit;
	
	};
	if ($@){
		#Se loguea error de Base de Datos
		&C4::AR::Mensajes::printErrorDB($@, 'B438',"INTRA");
		$msg_object->{'error'} = 1;
		#Se setea error para el usuario
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U390', 'params' => []} ) ;
		$db->rollback;
	}
  
	$db->{connect_options}->{AutoCommit} = 1;
	 
	return ($msg_object)
}
sub t_eliminarSeudonimosTema {
  
  my($idTema,$seudonimo)=@_;
  my $msg_object= C4::AR::Mensajes::create();
  eval {
    use C4::Modelo::CatControlSeudonimoTema::Manager;
    my @filtros;
    push (@filtros, (id_tema => {eq => $idTema}) );
    push (@filtros, (id_tema_seudonimo => {eq => $seudonimo}) );
    C4::Modelo::CatControlSeudonimoTema::Manager->delete_cat_control_seudonimo_tema( where => \@filtros);
    C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U309', 'params' => []} );
  };
  if ($@){
      #Se loguea error de Base de Datos
      $msg_object->{'error'} = 1;
      C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'B400', 'params' => []} );
  }
  
  return ($msg_object)
}
sub t_insertSeudonimosEditoriales {
  	my($seudonimos_arrayref, $idEditorial)=@_;
	
	my $msg_object= C4::AR::Mensajes::create();
	
	my $db = C4::Modelo::CatControlSeudonimoEditorial->new()->db;
	
	$db->{connect_options}->{AutoCommit} = 0;
	$db->begin_work;
	eval {
	
		foreach my $seudonimo (@$seudonimos_arrayref){
			my $seudonimo_temp = C4::Modelo::CatControlSeudonimoEditorial->new( db => $db );
			$seudonimo_temp->agregar($idEditorial,$seudonimo->{'ID'});
			C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U392', 'params' => []} );
		}
		$db->commit;
	
	};
	if ($@){
		#Se loguea error de Base de Datos
		&C4::AR::Mensajes::printErrorDB($@, 'B439',"INTRA");
		$msg_object->{'error'} = 1;
		#Se setea error para el usuario
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U390', 'params' => []} ) ;
		$db->rollback;
	}
  
	$db->{connect_options}->{AutoCommit} = 1;
 	return ($msg_object)
}
sub t_eliminarSeudonimosEditorial {
  
  my($idEditorial,$seudonimo)=@_;
  my $msg_object= C4::AR::Mensajes::create();
  eval {
    use C4::Modelo::CatControlSeudonimoEditorial::Manager;
    my @filtros;
    push (@filtros, (id_editorial => {eq => $idEditorial}) );
    push (@filtros, (id_editorial_seudonimo => {eq => $seudonimo}) );
    C4::Modelo::CatControlSeudonimoEditorial::Manager->delete_cat_control_seudonimo_editorial( where => \@filtros);
    C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U309', 'params' => []} );
  };
  if ($@){
      #Se loguea error de Base de Datos
      $msg_object->{'error'} = 1;
      C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'B400', 'params' => []} );
  }
  
  return ($msg_object)
}
END { }       # module clean-up code here (global destructor)
1;
__END__