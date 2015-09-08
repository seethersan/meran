#!/usr/bin/perl
# Meran - MERAN UNLP is a ILS (Integrated Library System) wich provides Catalog,
# Circulation and User's Management. It's written in Perl, and uses Apache2
# Web-Server, MySQL database and Sphinx 2 indexing.
# Copyright (C) 2009-2015 Grupo de desarrollo de Meran CeSPI-UNLP
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
use CGI;
use C4::AR::ImportacionIsoMARC;
my $input = new CGI;
my $theme = $input->param('theme') || "default";
my ($template, $nro_socio, $cookie)
    = get_template_and_user({template_name => "importacionMarc.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {     ui => 'ANY', 
                                        tipo_documento => 'ANY', 
                                        accion => 'CONSULTA', 
                                        entorno => 'undefined'},
			     debug => 1,
			     });
my $id =$input->param('id');
my $campo5 =$input->param('campo5');
my $campo9 =$input->param('campo9');
my $ui =$input->param('branch');
my $campoIso=$input->param('campoIso');
my $subCampoIso=$input->param('subCampoIso');
my $descripcion=$input->param('descripcion');
my $MARCsubfield=$input->param('listaSecundaria');
my $MARCfield=$input->param('fMarc');
my $orden=$input->param('orden');
my $separador=$input->param('separador');
if ($id){update($campo5,$campo9,$campoIso, $subCampoIso,$descripcion,$ui,$orden,$separador,$MARCfield,$MARCsubfield,$id);}
	else{insertNuevo($campo5,$campo9,$campoIso, $subCampoIso,$descripcion,$ui,$orden,$separador,$MARCfield,$MARCsubfield);}
$template->param(
                            ok          => \'ok',
			    descripcionI => $descripcion,
                	    subcampoiso => $subCampoIso,
			    campoiso    => $campoIso,
			    MARCfield  => $MARCfield,
			    MARCsubfield  => $MARCsubfield,
		 );
print $input->redirect('importacionMarc.pl?campoiso='.$campoIso.'&subcampoiso='.$subCampoIso.'&ok=1&code='.$campoIso);
