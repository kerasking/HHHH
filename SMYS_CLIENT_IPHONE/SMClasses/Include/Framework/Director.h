/*
场景的管理类
Copyright(c) 1999-2012, TQ Digital Entertainment, All Rights Reserved
*/
#ifndef __FRAMEWORK__DIRECTOR__H__
#define  __FRAMEWORK__DIRECTOR__H__
#include "FrameworkTypes.h"
#include "Scene.h"
#include <map>
using namespace std;

const unsigned int  INVALIDSCENE = 0xFFFFFFFF;//保留ID，非法的场景ID
const unsigned int  ACTIVESCENE = INVALIDSCENE-1;//当前活动的场景

//场景的管理类
class CDirector
{
public:
	//添加场景
	bool AddScene(CScene* sce);

	//移除场景
	bool RemoveScene(CScene* sce);
	bool RemoveScene(int nSceneID);

	//移除所有场景
	bool RemoveAllScenes();

	//设置当前活动场景
	bool SetActiveScene(CScene* sce);
	bool SetActiveScene(int nSceneID);

	//获取当前活动场景
	CScene* GetActiveScene();

	//根据场景ID，获取场景对象指针
	CScene* GetSceneByID(int nSceneID);

	//发送场景消息，由场景的MsgHandler处理。
	bool SendSceneMessage(int nSceneID, UINT nMsg, WPARAM wParam, LPARAM lParam);

public:
	static CDirector& sharedInstance(void);
	
private:
	virtual ~CDirector(void);
	CDirector(void);

private:
	typedef map<int, CScene*> SCENEMAP;
	SCENEMAP	m_mapScenes;
	int			m_nAcitveSceneID;
};
#endif


