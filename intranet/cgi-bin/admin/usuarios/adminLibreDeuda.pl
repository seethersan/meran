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
use CGI;
use C4::AR::Auth;
use C4::AR::Utilidades;
my $input = new CGI;
my ($template, $session, $t_params) = get_template_and_user({
                        template_name => "admin/usuarios/adminLibreDeuda.tmpl",
                        query => $input,
                        type => "intranet",
                        authnotrequired => 0,
                        flagsrequired => {  ui => 'ANY', 
                                            tipo_documento => 'ANY', 
                                            accion => 'CONSULTA', 
                                            entorno => 'undefined'},
                        debug => 1,
			    });
if ($input->param('newflags')) {
    	my $flags="";
	if($input->param('chk0')){
		$flags="11111";
	}
	else{
    		for(my $i=1;$i<6;$i++) {
    			my $flag=0;
    			if ($input->param('chk'.$i) == 1){
    				$flag='1';
			    }else{
                    $flag='0';
                }
	    	    $flags=$flags.$flag;
    		}
	}
	C4::AR::Utilidades::cambiarLibreDeuda($flags);
    $t_params->{'mensaje'}= C4::AR::Filtros::i18n("La configuraci&oacute;n de la administraci&oacute;n se ha modificado.");
    $t_params->{'mensaje_class'}= "alert-success";
}
my $libreD=C4::AR::Preferencias::getValorPreferencia("libreDeuda");
$t_params->{'libreD'}= $libreD;
C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
