#ifndef __UI_CTRL_IMAGE_EX__
#define __UI_CTRL_IMAGE_EX__

#include "CtrlImage.h"
#include "tools.h"

//图片控件,增加了设置文本的功能
class CCtrlImageEx : public CCtrlImage
{
protected:
	int m_verAlign;//控件垂直对齐方式
	int m_herAlign;//控件水平对齐方式
	CRect m_ShowRect;//在原图片上截取的要显示的区域大小
	CRect m_CntRect;//图片在屏幕上的区域
	bool m_bShowRect;//是否新设置了图片
	DWORD m_dwFontColor;//字体颜色
	
public:
	CCtrlImageEx();
	virtual ~CCtrlImageEx();

	//设置字体颜色
	void SetFontColor(DWORD dwFontColor);
	
	//设置字体大小
	void SetFontSize(int iFontSize);
	
	//设置文本
	void SetWindowText(const char* lpText, int verAlign=VERALIGN_CENTER, int herAlign=HERALIGN_CENTER);
	
	//用UTF8编码设置文本
	void SetWindowTextWithUTF8(const char* str, int verAlign=VERALIGN_CENTER, int herAlign=HERALIGN_CENTER);
	
	//设置图片显示区域
	void SetShowRect(CRect& showRect/*在原图片上截取的要显示的区域大小*/, CRect& cntRect/*图片在屏幕上的区域*/);
	
	//绘制控件的背景
	virtual void DoPaintBackground(CPoint& cntScreenOrg,CRect& showRect,CRect& cntRect,CPoint& viewOrg);
	
	//绘制控件的前景
	virtual void DoPaintForeground(CPoint& cntScreenOrg,CRect& showRect,CRect& cntRect,CPoint& viewOrg);
	
protected:
	char* m_lpText;//文本
	int m_iWidth;//文本的宽度
	
};

#endif
