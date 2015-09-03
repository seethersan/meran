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
use CGI;
use C4::AR::Auth;
use C4::AR::Utilidades;
use C4::AR::Estadisticas;
my $input = new CGI;
my ($template, $session, $t_params) = get_template_and_user 
				({template_name => "admin/referencies.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {     ui => 'ANY', 
                                        tipo_documento => 'ANY', 
                                        accion => 'CONSULTA', 
                                        entorno => 'undefined'},
			     debug => 1,
			     });
my $tabla=$input->param('editandotabla');
my $valores=buscarTabladeReferencia($tabla);
my $env;
my @campos=obtenerCampos($tabla);
my $ind=$input->param('editandoind');
($ind||($ind=0)); 
my $search=$input->param('description');
($search||($search='')); 
my $cant=$input->param('editandocant');
($cant||($cant=20)); 
my $orden=$input->param('editandoorden');
($orden||($orden=$valores->{'orden'})); 
my $bloqueIni= $input->param('bloqueIni');
($bloqueIni||($bloqueIni = ''));
my $bloqueFin= $input->param('bloqueFin');
($bloqueFin||($bloqueFin = ''));
my $ini;
my $pageNumber;
my $cantR=cantidadRenglones();
if (($input->param('ini') eq "")){
        $ini=0;
	$pageNumber=1;
} else {
	$ini= ($input->param('ini')-1)* $cantR;
	$pageNumber= $input->param('ini');
};
my ($total,@loop)= listadoTabla($tabla,$ini,$cantR,$valores->{'camporeferencia'},$orden,$search,$bloqueIni,$bloqueFin);
my $num= 1;
foreach my $res (@loop) {
	((($num % 2) && ($res->{'clase'} = 'par' ))|| ($res->{'clase'}='impar'));
    	$num++;
}
my @numeros=armarPaginas($total);
my $paginas = scalar(@numeros)||1;
my $pagActual = $input->param('ini')||1;
				$t_params->{'paginas'} = $paginas;
				$t_params->{'actual'}= $pagActual;
if ( $total > $cantR ){#Para ver si tengo que poner la flecha de siguiente pagina o la de anterior
        my $sig = $pagActual+1;
        if ($sig <= $paginas){
				$t_params->{'ok'} = '1';
				$t_params->{'sig'}= $sig;
        };
        if ($sig > 2 ){
                my $ant = $pagActual-1;
				$t_params->{'ok2'} = '1';
				$t_params->{'ant'}= $ant;}
}
$t_params->{'camposloop'}= \@campos;
$t_params->{'loop'}= \@loop;
$t_params->{'editandoind'} = $ind;
$t_params->{'editandocant'}= $cant;
$t_params->{'search'}= $search;
$t_params->{'editandoorden'}= $orden;
$t_params->{'editandotabla'}= $tabla;
$t_params->{'editandoidentificador'}= $valores->{'nomcamporeferencia'};
$t_params->{'editandototal'}= $total;
$t_params->{'bloqueFin'}= $bloqueFin;
$t_params->{'bloqueIni'}= $bloqueIni;
$t_params->{'numeros'}= \@numeros;
C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
