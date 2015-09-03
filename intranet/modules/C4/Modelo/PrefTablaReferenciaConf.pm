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
# along with Meran.  If not, see <http://www.gnu.org/licenses/>.package C4::Modelo::PrefTablaReferenciaConf;
use strict;
use base qw(C4::Modelo::DB::Object::AutoBase2);
__PACKAGE__->meta->setup(
    table   => 'pref_tabla_referencia_conf',
    columns => [
        id                  => { type => 'serial', overflow => 'truncate'},
        tabla               => { type => 'varchar', overflow => 'truncate', length => 255, not_null => 1 },
        campo               => { type => 'varchar', overflow => 'truncate', length => 20, not_null => 1 },
        campo_alias         => { type => 'varchar', overflow => 'truncate', length => 255, not_null => 1 },
        visible             => { type => 'integer', overflow => 'truncate', length => 11, not_null => 1},
    ],
    primary_key_columns => [ 'id' ],
);
use C4::Modelo::PrefTablaReferenciaConf::Manager;
=head1
    Obtiene toda la tabla filtrada por nombre_tabla
=cut
sub getConfTabla{
    my ($nombre_tabla) = @_;
    my $data = C4::Modelo::PrefTablaReferenciaConf::Manager->get_pref_tabla_referencia_conf(   query =>  [ 
                                                                                    tabla  => { eq => $nombre_tabla  },
                                                                                   ],
   
                                                    );
    
    if(scalar(@$data) > 0){
        return $data;
    } else {
        return 0;
    }
}
sub getConf{
    my ($self)          = shift;
    my ($tabla, $campo) = @_;
    my @filtros;
    push (@filtros, (campo => {eq => $campo}) );
    push (@filtros, (tabla => {eq => $tabla}) );
    my $configuarcion = C4::Modelo::PrefTablaReferenciaConf::Manager->get_pref_tabla_referencia_conf(  query => \@filtros,
                                                                                  );
    if(scalar(@$configuarcion) > 0){
        return $configuarcion->[0];
    } else {
        return 0;
    }
}
=item
    Idem al de arriba pero sin hacer el shift, se rompia
=cut
sub getConfig{
    my ($tabla, $campo) = @_;
    my @filtros;
    push (@filtros, (campo => {eq => $campo}) );
    push (@filtros, (tabla => {eq => $tabla}) );
    my $configuarcion = C4::Modelo::PrefTablaReferenciaConf::Manager->get_pref_tabla_referencia_conf(  query => \@filtros,
                                                                                  );
    if(scalar(@$configuarcion) > 0){
        return $configuarcion->[0];
    } else {
        return 0;
    }
}
sub cambiarVisivilidad{
    my ($tabla, $campo) = @_;
    my $conf            = getConfig($tabla, $campo);
    
    if($conf->getVisible()){
    
        $conf->setVisible(0);
    
    }else{
    
        $conf->setVisible(1);
    
    }
}
sub getVisible{
    my ($self) = shift;
    return ($self->visible);
}
sub getCampoAlias{
    my ($self) = shift;
    return ($self->campo_alias);
}
sub getCampo{
    my ($self) = shift;
    return ($self->campo);
}
sub getTabla{
    my ($self) = shift;
    return ($self->tabla);
}
sub setCampoAlias{
    my ($self)          = shift;
    my ($campo_alias)   = @_;
    
    $self->campo_alias($campo_alias);
    $self->save();
}
sub setVisible{
    my ($self)      = shift;
    my ($visible)   = @_;
    
    $self->visible($visible);
    $self->save();
}
1;
