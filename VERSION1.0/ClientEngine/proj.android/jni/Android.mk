LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := ClientEngine

LOCAL_MODULE_FILENAME := libClientEngine

LOCAL_SRC_FILES := \
../../main.cpp \
../../Framework/src/NDBaseDirector.cpp \
../../Framework/src/NDBaseLayer.cpp \
../../Framework/src/NDBaseNode.cpp \
../../Framework/src/NDCommonProtocol.cpp \
../../Framework/src/NDDebugOpt.cpp \
../../Framework/src/NDDirector.cpp \
../../Framework/src/NDLayer.cpp \
../../Framework/src/NDLightEffect.cpp \
../../Framework/src/NDMapLayer.cpp \
../../Framework/src/NDNode.cpp \
../../Framework/src/NDObject.cpp \
../../Framework/src/NDScene.cpp \
../../Framework/src/NDSprite.cpp \
../../Framework/src/UsePointPls.cpp \
../../Framework/src/NDBaseBattleMgr.cpp \
../../Framework/src/NDBaseNetMgr.cpp \
../../Framework/src/NDUIBaseItemButton.cpp \
../../Framework/src/NDBaseGlobalDialog.cpp \
../../Framework/src/NDBaseScriptMgr.cpp \
../../Update/src/DownloadPackage.cpp \
../../Update/src/Reachability.cpp \
../../Update/src/ZipUnzip.cpp \
../../Update/src/Unzip.cpp \
../../Graphic/src/CCTexture2DExt.cpp \
../../Graphic/src/CCTextureCacheExt.cpp \
../../Graphic/src/NDAnimation.cpp \
../../Graphic/src/NDAnimationGroup.cpp \
../../Graphic/src/NDAnimationGroupPool.cpp \
../../Graphic/src/NDColorPool.cpp \
../../Graphic/src/NDCombinePicture.cpp \
../../Graphic/src/NDFrame.cpp \
../../Graphic/src/NDPicture.cpp \
../../Graphic/src/NDTextureMonitor.cpp \
../../Graphic/src/NDTile.cpp \
../../Graphic/src/UIImageCombiner.cpp \
../../Graphic/src/UIImageExt.cpp \
../../MapData/src/NDMapData.cpp \
../../MapData/src/NDWorldMapData.cpp \
../../System/src/AStar.cpp \
../../System/src/cocos2dExt.cpp \
../../System/src/JavaMethod.cpp \
../../System/src/NDAutoPath.cpp \
../../System/src/NDClassFactory.cpp \
../../System/src/NDDictionary.cpp \
../../System/src/NDLocalXmlString.cpp \
../../System/src/NDPath.cpp \
../../System/src/NDTimer.cpp \
../../System/src/NDTouch.cpp \
../../System/src/NDWideString.cpp \
../../System/src/SMString.cpp \
../../UI/src/Analyst.cpp \
../../UI/src/HyperLinkLabel.cpp \
../../UI/src/NDScrollLayer.cpp \
../../UI/src/NDTextNode.cpp \
../../UI/src/NDUIBaseGraphics.cpp \
../../UI/src/NDUIButton.cpp \
../../UI/src/NDUICheckBox.cpp \
../../UI/src/NDUIDialog.cpp \
../../UI/src/NDUIEdit.cpp \
../../UI/src/NDUIFrame.cpp \
../../UI/src/NDUIImage.cpp \
../../UI/src/NDUILabel.cpp \
../../UI/src/NDUILayer.cpp \
../../UI/src/NDUINode.cpp \
../../UI/src/NDUIOptionButton.cpp \
../../UI/src/NDUIProgressBar.cpp \
../../UI/src/NDUIScrollContainer.cpp \
../../UI/src/NDUIScrollText.cpp \
../../UI/src/NDUIScrollViewContainer.cpp \
../../UI/src/NDUISynLayer.cpp \
../../UI/src/SysTimer.cpp \
../../UI/src/UIChatText.cpp \
../../UI/src/UICheckBox.cpp \
../../UI/src/UIDialog.cpp \
../../UI/src/UIExp.cpp \
../../UI/src/UIHyperlink.cpp \
../../UI/src/UIList.cpp \
../../UI/src/UIMovableLayer.cpp \
../../UI/src/UIRadioButton.cpp \
../../UI/src/UIScroll.cpp \
../../UI/src/UIScrollContainerExpand.cpp \
../../UI/src/UIScrollViewExpand.cpp \
../../UI/src/UIScrollViewMulHand.cpp \
../../UI/src/UISpriteNode.cpp \
../../UI/import/src/IniFile.cpp \
../../UI/import/src/NDUILoadEngine.cpp \
../../UI/import/src/UIData.cpp \
../../UI/src/UIEdit.cpp \
../../Utility/src/Des.cpp \
../../Utility/src/MD5checksum.cpp \
../../Utility/src/NDConsole.cpp \
../../Utility/src/NDString.cpp \
../../Utility/src/TQPlatform.cpp \
../../Utility/src/WjcDes.cpp \
../../Utility/src/XMLReader.cpp \
../../Utility/src/NDUtil.cpp \
../../Utility/src/NDVideoMgr.cpp \
../../Utility/src/NDVideoEventListener.cpp \
../../Script/src/LuaStateMgr.cpp \
../../Script/src/EngineScriptCommon.cpp \
../../DataTrans/src/NDDataTransThread.cpp \
../../DataTrans/src/NDMessageCenter.cpp \
../../DataTrans/src/NDSocket.cpp \
../../DataTrans/src/NDTransData.cpp \
../../Platform/src/IphoneInput.cpp \
../../Utility/src/ImageNumber.cpp \
../../Utility/src/NDDataSource.cpp \
../../Utility/src/NDRidePet.cpp \
../../TempClass/NDUITableLayer.cpp \
../../Performance.cpp

LOCAL_C_INCLUDES := \
$(LOCAL_PATH)/../../DataTrans/inc \
$(LOCAL_PATH)/../../Framework/inc \
$(LOCAL_PATH)/../../Update/inc \
$(LOCAL_PATH)/../../Graphic/inc \
$(LOCAL_PATH)/../../MapData/inc \
$(LOCAL_PATH)/../../Script/inc \
$(LOCAL_PATH)/../../System/inc \
$(LOCAL_PATH)/../../TempClass \
$(LOCAL_PATH)/../../UI/inc \
$(LOCAL_PATH)/../../Platform/inc \
$(LOCAL_PATH)/../../UI/import/inc \
$(LOCAL_PATH)/../../Utility/inc \
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
$(LOCAL_PATH)/../../../cocos2d-x/libpng \
$(LOCAL_PATH)/../../../luaplus \
$(LOCAL_PATH)/../../../tinyxml/inc \
$(LOCAL_PATH)/../../../include/C3/win \
$(LOCAL_PATH)/../../../ClientLogic/MsgDefine/inc \
$(LOCAL_PATH)/../../../ClientLogic/Script/inc \
$(LOCAL_PATH)/../../../ClientLogic/GameScene/inc \
$(LOCAL_PATH)/../../../NetWork/inc

LOCAL_LDLIBS := -L$(call host-path, $(LOCAL_PATH)/../../proj.android/libs/$(TARGET_ARCH_ABI)) \
                -L$(call host-path, $(LOCAL_PATH)/../../../cocos2d-x/cocos2dx/platform/third_party/android/libraries/$(TARGET_ARCH_ABI)) \
				-L$(SYSROOT)/usr/lib -lGLESv2
				
LOCAL_WHOLE_STATIC_LIBRARIES := cocos2dx_static
LOCAL_WHOLE_STATIC_LIBRARIES += luaplus
LOCAL_WHOLE_STATIC_LIBRARIES += tinyxml
LOCAL_WHOLE_STATIC_LIBRARIES += NetWork

include $(BUILD_SHARED_LIBRARY)

$(call import-module,LuaPlus/proj.android/jni)
$(call import-module,cocos2dx)
$(call import-module,tinyxml/proj.android/jni)
$(call import-module,NetWork/proj.android/jni)