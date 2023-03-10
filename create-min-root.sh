#!/bin/sh

ldd_helper() {
    TESTFILE=$1
    ldd $TESTFILE 2> /dev/null > /dev/null || return

    RESULT=$(ldd $TESTFILE | grep -oP '\s\S+\s\(\S+\)' | sed -e 's/^\s//' -e 's/\s.*$//') #'
    echo "$RESULT"
}

find_binaries() {
    OUTPUT=$(mktemp)
    for f in $(cat $1)
    do
        ldd_helper $f >> $OUTPUT
    done
    cat $OUTPUT | sort | uniq | sed -e '/linux-vdso.so.1/d' > $OUTPUT.new
    mv -f $OUTPUT.new $OUTPUT
    cat $OUTPUT | xargs realpath > $OUTPUT.new
    cat $OUTPUT.new >> $OUTPUT
    rm -f $OUTPUT.new
    cat $OUTPUT
}

FILES=$(mktemp)
BINARY_LIST=$(mktemp)

find /usr/build/prefix > $FILES
find_binaries $FILES > $BINARY_LIST

TAR_FILE=$(mktemp)
rm $TAR_FILE
TAR_FILE_LIST=$(mktemp)
cat $TAR_FILE_LIST

cat $FILES > $TAR_FILE_LIST
cat $BINARY_LIST >> $TAR_FILE_LIST
tar -czf $TAR_FILE --no-recursion --transform='s/usr\/build\/prefix\///g' -T $(cat $TAR_FILE_LIST | xargs -i sh -c 'test -e {} && echo {}')
mv -f $TAR_FILE /root/min-root.tar.gz