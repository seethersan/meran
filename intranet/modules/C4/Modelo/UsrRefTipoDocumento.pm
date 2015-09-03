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
# along with Meran.  If not, see <http://www.gnu.org/licenses/>.package C4::Modelo::UsrRefTipoDocumento;
use strict;
    
use base qw(C4::Modelo::DB::Object::AutoBase2);
__PACKAGE__->meta->setup(
    table   => 'usr_ref_tipo_documento',
    columns => [
        id                => { type => 'serial', overflow => 'truncate', not_null => 1 },
        nombre            => { type => 'varchar', overflow => 'truncate', length => 50, not_null => 1 },
        descripcion       => { type => 'varchar', overflow => 'truncate', length => 250, not_null => 1 },
    ],
    primary_key_columns => [ 'id' ],
    unique_key => [ 'nombre' ],
);
use C4::Modelo::UsrRefTipoDocumento::Manager;
use C4::Modelo::RefEstado;
use Text::LevenshteinXS;
sub toString{
    my ($self) = shift;
    return ($self->getDescripcion);
}
sub getId{
  my ($self) = shift;
  return ($self->id);
}
sub getDescripcion{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->descripcion));
}
    
sub setDescripcion{
    my ($self) = shift;
    my ($descripcion) = @_;
    $self->descripcion($descripcion);
}
    
sub getNombre{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->nombre));
}
    
sub setNombre{
    my ($self) = shift;
    my ($nombre) = @_;
    $self->nombre($nombre);
}
sub obtenerValoresCampo {
	my ($self)              = shift;
    my ($campo, $orden)     = @_;
    my @array_valores;
    my @fields  = ($campo, $orden);
    my $v       = $self->validate_fields(\@fields);
    if($v){
        my $ref_valores = C4::Modelo::UsrRefTipoDocumento::Manager->get_usr_ref_tipo_documento
                            ( select   => ['nombre',$campo],
                              sort_by => ($orden) );
        for(my $i=0; $i<scalar(@$ref_valores); $i++ ){
      
                my $valor;
                $valor->{"clave"}=$ref_valores->[$i]->getNombre;
                $valor->{"valor"}=$ref_valores->[$i]->getCampo($campo);
            push (@array_valores, $valor);
        }
    }
	
    return (scalar(@array_valores), \@array_valores);
}
sub obtenerValorCampo {
	my ($self)=shift;
    	my ($campo,$id)=@_;
 	my $ref_valores = C4::Modelo::UsrRefTipoDocumento::Manager->get_usr_ref_tipo_documento
						( select   => [$campo],
						  query =>[ descripcion => { eq => $id} ]);
  if(scalar(@$ref_valores) > 0){
    return ($ref_valores->[0]->getCampo($campo));
  }else{
    #no se pudo recuperar el objeto por el id pasado por parametro
    return undef;
  }
}
sub getCampo{
    my ($self) = shift;
	my ($campo)=@_;
    
	if ($campo eq "descripcion") {return $self->getDescripcion;}
	if ($campo eq "nombre") {return $self->getNombre;}
	return (0);
}
sub nextMember{
    return(C4::Modelo::RefEstado->new());
}
sub getAll{
    my ($self) = shift;
    my ($limit,$offset,$matchig_or_not,$filtro)=@_;
    $matchig_or_not = $matchig_or_not || 0;
    my @filtros;
    if ($filtro){
        my @filtros_or;
        push(@filtros_or, (nombre => {like => '%'.$filtro.'%'}) );
        push(@filtros_or, (descripcion => {like => '%'.$filtro.'%'}) );
        push(@filtros, (or => \@filtros_or) );
    }
    my $ref_valores;
    if ($matchig_or_not){ #ESTOY BUSCANDO SIMILARES, POR LO TANTO NO TENGO QUE LIMITAR PARA PERDER RESULTADOS
        push(@filtros, ($self->getPk => {ne => $self->getPkValue}) );
        $ref_valores = C4::Modelo::UsrRefTipoDocumento::Manager->get_usr_ref_tipo_documento(query => \@filtros,);
    }else{
        $ref_valores = C4::Modelo::UsrRefTipoDocumento::Manager->get_usr_ref_tipo_documento(query => \@filtros,
                                                                    limit => $limit, 
                                                                    offset => $offset, 
                                                                    sort_by => ['descripcion'] 
                                                                   );
    }
    my $ref_cant = C4::Modelo::UsrRefTipoDocumento::Manager->get_usr_ref_tipo_documento_count(query => \@filtros,);
    my $self_descripcion = $self->getDescripcion;
    my $match = 0;
    if ($matchig_or_not){
        my @matched_array;
        foreach my $each (@$ref_valores){
          $match = ((distance($self_descripcion,$each->getDescripcion)<=1));
          if ($match){
            push (@matched_array,$each);
          }
        }
        return (scalar(@matched_array),\@matched_array);
    }
    else{
      return($ref_cant,$ref_valores);
    }
}
1;
