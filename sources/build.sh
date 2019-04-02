#!/bin/sh
source venv/bin/activate
set -e

cd sources

echo "Generating Static fonts"
mkdir -p ../fonts/ttfs
fontmake -g "MerriweatherSans for VF.glyphs" -i -o ttf --output-dir ../fonts/ttfs/
fontmake -g "MerriweatherSans-Italic for VF.glyphs" -i -o ttf --output-dir ../fonts/ttfs/

echo "Generating VFs"
mkdir -p ../fonts/variable
fontmake -g "MerriweatherSans for VF.glyphs" -o variable --output-path ../fonts/variable/MerriweatherSans-Roman-VF.ttf
fontmake -g "MerriweatherSans-Italic for VF.glyphs" -o variable --output-path ../fonts/variable/MerriweatherSans-Italic-VF.ttf

# rm -rf master_ufo/ instance_ufo/
echo "Post processing"


ttfs=$(ls ../fonts/ttfs/*.ttf)
for ttf in $ttfs
do
	gftools fix-dsig -f $ttf;
	gftools fix-nonhinting $ttf "$ttf.fix";
	mv "$ttf.fix" $ttf;
done
rm ../fonts/ttfs/*backup*.ttf

vfs=$(ls ../fonts/variable/*.ttf)
for vf in $vfs
do
	gftools fix-dsig -f $vf;
	gftools fix-nonhinting $vf "$vf.fix";
	mv "$vf.fix" $vf;
	ttx -f -x "MVAR" $vf; # Drop MVAR. Table has issue in DW
	rtrip=$(basename -s .ttf $vf)
	new_file=../fonts/variable/$rtrip.ttx;
	rm $vf;
	ttx $new_file
	rm ../fonts/variable/*.ttx
done
rm ../fonts/variable/*backup*.ttf

gftools fix-vf-meta $vfs;
for vf in $vfs
do
	mv "$vf.fix" $vf;
done

cd ..

# echo "QAing"
# TODO (M FOLEY) merge https://github.com/googlefonts/gftools/pull/101
# gftools qa ../fonts/variable/*.ttf -fb ../old_dropbox/_deliverables/TTF/*.ttf -o ../qa --fontbakery --diffenator --browser-previews

