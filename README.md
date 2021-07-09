# imagemagick_lib_ios

imagemagick compile script.
thank you by [marforic](https://github.com/marforic/imagemagick_lib_iphone).
I changed the script, which is great for me.

If you can’t compile successfully, then I have compiled lib here, right here `IMPORT_ME`
this is imagemagick info:

```
Version: ImageMagick 7.1.0-3 Q8 arm 2021-06-25 https://imagemagick.org
Copyright: (C) 1999-2021 ImageMagick Studio LLC
License: https://imagemagick.org/script/license.php
Features: Cipher DPC HDRI 
Delegates (built-in): fontconfig freetype jng jpeg png xml zlib
```

#### Question
If you have encountered this problem:
```
ld: warning: ignoring file /usr/local/Cellar/openexr/3.0.3/lib/libOpenEXRUtil-3_0.dylib, building for iOS-arm64 but attempting to link with file built for macOS-x86_64
ld: warning: ignoring file /usr/local/Cellar/webp/1.2.0/lib/libwebpdemux.dylib, building for iOS-arm64 but attempting to link with file built for macOS-x86_64
ld: warning: ignoring file /usr/local/Cellar/webp/1.2.0/lib/libwebp.dylib, building for iOS-arm64 but attempting to link with file built for macOS-x86_64
ld: warning: ignoring file /usr/local/Cellar/openjpeg/2.4.0/lib/libopenjp2.dylib, building for iOS-arm64 but attempting to link with file built for macOS-x86_64
ld: warning: ignoring file /usr/local/Cellar/openexr/3.0.3/lib/libIlmThread-3_0.dylib, building for iOS-arm64 but attempting to link with file built for macOS-x86_64
ld: warning: ignoring file /usr/local/Cellar/openexr/3.0.3/lib/libIex-3_0.dylib, building for iOS-arm64 but attempting to link with file built for macOS-x86_64
ld: warning: ignoring file /usr/local/Cellar/imath/3.0.3/lib/libImath-3_0.dylib, building for iOS-arm64 but attempting to link with file built for macOS-x86_64
Undefined symbols for architecture arm64:
"_FcConfigDestroy", referenced from:
      _LoadFontConfigFonts in libMagickCore-7.Q8HDRI.a(libMagickCore_7_Q8HDRI_la-type.o)
  "_FcConfigGetCurrent", referenced from:
      _LoadFontConfigFonts in libMagickCore-7.Q8HDRI.a(libMagickCore_7_Q8HDRI_la-type.o)
  "_FcConfigSetRescanInterval", referenced from:
      _LoadFontConfigFonts in libMagickCore-7.Q8HDRI.a(libMagickCore_7_Q8HDRI_la-type.o)
...
  "_png_write_info", referenced from:
      _WriteOnePNGImage in libMagickCore-7.Q8HDRI.a(MagickCore_libMagickCore_7_Q8HDRI_la-png.o)
  "_png_write_info_before_PLTE", referenced from:
      _WriteOnePNGImage in libMagickCore-7.Q8HDRI.a(MagickCore_libMagickCore_7_Q8HDRI_la-png.o)
  "_png_write_row", referenced from:
      _WriteOnePNGImage in libMagickCore-7.Q8HDRI.a(MagickCore_libMagickCore_7_Q8HDRI_la-png.o)
ld: symbol(s) not found for architecture arm64
clang: error: linker command failed with exit code 1 (use -v to see invocation)
make[1]: *** [utilities/magick] Error 1
make: *** [all] Error 2

```
* you can remove local lib by brew 

```
brew uninstall --ignore-dependencies webp
```
or

* recompile the new library.
