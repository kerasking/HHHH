LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := sqlite3

LOCAL_MODULE_FILENAME := sqlite3

LOCAL_SRC_FILES := \
../../src/sqlite3.c

LOCAL_C_INCLUDES := \
$(LOCAL_PATH)/../../inc

include $(BUILD_SHARED_LIBRARY)
