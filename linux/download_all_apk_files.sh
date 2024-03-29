#!/bin/bash
#set -x

echo "I'm calculating hash MD5 on all APK files on the Android device.Wait!"
adb shell "su -c 'find / -iname "*.apk" -exec md5sum -b "{}" \; >/data/local/tmp/apk.txt'"

echo "Download the list.Wait!"
adb pull /data/local/tmp/apk.txt .
cat apk.txt | while read BUFFER
do 
    FILE_HASH=`echo "$BUFFER" | awk '{ FS=" " ; print $1 }'`
    FILE_APK=`echo "$BUFFER" | awk '{ FS=" " ; print $2 }'`
    LOCAL_FILE_APK=.${FILE_APK}
    LOCAL_FILE_HASH=
    if [ -f "${LOCAL_FILE_APK}" ]
    then
        LOCAL_FILE_HASH=`md5sum -b "${LOCAL_FILE_APK}" | awk '{ FS=" " ; print $1 }'`
    fi 
    if [ "${LOCAL_FILE_HASH}" != "${FILE_HASH}" ]
    then
        echo "Download the new APK file '${FILE_APK}'. Wait!"
        adb pull "${FILE_APK}" "${LOCAL_FILE_APK}"
    else
        echo "APK file '${FILE_APK}' is the same! Skipped."
    fi
done

echo "Finished."
exit 0
