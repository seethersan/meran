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
# along with Meran.  If not, see <http://www.gnu.org/licenses/>.package C4::Modelo::PrefValorAutorizado;
use strict;
use base qw(C4::Modelo::DB::Object::AutoBase2);
__PACKAGE__->meta->setup(
    table   => 'pref_valor_autorizado',
    columns => [
        id               => { type => 'serial', overflow => 'truncate', not_null => 1 },
        category         => { type => 'character', overflow => 'truncate', default => '', length => 40, not_null => 1 },
        authorised_value => { type => 'character', overflow => 'truncate', default => '', length => 80, not_null => 1 },
        lib              => { type => 'character', overflow => 'truncate', length => 80 },
    ],
    primary_key_columns => [ 'id' ],
);
use C4::Modelo::RefIdioma::Manager;
use Text::LevenshteinXS;
sub lastTable{
    return(1);
}
sub getId{
    my ($self) = shift;
    return ($self->id);
}
sub getCategory{
    my ($self) = shift;
    return ($self->category);
}
sub setCategory{
    my ($self) = shift;
    my ($category) = @_;
    $self->category($category);
}
sub getAuthorisedValue{
    my ($self) = shift;
    return ($self->authorised_value);
}
sub setAuthorisedValue{
    my ($self) = shift;
    my ($authorised_value) = @_;
    $self->authorised_value($authorised_value);
}
sub getLib{
    my ($self) = shift;
    return ($self->lib);
}
sub setLib{
    my ($self) = shift;
    my ($lib) = @_;
    $self->lib($lib);
}
sub agregar{
    my ($self)=shift;
    my ($data_hash)=@_;
    #Asignando data...
    $self->setCategory($data_hash->{'category'});
    $self->setAuthorisedValue($data_hash->{'authorised_value'});
    $self->setLib($data_hash->{'lib'});
    $self->save();
}
sub getAll{
    my ($self) = shift;
    my ($limit,$offset,$matchig_or_not,$filtro)=@_;
    $matchig_or_not = $matchig_or_not || 0;
    my @filtros;
    if ($filtro){
        my @filtros_or;
        push(@filtros_or, (category => {like => '%'.$filtro.'%'}) );
        push(@filtros, (or => \@filtros_or) );
    }
    my $ref_valores;
    if ($matchig_or_not){ #ESTOY BUSCANDO SIMILARES, POR LO TANTO NO TENGO QUE LIMITAR PARA PERDER RESULTADOS
        push(@filtros, ($self->getPk => {ne => $self->getPkValue}) );
        $ref_valores = C4::Modelo::PrefValorAutorizado::Manager->get_pref_valor_autorizado(query => \@filtros,);
    }else{
        $ref_valores = C4::Modelo::PrefValorAutorizado::Manager->get_pref_valor_autorizado(query => \@filtros,
                                                                    limit => $limit, 
                                                                    offset => $offset, 
                                                                    sort_by => ['category'] 
                                                                   );
    }
    my $ref_cant = C4::Modelo::PrefValorAutorizado::Manager->get_pref_valor_autorizado_count(query => \@filtros,);
    my $self_category = $self->getCategory;
    my $match = 0;
    if ($matchig_or_not){
        my @matched_array;
        foreach my $each (@$ref_valores){
          $match = ((distance($self_category,$each->getCategory)<=1));
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
