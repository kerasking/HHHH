---------------------------------------------------
--描述: 培养
--时间: 2012.3.21
--作者: wjl
---------------------------------------------------
RoleTrainUI = {}
local p = RoleTrainUI;

-- 界面控件坐标定义
local winsize = GetWinSize();

local CONTAINTER_W = RectUILayer.size.w / 2;
local CONTAINTER_H = RectUILayer.size.h;
local CONTAINTER_X = RectUILayer.size.w / 2;
local CONTAINTER_Y = 0;

local ATTR_OFFSET_X = RectUILayer.size.w / 2;
local ATTR_OFFSET_Y = 0;

local ID_ROLETRAIN_R_CTRL_PICTURE_STATE_3				= 29;
local ID_ROLETRAIN_R_CTRL_PICTURE_STATE_2				= 28;
local ID_ROLETRAIN_R_CTRL_PICTURE_STATE_1				= 27;
local ID_ROLETRAIN_R_CTRL_BUTTON_SAVE					= 115;
local ID_ROLETRAIN_R_CTRL_BUTTON_TRAIN_EXTREME			= 114;
local ID_ROLETRAIN_R_CTRL_BUTTON_TRAIN_DIAMOND			= 113;
local ID_ROLETRAIN_R_CTRL_BUTTON_TRAIN_PLATINA			= 112;
local ID_ROLETRAIN_R_CTRL_BUTTON_TRAIN_STR				= 111;
local ID_ROLETRAIN_R_CTRL_BUTTON_TRAIN_NOR				= 110;
local ID_ROLETRAIN_R_CTRL_TEXT_MAGIC_NEW				= 109;
local ID_ROLETRAIN_R_CTRL_TEXT_STUNT_NEW				= 108;
local ID_ROLETRAIN_R_CTRL_TEXT_ATTACK_NEW				= 107;
local ID_ROLETRAIN_R_CTRL_TEXT_MAGIC_OLD				= 106;
local ID_ROLETRAIN_R_CTRL_TEXT_STUNT_OLD				= 105;
local ID_ROLETRAIN_R_CTRL_TEXT_ATTACK_OLD				= 104;
local ID_ROLETRAIN_R_CTRL_TEXT_103						= 103;
local ID_ROLETRAIN_R_CTRL_TEXT_102						= 102;
local ID_ROLETRAIN_R_CTRL_TEXT_101						= 101;
local ID_ROLETRAIN_R_CTRL_TEXT_100						= 100;
local ID_ROLETRAIN_R_CTRL_TEXT_99						= 99;
local ID_ROLETRAIN_R_CTRL_TEXT_98						= 98;
local ID_ROLETRAIN_R_CTRL_TEXT_97						= 97;
local ID_ROLETRAIN_R_CTRL_TEXT_96						= 96;

local ID_ROLETRAIN_R_CTRL_TEXT_LEVEL					= 94;
local ID_ROLETRAIN_R_CTRL_TEXT_93						= 93;
local ID_ROLETRAIN_R_CTRL_TEXT_ROLE_NAME				= 92;
local long ID_ROLETRAIN_R_CTRL_PICTURE_ROLE					= 90;
local long ID_ROLETRAIN_R_CTRL_PICTURE_BG					= 91;

local ID_ROLETRAIN_R_CTRL_BUTTON_CLOSE					= 95;

p.TagUiLayer = NMAINSCENECHILDTAG.RoleTrain;
p.TagClose = ID_ROLETRAIN_R_CTRL_BUTTON_CLOSE;
p.TagContainer = 677;

p.TagName = ID_ROLETRAIN_R_CTRL_TEXT_ROLE_NAME;
p.TagLevel = ID_ROLETRAIN_R_CTRL_TEXT_LEVEL;

p.TagOldPropert = {
	phy = ID_ROLETRAIN_R_CTRL_TEXT_ATTACK_OLD,
	skl = ID_ROLETRAIN_R_CTRL_TEXT_STUNT_OLD,
	mag = ID_ROLETRAIN_R_CTRL_TEXT_MAGIC_OLD,
}

p.TagNewPropert = {
	phy = ID_ROLETRAIN_R_CTRL_TEXT_ATTACK_NEW,
	skl = ID_ROLETRAIN_R_CTRL_TEXT_STUNT_NEW,
	mag = ID_ROLETRAIN_R_CTRL_TEXT_MAGIC_NEW,
}

p.TagSignPic = {
	phy = ID_ROLETRAIN_R_CTRL_PICTURE_STATE_1,
	skl = ID_ROLETRAIN_R_CTRL_PICTURE_STATE_2,
	mag = ID_ROLETRAIN_R_CTRL_PICTURE_STATE_3,
}

p.TagTrain = {
	ID_ROLETRAIN_R_CTRL_BUTTON_TRAIN_NOR,
	ID_ROLETRAIN_R_CTRL_BUTTON_TRAIN_STR,
	ID_ROLETRAIN_R_CTRL_BUTTON_TRAIN_PLATINA,
	ID_ROLETRAIN_R_CTRL_BUTTON_TRAIN_DIAMOND,
	ID_ROLETRAIN_R_CTRL_BUTTON_TRAIN_EXTREME,	
}

p.TagTrainName = {
	"普通培养",
	"加强培养",
	"白金培养",
	"钻石培养",
	"至尊培养",
}

p.TagSave = ID_ROLETRAIN_R_CTRL_BUTTON_SAVE;

p.mPetId = nil;
p.mTrain = nil;

p.mOldTrain = {};
p.mSaveIgnorConfirm = false;
p.mTrainIgnorConfirm = false;
p.mCurrentType = nil;

function p.isInShow()
	return IsUIShow(p.TagUiLayer);
end

function p.LoadUI(petId)
	p.mPetId = petId;
	LogInfo("petId%d", petId);
	if not RolePet.IsExistPet(petId) then
		LogInfo("PlayerUIAttr role train, invalid petid");
		return true;
	end
			
	if IsUIShow(p.TagUiLayer) then
		p.refreshInfo();
		return true;
	end
	
	local scene = GetSMGameScene();	
	--local scene = director:GetRunningScene();
	if scene == nil then
		LogInfo("scene == nil,load PlayerAttr failed!");
		return;
	end
	
	local layer = createNDUILayer();
	if layer == nil then
		return false;
	end
	layer:Init();
	layer:SetTag(p.TagUiLayer);
	layer:SetFrameRect(RectUILayer);
	layer:SetBackgroundColor(ccc4(125, 125, 125, 0));
	scene:AddChild(layer);
	
	--初始化ui
	local uiLoad = createNDUILoad();
	if not CheckP(uiLoad) then
		return false;
	end
	
	uiLoad:Load("RoleTrain_R.ini", layer, p.OnUIEvent, CONTAINTER_X, CONTAINTER_Y);
	uiLoad:Free();
	
	p.initData();
	p.initSubUI();

	
	return true;
end

function p.CloseUI()
	p.freeData();
	CloseUI(p.TagUiLayer);
end

function p.OnUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if p.TagClose == tag then
			p.CloseUI();
		--elseif (p.TagOpen == tag ) then
		elseif p.TagSave == tag then
			p.onClickSave();
		elseif p.onClickItem(uiNode, tag) then
		end
	end
	return true;
end

function p.onClickItem(uiNode, tag)
	for i = 1, #p.TagTrain do
		if tag == p.TagTrain[i] then
			p.mCurrentType = i;
			if (i > 1 and (not p.mTrainIgnorConfirm)) then
				local money = SafeN2S(VipConfig.getTrainMoney(i))
				local tip = "花费" .. money .. "元宝使用" ..p.TagTrainName[i].."，是否继续？" 
				CommonDlg.ShowNoPrompt(tip, p.onTrainGetConfirm);
			else
				p.sendTrain();
			end
			return true;
		end
	end
	return false;
end



function p.onClickSave()
	if ((not p.mTrain) or not p.mOldTrain ) then
		return;
	end
	if not p.mSaveIgnorConfirm then
		if (p.mTrain.phy < p.mOldTrain.phy or p.mTrain.skl < p.mOldTrain.skl or p.mTrain.mag < p.mOldTrain.mag) then
			CommonDlg.ShowNoPrompt("新属性低于原属性，是否继续保存？", p.onSaveConfirm);
			return true;
		end
	end
	
	p.sendSave();
	return true;
end

function p.onSaveConfirm(nId, event, parm)
	
	if event == CommonDlg.EventCheck then
		if (parm and parm == true) then
			p.mSaveIgnorConfirm = true;
			LogInfo("isCheck...");
		end
	elseif event == CommonDlg.EventOK then
		p.sendSave();
	end
end

function p.onTrainGetConfirm(nId, event, parm)
	if event == CommonDlg.EventCheck then
		if (parm and parm == true) then
			p.mTrainIgnorConfirm = true;
			LogInfo("isCheck...");
		end
	elseif event == CommonDlg.EventOK then
		p.sendTrain();
	end
end

function p.sendSave()
	ShowLoadBar();
	MsgRoleTrain.sendTrainCommit(p.mPetId);
end

function p.sendTrain()
	if not p.mCurrentType then
		return;
	end
	ShowLoadBar();
	MsgRoleTrain.sendTrain(p.mPetId, p.mCurrentType);
end

function p.initSubUI()
	--p.iniContainer();
	local layer = p.getUiLayer();
	local platinalV = GetButton(layer, p.TagTrain[3])
	if (platinalV and (not PlayerVip.hasPlatinaTrain()) ) then
		platinalV:EnalbeGray(true);
	end
	
	local diamondV = GetButton(layer, p.TagTrain[4])
	if (diamondV and (not PlayerVip.hasDiamondTrain()) ) then
		diamondV:EnalbeGray(true);
	end
	
	local imperialV = GetButton(layer, p.TagTrain[5])
	if (imperialV and (not PlayerVip.hasImperialTrain()) ) then
		imperialV:EnalbeGray(true);
	end
	
	p.refreshInfo();
end

function p.refreshInfo()
	
	local layer		= p.getUiLayer();
	local nameV		= GetLabel(layer, p.TagName);  
	local levelV	= GetLabel(layer, p.TagLevel);
	local oldPhyV	= GetLabel(layer, p.TagOldPropert.phy);
	local oldSklV	= GetLabel(layer, p.TagOldPropert.skl);
	local oldMgV	= GetLabel(layer, p.TagOldPropert.mag);
	
	local orgPhy	= ConvertN(p.getOrgPhy(p.mPetId));
	local orgSkl	= ConvertN(p.getOrgSkl(p.mPetId));
	local orgMag	= ConvertN(p.getOrgMag(p.mPetId));
	local trainPhy	= ConvertN(p.getTrainPhy(p.mPetId));
	local trainSkl	= ConvertN(p.getTrainSkl(p.mPetId));
	local trainMag	= ConvertN(p.getTrainMag(p.mPetId));
	
	p.mOldTrain.phy = trainPhy;
	p.mOldTrain.skl = trainSkl;
	p.mOldTrain.mag = trainMag;
	
	
	
	if CheckP(nameV) then
		nameV:SetText(ConvertS(RolePet.GetPetInfoS(p.mPetId, PET_ATTR.PET_ATTR_NAME)));--SafeN2S(p.getPetLevel(p.mPetId)));
	end
	
	if CheckP(levelV) then
		levelV:SetText(SafeN2S(p.getPetLevel(p.mPetId)));--SafeN2S(p.getPetLevel(p.mPetId)));
	end
	
	if CheckP(oldPhyV) then
		LogInfo("ophy:%d", trainPhy);
		oldPhyV:SetText(string.format("%s+%s", SafeN2S(orgPhy), SafeN2S(trainPhy)));
	end
	if CheckP(oldSklV) then
		oldSklV:SetText(string.format("%s+%s", SafeN2S(orgSkl), SafeN2S(trainSkl)));
	end
	if CheckP(oldMgV) then
		oldMgV:SetText(string.format("%s+%s", SafeN2S(orgMag), SafeN2S(trainMag)));
	end
	
	p.refreshRightInfo();

end

function p.refreshRightInfo()
	
	local layer		= p.getUiLayer();
	
	local orgPhy	= ConvertN(p.getOrgPhy(p.mPetId));
	local orgSkl	= ConvertN(p.getOrgSkl(p.mPetId));
	local orgMag	= ConvertN(p.getOrgMag(p.mPetId));
	
	local newPhyV	= GetLabel(layer, p.TagNewPropert.phy);
	local newSklV	= GetLabel(layer, p.TagNewPropert.skl);
	local newMagV	= GetLabel(layer, p.TagNewPropert.mag);
	
	local phyPicV	= GetImage(layer, p.TagSignPic.phy);
	local sklPicV	= GetImage(layer, p.TagSignPic.skl);
	local magPicV	= GetImage(layer, p.TagSignPic.mag);
	
	if CheckP(newPhyV) then
		if p.mTrain and p.mTrain.phy then
			newPhyV:SetText(string.format("%s+%s", SafeN2S(orgPhy) ,SafeN2S(p.mTrain.phy)));
			if (p.mOldTrain and p.mOldTrain.phy) then
				phyPicV:SetVisible(true);
				if (p.mOldTrain.phy > p.mTrain.phy)	then
					phyPicV:SetPicture(p.getDownPic(), false);
				elseif (p.mOldTrain.phy < p.mTrain.phy ) then
					phyPicV:SetPicture(p.getUpPic(), false);
				else
					phyPicV:SetVisible(false);
				end
			end
		else
			newPhyV:SetText("");
			phyPicV:SetVisible(false);
		end
	end
	if CheckP(newSklV) then
		if p.mTrain and p.mTrain.skl then
			newSklV:SetText(string.format("%s+%s", SafeN2S(orgSkl) ,SafeN2S(p.mTrain.skl)));
			if (p.mOldTrain and p.mOldTrain.skl) then
				sklPicV:SetVisible(true);
				if (p.mOldTrain.skl > p.mTrain.skl)	then
					sklPicV:SetPicture(p.getDownPic(), false);
				elseif (p.mOldTrain.skl < p.mTrain.skl ) then
					sklPicV:SetPicture(p.getUpPic(), false);
				else
					sklPicV:SetVisible(false);
				end
			end
			
		else
			newSklV:SetText("");
			sklPicV:SetVisible(false);
		end
	end
	if CheckP(newMagV) then
		if p.mTrain and p.mTrain.mag then
			newMagV:SetText(string.format("%s+%s", SafeN2S(orgMag) ,SafeN2S(p.mTrain.mag)));
			if (p.mOldTrain and p.mOldTrain.mag) then
				magPicV:SetVisible(true);
				if (p.mOldTrain.mag > p.mTrain.mag)	then
					magPicV:SetPicture(p.getDownPic(), false);
				elseif (p.mOldTrain.mag < p.mTrain.mag ) then
					magPicV:SetPicture(p.getUpPic(),false);
				else
					magPicV:SetVisible(false);
				end
			end
		else
			newMagV:SetText("");
			magPicV:SetVisible(false);
		end
	end
	
	local saveV = GetButton(layer, p.TagSave);
	if p.mTrain then
		saveV:EnalbeGray(false);
	else
		saveV:EnalbeGray(true);
	end
end

function p.iniContainer()
	local container = p.getContainerById(p.TagContainer);
	if not CheckP(container) then
		LogInfo("nil == container");
		return;
	end
	container:RemoveAllView();
	local rectview = container:GetFrameRect();
	
	container:SetViewSize(CGSizeMake(rectview.size.w, rectview.size.h));
	
	local lst, count = MsgMagic.getRoleMatrixList();
	p.mMatrixList = lst;
	p.mCurrentPage = 1;
	
	
	if (count == nil or count < 1) then
		count = 1
	end
	local page = 1;--math.ceil((count-1)/3);
	
	for i = 1,  page do
	
	local view = createUIScrollView();
	
	if not CheckP(view) then
		LogInfo("view == nil");
		return;
	end
	view:Init(false);
	view:SetScrollStyle(UIScrollStyle.Horzontal);
	view:SetViewId(i);
	view:SetMovableViewer(container);
	view:SetScrollViewer(container);
	view:SetContainer(container);
	container:AddView(view);
	
	--初始化ui
	local uiLoad = createNDUILoad();
	if not CheckP(uiLoad) then
		return false;
	end
	
	uiLoad:Load("NormalCopy_M.ini", view, p.OnUIEvent, 0, 0);
	
	uiLoad:Free();
   end
end


function p.getContainerById(nId)
	local layer = p.getUiLayer();
	local container = GetScrollViewContainer(layer, nId);
	return container;
	
end

function p.getUiLayer()
	local scene = GetSMGameScene();
	if not CheckP(scene) then
		return nil;
	end
	
	local layer = GetUiLayer(scene, p.TagUiLayer);
	if not CheckP(layer) then
		LogInfo("nil == layer")
		return nil;
	end
	
	return layer;
end


function p.clickButton(node) 
	
end


function p.processNet(msgId, m)
	if (msgId == nil ) then
		LogInfo("processNet msgId == nil" );
	end
	--LogInfo(string.format("processNet%d" , msgId));
	if msgId == NMSG_Type._MSG_ROLE_TRAIN_GET then
	elseif msgId == NMSG_Type._MSG_ROLE_TRAIN_TRAIN then
		p.mTrain = m;
		p.refreshRightInfo();
	elseif msgId == NMSG_Type._MSG_ROLE_TRAIN_COMMIT then
		p.mTrain = nil;
		PlayerUIAttr.UpdatePetAttrById(p.mPetId);
		p.refreshInfo();
	end
	
	CloseLoadBar();
end

-- level
function p.getPetLevel(nPetId)
	return RolePet.GetPetInfoN(nPetId, PET_ATTR.PET_ATTR_LEVEL);
end

-- 属性武力值
function  p.getOrgPhy(nPetId)
	return RolePet.GetPetInfoN(nPetId,PET_ATTR.PET_ATTR_PHYSICAL) + RolePet.GetMedicinePhy(nPetId);
end
--培养武力值
function  p.getTrainPhy(nPetId)
	return RolePet.GetPetInfoN(nPetId,PET_ATTR.PET_ATTR_PHY_FOSTER);
end

-- 属性绝技值
function  p.getOrgSkl(nPetId)
	return RolePet.GetPetInfoN(nPetId,PET_ATTR.PET_ATTR_SUPER_SKILL) + RolePet.GetMedicineSuperSkill(nPetId);
end
--培养绝技值
function  p.getTrainSkl(nPetId)
	return RolePet.GetPetInfoN(nPetId,PET_ATTR.PET_ATTR_SUPER_SKILL_FOSTER);
end

-- 属性法术值
function  p.getOrgMag(nPetId)
	return RolePet.GetPetInfoN(nPetId,PET_ATTR.PET_ATTR_MAGIC) + RolePet.GetMedicineMagic(nPetId);
end
--培养法术值
function  p.getTrainMag(nPetId)
	return RolePet.GetPetInfoN(nPetId,PET_ATTR.PET_ATTR_MAGIC_FOSTER);
end

function p.initData()
	p.initConst();
	p.mCurrentType = nil;
	p.mTrain = nil;
	p.mOldTrain = {};
	MsgRoleTrain.mUIListener = p.processNet;
end

function p.freeData()
	MsgRoleTrain.mUIListener = nil;
	p.mOldTrain = {};
	p.mTrain = nil;
end

function p.initConst()
end

function p.getUpPic()
	local pool = DefaultPicPool();
	return pool:AddPicture(GetSMImgPath("mark_up.png"), false)
end

function p.getDownPic()
	local pool = DefaultPicPool();
	return pool:AddPicture(GetSMImgPath("mark_down.png"), false)
end

