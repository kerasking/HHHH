//
//  NDAutoPath.h
//  MapDataPool
//
//  Created by jhzheng on 10-12-13.
//  Copyright 2010 (网龙)DeNA. All rights reserved.
//

#ifndef __NDAUTOPATH_H__
#define __NDAUTOPATH_H__

#include "NDMapLayer.h"
#include "NDObject.h"
#include "AStar.h"

namespace NDEngine
{
bool checkCanPass(NDMapLayer* maplayer, CMyPos& from, CMyPos& to);

class NDAutoPath: NDObject
{
	DECLARE_CLASS (NDAutoPath)
public:
	explicit NDAutoPath();

	/* 获取共享的自动寻路实例,如果未创建则创建
	 返回值: 地图数据池
	 */
	static NDAutoPath* sharedAutoPath();

	/* 释放共享的自动寻路实例
	 */
	void purgeSharedAutoPath();

	/* 从某一个像素点自动寻路到另外一个像素点(结果通过getPathPointArray方法获取)
	 参数:fromPosition-起始像素点,toPoition-结束像素点,mapLayer-地图层指针,step-寻路间隔步数
	 */
	bool autoFindPath(CGPoint kFromPosition, CGPoint kToPosition,
			NDMapLayer* pkMapLayer, int nStep, bool bMustarrive = false,
			bool bIgnoreMask = false);

	/* 获取寻路后的得到的所有像素
	 返回值:向量引用(元素为CGPoint)
	 */
	const std::vector<CGPoint>& getPathPointVetor();

	bool isIgnoreMask();

private:
	void init();

	//unsigned int GetHValue(auto_path_pos pos);

	void GetPath();

private:
	std::vector<CGPoint> m_pointVector;					// 寻路结果后得到的像素Vector
	bool m_bIgnoreMask, m_bMustArrive;
	CAStar* m_pkAStar;
	int m_nStep;
};

}
#endif //__NDAUTOPATH_H__
