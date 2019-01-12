#!/bin/sh
#
# Destop processing does not use the manifest data supplied by APDE.
# Since most of my development takes place in APDE and I use
# desktop for exporting to gradle only, I will use a shell script to
# make manifest changes appear in gradle.

#  Permissions are less problematic since Processing an Gradle keep
#  permissions that appear inside AndroidManifest.

MANIFESTPACKAGE=$(grep "manifest.package" sketch.properties|cut -d= -f 2)
MANIFESTVERSIONNAME=$(grep "manifest.version.name" sketch.properties|cut -d= -f 2)
MANIFESTVERSIONCODE=$(grep "manifest.version.code" sketch.properties|cut -d= -f 2)

echo values from build.gradle:
echo $MANIFESTPACKAGE
echo $MANIFESTVERSIONNAME
echo $MANIFESTVERSIONCODE

#TO-DO: compare versioncode with build.gradle. It has to be bigger.

if [ -s android/app/build.gradle ]; then

  cat android/app/build.gradle | sed -e "/defaultConfig/,/}/{;s/\(applicationId *[\"]\)[^\"]*\(\"\)/\1$MANIFESTPACKAGE\2/g;s/\(versionName[ ]*[\"]\)[^\"]*\(\"\)/\1$MANIFESTVERSIONNAME\2/g;s/\(versionCode[ ]*\)[0-9]*/\1$MANIFESTVERSIONCODE/g;}"  > android/app/build.gradle.new
  
  if [ -s android/app/build.gradle.new ]; then
      echo New android/app/build.gradle.new generated    
      mv android/app/build.gradle android/app/build.gradle.old
      mv android/app/build.gradle.new android/app/build.gradle
   
  fi
   
else
    echo android/app/build.gradle missing

fi