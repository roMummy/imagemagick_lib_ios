#!/bin/bash

fontconfig_compile() {
	echo "[|- MAKE $BUILDINGFOR]"
	try make -j$CORESNUM
	try make install
	echo "[|- CP STATIC/DYLIB $BUILDINGFOR]"
    mkdir -p $LIB_DIR/fontconfig_${BUILDINGFOR}_dylib/
 
	try cp ${FONTCONFIG_LIB_DIR}_${BUILDINGFOR}/lib/$LIBPATH_fontconfig $LIB_DIR/libfontconfig.a.$BUILDINGFOR
	try cp ${FONTCONFIG_LIB_DIR}_${BUILDINGFOR}/lib/$LIBPATH_fontconfig_dylib $LIB_DIR/fontconfig_${BUILDINGFOR}_dylib/libfontconfig.dylib
	first=`echo $ARCHS | awk '{print $1;}'`
    
	if [ "$BUILDINGFOR" == "$first" ]; then
		echo "[|- CP include files (arch ref: $first)]"
		# copy the include files
		try cp -r ${FONTCONFIG_LIB_DIR}_${BUILDINGFOR}/include/fontconfig*/ $LIB_DIR/include/fontconfig/
	fi
	echo "[|- CLEAN $BUILDINGFOR]"
	try make distclean
}

fontconfig () {
	echo "[+ fontconfig: $1]"
	cd $FONTCONFIG_DIR
	
	LIBPATH_fontconfig=libfontconfig.a
	LIBPATH_fontconfig_dylib=libfontconfig.dylib
	
	if [ "$1" == "armv7" ] || [ "$1" == "armv7s" ] || [ "$1" == "arm64" ]; then
		save
		armflags $1
#        echo "1"
		echo "[|- CONFIG $BUILDINGFOR]"
		export CC="$(xcode-select -print-path)/usr/bin/gcc" # override clang
        export PKG_CONFIG_PATH="${FREETYPE_LIB_DIR}_${BUILDINGFOR}/lib/pkgconfig/:$PKG_CONFIG_PATH"
#        echo $PKG_CONFIG_PATH
        
		try ./configure \
        --prefix=${FONTCONFIG_LIB_DIR}_${BUILDINGFOR} \
        --with-pic \
        --enable-static \
        --disable-shared \
        --disable-fast-install \
        --disable-rpath \
        --disable-libxml2 \
        --disable-docs \
        --disable-expat \
        --host=arm-apple-darwin
#        echo "111"
		fontconfig_compile
		restore
	elif [ "$1" == "i386" ] || [ "$1" == "x86_64" ]; then
		save
		intelflags $1
        echo "2"
		echo "[|- CONFIG $BUILDINGFOR]"
		try ./configure \
        --prefix=${FONTCONFIG_LIB_DIR}_${BUILDINGFOR} \
        --enable-shared \
        --enable-static \
        --host=${BUILDINGFOR}-apple-darwin
        
		fontconfig_compile
		restore
	else
		echo "[ERR: Nothing to do for $1]"
	fi
	
	joinlibs=$(check_for_archs $LIB_DIR/libfontconfig.a)
	if [ $joinlibs == "OK" ]; then
		echo "[|- COMBINE $ARCHS]"
		accumul=""
		for i in $ARCHS; do
			accumul="$accumul -arch $i $LIB_DIR/libfontconfig.a.$i"
		done
		# combine the static libraries
		try lipo $accumul -create -output $LIB_DIR/libfontconfig.a
		echo "[+ DONE]"
	fi
}
