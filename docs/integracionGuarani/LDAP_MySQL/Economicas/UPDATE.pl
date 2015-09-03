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
base=$(cat /etc/meran/meranECONOMICAS.conf |grep database| awk -F"=" '{print $2}')
usuarioBase=$(cat /etc/meran/meranECONOMICAS.conf |egrep ^user=| awk -F"=" '{print $2}')
passBase=$(cat /etc/meran/meranECONOMICAS.conf |egrep ^pass=| awk -F"=" '{print $2}')
fotosPATH=$(cat /etc/meran/meranECONOMICAS.conf |egrep ^picturesdir=| awk -F"=" '{print $2}')
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
	echo "Actualizar las Bases de Datos LDAP y MYSQL?(S/N)";
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
 if [ -f ldifUPDATE.ldif ]
 	then 
	mv ldifUPDATE.ldif backs/ldifUPDATE`date +%d-%m-%Y_%H-%M`.ldif;
         fi
echo "Arrancando con el ldap_UPDATE $1 $2 $3";
export PERL5LIB=/usr/share/meran/ECONOMICAS/intranet/modules/C4/Share/share/perl/5.10.1/:/usr/share/meran/ECONOMICAS/intranet/modules/C4/Share/lib/perl/5.10.1/:/usr/share/meran/ECONOMICAS/intranet/modules/C4/Share/share/perl/5.10/:/usr/share/meran/ECONOMICAS/intranet/modules/C4/C4/Share/share/perl/5.10.1/:/usr/share/meran/ECONOMICAS/intranet/modules/C4/Share/lib/perl/5.10/:/usr/share/meran/ECONOMICAS/intranet/modules/C4/Share/lib/perl5/; export MERAN_CONF=/etc/meran/meranECONOMICAS.conf; perl -T script_ldap_UPDATE.pl $1 $4 > ldifUPDATE.ldif 2>> /var/log/actualizacion/erroresLDAP;
 
if [ -f personsUPDATE.sql ] 
	then 
	mv personsUPDATE.sql backs/personsUPDATE`date +%d-%m-%Y_%H-%M`.sql;
fi
export PERL5LIB=/usr/share/meran/ECONOMICAS/intranet/modules/C4/Share/share/perl/5.10.1/:/usr/share/meran/ECONOMICAS/intranet/modules/C4/Share/lib/perl/5.10.1/:/usr/share/meran/ECONOMICAS/intranet/modules/C4/Share/share/perl/5.10/:/usr/share/meran/ECONOMICAS/intranet/modules/C4/C4/Share/share/perl/5.10.1/:/usr/share/meran/ECONOMICAS/intranet/modules/C4/Share/lib/perl/5.10/:/usr/share/meran/ECONOMICAS/intranet/modules/C4/Share/lib/perl5/; export MERAN_CONF=/etc/meran/meranECONOMICAS.conf; perl -T script_sql_UPDATE.pl $1 "dbi:mysql:$base" $usuarioBase $passBase $3 $debug > personsUPDATE.sql 2>> /var/log/actualizacion/erroresMYSQL;
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
			/usr/sbin/slapcat > backs/arbol`date +%d-%m-%Y_%H-%M`.ldif;
		/usr/sbin/slapadd -c -l /home/soportelinti/ldifUPDATE.ldif 2>> /var/log/actualizacion/erroresLDAP;
		chown openldap:openldap -R /var/lib/ldap
			/etc/init.d/slapd start;
			fi
		echo "Finalizando actualizacion de LDAP del día  "`date +%d-%m-%Y_%H:%M` >> /var/log/actualizacion/resultado ;
		echo "Comenzando actualizacion de mysql del día  "`date +%d-%m-%Y_%H:%M` >> /var/log/actualizacion/resultado ;
		echo "Errores del día "`date +%d-%m-%Y-%H:%M` >> /var/log/actualizacion/erroresMYSQL ;
		mysqldump $base -u$usuarioBase -t usr_persona -p$passBase > backs/persons`date +%d-%m-%Y_%H:%M`.sql; 
		mysqldump $base -u$usuarioBase -t usr_socio -p$passBase >> backs/persons`date +%d-%m-%Y_%H:%M`.sql; 
		mysql $base -u$usuarioBase -f -p$passBase < personsUPDATE.sql 2>> /var/log/actualizacion/erroresMYSQL;
		echo "Finalizando actualizacion de mysql del día  "`date +%d-%m-%Y_%H:%M` >> /var/log/actualizacion/resultado ;
	fi
echo "Finalizando UPDATE "`date +%d-%m-%Y-%H:%M` >> /var/log/actualizacion/resultado ;
