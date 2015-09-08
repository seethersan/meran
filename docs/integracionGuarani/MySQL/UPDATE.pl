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
base=$(cat /etc/meran/meranconjunta.conf |grep database| awk -F"=" '{print $2}')
hostBase=$(cat /etc/meran/meranconjunta.conf |grep hostname| awk -F"=" '{print $2}')
usuarioBase=$(cat /etc/meran/meranconjunta.conf |egrep ^user=| awk -F"=" '{print $2}')
passBase=$(cat /etc/meran/meranconjunta.conf |egrep ^pass=| awk -F"=" '{print $2}')
fotosPATH=$(cat /etc/meran/meranconjunta.conf |egrep ^picturesdir=| awk -F"=" '{print $2}')
debug=0
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
	echo "Actualizar las Bases de Datos MYSQL?(S/N)";
	read pregunta2;
	else 
	 pregunta=S;
	 pregunta2=S;
fi
if [ $pregunta = S ] 
 then
 if [ ! -d backs/ ] 
	then
	mkdir backs;
	echo "CREADO";
	fi
 
if [ -f personsUPDATE.sql ] 
	then 
	mv personsUPDATE.sql backs/personsUPDATE`date +%d-%m-%Y_%H-%M`.sql;
fi
perl -T script_sql_UPDATE.pl $1 "dbi:mysql:$base" $usuarioBase $passBase $3 $debug > personsUPDATE.sql 2>> /var/log/actualizacion/erroresMYSQL;
fi
if [ $pregunta2 = S ] 
	then
		if [ ! -d backs ]
			then
			mkdir backs ;
			fi
		echo "Comenzando actualizacion de mysql del día  "`date +%d-%m-%Y_%H:%M` >> /var/log/actualizacion/resultado ;
		echo "Errores del día "`date +%d-%m-%Y-%H:%M` >> /var/log/actualizacion/erroresMYSQL ;
		mysqldump $base -h$hostBase -u$usuarioBase -t usr_persona -p$passBase > backs/persons`date +%d-%m-%Y_%H:%M`.sql; 
		mysqldump $base -h$hostBase -u$usuarioBase -t usr_socio -p$passBase >> backs/persons`date +%d-%m-%Y_%H:%M`.sql; 
		mysql $base -h$hostBase -u$usuarioBase -f -p$passBase < personsUPDATE.sql 2>> /var/log/actualizacion/erroresMYSQL;
		echo "Finalizando actualizacion de mysql del día  "`date +%d-%m-%Y_%H:%M` >> /var/log/actualizacion/resultado ;
	fi
echo "Finalizando UPDATE "`date +%d-%m-%Y-%H:%M` >> /var/log/actualizacion/resultado ;
