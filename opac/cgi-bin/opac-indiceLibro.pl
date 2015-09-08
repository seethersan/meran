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
require Exporter;
use CGI;
use C4::AR::Auth;
use C4::Date;
use C4::Biblio;
my $input = new CGI;
my $id2=$input->param('id2');
my $id1=$input->param('id1');
my $infoIndice=$input->param('indice');
my ($template, $borrowernumber, $cookie) 
    = get_template_and_user({template_name => "opac-indiceLibro.tmpl",
			     query => $input,
			     type => "opac",
			     authnotrequired => 1,
			     flagsrequired => {     ui => 'ANY', 
                                        tipo_documento => 'ANY', 
                                        accion => 'CONSULTA', 
                                        entorno => 'undefined'},
			     });
my ($resultsdata)=&C4::AR::Nivel2::getIndice($id2);
my @autoresAdicionales=C4::AR::Nivel1::getAutoresAdicionales($id1);
my @colaboradores=C4::AR::Nivel1::getColaboradores($id1);
$template->param(
		infoIndice => $resultsdata->{'indice'},
 		id1 => $id1,
         	id2 => $id2,
		UNITITLE    => C4::AR::Nivel1::getUnititle($id1),
		AUTHOR    => \@autorPPAL,
		ADDITIONAL => \@autoresAdicionales,
	    	COLABS => \@colaboradores,
);
output_html_with_http_headers $cookie, $template->output;
