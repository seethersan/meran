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
# along with Meran.  If not, see <http://www.gnu.org/licenses/>.package C4::Modelo::PrefInformacionReferencia;
use strict;
use base qw(C4::Modelo::DB::Object::AutoBase2);
__PACKAGE__->meta->setup(
    table   => 'pref_informacion_referencia',
    columns => [
        idinforef  => { type => 'serial', overflow => 'truncate', not_null => 1 },
        idestcat   => { type => 'integer', overflow => 'truncate', not_null => 1 },
        referencia => { type => 'varchar', overflow => 'truncate', length => 255, not_null => 1 },
        orden      => { type => 'varchar', overflow => 'truncate', length => 255, not_null => 1 },
        campos     => { type => 'varchar', overflow => 'truncate', length => 255, not_null => 1 },
        separador  => { type => 'varchar', overflow => 'truncate', length => 3 },
    ],
    primary_key_columns => [ 'idinforef' ],
    
     relationships =>
    [
        tipoItem => 
        {
            class       => 'C4::Modelo::CatEstructuraCatalogacion',
            key_columns => { idinforef => 'idestcat' },
            type        => 'one to one',
        },
    ],
);
use C4::Modelo::CatAutor;
sub load{
    my $self = $_[0]; # Copy, not shift
    
    my $error = 1;
    eval {
    
         unless( $self->SUPER::load(speculative => 1) ){
                 C4::AR::Debug::debug("PrefInformacionReferencia =>  dentro del unless, no existe el objeto SUPER load");
                $error = 0;
         }
        C4::AR::Debug::debug("PrefInformacionReferencia =>  SUPER load");
        return $self->SUPER::load(@_);
    };
    if($@){
        C4::AR::Debug::debug("PrefInformacionReferencia =>  no existe el objeto");
        $error = undef;
    }
    return $error;
}
sub agregar{
    my ($self)=shift;
    my ($data_hash)=@_;
    $self->setIdEstCat($data_hash->{'id_est_cat'});
    $self->setReferencia($data_hash->{'tabla'});
    $self->setOrden($data_hash->{'orden'}||'ALL');
    $self->setCampos($data_hash->{'campos'});
    $self->setSeparador($data_hash->{'separador'});
    $self->save();
}
sub modificar{
    my ($self)      = shift;
    my ($data_hash) = @_;
    $self->setIdEstCat($data_hash->{'id_est_cat'});
    $self->setReferencia($data_hash->{'tabla'});
    $self->setOrden($data_hash->{'orden'}||'ALL');
    $self->setCampos($data_hash->{'campos'});
    $self->setSeparador($data_hash->{'separador'});
    $self->save();
}
sub createFromAlias{
    my ($self)      = shift;
    my $classAlias  = shift;
    my $autorTemp   = C4::Modelo::CatAutor->new();
    return ($autorTemp->createFromAlias($classAlias));
}
sub getIdInfoRef{
    my ($self) = shift;
    return ($self->idinforef);
}
sub getIdEstCat{
    my ($self) = shift;
    return ($self->idestcat);
}
sub setIdEstCat{
    my ($self) = shift;
    my ($idestcat) = @_;
    $self->idestcat($idestcat);
}
sub getReferencia{
    my ($self) = shift;
    return ($self->referencia);
}
sub setReferencia{
    my ($self) = shift;
    my ($referencia) = @_;
    $self->referencia($referencia);
}
sub getOrden{
    my ($self) = shift;
    return ($self->orden);
}
sub setOrden{
    my ($self) = shift;
    my ($orden) = @_;
    $self->orden($orden);
}
sub getCampos{
    my ($self) = shift;
    return ($self->campos);
}
sub setCampos{
    my ($self) = shift;
    my ($campos) = @_;
    $self->campos($campos);
}
sub getSeparador{
    my ($self) = shift;
    return ($self->separador);
}
sub setSeparador{
    my ($self) = shift;
    my ($separador) = @_;
    $self->separador($separador);
}
1;
