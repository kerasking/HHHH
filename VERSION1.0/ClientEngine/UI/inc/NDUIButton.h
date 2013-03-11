/*
 *  NDUIButton.h
 *  DragonDrive
 *
 *  Created by wq on 10-12-29.
 *  Copyright 2010 (网龙)DeNA. All rights reserved.
 *
 *   modify by yay on 12-1-12
 *   add lua callback
 */

#ifndef __ND_UI_BUTTON_H__
#define __ND_UI_BUTTON_H__

#include "NDUINode.h"
#include <string>
#include "NDUILabel.h"
#include "NDUIScrollText.h"
#include "NDCombinePicture.h"
//#include "NDLightEffect.h"
#include "NDLightEffect.h"
#include "NDUIBaseItemButton.h"


NS_NDENGINE_BGN


//////////////////////////////////////////////////////////////////////////////////////////////
class NDUIButton;	
//delegates begin
class NDUIButtonDelegate
{
public:
//		
//		函数：OnButtonClick
//		作用：当按钮被点击之后框架调用该方法
//		参数：button被点击的按钮
//		返回值：无
	virtual void OnButtonClick(NDUIButton* button);
	virtual void OnButtonDown(NDUIButton* button);
	virtual void OnButtonUp(NDUIButton* button);
	virtual bool OnButtonLongClick(NDUIButton* button);
	virtual bool OnButtonDragOut(NDUIButton* button, CCPoint beginTouch, CCPoint moveTouch, bool longTouch);
	virtual bool OnButtonDragOutComplete(NDUIButton* button, CCPoint endTouch, bool outOfRange);
	virtual bool OnButtonDragIn(NDUIButton* desButton, NDUINode *uiSrcNode, bool longTouch);
	virtual bool OnButtonDragOver(NDUIButton* overButton, bool inRange);
	virtual bool OnButtonLongTouch(NDUIButton* button);
	virtual bool OnButtonLongTouchCancel(NDUIButton* button);
};
//delegates end


//////////////////////////////////////////////////////////////////////////////////////////////
class NDUIButton : public NDUIBaseItemButton
{
	DECLARE_CLASS(NDUIButton)
public:
	NDUIButton();
	~NDUIButton();
	
public:		
//		
//		函数：Initialization
//		作用：初始化按钮，必须被显示或者隐式调用
//		参数：无
//		返回值：无
	void Initialization(); override
//		
//		函数：SetImage
//		作用：设置按钮的图片
//		参数：pic图片，useCustomRect图片是否显示在自定义范围（相对于按钮的显示范围），customRect自定义范围
//		返回值：无
	void SetImage(NDPicture* pic, bool useCustomRect = false, CCRect customRect = CCRectZero, bool clearPicOnFree = false);
	void SetImageCustom(NDPicture* pic, bool useCustomRect = false, CCRect customRect = CCRectZero){
		this->SetImage(pic, useCustomRect, customRect, true);
	}
	
	void SetImageLua(NDPicture* pic);
//		
//		函数：SetCombineImage
//		作用：设置按钮的图片(组合)
//		参数：combinepic图片(组合)，useCustomRect图片是否显示在自定义范围（相对于按钮的显示范围），customRect自定义范围
//		返回值：无
	void SetCombineImage(NDCombinePicture* combinepic, bool useCustomRect = false, CCRect customRect = CCRectZero, bool clearPicOnFree = false);
//		
//		函数：SetTouchDownImage
//		作用：设置按钮被按下时的图片，调用该方法将使得SetTouchDownColor方法失效
//		参数：pic图片，useCustomRect图片是否显示在自定义范围（相对于按钮的显示范围），customRect自定义范围
//		返回值：无
	void SetTouchDownImage(NDPicture* pic, bool useCustomRect = false, CCRect customRect = CCRectZero, bool clearPicOnFree = false);	
	void SetTouchDownImageCustom(NDPicture* pic, bool useCustomRect = false, CCRect customRect = CCRectZero){
		this->SetTouchDownImage(pic, useCustomRect, customRect, true);
	}
	
	void SetTouchDownImageLua(NDPicture* pic);
//		
//		函数：SetTouchDownCombineImage
//		作用：设置按钮被按下时的图片(组合)，调用该方法将使得SetTouchDownColor方法失效
//		参数：pic图片，useCustomRect图片是否显示在自定义范围（相对于按钮的显示范围），customRect自定义范围
//		返回值：无
	void SetTouchDownCombineImage(NDCombinePicture* combinepic, bool useCustomRect = false, CCRect customRect = CCRectZero, bool clearPicOnFree = false);
	
//		
//		函数：SetTouchDownColor
//		作用：设置按钮被按下时的颜色，调用该方法将使得SetTouchDownImage方法失效
//		参数：touchDownColor颜色值rgba
//		返回值：无
	void SetTouchDownColor(cocos2d::ccColor4B touchDownColor);
//		
//		函数：SetFocusColor
//		作用：设置焦点时的颜色，调用该方法将使SetFocusRimImage和SetFocusNormal方法失效
//		参数：focusColor颜色值rgba
//		返回值：无
	void SetFocusColor(cocos2d::ccColor4B focusColor);		
//		
//		函数：SetFocusRimImage
//		作用：设置焦点时使用框架提供的一种边框，调用该方法将使SetFocusColor和SetFocusNormal方法失效
//		参数：无
//		返回值：无
	void SetFocusRimImage();
	
//		
//		函数：SetFocusNormal
//		作用：设置焦点时不做任何操作，调用该方法将使SetFocusColor和SetFocusRimImage方法失效
//		参数：无
//		返回值：无
	void SetFocusNormal();

//		
//		函数：SetFocusImage
//		作用：设置焦点时使用图片，调用该方法将使SetFocusColor,SetFocusNormal和SetFocusRimImage方法失效
//		参数：无
//		返回值：无
	void SetFocusImage(NDPicture *pic, bool useCustomRect = false, CCRect customRect = CCRectZero, bool clearPicOnFree = false);
	void SetFocusImageCustom(NDPicture *pic, bool useCustomRect = false, CCRect customRect = CCRectZero)
	{
		SetFocusImage(pic, useCustomRect, customRect, true);
	}
	
	void SetFocusImageLua(NDPicture *pic);

	void SetDisImage(NDPicture *pic, bool useCustomRect = false, CCRect customRect = CCRectZero, bool clearPicOnFree = false);
//		
//		函数：OpenFrame
//		作用：打开文字按钮的边框，如果时文字按钮则框架默认时打开的
//		参数：无
//		返回值：无
	void OpenFrame(){ m_framed = true; }
//		
//		函数：CloseFrame
//		作用：关闭文字按钮的边框
//		参数：无
//		返回值：无
	void CloseFrame(){ m_framed = false; }
public:
//		
//		函数：SetTitle
//		作用：设置按钮的文本信息
//		参数：title, bScroll是否自动滚动(超出按钮的长度就滚动,否则不滚动),　bForce强制滚动
//		返回值：无		
	void SetTitle(const char* title, bool bAutoScroll=true, bool bForce=false, unsigned int leftWidth=0, unsigned int rightWidth=0);
	
	void SetTitleLua(const char* title);
//	
//		函数：GetTitle
//		作用：获取按钮的文本信息
//		参数：无
//		返回值：文本信息
	std::string GetTitle();
//		
//		函数：SetFontColor
//		作用：设置按钮的字体颜色
//		参数：fontColor颜色值rgba
//		返回值：
	void SetFontColor(cocos2d::ccColor4B fontColor);
	
	void SetFocusFontColor(cocos2d::ccColor4B focusFontColor);
//		
//		函数：GetFontColor
//		作用：获取按钮的字体颜色
//		参数：无
//		返回值：颜色值rgba
	cocos2d::ccColor4B GetFontColor();
//		
//		函数：SetBackgroundColor
//		作用：设置按钮的背景色，默认值为黑色
//		参数：color颜色值rgba
//		返回值：无		
	void SetBackgroundColor(cocos2d::ccColor4B color);
	
//		
//		函数：SetBackgroundPicture
//		作用：设置按钮的背景图
//		参数：pic图片, clearPicOnFree托管释放
//		返回值：无		
	void SetBackgroundPicture(NDPicture *pic, NDPicture *touchPic = NULL, bool useCustomRect = false, CCRect customRect = CCRectZero, bool clearPicOnFree = false);
	void SetBackgroundPictureCustom(NDPicture *pic, NDPicture *touchPic = NULL, bool useCustomRect = false, CCRect customRect = CCRectZero){
		this->SetBackgroundPicture(pic, touchPic, useCustomRect, customRect, true);
	}
	
	void SetBackgroundPictureLua(NDPicture *pic, NDPicture *touchPic = NULL);
//		
//		函数：SetBackgroundColor
//		作用：设置按钮的背景组合图
//		参数：combinepic组合图片, clearPicOnFree托管释放
//		返回值：无		
	void SetBackgroundCombinePic(NDCombinePicture *combinepic, NDCombinePicture *touchCombinePic = NULL, bool clearPicOnFree = false);
	
//		
//		函数：SetFontSize
//		作用：设置按钮标题的字体大小
//		参数：fontSize字体大小，默认值为15
//		返回值：无
	void SetFontSize(unsigned int fontSize);
//		
//		函数：GetFontSize
//		作用：获取按钮标题的字体大小
//		参数：无
//		返回值：字体大小
	unsigned int GetFontSize();	
	
	//　显示两个标签(居中显示)的接口不能与显示一个标签的同时用,且暂时只需要设置接口,如需要获取接口再加
	void SetText(const char* text1, 
				 const char* text2,
				 unsigned int interaval = 0,
				 cocos2d::ccColor4B color1 = ccc4(11, 34, 18, 255),
				 cocos2d::ccColor4B color2 = ccc4(11, 34, 18, 255),
				 unsigned int fontSize1 = 13,
				 unsigned int fontSize2 = 13);
				 
	void SetArrow(bool bSet);
	
	void EnalbeGray(bool gray)
	{ 
		m_bGray = gray; 
		
		if (0 == m_disImage)
		{
			if (m_image) m_image->SetGrayState(gray); 
			if (m_picBG) m_picBG->SetGrayState(gray);
			if (m_picTouchBG) m_picTouchBG->SetGrayState(gray);
			if (m_touchDownImage) m_touchDownImage->SetGrayState(gray);
			if (m_focusImage) m_focusImage->SetGrayState(gray);
		}
	}
	
	bool IsGray() { return m_bGray; }
	
	
	void EnalbelBackgroundGray(bool gray) { if (m_picBG) m_picBG->SetGrayState(gray);
											if (m_picTouchBG) m_picTouchBG->SetGrayState(gray); 	
											}
	
	bool IsBackgroundGray() { if (m_picBG) return m_picBG->IsGrayState(); return false; }
	
	void SetNormalImageColor(cocos2d::ccColor4B color) { m_normalImageColor = color; }
	
	NDPicture* GetImage() { return m_image; }
	NDPicture* GetImageCopy() { if (m_image) return m_image->Copy(); return NULL; }
	void TabSel(bool bSel);
	bool IsTabSel();
	void ChangeSprite(const char* szSprite, CCPoint posOffset);
	void SetFocus(bool bFocus);
	void SetSoundEffect(int nId);
	int GetSoundEffect();

public:
	void draw();
	void drawFocus();
	void drawTouchDown();
	void drawButtonImage();
	void drawButtonFrame();
	void drawLongTouch();
	void SetFrameRect(CCRect rect); 
	void OnTouchDown(bool touched);
	void OnLongTouchDown(bool touched);
	//void SetChecked( bool bChecked ){ m_bChecked = bChecked; m_bGray = bChecked; }
	void SetChecked( bool bChecked ){ m_bTabSel = bChecked; m_bFocusEnable = bChecked; m_bChecked = bChecked;}

	
	bool CanDestroyOnRemoveAllChildren(NDNode* pNode);

	void enableHighlight( bool flag ) { bEnableHighlight = flag; }
	bool isHighlight() const;

public:
	void SetTitle();
	void SetTwoTitle();

protected: //pic
	NDPicture* m_image, *m_touchDownImage;
	NDPicture* m_rimImageLT, *m_rimImageRT, *m_rimImageLB, *m_rimImageRB;
	NDPicture* m_focusImage;
	NDPicture* m_disImage;
	NDUILabel* m_title;	

protected:
	NDCombinePicture *m_combinepicImg, *m_combinepicTouchDownImg;
	NDCombinePicture *m_combinePicBG, *m_combinePicTouchBG;
	NDPicture		 *m_picBG,  *m_picTouchBG;
	bool			 m_bClearBgOnFree;
	bool			 m_bArrow;
	//NDLightEffect	 *m_spriteArrow;

protected:
	//显示两个标签相关
	NDUILabel *m_lbTitle1, *m_lbTitle2;
	bool m_bNeedSetTwoTitle;
	unsigned m_uiTwoTitleInter;

protected:
	cocos2d::ccColor4B m_touchDownColor;
	cocos2d::ccColor4B m_focusColor;
	cocos2d::ccColor4B m_backgroundColor;
	cocos2d::ccColor4B m_normalImageColor;
	bool m_touched;
	bool m_longTouched;
	bool m_framed;
	bool m_useCustomRect, m_touchDownImgUseCustomRect;
	bool m_clearUpPicOnFree, m_clearDownPicOnFree;
	bool m_bCustomFocusImageRect;
	bool m_ClearFocusImageOnFree;
	bool m_useBackgroundCustomRect;
	int m_SoundEffectId;
	CCRect m_backgroundCustomRect;
	CCRect m_customRect;
	CCRect m_touchDownImgCustomRect;
	CCRect m_customFocusImageRect;
	CCRect m_customDisImageRect;

	bool m_bCustomDisImageRect;
	bool m_ClearDisImageOnFree;
	
	typedef enum
	{
		TouchDownNone,
		TouchDownImage,
		TouchDownColor
	}TouchDownStatus;
	TouchDownStatus m_touchDownStatus;
	
	typedef enum
	{
		FocusNone,
		FocusColor,
		FocusRimImage,
		FocusImage,
	}FocusStatus;
	FocusStatus m_focusStatus;
	bool m_bFocusEnable;

protected: //scroll text
	NDUIScrollText* m_scrtTitle;
	bool m_bAutoScroll, m_bForce;
	std::string m_strTitle;
	unsigned int m_uiTitleFontSize;
	cocos2d::ccColor4B m_colorTitle, m_colorFocusTitle;
	bool m_bNeedSetTitle;
	bool m_bScrollTitle;
			
	unsigned int	 m_uiTitleLeftWidth;
	unsigned int m_uiTitleRightWidth;
	bool			 m_bGray;
	bool m_bChecked;
	bool			 m_bTabSel;
	NDLightEffect* m_pSprite;
	CCPoint			m_posSprite;
	bool			bEnableHighlight;
};

NS_NDENGINE_END 

#endif