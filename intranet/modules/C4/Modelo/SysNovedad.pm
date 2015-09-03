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
# along with Meran.  If not, see <http://www.gnu.org/licenses/>.package C4::Modelo::SysNovedad;
use strict;
use base qw(C4::Modelo::DB::Object::AutoBase2);
__PACKAGE__->meta->setup(
    table   => 'sys_novedad',
    columns => [
        id              => { type => 'serial', overflow => 'truncate', length => 16 },
        usuario         => { type => 'varchar', overflow => 'truncate', not_null => 1, length => 16 },
        fecha           => { type => 'integer', overflow => 'truncate', not_null => 1, length => 16 },
        titulo          => { type => 'varchar', overflow => 'truncate', not_null => 1, length => 255 },
        categoria       => { type => 'varchar', overflow => 'truncate', not_null => 1, length => 255 },
        contenido       => { type => 'text', overflow => 'truncate', not_null => 1 },
        links           => { type => 'varchar', overflow => 'truncate', not_null => 0, length => 1024 },
        adjunto         => { type => 'varchar', overflow => 'truncate', not_null => 1, length => 255 },
        nombreAdjunto   => { type => 'varchar', overflow => 'truncate', not_null => 0, length => 255 },
    ],
    primary_key_columns => [ 'id' ],
);
sub agregar{
    my ($self)      = shift;
    my ($params)    = @_;    
    my $usuario     = C4::AR::Auth::getSessionNroSocio();
    $self->setTitulo($params->{'titulo'});
    $self->setContenido($params->{'contenido'});
    $self->setCategoria($params->{'categoria'});
    $self->setLinks($params->{'links'});
    $self->setNombreAdjunto($params->{'nombreAdjunto'});
    $self->setUsuario($usuario);
    return($self->save());
}
sub getId{
    my ($self) = shift;
    return ($self->id);
}
sub getUsuario{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->usuario));
}
sub setUsuario{
    my ($self) = shift;
    my ($usuario) = @_;
    $self->usuario($usuario);
}
sub getLinks{
    my ($self) = shift;
    return ($self->links);
}
sub setLinks{
    my ($self) = shift;
    my ($links) = @_;
    $self->links($links);
}
sub getNombreAdjunto{
    my ($self) = shift;
    return ($self->nombreAdjunto);
}
sub setNombreAdjunto{
    my ($self) = shift;
    my ($nombreAdjunto) = @_;
    $self->nombreAdjunto($nombreAdjunto);
}
sub getAdjunto{
    my ($self) = shift;
    return ($self->adjunto);
}
sub setAdjunto{
    my ($self) = shift;
    my ($adjunto) = @_;
    $self->adjunto($adjunto);
}
sub getFechaLegible{
    my ($self) = shift;
    return ($self->fecha);
}
sub setFecha{
    my ($self) = shift;
    my ($fecha) = @_;
    $self->fecha($fecha);
}
sub getTitulo{
    my ($self) = shift;
    return ($self->titulo);
}
sub setTitulo{
    my ($self) = shift;
    my ($titulo) = @_;
    $self->titulo($titulo);
}
sub getCategoria{
    my ($self) = shift;
    return ($self->categoria);
}
sub setCategoria{
    my ($self) = shift;
    my ($string) = @_;
    $self->categoria($string);
}
sub getContenido{
    my ($self) = shift;
    return ($self->contenido);
}
sub setContenido{
    my ($self) = shift;
    my ($string) = @_;
    $self->contenido($string);
}
sub getResumen{
    my ($self) = shift;
    my $string_sub = substr ($self->contenido,0,150);
    return ($string_sub."...");
}
sub getFechaLegible{
    my ($self) = shift;
    my $dateformat = C4::Date::get_date_format();
    
    return (C4::Date::format_date($self->fecha,$dateformat));
}
1;
