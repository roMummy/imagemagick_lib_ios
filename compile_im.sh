#!/bin/bash

im_compile() {
	echo "[|- MAKE $BUILDINGFOR]"
	try make -j$CORESNUM
	try make install
	echo "[|- CP STATIC/DYLIB $BUILDINGFOR]"
	cp $LIBPATH_core $LIB_DIR/$LIBNAME_core.$BUILDINGFOR
	cp $LIBPATH_wand $LIB_DIR/$LIBNAME_wand.$BUILDINGFOR
	cp $LIBPATH_magickpp $LIB_DIR/$LIBNAME_magickpp.$BUILDINGFOR
	if [ "$BUILDINGFOR" == "arm64" ]; then  # copy include and config files
		# copy the wand/ + core/ headers
		cp -r $IM_LIB_DIR/include/ImageMagick-*/MagickCore/ $LIB_DIR/include/magick/
		cp -r $IM_LIB_DIR/include/ImageMagick-*/MagickWand/ $LIB_DIR/include/wand/
		cp -r $IM_LIB_DIR/include/ImageMagick-*/magick++/ $LIB_DIR/include/magick++/
		cp -r $IM_LIB_DIR/include/ImageMagick-*/Magick++.h $LIB_DIR/include/Magick++.h

		# copy configuration files needed for certain functions
		cp -r $IM_LIB_DIR/etc/ImageMagick-*/ $LIB_DIR/include/im_config/
		cp -r $IM_LIB_DIR/share/ImageMagick-*/ $LIB_DIR/include/im_config/
	fi
	echo "[|- CLEAN $BUILDINGFOR]"
	try make distclean
}

im () {
	echo "[+ IM: $1]"
	cd $IM_DIR
	
	# static library that will be generated
	LIBPATH_core=$IM_LIB_DIR/lib/libMagickCore-7.Q8HDRI.a
	LIBNAME_core=`basename $LIBPATH_core`
	LIBPATH_wand=$IM_LIB_DIR/lib/libMagickWand-7.Q8HDRI.a
	LIBNAME_wand=`basename $LIBPATH_wand`
	LIBPATH_magickpp=$IM_LIB_DIR/lib/libMagick++-7.Q8HDRI.a
	LIBNAME_magickpp=`basename $LIBPATH_magickpp`
	
	if [ "$1" == "armv7" ] || [ "$1" == "armv7s" ] || [ "$1" == "arm64" ]; then
		save
		armflags $1
        
        export PKG_CONFIG_PATH="${PNG_LIB_DIR}_${BUILDINGFOR}/lib/pkgconfig/:${FREETYPE_LIB_DIR}_${BUILDINGFOR}/lib/pkgconfig/:${FONTCONFIG_LIB_DIR}_${BUILDINGFOR}/lib/pkgconfig/:$PKG_CONFIG_PATH"
       
        
		export CC="$(xcode-select -print-path)/usr/bin/gcc" # override clang
		export CPPFLAGS="-I$LIB_DIR/include/jpeg -I$LIB_DIR/include/png  -I$LIB_DIR/include/webp -I$LIB_DIR/include/raw -I$IM_LIB_DIR/include/ImageMagick-7 -I$LIB_DIR/include/fontconfig"
        
        export CFLAGS="$CFLAGS -DTARGET_OS_IPHONE "
        
		export LDFLAGS="$LDFLAGS -L$LIB_DIR/jpeg_${BUILDINGFOR}_dylib/ -L${LIB_DIR}/png_${BUILDINGFOR}_dylib/   -L$LIB_DIR/webp_${BUILDINGFOR}_dylib/ -L$LIB_DIR/raw_${BUILDINGFOR}_dylib/ -L$LIB_DIR/fontconfig_${BUILDINGFOR}_dylib/  -L$LIB_DIR "
       
        
		echo "[|- CONFIG $BUILDINGFOR]"
        
		try ./configure prefix=$IM_LIB_DIR  \
            --host=arm-apple-darwin \
			--disable-opencl \
            --disable-largefile \
            --with-quantum-depth=8 \
            --with-magick-plus-plus \
            --with-png \
            --with-freetype \
            --with-fontconfig \
			--without-perl \
            --without-x \
            --disable-shared \
            --disable-openmp \
            --without-bzlib \
            --without-openexr \
            --without-lcms \
            --without-webp \
            --without-lzma \
            --without-openjp2
            
            
		im_compile
		restore
	elif [ "$1" == "i386" ] || [ "$1" == "x86_64" ]; then
        echo "x86"
		save
		intelflags $1
		export CPPFLAGS="$CPPFLAGS -I$LIB_DIR/include/jpeg -I$LIB_DIR/include/png -I$LIB_DIR/include/tiff -I$LIB_DIR/include/webp -I$LIB_DIR/include/raw/ -I$SIMSDKROOT/usr/include"
		export LDFLAGS="$LDFLAGS -L$LIB_DIR/jpeg_${BUILDINGFOR}_dylib/ -L$LIB_DIR/png_${BUILDINGFOR}_dylib/ -L$LIB_DIR/tiff_${BUILDINGFOR}_dylib/ -L$LIB_DIR/webp_${BUILDINGFOR}_dylib/ -L$LIB_DIR/raw_${BUILDINGFOR}_dylib/ -L$LIB_DIR"
		echo "[|- CONFIG $BUILDINGFOR]"
		try ./configure prefix=$IM_LIB_DIR \
            --disable-opencl \
			--disable-largefile \
            --with-quantum-depth=8 \
            --with-magick-plus-plus \
            --with-freetype \
            --with-png \
            --without-perl \
            --without-x \
			--disable-shared \
            --disable-openmp \
            --without-bzlib \
            --without-threads \
            --disable-dependency-tracking \
            --host=${BUILDINGFOR}-apple-darwin
            
		im_compile
		restore
	else
		echo "[ERR: Nothing to do for $1]"
	fi
	
	# join libMagickCore
	joinlibs=$(check_for_archs $LIB_DIR/$LIBNAME_core)
	if [ $joinlibs == "OK" ]; then
		echo "[|- COMBINE $ARCHS]"
		accumul=""
		for i in $ARCHS; do
			accumul="$accumul -arch $i $LIB_DIR/$LIBNAME_core.$i"
		done
		# combine the static libraries
		try lipo $accumul -create -output $LIB_DIR/libMagickCore.a
		echo "[+ DONE]"
	fi

	# join libMacigkWand
	joinlibs=$(check_for_archs $LIB_DIR/$LIBNAME_wand)
	if [ $joinlibs == "OK" ]; then
		echo "[|- COMBINE $ARCHS]"
		accumul=""
		for i in $ARCHS; do
			accumul="$accumul -arch $i $LIB_DIR/$LIBNAME_wand.$i"
		done
		# combine the static libraries
		try lipo $accumul -create -output $LIB_DIR/libMagickWand.a
		echo "[+ DONE]"
	fi

	# join libMagick++
	joinlibs=$(check_for_archs $LIB_DIR/$LIBNAME_magickpp)
	if [ $joinlibs == "OK" ]; then
		echo "[|- COMBINE $ARCHS]"
		accumul=""
		for i in $ARCHS; do
			accumul="$accumul -arch $i $LIB_DIR/$LIBNAME_magickpp.$i"
		done
		# combine the static libraries
		try lipo $accumul -create -output $LIB_DIR/libMagick++.a
		echo "[+ DONE]"
	fi
}
