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
# along with Meran.  If not, see <http://www.gnu.org/licenses/>.package C4::Modelo::EDocument;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);
=item

DROP TABLE IF EXISTS `e_document`;
CREATE TABLE IF NOT EXISTS `e_document` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `filename` varchar(255) CHARACTER SET utf8 NOT NULL,
  `title` varchar(255) CHARACTER SET utf8 NOT NULL,
  `id2` int(11) NOT NULL,
  `file_type` varchar(10) CHARACTER SET utf8 NOT NULL DEFAULT 'pdf',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=UTF8 AUTO_INCREMENT=0 ;

=cut

__PACKAGE__->meta->setup(
    table   => 'e_document',

    columns => [
        id              => { type => 'serial', overflow => 'truncate', length => 11, },
        filename        => { type => 'varchar', overflow => 'truncate', length => 255, not_null => 1 },
        title           => { type => 'varchar', overflow => 'truncate', length => 255, not_null => 1 },
        id2             => { type => 'int', overflow => 'truncate', length => 11, not_null => 1 },
        file_type       => { type => 'varchar', overflow => 'truncate', length => 64, not_null => 1, default=>"pdf" },
    ],

    primary_key_columns => [ 'id' ],
);


sub agregar(){
	my ($self) = shift;
	my ($id2) = shift;
    my ($filename) = shift;
    my ($type) = shift;
    my ($name) = shift;
	
	$self->setId2($id2);
	$self->setFilename($filename);
    $self->setFileType($type);
    $self->setTitle($name);
    
    $self->save();
	
}

sub getIconType(){
    my ($self) = shift;

    my $file_type = $self->getFileType;
    
    my @nombreYExtension = split('\/',$file_type);
    
    return (@nombreYExtension[1]);
	
}
sub getId{
    my ($self) = shift;
    return ($self->id);
}

sub getFilename{
    my ($self) = shift;
    return ($self->filename);
}

sub getTitle{
    my ($self) = shift;
    return ($self->title);
}

sub getId2{
    my ($self) = shift;
    return ($self->id2);
}

sub getFileType{
    my ($self) = shift;
    return ($self->file_type);
}




sub setFilename{
    my ($self)   = shift;
    my ($filename) = @_;
    $self->filename($filename);
}

sub setTitle{
    my ($self)   = shift;
    my ($title) = @_;
    $self->title($title);
}

sub setId2{
    my ($self)   = shift;
    my ($id2) = @_;
    $self->id2($id2);
}

sub setFileType{
    my ($self)   = shift;
    my ($file_type) = @_;
    $self->file_type($file_type);
}
