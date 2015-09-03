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
# along with Meran.  If not, see <http://www.gnu.org/licenses/>.package C4::Output;
use strict;
require Exporter;
use Template;
use Template::Filters;
use C4::AR::Filtros;
use C4::AR::Auth;
use C4::AR::Preferencias;
use C4::AR::Logos;
use vars qw($VERSION @ISA @EXPORT);
$VERSION = 0.01;
=head1 NAME
C4::Output - Functions for generating HTML for the Koha web interface
=head1 SYNOPSIS
  use C4::Output;
  $str = &mklink("http://www.koha.org/", "Koha web page");
  print $str;
=head1 DESCRIPTION
The functions in this module generate HTML, and return the result as a
printable string.
=head1 FUNCTIONS
=over 2
=cut
@ISA = qw(Exporter);
@EXPORT = qw(
                gettemplate
         );
sub gettemplate {
    my ($tmplbase, $opac, $loging_out, $socio) = @_;
    my $htdocs;
    my $tema_opac   = C4::AR::Preferencias::getValorPreferencia('tema_opac_default') || C4::AR::Preferencias::getValorPreferencia('defaultUI');
    my $tema_intra  = C4::Context->config('tema');; #para volver a tener temas, poner la linea de arriba 
    my $temas       = C4::Context->config('temas');
    my $tema;
    my $type;
    if ($opac ne "intranet") {
        $htdocs     = C4::Context->config('opachtdocs');
        $temas      = C4::Context->config('temasOPAC');
        $tema       = $tema_opac;
        $type       = 'OPAC';
    } else {
        $htdocs     = C4::Context->config('intrahtdocs');
        $temas      = C4::Context->config('temas');
        $tema       = $tema_intra;
        $type       = 'INTRA';
    }
    my $filter      = Template::Filters->new({
                            FILTERS => {    'i18n' =>  \&C4::AR::Filtros::i18n, #se carga el filtro i18n
                                },
                    });
    my $template = Template->new({
                    INCLUDE_PATH    => [
                                            "$htdocs",
                                            "$htdocs/includes/",
                                            "$htdocs/catalogacion/",
                                            "$htdocs/includes/popups/",
                                            "$htdocs/includes/menu",
                                            C4::Context->config('includes_general'),
                                    ],
                    ABSOLUTE        => 1,
                    CACHE_SIZE      => 200,
                    COMPILE_DIR     => '/tmp/ttc',
                    RELATIVE        => 1,
                    EVAL_PERL       => 1,
                    LOAD_FILTERS    => [ $filter ],
                    }); 
    #se inicializa la hash de los parametros para el template
    my %params = ();
    #se asignan los parametros que son necesarios para todos los templates
    my $ui;
    my $nombre_ui       = '';
    my $default_ui      = C4::AR::Preferencias::getValorPreferencia('defaultUI');
    $ui                 = C4::Modelo::PrefUnidadInformacion->getByCode($default_ui);
    my $date            = C4::AR::Utilidades::getDate();
    if($ui){
        $nombre_ui = $ui->getNombre();
    }
    my $user_theme,
    my $user_theme_intra;
    my ($session)       = CGI::Session->load();
    my $url_server      = C4::AR::Preferencias::getValorPreferencia('serverName');
    my $opac_port       = ":".(C4::Context->config('opac_port')||'80');
    my $user_theme      = $session->param('usr_theme') || $tema_opac;
    my $server_port     = ":".$ENV{'SERVER_PORT'};
    my $registrado      = C4::AR::Preferencias::getValorPreferencia('registradoMeran'); #si esta registrado MERAN o no
    my $version         = C4::Context->version();
    if ( ($server_port == 80) || ($server_port == 443) ){
            $server_port = "";
    }
    my $SERVER_URL       =(C4::AR::Utilidades::trim($url_server)||($ENV{'SERVER_NAME'})).$server_port;
    my $SERVER_URL_OPAC  =(C4::AR::Utilidades::trim($url_server)||($ENV{'SERVER_NAME'})).$opac_port;
    #para volver a tener temas, poner $session->param('usr_theme_intra') || $tema_intra;
    $user_theme_intra   = $tema_intra;
    if ($loging_out){
        $user_theme         = $tema_opac;
        $user_theme_intra   = $tema_intra;
    }
    %params= (
            type                        => ($opac ne 'intranet'? 'opac': 'intranet'),  #indica desde donde se hace el requerimiento
            tema                        => $tema,
            temas                       => $temas,
            titulo_nombre_ui            => C4::AR::Preferencias::getValorPreferencia('titulo_nombre_ui'),
            template_name               => "$htdocs/$tmplbase", #se setea el nombre del tmpl
            ui                          => $ui,
            actual_year                 => $date->{'year'},
            date                        => $date,
            localization_FLAGS          => C4::AR::Filtros::setFlagsLang($type,$user_theme),
            HOST                        => $ENV{HTTP_HOST},
            user_theme                  => $user_theme,
            user_theme_intra            => $user_theme_intra,
            url_prefix                  => C4::AR::Utilidades::getUrlPrefix(),
            SERVER_ADDRESS              => $SERVER_URL,
            SERVER_ADDRESS_OPAC         => $SERVER_URL_OPAC,
            SERVER_PORT                 => $server_port,
            socio_data                  => C4::AR::Auth::buildSocioDataHashFromSession(),
            date_separator              => C4::AR::Filtros::i18n("de"),
            CirculationEnabled          => C4::AR::Preferencias::getValorPreferencia("CirculationEnabled"),
            LibraryName                 => C4::AR::Preferencias::getValorPreferencia("LibraryName"),
            twitter_username_to_search  => C4::AR::Preferencias::getValorPreferencia("twitter_username_to_search") || undef,
            plainPassword               => C4::Context->config('plainPassword') || 0,
            nroRandom                   => C4::AR::Auth::getSessionNroRandom(),
            unload_alert                => 0,
            logo                        => C4::AR::Logos::getNombreLogoUI(),
            registrado_meran            => $registrado,
            version                     => $version,
        );
    return ($template, \%params);
}
END { }       # module clean-up code here (global destructor)
1;
__END__
