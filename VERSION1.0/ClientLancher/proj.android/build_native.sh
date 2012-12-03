# set params
NDK_ROOT_LOCAL=/cygdrive/d/android-ndk-r8b
COCOS2DX_ROOT_LOCAL=/cygdrive/d/work/client/VERSION1.0/cocos2d-x
CLIENT_LOCAL=/cygdrive/d/work/client/VERSION1.0/

buildexternalsfromsource=

usage(){
cat << EOF
usage: $0 [options]

Build C/C++ native code using Android NDK

OPTIONS:
   -s	Build externals from source
   -h	this help
EOF
}

while getopts "s" OPTION; do
	case "$OPTION" in
		s)
			buildexternalsfromsource=1
			;;
		h)
			usage
			exit 0
			;;
	esac
done

# try to get global variable

HELLOWORLD_ROOT=/cygdrive/d/work/client/VERSION1.0/ClientLancher/proj.android

# make sure assets is exist
if [ -d $HELLOWORLD_ROOT/assets ]; then
    rm -rf $HELLOWORLD_ROOT/assets
fi

mkdir $HELLOWORLD_ROOT/assets
mkdir $HELLOWORLD_ROOT/assets/SimplifiedChineseRes



if [[ $buildexternalsfromsource ]]; then
    echo "Building external dependencies from source"
    $NDK_ROOT_LOCAL/ndk-build -C $HELLOWORLD_ROOT $* \
        NDK_MODULE_PATH=${CLIENT_LOCAL}:${COCOS2DX_ROOT_LOCAL}:${COCOS2DX_ROOT_LOCAL}/cocos2dx/platform/third_party/android/source
else
    echo "Using prebuilt externals"
    $NDK_ROOT_LOCAL/ndk-build -C $HELLOWORLD_ROOT $* \
        NDK_MODULE_PATH=${CLIENT_LOCAL}:${COCOS2DX_ROOT_LOCAL}:${COCOS2DX_ROOT_LOCAL}/cocos2dx/platform/third_party/android/prebuilt
fi
