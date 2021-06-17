#!/bin/sh

rm -rf gen obj

echo " aapt2"
mkdir gen

aapt2 compile --dir libs/res-appcompat -o libs/resources-appcompat.zip
aapt2 compile --dir libs/res-cardview -o libs/resources-cardview.zip
aapt2 compile --dir libs/res-design -o libs/resources-design.zip
aapt2 compile --dir libs/res-recyclerview -o libs/resources-recyclerview.zip
aapt2 compile --dir res -o resources.zip
aapt2 link -I android.jar --rename-manifest-package "com.iamtrk.androidexplorer" --auto-add-overlay -R libs/resources-appcompat.zip -R libs/resources-cardview.zip -R libs/resources-design.zip -R libs/resources-recyclerview.zip --manifest AndroidManifest.xml --java gen --extra-packages android.support.v7.appcompat:android.support.v7.cardview:android.support.design:android.support.v7.recyclerview -o res.apk resources.zip
#rm -f libs/resources-appcompat.zip libs/resources-cardview.zip libs/resources-design.zip libs/resources-recyclerview.zip resources.zip

for i in libs/*.jar; do
  libs="$libs:$i"
  dxlibs="$dxlibs $i"
  d8libs="$d8libs --classpath $i"
done
libs="${libs#:}"

echo " javac"
mkdir obj
javac -source 1.7 -target 1.7 -bootclasspath android.jar -cp $libs -sourcepath java:gen $(find java gen -type f -name '*.java') -d obj
#rm -rf gen

echo " d8"
#echo $d8libs
#echo $dxlibs
#echo $(find obj -type f)
#mkdir d8output
mkdir d8output
d8 --release --lib android.jar $d8libs --output d8output $(find obj -type f) $dxlibs
#rm -rf obj
echo "finished"
#R文件们 $(find obj -type f), dxlibs
# 用apktool替换apkbuilder
echo "apktool"
apktool d res.apk --output reverseCompiledRes
cp ./d8output/classes.dex ./reverseCompiledRes
apktool b reverseCompiledRes --output ./out.apk
#echo " apkbuilder"
#apkbuilder out.apk -u -z res.apk -f classes.dex
#rm -f classes.dex res.apk

#echo " zipalign"
#zipalign 4 out.apk out-aligned.apk
#rm -f out.apk

echo " apksigner"
apksigner sign --ks debug.keystore --ks-pass pass:android --out final.apk out.apk

#apksigner sign --ks debug.keystore --ks-pass pass:android --out final.apk out-aligned.apk
#rm -f out-aligned.apk
