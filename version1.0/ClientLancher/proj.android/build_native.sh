# set params
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
NDK_ROOT_LOCAL=/cygdrive/d/android-ndk-r8b
COCOS2DX_ROOT_LOCAL="$DIR/../../cocos2d-x"
CLIENT_LOCAL="$DIR/../.."

echo "NDK_ROOT_LOCAL = $NDK_ROOT_LOCAL"
echo "COCOS2DX_ROOT_LOCAL = $COCOS2DX_ROOT_LOCAL"
echo "CLIENT_LOCAL = $CLIENT_LOCAL"

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
if [ $NDK_ROOT"aaa" != "aaa" ]; then
echo "use global definition of NDK_ROOT: $NDK_ROOT"
NDK_ROOT_LOCAL=$NDK_ROOT
fi

if [ $COCOS2DX_ROOT"aaa" != "aaa" ]; then
echo "use global definition of COCOS2DX_ROOT: $COCOS2DX_ROOT"
COCOS2DX_ROOT_LOCAL=$COCOS2DX_ROOT
fi

#HELLOWORLD_ROOT=/cygdrive/e/work/dhsgclient-x/VERSION1.0/ClientLancher/proj.android
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
COCOS2DX_ROOT="$DIR/../../cocos2d-x/cocos2dx"
HELLOWORLD_ROOT="$DIR"
CLIENT_LOCAL="$DIR/../../"
echo "NDK_ROOT = $NDK_ROOT"
echo "COCOS2DX_ROOT = $COCOS2DX_ROOT"
echo "APP_ANDROID_ROOT = $HELLOWORLD_ROOT"
RES_LOCAL="$HELLOWORLD_ROOT/../../Bin/copy"
echo "RES_PATH = $RES_LOCAL"


# make sure assets is exist
if [ -d $HELLOWORLD_ROOT/assets ]; then
    rm -rf $HELLOWORLD_ROOT/assets
fi

mkdir $HELLOWORLD_ROOT/assets
#mkdir $HELLOWORLD_ROOT/assets/SimplifiedChineseRes

if [[ $buildexternalsfromsource ]]; then
    echo "Building external dependencies from source"
    $NDK_ROOT_LOCAL/ndk-build -C $HELLOWORLD_ROOT $* \
        NDK_MODULE_PATH=${CLIENT_LOCAL}:${COCOS2DX_ROOT_LOCAL}:${COCOS2DX_ROOT_LOCAL}/cocos2dx/platform/third_party/android/source
else
    echo "Using prebuilt externals"
    $NDK_ROOT_LOCAL/ndk-build -C $HELLOWORLD_ROOT $* \
        NDK_MODULE_PATH=${CLIENT_LOCAL}:${COCOS2DX_ROOT_LOCAL}:${COCOS2DX_ROOT_LOCAL}/cocos2dx/platform/third_party/android/prebuilt
fi

cp libs/libmobage.so libs/armeabi/libmobage.so
#cp libs/LiSu.ttf assets/LiSu.ttf
