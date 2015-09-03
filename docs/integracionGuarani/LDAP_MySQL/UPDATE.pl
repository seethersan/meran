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
preguntar=$2;
if [ ! -d /var/log/actualizacion/ ] 
	then
	mkdir /var/log/actualizacion/;
	echo "CREADO";
	fi
echo "Comenzando UPDATE "`date +%d/%m/%Y-%H:%M` >> /var/log/actualizacion/resultado ;
if [ $preguntar = 1 ] 
 then
 echo "Actualizar los datos a actualizar desde el archivo de Guarani?(S/N)";
 read pregunta;
 echo "Actualizar las Bases de Datos LDAP y MYSQL?(S/N)";
 read pregunta2;
 else 
 pregunta=S;
 pregunta2=S;
fi
if [ $pregunta = S ] 
 then
 if [ -f ldifUPDATE.ldif ]
 	then 
	mv ldifUPDATE.ldif ldifUPDATE`date +%d-%m-%Y_%H-%M`.ldif;
         fi
./script_ldap_UPDATE.pl $1 > ldifUPDATE.ldif 2>> /var/log/actualizacion/erroresLDAP;
 if [ -f personsUPDATE.sql ] 
 	then 
		mv personsUPDATE.sql personsUPDATE`date +%d-%m-%Y_%H-%M`.sql;
	fi
./script_sql_UPDATE.pl $1 > personsUPDATE.sql 2>> /var/log/actualizacion/erroresMYSQL;
fi
if [ $pregunta2 = S ] 
	then
		echo "Comenzando actualizacion de LDAP del día  "`date +%d-%m-%Y_%H:%M` >> /var/log/actualizacion/resultado ;
		echo "Errores del día "`date +%d/%m/%Y-%H:%M` >> /var/log/actualizacion/erroresLDAP ;
		if [ ! -d backs ]
			then
			mkdir backs ;
			fi
		if [ -f ldifUPDATE.ldif ] 
			then
			/etc/init.d/slapd stop;
			slapcat > backs/arbol`date +%d-%m-%Y_%H-%M`.ldif;
			slapadd -c -l ldifUPDATE.ldif 2>> /var/log/actualizacion/erroresLDAP;
			/etc/init.d/slapd start;
			fi
		echo "Finalizando actualizacion de LDAP del día  "`date +%d-%m-%Y_%H:%M` >> /var/log/actualizacion/resultado ;
		echo "Comenzando actualizacion de mysql del día  "`date +%d-%m-%Y_%H:%M` >> /var/log/actualizacion/resultado ;
		echo "Errores del día "`date +%d-%m-%Y-%H:%M` >> /var/log/actualizacion/erroresMYSQL ;
		mysqldump Econo -t persons -p$3 > backs/persons`date +%d-%m-%Y_%H:%M`.sql; 
		mysql Econo -f -p$3 < personsUPDATE.sql 2>> /var/log/actualizacion/erroresMYSQL;
		echo "Finalizando actualizacion de mysql del día  "`date +%d-%m-%Y_%H:%M` >> /var/log/actualizacion/resultado ;
	fi
y si!!!
echo "Finalizando UPDATE "`date +%d-%m-%Y-%H:%M` >> /var/log/actualizacion/resultado ;
