#!/bin/bash

expat_compile() {
	echo "[|- MAKE $BUILDINGFOR]"
	try make -j$CORESNUM
	try make install
	echo "[|- CP STATIC/DYLIB $BUILDINGFOR]"
    mkdir -p $LIB_DIR/expat_${BUILDINGFOR}_dylib/
 
	try cp ${EXPAT_LIB_DIR}_${BUILDINGFOR}/lib/$LIBPATH_expat $LIB_DIR/libexpat.a.$BUILDINGFOR
	try cp ${EXPAT_LIB_DIR}_${BUILDINGFOR}/lib/$LIBPATH_expat_dylib $LIB_DIR/expat_${BUILDINGFOR}_dylib/libexpat.dylib
	first=`echo $ARCHS | awk '{print $1;}'`
    
	if [ "$BUILDINGFOR" == "$first" ]; then
		echo "[|- CP include files (arch ref: $first)]"
		# copy the include files
		try cp -r ${EXPAT_LIB_DIR}_${BUILDINGFOR}/include/expat* $LIB_DIR/include/expat/
	fi
	echo "[|- CLEAN $BUILDINGFOR]"
	try make distclean
}

expat () {
	echo "[+ expat: $1]"
	cd $EXPAT_DIR
	
	LIBPATH_expat=libexpat.a
	LIBPATH_expat_dylib=libexpat.dylib
	
	if [ "$1" == "armv7" ] || [ "$1" == "armv7s" ] || [ "$1" == "arm64" ]; then
		save
		armflags $1
#        echo "1"
		echo "[|- CONFIG $BUILDINGFOR]"
		export CC="$(xcode-select -print-path)/usr/bin/gcc" # override clang
#        export PKG_CONFIG_PATH="${FREETYPE_LIB_DIR}_${BUILDINGFOR}/lib/pkgconfig/:$PKG_CONFIG_PATH"
#        echo $PKG_CONFIG_PATH
        
		try ./configure \
        --prefix=${EXPAT_LIB_DIR}_${BUILDINGFOR} \
		--enable-shared \
		--enable-static \
        --host=aarch64-apple-darwin
        # --with-pic \
        # --without-docbook \
        # --without-xmlwf \
        # --enable-static \
        # --disable-shared \
        # --disable-fast-install \
        # --host=${BUILDINGFOR}-apple-darwin
#        echo "111"
		expat_compile
		restore
	elif [ "$1" == "i386" ] || [ "$1" == "x86_64" ]; then
		save
		intelflags $1
        echo "2"
		echo "[|- CONFIG $BUILDINGFOR]"
		export CC="$(xcode-select -print-path)/usr/bin/gcc" # override clang
		try ./configure \
		--prefix=${EXPAT_LIB_DIR}_${BUILDINGFOR} \
		--enable-shared \
		--enable-static \
		--host=${BUILDINGFOR}-apple-darwin

		expat_compile
		restore
	else
		echo "[ERR: Nothing to do for $1]"
	fi
	
	joinlibs=$(check_for_archs $LIB_DIR/libexpat.a)
	if [ $joinlibs == "OK" ]; then
		echo "[|- COMBINE $ARCHS]"
		accumul=""
		for i in $ARCHS; do
			accumul="$accumul -arch $i $LIB_DIR/libexpat.a.$i"
		done
		# combine the static libraries
		try lipo $accumul -create -output $LIB_DIR/libexpat.a
		echo "[+ DONE]"
	fi
}
