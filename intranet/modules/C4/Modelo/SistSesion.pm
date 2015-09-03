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
# along with Meran.  If not, see <http://www.gnu.org/licenses/>.package C4::Modelo::SistSesion;
use strict;
use base qw(C4::Modelo::DB::Object::AutoBaseSession);
__PACKAGE__->meta->setup(
    table   => 'sist_sesion',
    columns => [
        sessionID => { type => 'varchar', overflow => 'truncate', length => 255, not_null => 1 },
        userid    => { type => 'varchar', overflow => 'truncate', length => 255 },
        nroRandom    => { type => 'varchar', overflow => 'truncate', length => 255 },
		token    => { type => 'varchar', overflow => 'truncate', length => 255 },
        ip        => { type => 'varchar', overflow => 'truncate', length => 16 },
        lasttime  => { type => 'integer', overflow => 'truncate', length => 11 },
        flag  => { type => 'varchar', overflow => 'truncate', length => 255 },
    ],
    primary_key_columns => [ 'sessionID' ],
);
sub getActiveSession{
    my $self = shift;
    my ($sessionID) = @_;
    my @filtros;
    push (@filtros, ( sessionID => {eq => $sessionID} ));
    my $session = C4::Modelo::SistSesion::Manager->get_sist_sesion( query => \@filtros,);
  
    if (scalar(@$session)){
        return ($session->[0]);
    }else{
      return (0);
    }
}
=item
Se redefine el metodo delte para poder loguear
=cut
sub delete{
    my $self = $_[0]; # Copy, not shift
    my $context = new C4::Context;
    if($context->config('debug')){
        foreach my $param (@_){
        }
    }
    
    #se llama a delete
    return $self->SUPER::delete(@_);
}
sub setSessionId{
    my ($self) = shift;
    my ($sessionID) = @_;
    $self->sessionID($sessionID);
}
sub getSessionId{
    my ($self) = shift;
    return ($self->sessionID);
}
sub getUserid{
    my ($self) = shift;
    return ($self->userid);
}
sub setUserid{
    my ($self) = shift;
    my ($userid) = @_;
    $self->userid($userid);
}
sub getFlag{
    my ($self) = shift;
    if(!defined $self->flag){
        return "NO TIENE";
    }else{
        return ($self->flag);
    }
}
sub setFlag{
    my ($self) = shift;
    return ($self->flag);
}
sub getNroRandom{
    my ($self) = shift;
    return ($self->nroRandom);
}
sub setNroRandom{
    my ($self) = shift;
    my ($nroRandom) = @_;
    $self->nroRandom($nroRandom);
}
sub getToken{
    my ($self) = shift;
    return ($self->token);
}
sub setToken{
    my ($self) = shift;
    my ($token) = @_;
    $self->token($token);
}
sub getIp{
    my ($self) = shift;
    return ($self->ip);
}
sub setIp{
    my ($self) = shift;
    my ($ip) = @_;
    $self->ip($ip);
}
sub getLasttime{
    my ($self) = shift;
    return ($self->lasttime);
}
sub setLasttime{
    my ($self) = shift;
    my ($lasttime) = @_;    
    
    $self->lasttime($lasttime);
}
1;
