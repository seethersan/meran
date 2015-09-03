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
# along with Meran.  If not, see <http://www.gnu.org/licenses/>.package C4::AR::Debug;
use strict;
use warnings;
require Exporter;
use vars qw(@EXPORT_OK @ISA);
@ISA = qw(Exporter);
@EXPORT_OK = qw(
                log      
                debug
                warn
                info
                debugObject
                error
                debug_date_time
                printErrorDB
                printSession
);
sub log{
    my ($object, $data, $metodoLlamador) = @_;
    debug("Object: ".$object->toString."=> ".$metodoLlamador."\n");
}
sub printErrorDB {
    my($descripcion,$codigo,$tipo)=@_;
    my $paraMens;
    my $message=  C4::AR::Mensajes::getMensaje($codigo,$tipo,$paraMens);
    error($message."   ---  ".$descripcion);
}
=item
debug por linea
=cut
sub debugObject{
    my ($object, $data) = @_;
    my $type = C4::AR::Auth::getSessionType();
    my $nro_socio = C4::AR::Auth::getSessionNroSocio() || 'SIN_SOCIO_EN_SESION';
    debug($nro_socio."-- $type -- Object: ".$object->toString."=> ".$data."\n");
       
}
sub debug_date_time{
    debug(_str_debug_date_time());
}
=head2
    sub _str_debug_date_time
    
    genera el string con la fecha y hora
=cut
sub _str_debug_date_time{
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
    #     dia-mes-año    
    return $mday."-".($mon+1)."-".($year+1900)." ".$hour.":".$min.":".$sec;
}
sub _write_debug{
    my ($data) = @_;
    eval {
        my $context = new C4::Context;
        my $debug_file = $context->config('debug_file') || "/usr/share/meran/logs/debug.txt";
        my $type = C4::AR::Auth::getSessionType();
        my $nro_socio = C4::AR::Auth::getSessionNroSocio() || "";
        if (C4::AR::Utilidades::validateString($nro_socio)){
        	$nro_socio.=" -- ";
        }
        open(DEBUG_FILE, ">>".$debug_file);
    	print DEBUG_FILE $nro_socio."$type --("._str_debug_date_time().") => ".$data."\n";
    	close(DEBUG_FILE);        
    };
}
sub _debugStatus{
  my $context = new C4::Context;
  C4::AR::Auth::getSessionType();
    
  return ($context->config('debug'));    
}
sub error{
    my ($data) = @_;
    my $enabled = _debugStatus();
    (($enabled >= 128) && _write_debug("[error] ".$data));
}
sub warn{
    my ($data) = @_;
    my $enabled = _debugStatus();
    (($enabled >= 256) && _write_debug("[warn] ".$data));
}
sub info{
    my ($data) = @_;
    my $enabled = _debugStatus();
    (($enabled >= 512) && _write_debug("[info] ".$data));
}
sub debug{
    my ($data) = @_;
    my $enabled = _debugStatus();
    ($enabled >= 1024) && ($data) && (_write_debug("[debug] ".$data));
}
sub _printHASH {
    my ($hash_ref) = @_;
    C4::AR::Debug::debug("\n");
    C4::AR::Debug::debug("PRINT HASH: \n");
    if($hash_ref){
        while ( my ($key, $value) = each(%$hash_ref) ) {
				C4::AR::Debug::debug("		key: $key => value: $value\n");
		}
    }
    C4::AR::Debug::debug("\n");
}
=item sub printSession
    imprime los datos de la sesion
    Parametros:
    $session: sesion de la cual se sacan los datos a imprimir
    $desde: desde donde se llama esta funcion
=cut
sub printSession {
    my ($session, $desde) = @_;
    C4::AR::Debug::debug("\n");
    C4::AR::Debug::debug("*******************************************SESSION******************************************************");
    C4::AR::Debug::debug("Desde:                        ".$desde);
    C4::AR::Debug::debug("session->userid:              ".$session->param('userid'));
    C4::AR::Debug::debug("session->loggedinusername:    ".$session->param('loggedinusername'));
    C4::AR::Debug::debug("session->borrowernumber:      ".$session->param('borrowernumber'));
    C4::AR::Debug::debug("session->password:            ".$session->param('password'));
    C4::AR::Debug::debug("session->nroRandom:           ".$session->param('nroRandom'));
    C4::AR::Debug::debug("session->sessionID:           ".$session->param('sessionID'));
    C4::AR::Debug::debug("session->lang:                ".$session->param('lang'));
    C4::AR::Debug::debug("session->type:                ".$session->param('type'));
    C4::AR::Debug::debug("session->flagsrequired:       ".$session->param('flagsrequired'));
    C4::AR::Debug::debug("session->REQUEST_URI:         ".$session->param('REQUEST_URI'));
    C4::AR::Debug::debug("session->browser:             ".$session->param('browser'));
    C4::AR::Debug::debug("*****************************************END**SESSION****************************************************");
    C4::AR::Debug::debug("\n");
}
1;
__END__
