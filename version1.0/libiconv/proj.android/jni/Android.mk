LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := libiconv_static
LOCAL_MODULE_FILENAME := libiconv


LOCAL_SRC_FILES := \
../../libcharset/lib/localcharset.c \
../../lib/iconv.c \
../../lib/relocatable.c

LOCAL_C_INCLUDES += \
  $(LOCAL_PATH)/../.. \
  $(LOCAL_PATH)/../../include \
  $(LOCAL_PATH)/../../libcharset \
  $(LOCAL_PATH)/../../lib \
  $(LOCAL_PATH)/../../libcharset/include \
  $(LOCAL_PATH)/../../srclib
 
include $(BUILD_STATIC_LIBRARY)
