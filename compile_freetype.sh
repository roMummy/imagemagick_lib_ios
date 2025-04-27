#!/bin/bash

freetype_compile() {
	echo "[|- MAKE $BUILDINGFOR]"
	try make -j$CORESNUM
	try make install
	echo "[|- CP STATIC/DYLIB $BUILDINGFOR]"
    mkdir -p $LIB_DIR/freetype_${BUILDINGFOR}_dylib/
    mkdir -p ${FREETYPE_LIB_DIR}_${BUILDINGFOR}/
 
	try cp ${FREETYPE_LIB_DIR}_${BUILDINGFOR}/lib/$LIBPATH_freetype $LIB_DIR/libfreetype.a.$BUILDINGFOR
	try cp ${FREETYPE_LIB_DIR}_${BUILDINGFOR}/lib/$LIBPATH_freetype_dylib  $LIB_DIR/freetype_${BUILDINGFOR}_dylib/libfreetype.dylib
   
   
	first=`echo $ARCHS | awk '{print $1;}'`
    
	if [ "$BUILDINGFOR" == "$first" ]; then
		echo "[|- CP include files (arch ref: $first)]"
		# copy the include files
		try cp -r ${FREETYPE_LIB_DIR}_${BUILDINGFOR}/include/freetype2/ $LIB_DIR/include/freetype/
	fi
	echo "[|- CLEAN $BUILDINGFOR]"
	try make distclean
}

freetype () {
	echo "[+ freetype: $1]"
	cd $FREETYPE_DIR
	
	LIBPATH_freetype=libfreetype.a
	LIBPATH_freetype_dylib=libfreetype.dylib
	
	if [ "$1" == "armv7" ] || [ "$1" == "armv7s" ] || [ "$1" == "arm64" ]; then
		save
		armflags $1
		echo "[|- CONFIG $BUILDINGFOR]"
    
        export PKG_CONFIG_PATH="${PNG_LIB_DIR}_${BUILDINGFOR}/lib/pkgconfig/:$PKG_CONFIG_PATH"
		export CC="$(xcode-select -print-path)/usr/bin/gcc" # override clang

		try ./configure \
        prefix=${FREETYPE_LIB_DIR}_${BUILDINGFOR} \
        --with-pic \
        --with-zlib \
        --with-png \
        --without-harfbuzz \
        --without-bzip2 \
        --without-fsref \
        --without-quickdraw-toolbox \
        --without-quickdraw-carbon \
        --without-ats \
        --enable-static \
        --enable-shared \
        --disable-fast-install \
        --disable-mmap \
        --host=${BUILDINGFOR}-apple-darwin
        
		freetype_compile
		restore
	elif [ "$1" == "i386" ] || [ "$1" == "x86_64" ]; then
		save
		intelflags $1
        echo "2"
		echo "[|- CONFIG $BUILDINGFOR]"
		export CC="$(xcode-select -print-path)/usr/bin/gcc" # override clang
		
		# 添加PKG_CONFIG_PATH环境变量，指向本地编译的libpng库
        export PKG_CONFIG_PATH="${PNG_LIB_DIR}_${BUILDINGFOR}/lib/pkgconfig/:$PKG_CONFIG_PATH"

        try ./configure \
        prefix=${FREETYPE_LIB_DIR}_${BUILDINGFOR} \
        --with-pic \
        --with-zlib \
        --with-png \
        --without-harfbuzz \
        --without-bzip2 \
        --without-fsref \
        --without-quickdraw-toolbox \
        --without-quickdraw-carbon \
        --without-ats \
        --enable-static \
        --enable-shared \
        --disable-fast-install \
        --disable-mmap \
        --host=${BUILDINGFOR}-apple-darwin
         
		freetype_compile
		restore
	else
		echo "[ERR: Nothing to do for $1]"
	fi
	
	joinlibs=$(check_for_archs $LIB_DIR/libfreetype.a)
	if [ $joinlibs == "OK" ]; then
		echo "[|- COMBINE $ARCHS]"
		accumul=""
		for i in $ARCHS; do
			accumul="$accumul -arch $i $LIB_DIR/libfreetype.a.$i"
		done
		# combine the static libraries
		try lipo $accumul -create -output $LIB_DIR/libfreetype.a
		echo "[+ DONE]"
	fi
}
