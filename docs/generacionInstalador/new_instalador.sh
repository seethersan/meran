#!/bin/bash
rm -fr aux
mkdir aux
VERSION="$(head -n 1 ../../VERSION)"
cp -a ../../files/ ../../opac/ ../../intranet/ ../../includes aux/
cd aux
mkdir meranunlp
cp -r ../../instalador/* meranunlp
cp ../README ../COPYING ../licencia.txt meranunlp/
echo $VERSION > meranunlp/VERSION
tar -czvf meranunlp/intranetyopac.tar.gz opac/ intranet/ includes/ files/
tar -czvf meranunlp-v$VERSION.tar.gz meranunlp
rm -fr meranunlp opac intranet includes
