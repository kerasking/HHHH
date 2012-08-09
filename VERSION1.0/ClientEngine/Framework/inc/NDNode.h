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
		NODE_LEVEL_NONE=0,
		NODE_LEVEL_TEAM_LEADER,
		NODE_LEVEL_MAIN_ROLE,
	};

	typedef CAutoLink<NDCommonProtocol>			COMMON_VIEWER;
	typedef std::list<COMMON_VIEWER>			LIST_COMMON_VIEWER;
	typedef LIST_COMMON_VIEWER::iterator		LIST_COMMON_VIEWER_IT;
	
	class NDNode;
	class NDNodeDelegate
	{
	public:

		virtual void OnBeforeNodeRemoveFromParent(NDNode* node, bool bCleanUp){}
		virtual void OnAfterNodeRemoveFromParent(NDNode* node, bool bCleanUp){}
	};
	
	class NDNode : public NDCommonProtocol
	{
		DECLARE_CLASS(NDNode)
	public:
		NDNode();
		~NDNode();
	public:

		static NDNode* Node();

		virtual void Initialization(); 
		

		virtual void draw();

		NDNode* GetParent();	

		const std::vector<NDNode*>& GetChildren();

		void RemoveAllChildren(bool bCleanUp);

		CGSize GetContentSize();

		void SetContentSize(CGSize size);

		int GetzOrder();

		int GetTag();

		void SetTag(int tag);

		void AddChild(NDNode* node);

		void AddChild(NDNode* node, int z);

		virtual void AddChild(NDNode* node, int z, int tag);

		virtual void RemoveChild(NDNode* node, bool bCleanUp);

		virtual void RemoveChild(int tag, bool bCleanUp);

		bool ContainChild(NDNode* node);

		void RemoveFromParent(bool bCleanUp);

		NDNode* GetChild(int tag);		

		bool IsChildOf(NDNode* node);

		void EnableDraw(bool enabled);

		bool DrawEnabled();
		
		void SetParam1(int nParam1);
		void SetParam2(int nParam2);
		int GetParam1();
		int GetParam2();

		void TestCallBack(CCObject* pSender);	///< 测试用，用完要删除 郭浩
		
	protected:
		int m_nParam1;
		int m_nParam2;
	public:
		cocos2d::CCNode *m_ccNode;		
		
	protected:	
		std::vector<NDNode*> m_childrenList;
		NDNode* m_parent;
		bool m_drawEnabled;	

		void SetParent(NDNode* node);
		
	public:		
		void SetDestroyNotify(LuaObject func);
		bool GetDestroyNotify(LuaObject& func);
	private:
		LuaObject		m_delegateDestroy;

	public:
		void    SetPosx(int nposx){ m_nPosx = nposx; }
		void    SetPosy(int nposy){ m_nPosy = nposy; }
		int     GetPosx(void){ return m_nPosx; }
		int     GetPosy(void){ return m_nPosy; }
		void    SetNodeLevel(int nLevel){ m_nLevel = nLevel; }
		int     GetNodeLevel(){ return m_nLevel; }
	
	private:
		//屏幕格子坐标
		int  m_nPosx;
		int  m_nPosy;
		int  m_nLevel;//数值越高级别越高，数值为0不做排序处理

	public:
		void AddViewer(NDCommonProtocol* viewer);
		void RemoveViewer(NDCommonProtocol* viewer);
	protected:
		bool DispatchClickOfViewr(NDObject* object);
	protected:
		LIST_COMMON_VIEWER			m_listCommonViewer;
	};
	
}

#endif


