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
# along with Meran.  If not, see <http://www.gnu.org/licenses/>.package C4::Modelo::CatAyudaMarc;
use strict;
use base qw(C4::Modelo::DB::Object::AutoBase2);
__PACKAGE__->meta->setup(
    table   => 'cat_ayuda_marc',
    columns => [
        id          => { type => 'serial', overflow => 'truncate', not_null => 1 },
        ui          => { type => 'integer', overflow => 'truncate', not_null => 1},
        campo       => { type => 'character', overflow => 'truncate', length => 3, not_null => 1 },
        subcampo    => { type => 'character', overflow => 'truncate', length => 1, not_null => 1 },
        ayuda       => { type => 'text', overflow => 'truncate', not_null => 1 },
    ],
    primary_key_columns => [ 'id' ],
     relationships =>
    [
      unidad_informacion => 
      {
        class       => 'C4::Modelo::PrefUnidadInformacion',
        key_columns => { ui => 'id' },
        type        => 'one to one',
      },
    ]
);
sub agregarAyudaMarc{
    
    my ($self)   = shift;
    my ($params) = @_;
    
    $self->setSubCampo($params->{'subcampo'});
    $self->setCampo($params->{'campo'});
    $self->setAyuda($params->{'ayuda'});
    # $self->setUI($params->{'ui'});
    my $ui = C4::Modelo::PrefUnidadInformacion->getByCode(C4::AR::Preferencias::getValorPreferencia('defaultUI'));
    $self->setUI($ui->getId);
    $self->save();
}
sub editarAyudaMarc{
    my ($self)   = shift;
    my ($params) = @_;
    
    $self->setAyuda($params->{'ayuda'});
    $self->save();
}
sub getUI{
    my ($self) = shift;
    return $self->ui;
}
sub setUI{
    my ($self)  = shift;
    my ($ui)    = @_;
    $self->ui($ui); 
}
sub getSubCampo{
    my ($self) = shift;
    return $self->subcampo;
}
sub setSubCampo{
    my ($self)      = shift;
    my ($subcampo)  = @_;
    $self->subcampo($subcampo);
}
sub getCampo{
    my ($self) = shift;
    return $self->campo;
}
sub setCampo{
    my ($self)  = shift;
    my ($campo) = @_;
    $self->campo($campo);
}
sub getAyuda{
    my ($self) = shift;
    return ($self->ayuda);
}
sub getAyudaShort{
    my ($self) = shift;
    my $subString = substr ($self->ayuda,0,70);
    return ($subString."...");
}
sub setAyuda{
    my ($self) = shift;
    my ($ayuda) = @_;
    $self->ayuda($ayuda);
}
1;