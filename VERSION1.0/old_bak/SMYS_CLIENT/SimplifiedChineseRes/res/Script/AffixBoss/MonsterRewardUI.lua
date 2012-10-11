---------------------------------------------------
--描述: 副本战斗奖励UI
--时间: 2012.3.30
--作者: cl

---------------------------------------------------
local _G = _G;

MonsterRewardUI = {};
local p = MonsterRewardUI;

p.rewardItemTypes={0,0,0};

local ID_DYNMAPSUCCESS_CTRL_BUTTON_WATCH	=28;
local ID_DYNMAPSUCCESS_CTRL_TEXT_ROLE5_EXP    = 27;
local ID_DYNMAPSUCCESS_CTRL_TEXT_ROLE5    = 26;
local ID_DYNMAPSUCCESS_CTRL_PICTURE_21     = 24;
local ID_DYNMAPSUCCESS_CTRL_PICTURE_SPOILS    = 25;
local ID_DYNMAPSUCCESS_CTRL_BUTTON_CONFIRM    = 23;

local ID_DYNMAPSUCCESS_CTRL_OBJECT_BUTTON_SPOILS3    = 22;
local ID_DYNMAPSUCCESS_CTRL_OBJECT_BUTTON_SPOILS2    = 21;
local ID_DYNMAPSUCCESS_CTRL_OBJECT_BUTTON_SPOILS1    = 20;

local ID_DYNMAPSUCCESS_CTRL_TEXT_SPOIL3_NUM	= 98;
local ID_DYNMAPSUCCESS_CTRL_TEXT_SPOIL2_NUM	= 97;
local ID_DYNMAPSUCCESS_CTRL_TEXT_SPOIL1_NUM	= 96;

local ID_DYNMAPSUCCESS_CTRL_PICTURE_18     = 18;
local ID_DYNMAPSUCCESS_CTRL_PICTURE_15     = 15;
local ID_DYNMAPSUCCESS_CTRL_TEXT_ROLE4_EXP    = 14;
local ID_DYNMAPSUCCESS_CTRL_TEXT_ROLE3_EXP    = 13;
local ID_DYNMAPSUCCESS_CTRL_TEXT_ROLE2_EXP    = 12;
local ID_DYNMAPSUCCESS_CTRL_TEXT_ROLE1_EXP    = 11;
local ID_DYNMAPSUCCESS_CTRL_TEXT_ROLE4     = 10;
local ID_DYNMAPSUCCESS_CTRL_TEXT_ROLE3     = 9;
local ID_DYNMAPSUCCESS_CTRL_TEXT_ROLE2     = 8;
local ID_DYNMAPSUCCESS_CTRL_TEXT_ROLE1     = 7;
local ID_DYNMAPSUCCESS_CTRL_PICTURE_WIN_BACKGROUND2  = 4;
local ID_DYNMAPSUCCESS_CTRL_PICTURE_WIN_BACKGROUND  = 1;

local ID_DYNMAPSUCCESS_CTRL_TEXT_ITEM_NAME1	=	29;
local ID_DYNMAPSUCCESS_CTRL_TEXT_ITEM_NAME2	=	30;
local ID_DYNMAPSUCCESS_CTRL_TEXT_ITEM_NAME3	=	31;

local TAG_ITEM_INFO_CONTAINER = 9997;			--物品信息与操作
local TAG_ITEM_INFO = 9998;						--物品信息与操作

function p.GetParent()
	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end
	
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.MonsterReward);
	if nil == layer then
		return nil;
	end
	
	--local container = GetScrollViewContainer(layer, TAG_CONTAINER);
	return layer;
end

function p.OnUIEvent(uiNode,uiEventType,param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEvent[%d]",tag);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if ID_DYNMAPSUCCESS_CTRL_BUTTON_CONFIRM == tag then
			local scene = GetSMGameScene();
			CloseBattle();
			if scene~= nil then
				scene:RemoveChildByTag(NMAINSCENECHILDTAG.MonsterReward,true);
				return true;
			end
			
		elseif ID_DYNMAPSUCCESS_CTRL_BUTTON_WATCH == tag then
			restartLastBattle();
			
			local scene = GetSMGameScene();
			if scene~= nil then
				scene:RemoveChildByTag(NMAINSCENECHILDTAG.MonsterReward,true);
				return true;
			end
		elseif ID_DYNMAPSUCCESS_CTRL_OBJECT_BUTTON_SPOILS1==tag then
			if p.rewardItemTypes[1] ~= 0 then 
				p.ShowItemInfo(p.rewardItemTypes[1]);
			else
				p.CloseItemInfo();
			end
		elseif ID_DYNMAPSUCCESS_CTRL_OBJECT_BUTTON_SPOILS2==tag then
			if p.rewardItemTypes[2] ~= 0 then 
				p.ShowItemInfo(p.rewardItemTypes[2]);
			else
				p.CloseItemInfo();
			end
		elseif ID_DYNMAPSUCCESS_CTRL_OBJECT_BUTTON_SPOILS3==tag then
			if p.rewardItemTypes[3] ~= 0 then 
				p.ShowItemInfo(p.rewardItemTypes[3]);
			else
				p.CloseItemInfo();
			end
		end
	end
end

function p.SetRewardExp(exp)
	local nPlayerId = GetPlayerId();
	if nil == nPlayerId then
		LogInfo("nil == nPlayerId");
		return;
	end
	
	local layer = p.GetParent();
	if nil == layer then
		return nil;
	end
	
	local name=GetRoleBasicDataS(nPlayerId, USER_ATTR.USER_ATTR_NAME);
	LogInfo("award "..name);
	SetLabel(layer,ID_DYNMAPSUCCESS_CTRL_TEXT_ROLE1,name);
	SetLabel(layer,ID_DYNMAPSUCCESS_CTRL_TEXT_ROLE1_EXP,"经验+"..SafeN2S(exp));
	
	local teamList = MatrixConfigFunc.GetCurrentMatrix();
	if nil == teamList then
		LogInfo("Matrix nil");
		return nil;
	end
	local n=2;
	for i=1, 9 do
		local id=teamList[i];
		if id~=0 then
			local ismain=RolePet.GetPetInfoN(id,PET_ATTR.PET_ATTR_MAIN);
			if ismain==1 then
				continue;
			end
			local name= RolePet.GetPetInfoS(id,PET_ATTR.PET_ATTR_NAME);
			if n==2 then
				SetLabel(layer,ID_DYNMAPSUCCESS_CTRL_TEXT_ROLE2,name);
				SetLabel(layer,ID_DYNMAPSUCCESS_CTRL_TEXT_ROLE2_EXP,"经验+"..SafeN2S(exp));
			elseif n==3 then
				SetLabel(layer,ID_DYNMAPSUCCESS_CTRL_TEXT_ROLE3,name);
				SetLabel(layer,ID_DYNMAPSUCCESS_CTRL_TEXT_ROLE3_EXP,"经验+"..SafeN2S(exp));
			elseif n==4 then
				SetLabel(layer,ID_DYNMAPSUCCESS_CTRL_TEXT_ROLE4,name);
				SetLabel(layer,ID_DYNMAPSUCCESS_CTRL_TEXT_ROLE4_EXP,"经验+"..SafeN2S(exp));
			elseif n==5 then
				SetLabel(layer,ID_DYNMAPSUCCESS_CTRL_TEXT_ROLE5,name);
				SetLabel(layer,ID_DYNMAPSUCCESS_CTRL_TEXT_ROLE5_EXP,"经验+"..SafeN2S(exp));
			end
			n=n+1;
		end
	end
end

function p.addRewardItem(index,itemType,amount)
	local layer = p.GetParent();
	
	if nil==layer then
		return;
	end
	
	if index == 1 then
		p.rewardItemTypes[1]=itemType;
		SetLabel(layer,ID_DYNMAPSUCCESS_CTRL_TEXT_SPOIL1_NUM,SafeN2S(amount));
		local button1 = GetItemButton(layer,ID_DYNMAPSUCCESS_CTRL_OBJECT_BUTTON_SPOILS1);
		button1:ChangeItemType(itemType);
		SetLabel(layer,ID_DYNMAPSUCCESS_CTRL_TEXT_ITEM_NAME1,ItemFunc.GetName(itemType))
	elseif index == 2 then
		p.rewardItemTypes[2]=itemType;
		SetLabel(layer,ID_DYNMAPSUCCESS_CTRL_TEXT_SPOIL2_NUM,SafeN2S(amount));
		local button2 = GetItemButton(layer,ID_DYNMAPSUCCESS_CTRL_OBJECT_BUTTON_SPOILS2);
		button2:ChangeItemType(itemType);
		SetLabel(layer,ID_DYNMAPSUCCESS_CTRL_TEXT_ITEM_NAME2,ItemFunc.GetName(itemType))
	elseif index ==3 then
		p.rewardItemTypes[3]=itemType;
		SetLabel(layer,ID_DYNMAPSUCCESS_CTRL_TEXT_SPOIL3_NUM,SafeN2S(amount));
		local button3 = GetItemButton(layer,ID_DYNMAPSUCCESS_CTRL_OBJECT_BUTTON_SPOILS3);
		button3:ChangeItemType(itemType);
		SetLabel(layer,ID_DYNMAPSUCCESS_CTRL_TEXT_ITEM_NAME3,ItemFunc.GetName(itemType))
	end
end

function p.CloseItemInfo()
	local layer=p.GetParent();
	if layer == nil then
		return;
	end
	local scrollContainer	= RecursiveScrollContainer(layer, {TAG_ITEM_INFO_CONTAINER});
	if not CheckP(scrollContainer) then
		LogInfo("not CheckP(scrollContainer)");
		return;
	end
	local scroll			= RecursiveScroll(scrollContainer, {TAG_ITEM_INFO});
	if not CheckP(scroll) then
		LogInfo("not CheckP(scroll)");
		return;
	end
	scroll:RemoveAllChildren(true);
	scrollContainer:SetFrameRect(RectZero());
	scroll:SetFrameRect(RectZero());
end

function p.ShowItemInfo(itemType)
	local layer=p.GetParent();
	local scrollContainer	= RecursiveScrollContainer(layer, {TAG_ITEM_INFO_CONTAINER});
	if not CheckP(scrollContainer) then
		LogInfo("not CheckP(scrollContainer)");
		return;
	end
	local scroll			= RecursiveScroll(scrollContainer, {TAG_ITEM_INFO});
	if not CheckP(scroll) then
		LogInfo("not CheckP(scroll)");
		return;
	end
	
	scroll:RemoveAllChildren(true);
	LogInfo("scroll:RemoveAllChildren();");
	local nWidthLimit		= RectUILayer.size.w / 3;
	local nBGStartX			= RectUILayer.size.w / 6;
	local nBGStartY			= 0;
	local nHeightLimit		= RectUILayer.size.h;
	local nHeight			= ItemUI.AttachItemInfoByItemType(scroll, itemType,nWidthLimit);
	if nHeight <= 0 then
		scrollContainer:SetFrameRect(RectZero());
		scroll:SetFrameRect(RectZero());
		return;
	end
	
	scroll:SetFrameRect(CGRectMake(0, 0, nWidthLimit, nHeight));
	if nHeight < nHeightLimit then
		nBGStartY		= (nHeightLimit - nHeight) / 2;
		nHeightLimit	= nHeight;
	end
	scrollContainer:SetFrameRect(CGRectMake(nBGStartX, nBGStartY, nWidthLimit, nHeightLimit));
	scrollContainer:SetTopReserveDistance(nHeightLimit);
	scrollContainer:SetBottomReserveDistance(nHeightLimit);
	
	local pool = DefaultPicPool();
	if not CheckP(pool) then
		return;
	end 
	local pic		= pool:AddPictureEx(GetSMImgPath("bg/bg_ver_black.png"), nWidthLimit, nHeightLimit, false); 
	if not CheckP(pic) then
		return;
	end
	scrollContainer:SetBackgroundImage(pic);
end

function p.LoadUI()
	local scene=GetSMGameScene();
	if scene == nil then
		LogInfo("scene = nil,load ArenaRankUI failed!");
		return;
	end
	local layer = createNDUILayer();
	if layer == nil then
		LogInfo("scene = nil,2");
		return  false;
	end
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.MonsterReward);
	local winsize = GetWinSize();
	layer:SetFrameRect( CGRectMake(winsize.w /4, winsize.h *0.1, winsize.w /2, winsize.h * 0.8));
	--layer:SetBackgroundColor(ccc4(125,125,125,125));
	scene:AddChild(layer);
	
	local uiLoad=createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		LogInfo("scene = nil,4");
		return false;
	end
	uiLoad:Load("DynMapSuccess.ini",layer,p.OnUIEvent,0,0);
	uiLoad:Free();
	
	
	--物品信息层初始化
	local containerItem = createUIScrollContainer();
	if containerItem == nil then
		return;
	end
	containerItem:Init();
	containerItem:SetTag(TAG_ITEM_INFO_CONTAINER);
	containerItem:SetFrameRect(RectZero());
	layer:AddChildZ(containerItem, 1);
	
	local scroll = createUIScroll();
	if (scroll == nil) then
		containerItem:RemoveFromParent(true);
		return;
	end
	scroll:Init(false);
	scroll:SetFrameRect(RectZero());
	scroll:SetScrollStyle(UIScrollStyle.Verical);
	scroll:SetTag(TAG_ITEM_INFO);
	scroll:SetMovableViewer(containerItem);
	scroll:SetContainer(containerItem);
	containerItem:AddChild(scroll);
	
end