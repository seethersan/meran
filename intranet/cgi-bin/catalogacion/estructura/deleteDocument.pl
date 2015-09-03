#!/usr/bin/perl
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
# along with Meran.  If not, see <http://www.gnu.org/licenses/>.
use strict;
use C4::AR::Auth;
use C4::Output;
use CGI;
use C4::Context;
use C4::AR::UploadFile;
use JSON;
my $input = new CGI;
my ($nro_socio, $session, $flags) = checkauth( 
                                                        $input, 
                                                        0,
                                                        {   ui              => 'ANY', 
                                                            tipo_documento  => 'ANY', 
                                                            accion          => 'MODIFICACION', 
                                                            entorno         => 'usuarios'},
                                                            "intranet"
                        );  
my $params=$input->param('obj');
$params=C4::AR::Utilidades::from_json_ISO($params);
$params->{'nro_socio'} = $nro_socio;
my $msg_object = C4::AR::UploadFile::deleteDocument($input,$params);
my $infoOperacionJSON=to_json $msg_object;
C4::AR::Auth::print_header($session);
print $infoOperacionJSON;
