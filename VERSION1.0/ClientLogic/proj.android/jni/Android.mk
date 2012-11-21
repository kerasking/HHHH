LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := ClientLogic

LOCAL_MODULE_FILENAME := libClientLogic

LOCAL_SRC_FILES := \
../../BeforeGame/src/NDBeforeGameMgr.cpp \
../../BeforeGame/src/NDGameApplication.cpp \
../../BeforeGame/src/main.cpp \
../../Chat/src/ChatManager.cpp \
../../Common/src/GlobalDialog.cpp \
../../Common/src/NDUtility.cpp \
../../Drama/src/Drama.cpp \
../../Drama/src/DramaCommand.cpp \
../../Drama/src/DramaCommandBase.cpp \
../../Drama/src/DramaScene.cpp \
../../Drama/src/DramaTransitionScene.cpp \
../../Drama/src/DramaUI.cpp \
../../GameData/src/GameData.cpp \
../../GameData/src/GameDataBase.cpp \
../../GameScene/src/GameScene.cpp \
../../GameScene/src/SMBattleScene.cpp \
../../GameScene/src/SMGameScene.cpp \
../../GameScene/src/SMLoginScene.cpp \
../../GameScene/src/WorldMapScene.cpp \
../../Item/src/EnhancedObj.cpp \
../../Item/src/Item.cpp \
../../Item/src/ItemImage.cpp \
../../Item/src/ItemMgr.cpp \
../../Item/src/ItemUtil.cpp \
../../Item/src/NDItemType.cpp \
../../MapAndRole/src/AnimationList.cpp \
../../MapAndRole/src/AutoPathTip.cpp \
../../MapAndRole/src/NDBaseRole.cpp \
../../MapAndRole/src/NDManualRole.cpp \
../../MapAndRole/src/NDMapLayerLogic.cpp \
../../MapAndRole/src/NDMonster.cpp \
../../MapAndRole/src/NDNpc.cpp \
../../MapAndRole/src/NDPlayer.cpp \
../../Script/Src/ScriptCommon.cpp \
../../Script/Src/ScriptDataBase.cpp \
../../Script/Src/ScriptDrama.cpp \
../../Script/Src/ScriptGameData.cpp \
../../Script/Src/ScriptGameLogic.cpp \
../../Script/Src/ScriptGlobalEvent.cpp \
../../Script/Src/ScriptNetMsg.cpp \
../../Script/Src/ScriptTask.cpp \
../../Script/Src/ScriptTimer.cpp \
../../Script/Src/ScriptUI.cpp \
../../Pet/src/CPet.cpp \
../../Pet/src/CPetNode.cpp \
../../UICommon/src/UIEquipItem.cpp \
../../UICommon/src/UIItemButton.cpp \
../../UICommon/src/UINpcDlg.cpp \
../../UICommon/src/UIRoleNode.cpp \
../../UICommon/src/UITabLogic.cpp \
../../MsgDefine/src/NDNetMsg.cpp \
../../Syndicate/src/SyndicateCommon.cpp \
../../Task/src/Task.cpp \
../../Task/src/TaskData.cpp \
../../Task/src/TaskListener.cpp \
../../Module/src/NDMapMgr.cpp \
../../Module/Battle/src/Battle.cpp \
../../Module/Battle/src/BattleMgr.cpp \
../../Module/Battle/src/BattleSkill.cpp \
../../Module/Battle/src/BattleUtil.cpp \
../../Module/Battle/src/Fighter.cpp \
../../Module/Battle/src/Hurt.cpp \
../../Module/Battle/src/NDEraseInOutEffect.cpp \
../../Module/Battle/src/NDSubAniGroup.cpp \
../../Module/Battle/src/StatusDialog.cpp \
../../NewScene/NewChatScene.cpp \
../../System/src/SqliteDBMgr.cpp \
../../System/src/SystemSetMgr.cpp \
../../Common/src/NDDataPersist.cpp \
../../Module/src/TutorUILayer.cpp

LOCAL_C_INCLUDES := \
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
$(LOCAL_PATH)/../../BeforeGame/inc \
$(LOCAL_PATH)/../../Chat/inc \
$(LOCAL_PATH)/../../Common/inc \
$(LOCAL_PATH)/../../Drama/inc \
$(LOCAL_PATH)/../../GameData/inc \
$(LOCAL_PATH)/../../GameScene/inc \
$(LOCAL_PATH)/../../Item/inc \
$(LOCAL_PATH)/../../MapAndRole/inc \
$(LOCAL_PATH)/../../Module/inc \
$(LOCAL_PATH)/../../MsgDefine/inc \
$(LOCAL_PATH)/../../GameScene/inc \
$(LOCAL_PATH)/../../NewScene/UIPet \
$(LOCAL_PATH)/../../NewScene/ \
$(LOCAL_PATH)/../../Pet/inc \
$(LOCAL_PATH)/../../Script/inc \
$(LOCAL_PATH)/../../Syndicate/inc \
$(LOCAL_PATH)/../../NewScene/inc \
$(LOCAL_PATH)/../../System/inc \
$(LOCAL_PATH)/../../Task/inc \
$(LOCAL_PATH)/../../UICommon/inc \
$(LOCAL_PATH)/../../Module/Battle/inc \
$(LOCAL_PATH)/../../../cocos2d-x/cocos2dx/platform/third_party/win32 \
$(LOCAL_PATH)/../../../luaplus \
$(LOCAL_PATH)/../../../include/C3/win \
$(LOCAL_PATH)/../../../ClientLogic/MsgDefine/inc \
$(LOCAL_PATH)/../../../ClientLogic/Script/inc \
$(LOCAL_PATH)/../../../ClientLogic/GameScene/inc \
$(LOCAL_PATH)/../../../NetWork/inc

LOCAL_LDLIBS := -L$(call host-path, $(LOCAL_PATH)/../../proj.android/libs/$(TARGET_ARCH_ABI)) \
                -L$(call host-path, $(LOCAL_PATH)/../../../cocos2d-x/cocos2dx/platform/third_party/android/libraries/$(TARGET_ARCH_ABI))

LOCAL_WHOLE_STATIC_LIBRARIES += luaplus
LOCAL_WHOLE_STATIC_LIBRARIES += tinyxml
LOCAL_WHOLE_STATIC_LIBRARIES += NetWork
LOCAL_WHOLE_STATIC_LIBRARIES += ClientEngine

include $(BUILD_SHARED_LIBRARY)

$(call import-module,LuaPlus/proj.android/jni)
$(call import-module,tinyxml/proj.android/jni)
$(call import-module,NetWork/proj.android/jni)
$(call import-module,ClientEngine/proj.android/jni)