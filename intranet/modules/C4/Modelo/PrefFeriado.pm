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
# along with Meran.  If not, see <http://www.gnu.org/licenses/>.package C4::Modelo::PrefFeriado;
use strict;
use base qw(C4::Modelo::DB::Object::AutoBase2);
__PACKAGE__->meta->setup(
    table   => 'pref_feriado',
    columns => [
        id               => { type => 'serial', overflow => 'truncate', not_null => 1 },
        fecha            => { type => 'varchar', overflow => 'truncate', default => '0000-00-00', length => 10, not_null => 1 },
        feriado          => { type => 'varchar', overflow => 'truncate', length => 255, not_null => 0 },
    ],
    primary_key_columns => [ 'id' ],
);
sub agregar{
    my ($self) = shift;
    my ($fecha,$status,$feriado) = @_;
    $self->setFecha($fecha,$status,$feriado);
}
sub getFeriado{
    my ($self) = shift;
    return (C4::Utilidades::trim($self->feriado));
}
sub getFecha{
    my ($self) = shift;
    my $dateformat = C4::Date::get_date_format();
    return (C4::Date::format_date($self->fecha,$dateformat));
}
=item
    Devuelve la fecha en formato US, para el calendario
=cut
sub getFechaParaCalendario{
    my ($self) = shift;
    return (C4::Date::format_date($self->fecha,'us'));
}
sub getFeriado{
    my ($self) = shift;
    my $feriado = $self->feriado || C4::AR::Filtros::i18n('Sin Descripcion');
    
    return ($feriado);
}
sub setFecha{
    my ($self) = shift;
    my ($fecha,$status,$feriado) = @_;
    if ($status eq "true"){
        $self->fecha($fecha);
        $self->feriado($feriado);
        $self->save();
    }else {
        $self->delete();
    }
}
1;