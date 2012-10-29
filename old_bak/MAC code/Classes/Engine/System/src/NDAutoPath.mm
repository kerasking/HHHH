//
//  NDAutoPath.mm
//  MapDataPool
//
//  Created by jhzheng on 10-12-13.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NDAutoPath.h"
#import "NDConstant.h"
#import <sstream>
#import <stdlib.h>
#include "Performance.h"

namespace NDEngine
{
	IMPLEMENT_CLASS(NDAutoPath, NDObject)
	
	static NDAutoPath	*shareAutoPath;
	
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
		m_pointVector.clear();
		
		SAFE_DELETE(m_astar);
	}
	
	void NDAutoPath::init()
	{
		m_pointVector.clear();
		
		m_nStep = 0;
		
		m_bIgnoreMask = false;
		
		m_bMustArrive = true;
		
		m_astar = new CAStar;
		
		m_astar->SetCheckMethod(checkCanPass);
	}
	
	/* 从某一个像素点自动寻路到另外一个像素点(结果通过getPathPointArray方法获取)
	 参数:fromPosition-起始像素点,toPoition-结束像素点,mapLayer-地图层指针,step-寻路间隔步数
	 */
	bool NDAutoPath::autoFindPath(CGPoint fromPosition, CGPoint toPosition, NDMapLayer* mapLayer, int step, bool mustarrive/*=false*/, bool ignoreMask/*=false*/)
	{
		if ( !mapLayer || !mapLayer->GetMapData() ) {
			return NO;
		}
		
		if (!m_astar) 
			return NO;
		
		PerformanceTestName("自动寻路");
		
		m_nStep = step;
		
		m_bIgnoreMask = ignoreMask;
		
		m_bMustArrive = mustarrive;
		
		fromPosition.x -= DISPLAY_POS_X_OFFSET;
		fromPosition.y -= DISPLAY_POS_Y_OFFSET;
		
		toPosition.x -= DISPLAY_POS_X_OFFSET;
		toPosition.y -= DISPLAY_POS_Y_OFFSET;
		
		m_pointVector.clear();
		
		CMyPos startPos, endPos;
		
		startPos.x = (int)fromPosition.x / MAP_UNITSIZE;
		startPos.y = (int)fromPosition.y / MAP_UNITSIZE;
		
		endPos.x	= (int)toPosition.x / MAP_UNITSIZE;
		endPos.y	= (int)toPosition.y / MAP_UNITSIZE;
		
		std::stringstream ss;
		

		ss << "\n开始寻路==================" << "\n"
		<< "寻路起始点[" << startPos.x << "," << startPos.y << "]\n"
		<< "寻路目标点[" << endPos.x << "," << endPos.y << "]\n";
		
		NDLog(@"%@", [NSString stringWithUTF8String:ss.str().c_str()]);
	
		
		m_astar->SetAStarRange([mapLayer->GetMapData() columns], [mapLayer->GetMapData() rows]);
		
		unsigned long maxTime = 1000*20;
		
		if (mustarrive)
		{
			maxTime = 1000 * 1000;
		}
		
		if (!m_astar->FindPath(mapLayer, startPos, endPos, maxTime, mustarrive))
			return NO;
		
		this->GetPath(mapLayer);
		
		return YES;
		
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
		 uint nStartCellX = (uint)m_curPixelX / 16;
		 uint nStartCellY = (uint)m_curPixelY / 16;
		 uint nEndCellX = (uint)m_targetPixelX / 16;
		 uint nEndCellY = (uint)m_targetPixelY / 16;
		 
		 ss << "\n本次寻路路径==================" << "\n";
		 
		 ss << "寻路起始:" << "[" << nStartCellX << "," << nStartCellY << "]"
		 << ", 寻路目标" << "[" << nEndCellX << "," << nEndCellY << "]\n";
		 */
		
		//ss << "[" << currentNode.x << "," << currentNode.y << "]";
		
		//ss << "\n路径结束==================\n";
		
		//NDLog(@"%@", [NSString stringWithUTF8String:ss.str().c_str()]);
	}
	
	
	/* 获取寻路后的得到的所有像素
	 　　返回值:向量引用(元素为CGPoint)
	 */
	const std::vector<CGPoint>& NDAutoPath::getPathPointVetor()
	{
		return m_pointVector;
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
	
	void NDAutoPath::GetPath(NDMapLayer* mapLayer)
	{
		if (!m_astar) return;
		
		DEQUE_NODE& path = m_astar->GetAStarPath();
		
		if (path.empty()) return;
		
		int nCount = (int)path.size();
		
	
		if (nCount > 1)
		{
			std::stringstream ss; 
			ss << "\n本次寻路路径==================" << "\n";
			ss << "总步数:" << nCount << "\n";
			//<< "寻路起始:" << "[" << nStartCellX << "," << nStartCellY << "]"
			//<< ", 寻路目标" << "[" << nEndCellX << "," << nEndCellY << "]"
			//<< "\n";
			for (int i = 0; i < nCount; i++) 
			{
				NodeInfo* pathnode = path[i];
				ss << "[" << pathnode->nX << "," << pathnode->nY << "]";
			}
			ss << "\n路径结束==================\n";
			
			NDLog(@"%@", [NSString stringWithUTF8String:ss.str().c_str()]);
		}

		if (nCount > 0)
		{
			NodeInfo* node = path[path.size() - 1];
			NDMapData *mapdata = mapLayer->GetMapData();
			if (node && mapdata && mapdata.switchs)
			{
				NSArray	*switchs = mapdata.switchs;
				for (int i = 0; i < (int)[switchs count]; i++)
				{
					NDMapSwitch *mapswitch = [switchs objectAtIndex:i];
					if (!mapswitch) continue;
					if (abs(mapswitch.x - node->nX) <= 2 && abs(mapswitch.y - node->nY) <= 2)
					{
						nCount = (int)path.size() - 1;
						break;
					}
				}
			}
		}
		do 
		{
			int iTimes = MAP_UNITSIZE / m_nStep;
			
			CGPoint pos;
			NodeInfo* node = path[0];
			pos.x = node->nX*MAP_UNITSIZE+DISPLAY_POS_X_OFFSET;
			pos.y = node->nY*MAP_UNITSIZE+DISPLAY_POS_Y_OFFSET;
			
			for (int index = 0; index < nCount-1; index++)
			{
				NodeInfo& first	= *(path[index]);
				NodeInfo& second = *(path[index+1]);

				if (first.nX > second.nX)
				{
					if (first.nY > second.nY)
					{
						for (int j=0; j<iTimes; j++)
						{
							// 加点
							pos.y				-= m_nStep;
							pos.x				-=	m_nStep;
							
							m_pointVector.push_back(pos);
						}
					}
					else if (first.nY < second.nY)
					{
						for (int j=0; j<iTimes; j++)
						{
							// 加点
							pos.y				+= m_nStep;
							pos.x				-=	m_nStep;
							
							m_pointVector.push_back(pos);
						}
					}
					else if (first.nY == second.nY)
					{
						for (int j=0; j<iTimes; j++)
						{
							// 加点
							pos.x				-=	m_nStep;
		
							m_pointVector.push_back(pos);
						}
					}
				}
				else if (first.nX < second.nX)
				{
					if (first.nY > second.nY)
					{
						for (int j=0; j<iTimes; j++)
						{
							// 加点
							pos.y				-= m_nStep;
							pos.x				+=	m_nStep;
							
							m_pointVector.push_back(pos);
						}
					}
					else if (first.nY < second.nY)
					{
						for (int j=0; j<iTimes; j++)
						{
							// 加点
							pos.y				+= m_nStep;
							pos.x				+=	m_nStep;
							
							m_pointVector.push_back(pos);
						}
					}
					else if (first.nY == second.nY)
					{
						for (int j=0; j<iTimes; j++)
						{
							// 加点
							pos.x				+=	m_nStep;
							
							m_pointVector.push_back(pos);
						}
					}
				}
				else if (first.nX == second.nX)
				{
					if (first.nY > second.nY)
					{
						for (int j=0; j<iTimes; j++)
						{
							// 加点
							pos.y				-= m_nStep;
							
							m_pointVector.push_back(pos);
						}
					}
					else if (first.nY < second.nY)
					{
						for (int j=0; j<iTimes; j++)
						{
							// 加点
							pos.y				+= m_nStep;
							
							m_pointVector.push_back(pos);
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
		if (!maplayer || !maplayer->GetMapData()) return false;
		
		if (NDAutoPath::sharedAutoPath()->isIgnoreMask()) {
			NDMapData *mapData = maplayer->GetMapData();
			if (to.y >= [mapData rows] 
				|| to.x >= [mapData columns]
				|| to.x <= 0
				|| to.y <= 0) {
				return false;
			}
			return true;
		}
		
		return [maplayer->GetMapData() canPassByRow:to.y andColumn:to.x];
	}
}