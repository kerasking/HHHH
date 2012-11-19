LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := GameLauncher

LOCAL_MODULE_FILENAME := libGameLauncher

LOCAL_SRC_FILES := \
../../src/GameLauncher.cpp \
../../src/NDMonster.cpp \
../../src/NDManualRole.cpp \
../../src/NDBaseRole.cpp \
../../src/NDNpc.cpp \
../../src/AnimationList.cpp \
../../src/NDPlayer.cpp \
../../src/ScriptDataBase.cpp \
../../src/ScriptGameData.cpp \
../../src/AutoPathTip.cpp \
../../src/BattleMgr.cpp \
../../src/Battle.cpp \
../../src/NDEraseInOutEffect.cpp \
../../src/BattleSkill.cpp \
../../src/GameScene.cpp \
../../src/Fighter.cpp \
../../src/ItemMgr.cpp \
../../src/Item.cpp \
../../src/GlobalDialog.cpp \
../../src/BattleUtil.cpp \
../../src/CPet.cpp \
../../src/NDUtility.cpp \
../../src/Hurt.cpp \
../../src/ScriptGlobalEvent.cpp \
../../src/DramaScene.cpp \
../../src/Drama.cpp \
../../src/DramaCommand.cpp \
../../src/NDItemType.cpp \
../../src/DramaCommandBase.cpp \
../../src/SMBattleScene.cpp \
../../src/UIRoleNode.cpp \
../../src/ScriptGameLogic.cpp \
../../src/NDMapLayerLogic.cpp \
../../src/SMGameScene.cpp \
../../src/SMLoginScene.cpp \
../../src/WorldMapScene.cpp \
../../src/ScriptNetMsg.cpp

LOCAL_C_INCLUDES := \
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
$(LOCAL_PATH)/../../../ClientLogic/GameData/inc \
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
$(LOCAL_PATH)/../../../NetWork/inc

LOCAL_LDLIBS := -L$(call host-path, $(LOCAL_PATH)/../../proj.android/libs/$(TARGET_ARCH_ABI)) \
                -L$(call host-path, $(LOCAL_PATH)/../../../cocos2d-x/cocos2dx/platform/third_party/android/libraries/$(TARGET_ARCH_ABI))

LOCAL_WHOLE_STATIC_LIBRARIES := cocos2dx_static
LOCAL_WHOLE_STATIC_LIBRARIES += luaplus
LOCAL_WHOLE_STATIC_LIBRARIES += tinyxml
LOCAL_WHOLE_STATIC_LIBRARIES += NetWork
LOCAL_WHOLE_STATIC_LIBRARIES += ClientEngine

include $(BUILD_SHARED_LIBRARY)

$(call import-module,LuaPlus/proj.android/jni)
$(call import-module,cocos2dx)
$(call import-module,tinyxml/proj.android/jni)
$(call import-module,NetWork/proj.android/jni)
$(call import-module,ClientEngine/proj.android/jni)