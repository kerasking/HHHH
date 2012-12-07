LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := KUtil

LOCAL_MODULE_FILENAME := libKUtil

LOCAL_SRC_FILES := \
../../KBase64.cpp \
../../KDirectory.cpp \
../../KHttp.cpp \
../../KTcpServerSocket.cpp \
../../KUdpStack.cpp \
../../KCondition.cpp \
../../KFile.cpp \
../../KIniFile.cpp \
../../cpLog.cpp \
../../KFtpClient.cpp \
../../KMD5.cpp \
../../KTimeVal.cpp 


LOCAL_C_INCLUDES := \
$(LOCAL_PATH)/../.. \
$(LOCAL_PATH)/../../../cocos2d-x/cocos2dx/platform \
$(LOCAL_PATH)/../../../NetWork/inc

include $(BUILD_STATIC_LIBRARY)

