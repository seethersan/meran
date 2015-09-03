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
# along with Meran.  If not, see <http://www.gnu.org/licenses/>.package C4::Modelo::UsrEstado;
use base qw(C4::Modelo::DB::Object::AutoBase2);
__PACKAGE__->meta->setup
  (
    table   => 'usr_estado',
    columns => [
        id_estado        => { type => 'serial', overflow => 'truncate', not_null => 1, length => 11 },
        nombre           => { type => 'varchar', overflow => 'truncate', length => 255, not_null => 1 },
        fuente           => { type => 'varchar', overflow => 'truncate', length => 255, not_null => 1 },
    ],
    primary_key_columns => [ 'id_estado' ],
);
sub conformarUsrRegularidad{
    my ($self)=shift;
    my ($categorias_array_ref)  = C4::AR::Referencias::obtenerCategoriaDeSocio();
    foreach my $categoria (@$categorias_array_ref) {
        my $regularidad = C4::Modelo::UsrRegularidad->new();
        my %data_hash ={};
        $data_hash{'usr_estado_id'} = $self->getId_estado;
        $data_hash{'usr_ref_categoria_id'} = $categoria->getId();
        $data_hash{'Condicion'} = 0;
        $regularidad->agregar(\%data_hash);
    }    
	
}
sub agregar{
    my ($self)=shift;
    my ($data_hash)=@_;
    #Asignando data...
    $self->setFuente($data_hash->{'fuente'});
    $self->setNombre($data_hash->{'categoria'});
    $self->save();
    $self->conformarUsrRegularidad();
}
sub getId_estado{
    my ($self) = shift;
    return ($self->id_estado);
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
sub getFuente{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->fuente));
}
sub setFuente{
    my ($self) = shift;
    my ($fuente) = @_;
    $self->fuente($fuente);
}
sub obtenerValoresCampo {
    my ($self)=shift;
    my ($campo,$orden)=@_;
    my $ref_valores = C4::Modelo::UsrEstado::Manager->get_usr_estado
                        ( select   => ['id_estado', $campo],
                          sort_by => ($orden) );
    my @array_valores;
    for(my $i=0; $i<scalar(@$ref_valores); $i++ ){
        my $valor;
        $valor->{"clave"}=$ref_valores->[$i]->getId_estado;
        $valor->{"valor"}=$ref_valores->[$i]->getCampo($campo);
        push (@array_valores, $valor);
    }
    
    return (scalar(@array_valores), \@array_valores);
}
sub obtenerValorCampo {
    my ($self)=shift;
    my ($campo,$id)=@_;
    my $ref_valores = C4::Modelo::UsrEstado::Manager->get_usr_estado
                        ( select   => [$campo],
                          query =>[ id_estado => { eq => $id} ]);
        
  if(scalar(@$ref_valores) > 0){
    return ($ref_valores->[0]->getCampo($campo));
  }else{
    #no se pudo recuperar el objeto por el id pasado por parametro
    return undef;
  }
}
sub getAll{
    my ($self) = shift;
    my ($limit,$offset,$matchig_or_not,$filtro)=@_;
    $matchig_or_not = $matchig_or_not || 0;
    my @filtros;
    if ($filtro){
        my @filtros_or;
        if ($matchig_or_not){
            push(@filtros_or, (nombre => {like => '%'.$filtro.'%'}) );
            push(@filtros_or, (fuente => {like => '%'.$filtro.'%'}) );
        }else{
            push(@filtros_or, (nombre => {eq => $filtro}) );
            push(@filtros_or, (fuente => {eq => $filtro}) );
        }
        push(@filtros, (or => \@filtros_or) );
    }
    my $ref_valores;
    if ($matchig_or_not){ #ESTOY BUSCANDO SIMILARES, POR LO TANTO NO TENGO QUE LIMITAR PARA PERDER RESULTADOS
        push(@filtros, ($self->getPk => {ne => $self->getPkValue}) );
        $ref_valores = C4::Modelo::UsrEstado::Manager->get_usr_estado(query => \@filtros,);
    }else{
        $ref_valores = C4::Modelo::UsrEstado::Manager->get_usr_estado(query => \@filtros,
                                                                    limit => $limit, 
                                                                    offset => $offset, 
                                                                    sort_by => ['nombre'] 
                                                                   );
    }
    my $ref_cant = C4::Modelo::UsrEstado::Manager->get_usr_estado_count(query => \@filtros,);
    return($ref_cant,$ref_valores);
}
1;
