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
use DBI;
use CGI::Session;
use C4::Context;
use Switch;
use C4::AR::Utilidades;
use C4::Modelo::RefPais;
use C4::Modelo::CatAutor;
use MARC::Record;
use C4::AR::ImportacionIsoMARC;
use C4::AR::Catalogacion;
use C4::Modelo::CatRegistroMarcN2Analitica;



sub prepararNivelParaImportar{
     my ($marc_record, $itemtype, $nivel) = @_;
       my @infoArrayNivel=();
       foreach my $field ($marc_record->fields) {
        if(! $field->is_control_field){
            my %hash_temp                       = {};
            $hash_temp{'campo'}                 = $field->tag;
            $hash_temp{'indicador_primario'}    = $field->indicator(1);
            $hash_temp{'indicador_secundario'}  = $field->indicator(2);
            $hash_temp{'subcampos_array'}       = ();
            $hash_temp{'subcampos_hash'}        = ();
            $hash_temp{'cant_subcampos'}        = 0;
            my %hash_sub_temp = {};
            my @subcampos_array;
            #proceso todos los subcampos del campo
            foreach my $subfield ($field->subfields()) {
                my $subcampo          = $subfield->[0];
                my $dato              = $subfield->[1];
                C4::AR::Debug::debug("REFERENCIA!!!  ".$hash_temp{'campo'}."  ". $subcampo);
                my $estructura = C4::AR::Catalogacion::_getEstructuraFromCampoSubCampo($hash_temp{'campo'} , $subcampo , $itemtype , $nivel);
                if(($estructura)&&($estructura->getReferencia)&&($estructura->infoReferencia)){
                    C4::AR::Debug::debug("REFERENCIA!!!  ".$estructura->infoReferencia);
                    #es una referencia, yo tengo el dato nomás (luego se verá si hay que crear una nueva o ya existe en la base)
                    my $tabla = $estructura->infoReferencia->getReferencia;
                    my ($clave_tabla_referer_involved,$tabla_referer_involved) =  C4::AR::Referencias::getTablaInstanceByAlias($tabla);
                    my ($ref_cantidad,$ref_valores) = $tabla_referer_involved->getAll(1,0,0,$dato);
                    if ($ref_cantidad){
                      #REFERENCIA ENCONTRADA
                        $dato =  $ref_valores->[0]->get_key_value;
                    }
                    else { #no existe la referencia, hay que crearla
                      $dato = C4::AR::ImportacionIsoMARC::procesarReferencia($dato,$tabla,$clave_tabla_referer_involved,$tabla_referer_involved);
                    }
                 }
                #ahora guardo el dato para importar
                if ($dato){
                  C4::AR::Debug::debug("CAMPO: ". $hash_temp{'campo'}." SUBCAMPO: ".$subcampo." => ".$dato);
                  my $hash;
                  $hash->{$subcampo}= $dato;
                  $hash_sub_temp{$hash_temp{'cant_subcampos'}} = $hash;
                  push(@subcampos_array, ($subcampo => $dato));
                  $hash_temp{'cant_subcampos'}++;
                }
              }
          if ($hash_temp{'cant_subcampos'}){
            $hash_temp{'subcampos_hash'} =\%hash_sub_temp;
            $hash_temp{'subcampos_array'} =\@subcampos_array;
            push (@infoArrayNivel,\%hash_temp)
          }
        }
      }
        return  \@infoArrayNivel;
}
sub guardarNivel1DeImportacion{
    my ($marc_record, $template,$id2_padre) = @_;
    my $infoArrayNivel1 =  prepararNivelParaImportar($marc_record,$template,1);
   my $params_n1;
    $params_n1->{'id_tipo_doc'} = $template;
    $params_n1->{'infoArrayNivel1'} = $infoArrayNivel1;
   if(($template eq 'ANA')&&($id2_padre)){
        $params_n1->{'id2_padre'} = $id2_padre;
   }
   my ($msg_object, $id1) = C4::AR::Nivel1::t_guardarNivel1($params_n1);
    return ($msg_object,$id1);
}
sub guardarNivel2DeImportacion{
    my ($id1,$marc_record,$template) = @_;
    my $infoArrayNivel2 =  prepararNivelParaImportar($marc_record,$template,2);
    my $params_n2;
    $params_n2->{'id_tipo_doc'} = $template;
    $params_n2->{'tipo_ejemplar'} = $template;
    $params_n2->{'infoArrayNivel2'} = $infoArrayNivel2;
    $params_n2->{'id1'}=$id1;
    my ($msg_object2,$id1,$id2) = C4::AR::Nivel2::t_guardarNivel2($params_n2);
    return ($msg_object2,$id1,$id2);
}
sub guardarNivel3DeImportacion{
    my ($id1, $id2, $marc_record, $template, $ui) = @_;
    my @infoArrayNivel = ();
    my $params_n3;
    $params_n3->{'id_tipo_doc'} = $template;
    $params_n3->{'tipo_ejemplar'} = $template;
    $params_n3->{'id1'}=$id1;
    $params_n3->{'id2'}=$id2;
    $params_n3->{'ui_origen'}=$ui;
    $params_n3->{'ui_duenio'}=$ui;
    $params_n3->{'cantEjemplares'} = 1;
    $params_n3->{'responsable'} = 'meranadmin'; #No puede no tener un responsable
    #Hay que autogenerar el barcode o no???
    $params_n3->{'esPorBarcode'} = 'true';
    my @barcodes_array=();
    $barcodes_array[0]=$marc_record->subfield('995','f');
    $params_n3->{'BARCODES_ARRAY'} = \@barcodes_array;
    my %hash_temp1 = {};
    $hash_temp1{'indicador_primario'}  = '#';
    $hash_temp1{'indicador_secundario'}  = '#';
    $hash_temp1{'campo'}   = '995';
    $hash_temp1{'subcampos_array'}   =();
    $hash_temp1{'cant_subcampos'}   = 0;
    my %hash_sub_temp1 = {};
    my $field_995 = $marc_record->field('995');
    if ($field_995){
        foreach my $subfield ($field_995->subfields()) {
            my $subcampo          = $subfield->[0];
            my $dato              = $subfield->[1];
            my $hash;
            $hash->{$subcampo}= $dato;
            $hash_sub_temp1{$hash_temp1{'cant_subcampos'}} = $hash;
            $hash_temp1{'cant_subcampos'}++;
        }
    }
    $hash_temp1{'subcampos_hash'} =\%hash_sub_temp1;
    if ($hash_temp1{'cant_subcampos'}){
      push (@infoArrayNivel,\%hash_temp1)
    }
    # Ahora TODOS los 900!
    my %hash_temp2 = {};
    $hash_temp2{'indicador_primario'}  = '#';
    $hash_temp2{'indicador_secundario'}  = '#';
    $hash_temp2{'campo'}   = '900';
    $hash_temp2{'subcampos_array'}   =();
    $hash_temp2{'cant_subcampos'}   = 0;
    my %hash_sub_temp2 = {};
    my $field_900 = $marc_record->field('900');
    if ($field_900){
        foreach my $subfield ($field_900->subfields()) {
            my $subcampo          = $subfield->[0];
            my $dato              = $subfield->[1];
            my $hash;
            $hash->{$subcampo}= $dato;
            $hash_sub_temp2{$hash_temp2{'cant_subcampos'}} = $hash;
            $hash_temp2{'cant_subcampos'}++;
        }
    }
    $hash_temp2{'subcampos_hash'} =\%hash_sub_temp2;
    if ($hash_temp2{'cant_subcampos'}){
      push (@infoArrayNivel,\%hash_temp2)
    }
    #my $infoArrayNivel3 =  prepararNivelParaImportar($marc_record,$template,3);
    ###########################################################################
    $params_n3->{'infoArrayNivel3'} = \@infoArrayNivel;
    my ($msg_object3) = C4::AR::Nivel3::t_guardarNivel3($params_n3);
    return $msg_object3;
}

sub buscarRegistroDuplicado{
    my ($marc_record,$template) = @_;
    my $infoArrayNivel1 =  prepararNivelParaImportar($marc_record,$template,1);
    my $params_n1;
    $params_n1->{'id_tipo_doc'} = $template;
    $params_n1->{'infoArrayNivel1'} = $infoArrayNivel1;
     my $marc_record            = C4::AR::Catalogacion::meran_nivel1_to_meran($params_n1);
     my $catRegistroMarcN1       = C4::Modelo::CatRegistroMarcN1->new();
     my $clave_unicidad_alta    = $catRegistroMarcN1->generar_clave_unicidad($marc_record);
     my $n1 = C4::AR::Nivel1::getNivel1ByClaveUnicidad($clave_unicidad_alta);
    return $n1;
}


    sub prepararRegistroParaMigrar {
        my ($material, $template, $nivel) = @_;
                #Calculamos algunos campos
        #Lista de campos
        #Tenemos Niveles 1 y 2, si ya existe el título, se agrega un nuevo 2,
        #sino se agregan los 2 niveles
        my @campos_n1=(
            ['245','a',$material->{'apellido'}.", ".$material->{'nombres'}],
            ['100','q',$material->{'apellidodecasada'}],
            ['100','d',$material->{'fecha'}],
            ['100','e',$material->{'condicion'}],
            ['100','u',$material->{'dependencia'}],
            ['545','a',$material->{'estado'}],
            ['024','d',$material->{'tipodoc'}],
            ['024','a',$material->{'documento'}],
            ['545','b',$material->{'observaciones'}]
            );
        my @campos_n2=(
            ['900','b',$nivel],
            ['910','a',$template]
            );
        my @campos_n3=(
            );
        
        #Buscamos Ejemplares
        my @ejemplares=();
        my $cant_ejemplares=0;

        my $marc_record_n1 = MARC::Record->new();
        foreach my $campo (@campos_n1){
            if($campo->[2]){
                my @campos_registro = $marc_record_n1->field($campo->[0]);
                if (($campos_registro[-1])&&(!$campos_registro[-1]->subfield($campo->[1]))){
                    #No existe el subcampo en el campo, lo agrego
                    $campos_registro[-1]->add_subfields($campo->[1] => $campo->[2]);
                }
                else{
                    #No existe el campo o ya existe el subcampo, se crea uno nuevo.
                    my $field= MARC::Field->new($campo->[0], '', '', $campo->[1] => $campo->[2]);
                    $marc_record_n1->append_fields($field);
                }
            }
        }
        my $marc_record_n2 = MARC::Record->new();
        foreach my $campo (@campos_n2){
            if($campo->[2]){
                my @campos_registro = $marc_record_n2->field($campo->[0]);
                if (($campos_registro[-1])&&(!$campos_registro[-1]->subfield($campo->[1]))){
                    #No existe el subcampo en el campo, lo agrego
                    $campos_registro[-1]->add_subfields($campo->[1] => $campo->[2]);
                }
                else{
                    #No existe el campo o ya existe el subcampo, se crea uno nuevo.
                    my $field= MARC::Field->new($campo->[0], '', '', $campo->[1] => $campo->[2]);
                    $marc_record_n2->append_fields($field);
                }
            }
        }
        my $marc_record_n3_base = MARC::Record->new();
        foreach my $campo (@campos_n3){
            if($campo->[2]){
                my @campos_registro = $marc_record_n3_base->field($campo->[0]);
                if (($campos_registro[-1])&&(!$campos_registro[-1]->subfield($campo->[1]))){
                    #No existe el subcampo en el campo, lo agrego
                    $campos_registro[-1]->add_subfields($campo->[1] => $campo->[2]);
                }
                else{
                    #No existe el campo o ya existe el subcampo, se crea uno nuevo.
                    my $field= MARC::Field->new($campo->[0], '', '', $campo->[1] => $campo->[2]);
                    $marc_record_n3_base->append_fields($field);
                }
            }
        }
        return ($marc_record_n1,$marc_record_n2,$marc_record_n3_base,\@ejemplares);
    }

##Migramos Desaparecidos##


my $op = $ARGV[0] || 0;
my $db_driver =  "mysql";
my $db_name   = 'ddhh';
my $db_host   = 'localhost';
my $db_user   = 'root';
my $db_passwd = 'dev';
open (ERROR, '>/var/log/meran/errores_migracion_ddhh_'.$op.'.txt');
my $db= DBI->connect("DBI:mysql:$db_name:$db_host",$db_user, $db_passwd);
$db->do('SET NAMES utf8');
my $dbh = C4::Context->dbh;
#Migrar Desparecidos 
my $desaparecidos=$db->prepare("SELECT ddhhdesaparecidos.apellido, ddhhdesaparecidos.apellidodecasada, ddhhdesaparecidos.nombres, ddhhdesaparecidos_estado.descripcion as estado, ddhhdesaparecidos.fecha, ddhhdesaparecidos_condicion.descripcion as condicion, ddhhdesaparecidos_tipodoc.descripcion as tipodoc, ddhhdesaparecidos.documento, ddhhdesaparecidos.observaciones, ddhhdesaparecidos_dependencia.tipodependencia as tipodependencia, ddhhdesaparecidos_dependencia.descripcion as dependencia, ddhhdesaparecidos.archivofoto FROM ddhhdesaparecidos left join ddhhdesaparecidos_estado on ddhhdesaparecidos_estado.codestado = ddhhdesaparecidos.codestado left join ddhhdesaparecidos_condicion on ddhhdesaparecidos_condicion.codcondicion = ddhhdesaparecidos.codcondicion left join ddhhdesaparecidos_tipodoc on ddhhdesaparecidos_tipodoc.codtipodoc = ddhhdesaparecidos.codtipodoc left join ddhhdesaparecidos_dependencia on ddhhdesaparecidos_dependencia.coddependencia = ddhhdesaparecidos.coddependencia;");
$desaparecidos->execute();
my $cant =  $desaparecidos->rows;
my $count=0;
my $template = 'PER';
my $nivel = "Monografico";

while (my $desaparecido=$desaparecidos->fetchrow_hashref) {
    my ($marc_record_n1,$marc_record_n2,$marc_record_n3_base,$ejemplares) = prepararRegistroParaMigrar($libro,$template,$nivel);

    my ($msg_object,$id1);
    #Si ya existe?
    my $n1 = buscarRegistroDuplicado($marc_record_n1,$template);
    if ($n1){
        #Ya existe!!!
    print "Nivel 1 ya existe \n";
        $id1 = $n1->getId1();
    } else {
        ($msg_object,$id1) =  guardarNivel1DeImportacion($marc_record_n1,$template);
    print "Nivel 1 creado ?? ".$msg_object->{'error'}."\n";
        if(!$msg_object->{'error'}){
            $registros_creados++;
        }
        else{
            #Logueo error
            my $codMsg  = C4::AR::Mensajes::getFirstCodeError($msg_object);
            my $mensaje = C4::AR::Mensajes::getMensaje($codMsg,'INTRA');
            print ERROR "Error REGISTRO: Agregando Nivel 1: ".$libro->{'libro_nombre'}." registro número: ".$libro->{'titulo_id'}." (ERROR: $mensaje )\n";
        }
    }
    if ($id1){
            #Libros
            my ($msg_object2,$id1,$id2) =  guardarNivel2DeImportacion($id1,$marc_record_n2,$template);
            print "Nivel 2 creado ?? ".$msg_object2->{'error'}."\n";
            if (!$msg_object2->{'error'}){
                $grupos_creados ++;
                #Analíticas
                #my $cant_analiticas = agregarAnaliticas($id1,$id2,$material->{'RecNo'});
                #$analiticas_creadas += $cant_analiticas;
        #       print "Analiticas creadas? ".$cant_analiticas."\n";
                print "Ejemplaress";
                foreach my $ejemplar (@$ejemplares){
                    my $marc_record_n3 = $marc_record_n3_base->clone();
                    foreach my $campo (@$ejemplar){
                        if($campo->[2]){
                              if ($marc_record_n3->field($campo->[0])){
                                #Existe el campo agrego subcampo
                                $marc_record_n3->field($campo->[0])->add_subfields($campo->[1] => $campo->[2]);
                              }
                              else{
                                #No existe el campo
                                my $field= MARC::Field->new($campo->[0], '', '', $campo->[1] => $campo->[2]);
                                $marc_record_n3->append_fields($field);
                              }
                        }
                    }
                    #print $marc_record_n3->as_formatted;
                    my ($msg_object3) = guardarNivel3DeImportacion($id1,$id2,$marc_record_n3,$template,'BLGL');
         #           print "Nivel 3 creado ?? ".$msg_object3->{'error'}."\n";
                    if (!$msg_object3->{'error'}){
                            $ejemplares_creados ++;
                    }
                }
            }
            else{
            #Logueo error
            my $codMsg  = C4::AR::Mensajes::getFirstCodeError($msg_object2);
        my $mensaje = C4::AR::Mensajes::getMensaje($codMsg,'INTRA');
                    print ERROR "Error LIBRO: Agregando Nivel 2: ".$libro->{'libro_nombre'}." registro número: ".$libro->{'libro_id'}." (ERROR: $mensaje) \n";
            }
        }
    $count ++;
    my $perc = ($count * 100) / $cant;
    my $rounded = sprintf "%.2f", $perc;
    print "Registro $count de $cant ( $rounded %)  \r\n";
}

$desaparecidos->finish();

print "FIN MIGRACION: \n";
print "Registros creados: $registros_creados \n";
print "Grupos creados: $grupos_creados \n";
print "Ejemplares Creados: $ejemplares_creados \n";
print "Analíticas Creadas: $analiticas_creadas \n";