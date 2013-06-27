#!/bin/bash
#set -x

echo "I'm GRANTING all SQLITE3 files on the Android device.Wait!"
adb shell "su -c 'find / -iname "*.db" -exec chmod 666 "{}" \;'"

echo "I'm calculating hash MD5 on all SQLITE3 files on the Android device.Wait!"
adb shell "su -c 'find / -iname "*.db" -exec md5sum -b "{}" \; >/data/local/tmp/sqlite3.txt'"

echo "Download the list.Wait!"
adb pull /data/local/tmp/sqlite3.txt .

echo "I'm starting to read the file..."
cat sqlite3.txt | while read BUFFER
do 
    FILE_HASH=`echo "$BUFFER" | awk '{ FS=" " ; print $1 }'`
    FILE_SQLITE=`echo "$BUFFER" | awk '{ FS=" " ; print $2 }'`
    LOCAL_FILE_SQLITE=.${FILE_SQLITE}
    LOCAL_FILE_HASH=
    if [ -f "${LOCAL_FILE_SQLITE}" ]
    then
        LOCAL_FILE_HASH=`md5sum -b "${LOCAL_FILE_SQLITE}" | awk '{ FS=" " ; print $1 }'`
    fi 
    if [ "${LOCAL_FILE_HASH}" != "${FILE_HASH}" ]
    then
        echo "Download the new SQLITE file '${FILE_SQLITE}'. Wait!"
        adb pull "${FILE_SQLITE}" "${LOCAL_FILE_SQLITE}"
    else
        echo "SQLITE file '${FILE_SQLITE}' is the same! Skipped."
    fi
done

echo "Finished."
exit 0
