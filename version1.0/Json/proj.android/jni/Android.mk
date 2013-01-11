LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := Json

LOCAL_MODULE_FILENAME := libJson

LOCAL_SRC_FILES := \
../../src/json_internalarray.inl \
../../src/json_internalmap.inl \
../../src/json_reader.cpp \
../../src/json_valueiterator.inl \
../../src/json_value.cpp \
../../src/json_writer.cpp

LOCAL_C_INCLUDES := \
$(LOCAL_PATH)/../../inc

include $(BUILD_STATIC_LIBRARY)
