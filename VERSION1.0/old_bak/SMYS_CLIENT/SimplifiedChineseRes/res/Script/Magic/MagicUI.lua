---------------------------------------------------
--描述: 奇术
--时间: 2012.2.8
--作者: wjl
---------------------------------------------------
MagicUI = {}
local p = MagicUI;

p.TabTag = {
	ATTACK = 860,
	MATRIX = 861,
};

p.OFFSET_X = 8;
p.OFFSET_Y = 16;

--属性主界面tag
local ID_PLAYER_MAGIC_CLOSE = 389;
local ID_MATRIX_LIST = 1313;
local ID_ATTACK_LIST = 47;
local ID_LIST_ITEM_6 =  210;
local ID_COOLDOWN = 344;

p.InfoTag1 = {
bg			= 100,
img			= 211,
name		= 217,
level		= 218,
des			= 220,
pLevel		= 96,
exp			= 98,
upgrade		= 99,

expLabel	= 219,
conditionLabel = 95,
pLevelLabel = 97,

}

p.InfoTag2 = {
bg			= 181,
img			= 183,
name		= 313,
level		= 315,
des			= 316,
pLevel		= 319,
exp			= 321,
upgrade		= 322,
expLabel	= 320,
conditionLabel = 317,
pLevelLabel = 318,
}

p.InfoTag3 = {
bg			= 182,
img			= 184,
name		= 314,
level		= 323,
des			= 324,
pLevel		= 327,
exp			= 329,
upgrade		= 330,
expLabel	= 328,
conditionLabel = 325,
pLevelLabel = 326,
};

p.SophTag = 865;
p.stateIconSize = 60;

p.TimeTag = {
 bt = 159,
 txt = 343,
 bt_acc = 344,
 txt_tip = 342,
}

p.mTimerTaskTag = nil;

-- 界面控件坐标定义
local winsize = GetWinSize();

local CONTAINTER_W = RectUILayer.size.w / 2;
local CONTAINTER_H = RectUILayer.size.h;
local CONTAINTER_X = 0;
local CONTAINTER_Y = 0;

local ATTR_OFFSET_X = RectUILayer.size.w / 2;
local ATTR_OFFSET_Y = 0;

p.mCurrentTab = p.TabTag.MATRIX;
p.mCurrentPage = 0;
p.mAttackList = nil;
p.mMatrixList = nil;
p.mConfirmIgnor = false;



function p.LoadUI()
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
	layer:SetTag(NMAINSCENECHILDTAG.PlayerMagic);
	layer:SetFrameRect(RectUILayer);
	layer:SetBackgroundColor(ccc4(125, 125, 125, 125));
	scene:AddChild(layer);
	
	--初始化ui
	local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end
	
	uiLoad:Load("MagicStr.ini", layer, p.OnUIEvent, CONTAINTER_X, CONTAINTER_Y);
	uiLoad:Free();
	
	local coolBt = GetButton(layer, ID_COOLDOWN);
	--if (coolBt) then
	--coolBt:SetLuaDelegate(p.OnUIEvent);
	--end
	
	p.initData();
	p.RefreshContainer();
	
	p.refreshTimeUI();
	p.setTimeUITask();
	
	
	return true;
end

function p.OnUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEvent[%d]", tag);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if ID_PLAYER_MAGIC_CLOSE == tag then
			p.freeData();
			CloseUI(NMAINSCENECHILDTAG.PlayerMagic);
		elseif(p.InfoTag1.upgrade == tag) or (p.InfoTag2.upgrade == tag) or (p.InfoTag3.upgrade == tag) then
			p.clickUpgrade(uiNode);
		elseif p.TimeTag.bt_acc == tag or p.TimeTag.bt == tag then
			p.clickCoolDown();
		elseif (p.TabTag.ATTACK == tag or p.TabTag.MATRIX == tag) then
			p.clickTab(tag);
		end
	elseif uiEventType == NUIEventType.TE_TOUCH_TABLE_FOCUS then
	end
	return true;
end

function p.OnUIEventScroll(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEventScroll[%d]", tag);
	return true;
end

function p.GetMatrixContainer()
	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end
	
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.PlayerMagic);
	if nil == layer then
		return nil;
	end
	
	local container = GetScrollViewContainer(layer, ID_MATRIX_LIST);
	return container;
end

function p.GetAttackContainer()
	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end
	
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.PlayerMagic);
	if nil == layer then
		return nil;
	end
	
	local container = GetScrollViewContainer(layer, ID_ATTACK_LIST);
	return container;
end

function p.RefreshContainer()

	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end
	
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.PlayerMagic);
	if nil == layer then
		return nil;
	end
	local sopV = GetLabel(layer, p.SophTag);
	if CheckP(sopV) then
		sopV:SetText(SafeN2S(p.getUserSoph()));
	end
	 
	if (p.mCurrentTab == p.TabTag.MATRIX) then
		local a = p.GetAttackContainer();
		local m = p.GetMatrixContainer();
		a:SetVisible(false);
		m:SetVisible(true);
		p.RefreshMatrixContainer();
	elseif (p.mCurrentTab == p.TabTag.ATTACK) then
		local a = p.GetAttackContainer();
		local m = p.GetMatrixContainer();
		m:SetVisible(false);
		a:SetVisible(true);
		p.RefreshAttackContainer();
	end
end

function p.RefreshMatrixContainer()
local scene = GetSMGameScene();	

	
	local container = p.GetMatrixContainer();
	if nil == container then
		LogInfo("nil == container");
		return;
	end
	container:RemoveAllView();
	local rectview = container:GetFrameRect();
	--container:SetViewSize(CGSizeMake(rectview.size.w / 3, rectview.size.h));
	container:SetViewSize(CGSizeMake(rectview.size.w, rectview.size.h));
	
	local lst, count = MsgMagic.getRoleMatrixList();
	if not lst then
		lst = {};
	end
	p.mMatrixList = lst;
	p.mCurrentPage = 1;
	
	
	if (count == nil or count < 1) then
		count = 1
	end
	local page = math.ceil(count/3);
	
	for i = 1,  page do
	
	local view = createUIScrollView();
	
	if view == nil then
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
	
	uiLoad:Load("MagicStr_M.ini", view, p.OnUIEvent, p.OFFSET_X, p.OFFSET_Y);
	
	p.refreshMatrixItem(lst[(i - 1) * 3 + 1], view, p.InfoTag1);
	p.refreshMatrixItem(lst[(i - 1) * 3 + 2], view, p.InfoTag2);
	p.refreshMatrixItem(lst[(i - 1) * 3 + 3], view, p.InfoTag3);
	
	uiLoad:Free();
 end -- end for
	
end

function p.RefreshAttackContainer()
	local scene = GetSMGameScene();	
	
	local container = p.GetAttackContainer();
	if nil == container then
		LogInfo("nil == container");
		return;
	end
	container:RemoveAllView();
	local rectview = container:GetFrameRect();
	--container:SetViewSize(CGSizeMake((rectview.size.w * 0.95) / 3, rectview.size.h));
	container:SetViewSize(CGSizeMake(rectview.size.w, rectview.size.h));
	
	local lst, count = MsgMagic.getRoleAttackList();
	if not lst then
		lst = {};
	end
	p.mAttackList = lst;
	p.mCurrentPage = 1;
	
	
	if (count == nil or count < 1) then
		count = 1
	end
	local page = math.ceil(count / 3)
	
	for i = 1,  page do
	
	local view = createUIScrollView();
	
	if view == nil then
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
	
	uiLoad:Load("MagicStr_M.ini", view, p.OnUIEvent, p.OFFSET_X, p.OFFSET_Y);
	
	p.refreshAttackItem(lst[(i - 1) * 3 + 1], view, p.InfoTag1);
	p.refreshAttackItem(lst[(i - 1) * 3 + 2], view, p.InfoTag2);
	p.refreshAttackItem(lst[(i - 1) * 3 + 3], view, p.InfoTag3);
	
	uiLoad:Free();
 end -- end for
	
end

function p.refreshMatrixItem(matrix, view, viewIds)
	local nameV		= GetLabel(view, viewIds.name);
	local desV		= GetLabel(view, viewIds.des);
	local levelV	= GetLabel(view, viewIds.level);
	local pLevelV	= GetLabel(view, viewIds.pLevel);
	local expV		= GetLabel(view, viewIds.exp);
	local upgradeV	= GetButton(view, viewIds.upgrade);
	local imgV		= GetImage(view, viewIds.img);
	
	
	if (matrix) then
		
		local nPlayerId = GetPlayerId();
		local nPetId = ConvertN(RolePetFunc.GetMainPetId(nPlayerId));
		local userLevel = ConvertN(RolePet.GetPetInfoN(nPetId, PET_ATTR.PET_ATTR_LEVEL))
		
		local id = matrix.id;
		local level = matrix.level;
		local type = matrix.type;
	
		local sName = MatrixConfigFunc.GetDataBaseS(type,DB_MATRIX_CONFIG.NAME);
		local sDes = MatrixConfigFunc.GetDataBaseS(type, DB_MATRIX_CONFIG.DESCRIPT);
		local sLevel = string.format(" %d级", MatrixConfigFunc.GetUpLevelN(level, DB_MATRIX_UP_LEVEL.LEVEL));
		local uLevel = MatrixConfigFunc.GetUpLevelN(level + 1, DB_MATRIX_UP_LEVEL.USER_LEVEL);
		local suLevel = string.format("%d级", uLevel);
		local nSopth = MatrixConfigFunc.GetUpLevelN(level + 1, DB_MATRIX_UP_LEVEL.REQ_SOPH);
		local sSopth = string.format("%d", nSopth);
		local uSop = p.getUserSoph();
	
		nameV:SetText(sName);
		desV:SetText(sDes);
		levelV:SetText(sLevel);
		pLevelV:SetText(suLevel);
		expV:SetText(sSopth);
		
		upgradeV:EnalbeGray(false);
		if (uSop < nSopth) then
			upgradeV:EnalbeGray(true);
			expV:SetFontColor(ccc4(255, 0, 0, 255));
		end
		if (userLevel < uLevel) then
			upgradeV:EnalbeGray(true);
			pLevelV:SetFontColor(ccc4(255, 0, 0, 255));
		end
		local pic = p.GetIconByType(type);
		imgV:SetPicture( pic , true);
	else
		nameV:SetVisible(false);
		desV:SetVisible(false);
		levelV:SetVisible(false);
		pLevelV:SetVisible(false);
		expV:SetVisible(false);
		upgradeV:SetVisible(false);
		local expLabelV = GetLabel(view, viewIds.expLabel);
		local conditionLabelV = GetLabel(view, viewIds.conditionLabel);
		local pLevelLabelV = GetLabel(view, viewIds.pLevelLabel);
		expLabelV:SetVisible(false);
		conditionLabelV:SetVisible(false);
		pLevelLabelV:SetVisible(false);
		upgradeV:SetVisible(false);
	end
end

function p.refreshAttackItem(item, view, viewIds)
	local nameV		= GetLabel(view, viewIds.name);
	local desV		= GetLabel(view, viewIds.des);
	local levelV	= GetLabel(view, viewIds.level);
	local pLevelV	= GetLabel(view, viewIds.pLevel);
	local expV		= GetLabel(view, viewIds.exp);
	local upgradeV	= GetButton(view, viewIds.upgrade);
	local imgV		= GetImage(view, viewIds.img);
	
	
	if (item) then
		local nPlayerId = GetPlayerId();
		--local userLevel = GetRoleBasicDataN(nPlayerId, USER_ATTR.USER_ATTR_LEVEL)
		local nPetId = ConvertN(RolePetFunc.GetMainPetId(nPlayerId));
		local userLevel = ConvertN(RolePet.GetPetInfoN(nPetId, PET_ATTR.PET_ATTR_LEVEL))
		LogInfo("nPetId%d, userLevel:%d", nPetId, userLevel);
		local id = item.id;
		local level = item.level + 1;
		local type = item.type;
	
		local sName = AttackConfigFunc.GetDataBaseS(type,DB_MARTIALTYPE.NAME);
		local sDes = AttackConfigFunc.GetDataBaseS(type, DB_MARTIALTYPE.DESCRIPT);
		local sLevel = string.format(" %d级",item.level);
		local suLevel = string.format("%d级", level);
		local nSopth = AttackConfigFunc.GetDataBaseN(level, DB_MARTIALTYPE.UP_SOPH);
		local sSopth = string.format("%d", nSopth);
		local uSop = p.getUserSoph();
	
		nameV:SetText(sName);
		desV:SetText(sDes);
		levelV:SetText(sLevel);
		pLevelV:SetText(suLevel);
		expV:SetText(sSopth);
		
		upgradeV:EnalbeGray(false);
		if (uSop < nSopth) then
			upgradeV:EnalbeGray(true);
			expV:SetFontColor(ccc4(255, 0, 0, 255));
		end
		if (userLevel < level) then
			upgradeV:EnalbeGray(true);
			pLevelV:SetFontColor(ccc4(255, 0, 0, 255));
		end
		local pic = p.GetAttackIconByType(type);
		imgV:SetPicture(pic, true);
	else
		nameV:SetVisible(false);
		desV:SetVisible(false);
		levelV:SetVisible(false);
		pLevelV:SetVisible(false);
		expV:SetVisible(false);
		upgradeV:SetVisible(false);
		local expLabelV = GetLabel(view, viewIds.expLabel);
		local conditionLabelV = GetLabel(view, viewIds.conditionLabel);
		local pLevelLabelV = GetLabel(view, viewIds.pLevelLabel);
		expLabelV:SetVisible(false);
		conditionLabelV:SetVisible(false);
		pLevelLabelV:SetVisible(false);
	end
end

function p.clickUpgrade(node) 
	local tag = node:GetTag();
	local index = 0;
	if (tag == p.InfoTag1.upgrade) then
		index = 1;
	elseif(tag == p.InfoTag2.upgrade) then
		index = 2;
	elseif(tag == p.InfoTag3.upgrade) then
		index = 3;
	end
	
	if (index <= 0) then
		return;
	end
	
	if p.TabTag.MATRIX == p.mCurrentTab and p.mMatrixList then
		local m = p.mMatrixList[(p.mCurrentPage - 1) * 3 + index];
		if (m) then
			ShowLoadBar();
			MsgMagic.sendMatrixUpgrade(m.id);
		end
	elseif p.TabTag.ATTACK == p.mCurrentTab and p.mAttackList then
		local m = p.mAttackList[(p.mCurrentPage - 1) * 3 + index];
		LogInfo("MagicUI attack upgrade id:%d", m.id);
		if (m) then
			ShowLoadBar();
			MsgMagic.sendAttackUpgrade(m.id);
		end
	end
end

function p.clickCoolDown()
	if (not p.mConfirmIgnor) then
		local cool = MsgMagic.getCoolTime();
		local curTime = GetCurrentTime();
		local time = cool - curTime;
		local money = MatrixConfigFunc.getEmoneyForCleanCoolDown(time);
		local tip = "消除冷却时间需消耗".. SafeN2S(money) .. "元宝，是否继续？";
		CommonDlg.ShowNoPrompt(tip, p.onConfirmCoolDown);
	else
		p.sendMatrixCoolDown();
	end
	
end

function p.onConfirmCoolDown(nId, event, parm)
	if event == CommonDlg.EventCheck then
		if (parm and parm == true) then
			p.mConfirmIgnor = true;
			LogInfo("isCheck...");
		end
	elseif event == CommonDlg.EventOK then
		p.sendMatrixCoolDown();
	end
end

function p.sendMatrixCoolDown()
	ShowLoadBar();
	MsgMagic.sendMatrixCoolDown();
end

function p.clickTab(tag)
	if tag == p.mCurrentTab then
		return;
	end
	
	p.mCurrentTab = tag;
	p.RefreshContainer();
end

function p.processNet(msgId, m)
	if (msgId == nil ) then
		LogInfo("magicui processNet msgId == nil" );
	end
	if msgId == NMSG_Type._MSG_MATRIX_ADD then
	elseif msgId == NMSG_Type._MSG_MATRIX_UPGRADED then
		p.RefreshContainer();
	elseif msgId == NMSG_Type._MSG_MATRIX_COOLDOWN or msgId == NMSG_Type._MSG_ATTACK_COOLDOWN then
		p.RefreshContainer();
		p.refreshTimeUI();
		p.setTimeUITask();
	elseif msgId == NMSG_Type._MSG_ATTACK_ADD then
	elseif msgId == NMSG_Type._MSG_ATTACK_UPGRADED then
		p.RefreshContainer()
	end
	
	CloseLoadBar();
end

function p.initData()
	p.mMatrixList = nil;
	p.mAttackList = nil;
	MsgMagic.mUIListener = p.processNet;
	if (p.mTimerTaskTag) then
		UnRegisterTimer(p.mTimerTaskTag);
		p.mTimerTaskTag = nil;
	end
end

function p.freeData()
	p.mMatrixList = nil;
	p.mAttackList = nil;
	MsgMagic.mUIListener = nil;
	if (p.mTimerTaskTag) then
		UnRegisterTimer(p.mTimerTaskTag);
		p.mTimerTaskTag = nil;
	end
end

function p.timerCallback(tag)
	if (tag and tag == p.mTimerTaskTag) then
		LogInfo("timerCallback");
		p.refreshTimeUI();
	end
end

function p.setTimeUITask()
	local cool = MsgMagic.getCoolTime();
	local curTime = GetCurrentTime();
	local time = cool - curTime;
	if (p.mTimerTaskTag) then
		UnRegisterTimer(p.mTimerTaskTag);
		p.mTimerTaskTag = nil;
	end
	if (time > 0) then
		p.mTimerTaskTag = RegisterTimer(p.timerCallback, 1);
	end
end

function p.refreshTimeUI()
	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end
	
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.PlayerMagic);
	if nil == layer then
		return nil;
	end
	
	local txtV = GetLabel(layer, p.TimeTag.txt);
	local bt = GetButton(layer, p.TimeTag.bt);
	local bt_acc = GetButton(layer, p.TimeTag.bt_acc);
	local txtTip = GetLabel(layer, p.TimeTag.txt_tip);
	local cool = MsgMagic.getCoolTime();
	local curTime = GetCurrentTime();
	local time =  cool - curTime;
	LogInfo("cool:%d,cur:%d,time:%d", cool, curTime,time);
	local isVisible = true;
	if (time < 1) then
		isVisible = false;
		p.setTimeUITask();
	end
	if (txtV and isVisible) then
		local s = p.formatTime(time);
		LogInfo(s);
		txtV:SetText(s);
	end
	
	if (txtV) then
		txtV:SetVisible(isVisible);
	end
	
	if (bt) then
		bt:SetVisible(isVisible);
	end
	
	if (bt_acc) then
		bt_acc:SetVisible(isVisible);
	end
	
	if (txtTip) then
		txtTip:SetVisible(isVisible);
	end
	
end

function p.getUserSoph()
	local nPlayerId = GetPlayerId();
	local s = GetRoleBasicDataN(nPlayerId, USER_ATTR.USER_ATTR_SOPH);
	return s;
end


--返回时间hh:mm:ss---
function p.formatTime(timeNum, format)
	if format == nil then
		format = "%02d:%02d:%02d"
	end
	return string.format(format, p.calculateTime(timeNum))
end

function p.calculateTime(timeNum)
	local nSec=timeNum
	local h=0
	local m=0
	local s=0
	h=math.floor(nSec/ 3600)
	m=math.floor((nSec%3600) /60)
	s=nSec%60

	return h,m,s
end

--根据type 获得状态图标
function p.GetIconByType(type)
   local index = MatrixConfigFunc.GetDataBaseN(type, DB_MATRIX_CONFIG.LOOKFACE);
   if (CheckN(index)) then
		return p.GetPicByIconIndex(index);
   end
   return nil;
end

--根据type 获得状态图标
function p.GetAttackIconByType(type)
   local index = AttackConfigFunc.GetDataBaseN(type, DB_MARTIALTYPE.LOOKFACE);
   if (CheckN(index)) then
		return p.GetPicByIconIndex(index);
   end
   return nil;
end

--根据iconindex获得图标
function p.GetPicByIconIndex(iconIndex)
  local pool = DefaultPicPool();
  if CheckP(pool) then
    local pic = pool:AddPicture(GetSMImgPath("mix/Queue_and_Arts.png"), false);
	if CheckP(pic) then
	  pic:Cut(CGRectMake(
						 (iconIndex % 100 - 1)*p.stateIconSize,
	                     (iconIndex / 100 - 1)*p.stateIconSize,
						
						 p.stateIconSize,p.stateIconSize));
	  return pic;
	end 
  end
  return nil;
end

