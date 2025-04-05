curl -s https://raw.githubusercontent.com/pytgcalls/build-toolkit/refs/heads/master/build-toolkit.sh > build-toolkit.sh
source build-toolkit.sh

try_setup_msvc
try_setup_xcode

FFMPEG_VERSION=$(get_version "ffmpeg")

build_and_install "https://github.com/FFmpeg/FFmpeg.git" "n$FFMPEG_VERSION" configure-static --linux="--target-os=linux" \
  --macos="--enable-cross-compile --target-os=darwin" --windows="--toolchain=msvc --target-os=win64" --arch="$OS_ARCH" \
  --linux-macos="--extra-cflags=\"-DLIBTWOLAME_STATIC\" --extra-ldflags=\"-pthread\"" --disable-programs --disable-doc \
  --disable-network --disable-everything --enable-protocol=file --enable-decoder=h264 --enable-parser=h264 --enable-demuxer=h264 \
  --enable-muxer=mp4 --disable-dxva2 --disable-asm --prefix="$(pwd)/FFmpeg/build/"

mkdir -p artifacts/lib
mkdir -p artifacts/include
cp FFmpeg/build/lib/libavcodec.a artifacts/lib/"$(os_lib_format static avcodec)"
cp FFmpeg/build/lib/libavformat.a artifacts/lib/"$(os_lib_format static avformat)"
cp FFmpeg/build/lib/libavutil.a artifacts/lib/"$(os_lib_format static avutil)"
cp -r FFmpeg/build/include/libavcodec artifacts/include/
cp -r FFmpeg/build/include/libavutil artifacts/include/
cp -r FFmpeg/build/include/libavformat artifacts/include/