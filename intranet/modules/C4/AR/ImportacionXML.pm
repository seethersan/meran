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
package C4::AR::ImportacionXML;
=head
    Este modulo sera el encargado de realizar importaciones apartir de un XML
=cut
use strict;
require Exporter;
use C4::Context;
use C4::AR::XMLDBI;
use C4::Context;
use C4::AR::Utilidades ();
use XML::Checker::Parser;
use vars qw(@EXPORT_OK @ISA);
@ISA        = qw(Exporter);
@EXPORT_OK  = qw(
        importarVisualizacion
        importarCreacionCatalogo
);
=item
    Realiza la importacion de una la creacion de catalogo
=cut
sub importarCreacionCatalogo{
    my ($params, $postdata)  = @_;
    my $msg_object          = C4::AR::Mensajes::create();
    ######################## escribimos el archivo en /tmp ####################
    my @whiteList   = qw(
                            xml
                        );
    my $path    = "/tmp/output.xml";
    
    eval {
        # doesn't work
        # open(F, ">$path") or die "Cant write to $path. Reason: $!";
        #     print F $postdata;
        # close(F);
        # con BINMODE UN XML !!!! WTF !!!
        open ( WRITEIT, ">$path" ) or die "$!"; 
        binmode WRITEIT; 
        while ( <$postdata> ) { 
            print WRITEIT; 
        }
        close(WRITEIT);
    };
    if ($@) {
        C4::AR::Debug::debug("se murio escribiendo el archivo");
        $msg_object->{'error'} = 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'IXML03', 'intra'} ) ;
    
        return ($msg_object);
    }
    ################################ importacion y validacion  ###############################
    my $context = new C4::Context;
    my $user    = $context->config('userINTRA');
    my $pass    = $context->config('passINTRA');
    my $db      = $context->config('database');
    my $table   = "cat_estructura_catalogacion";
    my $xmldb   = XMLDBI->new('mysql', $db  . ';host=localhost', $user, $pass, $table, $db);
    #por ahora se borra siempre antes
    $xmldb->execute("DELETE FROM $table");
    eval {
        open(FILE, $path) or die $!;
        my $file = join "", <FILE>;
        # valida contra un DTD
        XML::Checker::Parser::map_uri('-//W3C//DTD HTML 4.0//EN' => C4::Context->config("dtdPath") . 'catalogo.dtd');
        $xmldb->parsestring($file);
    };
    if($@){
        # no pudo insertarlo o algun error 
        C4::AR::Debug::debug("se murio insertandolo en la base o validando contra un DTD");
        $msg_object->{'error'} = 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'IXML02', 'intra'} ) ;
        return ($msg_object);
    }
    $msg_object->{'error'} = 0;
    
    C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'IXML00', 'intra'} ) ;
    return ($msg_object);
}
=item
    Realiza la importacion de una visualizacion OPAC o INTRA
=cut
sub importarVisualizacion{
    my ($params, $postdata, $tipo)  = @_;
    my $msg_object          = C4::AR::Mensajes::create();
    ######################## escribimos el archivo en /tmp ####################
    my @whiteList   = qw(
                            xml
                        );
    my $path    = "/tmp/output.xml";
    
    eval {
        # doesn't work
        # open(F, ">$path") or die "Cant write to $path. Reason: $!";
        #     print F $postdata;
        # close(F);
        # con BINMODE UN XML !!!! WTF !!!
        open ( WRITEIT, ">$path" ) or die "$!"; 
        binmode WRITEIT; 
        while ( <$postdata> ) { 
            print WRITEIT; 
        }
        close(WRITEIT);
    };
    if ($@) {
        C4::AR::Debug::debug("se murio escribiendo el archivo");
        $msg_object->{'error'} = 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'IXML03', 'intra'} ) ;
    
        return ($msg_object);
    }
    ################################ importacion y validacion  ###############################
    # perl xml2sql.pl -sn econo -uid root -pwd dev -table cat_visualizacion_opac -input output.xml -v -driver mysql -x
    my $context = new C4::Context;
    my $user    = $context->config('userINTRA');
    my $pass    = $context->config('passINTRA');
    my $db      = $context->config('database');
    my $table   = "";
    if($tipo eq "opac"){
        $table   = 'cat_visualizacion_opac';
    }else{
        $table   = 'cat_visualizacion_intra';
    }
    my $xmldb   = XMLDBI->new('mysql', $db  . ';host=localhost', $user, $pass, $table, $db);
    #por ahora se borra siempre antes
    $xmldb->execute("DELETE FROM $table");
    eval {
        open(FILE, $path) or die $!;
        my $file = join "", <FILE>;
        #expresion regular que cambie <vista_campo></vista_campo> por <vista_campo>''</vista_campo>
        #sino inserta NULL en MySQL y vista_campo es NOT NULL
        $file =~ s/\<vista\_campo\>\<\/vista\_campo\>/\<vista\_campo\>\ \<\/vista\_campo\>/g;
        # valida contra un DTD
        XML::Checker::Parser::map_uri('-//W3C//DTD HTML 4.0//EN' => C4::Context->config("dtdPath") . 'visualizacion.dtd');
        $xmldb->parsestring($file);
    };
    if($@){
        # no pudo insertarlo o algun error 
        C4::AR::Debug::debug("se murio insertandolo en la base o validando contra un DTD");
        $msg_object->{'error'} = 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'IXML02', 'intra'} ) ;
        return ($msg_object);
    }
    $msg_object->{'error'} = 0;
    
    C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'IXML00', 'intra'} ) ;
    return ($msg_object);
}
END { }       # module clean-up code here (global destructor)
1;
__END__