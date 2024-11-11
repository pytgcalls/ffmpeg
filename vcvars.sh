# vcvarsall.bat-like script for msys2 bash
vs_base_path="/c/Program Files/Microsoft Visual Studio"
windows_kits_base_path="/c/Program Files (x86)/Windows Kits/10"

get_vs_edition() {
    #get year and edition
    local vs_year=$(ls -1 "$vs_base_path" | grep -Eo '[0-9]{4}')
    #get latest year
    vs_year=$(echo "$vs_year" | sort -nr | head -n1)
    #new base path
    local vs_base_path="$vs_base_path/$vs_year"
    #get edition
    local vs_edition=$(ls -1 "$vs_base_path" | grep -Eo 'Community|Professional|Enterprise')
    #get the best edition in order enterprise, professional, community
    if [ -d "$vs_base_path/Enterprise" ]; then
        vs_edition="Enterprise"
    elif [ -d "$vs_base_path/Professional" ]; then
        vs_edition="Professional"
    elif [ -d "$vs_base_path/Community" ]; then
        vs_edition="Community"
    fi
    echo "$vs_year/$vs_edition"
}

get_msvc_version() {
    #get msvc version
    vs_edition=$1
    local msvc_version=$(ls -1 "$vs_base_path/$vs_edition/VC/Tools/MSVC" | grep -Eo '[0-9.]+')
    #get latest version
    msvc_version=$(echo "$msvc_version" | sort -nr | head -n1)
    echo "$msvc_version"
}

get_windows_kits_version() {
    #get windows kits version
    local windows_kits_version=$(ls -1 "$windows_kits_base_path/Include" | grep -Eo '[0-9.]+')
    #get latest version
    windows_kits_version=$(echo "$windows_kits_version" | sort -nr | head -n1)
    echo "$windows_kits_version"
}


vs_edition="$(get_vs_edition)"
msvc_version="$(get_msvc_version $vs_edition)"
windows_kits_version="$(get_windows_kits_version)"

export PATH="$vs_base_path/$vs_edition/VC/Tools/MSVC/$msvc_version/bin/Hostx64/x64:$PATH"
export LIB="$vs_base_path/$vs_edition/VC/Tools/MSVC/$msvc_version/lib/x64:$windows_kits_base_path/Lib/$windows_kits_version/um/x64:$windows_kits_base_path/Lib/$windows_kits_version/ucrt/x64"
export INCLUDE="$vs_base_path/$vs_edition/VC/Tools/MSVC/$msvc_version/include:$windows_kits_base_path/Include/$windows_kits_version/ucrt:$windows_kits_base_path/Include/$windows_kits_version/um:$windows_kits_base_path/Include/$windows_kits_version/shared"
echo "Correctly set env vars for Visual Studio $vs_edition, MSVC $msvc_version and Windows Kits $windows_kits_version"
