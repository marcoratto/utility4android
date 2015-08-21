# Download All JPEG files #

```

#!/bin/bash
#set -x

echo "I'm calculating hash MD5 on all JPEG files on the Android device.Wait!"
adb shell "su -c 'find /mnt/sdcard/DCIM/Camera -iname "*.jpg" -exec md5sum -b "{}" \; >/data/local/tmp/jpg.txt'"
RET_CODE=$?
if [ $RET_CODE -ne 0 ]
then
    echo "ERROR $RET_CODE: adb return an error! Stopped."
    exit 1
fi

echo "Download the list.Wait!"
adb pull /data/local/tmp/jpg.txt .
RET_CODE=$?
if [ $RET_CODE -ne 0 ]
then
    echo "ERROR $RET_CODE: adb return an error! Stopped."
    exit 1
fi
cat jpg.txt | while read BUFFER
do 
    FILE_HASH=`echo "$BUFFER" | cut -c 1-32`
    FILE_JPEG=`echo "$BUFFER" | cut -c 35-`
    LOCAL_FILE_JPEG=`basename "${FILE_JPEG}"`
    LOCAL_FILE_HASH=
    if [ -f "${LOCAL_FILE_JPEG}" ]
    then
        LOCAL_FILE_HASH=`md5sum -b "${LOCAL_FILE_JPEG}" | awk '{ FS=" " ; print $1 }'`
    fi 
    if [ "${LOCAL_FILE_HASH}" != "${FILE_HASH}" ]
    then
        echo "Download the new JPEG file '${FILE_JPEG}'. Wait!"
        adb pull "${FILE_JPEG}" "${LOCAL_FILE_JPEG}"
        RET_CODE=$?
        if [ $RET_CODE -ne 0 ]
        then
            echo "ERROR $RET_CODE: adb return an error! Stopped."
            exit 1
        fi
    else
        echo "JPEG file '${FILE_JPEG}' is the same! Skipped."
    fi
done

echo "Finished."
exit 0

```