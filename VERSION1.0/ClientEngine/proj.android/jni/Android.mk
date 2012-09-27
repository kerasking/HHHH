LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := GameEngine

LOCAL_MODULE_FILENAME := GameEngine

LOCAL_SRC_FILES := \
../../Framework/src/NDBaseDirector.cpp \
../../Framework/src/NDBaseLayer.cpp \
../../Framework/src/NDBaseNode.cpp \
../../Framework/src/NDCommonProtocol.cpp \
../../Framework/src/NDDirector.cpp \
../../Framework/src/NDLayer.cpp \
../../Framework/src/NDLightEffect.cpp \
../../Framework/src/NDMapLayer.cpp \
../../Framework/src/NDNode.cpp \
../../Framework/src/NDObject.cpp \
../../Framework/src/NDScene.cpp \
../../Framework/src/NDSprite.cpp \
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
../../System/src/NDDictionary.cpp \
../../System/src/NDLocalXmlString.cpp \
../../System/src/NDPath.cpp \
../../System/src/NDTimer.cpp \
../../System/src/NDTouch.cpp \
../../System/src/NDWideString.cpp \
../../System/src/SMString.cpp \
../../UI/src/NDScrollLayer.cpp \
../../UI/src/NDTextNode.cpp \
../../UI/src/NDUIBaseGraphics.cpp \
../../UI/src/NDUIButton.cpp \
../../UI/src/NDUICheckBox.cpp \
../../UI/src/NDUIDialog.cpp \
../../UI/src/NDUIImage.cpp \
../../UI/src/NDUILabel.cpp \
../../UI/src/NDUILayer.cpp \
../../UI/src/NDUINode.cpp \
../../UI/src/NDUIOptionButton.cpp \
../../UI/src/NDUIScrollText.cpp \
../../UI/src/NDUISynLayer.cpp \
../../UI/src/UIChatText.cpp \
../../UI/src/UICheckBox.cpp \
../../UI/src/UIDialog.cpp \
../../UI/src/UIExp.cpp \
../../UI/src/UIHyperlink.cpp \
../../UI/src/UIMovableLayer.cpp \
../../UI/src/UIRadioButton.cpp \
../../UI/src/UIScroll.cpp \
../../UI/src/UIScrollContainer.cpp \
../../UI/src/UIScrollView.cpp \
../../UI/src/UISpriteNode.cpp \
../../UI/import/src/IniFile.cpp \
../../UI/import/src/NDUILoad.cpp \
../../UI/import/src/UIData.cpp \
../../UI/src/UIEdit.cpp \
../../Utility/src/Des.cpp \
../../Utility/src/MD5checksum.cpp \
../../Utility/src/NDString.cpp \
../../Utility/src/platform.cpp \
../../Utility/src/WjcDes.cpp \
../../Utility/src/XMLReader.cpp \
../../Script/src/LuaStateMgr.cpp \
../../Script/src/ScriptMgr.cpp \
../../DataTrans/src/NDDataTransThread.cpp \
../../DataTrans/src/NDSocket.cpp \
../../DataTrans/src/NDTransData.cpp \
../../Utility/src/ImageNumber.cpp \
../../Utility/src/NDDataSource.cpp \
../../Utility/src/NDRidePet.cpp \
../../TempClass/NDUITableLayer.cpp

LOCAL_C_INCLUDES := \
$(LOCAL_PATH)/../../DataTrans/inc \
$(LOCAL_PATH)/../../Framework/inc \
$(LOCAL_PATH)/../../Graphic/inc \
$(LOCAL_PATH)/../../MapData/inc \
$(LOCAL_PATH)/../../Script/inc \
$(LOCAL_PATH)/../../System/inc \
$(LOCAL_PATH)/../../TempClass/inc \
$(LOCAL_PATH)/../../UI/inc \
$(LOCAL_PATH)/../../Utility/inc

LOCAL_WHOLE_STATIC_LIBRARIES := cocos2dx_static
LOCAL_WHOLE_STATIC_LIBRARIES += cocosdenshion_static

include $(BUILD_SHARED_LIBRARY)

$(call import-module,cocos2dx)
$(call import-module,CocosDenshion/android)