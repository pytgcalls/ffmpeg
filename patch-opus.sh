function patch_opus() {
    while read -r file; do
      if [[ ! "${file}" =~ .*_gnu\.s$ ]]; then
        gnu_file="${file%.s}_gnu.s"
        ${ASM_CONVERTER} "${file}" > "${gnu_file}"
        perl -pi -e "s/-gnu\.S/_gnu\.s/g" "${gnu_file}"
        rm -f "${file}"
      fi
    done < <(find . -iname '*.s')

    sed \
      -e "s/@OPUS_ARM_MAY_HAVE_EDSP@/1/g" \
      -e "s/@OPUS_ARM_MAY_HAVE_MEDIA@/1/g" \
      -e "s/@OPUS_ARM_MAY_HAVE_NEON@/1/g" \
      celt/arm/armopts.s.in > celt/arm/armopts.s.temp
    ${ASM_CONVERTER} "celt/arm/armopts.s.temp" > "celt/arm/armopts_gnu.s"
    rm "celt/arm/armopts.s.temp"
}