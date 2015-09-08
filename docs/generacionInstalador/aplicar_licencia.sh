#!/bin/bash

cd /usr/share/meran/dev/

for i in $(find -name '*.pl'); do
	echo "#!/usr/bin/perl" > /tmp/auxiliar
	LANG=es_ES.iso88591 cat  /usr/share/meran/dev/docs/generacionInstalador/licencia.txt >> /tmp/auxiliar
	LANG=es_ES.iso88591 sed s/^#.*//g $i >> /tmp/auxiliar
	LANG=es_ES.iso88591 sed '/^$/d' /tmp/auxiliar > $i
	chmod +x $i
done;

cd /usr/share/meran/dev/intranet/modules/C4/AR/

for i in $(find -name '*.pm'); do
	LANG=es_ES.iso88591 cat /usr/share/meran/dev/docs/generacionInstalador/licencia.txt > /tmp/auxiliar
	LANG=es_ES.iso88591 sed s/^#.*//g $i >> /tmp/auxiliar
	LANG=es_ES.iso88591 sed '/^$/d' /tmp/auxiliar > $i
done;

