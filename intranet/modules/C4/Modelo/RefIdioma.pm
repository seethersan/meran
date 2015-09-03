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
# along with Meran.  If not, see <http://www.gnu.org/licenses/>.package C4::Modelo::RefIdioma;
use strict;
use base qw(C4::Modelo::DB::Object::AutoBase2);
__PACKAGE__->meta->setup(
    table   => 'ref_idioma',
    columns => [
        id          => { type => 'serial', overflow => 'truncate', not_null => 1 },
        idLanguage  => { type => 'character', overflow => 'truncate',length => 2 ,not_null => 1 },
        marc_code   => { type => 'character', overflow => 'truncate',length => 3 },
        description => { type => 'varchar', overflow => 'truncate', length => 30, not_null => 1 },
    ],
    primary_key_columns => [ 'id' ],
    unique_key => [ 'idLanguage' ],
);
use C4::Modelo::RefIdioma::Manager;
use C4::Modelo::RefPais;
use Text::LevenshteinXS;
sub toString{
	my ($self) = shift;
    return ($self->getDescription);
}    
sub get_key_value{
    my ($self) = shift;
    
    return ($self->getIdLanguage);
}
sub getObjeto{
	my ($self) = shift;
	my ($id) = @_;
 	my $objecto= C4::Modelo::RefIdioma->new(idLanguage => $id);
	$objecto->load();
	return $objecto;
}
sub getId{
    my ($self) = shift;
    return ($self->id);
} 
   
sub getIdLanguage{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->idLanguage));
}
    
sub setIdLanguage{
    my ($self) = shift;
    my ($idLanguage) = @_;
    $self->idLanguage($idLanguage);
}
sub getMarcCode{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->marc_code));
}
sub setMarcCode{
    my ($self) = shift;
    my ($marc_code) = @_;
    $self->marc_code($marc_code);
}
sub getDescription{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->description));
}
sub setDescription{
    my ($self) = shift;
    my ($description) = @_;
    $self->description($description);
}
sub obtenerValoresCampo {
    my ($self)              = shift;
    my ($campo,$orden)      = @_;
    my @array_valores;
    my @fields  = ($campo, $orden);
    my $v       = $self->validate_fields(\@fields);
    if($v){
        my $ref_valores = C4::Modelo::RefIdioma::Manager->get_ref_idioma
                            ( select   => ['*'],
                              sort_by => ($orden) );
        for(my $i=0; $i<scalar(@$ref_valores); $i++ ){
            my $valor;
            $valor->{"clave"} = $ref_valores->[$i]->getIdLanguage;
            $valor->{"valor"} = $ref_valores->[$i]->getCampo($campo);
            push (@array_valores, $valor);
        }
    }
	
    return (scalar(@array_valores), \@array_valores);
}
sub obtenerValorCampo {
	my ($self)=shift;
   	my ($campo,$id)=@_;
 	my $ref_valores = C4::Modelo::RefIdioma::Manager->get_ref_idioma
						( select   => [$campo],
 						  query =>[ idLanguage => { eq => $id} ]);
    	
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
    
 	if ($campo eq "idLanguage") {return $self->getIdLanguage;}
	if ($campo eq "description") {return $self->getDescription;}
	if ($campo eq "marc_code") {return $self->getMarcCode;}
    
	return (0);
}
sub nextMember{
    return(C4::Modelo::RefPais->new());
}
=head2
    sub getIdiomaById
=cut
sub getIdiomaById{
    my ($self) = shift;
    my ($idioma) = @_;
    my @filtros;
    my @filtros_or;
    push(@filtros_or, (idLanguage => {eq => $idioma}) );
    push(@filtros_or, (marc_code => {eq => $idioma}) );
    push(@filtros, (or => \@filtros_or) );
    my $idiomas_array_ref = C4::Modelo::RefIdioma::Manager->get_ref_idioma(
        query   => \@filtros,
        select  => ['*'],
        sort_by => 'description ASC',
        limit   => 1,
        offset  => 0,
    );
    return (scalar(@$idiomas_array_ref), $idiomas_array_ref);
}
sub getIdiomaByName{
    my ($self) = shift;
    my ($idioma) = @_;
    my @filtros;
    push(@filtros, (description => {eq => $idioma}) );
    my $idiomas_array_ref = C4::Modelo::RefIdioma::Manager->get_ref_idioma(
        query   => \@filtros,
        select  => ['*'],
        sort_by => 'description ASC',
        limit   => 1,
        offset  => 0,
    );
    return (scalar(@$idiomas_array_ref), $idiomas_array_ref);
}
sub getAll{
    my ($self) = shift;
    my ($limit,$offset,$matchig_or_not,$filtro)=@_;
    $matchig_or_not = $matchig_or_not || 0;
    my @filtros;
    if ($filtro){
        my @filtros_or;
        push(@filtros_or, (idLanguage => {eq => $filtro }) );
        push(@filtros_or, (description => {like => '%'.$filtro.'%'}) );
        push(@filtros_or, (marc_code => {eq => $filtro }) );
        push(@filtros, (or => \@filtros_or) );
    }
    my $ref_valores;
    if ($matchig_or_not){ #ESTOY BUSCANDO SIMILARES, POR LO TANTO NO TENGO QUE LIMITAR PARA PERDER RESULTADOS
        push(@filtros, ($self->getPk => {ne => $self->getPkValue}) );
        $ref_valores = C4::Modelo::RefIdioma::Manager->get_ref_idioma(query => \@filtros,);
    }else{
        $ref_valores = C4::Modelo::RefIdioma::Manager->get_ref_idioma(query => \@filtros,
                                                                    limit => $limit, 
                                                                    offset => $offset, 
                                                                    sort_by => ['description'] 
                                                                   );
    }
    my $ref_cant = C4::Modelo::RefIdioma::Manager->get_ref_idioma_count(query => \@filtros,);
    my $self_description = $self->getDescription;
    my $match = 0;
    if ($matchig_or_not){
        my @matched_array;
        foreach my $each (@$ref_valores){
          $match = ((distance($self_description,$each->getDescription)<=1));
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
