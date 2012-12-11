/*
 *  ScriptDrama.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 12-1-10.
 *  Copyright 2012 (网龙)DeNA. All rights reserved.
 *
 */
#include "NDDirector.h"
#include "ScriptDrama.h"
#include "ScriptInc.h"
#include "DramaCommand.h"
#include "Drama.h"

namespace NDEngine {

// 脚本api

////////////////////////////////////////////////////////////////////////////////////
// 对话设置

// 函数: DramaOpenLChatDlg();
// 功能: 打开左边对话框

// 函数: DramaOpenRChatDlg();
// 功能: 打开右边对话框

// 函数: DramaCloseLChatDlg();
// 功能: 关闭对话框

// 函数: DramaCloseRChatDlg();
// 功能: 关闭右边对话框

// 函数: DramaSetLChatFigure(string strFileName);
// 功能: 设置剧情左边聊天头像
// 参数: strFileName: 头像文件名

// 函数: DramaSetLChatName(string strName, int nFontsize, int nFontcolor);
// 功能: 设置剧情左边聊天名字
// 参数: strName: 名字
//		nFontsize: 字体(默认nil)
//		nFontcolor: 颜色(默认nil)

// 函数: DramaSetLChatNameBySpriteKey(int nKey, int nFontsize, int nFontcolor);
// 功能: 设置剧情左边聊天名字
// 参数: nKey: 增加精灵时返回的key
//		nFontsize: 字体(默认nil)
//		nFontcolor: 颜色(默认nil)

// 函数: DramaSetLChatContent(string strContent, int nFontsize, int nFontcolor);
// 功能: 设置剧情左边聊天内容
// 参数: strContent: 聊天内容
//		nFontsize: 字体(默认nil)
//		nFontcolor: 颜色(默认nil)

// 函数: DramaSetRChatFigure(string strFileName);
// 功能: 设置剧情右边聊天头像

// 函数: DramaSetRChatName(string strName, int nFontsize, int nFontcolor);
// 功能: 设置剧情右边聊天名字

// 函数: DramaSetRChatNameBySpriteKey(int nKey, int nFontsize, int nFontcolor);
// 功能: 设置剧情右边聊天名字
// 参数: nKey: 增加精灵时返回的key
//		nFontsize: 字体(默认nil)
//		nFontcolor: 颜色(默认nil)

// 函数: DramaSetRChatContent(string strContent, int nFontsize, int nFontcolor);
// 功能: 设置剧情右边聊天内容

////////////////////////////////////////////////////////////////////////////////////
// 精灵操作

// 函数: DramaAddSprite(int nLookface, int nType, bool faceRight, string name);
// 功能: 往场景增加精灵
// 参数: nLookface: 精灵的外观
//		nType: 精灵的类型, 1 玩家, 2 npc, 3 怪物 4 精灵
//      faceRight:精灵的朝向, true 朝右, false 朝左
//      name:显示在头上的名字
// 返回值: int nKey : 用于后续对该精灵的其它操作

// 函数: DramaRemoveSprite(int nKey);
// 功能: 移除场景中的精灵
// 参数: nKey: AddDramaSprite函数返回的nKey

// 函数: DramaSetSpriteAni(int nKey, int nAniIndex);
// 功能: 设置场景中的精灵的动作
// 参数: nKey: AddDramaSprite函数返回的key
//		nAniIndex: 动作索引

// 函数: DramaSetSpritePosition(int nKey, int nPosX, int nPosY);
// 功能: 设置场景中的精灵的位置
// 参数: nKey: AddDramaSprite函数返回的key
//		nPosX: 地图坐标X(以Cell为单位)
//		nPosY: 地图坐标Y(以Cell为单位)

// 函数: DramaMoveSprite(int nKey, int nToPosX, int nToPosY, int nStep);
// 功能: 移动场景中的精灵到指定位置
// 参数: nKey: AddDramaSprite函数返回的key
//		nToPosX: 指定位置的地图坐标X(以Cell为单位)
//		nToPosY: 地图坐标Y(以Cell为单位)
//		nStep: 像机步进值

////////////////////////////////////////////////////////////////////////////////////
// 场景操作

// 函数: DramaLoadScene(int nMapID);
// 功能: 加载场景
// 参数: nMapID: 地图ID

// 函数: DramaLoadEraseInOutScene(string centerText, float showTime);
// 功能: 加载淡入淡出场景
// 参数: centerText: 屏幕中间显示的文本
// 参数:	nFontsize: 字体(默认nil)
// 参数:	nFontcolor: 颜色(默认nil)
// 参数: showTime: 场景显示的时间

// 函数: DramaRemoveEraseInOutScene(int nKey)
// 功能: 移除淡入淡出场景
// 参数: nKey: DramaLoadEraseInOutScene返回的key

////////////////////////////////////////////////////////////////////////////////////
// 像机操作

// 函数: DramaSetCameraPos(int nPosX, int nPosY)
// 功能: 设置场景中的相机位置
// 参数: nPosX: 地图坐标X(以Cell为单位)
//		nPosY: 地图坐标Y(以Cell为单位)

// 函数: DramaMoveCamera(int nToPosX, int nToPosY, int nStep)
// 功能: 移动相机到场景中的指定位置
// 参数: nToPosX: 地图坐标X(以Cell为单位)
//		nToPosY: 地图坐标Y(以Cell为单位)
//		nStep:像机步进距离

////////////////////////////////////////////////////////////////////////////////////
// 其它操作

// 函数: DramaSetWaitTime(float fTime)
// 功能: 场景不作任何处理fTime ms;
// 参数: fTime: 以毫秒为单位

// 函数: DramaWaitPrevActionFinish()
// 功能: 等待之前的操作完成后再继续后面的操作

// 函数: DramaWaitPrevActionFinishAndClick()
// 功能: 等待之前的操作完成后再通过点击继续后面的操作

// 函数: DramaStart();
// 功能: 开始剧情

// 函数: DramaFinish();
// 功能: 结束剧情

// 函数: DramaShowTipDlg(std::string content)
// 功能: 在场景正中间显示提示对话框
// 参数: content: 内容

////////////////////////////////////////////////////////////////////////////////////
// 对话设置

void DramaCloseRChatDlg();
void DramaOpenLChatDlgNotCloseRight();
void DramaCloseLChatDlg();
void DramaOpenRChatDlgNotCloseLeft();
// 函数: DramaOpenLChatDlg();
// 功能: 打开左边对话框,同时关闭右边对话框
void DramaOpenLChatDlg()
{
	DramaCloseRChatDlg();
	DramaOpenLChatDlgNotCloseRight();
}
// 函数: DramaOpenLChatDlg();
// 功能: 打开左边对话框,不关闭右边对话框
void DramaOpenLChatDlgNotCloseRight()
{
	DramaCommandDlg* command = new DramaCommandDlg;
	command->InitWithOpen(true);
	DramaObj.AddCommond(command);
}

// 函数: DramaOpenRChatDlg();
// 功能: 打开右边对话框,同时关闭左边对话框
void DramaOpenRChatDlg()
{
	DramaCloseLChatDlg();
	DramaOpenRChatDlgNotCloseLeft();
}
// 函数: DramaOpenRChatDlgNotCloseLeft();
// 功能: 打开右边对话框，不关闭左边对话框
void DramaOpenRChatDlgNotCloseLeft()
{
	DramaCommandDlg* command = new DramaCommandDlg;
	command->InitWithOpen(false);
	DramaObj.AddCommond(command);
}


// 函数: DramaCloseLChatDlg();
// 功能: 关闭对话框
void DramaCloseLChatDlg()
{
	DramaCommandDlg* command = new DramaCommandDlg;
	command->InitWithClose(true);
	DramaObj.AddCommond(command);
}

// 函数: DramaCloseRChatDlg();
// 功能: 关闭右边对话框
void DramaCloseRChatDlg()
{
	DramaCommandDlg* command = new DramaCommandDlg;
	command->InitWithClose(false);
	DramaObj.AddCommond(command);
}

// 函数: DramaSetLChatFigure(string strFileName);
// 功能: 设置剧情左边聊天头像
// 参数: strFileName: 头像文件名
void DramaSetLChatFigure(std::string strFileName, bool bReverse, int nCol, int nRow)
{
	DramaCommandDlg* command = new DramaCommandDlg;
	command->InitWithSetFigure(true, strFileName, bReverse, nCol, nRow);
	DramaObj.AddCommond(command);
}

// 函数: DramaSetLChatName(string strName, int nFontsize, int nFontcolor);
// 功能: 设置剧情左边聊天名字
// 参数: strName: 名字
//		nFontsize: 字体(默认nil)
//		nFontcolor: 颜色(默认nil)

void DramaSetLChatName(std::string strName, int nFontSize, int nFontColor)
{
    nFontSize*=FONT_SCALE;
	DramaCommandDlg* command = new DramaCommandDlg;
	command->InitWithSetTitle(true, strName, nFontSize, nFontColor);
	DramaObj.AddCommond(command);
}

// 函数: DramaSetLChatNameBySpriteKey(int nKey, int nFontsize, int nFontcolor);
// 功能: 设置剧情左边聊天名字
// 参数: nKey: 增加精灵时返回的key
//		nFontsize: 字体(默认nil)
//		nFontcolor: 颜色(默认nil)
void DramaSetLChatNameBySpriteKey(int nKey, int nFontSize, int nFontColor)
{
	nFontSize *= FONT_SCALE;
	DramaCommandDlg* command = new DramaCommandDlg;
	command->InitWithSetTitleBySpriteKey(true, nKey, nFontSize, nFontColor);
	DramaObj.AddCommond(command);
}

// 函数: DramaSetLChatContent(string strContent, int nFontsize, int nFontcolor);
// 功能: 设置剧情左边聊天内容
// 参数: strContent: 聊天内容
//		nFontsize: 字体(默认nil)
//		nFontcolor: 颜色(默认nil)
void DramaSetLChatContent(std::string strContent, int nFontSize, int nFontColor)
{
	nFontSize *= FONT_SCALE;
	DramaCommandDlg* command = new DramaCommandDlg;
	command->InitWithSetContent(true, strContent, nFontSize, nFontColor);
	DramaObj.AddCommond(command);
}

// 函数: DramaSetRChatFigure(string strFileName);
// 功能: 设置剧情右边聊天头像
void DramaSetRChatFigure(std::string strFileName, bool bReverse, int nCol, int nRow)
{
	DramaCommandDlg* command = new DramaCommandDlg;
	command->InitWithSetFigure(false, strFileName, bReverse,  nCol ,  nRow);
	DramaObj.AddCommond(command);
}

// 函数: DramaSetRChatName(string strName, int nFontsize, int nFontcolor);
// 功能: 设置剧情右边聊天名字
void DramaSetRChatName(std::string strName, int nFontSize, int nFontColor)
{
	nFontSize *= FONT_SCALE;
	DramaCommandDlg* command = new DramaCommandDlg;
	command->InitWithSetTitle(false, strName, nFontSize, nFontColor);
	DramaObj.AddCommond(command);
}

// 函数: DramaSetRChatNameBySpriteKey(int nKey, int nFontsize, int nFontcolor);
// 功能: 设置剧情右边聊天名字
// 参数: nKey: 增加精灵时返回的key
//		nFontsize: 字体(默认nil)
//		nFontcolor: 颜色(默认nil)
void DramaSetRChatNameBySpriteKey(int nKey, int nFontSize, int nFontColor)
{
	nFontSize *= FONT_SCALE;
	DramaCommandDlg* command = new DramaCommandDlg;
	command->InitWithSetTitleBySpriteKey(false, nKey, nFontSize, nFontColor);
	DramaObj.AddCommond(command);
}

// 函数: DramaSetRChatContent(string strContent, int nFontsize, int nFontcolor);
// 功能: 设置剧情右边聊天内容
void DramaSetRChatContent(std::string strContent, int nFontSize, int nFontColor)
{
	nFontSize *= FONT_SCALE;
	DramaCommandDlg* command = new DramaCommandDlg;
	command->InitWithSetContent(false, strContent, nFontSize, nFontColor);
	DramaObj.AddCommond(command);
}

////////////////////////////////////////////////////////////////////////////////////
// 精灵操作

// 函数: DramaAddSprite(int nLookface, int nType, bool faceRight, string name);
// 功能: 往场景增加精灵
// 参数: nLookface: 精灵的外观
//		nType: 精灵的类型, 1 玩家, 2 npc, 3 怪物
//      faceRight:精灵的朝向, true 朝右, false 朝左
//      name:显示在头上的名字
// 返回值: int nKey : 用于后续对该精灵的其它操作
double DramaAddSprite(int nLookface, int nType, bool faceRight, std::string name)
{
	DramaCommandSprite* command = new DramaCommandSprite;
	command->InitWithAdd(nLookface, nType, faceRight, name);
	DramaObj.AddCommond(command);
	return command->GetKey();
}

// 函数: DramaAddSpriteWithFile(std::string filename)
// 功能: 往场景增加精灵
// 参数: std::string name: 精灵的文件名
// 返回值: int nKey : 用于后续对该精灵的其它操作
double DramaAddSpriteWithFile(std::string filename)
{
	DramaCommandSprite* command = new DramaCommandSprite;
	command->InitWithAddByFile(filename);
	DramaObj.AddCommond(command);
	return command->GetKey();
}

// 函数: DramaRemoveSprite(int nKey);
// 功能: 移除场景中的精灵
// 参数: nKey: AddDramaSprite函数返回的nKey
void DramaRemoveSprite(int nKey)
{
	DramaCommandSprite* command = new DramaCommandSprite;
	command->InitWithRemove(nKey);
	DramaObj.AddCommond(command);
}

// 函数: DramaSetSpriteAni(int nKey, int nAniIndex);
// 功能: 设置场景中的精灵的动作
// 参数: nKey: AddDramaSprite函数返回的key
//		nAniIndex: 动作索引
void DramaSetSpriteAni(int nKey, int nAniIndex)
{
	DramaCommandSprite* command = new DramaCommandSprite;
	command->InitWithSetAnimation(nKey, nAniIndex);
	DramaObj.AddCommond(command);
}

// 函数: DramaSetSpriteReverse(int nKey, bool bReverse)
// 功能: 设置场景中的精灵的翻转
// 参数: nKey: AddDramaSprite函数返回的key
//		 bReverse: 是否翻转
void DramaSetSpriteReverse(int nKey, bool bReverse)    
{ 
	DramaCommandSprite* command = new DramaCommandSprite;
	command->InitWithSetReverse(nKey, bReverse);
	DramaObj.AddCommond(command);
}

// 函数: DramaSetSpritePosition(int nKey, int nPosX, int nPosY);
// 功能: 设置场景中的精灵的位置
// 参数: nKey: AddDramaSprite函数返回的key
//		nPosX: 地图坐标X(以Cell为单位)
//		nPosY: 地图坐标Y(以Cell为单位)
void DramaSetSpritePosition(int nKey, int nPosX, int nPosY)
{
	DramaCommandSprite* command = new DramaCommandSprite;
	command->InitWithSetPos(nKey, nPosX, nPosY);
	DramaObj.AddCommond(command);
}

// 函数: DramaMoveSprite(int nKey, int nToPosX, int nToPosY, int nStep);
// 功能: 移动场景中的精灵到指定位置
// 参数: nKey: AddDramaSprite函数返回的key
//		nToPosX: 指定位置的地图坐标X(以Cell为单位)
//		nToPosY: 地图坐标Y(以Cell为单位)
//		nStep: 像机步进值
void DramaMoveSprite(int nKey, int nPosX, int nPosY, int nStep)
{
	DramaCommandSprite* command = new DramaCommandSprite;
	command->InitWithMove(nKey, nPosX, nPosY, nStep);
	DramaObj.AddCommond(command);
}

////////////////////////////////////////////////////////////////////////////////////
// 场景操作

// 函数: DramaLoadScene(int nMapID);
// 功能: 加载场景
// 参数: nMapID: 地图ID
void DramaLoadScene(int nMapID)
{
	DramaCommandScene* command = new DramaCommandScene;
	command->InitWithLoadDrama(nMapID);
	DramaObj.AddCommond(command);
}

// 函数: DramaLoadEraseInOutScene(string centerText, int nFontsize, int nFontColor);
// 功能: 加载淡入淡出场景
// 参数: centerText: 屏幕中间显示的文本
// 参数:	nFontsize: 字体(默认nil)
// 参数:	nFontcolor: 颜色(默认nil)
// 返回值: key(用于后续操作例如删除场景)
double DramaLoadEraseInOutScene(string centerText, int nFontsize, int nFontColor)
{
	nFontsize *= FONT_SCALE;
	DramaCommandScene* command = new DramaCommandScene;
	command->InitWithLoad(centerText, nFontsize, nFontColor);
	DramaObj.AddCommond(command);
	return command->GetKey();
}

// 函数: DramaRemoveEraseInOutScene(int nKey)
// 功能: 移除淡入淡出场景
// 参数: nKey: DramaLoadEraseInOutScene返回的key
void DramaRemoveEraseInOutScene(int nKey)
{
	DramaCommandScene* command = new DramaCommandScene;
	command->InitWithRemove(nKey);
	DramaObj.AddCommond(command);
}

////////////////////////////////////////////////////////////////////////////////////
// 像机操作

// 函数: DramaSetCameraPos(int nPosX, int nPosY)
// 功能: 设置场景中的相机位置
// 参数: nPosX: 地图坐标X(以Cell为单位)
//		nPosY: 地图坐标Y(以Cell为单位)
void DramaSetCameraPos(int nPosX, int nPosY)
{
	DramaCommandCamera* command = new DramaCommandCamera;
	command->InitWithSetPos(nPosX, nPosY);
	DramaObj.AddCommond(command);
}

// 函数: DramaMoveCamera(int nToPosX, int nToPosY, int nStep)
// 功能: 移动相机到场景中的指定位置
// 参数: nToPosX: 地图坐标X(以Cell为单位)
//		nToPosY: 地图坐标Y(以Cell为单位)
//		nStep:像机步进距离
void DramaMoveCamera(int nToPosX, int nToPosY, int nStep)
{
	DramaCommandCamera* command = new DramaCommandCamera;
	command->InitWithMove(nToPosX, nToPosY, nStep);
	DramaObj.AddCommond(command);
}

////////////////////////////////////////////////////////////////////////////////////
// 其它操作

// 函数: DramaSetWaitTime(float fTime)
// 功能: 场景不作任何处理fTime ms;
// 参数: fTime: 以毫秒为单位
void DramaSetWaitTime(float fTime)
{
	DramaCommandWait* command = new DramaCommandWait;
	command->InitWithWait(fTime);
	DramaObj.AddCommond(command);
}

// 函数: DramaWaitPrevActionFinish()
// 功能: 等待之前的操作完成后再继续后面的操作
void DramaWaitPrevActionFinish()
{
	DramaCommandWait* command = new DramaCommandWait;
	command->InitWithWaitPreActionFinish();
	DramaObj.AddCommond(command);
}

// 函数: DramaWaitPrevActionFinishAndClick()
// 功能: 等待之前的操作完成后再通过点击继续后面的操作
void DramaWaitPrevActionFinishAndClick()
{
	DramaCommandWait* command = new DramaCommandWait;
	command->InitWithWaitPreActFinishAndClick();
	DramaObj.AddCommond(command);
}

// 函数: DramaStart();
// 功能: 开始剧情
void DramaStart()
{
	DramaObj.Start();
}

// 函数: DramaFinish();
// 功能: 结束剧情
void DramaFinish()
{
	DramaCommandScene* command = new DramaCommandScene;
	command->InitWithFinishDrama();
	DramaObj.AddCommond(command);
}

// 函数: DramaShowTipDlg(std::string content)
// 功能: 在场景正中间显示提示对话框
// 参数: content: 内容
void DramaShowTipDlg(std::string content)
{
	DramaCommandDlg* command = new DramaCommandDlg;
	command->InitWithTip(content);
	DramaObj.AddCommond(command);
}

// 函数: DramaPlaySoundEffect
// 功能: 播放音效
// 参数: nSoundEffectId: 音效的id
void DramaPlaySoundEffect(int nSoundEffectId)
{
	DramaCommandSoundEffect* pkCommand = new DramaCommandSoundEffect;
	pkCommand->InitWithSoundEffectId(nSoundEffectId);
	DramaObj.AddCommond(pkCommand);
}
    
void ScriptDramaLoad()
{
	ETCFUNC("DramaPlaySoundEffect", DramaPlaySoundEffect);
	ETCFUNC("DramaOpenLChatDlg", DramaOpenLChatDlg);
	ETCFUNC("DramaOpenLChatDlgNotCloseRight", DramaOpenLChatDlgNotCloseRight);
	ETCFUNC("DramaOpenRChatDlg", DramaOpenRChatDlg);
	ETCFUNC("DramaOpenRChatDlgNotCloseLeft", DramaOpenRChatDlgNotCloseLeft);
	ETCFUNC("DramaCloseLChatDlg", DramaCloseLChatDlg);
	ETCFUNC("DramaCloseRChatDlg", DramaCloseRChatDlg);
	ETCFUNC("DramaSetLChatFigure", DramaSetLChatFigure);
	ETCFUNC("DramaSetLChatName", DramaSetLChatName);
	ETCFUNC("DramaSetLChatNameBySpriteKey", DramaSetLChatNameBySpriteKey);
	ETCFUNC("DramaSetLChatContent", DramaSetLChatContent);
	ETCFUNC("DramaSetRChatFigure", DramaSetRChatFigure);
	ETCFUNC("DramaSetRChatName", DramaSetRChatName);
	ETCFUNC("DramaSetRChatNameBySpriteKey", DramaSetRChatNameBySpriteKey);
	ETCFUNC("DramaSetRChatContent", DramaSetRChatContent);
	ETCFUNC("DramaAddSprite", DramaAddSprite);
	ETCFUNC("DramaAddSpriteWithFile", DramaAddSpriteWithFile);
	ETCFUNC("DramaRemoveSprite", DramaRemoveSprite);
	ETCFUNC("DramaSetSpriteAni", DramaSetSpriteAni);
	ETCFUNC("DramaSetSpritePosition", DramaSetSpritePosition);
	ETCFUNC("DramaMoveSprite", DramaMoveSprite);
	ETCFUNC("DramaLoadScene", DramaLoadScene);
	ETCFUNC("DramaLoadEraseInOutScene", DramaLoadEraseInOutScene);
	ETCFUNC("DramaRemoveEraseInOutScene", DramaRemoveEraseInOutScene);
	ETCFUNC("DramaSetCameraPos", DramaSetCameraPos);
	ETCFUNC("DramaMoveCamera", DramaMoveCamera);
	ETCFUNC("DramaSetWaitTime", DramaSetWaitTime);
	ETCFUNC("DramaWaitPrevActionFinish", DramaWaitPrevActionFinish);
	ETCFUNC("DramaWaitPrevActionFinishAndClick", DramaWaitPrevActionFinishAndClick);
	ETCFUNC("DramaStart", DramaStart);
	ETCFUNC("DramaFinish", DramaFinish);
	ETCFUNC("DramaShowTipDlg", DramaShowTipDlg);
	ETCFUNC("DramaSetSpriteReverse", DramaSetSpriteReverse);
}

}
