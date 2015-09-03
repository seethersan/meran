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
# along with Meran.  If not, see <http://www.gnu.org/licenses/>.package C4::Modelo::UsrLoginAttempts;
use strict;
use base qw(C4::Modelo::DB::Object::AutoBase2);
__PACKAGE__->meta->setup(
    table   => 'usr_login_attempts',
    columns => [
        nro_socio    => { type => 'varchar', overflow => 'truncate', length => 16, not_null => 1, overflow => 'truncate' },
        attempts     => { type => 'integer', overflow => 'truncate', length => 32, default => 0, overflow => 'truncate' },
    ],
    primary_key_columns => [ 'nro_socio' ],
);
sub increase{
	my ($self) = shift;
	
	my $attempts = $self->attempts;
	$attempts++;
	$self->attempts($attempts);
	
	$self->save();
}
sub reset{
    my ($self) = shift;
    
    $self->attempts(0);
    
    $self->save();
}
1;