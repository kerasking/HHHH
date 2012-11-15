/*
 *  NDPageButton.h
 *  DragonDrive
 *
 *  Created by wq on 11-3-21.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef __ND_PAGE_BUTTON_H__
#define __ND_PAGE_BUTTON_H__

#include "NDUILayer.h"
#include "NDUIButton.h"

using namespace NDEngine;

class IPageButtonDelegate {
public:
	virtual void OnPageChange(int nCurPage, int nTotalPage) { }
};

class NDPageButton :
public NDUILayer,
public NDUIButtonDelegate
{
	DECLARE_CLASS(NDPageButton)
public:
	NDPageButton();
	~NDPageButton();
	
	void OnButtonClick(NDUIButton* button);
	void Initialization(CCRect rectFrame);
	
	void SetDelegate(IPageButtonDelegate* delegate) {
		this->m_pageDelegate = delegate;
	}
	
	void SetPages(int nCurPage, int nTotalPage);
	
	int GetCurPage() const {
		return this->m_nCurPage;
	}
	
	int GetTotalPage() const {
		return this->m_nTotalPage;
	}
	
private:
	int m_nCurPage;
	int m_nTotalPage;
	
	NDUIButton* m_btnPrePage;
	NDUIButton* m_btnNextPage;
	
	NDUILabel* m_lbPages;
	
	IPageButtonDelegate* m_pageDelegate;
};

#endif