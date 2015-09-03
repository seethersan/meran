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
# along with Meran.  If not, see <http://www.gnu.org/licenses/>.package C4::Modelo::PortadaOpac;
use strict;
use base qw(C4::Modelo::DB::Object::AutoBase2);
__PACKAGE__->meta->setup(
    table   => 'portada_opac',
    columns => [
        id             => { type => 'serial', overflow => 'truncate', not_null => 1 },
        image_path     => { type => 'varchar', overflow => 'truncate', length => 255, not_null => 1 },
        footer         => { type => 'text', overflow => 'truncate', not_null => 0 },
        footer_title   => { type => 'varchar', overflow => 'truncate', length => 64, not_null => 1 },
        orden          => { type => 'integer', length => 10, default => 1, not_null => 1 },
    ],
    primary_key_columns => [ 'id' ],
);
sub agregar{
    my ($self) = shift;
    my ($data_hash) = @_;
    $self->setImagePath($data_hash->{'image_path'});
    $self->setFooter($data_hash->{'footer'});
    $self->setOrden($data_hash->{'orden'});
    $self->save();
}
sub getImagePath{
    my ($self) = shift;
    return ($self->image_path);
}
sub setImagePath{
    my ($self) = shift;
    my ($path) = @_;
    $self->image_path($path);
}
sub getFooter{
    my ($self) = shift;
    return ($self->footer);
}
sub setFooter{
    my ($self) = shift;
    my ($footer) = @_;
    $self->footer($footer);
}
sub getFooterTitle{
    my ($self) = shift;
    return ($self->footer_title);
}
sub setFooterTitle{
    my ($self) = shift;
    my ($footer_title) = @_;
    $self->footer_title($footer_title);
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
1;
