//
//  NDAutoPath.mm
//  MapDataPool
//
//  Created by jhzheng on 10-12-13.
//  Copyright 2010 (网龙)DeNA. All rights reserved.
//

#include "NDAutoPath.h"
#include "NDConstant.h"
#include <sstream>
#include <stdlib.h>
//#include "Performance.h"
#include "CCPointExtension.h"
#include "NDUtil.h"
#include "NDDirector.h"

namespace NDEngine
{
IMPLEMENT_CLASS(NDAutoPath, NDObject)

static NDAutoPath *shareAutoPath;

NDAutoPath::NDAutoPath()
{
	init();
}

/* 获取共享的自动寻路实例,如果未创建则创建
 返回值: 地图数据池
 */
NDAutoPath* NDAutoPath::sharedAutoPath()
{
	if (!shareAutoPath)
	{
		shareAutoPath = new NDAutoPath;
	}

	return shareAutoPath;
}

/* 释放共享的自动寻路实例
 */
void NDAutoPath::purgeSharedAutoPath()
{
	m_kPointVector.clear();

	CC_SAFE_DELETE (m_pkAStar);
}

void NDAutoPath::init()
{
	m_kPointVector.clear();

	m_nStep = 0;

	m_bIgnoreMask = false;

	m_bMustArrive = true;

	m_pkAStar = new CAStar;

	m_pkAStar->SetCheckMethod(checkCanPass);
}

/* 从某一个像素点自动寻路到另外一个像素点(结果通过getPathPointArray方法获取)
 参数:fromPosition-起始像素点,toPoition-结束像素点,mapLayer-地图层指针,step-寻路间隔步数
 */
bool NDAutoPath::autoFindPath(CCPoint kFromPosition, CCPoint kToPosition,
		NDMapLayer* pkMapLayer, int nStep, bool bMustArrive/*=false*/,
		bool bIgnoreMask/*=false*/)
{
	if (!pkMapLayer || !pkMapLayer->GetMapData())
	{
		return false;
	}

	if (!m_pkAStar)
		return false;

	//PerformanceTestName("自动寻路");

	m_nStep = nStep;

	m_bIgnoreMask = bIgnoreMask;

	m_bMustArrive = bMustArrive;

	kFromPosition.x -= DISPLAY_POS_X_OFFSET;
	kFromPosition.y -= DISPLAY_POS_Y_OFFSET;

	kToPosition.x -= DISPLAY_POS_X_OFFSET;
	kToPosition.y -= DISPLAY_POS_Y_OFFSET;

	m_kPointVector.clear();

	CMyPos kStartPos;
	CMyPos kEndPos;

	kStartPos.x = (int) kFromPosition.x / MAP_UNITSIZE;
	kStartPos.y = (int) kFromPosition.y / MAP_UNITSIZE;

	kEndPos.x = (int) kToPosition.x / MAP_UNITSIZE;
	kEndPos.y = (int) kToPosition.y / MAP_UNITSIZE;

	std::stringstream ss;

	ss << "\n开始寻路==================" << "\n" << "寻路起始点[" << kStartPos.x << ","
			<< kStartPos.y << "]\n" << "寻路目标点[" << kEndPos.x << "," << kEndPos.y
			<< "]\n";

	//NDLog("%@", [NSString stringWithUTF8String:ss.str().c_str()]);

	m_pkAStar->SetAStarRange(pkMapLayer->GetMapData()->getColumns(),
			pkMapLayer->GetMapData()->getRows());

	unsigned long ulMaxTime = 1000 * 20;

	if (bMustArrive)
	{
		ulMaxTime = 1000 * 1000;
	}

	if (!m_pkAStar->FindPath(pkMapLayer, kStartPos, kEndPos, ulMaxTime, bMustArrive))
	{
		return false;
	}

	GetPath();

	return true;

	//if( !checkFromOnePosToAnother(posCur, posNext) && !ignoreMask )
	//if( ![m_PathSet count] )
	//		{
	//			if ( m_NearestNode && mustarrive)
	//			{//选择一条离终点最近的路径
	//				GetPath(m_NearestNode);
	//			}
	//			//无法到达
	//			return NO;
	//		}
	/*
	 std::stringstream ss;
	 unsigned int nStartCellX = (unsigned int)m_curPixelX / 16;
	 unsigned int nStartCellY = (unsigned int)m_curPixelY / 16;
	 unsigned int nEndCellX = (unsigned int)m_targetPixelX / 16;
	 unsigned int nEndCellY = (unsigned int)m_targetPixelY / 16;

	 ss << "\n本次寻路路径==================" << "\n";

	 ss << "寻路起始:" << "[" << nStartCellX << "," << nStartCellY << "]"
	 << ", 寻路目标" << "[" << nEndCellX << "," << nEndCellY << "]\n";
	 */

	//ss << "[" << currentNode.x << "," << currentNode.y << "]";
	//ss << "\n路径结束==================\n";
	//NDLog("%@", [NSString stringWithUTF8String:ss.str().c_str()]);
}

/* 获取寻路后的得到的所有像素
 返回值:向量引用(元素为CCPoint)
 */
const std::vector<CCPoint>& NDAutoPath::getPathPointVetor()
{
	return m_kPointVector;
}

/*
 unsigned int NDAutoPath::GetHValue(auto_path_pos pos)
 {
 int nDx = abs((long)(m_posTarget.x-pos.x));
 int nDy = abs((long)(m_posTarget.y-pos.y));

 if(nDx > nDy)
 return 10 * nDy;
 return 10 * nDx;

 }
 */

void NDAutoPath::GetPath()
{
	if (!m_pkAStar)
	{
		return;
	}

	DEQUE_NODE& kPath = m_pkAStar->GetAStarPath();

	if (kPath.empty())
	{
		return;
	}

	int nCount = (int) kPath.size();

	if (nCount > 1)
	{
		std::stringstream kStringStream;
		kStringStream << "\n本次寻路路径==================" << "\n";
		kStringStream << "总步数:" << nCount << "\n";

		for (int i = 0; i < nCount; i++)
		{
			NodeInfo* pathnode = kPath[i];
			kStringStream << "[" << pathnode->nX << "," << pathnode->nY << "]";
		}
		kStringStream << "\n路径结束==================\n";
	}

	do
	{
		int iTimes = MAP_UNITSIZE / m_nStep;

		CCPoint kPos;
		NodeInfo* pkNode = kPath[0];
// 		kPos.x = pkNode->nX * MAP_UNITSIZE + DISPLAY_POS_X_OFFSET;
// 		kPos.y = pkNode->nY * MAP_UNITSIZE + DISPLAY_POS_Y_OFFSET;//@del
		kPos = ConvertUtil::convertCellToDisplay( pkNode->nX, pkNode->nY );

		for (int index = 0; index < nCount - 1; index++)
		{
			NodeInfo& first = *(kPath[index]);
			NodeInfo& second = *(kPath[index + 1]);

			if (first.nX > second.nX)
			{
				if (first.nY > second.nY)
				{
					for (int j = 0; j < iTimes; j++)
					{
						// 加点
						kPos.y -= m_nStep;
						kPos.x -= m_nStep;

						m_kPointVector.push_back(kPos);
					}
				}
				else if (first.nY < second.nY)
				{
					for (int j = 0; j < iTimes; j++)
					{
						// 加点
						kPos.y += m_nStep;
						kPos.x -= m_nStep;

						m_kPointVector.push_back(kPos);
					}
				}
				else if (first.nY == second.nY)
				{
					for (int j = 0; j < iTimes; j++)
					{
						// 加点
						kPos.x -= m_nStep;

						m_kPointVector.push_back(kPos);
					}
				}
			}
			else if (first.nX < second.nX)
			{
				if (first.nY > second.nY)
				{
					for (int j = 0; j < iTimes; j++)
					{
						// 加点
						kPos.y -= m_nStep;
						kPos.x += m_nStep;

						m_kPointVector.push_back(kPos);
					}
				}
				else if (first.nY < second.nY)
				{
					for (int j = 0; j < iTimes; j++)
					{
						// 加点
						kPos.y += m_nStep;
						kPos.x += m_nStep;

						m_kPointVector.push_back(kPos);
					}
				}
				else if (first.nY == second.nY)
				{
					for (int j = 0; j < iTimes; j++)
					{
						// 加点
						kPos.x += m_nStep;

						m_kPointVector.push_back(kPos);
					}
				}
			}
			else if (first.nX == second.nX)
			{
				if (first.nY > second.nY)
				{
					for (int j = 0; j < iTimes; j++)
					{
						// 加点
						kPos.y -= m_nStep;

						m_kPointVector.push_back(kPos);
					}
				}
				else if (first.nY < second.nY)
				{
					for (int j = 0; j < iTimes; j++)
					{
						// 加点
						kPos.y += m_nStep;

						m_kPointVector.push_back(kPos);
					}
				}
				else if (first.nY == second.nY)
				{
				}
			}
		}
	} while (0);

	return;
}

//bool NDAutoPath::checkFromOnePosToAnother(auto_path_pos pos, auto_path_pos otherPos)
//	{
//		return [m_MapData canPassByRow:otherPos.y andColumn:otherPos.x];
//	}

bool NDAutoPath::isIgnoreMask()
{
	return m_bIgnoreMask;
}

bool checkCanPass(NDMapLayer* maplayer, CMyPos& from, CMyPos& to)
{
	if (!maplayer || !maplayer->GetMapData())
		return false;

	if (NDAutoPath::sharedAutoPath()->isIgnoreMask())
	{
		NDMapData *mapData = maplayer->GetMapData();
		if (!mapData || to.y >= mapData->getRows()
				|| to.x >= mapData->getColumns() || to.x <= 0 || to.y <= 0)
		{
			return false;
		}
		return true;
	}

	return maplayer->GetMapData()->canPassByRow(to.y, to.x);
}

}