LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)
LOCAL_MODULE := GameEngine

LOCAL_SRC_FILES := \
ClientEngine/Framework/src/NDBaseNode.cpp \
ClientEngine/Framework/src/NDBaseLayer.cpp \
ClientEngine/Framework/src/NDBaseDirector.cpp \
ClientEngine/Framework/src/NDObject.cpp \
ClientEngine/Framework/src/NDDirector.cpp \
ClientEngine/Framework/src/NDLightEffect.cpp \
ClientEngine/Framework/src/NDMapLayer.cpp \
ClientEngine/Framework/src/NDNode.cpp \
ClientEngine/Framework/src/NDScene.cpp \
ClientEngine/Framework/src/NDSprite.cpp \

ClientEngine/System/src/AStar.cpp \
ClientEngine/System/src/cocos2dExt.cpp \
ClientEngine/System/src/JavaMethod.cpp \
ClientEngine/System/src/NDAutoPath.cpp \
ClientEngine/System/src/NDAutoPathNode.cpp \
ClientEngine/System/src/NDDictionary.cpp \
ClientEngine/System/src/NDLocalXmlString.cpp \
ClientEngine/System/src/NDPath.cpp \
ClientEngine/System/src/NDTimer.cpp \
ClientEngine/System/src/NDTouch.cpp \
ClientEngine/System/src/NDWideString.cpp \
ClientEngine/System/src/SMString.cpp


LOCAL_C_INCLUDES := $(LOCAL_PATH)/../../cocos2dx \
                    $(LOCAL_PATH)/../../cocos2dx/platform \
                    $(LOCAL_PATH)/../../cocos2dx/include \
                    $(LOCAL_PATH)/../../CocosDenshion/include \
                    $(LOCAL_PATH)/../../cocos2dx/lua_support 

LOCAL_LDLIBS := -L$(call host-path, $(LOCAL_PATH)/../android/libs/$(TARGET_ARCH_ABI)) \
                -lcocos2d -lcocosdenshion \
                -L$(call host-path, $(LOCAL_PATH)/../../cocos2dx/platform/third_party/android/libraries/$(TARGET_ARCH_ABI)) -lcurl
            
include $(BUILD_SHARED_LIBRARY)