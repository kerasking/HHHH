/*
 *  NDCommonScene.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-8-11.
 *  Copyright 2011 (网龙)DeNA. All rights reserved.
 *
 */

#ifndef _ND_COMMON_SCENE_H_
#define _ND_COMMON_SCENE_H_

#include "NDUILayer.h"
#include "NDScene.h"
#include "NDUILabel.h"
#include "NDUIButton.h"
#include "NDUISpecialLayer.h"
#include "NDUIImage.h"

using namespace NDEngine;

//////////////////////////////////////////////////////////////
#pragma mark tab 节点
class TabNode : public NDUINode
{
	DECLARE_CLASS(TabNode)
	
	TabNode();
	
	virtual ~TabNode();
public:
	void Initialization(); override
	
	// interface begin ...
	void SetImage(NDPicture *pic, NDPicture *focusPic, NDPicture* selPic=NULL);
	
	void SetText(const char *text);
	
	void SetTextColor(ccColor4B color, bool setBoder=false, ccColor4B colorBoder=ccc4(255, 255, 255, 255));
	
	void SetFocusColor(ccColor4B color, bool setBoder=false, ccColor4B colorBoder=ccc4(255, 255, 255, 255));
	
	void SetTextFontSize(unsigned int fontsize, bool horzontal=true, unsigned int verticalOffset=0);
	
	void SetFocus(bool focus);
	
	void ShowHorizontal(bool horizontal);
	
	void SetTextPicture(NDPicture* picText, NDPicture* picFocusText);
	
	// interface end ...
	
protected:
	
	void draw(); override
	
	void InitLabel();
	
protected:

	NDUILabel *m_lbText;
	
	NDPicture *m_pic, *m_picFocus;
	
	NDPicture *m_picFocusSel;
	
	NDPicture *m_picText, *m_picFocusText;
	
	bool m_focus;
	
	bool m_focusTextColor;
	
	ccColor4B m_textColor, m_focusColor;
	
	bool m_bHorizontal;
	
	unsigned int m_uiVerticalOffect;
};

class VerticalTabNode : public TabNode
{
	DECLARE_CLASS(VerticalTabNode)
	VerticalTabNode();
public:
	void SetFoucusOffset(int offset);
private:
	void draw(); override
	
	int m_iFocusOffset;
};

//////////////////////////////////////////////////////////////
#pragma mark tab容器代理
class TabLayer;

class TabLayerDelegate
{
public:
	virtual void OnTabLayerSelect(TabLayer* tab, unsigned int lastIndex, unsigned int curIndex) {}
	virtual void OnTabLayerClick(TabLayer* tab, uint curIndex) {}
	virtual void OnTabLayerNextPage(TabLayer* tab, unsigned int lastPage, unsigned int nextPage) {}
};

//////////////////////////////////////////////////////////////
#pragma mark tab容器
class TabLayer : 
public NDUILayer
{
	DECLARE_CLASS(TabLayer)
	
	TabLayer();
	
	virtual ~TabLayer();
	
public:
	void Initialization(unsigned int interval=0); hide
	
	void SetTabNodeSize(CGSize size);
	
	virtual TabNode* CreateTabNode();
	
	TabNode* GetTabNode(unsigned int index);
	
	unsigned int GetTabNodeCount();
	
	virtual void SetFocusTabIndex(unsigned int index, bool dispatchEvent=false);
	
	void SetFocusTabNode(TabNode* tabnode, bool dispatchEvent=false);
	
	unsigned int GetFocusIndex();
	
	CGSize GetTabNodeSize();
	
	TabNode* GetFoucusTabNode();

protected:
	
	bool DispatchTouchEndEvent(CGPoint beginTouch, CGPoint endTouch); override
	
protected:
	
	unsigned int m_uiFocusIndex;
	
	unsigned int m_uiInterval;
	
	CGSize m_tabNodeSize;
};

//////////////////////////////////////////////////////////////
#pragma mark 水平型tab容器
class HorizontalTabLayer : public TabLayer
{
	DECLARE_CLASS(HorizontalTabLayer)
	
	HorizontalTabLayer();
	
public:
	TabNode* CreateTabNode(); override
	
	virtual void SetFocusTabIndex(unsigned int index, bool dispatchEvent=false);
	
	// call before CreateTabNode
	void SetCountPerPage(unsigned int count);
	
	bool IsShowPage();
	
	void NextPage();
	
	unsigned int GetPerPageCount() { return m_uiCountPerPage; }
	
private:
	bool m_ShowPage;
	
	unsigned int m_uiCountPerPage;
};

//////////////////////////////////////////////////////////////
#pragma mark 垂直型tab容器
class VerticalTabLayer : public TabLayer
{
	DECLARE_CLASS(VerticalTabLayer)
	
public:
	
	VerticalTabNode* CreateTabNode(); override
};

//////////////////////////////////////////////////////////////
#pragma mark 客户层代理
class NDUIClientLayer;

class NDUIClientLayerDelegate
{
public:
	virtual void OnClientLayerTabSel(NDUIClientLayer* clientLayer, unsigned int lastIndex, unsigned int curIndex) {}
};

//////////////////////////////////////////////////////////////
#pragma mark 客户层
class NDUIClientLayer : 
public NDUIChildrenEventLayer,
public TabLayerDelegate
{
	DECLARE_CLASS(NDUIClientLayer)
	
	NDUIClientLayer();
	
	~NDUIClientLayer();
	
public:
	
	// 创建一个功能tab标签(仅有一个)
	// 使用者对返回的tab作定制
	VerticalTabLayer* CreateFuncTab(unsigned int interval=0);
	
	// 获取功能层(调用之前若已创建了tab,则返回对应的标签层)
	// 可以加入显示节点
	// 至于标签的切换工作(功能层切换)内部完成
	NDUILayer* GetFuncLayer(unsigned int index);
	
	TabNode* GetFuncTabNode(unsigned int index);
	
	unsigned int GetFuncTabNodeCount();
	
	void SetFocusFuncTabIndex(unsigned int index, bool dispatchEvent=false);
	
	void SetFocusFuncTabNode(TabNode* tabnode, bool dispatchEvent=false);
	
	unsigned int GetCurFuncTabIndex();
	
	void OnTabLayerSelect(TabLayer* tab, unsigned int lastIndex, unsigned int curIndex); override
private:

	VerticalTabLayer* m_tab;
	
	std::vector<NDUILayer*> m_vClientLayer;
};

//////////////////////////////////////////////////////////////
#pragma mark 通用界面场景
class NDCommonScene : 
public NDScene,
public TabLayerDelegate,
public NDUIButtonDelegate
{
	DECLARE_CLASS(NDCommonScene)
	
	NDCommonScene();
	
	~NDCommonScene();
	
public:
	void Initialization(bool showPage=false, unsigned int perPageCount=0); override
	
	// 增加一个tab标签
	// 标签索引从0开始递增
	// 同时为该标签创建了一个客户层
	TabNode* AddTabNode();
	
	// 获取标签的客户层
	// 大多数工作是获取客户层后往层里加节点(具体展现),至于标签的切换工作(客户层切换)内部完成
	// 如果该客户层需要支持多个功能,可以把加入节点的工作重心转移到NDUIClientLayer->GetFuncLayer
	NDUIClientLayer* GetClientLayer(unsigned int tabIndex);
	
	// 获取通用层
	// 通用层与tab无关 
	// 通用层一直处于显示状态(不会因为tab切换而隐藏或显示)
	NDUILayer* CetGernalLayer(bool dealEvent,unsigned int zOrder=0);
	
	void SetTabFocusOnIndex(unsigned int index, bool dispatchEvent=false);
	
	unsigned int GetCurTabIndex();
	
protected:
	bool OnBaseButtonClick(NDUIButton* button);
	
	void OnTabLayerSelect(TabLayer* tab, unsigned int lastIndex, unsigned int curIndex); override

	void OnTabLayerNextPage(TabLayer* tab, unsigned int lastPage, unsigned int nextPage); override
protected:
	
	HorizontalTabLayer* m_tab;
	
	std::vector<NDUIClientLayer*>	m_vClientLayer;
	NDUILayer						*m_genralLayer;
	NDUILayer						*m_genralEventLayer;
	
	unsigned int m_curTabIndex;
	
	unsigned int m_uiTabInterval;
	
	CGSize m_tabNodeSize;
	
protected:
	void InitTab(bool showPage=false, unsigned int perPageCount=0);
	
protected:
	NDUIButton *m_btnClose, *m_btnNext;
	
	NDUILayer  *m_layerBackground;
};

#pragma mark 功能tab
class NDFuncTab :
public NDUILayer,
public TabLayerDelegate
{
	DECLARE_CLASS(NDFuncTab)

	NDFuncTab();
	
	~NDFuncTab();
	
public:
	
	void Initialization(unsigned int tabCount, CGPoint pos, CGSize sizeTabNode=CGSizeMake(25, 63), unsigned selHeight=0, unsigned unselHeight=0, bool bFullClient=false, int bgwidth=280); hide
	
	TabNode* GetTabNode(unsigned int index);
	
	// 获取标签的客户层
	// 大多数工作是获取客户层后往层里加节点(具体展现),至于标签的切换工作(客户层切换)内部完成
	// 如果该客户层需要支持多个功能,可以把加入节点的工作重心转移到NDUIClientLayer->GetFuncLayer
	NDUIClientLayer* GetClientLayer(unsigned int tabIndex);
	
	void SetVisible(bool visible); override
	
	void SetTabFocusOnIndex(unsigned int index, bool dispatchEvent=false);
	
protected:
	
	void OnTabLayerSelect(TabLayer* tab, unsigned int lastIndex, unsigned int curIndex); override
	void OnTabLayerClick(TabLayer* tab, uint curIndex); override

private:
	VerticalTabLayer* m_tab;
	std::vector<NDUIClientLayer*>	m_vClientLayer;
	
};

#pragma mark 社交类型场景
class NDCommonSocialScene :
public NDScene,
public TabLayerDelegate,
public NDUIButtonDelegate
{
	DECLARE_CLASS(NDCommonSocialScene)
	
	NDCommonSocialScene();
	
	~NDCommonSocialScene();
	
public:
	void Initialization(); override
	
	void InitTab(unsigned int tabCount, CGSize sizeTabNode=CGSizeMake(25, 63), unsigned selHeight=0, unsigned unselHeight=0);
	
	void SetClientLayerBackground(unsigned int tabIndex, bool bFullClient=false, int bgwidth=280);
	
	TabNode* GetTabNode(unsigned int tabIndex);
	
	NDUIClientLayer* GetClientLayer(unsigned int tabIndex);
	
	void SetTabFocusOnIndex(unsigned int index, bool dispatchEvent=false);
	
protected:
	bool OnBaseButtonClick(NDUIButton* button);
	
	void OnTabLayerSelect(TabLayer* tab, unsigned int lastIndex, unsigned int curIndex); override
	
protected:
	NDUIButton *m_btnClose;
	NDUILayer  *m_layerBackground;
	VerticalTabLayer* m_tab;
	std::vector<NDUIClientLayer*>	m_vClientLayer;
	std::vector<NDUIImage*>			m_vClientBackground;
};

#pragma mark 水平型功能tab

class NDHFuncTab;

class HFuncTabDelegate
{
public:
	virtual void OnHFuncTabSelect(NDHFuncTab* tab, unsigned int lastIndex, unsigned int curIndex) {}
	virtual void OnHFuncTabClick(NDHFuncTab* tab, uint curIndex) {}
};

class NDHFuncTab :
public NDUILayer,
public TabLayerDelegate
{
	DECLARE_CLASS(NDHFuncTab)
	
	NDHFuncTab();
	
	~NDHFuncTab();
	
public:
	
	void Initialization(unsigned int tabCount, CGSize sizeTabNode=CGSizeMake(70, 34), unsigned int interval=5); hide
	
	TabNode* GetTabNode(unsigned int index);
	
	// 获取标签的客户层
	// 大多数工作是获取客户层后往层里加节点(具体展现),至于标签的切换工作(客户层切换)内部完成
	// 如果该客户层需要支持多个功能,可以把加入节点的工作重心转移到NDUIClientLayer->GetFuncLayer
	NDUIClientLayer* GetClientLayer(unsigned int tabIndex);
	
	void SetVisible(bool visible); override
	
	void SetTabFocusOnIndex(unsigned int index, bool dispatchEvent=false);
	
protected:
	
	void OnTabLayerSelect(TabLayer* tab, unsigned int lastIndex, unsigned int curIndex); override
	void OnTabLayerClick(TabLayer* tab, uint curIndex); override
	
private:
	HorizontalTabLayer* m_tab;
	std::vector<NDUIClientLayer*>	m_vClientLayer;
	NDUILayer *m_layerBackground;
	
};

#pragma mark 通用界面层
class NDCommonLayer : 
public NDUILayer,
public TabLayerDelegate,
public NDUIButtonDelegate
{
	DECLARE_CLASS(NDCommonLayer)
	
	NDCommonLayer();
	
	~NDCommonLayer();
	
public:
	void Initialization(bool showPage=false, unsigned int perPageCount=0); override
	
	// maxTabNodeCharWidth-最大的tab节点字符的宽度
	void Initialization(float maxTabNodeCharWidth); override
	
	void OnButtonClick(NDUIButton* button); override
	
	virtual void SetVisible(bool visible); override
	
	// 增加一个tab标签
	// 标签索引从0开始递增
	// 同时为该标签创建了一个客户层
	TabNode* AddTabNode();
	
	// 获取标签的客户层
	// 大多数工作是获取客户层后往层里加节点(具体展现),至于标签的切换工作(客户层切换)内部完成
	// 如果该客户层需要支持多个功能,可以把加入节点的工作重心转移到NDUIClientLayer->GetFuncLayer
	NDUIClientLayer* GetClientLayer(unsigned int tabIndex);
	
	CGSize GetClientSize();
	
	// 获取通用层
	// 通用层与tab无关 
	// 通用层一直处于显示状态(不会因为tab切换而隐藏或显示)
	NDUILayer* CetGernalLayer(bool dealEvent,unsigned int zOrder=0);
	
	void SetTabFocusOnIndex(unsigned int index, bool dispatchEvent=false);
	
	unsigned int GetCurTabIndex();
	
protected:
	bool OnBaseButtonClick(NDUIButton* button);
	
	void OnTabLayerSelect(TabLayer* tab, unsigned int lastIndex, unsigned int curIndex); override
	
	void OnTabLayerNextPage(TabLayer* tab, unsigned int lastPage, unsigned int nextPage); override
protected:
	
	HorizontalTabLayer* m_tab;
	
	std::vector<NDUIClientLayer*>	m_vClientLayer;
	NDUILayer						*m_genralLayer;
	NDUILayer						*m_genralEventLayer;
	
	unsigned int m_curTabIndex;
	
	unsigned int m_uiTabInterval;
	
	CGSize m_tabNodeSize;
	
protected:
	void InitTab(bool showPage=false, unsigned int perPageCount=0);
	
protected:
	NDUIButton *m_btnNext;
	
	NDUILayer  *m_layerBackground;
};


#endif // _ND_COMMON_SCENE_H_
