LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := NDUtility

LOCAL_MODULE_FILENAME := libNDUtility

LOCAL_SRC_FILES := \
../../src/Des.cpp \
../../src/MD5checksum.cpp \
../../src/NDConsole.cpp \
../../src/NDString.cpp \
../../src/NDUtil.cpp \
../../src/TQPlatform.cpp \
../../src/WjcDes.cpp \
../../src/XMLReader.cpp \
../../src/NDClassFactory.cpp


LOCAL_C_INCLUDES := \
$(LOCAL_PATH)/../../inc \
$(LOCAL_PATH)/../../../cocos2d-x/cocos2dx/platform/third_party/win32 \
$(LOCAL_PATH)/../../../cocos2d-x/cocos2dx/include \
$(LOCAL_PATH)/../../../cocos2d-x/cocos2dx \
$(LOCAL_PATH)/../../../cocos2d-x/cocos2dx/platform/android \
$(LOCAL_PATH)/../../../cocos2d-x/cocos2dx/kazmath/include \
$(LOCAL_PATH)/../../../cocos2d-x/cocos2dx/platform \
$(LOCAL_PATH)/../../../cocos2d-x/cocos2dx/cocoa \
$(LOCAL_PATH)/../../../cocos2d-x/cocos2dx/base_nodes \
$(LOCAL_PATH)/../../../cocos2d-x/cocos2dx/touch_dispatcher \
$(LOCAL_PATH)/../../../cocos2d-x/cocos2dx/layers_scenes_transitions_nodes \
$(LOCAL_PATH)/../../../cocos2d-x/cocos2dx/label_nodes \
$(LOCAL_PATH)/../../../cocos2d-x/cocos2dx/actions \
$(LOCAL_PATH)/../../../cocos2d-x/cocos2dx/effects \
$(LOCAL_PATH)/../../../cocos2d-x/cocos2dx/keypad_dispatcher \
$(LOCAL_PATH)/../../../cocos2d-x/cocos2dx/label_nodes \
$(LOCAL_PATH)/../../../cocos2d-x/cocos2dx/misc_nodes \
$(LOCAL_PATH)/../../../cocos2d-x/cocos2dx/menu_nodes \
$(LOCAL_PATH)/../../../cocos2d-x/cocos2dx/particle_nodes \
$(LOCAL_PATH)/../../../cocos2d-x/cocos2dx/shaders \
$(LOCAL_PATH)/../../../cocos2d-x/cocos2dx/sprite_nodes \
$(LOCAL_PATH)/../../../cocos2d-x/cocos2dx/support \
$(LOCAL_PATH)/../../../cocos2d-x/cocos2dx/text_input_node \
$(LOCAL_PATH)/../../../cocos2d-x/cocos2dx/textures \
$(LOCAL_PATH)/../../../cocos2d-x/cocos2dx/tileMap_parallax_nodes \
$(LOCAL_PATH)/../../../cocos2d-x/libpng \
$(LOCAL_PATH)/../../../tinyxml/inc

include $(BUILD_STATIC_LIBRARY)

