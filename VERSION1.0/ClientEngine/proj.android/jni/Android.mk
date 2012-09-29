LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := helloworld_shared

LOCAL_MODULE_FILENAME := libhelloworld

LOCAL_C_INCLUDES := \
$(LOCAL_PATH)/../../DataTrans/inc \
$(LOCAL_PATH)/../../Framework/inc \
$(LOCAL_PATH)/../../Graphic/inc \
$(LOCAL_PATH)/../../MapData/inc \
$(LOCAL_PATH)/../../Script/inc \
$(LOCAL_PATH)/../../System/inc \
$(LOCAL_PATH)/../../TempClass/inc \
$(LOCAL_PATH)/../../UI/inc \
$(LOCAL_PATH)/../../Utility/inc \
$(LOCAL_PATH)/../../../cocos2d-x/cocos2dx/platform/third_party/win32 \
$(LOCAL_PATH)/../../../luaplus

LOCAL_WHOLE_STATIC_LIBRARIES := cocos2dx_static

include $(BUILD_SHARED_LIBRARY)

$(call import-module,cocos2dx)
