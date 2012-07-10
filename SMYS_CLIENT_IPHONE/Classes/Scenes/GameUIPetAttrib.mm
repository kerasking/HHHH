/*
 *  GameUIPetAttrib.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-1-25.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#import "GameUIPetAttrib.h"
#import "NDUIFrame.h"
#import "NDUIMenuLayer.h"
#import "NDPicture.h"
#import "NDManualRole.h"
#import "NDUILabel.h"
#import "NDUIButton.h"
#import "NDDirector.h"
#import "CGPointExtension.h"
#import "NDUIBaseGraphics.h"
#import "NDUITableLayer.h"
#import "NDUIImage.h"
#import "define.h"
#import "NDPlayer.h"
#import "NDConstant.h"
#import "ItemMgr.h"
#import "EnumDef.h"
#import "NDMsgDefine.h"
#import "NDDataTransThread.h"
#import "Item.h"
#import "ItemMgr.h"
#import "GameScene.h"
#import "NDUtility.h"
#import "define.h"
#include "NDBattlePet.h"
#include "NDMapMgr.h"
#import <sstream>
#import <string>

using namespace std;
using namespace NDEngine;

//IMPLEMENT_CLASS(GamePetNode, NDUILayer)
//
//int GamePetNode::lookface = 0;
//
//GamePetNode::GamePetNode()
//{
//	m_faceRightPet = false;
//	m_bSelf = true;
//	m_Sprite = NULL;
//}
//
//GamePetNode::~GamePetNode()
//{
//	NDPlayer& player = NDPlayer::defaultHero();
//	
//	if (!player.battlepet || !player.battlepet->GetParent()) 
//	{
//		return;
//	}
//	
//	if (!player.isTeamLeader() && player.isTeamMember()) 
//	{
//		NDManualRole *leader = NDMapMgrObj.GetTeamLeader(player.teamId);
//		if (leader) leader->SetTeamToLastPos();
//	}
//	
//	if (!m_bSelf) 
//	{
//		return;
//	}
//	
//	if (player.battlepet)
//	{
//		player.battlepet->RemoveFromParent(false);
//		player.battlepet->SetPositionEx(m_petPostion);
//		player.battlepet->SetCurrentAnimation(MONSTER_MAP_STAND, m_faceRightPet);
//		if (m_petParent) 
//		{
//			m_petParent->AddChild(player.battlepet);
//		}
//	}
//	player.SetAction(false);
//}
//
//void GamePetNode::Initialization(bool bSelf/*=true*/)
//{
//	m_bSelf = bSelf;
//	
//	NDUILayer::Initialization();
//	this->SetBackgroundColor(ccc4(255, 255, 255, 0));
//	this->SetTouchEnabled(false);
//	
//	if (bSelf) 
//	{
//		if (!NDPlayer::defaultHero().battlepet) 
//		{
//			NDLog(@"战宠不存在...");
//			return;
//		}
//		
//		m_petParent = NDPlayer::defaultHero().battlepet->GetParent();
//		if (!m_petParent && bSelf) 
//		{
//			NDLog(@"战宠对象没有父结点...");
//			return;
//		}
//		
//		NDPlayer::defaultHero().stopMoving();
//		
//		m_faceRightPet	= NDPlayer::defaultHero().battlepet->m_faceRight;
//		
//		NDPlayer::defaultHero().SetCurrentAnimation(MANUELROLE_STAND, NDPlayer::defaultHero().m_faceRight);
//		
//		NDPlayer::defaultHero().battlepet->SetCurrentAnimation(MANUELROLE_STAND, m_faceRightPet);
//		m_petPostion = NDPlayer::defaultHero().battlepet->GetPosition();
//		
//		NDPlayer::defaultHero().battlepet->RemoveFromParent(false);
//		this->AddChild(NDPlayer::defaultHero().battlepet);
//	}
//	else 
//	{
//		//确保lookface存在
//		m_Sprite = new NDSprite;
//		m_Sprite->SetNormalAniGroup(lookface);
//		m_Sprite->SetCurrentAnimation(0,true);
//		this->AddChild(m_Sprite);
//	}
//
//}
//
//void GamePetNode::draw()
//{
//	if (m_bSelf) 
//	{
//		if ( NDPlayer::defaultHero().battlepet )
//			NDPlayer::defaultHero().battlepet->RunAnimation(true);
//	}
//	else 
//	{
//		if (m_Sprite) 
//		{
//			m_Sprite->RunAnimation(true);
//		}
//	}
//}
//
//void GamePetNode::SetDisplayPos(CGPoint pos)
//{
//	if (m_bSelf) 
//	{
//		NDBattlePet *pet = NDPlayer::defaultHero().battlepet;
//		if ( pet )
//		{
//			int iH = pet->GetHeight()-32;
//			pet->SetPositionEx(ccp(pos.x, pos.y+iH));
//		}
//	}
//	else 
//	{
//		if (m_Sprite) 
//		{
//			int iH = m_Sprite->GetHeight()-32;
//			m_Sprite->SetPosition(ccp(pos.x, pos.y+iH));
//		}
//	}
//}

/////////////////////////////////////////////////////////

//#define prop_key_len (40)
//#define prop_min_len (60)
//#define prop_value_len (40)
//
//std::vector<int> getColorList(int t) 
//{
//	std::vector<int> res;
//	switch (t) {
//		case 0:
//		{ res.push_back(0x008aff); res.push_back(0x0066ff); } break;
//		case 1:
//		{ res.push_back(0x4258fd); res.push_back(0x0320f6); } break;
//		case 2:
//		{ res.push_back(0xfa69fc); res.push_back(0xf93afb); } break;
//		case 3:
//		{ res.push_back(0xfe4e56); res.push_back(0xff0000); } break;
//		case 4:
//		{ res.push_back(0xfee749); res.push_back(0xfddc01); } break;
//		default:
//		{ res.push_back(0x008aff); res.push_back(0x0066ff); }
//	}
//	
//	return res;
//}
//
//IMPLEMENT_CLASS(BasePropNode, NDUILayer)
//
//BasePropNode::BasePropNode()
//{
//	m_lbKey = NULL; m_lbValue = NULL;
//	m_picMinus = NULL; m_picAdd = NULL;
//	m_btnMinus = NULL; m_btnAdd = NULL;
//	m_bRecacl = true;
//	
//	for (int i = 0; i<4; i++) 
//	{
//		m_line[i] = NULL;
//	}
//}
//
//BasePropNode::~BasePropNode()
//{
//	SAFE_DELETE(m_picMinus);
//	SAFE_DELETE(m_picAdd);
//}
//
//void BasePropNode::Initialization() override
//{
//	NDUILayer::Initialization();
//	
//	for (int i=0; i<4; i++) 
//	{
//		m_line[i] = new NDUILine;
//		m_line[i]->Initialization();
//		m_line[i]->SetColor(ccc3(108, 130, 108));
//		m_line[i]->SetWidth(1);
//		this->AddChild(m_line[i]);
//	}
//	
//	m_picMinus = NDPicturePool::DefaultPool()->AddPicture(GetImgPath("plusMinus.png"));
//	m_picMinus->Cut(CGRectMake(8, 0, 9, 8));
//	
//	m_picAdd = NDPicturePool::DefaultPool()->AddPicture(GetImgPath("plusMinus.png"));
//	m_picAdd->Cut(CGRectMake(0, 0, 8, 8));
//
//	m_btnMinus = new NDUIButton;
//	m_btnMinus->Initialization();
//	m_btnMinus->SetVisible(false);
//	this->AddChild(m_btnMinus);
//	
//	m_btnAdd = new NDUIButton;
//	m_btnAdd->Initialization();
//	m_btnAdd->SetVisible(false);
//	this->AddChild(m_btnAdd);
//	
//	m_lbKey = new NDUILabel();
//	m_lbKey->Initialization();
//	m_lbKey->SetTextAlignment(LabelTextAlignmentCenter);
//	m_lbKey->SetFontSize(15);
//	m_lbKey->SetFontColor(ccc4(0, 0, 0, 255));
//	m_lbKey->SetVisible(false);
//	this->AddChild(m_lbKey);
//	
//	m_lbValue = new NDUILabel();
//	m_lbValue->Initialization();
//	m_lbValue->SetTextAlignment(LabelTextAlignmentCenter);
//	m_lbValue->SetFontSize(15);
//	m_lbValue->SetFontColor(ccc4(0, 0, 0, 255));
//	m_lbValue->SetVisible(false);
//	this->AddChild(m_lbValue);
//}
//
//void BasePropNode::draw() override
//{
//	if (!IsVisibled()) 
//	{
//		return;
//	}
//	NDUILayer::draw();
//	
//	CGRect scrRect = this->GetScreenRect();
//	
//	m_line[0]->SetFromPoint(ccp(scrRect.origin.x+1, scrRect.origin.y+1));
//	m_line[0]->SetToPoint(ccp(scrRect.origin.x+scrRect.size.width-1, scrRect.origin.y+1));
//	
//	m_line[1]->SetFromPoint(ccp(scrRect.origin.x+scrRect.size.width-1, scrRect.origin.y+1));
//	m_line[1]->SetToPoint(ccp(scrRect.origin.x+scrRect.size.width-1, scrRect.origin.y+scrRect.size.height-1));
//	
//	m_line[2]->SetFromPoint(ccp(scrRect.origin.x+scrRect.size.width-1, scrRect.origin.y+scrRect.size.height-1));
//	m_line[2]->SetToPoint(ccp(scrRect.origin.x+1, scrRect.origin.y+scrRect.size.height-1));
//	
//	m_line[3]->SetFromPoint(ccp(scrRect.origin.x+1, scrRect.origin.y+scrRect.size.height-1));
//	m_line[3]->SetToPoint(ccp(scrRect.origin.x+1, scrRect.origin.y+1));
//	
//	if (m_bRecacl) 
//	{
//		CGRect rect = GetFrameRect();
//		int iW = rect.size.width, iH = rect.size.height;
//		
//		m_lbKey->SetFrameRect(CGRectMake(0, 0, prop_key_len, iH));
//		m_lbKey->SetVisible(true);
//		m_lbValue->SetFrameRect(CGRectMake(prop_key_len+prop_min_len, 0, prop_value_len, iH));
//		m_lbValue->SetVisible(true);
//		
//		CGSize sizeMinus = m_picMinus->GetSize();
//		m_btnMinus->SetImage(m_picMinus, true, CGRectMake((prop_min_len-sizeMinus.width)/2, (iH-sizeMinus.height)/2, sizeMinus.width, sizeMinus.height));
//		m_btnMinus->SetFrameRect(CGRectMake(prop_key_len, 0, prop_key_len, iH));
//		m_btnMinus->SetVisible(true);
//		
//		CGSize sizeAdd = m_picAdd->GetSize();
//		int iAddW = iW - (prop_key_len+prop_value_len+prop_min_len);
//		m_btnAdd->SetImage(m_picAdd, true, CGRectMake((iAddW-sizeAdd.width)/2, (iH-sizeAdd.height)/2, sizeAdd.width, sizeAdd.height));
//		m_btnAdd->SetFrameRect(CGRectMake(prop_key_len+prop_value_len+prop_min_len, 0, iAddW, iH));
//		m_btnAdd->SetVisible(true);
//		
//		m_bRecacl = false;
//	}
//	
//	ccColor4B color;
//	if (this->GetParent() && this->GetParent()->IsKindOfClass(RUNTIME_CLASS(NDUILayer)) && ((NDUILayer*)(this->GetParent()))->GetFocus() == this) 		{
//		color = ccc4(255, 255, 0, 255);
//	}
//	else 
//	{
//		color = ccc4(231, 231, 222, 255);
//	}
//	
//	this->SetBackgroundColor(color);
//}
//
//void BasePropNode::SetKeyText(std::string text)
//{
//	if (m_lbKey) 
//	{
//		m_lbKey->SetText(text.c_str());
//	}
//}
//void BasePropNode::SetValue(std::string text)
//{
//	if (m_lbValue) 
//	{
//		m_lbValue->SetText(text.c_str());
//	}
//}
//void BasePropNode::SetValueColor(ccColor4B color)
//{
//	if (m_lbValue) 
//	{
//		m_lbValue->SetFontColor(color);
//	}
//}
//
///////////////////////////////////////////////////////////
//IMPLEMENT_CLASS(LayerProp, NDUILayer)
//
//LayerProp::LayerProp()
//{
//	m_lbName = NULL;
//	m_stateBar = NULL;
//	m_bRecacl = true;
//}
//
//LayerProp::~LayerProp()
//{
//}
//
//void LayerProp::Initialization() override
//{
//	NDUILayer::Initialization();
//	
//	m_lbName = new NDUILabel();
//	m_lbName->Initialization();
//	m_lbName->SetTextAlignment(LabelTextAlignmentCenter);
//	m_lbName->SetFontSize(15);
//	m_lbName->SetFontColor(ccc4(0, 0, 0, 255));
//	m_lbName->SetVisible(false);
//	this->AddChild(m_lbName);
//	
//	m_stateBar = new NDUIStateBar;
//	m_stateBar->Initialization();
//	m_stateBar->SetTouchEnabled(false);
//	m_stateBar->ShowNum(true);
//	m_stateBar->SetStateColor(ccc4(255, 0, 0,255));
//	m_stateBar->SetVisible(false);
//	this->AddChild(m_stateBar);
//}
//
//void LayerProp::draw() override
//{
//	if (!IsVisibled()) 
//	{
//		return;
//	}
//	NDUILayer::draw();
//	
//	if (m_bRecacl) 
//	{
//		CGRect rect = GetFrameRect();
//		int iW = rect.size.width, iH = rect.size.height;
//		CGSize sizetext = getStringSizeMutiLine(m_lbName->GetText().c_str(), 15, CGSizeMake(480, 320));
//		m_lbName->SetFrameRect(CGRectMake(0, 0, sizetext.width+4, iH));
//		m_lbName->SetVisible(false);
//		
//		m_stateBar->SetFrameRect(CGRectMake(sizetext.width+4, 2, iW-(sizetext.width+8), iH-2));
//		m_stateBar->SetVisible(true);
//		m_bRecacl = false;
//	}
//	
//	ccColor4B color;
//	if (this->GetParent() && this->GetParent()->IsKindOfClass(RUNTIME_CLASS(NDUILayer)) && ((NDUILayer*)(this->GetParent()))->GetFocus() == this) 
//	{
//		color = ccc4(255, 255, 0, 255);
//	}
//	else 
//	{
//		color = ccc4(231, 231, 222, 255);
//	}
//	
//	this->SetBackgroundColor(color);
//}
//
//void LayerProp::SetKeyText(std::string text)
//{
//	if (m_lbName) 
//	{
//		m_lbName->SetText(text.c_str());
//	}
//}
//
//void LayerProp::SetStateNum(int iCur, int iSum)
//{
//	if (m_stateBar) 
//	{
//		m_stateBar->SetNumber(iCur, iSum);
//	}
//}
//
//void LayerProp::SetColor(std::vector<int>& colors)
//{
//	if (int(colors.size()) < 2) 
//	{
//		return;
//	}
//	
//	if (m_stateBar) 
//	{
//		m_stateBar->SetStateColor(INTCOLORTOCCC4(colors[1]));
//		m_stateBar->SetSlideColor(INTCOLORTOCCC4(colors[0]));
//	}
//}
//
///////////////////////////////////////////////////////////
//
//#define title_image ([[NSString stringWithFormat:@"%s", GetImgPath("titles.png")] UTF8String])
//
//string strPetBasic[ePAB_End] = 
//{
//	NDCommonCString("Liliang"), 
//	NDCommonCString("TiZhi"), 
//	NDCommonCString("MingJie"), 
//	NDCommonCString("ZhiLi"), 
//};
//
//enum ePetAttrDetail 
//{
//	ePAD_Begin = 0,
//	ePAD_Name = ePAD_Begin,
//	ePAD_Bind,
//	ePAD_Quality,
//	ePAD_XingGe,
//	ePAD_InitLev,
//	ePAD_Age,
//	ePAD_Honyst,
//	ePAD_SkillNum,
//	ePAD_InitLiLiang,
//	ePAD_InitTizhi,
//	ePAD_InitMinJie,
//	ePAD_InitZhiLi,
//	ePAD_End,
//};
//
//string strPetDetail[ePAD_End] = 
//{
//	NDCommonCString("PetName"), 
//	NDCommonCString("BindState"), 
//	NDCommonCString("PingZhi"), 
//	NDCommonCString("XingGe"), 
//	NDCommonCString("ChuShiLvl"), 
//	NDCommonCString("ShouMing"), 
//	NDCommonCString("HonestVal"), 
//	NDCommonCString("SkillCao"), 
//	NDCommonCString("ChuShiLiLiang"), 
//	NDCommonCString("ChuShiTiZhi"), 
//	NDCommonCString("ChuShiMingJie"), 
//	NDCommonCString("ChuShiZhiLi")
//};
//
//enum ePetAttrAdvance 
//{
//	ePAA_Begin = 0,
//	ePAA_PhyAtk = ePAA_Begin,
//	ePAA_PhyDef,
//	ePAA_MagicAtk,
//	ePAA_MagicDef,
//	ePAA_AtkSpeed,
//	ePAA_HardHit,
//	ePAA_Dodge,
//	ePAA_PetHit,
//	ePAA_End,
//};
//
//string strPetAdvance[ePAA_End] = 
//{
//	NDCommonCString("PhyAtkVal"), 
//	NDCommonCString("PhyDef"), 
//	NDCommonCString("MagicAtkVal"), 
//	NDCommonCString("FaShuDef"), 
//	NDCommonCString("AtkSpeed"),
//	NDCommonCString("CriticalHit"), 
//	NDCommonCString("DuoShang"), 
//	NDCommonCString("hit")
//};
//
///////////////////////////////////////////////////////////////////
//IMPLEMENT_CLASS(GameUIPetAttrib, NDUILayer)
//
//std::string GameUIPetAttrib::str_PET_ATTR_NAME = ""; // 名字STRING
//int GameUIPetAttrib::int_PET_ATTR_LEVEL = 0; // 等级INT
//int GameUIPetAttrib::int_PET_ATTR_EXP = 0; // 经验INT
//int GameUIPetAttrib::int_PET_ATTR_LIFE = 0; // 生命值INT
//int GameUIPetAttrib::int_PET_ATTR_MAX_LIFE = 0; // 最大生命值INT
//int GameUIPetAttrib::int_PET_ATTR_MANA = 0; // 魔法值INT
//int GameUIPetAttrib::int_PET_ATTR_MAX_MANA = 0; // 最大魔法值INT
//int GameUIPetAttrib::int_PET_ATTR_STR = 0; // 力量INT
//int GameUIPetAttrib::int_PET_ATTR_STA = 0; // 体质INT
//int GameUIPetAttrib::int_PET_ATTR_AGI = 0; // 敏捷INT
//int GameUIPetAttrib::int_PET_ATTR_INI = 0; // 智力INT
//int GameUIPetAttrib::int_PET_ATTR_LEVEL_INIT = 0; // 初始等级INT
//int GameUIPetAttrib::int_PET_ATTR_STR_INIT = 0; // 初始力量INT
//int GameUIPetAttrib::int_PET_ATTR_STA_INIT = 0; // 初始体质INT
//int GameUIPetAttrib::int_PET_ATTR_AGI_INIT = 0; // 初始敏捷INT
//int GameUIPetAttrib::int_PET_ATTR_INI_INIT = 0; // 初始智力INT
//int GameUIPetAttrib::int_PET_ATTR_LOYAL = 0; // 忠诚度INT
//int GameUIPetAttrib::int_PET_ATTR_AGE = 0; // 寿命INT
//int GameUIPetAttrib::int_PET_ATTR_FREE_SP = 0; // 剩余技能点数INT
//int GameUIPetAttrib::int_PET_PHY_ATK_RATE = 0;//物攻资质
//int GameUIPetAttrib::int_PET_PHY_DEF_RATE = 0;//物防资质
//int GameUIPetAttrib::int_PET_MAG_ATK_RATE = 0;//法攻资质
//int GameUIPetAttrib::int_PET_MAG_DEF_RATE = 0;//法防资质
//int GameUIPetAttrib::int_PET_ATTR_HP_RATE = 0; // 生命资质
//int GameUIPetAttrib::int_PET_ATTR_MP_RATE = 0; // 魔法资质
//int GameUIPetAttrib::int_PET_MAX_SKILL_NUM = 0;//最大可学技能数
//int GameUIPetAttrib::int_PET_SPEED_RATE = 0;//速度资质
//
//int GameUIPetAttrib::int_PET_PHY_ATK_RATE_MAX = 0;//物攻资质上限
//int GameUIPetAttrib::int_PET_PHY_DEF_RATE_MAX = 0;//物防资质上限
//int GameUIPetAttrib::int_PET_MAG_ATK_RATE_MAX = 0;//法攻资质上限
//int GameUIPetAttrib::int_PET_MAG_DEF_RATE_MAX = 0;//法防资质上限
//int GameUIPetAttrib::int_PET_ATTR_HP_RATE_MAX = 0; // 生命资质上限
//int GameUIPetAttrib::int_PET_ATTR_MP_RATE_MAX = 0; // 魔法资质上限
//int GameUIPetAttrib::int_PET_SPEED_RATE_MAX = 0;//速度资质上限
//
//int GameUIPetAttrib::int_PET_GROW_RATE = 0;// 成长率
//int GameUIPetAttrib::int_PET_GROW_RATE_MAX = 0;// 成长率
//int GameUIPetAttrib::int_PET_HIT  = 0;//命中
//
//int GameUIPetAttrib::int_ATTR_FREE_POINT = 0; //自由点数
//int GameUIPetAttrib::int_PET_ATTR_LEVEUP_EXP = 0; // 升级经验
//int GameUIPetAttrib::int_PET_ATTR_PHY_ATK = 0; // 物理攻击力INT
//int GameUIPetAttrib::int_PET_ATTR_PHY_DEF = 0; // 物理防御INT
//int GameUIPetAttrib::int_PET_ATTR_MAG_ATK = 0; // 法术攻击力INT
//int GameUIPetAttrib::int_PET_ATTR_MAG_DEF = 0; // 法术抗性INT
//int GameUIPetAttrib::int_PET_ATTR_HARD_HIT = 0;// 暴击
//int GameUIPetAttrib::int_PET_ATTR_DODGE = 0;// 闪避
//int GameUIPetAttrib::int_PET_ATTR_ATK_SPEED = 0;// 攻击速度
//int GameUIPetAttrib::int_PET_ATTR_TYPE = 0;// 类型
//int GameUIPetAttrib::int_PET_ATTR_LOOKFACE = 0;//外观
//int GameUIPetAttrib::bindStatus = 0;//绑定状态
//
//int GameUIPetAttrib::ownerid = 0;
//std::string GameUIPetAttrib::ownerName = "";// 主人名
//
//GameUIPetAttrib::GameUIPetAttrib()
//{
//	m_picBasic = NULL; m_picBasicDown = NULL; m_btnBasic = NULL;
//	m_picDetail = NULL; m_picDetailDown = NULL; m_btnDetail = NULL;
//	m_picAdvance = NULL; m_picAdvanceDown = NULL; m_btnAdvance = NULL;
//	
//	m_framePet  = NULL;
//	m_lbName = NULL; m_lbLevel = NULL; m_lbZhuRen = NULL;
//	m_lbHP = NULL; m_lbMP = NULL; m_lbExp = NULL;
//	m_layerPet = NULL;
//	m_stateBarHP = NULL; m_stateBarMP = NULL; m_stateBarExp = NULL;
//
//	m_GamePetNode = NULL;
//	
//	m_lbCurProp = NULL; //m_lbRate = NULL;
//
//	m_enumTBS = eTBS_Basic;
//	
//	m_tableLayerBasic = NULL;
//	m_tableLayerDetail = NULL;
//	m_tableLayerAdvance = NULL;
//	
//	m_iFocusTitle = eTBS_Basic;
//	
//	m_bSelf = true;
//	
//	m_imageNumTotalPoint = NULL;
//	m_imageNUmAllocPoint = NULL;
//	m_picMinus = NULL;
//	m_imageMinus = NULL;
//	
//	memset(m_BasePropNode, 0, sizeof(m_BasePropNode));
//} 
//
//GameUIPetAttrib::~GameUIPetAttrib()
//{
//	SAFE_DELETE(m_picBasic);
//	SAFE_DELETE(m_picBasicDown);
//	SAFE_DELETE(m_picDetail);
//	SAFE_DELETE(m_picDetailDown);
//	SAFE_DELETE(m_picAdvance);
//	SAFE_DELETE(m_picAdvanceDown);
//	SAFE_DELETE(m_picMinus);
//}
//
//void GameUIPetAttrib::Initialization(bool bSelf/*=true*/)
//{
//	m_bSelf = bSelf; 
//	
//	if (m_bSelf) setBattlePetValueToPetAttr();
//	UpdateStrucPoint();
//	
//	NDUIMenuLayer::Initialization();
//	
//	CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
//	
//	this->ShowOkBtn();
//	
//	if ( this->GetOkBtn() ) 
//	{
//		this->GetOkBtn()->SetDelegate(this);
//	}
//	
//	if ( this->GetCancelBtn() ) 
//	{
//		this->GetCancelBtn()->SetDelegate(this);
//	}
//	
//	m_picBasic = NDPicturePool::DefaultPool()->AddPicture(title_image);
//	m_picBasicDown = NDPicturePool::DefaultPool()->AddPicture(title_image);
//	m_picBasic->Cut(CGRectMake(321, 79, 46, 20));
//	m_picBasicDown->Cut(CGRectMake(321, 59, 46, 20));
//	m_btnBasic = new NDUIButton();
//	m_btnBasic->Initialization();
//	m_btnBasic->SetFrameRect(CGRectMake(27, (28-m_picBasic->GetSize().height)/2, 44, 20));
//	m_btnBasic->SetImage(m_picBasicDown);
//	m_btnBasic->SetTitle("");
//	m_btnBasic->SetDelegate(this);
//	this->AddChild(m_btnBasic);
//	
//	m_picDetail = NDPicturePool::DefaultPool()->AddPicture(title_image);
//	m_picDetailDown = NDPicturePool::DefaultPool()->AddPicture(title_image);
//	m_picDetail->Cut(CGRectMake(319, 40, 46, 18));
//	m_picDetailDown->Cut(CGRectMake(319, 20, 46, 20));
//	m_btnDetail = new NDUIButton();
//	m_btnDetail->Initialization();
//	m_btnDetail->SetFrameRect(CGRectMake(209, (28-m_picDetail->GetSize().height)/2, 44, 20));
//	m_btnDetail->SetImage(m_picDetail);
//	m_btnDetail->SetTitle("");
//	m_btnDetail->SetDelegate(this);
//	this->AddChild(m_btnDetail);
//	
//	m_picAdvance = NDPicturePool::DefaultPool()->AddPicture(title_image);
//	m_picAdvanceDown = NDPicturePool::DefaultPool()->AddPicture(title_image);
//	m_picAdvance->Cut(CGRectMake(319, 119, 46, 20));
//	m_picAdvanceDown->Cut(CGRectMake(319, 99, 46, 20));
//	m_btnAdvance = new NDUIButton();
//	m_btnAdvance->Initialization();
//	m_btnAdvance->SetFrameRect(CGRectMake(390, (28-m_picAdvance->GetSize().height)/2, 44, 20));
//	m_btnAdvance->SetImage(m_picAdvance);
//	m_btnAdvance->SetTitle("");
//	m_btnAdvance->SetDelegate(this);
//	this->AddChild(m_btnAdvance);
//	
//	m_framePet = new NDUIFrame();
//	m_framePet->Initialization();
//	m_framePet->SetFrameRect(CGRectMake(40, 60, 160, 193));
//	this->AddChild(m_framePet);
//	
//	m_lbName = new NDUILabel();
//	m_lbName->Initialization();
//	//m_lbName->SetText("小绵羊");
//	m_lbName->SetFontSize(15);
//	m_lbName->SetTextAlignment(LabelTextAlignmentCenter);
//	int nameColor = NDItemType::getItemColor(int_PET_ATTR_TYPE);
//	m_lbName->SetFontColor(INTCOLORTOCCC4(nameColor));
//	m_lbName->SetFrameRect(CGRectMake(0, 0, 160, 20));
//	m_framePet->AddChild(m_lbName);
//	
//	m_layerPet = new NDUILayer;
//	m_layerPet->Initialization();
//	m_layerPet->SetFrameRect(CGRectMake(10, 20, 140, 105));
//	m_layerPet->SetBackgroundColor(ccc4(242, 236, 204, 255));
//	m_framePet->AddChild(m_layerPet);
//	
//	m_lbLevel = new NDUILabel();
//	m_lbLevel->Initialization();
//	m_lbLevel->SetText(NDCommonCString("level"));
//	m_lbLevel->SetFontSize(15);
//	m_lbLevel->SetTextAlignment(LabelTextAlignmentLeft);
//	m_lbLevel->SetFontColor(INTCOLORTOCCC4(0x862700));
//	m_lbLevel->SetFrameRect(CGRectMake(7, 28, 480, 15));
//	m_layerPet->AddChild(m_lbLevel);
//	
//	m_lbZhuRen = new NDUILabel();
//	m_lbZhuRen->Initialization();
//	m_lbZhuRen->SetText(NDCommonCString("ZhuRen"));
//	m_lbZhuRen->SetFontSize(15);
//	m_lbZhuRen->SetTextAlignment(LabelTextAlignmentLeft);
//	m_lbZhuRen->SetFontColor(ccc4(20,29,2,255));
//	m_lbZhuRen->SetFrameRect(CGRectMake(7, 12, 480, 15));
//	m_layerPet->AddChild(m_lbZhuRen);
//	
//	std::stringstream ssXingGe;
//	ssXingGe << "【" << getPetType(int_PET_ATTR_TYPE) << "】";
//	NDUILabel *xingge = new NDUILabel();
//	xingge->Initialization();
//	xingge->SetText(ssXingGe.str().c_str());
//	xingge->SetFontSize(15);
//	xingge->SetTextAlignment(LabelTextAlignmentLeft);
//	xingge->SetFontColor(INTCOLORTOCCC4(0xff0000));
//	xingge->SetFrameRect(CGRectMake(80, 85, 480, 20));
//	m_layerPet->AddChild(xingge);
//	
//	if (!m_bSelf) GamePetNode::lookface = int_PET_ATTR_LOOKFACE;
//	m_GamePetNode = new GamePetNode;
//	m_GamePetNode->Initialization(bSelf);
//	//以下两行固定用法
//	m_GamePetNode->SetFrameRect(CGRectMake(0, 0, winSize.width, winSize.height));
//	m_GamePetNode->SetDisplayPos(ccp(120,165));
//	m_layerPet->AddChild(m_GamePetNode);
//
//	m_lbHP = new NDUILabel();
//	m_lbHP->Initialization();
//	m_lbHP->SetText("HP");
//	m_lbHP->SetFontSize(13);
//	m_lbHP->SetTextAlignment(LabelTextAlignmentLeft);
//	m_lbHP->SetFontColor(ccc4(38,59,28,255));
//	m_lbHP->SetFrameRect(CGRectMake(6, 131, 480, 13));
//	m_framePet->AddChild(m_lbHP);
//	
//	m_lbMP = new NDUILabel();
//	m_lbMP->Initialization();
//	m_lbMP->SetText("MP");
//	m_lbMP->SetFontSize(13);
//	m_lbMP->SetTextAlignment(LabelTextAlignmentLeft);
//	m_lbMP->SetFontColor(ccc4(38,59,28,255));
//	m_lbMP->SetFrameRect(CGRectMake(6, 150, 480, 13));
//	m_framePet->AddChild(m_lbMP);
//	
//	m_lbExp = new NDUILabel();
//	m_lbExp->Initialization();
//	m_lbExp->SetText("EXP");
//	m_lbExp->SetFontSize(13);
//	m_lbExp->SetTextAlignment(LabelTextAlignmentLeft);
//	m_lbExp->SetFontColor(ccc4(38,59,28,255));
//	m_lbExp->SetFrameRect(CGRectMake(6, 170, 480, 13));
//	m_framePet->AddChild(m_lbExp);
//	
//	m_stateBarHP = new NDUIStateBar();
//	m_stateBarHP->Initialization(false);
//	m_stateBarHP->SetFrameRect(CGRectMake(33, 131, 114, 13));
//	m_stateBarHP->SetNumber(125, 7789);
//	m_stateBarHP->SetStateColor(ccc4(202,67,48,255));
//	m_framePet->AddChild(m_stateBarHP);
//	
//	m_stateBarMP = new NDUIStateBar();
//	m_stateBarMP->Initialization(false);
//	m_stateBarMP->SetFrameRect(CGRectMake(33, 150, 114, 13));
//	m_stateBarMP->SetNumber(1, 2);
//	m_stateBarMP->SetStateColor(ccc4(39,142,185,255));
//	m_framePet->AddChild(m_stateBarMP);
//	
//	m_stateBarExp = new NDUIStateBar();
//	m_stateBarExp->Initialization(false);
//	m_stateBarExp->SetFrameRect(CGRectMake(33, 170, 114, 13));
//	m_stateBarExp->SetNumber(77,99);
//	m_stateBarExp->SetStateColor(ccc4(81,185,48,255));
//	m_framePet->AddChild(m_stateBarExp);
//	
//	m_lbCurProp = new NDUILabel();
//	m_lbCurProp->Initialization();
//	m_lbCurProp->SetText(NDCommonCString("AllocProp"));
//	m_lbCurProp->SetFontSize(15);
//	m_lbCurProp->SetTextAlignment(LabelTextAlignmentLeft);
//	m_lbCurProp->SetFontColor(ccc4(0,0,0,255));
//	m_lbCurProp->SetFrameRect(CGRectMake(220, 44, 480, 15));
//	this->AddChild(m_lbCurProp);
//	
//	m_imageNumTotalPoint = new ImageNumber;
//	m_imageNumTotalPoint->Initialization();
//	m_imageNumTotalPoint->SetTitleRedNumber(0);
//	m_imageNumTotalPoint->SetFrameRect(CGRectMake(320, 44, 60, 8));
//	this->AddChild(m_imageNumTotalPoint);
//	
//	m_imageNUmAllocPoint = new ImageNumber;
//	m_imageNUmAllocPoint->Initialization();
//	m_imageNUmAllocPoint->SetTitleRedNumber(0);
//	m_imageNUmAllocPoint->SetFrameRect(CGRectMake(390, 44, 60, 8));
//	this->AddChild(m_imageNUmAllocPoint);
//	
//	m_picMinus = NDPicturePool::DefaultPool()->AddPicture(GetImgPath("plusMinus.png"));
//	m_picMinus->Cut(CGRectMake(8, 0, 9, 8));
//	
//	m_imageMinus = new NDUIImage;
//	m_imageMinus->Initialization();
//	m_imageMinus->SetPicture(m_picMinus);
//	m_imageMinus->SetFrameRect(CGRectMake(380, 48, 8, 8));
//	this->AddChild(m_imageMinus);
//	
//	do 
//	{
//		m_tableLayerBasic = new NDUITableLayer;
//		m_tableLayerBasic->Initialization();
//		m_tableLayerBasic->SetDelegate(this);
//		m_tableLayerBasic->VisibleSectionTitles(false);
//		m_tableLayerBasic->VisibleScrollBar(true);
//		m_tableLayerBasic->SetFrameRect(CGRectMake(220, 60, 230, 193));
//		NDDataSource *dataSource = new NDDataSource;
//		NDSection *section = new NDSection;
//		for ( int i=ePAB_Begin; i<ePAB_End; i++) 
//		{
//			m_BasePropNode[i] = new BasePropNode;			
//			m_BasePropNode[i]->Initialization();
//			m_BasePropNode[i]->SetKeyText(strPetBasic[i].c_str());
//			m_BasePropNode[i]->SetValue("500");
//			m_BasePropNode[i]->SetFrameRect(CGRectMake(0, 0, 229, 30));
//			section->AddCell(m_BasePropNode[i]);
//		}
//		
//		std::vector<int> colors = getColorList(int_PET_ATTR_TYPE % 10-5);
//#define fastinit(prop,str, min, max) \
//		do \
//		{ \
//			prop = new LayerProp; \
//			prop->Initialization(); \
//			prop->SetKeyText(str); \
//			prop->SetStateNum(min,max); \
//			prop->SetFrameRect(CGRectMake(0, 0, 229, 30)); \
//			prop->SetColor(colors);\
//			section->AddCell(prop); \
//		} while (0)
//
//		fastinit(m_BaseLayerProp[ePABE_Begin], NDCommonCString("ChengZhangZiZhi"), int_PET_GROW_RATE, int_PET_GROW_RATE_MAX);
//		fastinit(m_BaseLayerProp[ePABE_Begin+1], NDCommonCString("QiXueZiZhi"), int_PET_ATTR_HP_RATE, int_PET_ATTR_HP_RATE_MAX);
//		fastinit(m_BaseLayerProp[ePABE_Begin+2], NDCommonCString("FaLiZiZhi"), int_PET_ATTR_MP_RATE, int_PET_ATTR_MP_RATE_MAX);
//		fastinit(m_BaseLayerProp[ePABE_Begin+3], NDCommonCString("WuGongZiZhi"), int_PET_PHY_ATK_RATE, int_PET_PHY_ATK_RATE_MAX);
//		fastinit(m_BaseLayerProp[ePABE_Begin+4], NDCommonCString("WuFangZiZhi"), int_PET_PHY_DEF_RATE, int_PET_PHY_DEF_RATE_MAX);
//		fastinit(m_BaseLayerProp[ePABE_Begin+5], NDCommonCString("FaGongZiZhi"), int_PET_MAG_ATK_RATE, int_PET_MAG_ATK_RATE_MAX);
//		fastinit(m_BaseLayerProp[ePABE_Begin+6], NDCommonCString("FaFangZiZhi"), int_PET_MAG_DEF_RATE, int_PET_MAG_DEF_RATE_MAX);
//		fastinit(m_BaseLayerProp[ePABE_Begin+7], NDCommonCString("SpeedZiZhi"), int_PET_SPEED_RATE, int_PET_SPEED_RATE_MAX);
//#undef	fastinit	
//		dataSource->AddSection(section);
//		m_tableLayerBasic->SetDataSource(dataSource);
//		this->AddChild(m_tableLayerBasic);
//	} while (0);
//	
//	do 
//	{
//		m_tableLayerDetail = new NDUITableLayer;
//		m_tableLayerDetail->Initialization();
//		m_tableLayerDetail->VisibleSectionTitles(false);
//		m_tableLayerDetail->SetFrameRect(CGRectMake(220, 60, 230, 193));
//		m_tableLayerDetail->VisibleScrollBar(true);
//		m_tableLayerDetail->SetDelegate(this);
//		NDDataSource *dataSource = new NDDataSource;
//		NDSection *section = new NDSection;
//		for ( int i=ePAD_Begin; i<ePAD_End; i++) 
//		{
//			NDUIProp  *propDetail = new NDUIProp;
//			propDetail->Initialization();
//			propDetail->SetFrameRect(CGRectMake(0, 0, 229, 20));
//			propDetail->SetKeyText(strPetDetail[i].c_str());
//			propDetail->SetValueText("");
//			section->AddCell(propDetail);
//		}
//		
//		dataSource->AddSection(section);
//		m_tableLayerDetail->SetDataSource(dataSource);
//		this->AddChild(m_tableLayerDetail);
//	} while (0);
//	
//	do 
//	{
//		m_tableLayerAdvance = new NDUITableLayer;
//		m_tableLayerAdvance->Initialization();
//		m_tableLayerAdvance->VisibleSectionTitles(false);
//		m_tableLayerAdvance->VisibleScrollBar(true);
//		m_tableLayerAdvance->SetFrameRect(CGRectMake(220, 60, 230, 193));
//		NDDataSource *dataSource = new NDDataSource;
//		NDSection *section = new NDSection;
//		
//		for(int i=ePAA_Begin; i<ePAA_End; i++)
//		{
//			NDUIProp  *propDetail = new NDUIProp;
//			propDetail->Initialization();
//			propDetail->SetFrameRect(CGRectMake(0, 0, 229, 20));
//			propDetail->SetKeyText(strPetAdvance[i].c_str());
//			propDetail->SetValueText("");
//			section->AddCell(propDetail);
//		}
//		
//		dataSource->AddSection(section);
//		m_tableLayerAdvance->SetDataSource(dataSource);
//		this->AddChild(m_tableLayerAdvance);
//	} while (0);
//	
//	UpdateGameUIPetAttrib();
//	updatePoint();
//}
//
//void GameUIPetAttrib::draw()
//{	
//	if (m_enumTBS == eTBS_Detail) 
//	{
//		ShowDetail();
//	}
//	else if (m_enumTBS == eTBS_Advance)
//	{
//		ShowAdvance();
//	}
//	else 
//	{
//		ShowBasic();
//	}
//	NDUIMenuLayer::draw();
//}
//
//void GameUIPetAttrib::OnButtonClick(NDUIButton* button)
//{
//	if ( button == m_btnBasic ) 
//	{
//		changeTitleFocus(eTBS_Basic);
//		m_enumTBS = eTBS_Basic;
//	}
//	else if ( button == m_btnDetail )
//	{
//		changeTitleFocus(eTBS_Detail);
//		m_enumTBS = eTBS_Detail;
//	}
//	else if ( button == m_btnAdvance )
//	{
//		changeTitleFocus(eTBS_Advance);
//		m_enumTBS = eTBS_Advance;
//	}
//	else if ( button == this->GetOkBtn() )
//	{
//		if (m_struPoint.iAlloc > 0 
//			&& m_struPoint.iAlloc <= m_struPoint.iTotal
//			&& m_struPoint.VerifyAllocPoint() ) 
//		{
//			NDUIDialog* dlg = new NDUIDialog;
//			dlg->Initialization();
//			dlg->SetDelegate(this);
//			stringstream ss;
//			ss << NDCommonCString("ModifyAttrTip") << (m_struPoint.iTotal-m_struPoint.iAlloc);
//			dlg->Show(NDCommonCString("tip"), ss.str().c_str(), NULL, NDCommonCString("Ok"), NDCommonCString("Cancel"), NULL);
//		}
//		else 
//		{
//			NDDirector::DefaultDirector()->PopScene();
//		}
//	}
//	else if ( button == this->GetCancelBtn() )
//	{
//		NDDirector::DefaultDirector()->PopScene();
//	}
//}
//
//void GameUIPetAttrib::OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex)
//{
//	dialog->Close();
//	if (buttonIndex == 0) {
//		this->sendAction();
//	}
//}
//
//void GameUIPetAttrib::sendAction() {
//	if ( !(m_struPoint.iAlloc > 0 
//		&& m_struPoint.iAlloc <= m_struPoint.iTotal
//		&& m_struPoint.VerifyAllocPoint()) 
//		)
//	{
//		return;
//	}
//	
//	Item *itempet = ItemMgrObj.GetEquipItemByPos(Item::eEP_Pet);
//	NDBattlePet *pet = NDPlayer::defaultHero().battlepet;
//	if (!itempet || !pet) 
//	{
//		return;
//	}
//	
//	//int STR_POINT = 0x01;
////	int STA_POINT = 0x02;
////	int AGI_POINT = 0x04;
////	int INI_POINT = 0x08;
//	int POINT_DEF[_stru_point::ps_end] = { 0x01, 0x04, 0x08, 0x02,};
//	NDTransData bao(_MSG_CHG_PET_POINT);
//	bao << int(itempet->iID);
//	int btPointField = 0;
//	for (int i = _stru_point::ps_begin; i < _stru_point::ps_end; i++) 
//	{
//		if (m_struPoint.m_psProperty[i].iPoint > 0) 
//		{
//			btPointField |= POINT_DEF[i];
//		}
//	}
//	bao << (unsigned char)btPointField;
//	for (int i = _stru_point::ps_begin; i < _stru_point::ps_end; i++) 
//	{
//		if (m_struPoint.m_psProperty[i].iPoint > 0) 
//		{
//			bao << (unsigned short)(m_struPoint.m_psProperty[i].iPoint);
//		}
//	}
//	SEND_DATA(bao);
//	
//	pet->tmpRestPoint = m_struPoint.iTotal - m_struPoint.iAlloc;
//	pet->tmpStrPoint = m_struPoint.GetPoint(_stru_point::ps_liliang);
//	pet->tmpStaPoint = m_struPoint.GetPoint(_stru_point::ps_tizhi);
//	pet->tmpAgiPoint = m_struPoint.GetPoint(_stru_point::ps_minjie);
//	pet->tmpIniPoint = m_struPoint.GetPoint(_stru_point::ps_zhili);
//	int_ATTR_FREE_POINT = pet->tmpRestPoint;
//	int_PET_ATTR_STR = pet->tmpStrPoint;
//	int_PET_ATTR_STA = pet->tmpStaPoint;
//	int_PET_ATTR_AGI = pet->tmpAgiPoint;
//	int_PET_ATTR_INI = pet->tmpIniPoint;
//	
//	UpdateStrucPoint();
//	updatePoint();
//}
//
//bool GameUIPetAttrib::OnCustomViewConfirm(NDUICustomView* customView)
//{
//	std::string strName = customView->GetEditText(0);
//	if (!strName.empty() && UpdateDetailPetName(strName))
//	{
//		Item* item = ItemMgrObj.GetEquipItemByPos(Item::eEP_Pet);
//		if (!item) 
//		{
//			NDLog(@"宠物属性界面更改宠物名字时找不到宠物所在装备");
//			return true;
//		}
//		
//		NDTransData data(_MSG_NAME);
//		data << item->iID << (unsigned char)0;
//		data.WriteUnicodeString(strName);
//		
//		NDDataTransThread::DefaultThread()->GetSocket()->Send(&data);
//		
//		m_lbName->SetText(strName.c_str());
//	}
//	return true;
//}
//
//void GameUIPetAttrib::OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
//{
//	if (!m_bSelf) 
//	{
//		return;
//	}
//	
//	if	(table == m_tableLayerDetail && cellIndex == 0)
//	{
//		stringstream ss;
//		ss << NDCommonCString("InputNewPetName");
//		NDUICustomView *view = new NDUICustomView;
//		view->Initialization();
//		view->SetDelegate(this);
//		std::vector<int> vec_id; vec_id.push_back(101);
//		std::vector<std::string> vec_str; vec_str.push_back(ss.str());
//		view->SetEdit(1, vec_id, vec_str);
//		view->Show();
//		this->AddChild(view);
//	} else if (table == m_tableLayerBasic) {
//		bool bUpdate = false;
//		switch (cellIndex) {
//			case 0: // 力量
//			{
//				if (this->m_tableLayerBasic->m_beginTouch.x > 266 &&
//				    this->m_tableLayerBasic->m_beginTouch.x < 316) { // 减
//					if (m_struPoint.iAlloc <= 0)
//					{
//						return;
//					}
//					if (this->m_struPoint.m_psProperty[_stru_point::ps_liliang].iPoint > 0) {
//						this->m_struPoint.m_psProperty[_stru_point::ps_liliang].iPoint--;
//						this->m_struPoint.iAlloc--;
//						bUpdate = true;
//					}
//				} else if (this->m_tableLayerBasic->m_beginTouch.x > 366 &&
//					     this->m_tableLayerBasic->m_beginTouch.x < 416) { // 加
//					if (this->m_struPoint.iTotal > this->m_struPoint.iAlloc) {
//						this->m_struPoint.m_psProperty[_stru_point::ps_liliang].iPoint++;
//						this->m_struPoint.iAlloc++;
//						bUpdate = true;
//					}
//				} else {
//					showDialog(NDCommonCString("Liliang"), NDCommonCString("LiLiangAttrTip"));
//				}
//			}
//				break;
//			case 1:
//				if (this->m_tableLayerBasic->m_beginTouch.x > 266 &&
//				    this->m_tableLayerBasic->m_beginTouch.x < 316) { // 减
//					if (m_struPoint.iAlloc <= 0)
//					{
//						return;
//					}
//					if (this->m_struPoint.m_psProperty[_stru_point::ps_tizhi].iPoint > 0) {
//						this->m_struPoint.m_psProperty[_stru_point::ps_tizhi].iPoint--;
//						this->m_struPoint.iAlloc--;
//						bUpdate = true;
//					}
//				} else if (this->m_tableLayerBasic->m_beginTouch.x > 366 &&
//					   this->m_tableLayerBasic->m_beginTouch.x < 416) { // 加
//					if (this->m_struPoint.iTotal > this->m_struPoint.iAlloc) {
//						this->m_struPoint.m_psProperty[_stru_point::ps_tizhi].iPoint++;
//						this->m_struPoint.iAlloc++;
//						bUpdate = true;
//					}
//				} else {
//					showDialog(NDCommonCString("TiZhi"), NDCommonCString("TiZhiAttrTip"));
//
//				}
//				break;
//			case 2:
//				if (this->m_tableLayerBasic->m_beginTouch.x > 266 &&
//				    this->m_tableLayerBasic->m_beginTouch.x < 316) { // 减
//					if (m_struPoint.iAlloc <= 0)
//					{
//						return;
//					}
//					if (this->m_struPoint.m_psProperty[_stru_point::ps_minjie].iPoint > 0) {
//						this->m_struPoint.m_psProperty[_stru_point::ps_minjie].iPoint--;
//						this->m_struPoint.iAlloc--;
//						bUpdate = true;
//					}
//				} else if (this->m_tableLayerBasic->m_beginTouch.x > 366 &&
//					   this->m_tableLayerBasic->m_beginTouch.x < 416) { // 加
//					if (this->m_struPoint.iTotal > this->m_struPoint.iAlloc) {
//						this->m_struPoint.m_psProperty[_stru_point::ps_minjie].iPoint++;
//						this->m_struPoint.iAlloc++;
//						bUpdate = true;
//					}
//				} else {
//					showDialog(NDCommonCString("MingJie"), NDCommonCString("MingJieAttrTip"));
//				}
//				break;
//			case 3:
//				if (this->m_tableLayerBasic->m_beginTouch.x > 266 &&
//				    this->m_tableLayerBasic->m_beginTouch.x < 316) { // 减
//					if (m_struPoint.iAlloc <= 0)
//					{
//						return;
//					}
//					if (this->m_struPoint.m_psProperty[_stru_point::ps_zhili].iPoint > 0) {
//						this->m_struPoint.m_psProperty[_stru_point::ps_zhili].iPoint--;
//						this->m_struPoint.iAlloc--;
//						bUpdate = true;
//					}
//				} else if (this->m_tableLayerBasic->m_beginTouch.x > 366 &&
//					   this->m_tableLayerBasic->m_beginTouch.x < 416) { // 加
//					if (this->m_struPoint.iTotal > this->m_struPoint.iAlloc) {
//						this->m_struPoint.m_psProperty[_stru_point::ps_zhili].iPoint++;
//						this->m_struPoint.iAlloc++;
//						bUpdate = true;
//					}
//				} else {
//					showDialog(NDCommonCString("ZhiLi"), NDCommonCString("ZhiLiAttrTip"));
//				}
//				break;
//			default:
//				break;
//		}
//		if (bUpdate) {
//			this->updatePoint();
//		}
//	}
//}
//
//void GameUIPetAttrib::updatePoint()
//{
//	for (int i = ePAB_Begin; i < ePAB_End; i++) 
//	{
//		ccColor4B color = ccc4(0, 0, 0, 255);
//		int iValue = 0;
//		_stru_point::point_state& pointstate = m_struPoint.m_psProperty[i];
//		if (pointstate.iPoint != 0) 
//		{
//			iValue += pointstate.iPoint;
//			color = ccc4(255, 0, 0, 255);
//		}
//		iValue += pointstate.iFix;
//		std::stringstream ss; ss << iValue;
//		if (m_BasePropNode[i]) 
//		{
//			m_BasePropNode[i]->SetValue(ss.str());
//			m_BasePropNode[i]->SetValueColor(color);
//		}
//	}
//	
//	if (m_imageNumTotalPoint) 
//	{
//		m_imageNumTotalPoint->SetTitleRedNumber(m_struPoint.iTotal);
//	}
//	
//	if (m_imageNUmAllocPoint) 
//	{
//		m_imageNUmAllocPoint->SetTitleRedNumber(m_struPoint.iAlloc);
//	}
//	
//	if (m_struPoint.iAlloc > 0 && m_imageMinus)
//	{
//		m_imageMinus->SetVisible(true);
//	}
//}
//
//void GameUIPetAttrib::UpdateGameUIPetAttrib()
//{
//	m_lbName->SetText(str_PET_ATTR_NAME.c_str());
//	stringstream ssName; ssName << NDCommonCString("ZhuRen") << ":" << ownerName.c_str();
//	m_lbZhuRen->SetText(ssName.str().c_str());
//	
//	stringstream ssLvl; ssLvl << int_PET_ATTR_LEVEL << NDCommonCString("Ji");
//	m_lbLevel->SetText(ssLvl.str().c_str());
//	
//	m_stateBarHP->SetNumber(int_PET_ATTR_LIFE, int_PET_ATTR_MAX_LIFE);
//	m_stateBarMP->SetNumber(int_PET_ATTR_MANA, int_PET_ATTR_MAX_MANA);
//	m_stateBarExp->SetNumber(int_PET_ATTR_EXP, int_PET_ATTR_LEVEUP_EXP);
//	
//	updatePoint();
//	
//	UpdateBasicData(ePABE_GrowRate, int_PET_GROW_RATE, int_PET_GROW_RATE_MAX);
//	UpdateBasicData(ePABE_HpRate, int_PET_ATTR_HP_RATE, int_PET_ATTR_HP_RATE_MAX);
//	UpdateBasicData(ePABE_MpRate, int_PET_ATTR_MP_RATE, int_PET_ATTR_MP_RATE_MAX);
//	UpdateBasicData(ePABE_PhyAtkRate, int_PET_PHY_ATK_RATE, int_PET_PHY_ATK_RATE_MAX);
//	UpdateBasicData(ePABE_PhyDefRate, int_PET_PHY_DEF_RATE, int_PET_PHY_DEF_RATE_MAX);
//	UpdateBasicData(ePABE_MagAtkRate, int_PET_MAG_ATK_RATE, int_PET_MAG_ATK_RATE_MAX);
//	UpdateBasicData(ePABE_MagDefRate, int_PET_MAG_DEF_RATE, int_PET_MAG_DEF_RATE_MAX);
//	UpdateBasicData(ePABE_SpeedRate, int_PET_SPEED_RATE, int_PET_SPEED_RATE_MAX);
//	
//	UpdateDetailPetName(str_PET_ATTR_NAME);
//	
//	UpdateDetailData(ePAD_Bind, bindStatus);
//	UpdateDetailData(ePAD_Quality, int_PET_ATTR_TYPE);
//	UpdateDetailData(ePAD_XingGe, int_PET_ATTR_TYPE);
//	UpdateDetailData(ePAD_InitLev, int_PET_ATTR_LEVEL_INIT);
//	UpdateDetailData(ePAD_Age, int_PET_ATTR_AGE);
//	UpdateDetailData(ePAD_Honyst, int_PET_ATTR_LOYAL);
//	UpdateDetailData(ePAD_SkillNum, int_PET_MAX_SKILL_NUM);
//	UpdateDetailData(ePAD_InitLiLiang, int_PET_ATTR_STR_INIT);
//	UpdateDetailData(ePAD_InitTizhi, int_PET_ATTR_STA_INIT);
//	UpdateDetailData(ePAD_InitMinJie, int_PET_ATTR_AGI_INIT);
//	UpdateDetailData(ePAD_InitZhiLi, int_PET_ATTR_INI_INIT);
//	
//	UpdateAdvanceData(ePAA_PhyAtk, int_PET_ATTR_PHY_ATK);
//	UpdateAdvanceData(ePAA_PhyDef, int_PET_ATTR_PHY_DEF);
//	UpdateAdvanceData(ePAA_MagicAtk, int_PET_ATTR_MAG_ATK);
//	UpdateAdvanceData(ePAA_MagicDef, int_PET_ATTR_MAG_DEF);
//	UpdateAdvanceData(ePAA_AtkSpeed, int_PET_ATTR_ATK_SPEED);
//	UpdateAdvanceData(ePAA_HardHit, int_PET_ATTR_HARD_HIT);
//	UpdateAdvanceData(ePAA_Dodge, int_PET_ATTR_DODGE);
//	UpdateAdvanceData(ePAA_PetHit, int_PET_HIT);
//}
//
//void GameUIPetAttrib::ShowBasic()
//{
//	m_lbCurProp->SetVisible(true);
//	m_imageNumTotalPoint->SetVisible(true);
//	m_imageNUmAllocPoint->SetVisible(true);
//	if (m_struPoint.iAlloc > 0 && m_imageMinus)
//	{
//		m_imageMinus->SetVisible(true);
//	}
//	m_tableLayerBasic->SetVisible(true);
//	m_tableLayerDetail->SetVisible(false);
//	m_tableLayerAdvance->SetVisible(false);
//}
//void GameUIPetAttrib::ShowDetail()
//{	
//	m_lbCurProp->SetVisible(false);
//	m_imageNumTotalPoint->SetVisible(false);
//	m_imageNUmAllocPoint->SetVisible(false);
//	m_imageMinus->SetVisible(false);
//	m_tableLayerBasic->SetVisible(false);
//	m_tableLayerDetail->SetVisible(true);
//	m_tableLayerAdvance->SetVisible(false);
//}
//void GameUIPetAttrib::ShowAdvance()
//{
//	m_lbCurProp->SetVisible(false);
//	m_imageNumTotalPoint->SetVisible(false);
//	m_imageNUmAllocPoint->SetVisible(false);
//	m_imageMinus->SetVisible(false);
//	m_tableLayerBasic->SetVisible(false);
//	m_tableLayerDetail->SetVisible(false);
//	m_tableLayerAdvance->SetVisible(true);
//}
//
//void GameUIPetAttrib::UpdateBasicData(int eProp, int iMin, int iMax)
//{
//	if (eProp < ePABE_Begin || eProp >= ePABE_End || !m_BaseLayerProp[eProp]) 
//	{
//		return;
//	}
//	
//	m_BaseLayerProp[eProp]->SetStateNum(iMin, iMax);
//}
//
//void GameUIPetAttrib::UpdateDetailData(int eProp, int value)
//{
//	NDSection *section = m_tableLayerDetail->GetDataSource()->Section(0);
//	if ( section->Count() !=  ePAD_End ) 
//	{
//		NDLog(@"GameUIPetAttrib:UpdateDetailData 界面更新出错!!!");
//	}
//	else 
//	{
//		NDUINode *node = section->Cell(eProp);								
//		if (node->IsKindOfClass(RUNTIME_CLASS(NDUIProp)))					
//		{		
//			stringstream ss;  
//			if (eProp == ePAD_XingGe) 
//			{
//				ss << getPetType(value);
//			}
//			else if (eProp == ePAD_Quality) 
//			{
//				int tempInt = value % 10;
//				if (tempInt >= 5) 
//				{
//					ss << NDItemType::PETLEVEL(tempInt - 5);
//				}
//			}
//			else if (eProp == ePAD_Bind)
//			{
//				if (value == BIND_STATE_BIND) 
//				{
//					ss << NDCommonCString("hadbind");
//				} else {
//					ss << NDCommonCString("WeiBind");
//				}
//			}
//			else 
//			{
//				ss << value;
//			}
//
//			NDUIProp *prop = (NDUIProp*)node;								
//			prop->SetValueText(ss.str());	
//		}
//		else																
//		{																	
//			NDLog(@"GameUIPetAttrib:UpdateDetailData 界面更新出错,枚举值[%d]!!!", eProp);	
//		}
//	}
//}
//
//void GameUIPetAttrib::UpdateAdvanceData(int eProp, int value)
//{
//	NDSection *section = m_tableLayerAdvance->GetDataSource()->Section(0);
//	if ( section->Count() !=  ePAA_End ) 
//	{
//		NDLog(@"GameUIPetAttrib:UpdateAdvanceData 界面更新出错!!!");
//	}
//	else 
//	{
//		NDUINode *node = section->Cell(eProp);								
//		if (node->IsKindOfClass(RUNTIME_CLASS(NDUIProp)))					
//		{									
//			stringstream ss; ss << value;
//			NDUIProp *prop = (NDUIProp*)node;
//			prop->SetValueText(ss.str());	
//		}																	
//		else																
//		{																	
//			NDLog(@"GameUIPetAttrib:UpdateAdvanceData 界面更新出错,枚举值[%d]!!!", eProp);	
//		}
//	}
//}
//
//void GameUIPetAttrib::changeTitleFocus(int iTitleType)
//{
//	if (iTitleType < eTBS_Begin || iTitleType >= eTBS_End)
//		return;
//	
//	if ( m_enumTBS == iTitleType ) return;
//	
//	changeTitleImage(m_enumTBS,false);
//	changeTitleImage(iTitleType, true);
//}
//
//void GameUIPetAttrib::changeTitleImage(int iTitleType, bool bFocus)
//{
//	if (iTitleType == eTBS_Basic && m_btnBasic)
//	{
//		if (bFocus && m_picBasicDown)
//		{
//			m_btnBasic->SetImage(m_picBasicDown);
//		}
//		else if (m_picBasic)
//		{
//			m_btnBasic->SetImage(m_picBasic);
//		}
//		
//	}
//	else if (iTitleType == eTBS_Detail && m_btnDetail)
//	{
//		if (bFocus && m_picDetailDown)
//		{
//			m_btnDetail->SetImage(m_picDetailDown);
//		}
//		else if (m_picDetail)
//		{
//			m_btnDetail->SetImage(m_picDetail);
//		}
//	}
//	else if (iTitleType == eTBS_Advance && m_btnAdvance)
//	{
//		if (bFocus && m_picAdvanceDown)
//		{
//			m_btnAdvance->SetImage(m_picAdvanceDown);
//		}
//		else if (m_picAdvance)
//		{
//			m_btnAdvance->SetImage(m_picAdvance);
//		}
//	}
//	
//}
//
//bool GameUIPetAttrib::UpdateDetailPetName(std::string str)
//{
//	if (!m_tableLayerDetail 
//		|| !m_tableLayerDetail->GetDataSource() 
//		|| m_tableLayerDetail->GetDataSource()->Count() == 0
//		|| m_tableLayerDetail->GetDataSource()->Section(0)->Count() == 0) 
//	{
//		return false;
//	}
//	
//	NDUINode* node = m_tableLayerDetail->GetDataSource()->Section(0)->Cell(0);
//	if (node && node->IsKindOfClass(RUNTIME_CLASS(NDUIProp))) 
//	{
//		NDUIProp* prop = (NDUIProp*)node;
//		prop->SetKeyText(str);
//		prop->SetValueText(NDCommonCString("modify"));
//		prop->SetValueColor(ccc3(255, 0, 0));
//		return true;
//	}
//	
//	return false;
//}
//
//void GameUIPetAttrib::setBattlePetValueToPetAttr()
//{
//	/*
//	NDBattlePet *battlepet = NDPlayer::defaultHero().battlepet;
//	if (!battlepet)
//	{
//		return;
//	}
//	
//	Item* itemPet = ItemMgrObj.GetEquipItem(Item::eEP_Pet);
//	HeroPetInfo::PetData& pet = NDMapMgrObj.petInfo.m_data;
//	
//	if (itemPet == NULL || itemPet->iID != battlepet->m_id || itemPet->iID != pet.int_PET_ID) 
//	{
//		NDLog(@"error, 查看玩家装备的宠物id不正确");
//		return;
//	}
//	
//	//NDBattlePet& pet = *(NDPlayer::defaultHero().battlepet);
//	str_PET_ATTR_NAME = NDMapMgrObj.petInfo.str_PET_ATTR_NAME; // 名字STRING
//	int_PET_ATTR_LEVEL = pet.int_PET_ATTR_LEVEL; // 等级INT
//	int_PET_ATTR_EXP = pet.int_PET_ATTR_EXP; // 经验INT
//	int_PET_ATTR_LIFE = pet.int_PET_ATTR_LIFE; // 生命值INT
//	int_PET_ATTR_MAX_LIFE = pet.int_PET_ATTR_MAX_LIFE; // 最大生命值INT
//	int_PET_ATTR_MANA = pet.int_PET_ATTR_MANA; // 魔法值INT
//	int_PET_ATTR_MAX_MANA = pet.int_PET_ATTR_MAX_MANA; // 最大魔法值INT
//	int_PET_ATTR_STR = pet.int_PET_ATTR_STR; // 力量INT
//	int_PET_ATTR_STA = pet.int_PET_ATTR_STA; // 体质INT
//	int_PET_ATTR_AGI = pet.int_PET_ATTR_AGI; // 敏捷INT
//	int_PET_ATTR_INI = pet.int_PET_ATTR_INI; // 智力INT
//	int_PET_ATTR_LEVEL_INIT = pet.int_PET_ATTR_LEVEL_INIT; // 初始等级INT
//	int_PET_ATTR_STR_INIT = pet.int_PET_ATTR_STR_INIT; // 初始力量INT
//	int_PET_ATTR_STA_INIT = pet.int_PET_ATTR_STA_INIT; // 初始体质INT
//	int_PET_ATTR_AGI_INIT = pet.int_PET_ATTR_AGI_INIT; // 初始敏捷INT
//	int_PET_ATTR_INI_INIT = pet.int_PET_ATTR_INI_INIT; // 初始智力INT
//	int_PET_ATTR_LOYAL = pet.int_PET_ATTR_LOYAL; // 忠诚度INT
//	int_PET_ATTR_AGE = pet.int_PET_ATTR_AGE; // 寿命INT
//	int_PET_ATTR_FREE_SP = pet.int_PET_ATTR_FREE_SP; // 剩余技能点数INT
//	int_PET_PHY_ATK_RATE = pet.int_PET_PHY_ATK_RATE;// 物攻资质
//	int_PET_PHY_DEF_RATE = pet.int_PET_PHY_DEF_RATE;// 物防资质
//	int_PET_MAG_ATK_RATE = pet.int_PET_MAG_ATK_RATE;// 法攻资质
//	int_PET_MAG_DEF_RATE = pet.int_PET_MAG_DEF_RATE;// 法防资质
//	int_PET_ATTR_HP_RATE = pet.int_PET_ATTR_HP_RATE; // 生命资质
//	int_PET_ATTR_MP_RATE = pet.int_PET_ATTR_MP_RATE; // 魔法资质
//	int_PET_MAX_SKILL_NUM = pet.int_PET_MAX_SKILL_NUM;// 最大可学技能数
//	int_PET_SPEED_RATE = pet.int_PET_SPEED_RATE;// 速度资质
//	int_ATTR_FREE_POINT = pet.int_ATTR_FREE_POINT; // 自由点数
//	int_PET_ATTR_LEVEUP_EXP = pet.int_PET_ATTR_LEVEUP_EXP; // 升级经验
//	int_PET_ATTR_PHY_ATK = pet.int_PET_ATTR_PHY_ATK; // 物理攻击力INT
//	int_PET_ATTR_PHY_DEF = pet.int_PET_ATTR_PHY_DEF; // 物理防御INT
//	int_PET_ATTR_MAG_ATK = pet.int_PET_ATTR_MAG_ATK; // 法术攻击力INT
//	int_PET_ATTR_MAG_DEF = pet.int_PET_ATTR_MAG_DEF; // 法术抗性INT
//	int_PET_ATTR_HARD_HIT = pet.int_PET_ATTR_HARD_HIT;// 暴击
//	int_PET_ATTR_DODGE = pet.int_PET_ATTR_DODGE;// 闪避
//	int_PET_ATTR_ATK_SPEED = pet.int_PET_ATTR_ATK_SPEED;// 攻击速度
//	ownerName = NDPlayer::defaultHero().m_name;
//	
//	this->m_struPoint.iTotal = pet.int_ATTR_FREE_POINT;
//	this->m_struPoint.m_psProperty[_stru_point::ps_liliang].iFix = pet.int_PET_ATTR_STR;
//	this->m_struPoint.m_psProperty[_stru_point::ps_tizhi].iFix = pet.int_PET_ATTR_STA;
//	this->m_struPoint.m_psProperty[_stru_point::ps_minjie].iFix = pet.int_PET_ATTR_AGI;
//	this->m_struPoint.m_psProperty[_stru_point::ps_zhili].iFix = pet.int_PET_ATTR_INI;
//	
//	
//	int_PET_GROW_RATE_MAX=pet.int_PET_GROW_RATE_MAX;// 成长资质上限
//	int_PET_PHY_ATK_RATE_MAX=pet.int_PET_PHY_ATK_RATE_MAX;// 物攻资质上限
//	int_PET_PHY_DEF_RATE_MAX=pet.int_PET_PHY_DEF_RATE_MAX;// 物防资质上限
//	int_PET_MAG_ATK_RATE_MAX=pet.int_PET_MAG_ATK_RATE_MAX;// 法攻资质上限
//	int_PET_MAG_DEF_RATE_MAX=pet.int_PET_MAG_DEF_RATE_MAX;// 法防资质上限
//	int_PET_ATTR_HP_RATE_MAX=pet.int_PET_ATTR_HP_RATE_MAX; // 生命资质上限
//	int_PET_ATTR_MP_RATE_MAX=pet.int_PET_ATTR_MP_RATE_MAX; // 魔法资质上限
//	int_PET_SPEED_RATE_MAX=pet.int_PET_SPEED_RATE_MAX;// 速度资质上限
//	int_PET_GROW_RATE=pet.int_PET_GROW_RATE;//成长资质
//	bindStatus = pet.bindStatus;
//	*/
//}
//
//std::string GameUIPetAttrib::getPetType(int type) {
//	std::string s = "";
//	switch (type / 10 % 10) {
//		case 1:
//			s = NDCommonCString("LuMang");
//			break;
//		case 2:
//			s = NDCommonCString("LengJing");
//			break;
//		case 3:
//			s = NDCommonCString("TaoQi");
//			break;
//		case 4:
//			s = NDCommonCString("HangHou");
//			break;
//		case 5:
//			s = NDCommonCString("DangXiao");
//			break;
//	}
//	return s;
//}
//
//void GameUIPetAttrib::UpdateStrucPoint()
//{
//	m_struPoint.reset();
//	m_struPoint.iTotal = int_ATTR_FREE_POINT;
//	m_struPoint.m_psProperty[_stru_point::ps_liliang].iFix = int_PET_ATTR_STR;
//	m_struPoint.m_psProperty[_stru_point::ps_tizhi].iFix = int_PET_ATTR_STA;
//	m_struPoint.m_psProperty[_stru_point::ps_minjie].iFix = int_PET_ATTR_AGI;
//	m_struPoint.m_psProperty[_stru_point::ps_zhili].iFix = int_PET_ATTR_INI;
//}
//
////////////////////////////////////////////
//IMPLEMENT_CLASS(GamePetAttribScene, NDScene)
//
//GamePetAttribScene::GamePetAttribScene()
//{
//}
//
//GamePetAttribScene::~GamePetAttribScene()
//{
//}
//
//GamePetAttribScene* GamePetAttribScene::Scene()
//{
//	GamePetAttribScene *scene = new GamePetAttribScene;
//	scene->Initialization();
//	return scene;
//}
//
//void GamePetAttribScene::Initialization(bool bSelf/*=true*/)
//{
//	NDScene::Initialization();
//	
//	GameUIPetAttrib *attrib = new GameUIPetAttrib;
//	attrib->Initialization(bSelf);
//	this->AddChild(attrib, UILAYER_Z, UILAYER_PET_ATTRIB_TAG);
//}