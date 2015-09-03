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
use C4::Modelo::CatRegistroMarcN1;
use C4::Modelo::CatRegistroMarcN1::Manager;
use MARC::Record;
my $n1s = C4::Modelo::CatRegistroMarcN1::Manager->get_cat_registro_marc_n1(); 
my $cant=0;
foreach my $n1 (@$n1s){
   my $marc_record_base    = MARC::Record->new_from_usmarc($n1->getMarcRecord());
   my $registro_erroneo=0;
   my $log="";
   my @titulos= $marc_record_base->field("245");
   if(scalar(@titulos) > 1){
      $log="Título repetido id1=".$n1->getId1." = " .$titulos[0]->subfield("a") ." (".scalar(@titulos)." títulos) ";
      $registro_erroneo=1;
      
      # Tomo el 1ro
      my $primer_titulo = $titulos[0];
      # Elimino todos
      $marc_record_base->delete_fields(@titulos);
      #Vuelvo a agregar el 1ro
      $marc_record_base->append_fields($primer_titulo);
      
      }
   my @autores= $marc_record_base->field("100");
   if(scalar(@autores) > 1){
      $log .= " + Autor repetido id1=".$n1->getId1." = " .$autores[0]->subfield("a") ." (".scalar(@autores)." autores)";
      $registro_erroneo=1;
      
      # Tomo el 1ro
      my $primer_autor = $autores[0];
      # Elimino todos
      $marc_record_base->delete_fields(@autores);
      #Vuelvo a agregar el 1ro
      $marc_record_base->append_fields($primer_autor);
      }
      
   if($registro_erroneo){
        $cant =$cant+1;
        print $log."\n";
        $n1->setMarcRecord($marc_record_base->as_usmarc());
        $n1->save();
       }
}
print "Errores en ".$cant." registros";
1;
