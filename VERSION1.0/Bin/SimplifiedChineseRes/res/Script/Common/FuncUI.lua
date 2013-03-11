function GetScene(nSceneTag)
	local director = DefaultDirector();
	if nil == director then
		return nil;
	end
	
	local scene = director:GetSceneByTag(nSceneTag);
	return scene;
end

--主界面某个UI是否处于显示状态
function IsUIShow(tagUI)
	if not GetUI(tagUI) then
		return false;	
	end
	return true;
end

function SetUIVisible(visible)
	LogInfo("ui visible=%d ",visible);
	if visible==0 then --隐藏所有UI
		if not CheckT(NMAINSCENECHILDTAG) then
			LogInfo("CloseMainUI not CheckT(NMAINSCENECHILDTAG)");
			return;
		end
		for i, v in pairs(NMAINSCENECHILDTAG) do 

			--聊天按钮
			if i ~= "BottomMsgBtn" and
			   i ~= "ChatMainBar" and
               i ~= "ChatMainUI" then
               
				local ui = GetUI(v)
				if ui then
					if ( v ~= NMAINSCENECHILDTAG.BattleUI_Title ) then--Guosen 2012.11.5--回放时不隐藏该UI
						ui:SetVisible(false);
					end
				else
					LogInfo("SetUIVisible can not find ui:[%d]",v);
				end
			end 
		end
	elseif visible == 1 then --显示所有UI
		if not CheckT(NMAINSCENECHILDTAG) then
			LogInfo("CloseMainUI not CheckT(NMAINSCENECHILDTAG)");
			return;
		end
		for i, v in pairs(NMAINSCENECHILDTAG) do
            if i ~= "ChatGameScene" then
                local ui = GetUI(v)
                if ui then
                    ui:SetVisible(true);
                else
                    LogInfo("SetUIVisible can not find ui");
                end
            end    
		end
	end
end

function hideDynMapUI()
	for i, v in pairs(NMAINSCENECHILDTAG) do
		if i =="DynMapToolBar" then
			local ui = GetUI(v)
			if ui then
				ui:SetVisible(false);
			else
				LogInfo("hideDynMapUI can not find ui");
			end
		end
	end
end

function showCityMapUI()
	for i, v in pairs(NMAINSCENECHILDTAG) do
		if i =="DynMapToolBar" then
			local ui = GetUI(v)
			if ui then
				ui:SetVisible(false);
			else
				LogInfo("showCityMapUI can not find ui1");
			end
		elseif i=="TopSpeedBar"
			or i=="WorldMapBtn"
			or i=="TopActivitySpeedBar" then
			local ui = GetUI(v)
			if ui then
				ui:SetVisible(true);
			else
				LogInfo("showCityMapUI can not find ui2");
			end
		end
	end
end

function showBossMapUI()
	for i, v in pairs(NMAINSCENECHILDTAG) do
		if i=="TopSpeedBar"
			or i=="WorldMapBtn"
			or i =="DynMapToolBar"
			or i=="TopActivitySpeedBar" then
			local ui = GetUI(v)
			if ui then
				ui:SetVisible(false);
			else
				LogInfo("showBossMapUI can not find ui");
			end
		end
	end
end

function showDynMapUI()
	for i, v in pairs(NMAINSCENECHILDTAG) do
		if i =="DynMapToolBar" then
			local ui = GetUI(v)
			if ui then
				ui:SetVisible(true);
			else
				LogInfo("showDynMapUI can not find ui1");
			end
		elseif i=="TopSpeedBar"
			or i=="WorldMapBtn"
			or i=="TopActivitySpeedBar" then
			local ui = GetUI(v)
			if ui then
				ui:SetVisible(false);
			else
				LogInfo("showDynMapUI can not find ui2");
			end
		end
	end
end

--bTrack =0 则不是寻路状态
function showBattleMapUI(mapid, bTrack) 

   local  bTracking = TaskUI.GetTrackingBossId(); --是否为寻路状态  0为非寻路  1为寻路
   local nBattleID		= TaskUI.GetMainBossId();   --获得当前任务副本ID，已完成的话为空
    LogInfo("nBattleID:"..nBattleID);
  
   
   --当前任务为空直接为非寻路
   if ( nBattleID == nil or nBattleID == 0 ) then
     NormalBossListUI.LoadUI(mapid, 0);  
     return;
   end
   
   --获取副本战斗信息获取不到直接为非寻路
   local tBattleInfo	= AffixBossFunc.getBossInfo( nBattleID );       
    if ( tBattleInfo == nil ) then
         NormalBossListUI.LoadUI(mapid,  0);  
         return;
    end
   
    --获取副本信息所属的地图id,如果与传入的不同直接为非寻路
    local nCampaignID	= AffixBossFunc.findMapId( tBattleInfo.elite, tBattleInfo.typeid );
    if ( nCampaignID == nil ) or (nCampaignID ~= mapid) then
        NormalBossListUI.LoadUI(mapid,  0);  
        return;
    end  
   
   --非寻路处理
   if 0 == bTracking then
        LogInfo("can not find ui");
        NormalBossListUI.LoadUI(mapid,  0);  
        return;
   else
        LogInfo("can not find ui nBattleID = %d, task = %d", nBattleID, TaskUI.GetTrackType());
        NormalBossListUI.LoadUIWithBattleID( nBattleID, TaskUI.GetTrackType() );
        TaskUI.ResetTrackingBossId()
   end 
end

function closeworldbutton()
    BackCity();  
end

--删除node，bSoundEffect是否播放音效
function RemoveChildByTagNew(nUITag, bCleanUp,bSoundEffect)
	local scene = GetSMGameScene();
	
	if scene ~= nil then
		scene:RemoveChildByTag(nUITag, bCleanUp);
		if bSoundEffect ~= nil then
			if true == bSoundEffect then
				--Music.PlayEffectSound(0)
			end
		end
	end	
end

function CloseMainUI()
    LogInfo("CloseMainUI");
	local bRet	= false;
	if not CheckT(NMAINSCENECHILDTAG) then
		LogInfo("CloseMainUI not CheckT(NMAINSCENECHILDTAG)");
		return bRet;
	end
	
	--关闭通用对话框
	if CommonDlg.CloseOneDlg() then
		bRet	= true;
		return bRet;
	end
	
	for i, v in pairs(NMAINSCENECHILDTAG) do
		if i ~= "BottomSpeedBar" 
			and i ~= "WorldMapBtn" 
			and i ~= "bossUI" 
			and i ~= "bossRankUI" 
			and i ~= "UserStateList" 
			and i ~= "DynMapToolBar"
			and i ~= "CommonDlg" 
			and i ~= "EmailList"
			and i ~= "MilOrdersDisPTxt"
			and i ~= "MainUITop" 
            and i ~= "BottomMsgBtn"
            and i ~= "MilOrdersBtn" 
            and i ~= "BottomControlBtn" 
            and i ~= "BottomFind"
            and i ~= "BottomMsg"
            and i ~= "DynMapGuide" --++Guosen 2012.7.4
            and i ~= "AffixNormalBoss" --++Guosen 2012.7.6
            and i ~= "Arena" --++Guosen 2012.7.6
            and i ~= "ChatGameScene"
            and i ~= "GMProblemBtn"
            and i ~= "TestDelPlayer" 
            and i ~= "OLGiftBtn" 
            and i ~= "RechargeGiftBtn" 
            and i ~= "MonsterReward"
            and i ~= "BattleFail" 
            and i ~= "ArenaFightReplayUI" 
            and i ~= "RaidersLoad" 
            and i ~= "ArenaRewardUI" 
            and i ~= "BattleUI_Title" 
            and v ~= 2015    
            then
            
            
			if CloseUI(v) then
				bRet	= true;
			end
		end
	end
	
	if CloseDlg() then
	--npc对话
		bRet	= true;
	end
	
	return bRet;
end

function GetWorldMapUITag()
	if not CheckT(NMAINSCENECHILDTAG) then
		return 0;
	end
	
	if not CheckN(NMAINSCENECHILDTAG.WorldMap) then
		return 0;
	end
	
	return NMAINSCENECHILDTAG.WorldMap;
end

--延迟关闭
function lazyClose(tagUI,bPlaySE)
	local ui = GetUI(tagUI)
	if not ui then
		return false;	
	end
	
	if bPlaySE == nil or bPlaySE == true then
    	--Music.PlayEffectSound(0);
    end
    
	ui:lazyClose();
	
	return true;
end

--关闭主界面某个UI  默认播放音效
function CloseUI(tagUI,bPlaySE)
	local ui = GetUI(tagUI)
	if not ui then
		return false;	
	end
	
	if bPlaySE == nil or bPlaySE == true then
    	--Music.PlayEffectSound(0);
    end
    
	ui:RemoveFromParent(true);
	
	return true;
end

--获取主界面某个UI
function GetUI(tagUI)
	local scene = GetSMGameScene();	
	if scene == nil then
		return nil;
	end 
	if not CheckN(tagUI) then
		return nil;
	end
	local layer = GetUiLayer(scene, tagUI);
    --if(layer == nil) then
        --layer = GetUiNode(scene, tagUI);
    --end
    --if(layer == nil) then
        --layer = GetLabel(scene, tagUI);
    --end
    --if(layer == nil) then
        --layer = GetButton(scene, tagUI);
    --end
    --LogInfo("layerTag:[%d]",tagUI);

	return layer;
end


-- 设置游戏数据到标签上
-- pParent: 标签的父节点
-- nTag: 标签的tag
-- nScriptData: NScriptData枚举
-- nRoleData: NRoleData枚举
-- nRoleId: 角色ID(人或怪物或NPC..),对应于NScriptData枚举
-- nId:	数据ID(宠物或技能或物品...),对应于NRoleData枚举
-- nEnum: 数据枚举索引
-- 注:	1.SetGameDataNToLabel设置数值
--		2.SetGameDataSToLabel设置字符串

function SetGameDataNToLabel(pParent, nTag, nScriptData, nRoleData, nRoleId, nId, nEnum)
	if pParent == nil then
		return;
	end
	
	local lb = GetLabel(pParent, nTag);
	if nil == lb then
		return;
	end
	
	local val = GetGameDataN(nScriptData, nRoleId, nRoleData, nId, nEnum);
	if nil == val then
		return;
	end
	
	lb:SetText(tostring(val));
end

function SetGameDataSToLabel(pParent, nTag, nScriptData, nRoleData, nRoleId, nId, nEnum)
	if pParent == nil then
		return;
	end

	if not CheckN(nTag) then
		return;
	end
	
	local lb = GetLabel(pParent, nTag);
	if nil == lb then
		return;
	end
	
	local val = GetGameDataS(nScriptData, nRoleId, nRoleData, nId, nEnum);
	if nil == val then
		return;
	end
	
	lb:SetText(val);
end

function SetLabel(pParent, nTag, str)
	if not CheckP(pParent) then
		LogInfo("SetLabel invalid pParent");
		return;
	end
    if not CheckS(str) then
		LogInfo("SetLabel invalid str");
		return;
	end

	if not CheckN(nTag) then
		LogInfo("SetLabel invalid nTag");
		return;
	end
	
	local lb = GetLabel(pParent, nTag);
	if nil == lb then
		return;
	end
	
	lb:SetText(str);
    return lb;
end

function SetHyperlinkText(pParent, nTag, str)
	if pParent == nil or not CheckS(str) then
		return;
	end

	if not CheckN(nTag) then
		return;
	end
	
	local hlt = GetHyperLinkText(pParent, nTag);
	if nil == hlt then
		return;
	end
	
	hlt:SetLinkText(str);
end

function SetHyperlinkButtn(pParent, nTag, str)
	if pParent == nil or not CheckS(str) then
		return;
	end

	if not CheckN(nTag) then
		return;
	end
	
	local hlb = GetHyperLinkButton(pParent, nTag);
	if nil == hlb then
		return;
	end
	
	hlb:SetLinkText(str);
end

function CreateLabel(text, rect, fontsize, color)
	if not CheckS(text) or not CheckN(fontsize) or
		nil == rect or nil == color then
		LogInfo("CreateLabel arg invalid");
		return nil;
	end
	local lb = createNDUILabel();
	if not lb then
		LogInfo("CreateLabel create failed");
		return nil;
	end
	lb:Init();
	lb:SetText(text);
	lb:SetFrameRect(rect);
	lb:SetFontSize(fontsize);
	lb:SetFontColor(color);
	return lb;
end

function CreateHyperlinkButton(text, rect, fontsize, color)
	if not CheckS(text) or not CheckN(fontsize) or
		nil == rect or nil == color then
		return nil;
	end
	local hlb = createUIHyperlinkButton();
	if not hlb then
		return nil;
	end
	hlb:Init();
	hlb:SetFrameRect(rect);
	hlb:SetLinkBoundRect(rect);
	hlb:SetLinkTextFontSize(fontsize);
	hlb:SetLinkTextColor(color);
	hlb:SetLinkText(text)
	return hlb;
end

function CreateHyperlinkText(text, rect, fontsize, color)
	if not CheckS(text) or not CheckN(fontsize) or
		nil == rect or nil == color then
		return
	end
	local hlt = createUIHyperlinkButton();
	if not hlt then
		return nil;
	end
	hlt:Init();
	hlt:SetFrameRect(rect);
	hlt:SetLinkBoundRect(rect);
	hlt:SetLinkTextFontSize(fontsize);
	hlt:SetLinkTextColor(color);
	hlt:SetLinkText(text);
	return hlt;
end

--focusPicname, bPicShowInCenter参数可选
function CreateButton(picname, selpicname, text, rect, fontsize, focusPicname, bPicShowInCenter, backPicname)
	if not CheckStruct(rect) or not CheckN(fontsize) then
		LogInfo("CreateButton arg invalid");
		return nil;
	end
	local btn = createNDUIButton();
	if not CheckP(btn) then
		return nil;
	end
	btn:Init();
	btn:CloseFrame();
	btn:SetFrameRect(rect);
	btn:SetFontSize(fontsize);
	if CheckS(text) then
		btn:SetTitle(text);
	end
	--LogInfo("rect[%d][%d]", rect.size.w, rect.size.h);
	local pool = DefaultPicPool();
	if CheckS(picname) and "" ~= picname then
		if CheckP(pool)  then
			local pic = pool:AddPicture(GetSMImgPath(picname), false);
			if CheckP(pic) then
				if not bPicShowInCenter then
					btn:SetImage(pic);
				else
					local size	= pic:GetSize();
					--LogInfo("pic[%d][%d]", size.w, size.h);
					local r		= CGRectMake((rect.size.w - size.w) / 2, (rect.size.h - size.h) / 2, size.w, size.h);
					btn:SetImageEx(pic, true, r, true);
				end
			end
		end
	end
	
	if CheckS(selpicname) and "" ~= selpicname then
		if CheckP(pool)  then
			local picTouch = pool:AddPicture(GetSMImgPath(selpicname), false);
			if CheckP(picTouch) then
				if not bPicShowInCenter then
					btn:SetTouchDownImage(pic);
				else
					local size	= picTouch:GetSize();
					--LogInfo("picTouch[%d][%d]", size.w, size.h);
					local r		= CGRectMake((rect.size.w - size.w) / 2, (rect.size.h - size.h) / 2, size.w, size.h);
					btn:SetTouchDownImageEx(picTouch, true, r, true);
				end
			end
		end
	end
	
	if CheckS(focusPicname) and "" ~= focusPicname then
		if CheckP(pool)  then
			local picFocus = pool:AddPicture(GetSMImgPath(focusPicname), false);
			if CheckP(picFocus) then
				if not bPicShowInCenter then
					btn:SetFocusImage(picFocus);
				else
					local size	= picFocus:GetSize();
					--LogInfo("picFocus[%d][%d]", size.w, size.h);
					local r		= CGRectMake((rect.size.w - size.w) / 2, (rect.size.h - size.h) / 2, size.w, size.h);
					btn:SetFocusImageEx(picFocus, true, r, true);
				end
			end
		end
	end
	
	if CheckS(backPicname) and "" ~= backPicname then
		if CheckP(pool)  then
			local picBack = pool:AddPicture(GetSMImgPath(backPicname), false);
			if CheckP(picBack) then
				if not bPicShowInCenter then
					btn:SetBackgroundPicture(picBack, nil);
				else
					local size	= picBack:GetSize();
					--LogInfo("picBack[%d][%d]", size.w, size.h);
					local r		= CGRectMake((rect.size.w - size.w) / 2, (rect.size.h - size.h) / 2, size.w, size.h);
					btn:SetBackgroundPictureEx(picBack, nil, true, r, true);
				end
			end
		end
	end
	
	return btn;
end



--** chh 2012-08-01 **--
function HideLoginUI(nTag)
    LogInfo("HideLoginUI");
    local scene = GetRunningScene();
    
    local hideTags = {
        NMAINSCENECHILDTAG.Login_ServerUI,
        NMAINSCENECHILDTAG.Login_RegRoleUI,
    };
    
    for i,v in ipairs(hideTags) do 
        local layer = GetUiLayer(scene,v);
        if(layer) then
            layer:SetVisible(false);
        end
    end
    
    local layer = GetUiLayer(scene,nTag);
    if(layer) then
        layer:SetVisible(true);
        return true;
    end
    return false;
end

--引导购买金币
function EMoneyNotEnough(nMoney)
    local nPlayerId     = GetPlayerId();
    local ngmoney       = GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_EMONEY);
    if(nMoney>ngmoney) then
        CommonDlgNew.ShowYesOrNoDlg(GetTxtPub("JinBiBuZhu2"),MoneySellItemOk);
    end
end

function MoneySellItemOk(nEventType, param)
    if(nEventType == CommonDlgNew.BtnOk) then
        PlayerVIPUI.LoadUI();
    end
end


local BtnLeft   = "/General/arrows/icon_arrows2.png";
local BtnRight  = "/General/arrows/icon_arrows1.png";
local BtnLeftS   = "/General/arrows/icon_arrows7.png";
local BtnRightS  = "/General/arrows/icon_arrows8.png";

--设置箭头显示
function SetArrow(layer,pageView,nShowCount,nTagBegin,nTagEnd)
    LogInfo("SetArrow nTagBegin:[%d]",nTagBegin);
    local btnL = GetImage(layer,nTagBegin);
    local btnR = GetImage(layer,nTagEnd);
    local index = pageView:GetBeginIndex();
    local pageCount = pageView:GetViewCount();
    local pool = DefaultPicPool();
	if not CheckP(pool) then
		return;
	end
    
    --left
    local norpic;
    if (index==0) then
        norpic = pool:AddPicture(GetSMImgPath(BtnLeftS), true);
    else
        norpic = pool:AddPicture(GetSMImgPath(BtnLeft), true);
    end
    if(btnL) then
        btnL:SetPicture(norpic);
    else
        LogInfo("SetArrow btnL is nil!");
    end
    
    --right
    local norpic;
    if (index + nShowCount >= pageCount) then
        norpic = pool:AddPicture(GetSMImgPath(BtnRightS), true);
    else
        norpic = pool:AddPicture(GetSMImgPath(BtnRight), true);
    end
    if(btnR) then
        btnR:SetPicture(norpic);
    else
        LogInfo("SetArrow btnR is nil!");
    end
    
    LogInfo("index:[%d],index + nShowCount:[%d],pageCount:[%d]",index,index + nShowCount,pageCount);
end



