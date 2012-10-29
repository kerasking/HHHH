/*
 *  CreateRoleScene.mm
 *  DragonDrive
 *
 *  Created by wq on 11-1-7.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#import "CreateRoleScene.h"
#import "NDUIFrame.h"
#import "NDUILayer.h"
#import "NDConstant.h"
#import "NDSprite.h"
#import "NDUIButton.h"
#import "InitMenuScene.h"
#import "NDUISynLayer.h"
#import "NDMsgDefine.h"
#import "NDMapMgr.h"
#import "NDDataTransThread.h"
#import "NDDirector.h"
#import "NDUIBaseGraphics.h"
#include "NDUtility.h"
#include "NDBeforeGameMgr.h"
#include "NDPath.h"

class RoleNode : public NDUILayer
{
public:
	RoleNode()
	{
		m_maleRole = NULL;
		m_femaleRole = NULL;
		m_curRole = NULL;
		m_curAniID = 0;
		m_picUserPick = NULL;
	}
	
	void Initialization() override
	{
		NDUILayer::Initialization();
		m_maleRole = new NDManualRole();
		m_maleRole->Initialization(508099992);
		m_maleRole->SetEquipment(30000, 0);
		m_maleRole->SetEquipment(1800, 0);
		m_maleRole->SetPosition(ccp(117, 187));
		m_maleRole->SetCurrentAnimation(MANUELROLE_SKILL_WARRIOR_KNIFE_SINGLE, YES);
		
		m_femaleRole = new NDManualRole();
		m_femaleRole->Initialization(408099521);
		m_femaleRole->SetEquipment(30000, 0);
		m_femaleRole->SetEquipment(1800, 0);
		m_femaleRole->SetPosition(ccp(117, 187));
		m_femaleRole->SetCurrentAnimation(MANUELROLE_SKILL_WARRIOR_KNIFE_SINGLE, YES);
		
		//this->SetContentSize(CGSizeMake(480, 320));
		this->AddChild(m_maleRole);
		this->AddChild(m_femaleRole);
		
		m_curRole = m_maleRole;
		m_curAniID = MANUELROLE_SKILL_WARRIOR_KNIFE_SINGLE;
		
//		m_picUserPick = new NDSprite;
//		m_picUserPick->Initialization(GetAniPath("user_picker.spr"));
//		m_picUserPick->SetCurrentAnimation(0, false);
//		m_picUserPick->SetPosition(ccp(27, 90));
//		this->AddChild(m_picUserPick);
	}
	
	
	~RoleNode()
	{
	}
	
	virtual void draw() override
	{
//		if (m_picUserPick) m_picUserPick->RunAnimation(true);
//		
//		if (!m_picUserPick->IsAnimationComplete()) {
//			return;
//		}
//		
		m_curRole->RunAnimation(true);
		if (m_curRole->IsAnimationComplete()) {
			m_curRole->SetCurrentAnimation(this->m_curAniID, YES);
		}
	}
	
	void SetSex(SpriteSex sex)
	{
		if (sex == SpriteSexMale)
		{
			m_curRole = m_maleRole;
		}
		else if (sex == SpriteSexFemale)
		{
			m_curRole = m_femaleRole;
		}
	}
	
	void SetHair(int style, int color)
	{
		m_curRole->SetHair(style, color);
	}
	
	void SetWeapon(int type)
	{
		m_curRole->SetWeaponType(WEAPON_NONE);
		m_curRole->SetSecWeaponType(WEAPON_NONE);
		int weaponID = 1110019;
		switch (type) {
			case 1:// 刀
				weaponID = 1800;
				m_curAniID = MANUELROLE_SKILL_WARRIOR_KNIFE_SINGLE;
				break;
			case 2:// 剑
				weaponID = 1200;
				m_curAniID = MANUELROLE_SKILL_WARRIOR_SWORD_SINGLE;
				break;
			case 3:// 杖
				weaponID = 2200;
				m_curAniID = MANUELROLE_SKILL_WIZZARD;
				break;
			case 4:// 弓
				weaponID = 2400;
				m_curAniID = MANUELROLE_SKILL_ASSASIN_BOW_AREA;
				break;
			case 5:// 双刀
				weaponID = 1600;
				m_curAniID = MANUELROLE_ATTACK_DUAL_WEAPON;
				break;
			case 6:// 双剑
				weaponID = 1000;
				m_curAniID = MANUELROLE_ATTACK_DUAL_WEAPON;
				break;
			case 7:// 匕首
				weaponID = 2800;
				m_curAniID = MANUELROLE_SKILL_ASSASIN_PONIARD_SINGLE;
				break;
		}
		
		m_curRole->SetEquipment(weaponID, 9);
		if (type > 4) {
			m_curRole->SetEquipment(weaponID, 9);
		}
		m_curRole->SetCurrentAnimation(m_curAniID, YES);
	}
	
	void play()
	{
		if (m_picUserPick) {
			m_picUserPick->SetCurrentAnimation(0, false);
		}
	}
private:
	NDManualRole *m_femaleRole;
	NDManualRole *m_maleRole;
	NDManualRole *m_curRole;
	NDSprite *m_picUserPick;
	int m_curAniID;
};

IMPLEMENT_CLASS(CreateRoleScene, NDScene)

CreateRoleScene* CreateRoleScene::Scene()
{	
	CreateRoleScene* scene = new CreateRoleScene();
	scene->Initialization();
	return scene;
}

enum WEANPON_MEMO
{
	DAO = 0,
	JIAN = 1,
	ZHANG = 2,
	BISHOU = 3,
	GONG = 4,
};

enum WEANPON_OPT
{
	OPT_DAO = 0,
	OPT_JIAN,
	OPT_ZHANG,
	OPT_GONG,
	OPT_SHUANGDAO,
	OPT_SHUANGJIAN,
	OPT_BISHOU,
};

CreateRoleScene::CreateRoleScene()
{
	m_menuLayer = NULL;
	m_frame = NULL;
	m_lbTitle = NULL;
	m_lbHairClr = NULL;
	m_lbNickName = NULL;
	m_lbSex = NULL;
	m_lbSytle = NULL;
	m_lbWeapon = NULL;
	m_edtNickName = NULL;
	m_role = NULL;
	m_optHair = NULL;
	m_optSex = NULL;
	m_optStyle = NULL;
	m_optWeapon = NULL;
	m_btnOk = NULL;
	m_btnCancel = NULL;
	m_memoWeapon = NULL;
	
	m_vWeaponMemo.push_back(NDCommonCString("CreateRoleDao"));
	m_vWeaponMemo.push_back(NDCommonCString("CreateRoleJian"));
	m_vWeaponMemo.push_back(NDCommonCString("CreateRoleZhang"));
	m_vWeaponMemo.push_back(NDCommonCString("CreateRoleBiShou"));
	m_vWeaponMemo.push_back(NDCommonCString("CreateRoleGong"));
	
	NDNetMsgPoolObj.RegMsg(_MSG_NOTIFY, this);
	
	m_bFirstClickNickName = true;
}

CreateRoleScene::~CreateRoleScene()
{
	NDNetMsgPoolObj.UnRegMsg(_MSG_NOTIFY);
}

void CreateRoleScene::Initialization()
{
	NDScene::Initialization();
	
	NDPicturePool& picpool = *(NDPicturePool::DefaultPool());
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	NDUILayer *layer = new NDUILayer();
	layer->Initialization();
	layer->SetBackgroundImage(NDPath::GetImgPathNew("login_background.png"));
	layer->SetFrameRect(CGRectMake(0, 0, winsize.width, winsize.height));
	this->AddChild(layer);
	
	m_menuLayer = new NDUILayer();
	m_menuLayer->Initialization();
	m_menuLayer->SetBackgroundImage(NDPath::GetImgPathNew("createrole_bg.png"));
	m_menuLayer->SetFrameRect(CGRectMake(0, 0, winsize.width, winsize.height));
	layer->AddChild(m_menuLayer);
	
	NDPicture *picCreateRole = picpool.AddPicture(NDPath::GetImgPathNew("create&login_text.png"));
	picCreateRole->Cut(CGRectMake(0, 0, 94, 24));
	NDUIImage *imgCreateRole = new NDUIImage;
	imgCreateRole->Initialization();
	imgCreateRole->SetFrameRect(CGRectMake(194, 16, 96, 24));
	imgCreateRole->SetPicture(picCreateRole, true);
	m_menuLayer->AddChild(imgCreateRole);
	
	//NDPicture *picName = picpool.AddPicture(GetImgPathNew("create&login_text.png"));
//	picName->Cut(CGRectMake(0, 48, 48, 24));
//	NDUIImage *imgName = new NDUIImage;
//	imgName->Initialization();
//	imgName->SetFrameRect(CGRectMake(103, 52, 48, 24));
//	imgName->SetPicture(picName, true);
//	m_menuLayer->AddChild(imgName);

	NDUILayer *layerRoleBg = new NDUILayer;
	layerRoleBg->Initialization();
	layerRoleBg->SetBackgroundImage(picpool.AddPicture(NDPath::GetImgPathNew("bg_sub_bg.png"), 480-32, 168), true);
	layerRoleBg->SetFrameRect(CGRectMake(16, 45, 480-32, 168));
	m_menuLayer->AddChild(layerRoleBg);
	
	m_edtNickName = new NDUICustomEdit();
	m_edtNickName->Initialization(ccp(14, 9), 148, 27, "input_name.png", "input_name.png");
	m_edtNickName->SetDelegate(this);
	m_edtNickName->SetText(NDCommonCString("InputNickName"));
	m_edtNickName->SetMaxLength(10);
	m_edtNickName->SetFontColor(ccc4(98, 98, 98, 255));
	m_edtNickName->SetDelegate(this);
	layerRoleBg->AddChild(m_edtNickName);
	
	NDPicture *picVerticalSplit = picpool.AddPicture(NDPath::GetImgPathNew("bg_splitline_vertical.png"), 0, 160);
	NDUIImage *imgVerticalSplit = new NDUIImage;
	imgVerticalSplit->Initialization();
	imgVerticalSplit->SetPicture(picVerticalSplit, true);
	imgVerticalSplit->SetFrameRect(CGRectMake(171, 4, picVerticalSplit->GetSize().width, 160));
	layerRoleBg->AddChild(imgVerticalSplit);
	
	CGPoint originPorp = ccp(180, 7);
	NDUIOptionButtonEx *tmpOPBtns[4];
	memset(tmpOPBtns, 0, sizeof(tmpOPBtns));
	
	NDPicture *optSel, *optUnSel, *optFocus;
	optSel = picpool.AddPicture(NDPath::GetImgPathNew("left_sel_normal.png"));
	optUnSel = picpool.AddPicture(NDPath::GetImgPathNew("left_sel_hightlight.png")); 
	optFocus = picpool.AddPicture(NDPath::GetImgPathNew("bg_focus.png")); 
	for (int i = ePropSex; i <= eWeapon; i++) 
	{
		SetProptImage(i, ccpAdd(originPorp, ccp(0, 7)), layerRoleBg);
		
		tmpOPBtns[i] = new NDUIOptionButtonEx();
		tmpOPBtns[i]->Initialization();
		tmpOPBtns[i]->SetOptionImage(optUnSel->Copy(), optSel->Copy());
		tmpOPBtns[i]->SetDelegate(this);
		tmpOPBtns[i]->SetFrameRect(CGRectMake(originPorp.x+64, originPorp.y-4+5, 448-254, 35));
		CGRect rectOpt = tmpOPBtns[i]->GetFrameRect();
		tmpOPBtns[i]->SetFocusImage(optFocus->Copy(), 
									true, 
									CGRectMake((rectOpt.size.width-optFocus->GetSize().width)/2,
											   (rectOpt.size.height-optFocus->GetSize().height)/2,
											   optFocus->GetSize().width, 
											   optFocus->GetSize().height)
									);
		layerRoleBg->AddChild(tmpOPBtns[i]);
		
		tmpOPBtns[i]->SetReadyDispatchEvent(i == ePropSex);
		
		NDPicture *picHorizontalSplit = picpool.AddPicture(NDPath::GetImgPathNew("bg_splitline_horizontal.png"), 448-254-26);
		NDUIImage *imgHorizontalSplit = new NDUIImage;
		imgHorizontalSplit->Initialization();
		imgHorizontalSplit->SetPicture(picHorizontalSplit, true);
		imgHorizontalSplit->SetFrameRect(CGRectMake(originPorp.x+64+16, originPorp.y+25+1+10, 448-254-26, picHorizontalSplit->GetSize().height));
		layerRoleBg->AddChild(imgHorizontalSplit);
		
		originPorp.y += 40;
	}
	
	m_optSex = tmpOPBtns[0]; m_optStyle = tmpOPBtns[1];
	m_optHair = tmpOPBtns[2]; m_optWeapon = tmpOPBtns[3];
	
	delete optSel;
	delete optUnSel;
	delete optFocus;
	
	SetOptImage();
	
	//layerRoleBg->SetBackgroundImage(picpool.AddPicture(GetImgPathNew("bg_sub_bg.png"), 480-32, 128), true);
//	layerRoleBg->SetFrameRect(CGRectMake(16, 85, 480-32, 128));
	
	m_memoWeapon = new NDUIMemo();
	m_memoWeapon->Initialization();
	m_memoWeapon->SetBackgroundPicture(picpool.AddPicture(NDPath::GetImgPathNew("bg_sub_bg.png"), 480-32, 49), true);
	m_memoWeapon->SetText(m_vWeaponMemo.at(DAO).c_str());
	m_memoWeapon->SetFontSize(12);
	m_memoWeapon->SetFontColor(ccc4(1, 115, 128, 255));
	m_memoWeapon->SetFrameRect(CGRectMake(16, 220, 480-32, 49));
	m_menuLayer->AddChild(m_memoWeapon);
	
	m_btnOk = new NDUIOkCancleButton;
	m_btnOk->Initialization(CGRectMake(96, 276, 77, 26), true);
	m_btnOk->SetDelegate(this);
	m_menuLayer->AddChild(m_btnOk);
	
	m_btnCancel = new NDUIOkCancleButton;
	m_btnCancel->Initialization(CGRectMake(305, 276, 77, 26),false);
	m_btnCancel->SetDelegate(this);
	m_menuLayer->AddChild(m_btnCancel);
	
	m_role = new RoleNode();
	m_role->Initialization();
	m_role->SetTouchEnabled(false);
	m_role->SetFrameRect(CGRectMake(0, 0, winsize.width, winsize.height));
	m_menuLayer->AddChild(m_role);
	
	/*
	m_frame = new NDUIFrame();
	m_frame->Initialization();
	m_frame->SetFrameRect(CGRectMake(66, 87, 120, 110));
	m_menuLayer->AddChild(m_frame);
	
	CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
	
	m_role = new RoleNode();
	m_role->Initialization();
	m_role->SetTouchEnabled(false);
	m_role->SetFrameRect(CGRectMake(0, 0, winSize.width, winSize.height));
	m_frame->AddChild(m_role);
	
	m_lbTitle = new NDUILabel();
	m_lbTitle->Initialization();
	m_lbTitle->SetTextAlignment(LabelTextAlignmentCenter);
	m_lbTitle->SetText("创建人物");
	m_lbTitle->SetFrameRect(CGRectMake(0, 5, winSize.width, 20));
	m_lbTitle->SetFontSize(20);
	m_lbTitle->SetFontColor(ccc4(255, 231, 0, 255));
	m_menuLayer->AddChild(m_lbTitle);
	
	m_lbNickName = new NDUILabel();
	m_lbNickName->Initialization();
	m_lbNickName->SetTextAlignment(LabelTextAlignmentLeft);
	m_lbNickName->SetText("昵称");
	m_lbNickName->SetFontSize(14);
	m_lbNickName->SetFrameRect(CGRectMake(47, 43, 30, 14));
	m_lbNickName->SetFontColor(ccc4(24, 85, 82, 255));
	m_menuLayer->AddChild(m_lbNickName);
	
	m_lbSex = new NDUILabel();
	m_lbSex->Initialization();
	m_lbSex->SetText("性别");
	m_lbSex->SetTextAlignment(LabelTextAlignmentLeft);
	m_lbSex->SetFrameRect(CGRectMake(200, 88, 30, 14));
	m_lbSex->SetFontColor(ccc4(24, 85, 82, 255));
	m_lbSex->SetFontSize(14);
	m_menuLayer->AddChild(m_lbSex);
	
	m_optSex = new NDUIOptionButton();
	m_optSex->Initialization();
	
	VEC_OPTIONS vOps;
	vOps.push_back("男");
	vOps.push_back("女");
	m_optSex->SetOptions(vOps);
	m_optSex->SetDelegate(this);
	
	m_optSex->SetFrameRect(CGRectMake(240, 86, 158, 18));
	m_optSex->SetFontColor(ccc4(24, 85, 82, 255));
	m_optSex->SetBgClr(ccc4(247, 235, 206, 255));
	m_menuLayer->AddChild(m_optSex);
	
	m_lbSytle = new NDUILabel();
	m_lbSytle->Initialization();
	m_lbSytle->SetText("造型");
	m_lbSytle->SetFontSize(14);
	m_lbSytle->SetTextAlignment(LabelTextAlignmentLeft);
	m_lbSytle->SetFrameRect(CGRectMake(200, 118, 30, 14));
	m_lbSytle->SetFontColor(ccc4(24, 85, 82, 255));
	m_menuLayer->AddChild(m_lbSytle);
	
	m_optStyle = new NDUIOptionButton();
	m_optStyle->Initialization();
	
	vOps.clear();
	vOps.push_back("01");
	vOps.push_back("02");
	vOps.push_back("03");
	m_optStyle->SetOptions(vOps);
	m_optStyle->SetDelegate(this);
	
	m_optStyle->SetFrameRect(CGRectMake(240, 116, 158, 18));
	m_optStyle->SetFontColor(ccc4(24, 85, 82, 255));
	m_optStyle->SetBgClr(ccc4(247, 235, 206, 255));
	m_menuLayer->AddChild(m_optStyle);
	
	m_lbHairClr = new NDUILabel();
	m_lbHairClr->Initialization();
	m_lbHairClr->SetText("发色");
	m_lbHairClr->SetFontSize(14);
	m_lbHairClr->SetTextAlignment(LabelTextAlignmentLeft);
	m_lbHairClr->SetFrameRect(CGRectMake(200, 148, 30, 14));
	m_lbHairClr->SetFontColor(ccc4(24, 85, 82, 255));
	m_menuLayer->AddChild(m_lbHairClr);
	
	m_optHair = new NDUIOptionButton();
	m_optHair->Initialization();
	
	vOps.clear();
	vOps.push_back("01");
	vOps.push_back("02");
	vOps.push_back("03");
	vOps.push_back("04");
	vOps.push_back("05");
	m_optHair->SetOptions(vOps);
	m_optHair->SetDelegate(this);
	
	m_optHair->SetFrameRect(CGRectMake(240, 146, 158, 18));
	m_optHair->SetFontColor(ccc4(24, 85, 82, 255));
	m_optHair->SetBgClr(ccc4(247, 235, 206, 255));
	m_menuLayer->AddChild(m_optHair);
	
	m_lbWeapon = new NDUILabel();
	m_lbWeapon->Initialization();
	m_lbWeapon->SetText("武器");
	m_lbWeapon->SetFontSize(14);
	m_lbWeapon->SetTextAlignment(LabelTextAlignmentLeft);
	m_lbWeapon->SetFrameRect(CGRectMake(200, 178, 30, 14));
	m_lbWeapon->SetFontColor(ccc4(24, 85, 82, 255));
	m_menuLayer->AddChild(m_lbWeapon);
	
	m_lbHint = new NDUILabel();
	m_lbHint->Initialization();
	m_lbHint->SetFontSize(14);
	m_lbHint->SetTextAlignment(LabelTextAlignmentCenter);
	m_lbHint->SetFrameRect(CGRectMake(0, 286, 480, 14));
	m_lbHint->SetFontColor(ccc4(255, 10, 0, 255));
	m_menuLayer->AddChild(m_lbHint);
	
	m_optWeapon = new NDUIOptionButton();
	m_optWeapon->Initialization();
	
	vOps.clear();
	vOps.push_back("刀");
	vOps.push_back("剑");
	vOps.push_back("杖");
	vOps.push_back("弓");
	vOps.push_back("双刀");
	vOps.push_back("双剑");
	vOps.push_back("匕首");
	m_optWeapon->SetOptions(vOps);
	m_optWeapon->SetDelegate(this);
	
	m_optWeapon->SetFrameRect(CGRectMake(240, 176, 158, 18));
	m_optWeapon->SetFontColor(ccc4(24, 85, 82, 255));
	m_optWeapon->SetBgClr(ccc4(247, 235, 206, 255));
	m_menuLayer->AddChild(m_optWeapon);
	
	NDUILine *line = new NDUILine();
	line->Initialization();
	line->SetColor(ccc3(24, 85, 82));
	line->SetFromPoint(CGPointMake(2, 76));
	line->SetToPoint(CGPointMake(winSize.width - 4, 76));
	line->SetWidth(2);
	m_menuLayer->AddChild(line);
	
	NDUIFrame *frame = new NDUIFrame();
	frame->Initialization();
	frame->SetFrameRect(CGRectMake(8, 206, 464, 56));
	m_menuLayer->AddChild(frame);
	
	m_memoWeapon = new NDUIMemo();
	m_memoWeapon->Initialization();
	m_memoWeapon->SetBackgroundColor(ccc4(228, 219, 169, 255));
	m_memoWeapon->SetText(m_vWeaponMemo.at(DAO).c_str());
	m_memoWeapon->SetFrameRect(CGRectMake(30, 210, 430, 50));
	m_menuLayer->AddChild(m_memoWeapon);
	*/
}

void CreateRoleScene::OnButtonClick(NDUIButton* button)
{
	// 返回
	if (m_btnCancel == button)
	{
		NDDirector::DefaultDirector()->ReplaceScene(InitMenuScene::Scene(), true);
	}
	else if (m_btnOk == button)
	{
		// 非法输入提示
		if (m_edtNickName->GetText().empty())
		{
			//m_lbHint->SetText("角色名字不能为空");
			showDialog("", NDCommonCString("RoleNameCantEmpty"));
		}
		else
		{
			//m_lbHint->SetText("");
			NDUISynLayer::Show(SYN_CREATE_ROLE);
			
			// 发送创建角色消息
			Byte camp = 0;
			Byte sex = m_optSex->GetOptionIndex() + 1;
			Byte model = m_optStyle->GetOptionIndex() + 1;
			Byte hairColor = m_optHair->GetOptionIndex() + 1;
			Byte career = m_optWeapon->GetOptionIndex();
			//if (career > 3) career = 6;
			career = career< 4 ? career + 11 : career + 19;
			
			int dwLook = sex * 100000000 + model * 10000000 + hairColor * 1000000 + 1 * 100000;
			NDTransData data(MB_LOGINSYSTEM_CREATE_NEWBIE);
			data << dwLook // 人物模型 4个字节
				<< career // 职业 1个字节 // 1,2,3
				<< camp; // 阵营 1个字节 // 1,2
			
			data.WriteUnicodeString(m_edtNickName->GetText());
			
			// 增加帐号名、手机机型、渠道号
			data.WriteUnicodeString(NDBeforeGameMgrObj.GetUserName());
			data.WriteUnicodeString(platformString());
			data.WriteUnicodeString(loadPackInfo(STRPARAM));
			
			NDDataTransThread::DefaultThread()->GetSocket()->Send(&data);
			
			//处理设备信息上发
			//NDDataPersist device;
			//std::string username = NDBeforeGameMgrObj.GetUserName();
//			if (!device.HasAccountDevice(username.c_str()))
//			{
				//设备信息上发
				//NDTransData bao(_MSG_ACCOUNT_MOBILE);
				//bao << (unsigned char)2;
				//bao.WriteUnicodeString(username);
				//bao << (unsigned char)2;
				//bao.WriteUnicodeString(platformString());
				//SEND_DATA(bao);
				//保存
				//device.AddAccountDevice(username.c_str());
				//device.SaveAccountDeviceList();
			//}
		}

	}
}

void CreateRoleScene::OnOptionChangeEx(NDUIOptionButtonEx* option)
{	
	// 性别
	SpriteSex sex = m_optSex->GetOptionIndex() == 0 ? SpriteSexMale : SpriteSexFemale;
	m_role->SetSex(sex);
	m_role->SetHair(m_optStyle->GetOptionIndex() + 1, m_optHair->GetOptionIndex() + 1);
	int index = m_optWeapon->GetOptionIndex();
	if (index > 3) index = 7;
	else index += 1;
	m_role->SetWeapon(index);
	
	if (option == m_optWeapon)
	{
		switch (index-1)
		{
			case OPT_DAO: // 刀
				m_memoWeapon->SetText(m_vWeaponMemo.at(DAO).c_str());
				break;
			case OPT_JIAN: // 剑
				m_memoWeapon->SetText(m_vWeaponMemo.at(JIAN).c_str());
				break;
			case OPT_ZHANG: // 杖
				m_memoWeapon->SetText(m_vWeaponMemo.at(ZHANG).c_str());
				break;
			case OPT_GONG: // 弓
				m_memoWeapon->SetText(m_vWeaponMemo.at(GONG).c_str());
				break;
			case OPT_SHUANGDAO: // 双刀
				m_memoWeapon->SetText(m_vWeaponMemo.at(DAO).c_str());
				break;
			case OPT_SHUANGJIAN: // 双剑
				m_memoWeapon->SetText(m_vWeaponMemo.at(JIAN).c_str());
				break;
			case OPT_BISHOU: // 匕首
				m_memoWeapon->SetText(m_vWeaponMemo.at(BISHOU).c_str());
				break;
			default:
				break;
		}
		
		m_role->play();
	}
}

bool CreateRoleScene::OnClickOptionEx(NDUIOptionButtonEx* option)
{
	if (!option->IsReadyDispatchEvent())
	{
		NDUIOptionButtonEx *tmpOPBtns[4];
		tmpOPBtns[0] = m_optSex; tmpOPBtns[1] = m_optStyle;
		tmpOPBtns[2] = m_optHair; tmpOPBtns[3] = m_optWeapon;
		
		for (int i = 0; i < 4; i++) 
		{
			if (!tmpOPBtns[i]) continue;
			
			tmpOPBtns[i]->SetReadyDispatchEvent(tmpOPBtns[i] == option);
		}
		
		return true;
	}
	
	return false;
}

bool CreateRoleScene::process(MSGID msgID, NDEngine::NDTransData*, int len)
{
	switch (msgID)
	{
		case _MSG_NOTIFY:
			NDMapMgr::bFirstCreate = true;
			break;
		default:
			break;
	}
	return false;
}

void CreateRoleScene::SetProptImage(int index, CGPoint orgin, NDUINode* parent)
{
	if (!parent) return;
	
	NDPicturePool& picpool = *(NDPicturePool::DefaultPool());
	
	NDPicture *picProp = picpool.AddPicture(NDPath::GetImgPathNew("bg_property.png"));
	
	CGSize propSize = picProp->GetSize();
	
	NDUIImage *res = new NDUIImage;
	
	res->Initialization();
	
	res->EnableEvent(false);
	
	res->SetPicture(picProp, true);
	
	res->SetFrameRect(CGRectMake(orgin.x, orgin.y, propSize.width, propSize.height));
	
	parent->AddChild(res);
	
	CGRect cut = CGRectZero;
	
	switch (index) {
		case ePropSex:
			cut = CGRectMake(0, 0, 36, 18);
			break;
		case ePropStyle:
			cut = CGRectMake(5*18, 0, 36, 18);
			break;
		case eHair:
			cut = CGRectMake(7*18, 0, 36, 18);
			break;
		case eWeapon:
			cut = CGRectMake(9*18, 0, 36, 18);
			break;
		default:
			break;
	}
	
	if (cut.size.width == 0 || cut.size.height == 0) return;
	
	NDPicture *picSel = picpool.AddPicture(NDPath::GetImgPathNew("create&login_text2.png"));
	
	picSel->Cut(cut);
	
	NDUIImage *subImage = new NDUIImage;
	
	subImage->Initialization();
	
	subImage->SetPicture(picSel, true);
	
	subImage->SetFrameRect(CGRectMake(1, 1, picSel->GetSize().width, picSel->GetSize().height));
	
	res->AddChild(subImage);
}

void CreateRoleScene::SetOptImage()
{
	if (m_optSex)
	{
		VEC_OPTIONS_PIC vec_pic, vec_pic_sel;
		vec_pic.push_back(GetCreateCombinePic(CGRectMake(18*3, 0, 18, 18), CGRectZero)); //male
		vec_pic.push_back(GetCreateCombinePic(CGRectMake(18*4, 0, 18, 18), CGRectZero)); //female
		vec_pic_sel.push_back(GetCreateCombinePic(CGRectMake(18*3, 18, 18, 18), CGRectZero)); //male
		vec_pic_sel.push_back(GetCreateCombinePic(CGRectMake(18*4, 18, 18, 18), CGRectZero)); //female
		m_optSex->SetPicOptions(vec_pic,true);
		m_optSex->SetFocusPicOptions(vec_pic_sel,true);
	}
	
	if (m_optStyle)
	{
		VEC_OPTIONS_PIC vec_pic, vec_pic_sel;
		vec_pic.push_back(GetCreateCombinePic(CGRectMake(5, 18*4, 7, 18), CGRectMake(24, 18*4, 6, 18), CGRectZero)); //01
		vec_pic.push_back(GetCreateCombinePic(CGRectMake(5, 18*4, 7, 18), CGRectMake(40, 18*4, 9, 18), CGRectZero)); //02
		vec_pic.push_back(GetCreateCombinePic(CGRectMake(5, 18*4, 7, 18), CGRectMake(58, 18*4, 10, 18), CGRectZero)); //03
		vec_pic_sel.push_back(GetCreateCombinePic(CGRectMake(5, 18*5, 7, 18), CGRectMake(24, 18*5, 6, 18), CGRectZero)); //01
		vec_pic_sel.push_back(GetCreateCombinePic(CGRectMake(5, 18*5, 7, 18), CGRectMake(40, 18*5, 9, 18), CGRectZero)); //02
		vec_pic_sel.push_back(GetCreateCombinePic(CGRectMake(5, 18*5, 7, 18), CGRectMake(58, 18*5, 10, 18), CGRectZero)); //03
		m_optStyle->SetPicOptions(vec_pic,true);
		m_optStyle->SetFocusPicOptions(vec_pic_sel,true);
	}
	
	if (m_optHair)
	{
		VEC_OPTIONS_PIC vec_pic, vec_pic_sel;
		vec_pic.push_back(GetCreateCombinePic(CGRectMake(5, 18*4, 7, 18), CGRectMake(24, 18*4, 6, 18), CGRectZero)); //01
		vec_pic.push_back(GetCreateCombinePic(CGRectMake(5, 18*4, 7, 18), CGRectMake(40, 18*4, 9, 18), CGRectZero)); //02
		vec_pic.push_back(GetCreateCombinePic(CGRectMake(5, 18*4, 7, 18), CGRectMake(58, 18*4, 10, 18), CGRectZero)); //03
		vec_pic.push_back(GetCreateCombinePic(CGRectMake(5, 18*4, 7, 18), CGRectMake(76, 18*4, 10, 18), CGRectZero)); //04
		vec_pic.push_back(GetCreateCombinePic(CGRectMake(5, 18*4, 7, 18), CGRectMake(94, 18*4, 10, 18), CGRectZero)); //05
		vec_pic_sel.push_back(GetCreateCombinePic(CGRectMake(5, 18*5, 7, 18), CGRectMake(24, 18*5, 6, 18), CGRectZero)); //01
		vec_pic_sel.push_back(GetCreateCombinePic(CGRectMake(5, 18*5, 7, 18), CGRectMake(40, 18*5, 9, 18), CGRectZero)); //02
		vec_pic_sel.push_back(GetCreateCombinePic(CGRectMake(5, 18*5, 7, 18), CGRectMake(58, 18*5, 10, 18), CGRectZero)); //03
		vec_pic_sel.push_back(GetCreateCombinePic(CGRectMake(5, 18*5, 7, 18), CGRectMake(76, 18*5, 10, 18), CGRectZero)); //04
		vec_pic_sel.push_back(GetCreateCombinePic(CGRectMake(5, 18*5, 7, 18), CGRectMake(94, 18*5, 10, 18), CGRectZero)); //05
		m_optHair->SetPicOptions(vec_pic,true);
		m_optHair->SetFocusPicOptions(vec_pic_sel,true);
	}
	
	if (m_optWeapon)
	{
		VEC_OPTIONS_PIC vec_pic, vec_pic_sel;
		
		vec_pic.push_back(GetCreateCombinePic(CGRectMake(0, 18*2, 36, 18), CGRectZero)); //刀客
		vec_pic.push_back(GetCreateCombinePic(CGRectMake(18*3, 18*2, 36, 18), CGRectZero)); //剑侠
		vec_pic.push_back(GetCreateCombinePic(CGRectMake(18*8, 18*2, 36, 18), CGRectZero)); //术师
		vec_pic.push_back(GetCreateCombinePic(CGRectMake(18*5, 18*2, 54, 18), CGRectZero)); //弓箭手
		vec_pic.push_back(GetCreateCombinePic(CGRectMake(18*2, 18*2, 18, 18), CGRectMake(18, 18*2, 18, 18), CGRectZero)); //刺客
		
		vec_pic_sel.push_back(GetCreateCombinePic(CGRectMake(0, 18*3, 36, 18), CGRectZero)); //刀客
		vec_pic_sel.push_back(GetCreateCombinePic(CGRectMake(18*3, 18*3, 36, 18), CGRectZero)); //剑侠
		vec_pic_sel.push_back(GetCreateCombinePic(CGRectMake(18*8, 18*3, 36, 18), CGRectZero)); //术师
		vec_pic_sel.push_back(GetCreateCombinePic(CGRectMake(18*5, 18*3, 54, 18), CGRectZero)); //弓箭手
		vec_pic_sel.push_back(GetCreateCombinePic(CGRectMake(18*2, 18*3, 18, 18), CGRectMake(18, 18*3, 18, 18), CGRectZero)); //刺客
		
		m_optWeapon->SetPicOptions(vec_pic,true);
		m_optWeapon->SetFocusPicOptions(vec_pic_sel,true);
	}
	
//	m_optSex->SetVisible(true);
//	m_optStyle->SetVisible(false);
//	m_optHair->SetVisible(false);
//	m_optWeapon->SetVisible(false);
}

NDCombinePicture* CreateRoleScene::GetCreateCombinePic(CGRect cut, ...)
{
	NDCombinePicture* res = new NDCombinePicture;
	
	NDPicturePool& picpool = *(NDPicturePool::DefaultPool());
	
	va_list argumentList;
	CGRect eachObject;
	std::vector<CGRect> vecRect; 
	vecRect.push_back(cut);
	
	va_start(argumentList, cut);
	while (!CGRectEqualToRect((eachObject = va_arg(argumentList, CGRect)), CGRectZero)) 
	{
		vecRect.push_back(eachObject);
	}
	va_end(argumentList);

	for_vec(vecRect, std::vector<CGRect>::iterator)
	{
		NDPicture *pic = picpool.AddPicture(NDPath::GetImgPathNew("create&login_text2.png"));
		
		pic->Cut(*it);
		
		res->AddPicture(pic, CombintPictureAligmentRight);
	}
	
	return res;
}

bool CreateRoleScene::OnEditClick(NDUIEdit* edit)
{
	if (edit == m_edtNickName && m_bFirstClickNickName)
	{
		edit->SetText("");
		m_bFirstClickNickName = false;
	}
	
	return true;
}
