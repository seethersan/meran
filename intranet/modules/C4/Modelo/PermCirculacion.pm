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
# along with Meran.  If not, see <http://www.gnu.org/licenses/>.package C4::Modelo::PermCirculacion;
use strict;
use base qw(C4::Modelo::DB::Object::AutoBase2);
__PACKAGE__->meta->setup(
    table   => 'perm_circulacion',
    columns => [
        nro_socio => { type => 'varchar', overflow => 'truncate', length => 16, not_null => },
        ui  => { type => 'varchar', overflow => 'truncate', length => 4, not_null => 1 },
        tipo_documento => { type => 'varchar', overflow => 'truncate', length => 4, not_null => 1 }, 
        prestamos => { type => 'varchar', overflow => 'truncate', length => 8, not_null => 1 },
        circ_opac => { type => 'varchar', overflow => 'truncate', length => 8, not_null => 1 },
        circ_prestar => { type => 'varchar', overflow => 'truncate', length => 8, not_null => 1 },
        circ_renovar => { type => 'varchar', overflow => 'truncate', length => 8, not_null => 1 },
        circ_devolver => { type => 'varchar', overflow => 'truncate', length => 8, not_null => 1 },
        circ_sanciones => { type => 'varchar', overflow => 'truncate', length => 8, not_null => 1 },
    ],
    primary_key_columns => [ 'nro_socio','ui','tipo_documento' ],
);
sub agregar{
    my ($self) = shift;
    my ($permisos_hash) = @_;
    $self->setNro_socio($permisos_hash->{'nro_socio'});
    $self->setUI($permisos_hash->{'id_ui'});
    $self->setTipo_documento($permisos_hash->{'tipo_documento'});
    $self->setPrestamos($permisos_hash->{'prestamos'});
    $self->setCirc_opac($permisos_hash->{'circ_opac'});
    $self->setCirc_prestar($permisos_hash->{'circ_prestar'});
    $self->setCirc_renovar($permisos_hash->{'circ_renovar'});
    $self->setCirc_devolver($permisos_hash->{'circ_devolver'});
    $self->setCirc_sanciones($permisos_hash->{'circ_sanciones'});
    $self->save();
}
sub setAll{
    my ($self) = shift;
    my ($permisosByte) = @_;
    
    $self->setPrestamos($permisosByte);
    $self->setCirc_opac($permisosByte);
    $self->setCirc_prestar($permisosByte);
    $self->setCirc_renovar($permisosByte);
    $self->setCirc_devolver($permisosByte);
    $self->setCirc_sanciones($permisosByte);
}
sub modificar{
    my ($self) = shift;
    my ($permisos_hash) = @_;
    $self->save();
}
sub getNro_socio{
    my ($self) = shift;
    return ($self->nro_socio);
}
sub setNro_socio{
    my ($self) = shift;
    my ($nro_socio) = @_;
    
    $self->nro_socio($nro_socio);
}
sub getCirc_opac{
    my ($self) = shift;
    return ($self->circ_opac);
}
sub setCirc_opac{
    my ($self) = shift;
    my ($permisos) = @_;
    $self->circ_opac($permisos);
}
sub getCirc_prestar{
    my ($self) = shift;
    return ($self->circ_prestar);
}
sub setCirc_prestar{
    my ($self) = shift;
    my ($permisos) = @_;
    $self->circ_prestar($permisos);
}
sub getCirc_renovar{
    my ($self) = shift;
    return ($self->circ_renovar);
}
sub setCirc_renovar{
    my ($self) = shift;
    my ($permisos) = @_;
    $self->circ_renovar($permisos);
}
sub getCirc_devolver{
    my ($self) = shift;
    return ($self->circ_devolver);
}
sub setCirc_devolver{
    my ($self) = shift;
    my ($permisos) = @_;
    $self->circ_devolver($permisos);
}
sub getCirc_sanciones{
    my ($self) = shift;
    return ($self->circ_sanciones);
}
sub setCirc_sanciones{
    my ($self) = shift;
    my ($permisos) = @_;
    $self->circ_sanciones($permisos);
}
sub getUI{
    my ($self) = shift;
    
    return ($self->ui);
}
sub setUI{
    my ($self) = shift;
    my ($ui) = @_;
    
    $self->ui($ui);
}
sub getTipo_documento{
    my ($self) = shift;
    
    return ($self->tipo_documento);
}
sub setTipo_documento{
    my ($self) = shift;
    my ($tipo_documento) = @_;
    
    $self->tipo_documento($tipo_documento);
}
sub getPrestamos{
    my ($self) = shift;
    
    return ($self->prestamos);
}
sub setPrestamos{
    my ($self) = shift;
    my ($prestamos) = @_;
    
    $self->prestamos($prestamos);
}
sub convertirEnEstudiante{
    my ($self) = shift;
    my ($socio) = @_;
    $self->setAll(C4::AR::Permisos::getConsultaByte());
    $self->setNro_socio($socio->getNro_socio);
    $self->setUI($socio->getId_ui);
    $self->setTipo_documento('ALL');
    $self->save();
}
sub convertirEnLibrarian{
    my ($self) = shift;
    my ($socio) = @_;
    $self->setAll(C4::AR::Permisos::getConsultaByte() | C4::AR::Permisos::getAltaByte() | C4::AR::Permisos::getModificacionByte() );
    $self->setNro_socio($socio->getNro_socio);
    $self->setUI($socio->getId_ui);
    $self->setTipo_documento('ALL');
    $self->save();
}
sub convertirEnSuperLibrarian{
    my ($self) = shift;
    my ($socio) = @_;
    $self->setAll(C4::AR::Permisos::getTodosByte());
    $self->setNro_socio($socio->getNro_socio);
    $self->setUI($socio->getId_ui);
    $self->setTipo_documento('ALL');
    $self->save();
}
1;
