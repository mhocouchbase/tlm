#!/bin/bash

set -x

if [ $(uname -s) = "Darwin" ]; then
    XLOCALE_FILE=/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include/xlocale.h
else
    XLOCALE_FILE=/usr/include/xlocale.h
fi

LOCALE_FILE=/usr/include/locale.h

if [ ! -e ${XLOCALE_FILE} ]; then
    echo "$XLOCALE_FILE does not exist!"
    echo "Creating symlink for $XLOCALE_FILE ..."
    ln -s ${LOCALE_FILE} ${XLOCALE_FILE}
fi
