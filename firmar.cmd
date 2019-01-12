call ..\configfirma.cmd
apksigner sign --ks %APKSIGNFILE% android\app\build\outputs\apk\release\app-release-unsigned.apk

