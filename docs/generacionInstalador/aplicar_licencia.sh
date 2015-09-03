#!/bin/bash

cd ../../

for i in $(find -name *.pl); do
	echo "#!/usr/bin/perl" > /tmp/auxiliar
	LANG=es_ES.iso88591 cat ./docs/generacionInstalador/licencia.txt >> /tmp/auxiliar
	LANG=es_ES.iso88591 sed s/^#.*//g $i >> /tmp/auxiliar
	LANG=es_ES.iso88591 sed '/^$/d' /tmp/auxiliar > $i
	chmod +x $i
done;
for i in $(find -name *.pm); do
	LANG=es_ES.iso88591 cat ./docs/generacionInstalador/licencia.txt > /tmp/auxiliar
	LANG=es_ES.iso88591 sed s/^#.*//g $i >> /tmp/auxiliar
	LANG=es_ES.iso88591 sed '/^$/d' /tmp/auxiliar > $i
done;

