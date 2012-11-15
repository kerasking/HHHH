//
//  NDNode.h
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-7.
//  Copyright 2010 (网龙)DeNA. All rights reserved.
//
//	－－介绍－－
//	NDNode是框架的基础节点
//	节点的显示与z轴有关，z轴越大则越靠前显示
//	派生类必须隐式或显示的实现Initialization方法
//	派生类的对象生成之后必须隐式或显示的调用Initialization方法

#ifndef	__NDNode_H
#define __NDNode_H

#include "NDCommonProtocol.h"
#include "ScriptInc.h"
#include <vector>
#include <list>

#include "ccTypes.h"
#include "CCNode.h"
#include "CCObject.h"

#include "shaders/ccGLStateCache.h"
#include "shaders/CCGLProgram.h"

#define DECLARE_AUTOLINK(class_name) \
private: CAutoLink<class_name> m_autolink##class_name;

#define INTERFACE_AUTOLINK(class_name) \
public: CAutoLink<class_name> QueryLink() { return  m_autolink##class_name; }

#define INIT_AUTOLINK(class_name) \
m_autolink##class_name.Init(this)

using namespace cocos2d;

namespace NDEngine
{
enum NODE_LEVEL
{
	NODE_LEVEL_NONE = 0,
	NODE_LEVEL_TEAM_LEADER,
	NODE_LEVEL_MAIN_ROLE,
};

typedef CAutoLink<NDCommonProtocol> COMMON_VIEWER;
typedef std::list<COMMON_VIEWER> LIST_COMMON_VIEWER;
typedef LIST_COMMON_VIEWER::iterator LIST_COMMON_VIEWER_IT;

class NDNode;
class NDNodeDelegate
{
public:

	virtual void OnBeforeNodeRemoveFromParent(NDNode* node, bool bCleanUp)
	{
	}
	virtual void OnAfterNodeRemoveFromParent(NDNode* node, bool bCleanUp)
	{
	}
};

class NDNode: public NDCommonProtocol
{
DECLARE_CLASS(NDNode)
public:
	NDNode();
	~NDNode();
public:

	//
	//		函数：Node
	//		作用：静态方法，通过该方法调用无需显示调用Initialization方法
	//		参数：无
	//		返回值：本对象指针
	static NDNode* Node();
	//		
	//		函数：Initialization
	//		作用：初始化节点，必须备显示或隐式调用
	//		参数：无
	//		返回值：无
	virtual void Initialization(); 
	virtual void Destroy();

	//		
	//		函数：draw
	//		作用：游戏的循环体，游戏每一帧调用该方法，框架内部调用
	//		参数：无
	//		返回值：无
	virtual void draw();
	virtual void preDraw() {}
	virtual void postDraw() {}

	//		
	//		函数：GetParent
	//		作用：获取父亲节点
	//		参数：无
	//		返回值：返回父亲节点，没有父亲节点则返回null
	NDNode* GetParent();	
	//		
	//		函数：GetChildren
	//		作用：获取子节点列表
	//		参数：无
	//		返回值：节点列表
	const std::vector<NDNode*>& GetChildren();
	//		
	//		函数：RemoveAllChildren
	//		作用：删除所有子节点
	//		参数：bCleanUp如果为true则节点内部负责清理子节点的内存，否则由外部清理
	//		返回值：无
	void RemoveAllChildren(bool bCleanUp);
	//		
	//		函数：GetContentSize
	//		作用：获取节点的内容大小
	//		参数：无
	//		返回值：内容大小
	CCSize GetContentSize();
	//		
	//		函数：SetContentSize
	//		作用：设置节点的内容大小，该内容的大小会影响到绘制，基本上外部不需要显示调用
	//		参数：size内容大小
	//		返回值：无
	void SetContentSize(CCSize size);
	//		
	//		函数：GetzOrder
	//		作用：获取z轴大小
	//		参数：无
	//		返回值：z轴大小, 默认0
	int GetzOrder();
	//		
	//		函数：GetTag
	//		作用：获取节点标识
	//		参数：无
	//		返回值：节点标识
	int GetTag();
	//		
	//		函数：SetTag
	//		作用：设置节点标识
	//		参数：tag节点标识
	//		返回值：无
	void SetTag(int tag);
	//
	//		注意：被添加的子节点不可重复
	//		
	//		函数：AddChild(NDNode* node)
	//		作用：添加子节点
	//		参数：node子节点
	//		返回值：无
	void AddChild(NDNode* node);
	//		
	//		函数：AddChild(NDNode* node, int z)
	//		作用：添加子节点
	//		参数：node子节点，z子节点的z轴大小
	//		返回值：无
	void AddChild(NDNode* node, int z);
	//		
	//		函数：AddChild(NDNode* node, int z, int tag)
	//		作用：添加子节点
	//		参数：node子节点，z子节点的z轴大小，tag子节点的标识
	//		返回值：无
	virtual void AddChild(NDNode* pkNode, int nZBuffer, int nTag);
	//		
	//		函数：RemoveChild(NDNode* node, bool bCleanUp)
	//		作用：删除子节点
	//		参数：node子节点，bCleanUp如果为true则由节点内部负责清理子节点的内存，否则需要外部负责清理
	//		返回值：无
	virtual void RemoveChild(NDNode* pkNode, bool bCleanUp);
	//		
	//		函数：RemoveChild(int tag, bool bCleanUp)
	//		作用：删除子节点
	//		参数：tag子节点的标识，bCleanUp如果为true则由节点内部负责清理子节点的内存，否则需要外部负责清理
	//		返回值：无
	virtual void RemoveChild(int tag, bool bCleanUp);
	//		
	//		函数：ContainChild
	//		作用：是否包含子节点
	//		参数：node子节点
	//		返回值：true是，false否
	bool ContainChild(NDNode* node);
	//		
	//		函数：RemoveFromParent
	//		作用：从父亲节点中删除本节点，必须保证父亲节点存在
	//		参数：bCleanUp如果true则清理该节点的内存，否则不清理，将由外部负责清理
	//		返回值：无
	void RemoveFromParent(bool bCleanUp);
	//		
	//		函数：GetChild
	//		作用：获取子节点
	//		参数：tag子节点的标识
	//		返回值：子节点，失败返回null
	NDNode* GetChild(int tag);		
	//		
	//		函数：IsChildOf
	//		作用：判断是否是某一节点的子节点
	//		参数：node父亲或者祖父节点
	//		返回值：true是，false否
	bool IsChildOf(NDNode* node);
	//		
	//		以下两个函数基本由引擎内部调用，可无需关心
	//		
	//		函数：EnableDraw
	//		作用：设置节点是否允许被访问
	//		参数：enabled如果false则停止访问该节点，默认为true
	//		返回值：无
	void EnableDraw(bool enabled);
	//		
	//		函数：DrawEnabled
	//		作用：判断节点是否允许访问
	//		参数：无
	//		返回值：true允许访问，false不允许访问，默认为true
	bool DrawEnabled();

	void SetParam1(int nParam1);
	void SetParam2(int nParam2);
	int GetParam1();
	int GetParam2();

public: //@shader
	CC_SYNTHESIZE_RETAIN(CCGLProgram*, m_pShaderProgram, ShaderProgram);
	CC_SYNTHESIZE(ccGLServerState, m_glServerState, GLServerState);
protected:
	void DrawSetup( const char* shaderType = kCCShader_PositionTexture_uColor );

protected:
	int m_nParam1;
	int m_nParam2;
public:
	cocos2d::CCNode *m_ccNode;

protected:

	std::vector<NDNode*> m_kChildrenList;
	NDNode* m_pkParent;
	bool m_bDrawEnabled;

	void SetParent(NDNode* node);

public:

	void SetDestroyNotify(LuaObject func);
	bool GetDestroyNotify(LuaObject& func);

private:

	LuaObject m_kDelegateDestroy;

public:

	void SetPosx(int nposx)
	{
		m_nPosx = nposx;
	}
	void SetPosy(int nposy)
	{
		m_nPosy = nposy;
	}
	int GetPosx(void)
	{
		return m_nPosx;
	}
	int GetPosy(void)
	{
		return m_nPosy;
	}
	void SetNodeLevel(int nLevel)
	{
		m_nLevel = nLevel;
	}
	int GetNodeLevel()
	{
		return m_nLevel;
	}

private:
	//屏幕格子坐标
	int m_nPosx;
	int m_nPosy;
	int m_nLevel; //数值越高级别越高，数值为0不做排序处理

public:
	void AddViewer(NDCommonProtocol* viewer);
	void RemoveViewer(NDCommonProtocol* viewer);
public:
	bool DispatchClickOfViewr(NDObject* object);
protected:
	LIST_COMMON_VIEWER m_listCommonViewer;
};

}

#endif

