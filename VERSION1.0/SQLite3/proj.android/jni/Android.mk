LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := Sqlite3

LOCAL_MODULE_FILENAME := libSqlite3

LOCAL_SRC_FILES := \
../../src/sqlite3.c

LOCAL_C_INCLUDES := \
$(LOCAL_PATH)/../../inc

include $(BUILD_STATIC_LIBRARY)
