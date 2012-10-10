/**
场景类
Copyright(c) 1999-2012, TQ Digital Entertainment, All Rights Reserved
**/
#ifndef __FRAMEWORK__CScene__H__
#define __FRAMEWORK__CScene__H__
#include "FrameworkTypes.h"
#include "selector_protocol.h"
#include "Timer.h"

class CSprite;
class CScene :public SelectorProtocol,public ISysTimerDelegate
{
public:
	CScene(void);
	virtual ~CScene(void);
	
	//获取本场景ID。
	virtual int GetSceneID() = 0;

	//用户触摸输入事件。
	virtual bool OnTouchEvent(TOUCH_EVENT_INFO* tei=NULL/*输入信息*/) ;

	//每一帧准备绘制之前回调本函数，进行前期绘制或资源准备。
	virtual void PreRender();

	//每一帧绘制时回调本函数，进行场景的绘制。
	virtual bool OnRender() = 0;

	//每一帧准备绘制结束之前回调本函数，在此过程中绘制的对象，将在UI(窗口、控件)之上。
	virtual	void PostRender();

	//收到网络数据包。数据包先广播到可视的窗口后，才广播到当前活动场景。
	virtual void OnNetPackage(void* pDataPkg/*网络包指针*/) = 0;

	//移动场景，由框架回调，如果用户在场景中调用ShowRelative接口，
	//则必需在派生中调用CScene::OnMove，才能完成对场景上的物件移动进行托管。
	virtual void OnMove(int nXOffset/*X轴的移动增量,单位来象素*/, int nYOffset/*Y轴的移动增量,单位来象素*/);
	
	//缩放场景，由框架回调,
	virtual void OnScale(int nScale/*缩放的增量,单位来象素*/) = 0;

	//场景被激活，由框架回调
	virtual void OnActive()=0;

	//场景失去活动状态
	virtual void OnDeactive()=0;

	//定时器回调函数
	virtual int OnTimer(int TimerId, void* pParam);

	//获取当前场景的视图原点(即可视区域的左上角坐标)
	void GetViewPos(CPoint& refPos);

	//设置当前场景的视图原点
	void SetViewPos(const CPoint& refPos);

	//获取当前场景的视图大小(即可视大小)
	void GetViewRect(CRect& refRect);

	//获取场景的大小。
	void GetSceneSize(CSize& refSceneSize);

	//设置场景的大小
	void SetSceneSize(const CSize& refSceneSize);

	//将视图坐标转换成场景坐标(世界坐标)
	void ViewPos2WordPos(CPoint& refViewPos);



	//增加允许点击的精灵
	void AddTouchSprite(CSprite* pSprite);

	//删除允许点击的精灵
	void RemoveTouchSprite(CSprite* pSprite);

	//处理所有的精灵点击事件(若返回FALSE则不再查找其它的精灵)
	virtual BOOL OnSpriteEvent(CSprite* pObj, int nEventType);

	friend class CDirector;
protected:

	//消息处理，用于处理由SendMessage发送的消息。
	virtual bool MsgHandler(UINT nMessage,WPARAM wParam, LPARAM lParam=0);

	CPoint	m_posOrg;//视觉原点
	CSize m_sizeScene;//场景的大小

	vector<CSprite*> m_vecSpriteTouch;//允许点击的精灵
};

#endif

