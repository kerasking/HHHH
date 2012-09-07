#ifndef _ASTAR_H_
#define _ASTAR_H_

#include "NDMapLayer.h"
#include <deque>
#include <map>

using namespace NDEngine;

typedef struct _tagStructPos
{
	int x;
	int y;
} CMyPos;

typedef struct _tagStructNodeInfo
{
	int nX;
	int nY;
	int nG;
	int nH;
	int nStep;
	int nChildNum;
	int nDir;
	int nF;
	int nNumber;
	_tagStructNodeInfo* pParent;
	_tagStructNodeInfo* pChildNode[1024];
} NodeInfo;

typedef std::deque<NodeInfo*> DEQUE_NODE;
typedef std::map<int, NodeInfo*> MAP_NODE;

typedef bool (*CHECK_FUN)(NDMapLayer* maplayer, CMyPos& from, CMyPos& to);

class CAStar
{
public:
	CAStar();
	virtual ~CAStar();

private:
	DEQUE_NODE m_kSetNode;
	int m_nNodeIndex;

	MAP_NODE m_kSetOpen;
	MAP_NODE m_kSetClose;

	DEQUE_NODE m_kSetPath;

	CMyPos m_kPosStart;
	CMyPos m_kPosTarget;

	CMyPos m_kPosRealTarget;
	NodeInfo* m_pkNearestNode;

	unsigned long m_uMaxSerachTime;

	CHECK_FUN m_pCheckFun;

	int m_nMapWidth;
	int m_nMapHeight;

	bool m_bDoFindPath;
	NDMapLayer* m_pGamemap;
private:

	///\节点内存管理	
	void ClearNodeSet();
	inline NodeInfo* CreateNewNode();

	///\寻路算法
	NodeInfo* GetCurrentNode();
	void SearchChild(NodeInfo* pNode);
	void UpdateChildren(NodeInfo* pNode);
	bool CheckTarget();

	void GetPath(NodeInfo* pNode);

	inline NodeInfo* CheckList(MAP_NODE& list, int nNumber);
	inline void AddToList(MAP_NODE& list, NodeInfo* pNode);
	inline int GetHValue(const CMyPos& kPos);

public:
	///\路径管理
	BOOL FindPath(NDMapLayer *pGamemap, const CMyPos& posStart,
			const CMyPos& posTarget, unsigned long dwMaxSerachTime = 100,
			bool mustArrive = false);
	unsigned long GetPathAmount();
	NodeInfo* GetNodeByIndex(int nIndex);

	///\参数设置
	void SetAStarRange(int nMapWidth, int nMapHeight);
	void SetCheckMethod(CHECK_FUN pFun);

	void EndFindPath();

	DEQUE_NODE& GetAStarPath();
};
#endif
