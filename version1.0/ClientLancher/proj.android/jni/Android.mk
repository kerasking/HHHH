LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := GameLauncher

LOCAL_MODULE_FILENAME := libGameLauncher

LOCAL_SRC_FILES := \
../../GameMain/GameMain.cpp

LOCAL_C_INCLUDES := \
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
$(LOCAL_PATH)/../../include \
$(LOCAL_PATH)/../../../KUtil \
$(LOCAL_PATH)/../../../ClientEngine/DataTrans/inc \
$(LOCAL_PATH)/../../../ClientEngine/Framework/inc \
$(LOCAL_PATH)/../../../ClientEngine/Graphic/inc \
$(LOCAL_PATH)/../../../ClientEngine/MapData/inc \
$(LOCAL_PATH)/../../../ClientEngine/Script/inc \
$(LOCAL_PATH)/../../../ClientEngine/System/inc \
$(LOCAL_PATH)/../../../ClientEngine/TempClass \
$(LOCAL_PATH)/../../../ClientEngine/UI/inc \
$(LOCAL_PATH)/../../../ClientEngine/Platform/inc \
$(LOCAL_PATH)/../../../ClientEngine/UI/import/inc \
$(LOCAL_PATH)/../../../ClientEngine/Utility/inc \
$(LOCAL_PATH)/../../../ClientLogic/BeforeGame/inc \
$(LOCAL_PATH)/../../../ClientLogic/Chat/inc \
$(LOCAL_PATH)/../../../ClientLogic/Common/inc \
$(LOCAL_PATH)/../../../ClientLogic/Drama/inc \
$(LOCAL_PATH)/../../../ClientLogic/GameScene/inc \
$(LOCAL_PATH)/../../../ClientLogic/Item/inc \
$(LOCAL_PATH)/../../../ClientLogic/MapAndRole/inc \
$(LOCAL_PATH)/../../../ClientLogic/Module/inc \
$(LOCAL_PATH)/../../../ClientLogic/MsgDefine/inc \
$(LOCAL_PATH)/../../../ClientLogic/GameScene/inc \
$(LOCAL_PATH)/../../../ClientLogic/NewScene/UIPet \
$(LOCAL_PATH)/../../../ClientLogic/NewScene/ \
$(LOCAL_PATH)/../../../ClientLogic/Pet/inc \
$(LOCAL_PATH)/../../../ClientLogic/Script/inc \
$(LOCAL_PATH)/../../../ClientLogic/Syndicate/inc \
$(LOCAL_PATH)/../../../ClientLogic/NewScene/inc \
$(LOCAL_PATH)/../../../ClientLogic/System/inc \
$(LOCAL_PATH)/../../../ClientLogic/Task/inc \
$(LOCAL_PATH)/../../../ClientLogic/UICommon/inc \
$(LOCAL_PATH)/../../../ClientLogic/Module/Battle/inc \
$(LOCAL_PATH)/../../../cocos2d-x/cocos2dx/platform/third_party/win32 \
$(LOCAL_PATH)/../../../luaplus \
$(LOCAL_PATH)/../../../include/C3/win \
$(LOCAL_PATH)/../../../ClientLogic/MsgDefine/inc \
$(LOCAL_PATH)/../../../ClientLogic/Script/inc \
$(LOCAL_PATH)/../../../ClientLogic/GameScene/inc \
$(LOCAL_PATH)/../../../NetWork/inc \
$(LOCAL_PATH)/../../../TinyXML/inc \
$(LOCAL_PATH)/../../../NDUtility/inc \
$(LOCAL_PATH)/../../../Sqlite3/inc


LOCAL_LDLIBS := -L$(call host-path, $(LOCAL_PATH)/../../proj.android/libs/$(TARGET_ARCH_ABI)) \
                -L$(call host-path, $(LOCAL_PATH)/../../../cocos2d-x/cocos2dx/platform/third_party/android/libraries/$(TARGET_ARCH_ABI))

LOCAL_WHOLE_STATIC_LIBRARIES += ClientLogic

include $(BUILD_SHARED_LIBRARY)

$(call import-module,ClientLogic/proj.android/jni)