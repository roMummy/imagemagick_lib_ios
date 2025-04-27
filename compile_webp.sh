#!/bin/bash

webp_compile() {
	echo "[|- MAKE $BUILDINGFOR]"
	try make -j$CORESNUM
	try make install
	echo "[|- CP STATIC/DYLIB $BUILDINGFOR]"
    
    mkdir -p $LIB_DIR/webp_${BUILDINGFOR}_dylib
    mkdir -p ${WEBP_LIB_DIR}_${BUILDINGFOR}/
    
	echo "1"
	try cp ${WEBP_LIB_DIR}_${BUILDINGFOR}/lib/$LIBPATH_WEBP $LIB_DIR/libwebp.a.$BUILDINGFOR
	try cp ${WEBP_LIB_DIR}_${BUILDINGFOR}/lib/$LIBPATH_WEBP_dylib $LIB_DIR/webp_${BUILDINGFOR}_dylib/libwebp.dylib
	
	echo "2"
	try cp ${WEBP_LIB_DIR}_${BUILDINGFOR}/lib/$DECLIBLIST $LIB_DIR/libwebpdecoder.a.$BUILDINGFOR

	echo "3"
	try cp ${WEBP_LIB_DIR}_${BUILDINGFOR}/lib/$MUXLIBLIST $LIB_DIR/libwebpmux.a.$BUILDINGFOR
	try cp ${WEBP_LIB_DIR}_${BUILDINGFOR}/lib/$MUXLIBLIST_dylib $LIB_DIR/webp_${BUILDINGFOR}_dylib/libwebpmux.dylib

	echo "4"
	try cp ${WEBP_LIB_DIR}_${BUILDINGFOR}/lib/$DEMUXLIBLIST $LIB_DIR/libwebpdemux.a.$BUILDINGFOR
	try cp ${WEBP_LIB_DIR}_${BUILDINGFOR}/lib/$DEMUXLIBLIST_dylib $LIB_DIR/webp_${BUILDINGFOR}_dylib/libwebpdemux.dylib

	echo "5"
	try cp ${WEBP_LIB_DIR}_${BUILDINGFOR}/lib/$SHARPYUV $LIB_DIR/libsharpyuv.a.$BUILDINGFOR
	try cp ${WEBP_LIB_DIR}_${BUILDINGFOR}/lib/$sharpyuv_dylib $LIB_DIR/webp_${BUILDINGFOR}_dylib/libsharpyuv.dylib
	echo "6"
    
	first=`echo $ARCHS | awk '{print $1;}'`
    
	if [ "$BUILDINGFOR" == "$first" ]; then
		echo "[|- CP include files (arch ref: $first)]"
		# copy the include files
		try cp -r ${WEBP_LIB_DIR}_${BUILDINGFOR}/include/webp/ $LIB_DIR/include/webp/
	fi
	echo "[|- CLEAN $BUILDINGFOR]"
	try make distclean
}

webp () {
	echo "[+ webp: $1]"
	cd $WEBP_DIR
	
	LIBPATH_WEBP=libwebp.a
	LIBPATH_WEBP_dylib=libwebp.7.dylib

	DECLIBLIST=libwebpdecoder.a
	# DECLIBLIST_dylib=libwebpdecoder.a

  	MUXLIBLIST=libwebpmux.a
	MUXLIBLIST_dylib=libwebpmux.3.dylib

  	DEMUXLIBLIST=libwebpdemux.a
	DEMUXLIBLIST_dylib=libwebpdemux.2.dylib

	SHARPYUV=libsharpyuv.a
	sharpyuv_dylib=libsharpyuv.0.dylib
	

    
	
	if [ "$1" == "armv7" ] || [ "$1" == "armv7s" ] || [ "$1" == "arm64" ]; then
		save
		armflags $1
#        echo "1"
		echo "[|- CONFIG $BUILDINGFOR]"
		export CC="$(xcode-select -print-path)/usr/bin/gcc" # override clang
#        echo $CC
        
		# try ./configure prefix=${WEBP_LIB_DIR}_${BUILDINGFOR} \
		# --enable-shared \
		# --enable-static \
		# --host=${BUILDINGFOR}-apple-darwin
		try ./configure \
		--prefix=${WEBP_LIB_DIR}_${BUILDINGFOR} \
		--enable-shared \
		--enable-static \
    	--enable-libwebpdecoder --enable-swap-16bit-csp \
    	--enable-libwebpmux \
		--host=${BUILDINGFOR}-apple-darwin 
#        echo "111"
        webp_compile
		restore
	elif [ "$1" == "i386" ] || [ "$1" == "x86_64" ]; then
		save
		intelflags $1
        echo "2"
		# try make distclean
		echo "[|- CONFIG $BUILDINGFOR]"
		export CC="$(xcode-select -print-path)/usr/bin/gcc" # override clang
		
		try ./configure \
		--prefix=${WEBP_LIB_DIR}_${BUILDINGFOR} \
    	--enable-shared \
		--enable-static \
    	--enable-libwebpdecoder --enable-swap-16bit-csp \
    	--enable-libwebpmux \
		--host=${BUILDINGFOR}-apple-darwin 

		# try ./configure prefix=${WEBP_LIB_DIR}_${BUILDINGFOR} --enable-shared --enable-static --host=${BUILDINGFOR}-apple-darwin
		webp_compile
		restore
	else
		echo "[ERR: Nothing to do for $1]"
	fi
	
	combine_libs "libwebp"
	combine_libs "libwebpdecoder"
	combine_libs "libwebpmux"
	combine_libs "libwebpdemux"
	combine_libs "libsharpyuv"
}

combine_libs() {
    local lib_name=$1
    joinlibs=$(check_for_archs $LIB_DIR/$lib_name.a)
    if [ $joinlibs == "OK" ]; then
        echo "[|- COMBINE $ARCHS]"
        accumul=""
        for i in $ARCHS; do
            accumul="$accumul -arch $i $LIB_DIR/$lib_name.a.$i"
        done
        # combine the static libraries
        try lipo $accumul -create -output $LIB_DIR/$lib_name.a
        echo "[+ DONE]"
    fi
}