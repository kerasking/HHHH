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

local ID_DYNMAPSUCCESS_CTRL_TEXT_MONEY    = 29;
local ID_DYNMAPSUCCESS_CTRL_TEXT_SOPH       = 30;

local ID_DYNMAPSUCCESS_CTRL_PICTURE_21     = 24;
local ID_DYNMAPSUCCESS_CTRL_PICTURE_SPOILS    = 25;
local ID_DYNMAPSUCCESS_CTRL_BUTTON_CONFIRM    = 23;
local ID_DYNMAPSUCCESS_CTRL_ANGIN_BATTLE    =37;
local ID_DYNMAPSUCCESS_CTRL_NEXT_BATTLE     =35;

local ID_DYNMAPSUCCESS_CTRL_OBJECT_BUTTON_SPOILS3    = 22;
local ID_DYNMAPSUCCESS_CTRL_OBJECT_BUTTON_SPOILS2    = 21;
local ID_DYNMAPSUCCESS_CTRL_OBJECT_BUTTON_SPOILS1    = 20;

local ID_DYNMAPSUCCESS_CTRL_TEXT_SPOIL3_NUM	= 98;
local ID_DYNMAPSUCCESS_CTRL_TEXT_SPOIL2_NUM	= 97;
local ID_DYNMAPSUCCESS_CTRL_TEXT_SPOIL1_NUM	= 96;

local ID_DYNMAPSUCCESS_CTRL_PICTURE_18     = 18;
local ID_DYNMAPSUCCESS_CTRL_PICTURE_15     = 15;

local ID_DYNMAPSUCCESS_CTRL_TEXT_ROLE4     = 10;
local ID_DYNMAPSUCCESS_CTRL_TEXT_ROLE3     = 9;
local ID_DYNMAPSUCCESS_CTRL_TEXT_ROLE2     = 8;
local ID_DYNMAPSUCCESS_CTRL_TEXT_ROLE1     = 7;
local ID_DYNMAPSUCCESS_CTRL_PICTURE_WIN_BACKGROUND2  = 4;
local ID_DYNMAPSUCCESS_CTRL_PICTURE_WIN_BACKGROUND  = 1;
local exp = nil;
local ID_DYNMAPSUCCESS_CTRL_TEXT_ITEM_NAME1	=	100;
local ID_DYNMAPSUCCESS_CTRL_TEXT_ITEM_NAME2	=	101;
local ID_DYNMAPSUCCESS_CTRL_TEXT_ITEM_NAME3	=	102;

local TAG_ITEM_INFO_CONTAINER = 9997;			--物品信息与操作
local TAG_ITEM_INFO = 9998;						--物品信息与操作


local ID_DYNMAPSUCCESS_CTRL_TEXT_ROLE4_EXP    = 14;
local ID_DYNMAPSUCCESS_CTRL_TEXT_ROLE3_EXP    = 13;
local ID_DYNMAPSUCCESS_CTRL_TEXT_ROLE2_EXP    = 12;
local ID_DYNMAPSUCCESS_CTRL_TEXT_ROLE1_EXP    = 11;
local TAG_PET_HEAD = {64,65,66,67,68,};         --人物头像
local TAG_PET_EXP = {11,12,13,14,27,};         --人物经验


local PetShowList = {};         --要显示的部将列表

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
            Music.StopMusic();
            CloseBattle();
            BattleUI_Title.CloseUI();--
			local scene = GetSMGameScene();
			if scene ~= nil then
				scene:RemoveChildByTag(NMAINSCENECHILDTAG.MonsterReward,true);
			end
            
            --发送退出副本消息
            MsgAffixBoss.sendNmlLeave();
            
            if( NormalBossListUI and NormalBossListUI.nCampaignID ) then
                WorldMap(NormalBossListUI.nCampaignID);  
                NormalBossListUI.Redisplay();
            else
                NormalBossListUI.OnBtnBack();
            end
            
			return true;
		elseif ID_DYNMAPSUCCESS_CTRL_ANGIN_BATTLE == tag then
            CloseBattle();
            BattleUI_Title.CloseUI();--
			local scene = GetSMGameScene();
            if scene ~= nil then
                scene:RemoveChildByTag(NMAINSCENECHILDTAG.MonsterReward,true);
            end	
			MsgAffixBoss.sendNmlLeave();
            
			MsgAffixBoss.sendNmlEnter(NormalBossListUI.nChosenBattleID);
            MsgLogin.EnterInstanceBattle();
			return true;
		elseif ID_DYNMAPSUCCESS_CTRL_NEXT_BATTLE == tag then
            Music.StopMusic();
            CloseBattle();
            local scene = GetSMGameScene();
			if scene ~= nil then
				scene:RemoveChildByTag(NMAINSCENECHILDTAG.MonsterReward,true);
			end
			MsgAffixBoss.sendNmlLeave();
            -- 改回城++Guosen 2012.7.20	
            NormalBossListUI.OnBtnBack();
		elseif ID_DYNMAPSUCCESS_CTRL_BUTTON_WATCH == tag then
			restartLastBattle();
			
			local scene = GetSMGameScene();
			if scene~= nil then
				scene:RemoveChildByTag(NMAINSCENECHILDTAG.MonsterReward,true);
				return true;
			end
           --[[ 
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
        ]]
		end
	end
	return true;
end

function p.SetRewardExp(npetId, exp)
	local nPlayerId = GetPlayerId();
	if nil == nPlayerId then
		LogInfo("nil == nPlayerId");
		return;
	end
	
	local layer = p.GetParent();
	if nil == layer then
		return nil;
	end
    
    local record = {};
    record.nPetId = npetId;
    record.nExp   = exp;
    LogInfo("p.SetRewardExp petid = %d, exp = %d", npetId, exp);
    table.insert(PetShowList, record);
end

--显示人物头像以及经验值
function p.Refresh()
	local layer = p.GetParent();
    LogInfo("function p.Refresh() begin");
    if PetShowList ~= nil then
        table.sort(PetShowList, function(a,b) return a.nExp  > b.nExp  end);
    end
    
    local nIndex = 2;
    for i, v in pairs(PetShowList) do
        local isMain = RolePet.GetPetInfoN(v.nPetId, PET_ATTR.PET_ATTR_MAIN);
        if isMain == 1 then
            --排第一个
            SetLabel(layer, TAG_PET_EXP[1],GetTxtPub("exp").."+"..SafeN2S(v.nExp));
            local btn = GetButton(layer, TAG_PET_HEAD[1]);
             btn:SetImage(p.getPetPicture(v.nPetId));
        else
            SetLabel(layer, TAG_PET_EXP[nIndex], GetTxtPub("exp").."+"..SafeN2S(v.nExp));
            local btn = GetButton(layer, TAG_PET_HEAD[nIndex]);
            btn:SetImage(p.getPetPicture(v.nPetId));
            nIndex = nIndex + 1;
        end
        LogInfo("isMain = %d, i = %d, petid = %d, exp = %d", isMain, i,  v.nPetId, v.nExp);
    end
    
    for i=1,#TAG_PET_HEAD do
        local btn = GetButton(layer, TAG_PET_HEAD[i]);
        if(i>#PetShowList) then
            btn:SetVisible(false);
        end
    end
end













function p.addSophMoney(iSoph, iMoney)
	local layer = p.GetParent();
	
	if nil==layer then
		return;
	end
    SetLabel(layer, ID_DYNMAPSUCCESS_CTRL_TEXT_MONEY, _G.GetTxtPub("coin")..": "..SafeN2S(iMoney));
    
    if iSoph ~= 0 then
        SetLabel(layer, ID_DYNMAPSUCCESS_CTRL_TEXT_SOPH,_G.GetTxtPub("JianHun")..": "..SafeN2S(iSoph));  
    end
end



function p.addRewardItem(index,itemType,amount)
	local layer = p.GetParent();
	
	if nil==layer then
		return;
	end
	
	if index == 1 then
		p.rewardItemTypes[1]=itemType;
		SetLabel(layer,ID_DYNMAPSUCCESS_CTRL_TEXT_SPOIL1_NUM,"x"..SafeN2S(amount));
		local button1 = GetItemButton(layer,ID_DYNMAPSUCCESS_CTRL_OBJECT_BUTTON_SPOILS1);
		button1:ChangeItemType(itemType);
		local l_name = SetLabel(layer,ID_DYNMAPSUCCESS_CTRL_TEXT_ITEM_NAME1,ItemFunc.GetName(itemType))
        button1:SetVisible(true);
        
        --设置装备颜色
        ItemFunc.SetLabelColor(l_name,itemType);
	elseif index == 2 then
		p.rewardItemTypes[2]=itemType;
		SetLabel(layer,ID_DYNMAPSUCCESS_CTRL_TEXT_SPOIL2_NUM,"x"..SafeN2S(amount));
		local button2 = GetItemButton(layer,ID_DYNMAPSUCCESS_CTRL_OBJECT_BUTTON_SPOILS2);
		button2:ChangeItemType(itemType);
		local l_name = SetLabel(layer,ID_DYNMAPSUCCESS_CTRL_TEXT_ITEM_NAME2,ItemFunc.GetName(itemType))
        button2:SetVisible(true);
        
        --设置装备颜色
        ItemFunc.SetLabelColor(l_name,itemType);
	elseif index ==3 then
		p.rewardItemTypes[3]=itemType;
		SetLabel(layer,ID_DYNMAPSUCCESS_CTRL_TEXT_SPOIL3_NUM,"x"..SafeN2S(amount));
		local button3 = GetItemButton(layer,ID_DYNMAPSUCCESS_CTRL_OBJECT_BUTTON_SPOILS3);
		button3:ChangeItemType(itemType);
		local l_name = SetLabel(layer,ID_DYNMAPSUCCESS_CTRL_TEXT_ITEM_NAME3,ItemFunc.GetName(itemType))
        button3:SetVisible(true);
        
        --设置装备颜色
        ItemFunc.SetLabelColor(l_name,itemType);
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

function p.LoadUI(money,repute)
    MsgLogin.LeaveInstanceBattle();
    exp = repute;
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
	layer:SetFrameRect(RectFullScreenUILayer);
	--layer:SetBackgroundColor(ccc4(125,125,125,125));
	scene:AddChildZ(layer,2);
	
	local uiLoad=createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		LogInfo("scene = nil,4");
		return false;
	end
	uiLoad:Load("DynMapSuccess.ini",layer,p.OnUIEvent,0,0);
	uiLoad:Free();
           
    --经验副本不能再次挑战
    local nEnergy = PlayerFunc.GetStamina(GetPlayerId());
    
    if NormalBossListUI.nChosenBattleID == nil or (NormalBossListUI.GetIsBattleType() == 1) or (nEnergy == 0) then
        local button37 = GetButton(layer, ID_DYNMAPSUCCESS_CTRL_ANGIN_BATTLE);
        button37:SetVisible(false);  
    end     
	
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
	
    --设置武将头像
    PetShowList = {};   --要显示的部将列表清空
    --p.SetPetHead();
    
    
    
    local layer = p.GetParent();
    local button1 = GetItemButton(layer,ID_DYNMAPSUCCESS_CTRL_OBJECT_BUTTON_SPOILS1);
    local button2 = GetItemButton(layer,ID_DYNMAPSUCCESS_CTRL_OBJECT_BUTTON_SPOILS2);
    local button3 = GetItemButton(layer,ID_DYNMAPSUCCESS_CTRL_OBJECT_BUTTON_SPOILS3);
    button1:SetVisible(false);
    button2:SetVisible(false);
    button3:SetVisible(false);
    
    --胜利音效
    Music.PlayEffectSound(1094);
    
    -- 可升级则播放升级动画及音像--Guosen 2012.8.6
    MsgRolePet.ShowLevelUpAnimation();
end

--设置用户头像
function p.SetPetHead()
    local lst, count    = MsgMagic.getRoleMatrixList();
    
    LogInfo("function p.SetPetHead() count = %d", count);
    
	local currentMatrix    = lst[1];
    if (currentMatrix == nil) then
		currentMatrix = {0,0,0,0,0,0,0,0};
	end
    
    local PetList = {};
    --查找出战人数
    for i=1,#currentMatrix do
        if(currentMatrix[i]~=0) then
            LogInfo("function p.SetPetHead() currentMatrix[i = %d] = %d", i, currentMatrix[i]);
            table.insert(PetList,currentMatrix[i]);
        end
    end
    
    local Num = table.getn( PetList );
    LogInfo("Num= %d", Num);
                
    for i=1,#PetList do
        for j=i,#PetList do
            local PetIExp = RolePet.GetPetInfoN(PetList[i],PET_ATTR.PET_ATTR_EXP);
            local PetJExp = RolePet.GetPetInfoN(PetList[i],PET_ATTR.PET_ATTR_EXP);
            LogInfo("PetIExp= %d, PetJExp = %d", PetIExp, PetJExp);
            if(PetIExp<PetJExp) then
                PetList[i] = PetList[j];
            end
        end
    end
    
    --显示武将头像
    for i=1,#TAG_PET_HEAD do
        local btn = GetButton(p.GetParent(),TAG_PET_HEAD[i]);
        if(i>#PetList) then
            btn:SetVisible(false);
        else
            btn:SetImage(p.getPetPicture(PetList[i]));
        end
        
    end
    
end

function p.getPetPicture(nId)
	if not CheckN(nId) then
		return nil;
	end
	
	local nPetType = RolePet.GetPetInfoN(nId,PET_ATTR.PET_ATTR_TYPE);
    --**chh 2012-06-08
    if(nPetType == 0) then
        return nil;
    end
    local rtn = GetPetPotraitPic(nPetType);
	return rtn;
end

