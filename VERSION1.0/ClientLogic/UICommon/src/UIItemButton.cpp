/*
 *  UIItemButton.cpp
 *  SMYS
 *
 *  Created by jhzheng on 12-3-5.
 *  Copyright 2012 (网龙)DeNA. All rights reserved.
 *
 */

#include "UIItemButton.h"
#include "ItemUtil.h"
#include "NDUIImage.h"
#include "ItemImage.h"
#include "NDUILabel.h"
#include "ScriptGameLogic.h"
#include "NDDirector.h"
#include <sstream>

#include "CCPointExtension.h"
#include "NDUtility.h"
#include "NDPath.h"
#include "NDUIBaseGraphics.h"

#define TAG_ITEM_COUNT (34567)
#define TAG_ITEM_LOCK (34568)

IMPLEMENT_CLASS(CUIItemButton, NDUIButton)

CUIItemButton::CUIItemButton()
{
	m_unItemId		= 0;
	m_unItemType	= 0;
	m_bLock			= false;
	m_bShowAdapt	= true;
	m_unItemCount	= 0;
}

CUIItemButton::~CUIItemButton()
{
}

void CUIItemButton::InitializationItem()
{
	Initialization();
}

void CUIItemButton::SetItemFrameRect(CCRect rect)
{
	SetFrameRect(rect);
}

void CUIItemButton::CloseItemFrame()
{
	CloseFrame();
}

void CUIItemButton::SetItemBackgroundPicture(NDPicture *pic,
											NDPicture *touchPic /*= NULL*/, bool useCustomRect /*= false*/,
											CCRect customRect /*= CGRectZero*/, bool clearPicOnFree /*= false*/)
{
	SetBackgroundPicture(pic, touchPic, useCustomRect, customRect,
		clearPicOnFree);
}

void CUIItemButton::SetItemBackgroundPictureCustom(NDPicture *pic,
												  NDPicture *touchPic /*= NULL*/, bool useCustomRect /*= false*/,
												  CCRect customRect /*= CGRectZero*/)
{
	SetBackgroundPictureCustom(pic, touchPic, useCustomRect, customRect);
}

void CUIItemButton::SetItemTouchDownImage(NDPicture *pic,
									  bool useCustomRect /*= false*/, CCRect customRect /*= CGRectZero*/,
									  bool clearPicOnFree /*= false*/)
{
	SetTouchDownImage(pic, useCustomRect, customRect, clearPicOnFree);
}

void CUIItemButton::SetItemTouchDownImageCustom(NDPicture *pic,
											bool useCustomRect /*= false*/, CCRect customRect /*= CGRectZero*/)
{
	SetTouchDownImageCustom(pic, useCustomRect, customRect);
}

void CUIItemButton::SetItemFocusImage(NDPicture *pic,
									 bool useCustomRect /*= false*/, CCRect customRect /*= CGRectZero*/,
									 bool clearPicOnFree /*= false*/)
{
	SetFocusImage(pic, useCustomRect, customRect, clearPicOnFree);
}

void CUIItemButton::SetItemFocusImageCustom(NDPicture *pic,
										   bool useCustomRect /*= false*/, CCRect customRect /*= CGRectZero*/)
{
	SetFocusImageCustom(pic, useCustomRect, customRect);
}

void CUIItemButton::SetLock(bool bSet)
{
	m_bLock			= bSet;
	
	if (!m_bLock)
	{
		this->RemoveChild(TAG_ITEM_LOCK, true);
		return;
	}
	
	if (!this->GetChild(TAG_ITEM_LOCK))
	{
		NDPicture *pic	= NDPicturePool::DefaultPool()->AddPicture(GetSMImgPath("bg_grid_closed.png"));
		if (!pic)
		{
			return;
		}
		
		CCSize picSize	= pic->GetSize();
		CCRect rect	= this->GetFrameRect();
		rect.origin	= CCPointZero;
		if (picSize.width < rect.size.width)
		{
			rect.origin.x	= (rect.size.width - picSize.width) / 2;
			rect.size.width	= picSize.width;
		}
		if (picSize.height < rect.size.height)
		{
			rect.origin.y	= (rect.size.height - picSize.height) / 2;
			rect.size.height	= picSize.height;
		}
		NDUIImage* imgLock	= new NDUIImage;
		imgLock->Initialization();
		imgLock->SetFrameRect(rect);
		imgLock->SetPicture(pic, true);
		imgLock->SetTag(TAG_ITEM_LOCK);
		this->AddChild(imgLock);
		imgLock->SetVisible(this->IsVisibled());
	}
}

bool CUIItemButton::IsLock()
{
	return m_bLock;
}

void CUIItemButton::ChangeItem(unsigned int unItemId)
{
	m_unItemId					= unItemId;

	unsigned int nItemType		= GetItemInfoN(unItemId, ITEM_TYPE);
	
	this->ChangeItemType(nItemType);
	
	this->RefreshItemCount();
	
	if (unItemId > 0)
	{
		this->SetLock(false);
	}
}

unsigned int CUIItemButton::GetItemId()
{
	return m_unItemId;
}

void CUIItemButton::ChangeItemType(unsigned int unItemType)
{
	this->SetImage(NULL, false, CCRectZero, true);
	
	m_unItemType			= unItemType;
	
	unsigned int nIconIndex = GetItemDBN(unItemType, DB_ITEMTYPE_ICONINDEX);
	if (nIconIndex > 0)
	{
		NDPicture* pic	= ItemImage::GetSMItem(nIconIndex);
		if (pic)
		{
           pic->setScale(0.5f*RESOURCE_SCALE);
			if (!m_bShowAdapt)
			{
				CCSize size = pic->GetSize();
				CCRect frame = this->GetFrameRect();
				CCRect rect	= CCRectMake((frame.size.width - size.width) / 2, 
										 (frame.size.height - size.height) / 2, 
										 size.width, size.height);
				this->SetImage(pic, true, rect, true);
			}
			else
			{
				this->SetImage(pic, false, CCRectZero, true);
			}
		}
	}
}

unsigned int CUIItemButton::GetItemType()
{
	return m_unItemType;
}

void CUIItemButton::RefreshItemCount()
{
	unsigned int nItemCount		= 0;
	
	unsigned int nItemType		= GetItemInfoN(m_unItemId, ITEM_TYPE);
	
	if (IsItemCanChaiFen(nItemType))
	{
		nItemCount	= GetItemInfoN(m_unItemId, ITEM_AMOUNT);
	}
	
	this->ChangeItemCount(nItemCount);
}

unsigned int CUIItemButton::GetItemCount()
{
	return m_unItemCount;
}
void CUIItemButton::ChangeItemCount(unsigned int unItemCount)
{
	m_unItemCount	= unItemCount;
	if (unItemCount == 0)
	{
		this->RemoveChild(TAG_ITEM_COUNT, true);
		return;
	}
	
	NDNode *pNode		= this->GetChild(TAG_ITEM_COUNT);
	NDUILabel *pLabel	= NULL;
	if (!pNode || !pNode->IsKindOfClass(RUNTIME_CLASS(NDUILabel)))
	{
		this->RemoveChild(TAG_ITEM_COUNT, true);
		
		CCRect rect = this->GetFrameRect();
		
		pLabel		= new NDUILabel;
		pLabel->Initialization();
		pLabel->SetFontSize(14);
		pLabel->SetFontColor(ccc4(255, 204, 120, 255));
		pLabel->SetTag(TAG_ITEM_COUNT);
		pLabel->SetTextAlignment(LabelTextAlignmentRight);
		pLabel->SetFrameRect(CCRectMake(
							 0.125 * rect.size.width, 
							 0.5 * rect.size.height, 
							 0.75 * rect.size.width,
							 0.333 * rect.size.height));
		this->AddChild(pLabel);
	}
	else
	{
		pLabel		= (NDUILabel*)pNode;
	}
	
	std::stringstream ss; ss << unItemCount;
	pLabel->SetText(ss.str().c_str());
	pLabel->SetVisible(this->IsVisibled());
}

void CUIItemButton::SetShowAdapt(bool bShowAdapt)
{
	m_bShowAdapt	= bShowAdapt;
}

bool CUIItemButton::IsShowAdapt()
{
	return m_bShowAdapt;
}

void CUIItemButton::draw()
{
    //** chh 2012-06-22 **//
	//NDUIButton::draw();
    NDUINode::draw();
    
    if (this->IsVisibled()) 
    {
        if (m_bNeedSetTitle) 
        {
            SetTitle();
            m_bNeedSetTitle = false;
        }
        
        if (m_bNeedSetTwoTitle) 
        {
            SetTwoTitle();
            m_bNeedSetTwoTitle = false;
        }
        
        NDNode* parentNode = this->GetParent();
        if (parentNode) 
        {
            if (parentNode-IsKindOfClass(RUNTIME_CLASS(NDUILayer))) 
            {
                NDUILayer* uiLayer = (NDUILayer*)parentNode;
                
                CCRect scrRect = this->GetScreenRect();					
                
                //draw back ground
                if (m_picBG)
                {
                    if (m_useBackgroundCustomRect)
                        m_picBG->DrawInRect(CCRectMake(scrRect.origin.x + m_backgroundCustomRect.origin.x, 
                                                       scrRect.origin.y + m_backgroundCustomRect.origin.y, 
                                                       m_backgroundCustomRect.size.width,
                                                       m_backgroundCustomRect.size.height));
                    else
                        m_picBG->DrawInRect(scrRect);					
                }
                else if (m_combinePicBG)
                    m_combinePicBG->DrawInRect(scrRect);
                else
                  //  DrawRecttangle(scrRect, m_backgroundColor);
                
                
                if (m_bScrollTitle && m_scrtTitle && m_scrtTitle->GetParent() == this) 
                {
                    if (uiLayer->GetFocus() == this || IsTabSel())
                    {
                        // !run -> start
                        if (!m_scrtTitle->isRunning()) 
                        {
                            m_scrtTitle->Run();
                        }
                        
                        m_scrtTitle->SetFontColor(m_colorFocusTitle);
                        
                    }
                    else
                    {
                        // run -> stop -> resetpos
                        if (m_scrtTitle->isRunning()) 
                        {
                            m_scrtTitle->Stop();
                            m_scrtTitle->SetTextPos(CCPointMake(5.0f, 0.0f));
                        }
                        
                        m_scrtTitle->SetFontColor(m_colorTitle);
                    }
                }
                
                //bottom image
                if (m_image || m_combinepicImg) 
                {
                    if (!m_touched || NULL == m_touchDownImage) 
                    {
                        if (m_image) m_image->SetColor(m_normalImageColor);							
                        else if (m_combinepicImg) m_combinepicImg->SetColor(ccc4(255, 255, 255, 255));
                    }	
                    
                    //if (!IsTabSel() && ((m_touchDownStatus != TouchDownImage) || !m_touched || NULL == m_touchDownImage) )
                    {
                        if (m_useCustomRect) 
                        {
                            CCRect rect = CCRectMake(scrRect.origin.x + m_customRect.origin.x, 
                                                     scrRect.origin.y + m_customRect.origin.y, 
                                                     m_customRect.size.width, m_customRect.size.height);
                            if (m_touched && NULL == m_touchDownImage && m_touchDownStatus == TouchDownImage)
                            {
                                float fScale		= RESOURCE_SCALE;
                                
                                /*
                                rect.origin.x		-= 5* fScale;
                                rect.origin.y		-= 5 * fScale;
                                rect.size.width		+= 10* fScale;
                                rect.size.height	+= 10* fScale;
                                 */
                            }
                            if (m_image) m_image->DrawInRect(rect);
                            else if (m_combinepicImg) m_combinepicImg->DrawInRect(rect);
                        }
                        else 
                        {
                            CCRect rect		= scrRect;
                            if (m_touched && NULL == m_touchDownImage && m_touchDownStatus == TouchDownImage)
                            {
                                float fScale		= RESOURCE_SCALE;
                                /*
                                
                                rect.origin.x		-= 5* fScale;
                                rect.origin.y		-= 5 * fScale;
                                rect.size.width		+= 10* fScale;
                                rect.size.height	+= 10* fScale;
                                 */
                            }
                            if (m_image) m_image->DrawInRect(rect);
                            else if (m_combinepicImg) m_combinepicImg->DrawInRect(rect);
                        }
                    }						
                }
                else 
                {
                    if (m_framed) 
                    {
					    DrawPolygon(scrRect, ccc4(16, 56, 66, 255), 2);
                      DrawPolygon(CCRectMake(scrRect.origin.x + 3, scrRect.origin.y + 3, scrRect.size.width - 6, scrRect.size.height - 6), 
                                   ccc4(134, 39, 0, 255), 1);						
                      
						//左上角
						DrawLine(ccp(scrRect.origin.x + 3, scrRect.origin.y + 8), 
							     ccp(scrRect.origin.x + 8, scrRect.origin.y + 3), 
							     ccc4(134, 39, 0, 255), 1);

						//右上角                    
						DrawLine(ccp(scrRect.origin.x + scrRect.size.width - 3, scrRect.origin.y + 8), 
								 ccp(scrRect.origin.x + scrRect.size.width - 8, scrRect.origin.y + 3), 
							     ccc4(134, 39, 0, 255), 1);

						//左下角                       
						DrawLine(ccp(scrRect.origin.x + 3, scrRect.origin.y + scrRect.size.height - 8), 
								 ccp(scrRect.origin.x + 8, scrRect.origin.y + scrRect.size.height - 3), 
								 ccc4(134, 39, 0, 255), 1);

						//右下角                      
						DrawLine(ccp(scrRect.origin.x + scrRect.size.width - 3, scrRect.origin.y + scrRect.size.height - 8), 
								 ccp(scrRect.origin.x + scrRect.size.width - 8, scrRect.origin.y + scrRect.size.height - 3), 
								 ccc4(134, 39, 0, 255), 1);
                    }						
                }	
            
				 #if 0
 if (m_bArrow) 
                {
                    DrawPolygon(scrRect, ccc4(255, 0, 0, 255), 4);
                    

                    if (!m_spriteArrow) 
                    {
                        m_spriteArrow = new NDLightEffect;
                        m_spriteArrow->Initialization(NDPath::GetAniPath("button.spr"));
                        m_spriteArrow->SetLightId(0, false);
                        m_spriteArrow->SetPosition(ccpAdd(scrRect.origin, ccp(scrRect.size.width*5/6, scrRect.size.height*1/3)));
                    }
                    
                    if (m_spriteArrow) m_spriteArrow->Run(CCSizeMake(480, 320));

                }
#endif
                
                if (m_pSprite)
                {
                    //m_pSprite->SetPosition(ccpAdd(scrRect.origin, m_posSprite));
                    m_pSprite->Run( CCDirector::sharedDirector()->getWinSizeInPixels() );
                }             
                
                
                
                //draw touch down status
                //if (m_touched && !m_longTouched) 
                {
                    float scale = RESOURCE_SCALE;
                    CCRect scrRectBig = scrRect;
                    
                    //边框放大
                    
                    scrRectBig.origin.x -= 1*scale;
                    scrRectBig.origin.y -= 1*scale;
                    scrRectBig.size.width +=2*scale;
                    scrRectBig.size.height +=2*scale;
                     
                    
                    if (m_picTouchBG) m_picTouchBG->DrawInRect(scrRect);
                    
                    if (m_combinePicTouchBG) m_combinePicTouchBG->DrawInRect(scrRect);
                    
                    if (m_touchDownStatus == TouchDownImage) 
                    {
                        
                        if (m_touchDownImage) 
                        {
                            if (m_touchDownImgUseCustomRect) 
                            {
                                m_touchDownImage->DrawInRect(CCRectMake(scrRect.origin.x + m_touchDownImgCustomRect.origin.x, 
                                                                        scrRect.origin.y + m_touchDownImgCustomRect.origin.y, 
                                                                        m_touchDownImgCustomRect.size.width, m_touchDownImgCustomRect.size.height));
                            }
                            else 
                            {
                                m_touchDownImage->DrawInRect(scrRectBig);
                            }
                        }
                        else if (m_combinepicTouchDownImg)
                        {
                            if (m_touchDownImgUseCustomRect) 
                            {
                                m_combinepicTouchDownImg->DrawInRect(CCRectMake(scrRect.origin.x + m_touchDownImgCustomRect.origin.x, 
                                                                                scrRect.origin.y + m_touchDownImgCustomRect.origin.y, 
                                                                                m_touchDownImgCustomRect.size.width, m_touchDownImgCustomRect.size.height));
                            }
                            else 
                            {
                                m_combinepicTouchDownImg->DrawInRect(scrRectBig);
                            }
                        }
                        
                    }
                    else if (m_touchDownStatus == TouchDownColor)
                    {
                        if (m_image) 
                            m_image->SetColor(m_touchDownColor);
                        else if (m_combinepicImg)
                            m_combinepicImg->SetColor(m_touchDownColor);
                        
						   else							
                           DrawRecttangle(scrRectBig, m_touchDownColor);
                    }						
                }	
                
                
                //draw focus 
                if (uiLayer->GetFocus() == this || IsTabSel()) 
                {
                    if (m_focusStatus == FocusColor && m_bFocusEnable) 
                    {
                        DrawRecttangle(scrRect, m_focusColor);
                        if (m_title) 
                        {
                            m_title->SetFontColor(m_colorFocusTitle);
                        }
                    }
                    else if (m_focusStatus == FocusRimImage && m_bFocusEnable)
                    {
                        DrawRecttangle(scrRect, ccc4(138, 8, 8, 255));
                        
                        m_rimImageLT->DrawInRect(CCRectMake(scrRect.origin.x - 2, 
                                                            scrRect.origin.y - 3, 
                                                            m_rimImageLT->GetSize().width, m_rimImageLT->GetSize().height));
                        
                        m_rimImageRT->DrawInRect(CCRectMake(scrRect.origin.x + scrRect.size.width - m_rimImageRT->GetSize().width + 2, 
                                                            scrRect.origin.y - 3, 
                                                            m_rimImageRT->GetSize().width, m_rimImageRT->GetSize().height));
                        
                        m_rimImageLB->DrawInRect(CCRectMake(scrRect.origin.x - 2, 
                                                            scrRect.origin.y + scrRect.size.height - m_rimImageLB->GetSize().height + 3, 
                                                            m_rimImageLB->GetSize().width, m_rimImageLB->GetSize().height));
                        
                        m_rimImageRB->DrawInRect(CCRectMake(scrRect.origin.x + scrRect.size.width - m_rimImageRT->GetSize().width + 2, 
                                                            scrRect.origin.y + scrRect.size.height - m_rimImageLB->GetSize().height +3, 
                                                            m_rimImageRB->GetSize().width, m_rimImageRB->GetSize().height));
                        
                        int d = 0;
                        if (scrRect.origin.x < CCDirector::sharedDirector()->getWinSizeInPixels().width / 2) 
                        {
                            d = 1;
                        }
                        //left frame
							DrawLine(ccp(scrRect.origin.x + d, scrRect.origin.y + m_rimImageLT->GetSize().height - 8), 
                                 ccp(scrRect.origin.x + d, scrRect.origin.y + scrRect.size.height - m_rimImageLT->GetSize().height + 8), 
                                 ccc4(172, 159, 71, 255), 1);
                        DrawLine(ccp(scrRect.origin.x + d + 1, scrRect.origin.y + m_rimImageLT->GetSize().height - 8), 
                                 ccp(scrRect.origin.x + d + 1, scrRect.origin.y + scrRect.size.height - m_rimImageLT->GetSize().height + 8), 
                                 ccc4(255, 233, 86, 255), 1);
                        DrawLine(ccp(scrRect.origin.x + d + 2, scrRect.origin.y + m_rimImageLT->GetSize().height - 8), 
                                 ccp(scrRect.origin.x + d + 2, scrRect.origin.y + scrRect.size.height - m_rimImageLT->GetSize().height + 8), 
                                 ccc4(172, 159, 71, 255), 1);
                        
                        //right frame
                        DrawLine(ccp(scrRect.origin.x + scrRect.size.width + d - 1, scrRect.origin.y + m_rimImageRT->GetSize().height - 8), 
                                 ccp(scrRect.origin.x + scrRect.size.width + d - 1, scrRect.origin.y + scrRect.size.height - m_rimImageRT->GetSize().height + 8), 
                                 ccc4(172, 159, 71, 255), 1);
                        DrawLine(ccp(scrRect.origin.x + scrRect.size.width + d - 2, scrRect.origin.y + m_rimImageRT->GetSize().height - 8), 
                                 ccp(scrRect.origin.x + scrRect.size.width + d - 2, scrRect.origin.y + scrRect.size.height - m_rimImageRT->GetSize().height + 8), 
                                 ccc4(255, 233, 86, 255), 1);
                        DrawLine(ccp(scrRect.origin.x + scrRect.size.width + d - 3, scrRect.origin.y + m_rimImageRT->GetSize().height - 8), 
                                 ccp(scrRect.origin.x + scrRect.size.width + d - 3, scrRect.origin.y + scrRect.size.height - m_rimImageRT->GetSize().height + 8), 
                                 ccc4(172, 159, 71, 255), 1);
                        
                        //top frame
                        DrawLine(ccp(scrRect.origin.x + m_rimImageLT->GetSize().width - 8, scrRect.origin.y), 
                                 ccp(scrRect.origin.x + scrRect.size.width - m_rimImageLT->GetSize().width + 8, scrRect.origin.y), 
                                 ccc4(172, 159, 71, 255), 1);
                        DrawLine(ccp(scrRect.origin.x + m_rimImageLT->GetSize().width - 8, scrRect.origin.y + 1), 
                                 ccp(scrRect.origin.x + scrRect.size.width - m_rimImageLT->GetSize().width + 8, scrRect.origin.y + 1), 
                                 ccc4(255, 233, 86, 255), 1);
                        DrawLine(ccp(scrRect.origin.x + m_rimImageLT->GetSize().width - 8, scrRect.origin.y + 2), 
                                 ccp(scrRect.origin.x + scrRect.size.width - m_rimImageLT->GetSize().width + 8, scrRect.origin.y + 2), 
                                 ccc4(172, 159, 71, 255), 1);
                        
                        //bottom frame
                        DrawLine(ccp(scrRect.origin.x + m_rimImageLT->GetSize().width - 8, scrRect.origin.y + scrRect.size.height - 1), 
                                 ccp(scrRect.origin.x + scrRect.size.width - m_rimImageLT->GetSize().width + 8, scrRect.origin.y + scrRect.size.height - 1), 
                                 ccc4(172, 159, 71, 255), 1);
                        DrawLine(ccp(scrRect.origin.x + m_rimImageLT->GetSize().width - 8, scrRect.origin.y + scrRect.size.height - 2), 
                                 ccp(scrRect.origin.x + scrRect.size.width - m_rimImageLT->GetSize().width + 8, scrRect.origin.y + scrRect.size.height - 2), 
                                 ccc4(255, 233, 86, 255), 1);
                        DrawLine(ccp(scrRect.origin.x + m_rimImageLT->GetSize().width - 8, scrRect.origin.y + scrRect.size.height - 3), 
                                 ccp(scrRect.origin.x + scrRect.size.width - m_rimImageLT->GetSize().width + 8, scrRect.origin.y + scrRect.size.height - 3), 
                                 ccc4(172, 159, 71, 255), 1);
						
                    }
                    else if (m_focusStatus == FocusImage && m_focusImage && m_bFocusEnable)
                    {
                        if (m_bCustomFocusImageRect) 
                        {
                            m_focusImage->DrawInRect(CCRectMake(scrRect.origin.x + m_customFocusImageRect.origin.x, 
                                                                scrRect.origin.y + m_customFocusImageRect.origin.y, 
                                                                m_customFocusImageRect.size.width, m_customFocusImageRect.size.height));
                        }
                        else 
                        {
                            m_focusImage->DrawInRect(scrRect);
                        }
                    }
                }
                else 
                {
                    if (m_title) 
                    {
                        m_title->SetFontColor(m_colorTitle);
                    }
                }
                
                
                
                //按下放大效果
                if (m_longTouched)
                {
                    NDPicture *pic = m_image ? m_image : m_picBG;
                    
                    if (pic)
                    {
                        
                        pic->SetColor(ccc4(255, 255, 255, 255));
                        float fScale = RESOURCE_SCALE;
                        CCRect rect = CCRectMake(scrRect.origin.x - 3 * fScale, 
                                                 scrRect.origin.y - 3 * fScale, 
                                                 scrRect.size.width + 6 * fScale, 
                                                 scrRect.size.height + 6 * fScale);
                        
                        //背景放大
                        if(m_picBG){
                            m_picBG->DrawInRect(rect);
                        }
                        
                        //物品图片
                        pic->DrawInRect(rect);
                        
                        
                        //边框放大（select）                   
						   if(m_touchDownImage){
                            
                            float scale = RESOURCE_SCALE;
                            CCRect scrRectBig = rect;
                            scrRectBig.origin.x -= 1*scale;
                            scrRectBig.origin.y -= 1*scale;
                            scrRectBig.size.width +=2*scale;
                            scrRectBig.size.height +=2*scale;
                            
                            
                            m_touchDownImage->DrawInRect(scrRectBig);
                        }
                        
                        
                        //选中焦点
                        if(m_focusImage){
                            m_focusImage->DrawInRect(rect);
                        }
                        
                    }
                }
 			
                
                
            }			
        }
        
    }
    
    
	
	/*
	 CCRect scrRect = this->GetScreenRect();
	 
	 DrawLine(scrRect.origin, 
	 ccpAdd(scrRect.origin, ccp(scrRect.size.width, 0)),
	 ccc4(255, 255, 0, 255), 5);
	 
	 DrawLine(ccpAdd(scrRect.origin, ccp(scrRect.size.width, 0)),
	 ccpAdd(scrRect.origin, ccp(scrRect.size.width, scrRect.size.height)),
	 ccc4(255, 255, 0, 255), 5);
	 
	 DrawLine(ccpAdd(scrRect.origin, ccp(scrRect.size.width, scrRect.size.height)),
	 ccpAdd(scrRect.origin, ccp(0, scrRect.size.height)),
	 ccc4(255, 255, 0, 255), 5);
	 
	 DrawLine(ccpAdd(scrRect.origin, ccp(0, scrRect.size.height)),
	 scrRect.origin,
	 ccc4(255, 255, 0, 255), 5);*/
	 
}