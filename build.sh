source /dev/stdin <<< "$(curl -s https://raw.githubusercontent.com/pytgcalls/build-toolkit/refs/heads/master/build-toolkit.sh)"

require msvc
require xcode
require venv
require ndk

import patch-opus.sh
import libraries.properties
import libraries.properties from "github.com/pytgcalls/mesa"
import meson from python3
import ninja from python3

sysroot_dir="$BUILD_KIT_DIR/usr"

if is_linux; then
  build_and_install "libva" meson --prefix="$sysroot_dir"
  build_and_install "libvdpau" meson --prefix="$sysroot_dir"
fi

if is_linux || is_windows; then
  build_and_install "nv-codec-headers" make --prefix="$sysroot_dir"
fi

arch_builds=("default")

if is_android; then
  arch_builds=(
    "x86_64"
    "x86"
    "arm64-v8a"
    "armv7-a"
  )
fi

for arch in "${arch_builds[@]}"; do
  if is_windows; then
    build_and_install "opus" cmake -G "Visual Studio 17 2022" -A x64 -DCMAKE_INSTALL_PREFIX="$sysroot_dir"
  elif is_android; then
    build_and_install "opus" cmake -DCMAKE_TOOLCHAIN_FILE="$(android_tool toolchain)" \
        -DANDROID_ABI="$(normalize_arch "$arch" "fancy")" --setup-commands="patch_opus" --prefix="$sysroot_dir" \
        -DCMAKE_C_FLAGS="-O2 -fvisibility=hidden -ffunction-sections -fdata-sections -g -fno-omit-frame-pointer"
  else
    build_and_install "opus" configure --prefix="$sysroot_dir"
  fi
  build_and_install "FFmpeg" configure-static \
    --linux="--target-os=linux \
        --enable-vaapi \
        --enable-vdpau \
        --enable-libdrm \
        --enable-hwaccel=h264_vaapi \
        --enable-hwaccel=h264_vdpau \
        --enable-hwaccel=hevc_vaapi \
        --enable-hwaccel=hevc_vdpau \
        --enable-hwaccel=mpeg2_vaapi \
        --enable-hwaccel=mpeg2_vdpau \
        --enable-hwaccel=mpeg4_vaapi \
        --enable-hwaccel=mpeg4_vdpau \
        --extra-ldflags=-pthread" \
    --windows="--target-os=win64 \
        --toolchain=msvc" \
    --macos="--target-os=darwin \
        --enable-videotoolbox \
        --enable-hwaccel=h264_videotoolbox \
        --enable-hwaccel=hevc_videotoolbox \
        --extra-ldflags='-pthread -lbz2 -lz'" \
    --android="--target-os=android \
        --enable-cross-compile \
        --cc=$(android_tool cc "$arch") \
        --cxx=$(android_tool cxx "$arch") \
        --ar=$(android_tool ar) \
        --nm=$(android_tool nm) \
        --ranlib=$(android_tool ranlib) \
        --strip=$(android_tool strip) \
        --sysroot=$(android_tool sysroot) \
        --arch=$(normalize_arch "$arch") \
        --cpu=$(normalize_arch "$arch" "cpu") \
        --extra-ldflags='$(android_tool builtins "$arch") -nostdlib -lc -lm -ldl -pthread' \
        --disable-zlib" \
    --linux-windows="--enable-ffnvcodec \
        --enable-nvdec \
        --enable-cuvid \
        --enable-hwaccel=h264_nvdec \
        --enable-hwaccel=hevc_nvdec \
        --enable-hwaccel=mpeg2_nvdec \
        --enable-hwaccel=mpeg4_nvdec" \
    --linux-macos-android="--extra-cflags='-fvisibility=hidden -ffunction-sections -fdata-sections $(if is_macos; then echo -fno-common; fi) -g -fno-omit-frame-pointer -O2 -DCONFIG_LINUX_PERF=0'" \
    --disable-programs --disable-doc \
    --disable-network --disable-everything \
    --enable-runtime-cpudetect --enable-protocol=file \
    --enable-hwaccels --disable-dxva2 \
    --enable-libopus \
    --enable-decoder=h264 \
    --enable-decoder=mp3 \
    --enable-decoder=mp3adu \
    --enable-decoder=mp3adufloat \
    --enable-decoder=mp3float \
    --enable-decoder=mp3on4 \
    --enable-decoder=mp3on4float \
    --enable-decoder=mp1 \
    --enable-decoder=mp1float \
    --enable-decoder=mp2 \
    --enable-decoder=mp2float \
    --enable-decoder=mp3 \
    --enable-decoder=mp3adu \
    --enable-decoder=mp3adufloat \
    --enable-decoder=mp3float \
    --enable-decoder=mp3on4 \
    --enable-decoder=mp3on4float \
    --enable-decoder=mpeg4 \
    --enable-decoder=hevc \
    --enable-decoder=msmpeg4v2 \
    --enable-decoder=msmpeg4v3 \
    --enable-decoder=opus \
    --enable-decoder=pcm_alaw \
    --enable-decoder=pcm_f32be \
    --enable-decoder=pcm_f32le \
    --enable-decoder=pcm_f64be \
    --enable-decoder=pcm_f64le \
    --enable-decoder=pcm_lxf \
    --enable-decoder=pcm_mulaw \
    --enable-decoder=pcm_s16be \
    --enable-decoder=pcm_s16be_planar \
    --enable-decoder=pcm_s16le \
    --enable-decoder=pcm_s16le_planar \
    --enable-decoder=pcm_s24be \
    --enable-decoder=pcm_s24daud \
    --enable-decoder=pcm_s24le \
    --enable-decoder=pcm_s24le_planar \
    --enable-decoder=pcm_s32be \
    --enable-decoder=pcm_s32le \
    --enable-decoder=pcm_s32le_planar \
    --enable-decoder=pcm_s64be \
    --enable-decoder=pcm_s64le \
    --enable-decoder=pcm_s8 \
    --enable-decoder=pcm_s8_planar \
    --enable-decoder=pcm_u16be \
    --enable-decoder=pcm_u16le \
    --enable-decoder=pcm_u24be \
    --enable-decoder=pcm_u24le \
    --enable-decoder=pcm_u32be \
    --enable-decoder=pcm_u32le \
    --enable-decoder=pcm_u8 \
    --enable-decoder=pcm_zork \
    --enable-decoder=wavpack \
    --enable-decoder=wmalossless \
    --enable-decoder=wmapro \
    --enable-decoder=wmav1 \
    --enable-decoder=wmav2 \
    --enable-decoder=wmavoice \
    --enable-decoder=aac \
    --enable-decoder=aac_fixed \
    --enable-decoder=aac_latm \
    --enable-encoder=libopus \
    --enable-demuxer=h264 \
    --enable-demuxer=hevc \
    --enable-demuxer=matroska \
    --enable-demuxer=m4v \
    --enable-demuxer=mov \
    --enable-demuxer=mp3 \
    --enable-demuxer=ogg \
    --enable-demuxer=wav \
    --enable-demuxer=aac \
    --enable-muxer=ogg \
    --enable-muxer=opus \
    --enable-muxer=mp4 \
    --enable-parser=h264 \
    --enable-parser=hevc \
    --enable-parser=mpegaudio \
    --enable-parser=mpeg4video \
    --enable-parser=mpegaudio \
    --enable-parser=opus \
    --enable-parser=aac \
    --enable-parser=aac_latm

  if is_linux; then
    if [[ "$(uname -m)" == "x86_64" ]]; then
      convert_to_static "libva" "libva" "libva-drm" "libva-x11" --compiler="clang"
      copy_libs "libva" "artifacts" "libva" "libva-drm" "libva-x11"
    else
      convert_to_static "libva" "libva" "libva-drm" --compiler="clang"
      copy_libs "libva" "artifacts" "libva" "libva-drm"
    fi
    convert_to_static "libvdpau" --compiler="clang"
    copy_libs "libvdpau" "artifacts"
  fi

  copy_libs "FFmpeg" "artifacts" "avcodec" "avformat" "avutil" "swresample" --arch="$arch"
done