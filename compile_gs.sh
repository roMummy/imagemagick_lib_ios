#!/bin/bash

ghostscript_compile() {
    echo "[|- MAKE ghostscript $BUILDINGFOR]"
    try make so -j$CORESNUM
    try make install
    echo "[|- CP STATIC/DYLIB $BUILDINGFOR]"
    try cp $ghostscript_LIB_DIR/lib/$LIBPATH_ghostscript $LIB_DIR/libghostscript.a.$BUILDINGFOR
    try cp $ghostscript_LIB_DIR/lib/$LIBPATH_ghostscript_dylib $LIB_DIR/ghostscript_${BUILDINGFOR}_dylib/libghostscript.dylib
    first=`echo $ARCHS | awk '{print $1;}'`
    
    if [ "$BUILDINGFOR" == "$first" ]; then
        echo "[|- CP include files (arch ref: $first)]"
        # copy the include files
        try cp -r $ghostscript_LIB_DIR/include/libghostscript*/ $LIB_DIR/include/ghostscript/
    fi
    echo "[|- CLEAN $BUILDINGFOR]"
    try make distclean
}

ghostscript () {
    echo "begin"
    echo "[+ ghostscript: $1]"
    cd $GS_DIR
    echo $GS_DIR
    LIBPATH_ghostscript=libghostscript16.a
    LIBPATH_ghostscript_dylib=libghostscript16.dylib
    
    if [ "$1" == "armv7" ] || [ "$1" == "armv7s" ] || [ "$1" == "arm64" ]; then
        save
        armflags $1
#        echo "1"
        echo "[|- CONFIG $BUILDINGFOR]"
        export CC="$(xcode-select -print-path)/usr/bin/gcc" # override clang
        try ./configure \
        --prefix=${PNG_LIB_DIR}_${BUILDINGFOR} \
        --enable-shared \
        --enable-static \
        --disable-cups  \
        --host=arm-apple-darwin
        ghostscript_compile
        restore
    elif [ "$1" == "i386" ] || [ "$1" == "x86_64" ]; then
        save
        intelflags $1
        echo "2"
        echo "[|- CONFIG $BUILDINGFOR]"
        export CC="$(xcode-select -print-path)/usr/bin/gcc" # override clang
        try ./configure \
        --prefix=${PNG_LIB_DIR}_${BUILDINGFOR} \
        --enable-shared \
        --enable-static \
        --host=${BUILDINGFOR}-apple-darwin
        ghostscript_compile
        restore
    else
        echo "[ERR: Nothing to do for $1]"
    fi
    
    joinlibs=$(check_for_archs $LIB_DIR/libghostscript.a)
    if [ $joinlibs == "OK" ]; then
        echo "[|- COMBINE $ARCHS]"
        accumul=""
        for i in $ARCHS; do
            accumul="$accumul -arch $i $LIB_DIR/libghostscript.a.$i"
        done
        # combine the static libraries
        try lipo $accumul -create -output $LIB_DIR/libghostscript.a
        echo "[+ DONE]"
    fi
}
