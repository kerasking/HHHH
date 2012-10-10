#ifndef __CMAPVIEW__HH__
#define __CMAPVIEW__HH__
#include <vector>
#include "graphic.h"
#include "uitypes.h"
using namespace std;
/**
  地图管理,可用于场景等
**/

class CMapView
{
public:
	CMapView(void);
	~CMapView(void);

	//显示
	bool Show(int iPosViewX/*视觉原点X*/,int iPosViewY/*视觉原点Y*/,int nAlpha = 0, DWORD dwShowWay = _SHOWWAY_NORMAL);

	//初次载入地图
	bool LoadMap(const char* pAniFileName/*文件路径*/,  int nColCount/*横坐标列数*/,int nRowCount/*行数*/, int nImageSize = 256/*单个地图块宽度*/);
	
	//设置地图的显示区域(参数默认0则显示区域为屏幕大小)
	void SetShowSize(int iWidht=0/*默认0则显示区域为屏幕大小*/,int iHeight=0);
	
	//获取地图块缓存大小
	int GetCacheSize() const;

	//设置地图块缓存大小
	void SetCacheSize(int iCacheSize);
	
	//世界坐标转屏幕坐标
	void World2d2Screen( int nWorldX, int nWorldY, int* pScreenX, int* pScreenY);
	
	//获取缩放大小
	float GetScale() const;

	//设置缩放大小
	BOOL SetScale(float val);

	//设置地图原始大小
	void SetMapSize(const CSize& mapSize);

	//设置缩放范围
	BOOL SetScaleRange(float fMinScale,float fMaxScale);
	
	//获取某一地图块的顶点坐标(即世界坐标--大地图的坐标)
	CPoint GetCellPos(int iRow/*行*/,int iCol/*列*/);
	
	//增加一个缓存地图块
	void AddCache(int iPndNum/*地图号*/);
	
	//获取屏幕显示的地图块的大小
	float GetCellWidth();
	
	//获取地图块列数
	int GetColCount() const;
	
	//获取地图块行数
	int GetRowCount() const;

	//获取最小缩放倍数
	float GetScaleMin() const;

	//获取最大缩放倍数
	float GetScaleMax() const;

protected:
	bool ReadFile(const char* newpath);
	BOOL OnSetScale(float minScale=0);
	int GetNumOfMap(int iPosViewX,int iPosViewY,int* startRow,int* startCol);

	typedef map<int,CMyBitmap*> MAP_BMP;//缓存表的小地图列表(地图号-对应图片)
	MAP_BMP m_mapCache;
	typedef std::vector<CMyBitmap*> VecBmp;
	VecBmp m_vecCache;//管理缓存
	vector<string> m_vecMapPng;//全部的小地图地址列表
	float m_fScale;//缩放倍数
	string m_szAniFileName;
	int m_nRowCount;
	int m_nColCount;
	int m_nImageSize;//单个地图块宽度
	int m_nCacheSize;//缓存地图块(默认20)
	CSize m_showSize;//显示区域
	CPoint m_posView;//屏幕坐标的原点的世界坐标
	float m_fScaleMin;//最小缩放倍数(默认.5f,并在载入图片设置场景大小后自动调整最小缩放倍数)
	float m_fScaleMax;//最大缩放倍数(默认1.f)
	CSize m_sizeMap;//原地图的大小

	int m_iStartYPre;//最近一次的初始地图Y坐标
	int m_iStartXPre;//最近一次的初始地图X坐标
	float m_fScalePre;
	//int m_iNeedCachePre;//

};
#endif //__CMAPVIEW__HH__
/*
  使用方法:
#define X_NUM 13
#define Y_NUM 12 
#define MAP_WIDTH 256
const int iWidth=X_NUM*MAP_WIDTH-93;
const int iHeight=Y_NUM*MAP_WIDTH-(MAP_WIDTH-153);
CLoginScene::CLoginScene(void)
{
	//初次载入地图
	m_mapView.LoadMap("./ani/puzzle.ani",X_NUM,Y_NUM,MAP_WIDTH);
	
	//设置地图的显示区域
	m_mapView.SetShowSize();

	m_fSacle=.5f;
	SetScale(m_fSacle);
}

BOOL CLoginScene::SetScale(float fSacle)
{
	if (fSacle<m_mapView.GetScaleMin())
	{
		return FALSE;
	}

	m_mapView.SetMapSize(CSize(iWidth,iHeight));
	SetSceneSize(CSize(iWidth*m_fSacle,iHeight*m_fSacle));
	if(!m_mapView.SetScale(m_fSacle))
	{
		return FALSE;
	}

	OnMove(0,0);
	return TRUE;
}
**/