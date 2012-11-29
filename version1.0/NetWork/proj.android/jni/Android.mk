LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := NetWork

LOCAL_MODULE_FILENAME := libNetWork

LOCAL_SRC_FILES := \
../../src/Main.cpp \
../../src/Kathy.cpp \
../../src/KConnection.cpp \
../../src/KMutex.cpp \
../../src/KNetworkAddress.cpp \
../../src/KTcpClientSocket.cpp \
../../src/StringData.cpp

LOCAL_C_INCLUDES := \
$(LOCAL_PATH)/../../inc \
$(LOCAL_PATH)/../../../cocos2d-x/cocos2dx/platform

include $(BUILD_STATIC_LIBRARY)
