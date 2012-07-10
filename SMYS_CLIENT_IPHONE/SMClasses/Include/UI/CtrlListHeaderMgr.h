/*
 *  CCtrlListHeaderMgr.h
 *  列表的升降顺序排列管理类
 *  Copyright 2011 TQ Digital Entertainment. All rights reserved.
 *
 */
#ifndef __CCTRLLISTHEADERMGR__H_
#define __CCTRLLISTHEADERMGR__H_

#include <map>
#include <string>

using namespace std;

/**
  CCtrlList列表的升降顺序排列管理
**/
class CCtrlList;
class CCtrlListHeaderMgr
{
public:
    CCtrlListHeaderMgr();
    virtual ~CCtrlListHeaderMgr();

private:
    typedef pair<int, string> HeadPair;
    typedef map<int, HeadPair> HeadInfoMap;

    HeadInfoMap m_HeaderInfoMap;
    int m_iStatus;  //升序 2; 降序 1
    int m_iCurSel;  //当前选中项

    CCtrlList* m_pListCtrl;//管理的列表控件

public:
	//设置管理的列表控件
    void SetListCtrl(CCtrlList* pCtrlList);

    void AddHeaderInfo(int index, int iParam);

	//
    bool ClickListCtrlHeader(int index, int &iParam, int &iStatus);
};


#endif //__CCTRLLISTHEADERMGR__H_
