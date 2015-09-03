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
# along with Meran.  If not, see <http://www.gnu.org/licenses/>.package C4::Modelo::CatRefTipoNivel3;
use strict;
use base qw(C4::Modelo::DB::Object::AutoBase2);
__PACKAGE__->meta->setup(
    table   => 'cat_ref_tipo_nivel3',
    columns => [
        id                          => { type => 'serial', overflow => 'truncate', length => 11, not_null => 1 },
        id_tipo_doc                 => { type => 'varchar', overflow => 'truncate', length => 8, not_null => 1 },
        nombre                      => { type => 'varchar', overflow => 'truncate', length => 255, not_null => 1 },
        agregacion_temp             => { type => 'varchar', overflow => 'truncate', length => 250 },
        disponible                  => { type => 'integer', overflow => 'truncate', length => 1, not_null => 1, default => 1 },
        enable_nivel3               => { type => 'integer', overflow => 'truncate', length => 1, not_null => 1, default => 1 },
        enable_from_new_register    => { type => 'integer', overflow => 'truncate', length => 1, not_null => 1, default => 1 },
    ],
    primary_key_columns => [ 'id' ],
    unique_key => [ 'id_tipo_doc' ],
    
);
use C4::Modelo::PrefUnidadInformacion;
use C4::Modelo::CatRefTipoNivel3::Manager;
use Text::LevenshteinXS;
sub toString{
    my ($self)   = shift;
    return $self->getNombre;
}
=item
    Agrega un objeto CatRefTipoNivel3
=cut
sub agregar{
    my ($self)   = shift;
    my ($params) = @_;
    $self->id_tipo_doc($params->{'tipoDocumento'});
    $self->nombre($params->{'nombre'});
    $self->disponible(1);
    $self->enable_nivel3($params->{'nombre'});
    $self->save();
}
sub get_key_value{
    my ($self) = shift;
    
    return ($self->getId_tipo_doc);
}
sub getId{
    my ($self) = shift;
    return ($self->id);
}
sub getId_tipo_doc{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->id_tipo_doc));
}
sub setId_tipo_doc{
    my ($self) = shift;
    my ($id_tipo_doc) = @_;
    $self->id_tipo_doc($id_tipo_doc);
}
sub getDisponible{
    my ($self) = shift;
    return $self->disponible;
}
sub setDisponible{
    my ($self) = shift;
    my ($disponible) = @_;
    $self->disponible($disponible);
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
sub getEnableNivel3{
    my ($self) = shift;
    return $self->enable_nivel3;
}
sub setEnableNivel3{
    my ($self) = shift;
    my ($enable_nivel3) = @_;
    $self->enable_nivel3($enable_nivel3);
}
=item
    Habilita o no, el tipo de documento desde el alta de registros
=cut
sub getEnableFromNewRegister{
    my ($self) = shift;
    return $self->enable_from_new_register;
}
sub setEnableFromNewRegister{
    my ($self) = shift;
    my ($enable) = @_;
    $self->enable_from_new_register($enable);
}
sub nextMember{
    return(C4::Modelo::PrefUnidadInformacion->new());
}
=item
    Modifica el nombre y el ripo de doc
=cut
sub modTipoDocumento{
    my ($self)          = shift;
    my ($params)  = @_;
    $self->nombre($params->{'nombre'});
    $self->save();
}
sub obtenerValoresCampo {
    my ($self)          = shift;
    my ($campo,$orden)  = @_;
    my @array_valores;
    my @fields  = ($campo, $orden);
    my $v       = $self->validate_fields(\@fields);
    if($v){
	
        my $ref_valores = C4::Modelo::CatRefTipoNivel3::Manager->get_cat_ref_tipo_nivel3
                  ( select   => ['id_tipo_doc' , $campo],
                              sort_by => ($orden) );
        for(my $i=0; $i<scalar(@$ref_valores); $i++ ){
            my $valor;
            $valor->{"clave"}   = $ref_valores->[$i]->getId_tipo_doc;
            $valor->{"valor"}   = $ref_valores->[$i]->getCampo($campo);
            push (@array_valores, $valor);
        }
    }
	
    return (scalar(@array_valores), \@array_valores);
}
sub obtenerValorCampo {
	my ($self)=shift;
    my ($campo,$id)=@_;
    my $ref_valores = C4::Modelo::CatRefTipoNivel3::Manager->get_cat_ref_tipo_nivel3
						( select   => [$campo],
						  query =>[ id_tipo_doc => { eq => $id} ]);
    	
  if(scalar(@$ref_valores) > 0){
    return ($ref_valores->[0]->getCampo($campo));
  }else{
    #no se pudo recuperar el objeto por el id pasado por parametro
    return undef;
  }
}
sub enableNivel3 {
    my ($self) = shift;
    return $self->enable_nivel3;
}
sub getCampo{
    my ($self) = shift;
	my ($campo)=@_;
    
	if ($campo eq "id_tipo_doc") {return $self->getId_tipo_doc;}
	if ($campo eq "nombre") {return $self->getNombre;}
	return (0);
}
sub getAll{
    my ($self) = shift;
    my ($limit,$offset,$matchig_or_not,$filtro)=@_;
    $matchig_or_not = $matchig_or_not || 0;
    my @filtros;
    if ($filtro){
        my @filtros_or;
        push(@filtros_or, (nombre => {like => '%'.$filtro.'%'}) );
        push(@filtros, (or => \@filtros_or) );
    }
    my $ref_valores;
    if ($matchig_or_not){ #ESTOY BUSCANDO SIMILARES, POR LO TANTO NO TENGO QUE LIMITAR PARA PERDER RESULTADOS
        push(@filtros, ($self->getPk => {ne => $self->getPkValue}) );
        $ref_valores = C4::Modelo::CatRefTipoNivel3::Manager->get_cat_ref_tipo_nivel3(query => \@filtros,);
    }else{
        $ref_valores = C4::Modelo::CatRefTipoNivel3::Manager->get_cat_ref_tipo_nivel3(query => \@filtros,
                                                                    limit => $limit, 
                                                                    offset => $offset, 
                                                                    sort_by => ['nombre'] 
                                                                   );
    }
    my $ref_cant = C4::Modelo::CatRefTipoNivel3::Manager->get_cat_ref_tipo_nivel3_count(query => \@filtros,);
    return($ref_cant,$ref_valores);
}
1;
