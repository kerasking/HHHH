---------------------------------------------------
--描述: 竞技场界面
--时间: 2012.3.15
--作者: cl

---------------------------------------------------
local _G = _G;

ArenaUI={}
local p=ArenaUI;
local ID_ARENA_CTRL_BUTTON_ADD_TIME		=211;
local ID_ARENA_CTRL_TEXT_60      = 77;
local ID_ARENA_CTRL_TEXT_59      = 76;
local ID_ARENA_CTRL_TEXT_ARENA_ACCOUNT   = 210;
local ID_ARENA_CTRL_TEXT_USER_NAME	=117;
local ID_ARENA_CTRL_TEXT_57      = 74;
local ID_ARENA_CTRL_PICTURE_M5     = 204;
local ID_ARENA_CTRL_PICTURE_M4     = 190;
local ID_ARENA_CTRL_PICTURE_M3     = 176;
local ID_ARENA_CTRL_PICTURE_M2     = 162;
local ID_ARENA_CTRL_PICTURE_M1     = 148;
local ID_ARENA_CTRL_TEXT_67      = 68;
local ID_ARENA_CTRL_BUTTON_REMOVE_TIME   = 214;
local ID_ARENA_CTRL_TEXT_COOL_TIME    = 213;
local ID_ARENA_CTRL_TEXT_WIN_COUNT	=126;

local ID_ARENA_CTRL_TEXT_TANK_5     = 207;
local ID_ARENA_CTRL_TEXT_LEV_5     = 206;
local ID_ARENA_CTRL_TEXT_TANK_4     = 193;
local ID_ARENA_CTRL_TEXT_LEV_4     = 192;
local ID_ARENA_CTRL_TEXT_TANK_3     = 179;
local ID_ARENA_CTRL_TEXT_LEV_3     = 178;
local ID_ARENA_CTRL_TEXT_TANK_2     = 165;
local ID_ARENA_CTRL_TEXT_LEV_2     = 164;
local ID_ARENA_CTRL_TEXT_TANK_1     = 151;
local ID_ARENA_CTRL_TEXT_LEV_1     = 150;

local ID_ARENA_CTRL_TEXT_PLAYER_NAME_5   = 205;
local ID_ARENA_CTRL_TEXT_PLAYER_NAME_4   = 191;
local ID_ARENA_CTRL_TEXT_PLAYER_NAME_3   = 177;
local ID_ARENA_CTRL_TEXT_PLAYER_NAME_2   = 163;
local ID_ARENA_CTRL_TEXT_PLAYER_NAME_1   = 149;

local ID_ARENA_CTRL_TEXT_NEWS_4     = 133;
local ID_ARENA_CTRL_TEXT_NEWS_3     = 134;
local ID_ARENA_CTRL_TEXT_NEWS_2     = 132;
local ID_ARENA_CTRL_TEXT_NEWS_1     = 131;

local ID_ARENA_CTRL_TEXT_GET_TIME    = 98;
local ID_ARENA_CTRL_TEXT_CALL     = 125;


local ID_ARENA_CTRL_BUTTON_HERO     = 115;


local ID_ARENA_CTRL_PICTURE_ICON_4    = 130;
local ID_ARENA_CTRL_PICTURE_ICON_3    = 129;
local ID_ARENA_CTRL_PICTURE_ICON_1    = 127;
local ID_ARENA_CTRL_PICTURE_ICON_2    = 128;

local ID_ARENA_CTRL_TEXT_VOICE     = 124;
local ID_ARENA_CTRL_TEXT_350     = 96;
local ID_ARENA_CTRL_TEXT_349     = 349;
local ID_ARENA_CTRL_TEXT_348     = 123;
local ID_ARENA_CTRL_BUTTON_CLOSE    = 90;
local ID_ARENA_CTRL_TEXT_346     = 346;
local ID_ARENA_CTRL_TEXT_COPPER_NUM    = 94;
local ID_ARENA_CTRL_PICTURE_COPPER    = 342;
local ID_ARENA_CTRL_TEXT_INGOT_NUM    = 92;
local ID_ARENA_CTRL_PICTURE_INGOT    = 340;

local ID_ARENA_CTRL_BUTTON_R_1     = 135;
local ID_ARENA_CTRL_BUTTON_R_2     = 136;
local ID_ARENA_CTRL_BUTTON_R_3     = 137;
local ID_ARENA_CTRL_BUTTON_R_4     = 138;

-- 每个按钮ID
local tListItemBtnID ={
	135, 136, 137, 138,
};


local ID_ARENA_CTRL_PICTURE_BG     = 215;

local ID_ARENA_CTRL_BUTTON_ROLE_INFO_1	= 308;
local ID_ARENA_CTRL_BUTTON_ROLE_INFO_2	= 309;
local ID_ARENA_CTRL_BUTTON_ROLE_INFO_3	= 310;
local ID_ARENA_CTRL_BUTTON_ROLE_INFO_4	= 311;
local ID_ARENA_CTRL_BUTTON_ROLE_INFO_5	= 312;

local ID_ARENA_CTRL_PICTURE_ROLE_INFO_1	= 501;
local ID_ARENA_CTRL_PICTURE_ROLE_INFO_2	= 502;
local ID_ARENA_CTRL_PICTURE_ROLE_INFO_3	= 503;
local ID_ARENA_CTRL_PICTURE_ROLE_INFO_4	= 504;
local ID_ARENA_CTRL_PICTURE_ROLE_INFO_5	= 505;

local awardTime=0;
p.cdTime=0;
local awardTimeTag=-1;
local cdTimeTag=-1;

local add_Time_Dlg_id=0;
local remove_cd_Dlg_id=0;

local addedCount=0;
local restFightCount=0;

p.challengeID = {};

p.battleID=
{
	0,
	0,
	0,
	0,
	0,
};

function p.onCommonDlg1(nId, param)
    if ( CommonDlgNew.BtnOk == nId ) then
        LogInfo("++++++++++add_Time_Dlg_id++++++");
        addedCount=addedCount+1;
        _G.MsgArena.SendAddTime();
    end
end

function p.onCommonDlg2(nId, param)
        LogInfo("++++++++++remove_cd_Dlg_id++++++");
        if ( CommonDlgNew.BtnOk == nId ) then
			local n=p.cdTime%60;
			local cost=getIntPart(p.cdTime/60);
			if n>0 then
				cost=cost+1;
			end
			if cost > 0 then
				local nPlayerId = GetPlayerId();
				if nil == nPlayerId then
					LogInfo("nil == nPlayerId");
					return;
				end
	
                local emoney = GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_MONEY);
				--local emoney = GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_ADVANCE_MONEY);
				if emoney >= cost then
                     LogInfo("++++++++++SendClearTime++++++");
					_G.MsgArena.SendClearTime();
				else
					CommonDlg.ShowWithConfirm("金币不足", p.onCommonDlg);
				end
			end
		end
end

function p.OnUIEvent(uiNode,uiEventType,param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEvent[%d]",tag);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if ID_ARENA_CTRL_BUTTON_CLOSE == tag then
			local scene = GetSMGameScene();
			if scene~= nil then
				if cdTimeTag~= -1 then
					UnRegisterTimer(cdTimeTag);
					cdTimeTag=-1
				end
				if awardTimeTag~= -1 then
					UnRegisterTimer(awardTimeTag);
					awardTimeTag=-1
				end
				scene:RemoveChildByTag(NMAINSCENECHILDTAG.Arena,true);
                --BackCity();--Guosen 2012.7.2
				return true;
			end
		elseif ID_ARENA_CTRL_BUTTON_ADD_TIME == tag then
            local nPlayerId = GetPlayerId();
                if nil == nPlayerId then
                    LogInfo("nil == nPlayerId");
                    return;
                end
            local money = GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_EMONEY);
			local cost=(addedCount+1)*2;
            if money<cost then
                CommonDlg.ShowWithConfirm("金币不足", p.onCommonDlg);
            else
                --add_Time_Dlg_id=CommonDlg.ShowNoPrompt("是否花费"..SafeN2S(cost).."金币，增加1次挑战次数？", p.onCommonDlg1, true);
                CommonDlgNew.ShowYesOrNoDlg("是否花费"..SafeN2S(cost).."金币，增加1次挑战次数？", p.onCommonDlg1, true);
			end
		elseif ID_ARENA_CTRL_BUTTON_REMOVE_TIME == tag then
            LogInfo("+++++++++++ID_ARENA_CTRL_BUTTON_REMOVE_TIME+++++++");
            local nPlayerId = GetPlayerId();
                if nil == nPlayerId then
                    LogInfo("nil == nPlayerId");
                    return;
                end
            local money = GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_EMONEY);
			local cost=(addedCount+1)*2;
            if money<cost then
                CommonDlg.ShowWithConfirm("金币不足", p.onCommonDlg);
            end
            if restFightCount == 0 then
				local cost=(addedCount+1)*2;
				--add_Time_Dlg_id=CommonDlg.ShowNoPrompt("是否花费"..SafeN2S(cost).."金币，增加1次挑战次数？", p.onCommonDlg1, true);
                CommonDlgNew.ShowYesOrNoDlg("是否花费"..SafeN2S(cost).."金币，增加1次挑战次数？", p.onCommonDlg1, true);
                
			elseif p.cdTime>0 then
				local n=p.cdTime%60;
				local cost=getIntPart(p.cdTime/60);
				if n>0 then
					cost=cost+1;
				end
                cost = cost * 2;
				if cost > 0 then
					--remove_cd_Dlg_id=CommonDlg.ShowNoPrompt("竞技场尚在冷却中，是否花费"..SafeN2S(cost).."金币取消冷却？", 
                    --p.onCommonDlg2, true);
                             CommonDlgNew.ShowYesOrNoDlg("竞技场尚在冷却中，是否花费"..SafeN2S(cost).."金币取消冷却？",  p.onCommonDlg2, true);
                
				end
			end

		elseif ID_ARENA_CTRL_BUTTON_HERO == tag then
			_G.MsgArena.SendFrontRank();
		elseif ID_ARENA_CTRL_BUTTON_R_1 == tag then
			if p.battleID[1] ~= 0 then
				_G.MsgArena.SendWatchBattle(p.battleID[1]);
			end
		elseif ID_ARENA_CTRL_BUTTON_R_2 == tag then
			if p.battleID[2] ~= 0 then
				_G.MsgArena.SendWatchBattle(p.battleID[2]);
			end
		elseif ID_ARENA_CTRL_BUTTON_R_3 == tag then
			if p.battleID[3] ~= 0 then
				_G.MsgArena.SendWatchBattle(p.battleID[3]);
			end
		elseif ID_ARENA_CTRL_BUTTON_R_4 == tag then
			if p.battleID[4] ~= 0 then
				_G.MsgArena.SendWatchBattle(p.battleID[4]);
			end
		elseif ID_ARENA_CTRL_BUTTON_R_5 == tag then
			if p.battleID[5] ~= 0 then
				_G.MsgArena.SendWatchBattle(p.battleID[5]);
			end
            
		elseif ID_ARENA_CTRL_BUTTON_ROLE_INFO_1 == tag then
            p.StartChallenge(1)     
		elseif ID_ARENA_CTRL_BUTTON_ROLE_INFO_2 == tag then
			p.StartChallenge(2);
		elseif ID_ARENA_CTRL_BUTTON_ROLE_INFO_3 == tag then
			p.StartChallenge(3);
		elseif ID_ARENA_CTRL_BUTTON_ROLE_INFO_4 == tag then
			p.StartChallenge(4);
		elseif ID_ARENA_CTRL_BUTTON_ROLE_INFO_5 == tag then
			p.StartChallenge(5);
		end
        
	end
end

function p.StartChallenge(index)
	if p.challengeID[index][1]~=0 then
		if p.cdTime > 0 then
			remove_cd_Dlg_id=CommonDlg.ShowWithConfirm("挑战时间CD中...", nil);
			return;
		end
		
		if restFightCount == 0 then
			add_Time_Dlg_id=CommonDlg.ShowWithConfirm("挑战次数已用完...", nil);
			return;
		end
		
		_G.MsgArena.SendChallenge(p.challengeID[index][1]);
		
	end
end

function p.GetParent()
	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end
	
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.Arena);
	if nil == layer then
		return nil;
	end
	
	--local container = GetScrollViewContainer(layer, TAG_CONTAINER);
	return layer;
end

function p.SetAwardInfo(time,awardMoney,awardRepute)
	local layer=p.GetParent();
	LogInfo("awardTime:%d",time);
	local str=FormatTime(time,1);
	SetLabel(layer,ID_ARENA_CTRL_TEXT_GET_TIME,str);
	
	str="金钱:"..SafeN2S(awardMoney).." 声望:"..SafeN2S(awardRepute);
	SetLabel(layer,ID_ARENA_CTRL_TEXT_350,str);
	
	awardTime=time;
	if time > 0 then
		if awardTimeTag == -1 then
			awardTimeTag=RegisterTimer(p.OnTimer,1, "ArenaUI.SetAwardInfo");
			LogInfo("awardtimer tag[%d]",awardTimeTag);
		end
	end
end

function p.updateTime(cd)
	local layer=p.GetParent();
	local str=FormatTime(cd,1);
	SetLabel(layer,ID_ARENA_CTRL_TEXT_COOL_TIME,str);

	p.cdTime = cd;
	if p.cdTime > 0 then
		if cdTimeTag == -1 then
			cdTimeTag=RegisterTimer(p.OnTimer,1, "ArenaUI.updateTime");
			LogInfo("cdtimer tag[%d]",cdTimeTag);
		end
	end
	
end

function p.updateCount(restCount)
	local layer=p.GetParent();
    SetLabel(layer,ID_ARENA_CTRL_TEXT_ARENA_ACCOUNT,SafeN2S(restCount));
	restFightCount=restCount;
	local button=GetButton(layer,ID_ARENA_CTRL_BUTTON_ADD_TIME);
	if CheckP(button) then
		if restCount <= 0 then
			--button:SetVisible(true);
		else
			--button:SetVisible(false);
		end
	end
end

function p.OnTimer(tag)
	--LogInfo("timer tag[%d]",tag);
	local layer=p.GetParent();
	if tag == awardTimeTag then

		local str=FormatTime(awardTime,1);
		SetLabel(layer,ID_ARENA_CTRL_TEXT_GET_TIME,str);
		if awardTime <= 0 then
			awardTime=3*24*3600;
		else
			awardTime=awardTime-1;
		end
	elseif tag == cdTimeTag then
		
		local str=FormatTime(p.cdTime,1);
		SetLabel(layer,ID_ARENA_CTRL_TEXT_COOL_TIME,str);
		if p.cdTime <= 0 then
			UnRegisterTimer(cdTimeTag);
			cdTimeTag=-1;
			p.cdTime=0;
		else
			p.cdTime=p.cdTime-1;
		end
	end
end

function p.SetSelfInfo(rank,restCount,ac,cd,winCount)
	local layer=p.GetParent();
	addedCount=ac;
	restFightCount=restCount;
	SetLabel(layer,ID_ARENA_CTRL_TEXT_348 ,SafeN2S(rank));	
	
	SetLabel(layer,ID_ARENA_CTRL_TEXT_ARENA_ACCOUNT,SafeN2S(restCount));
    
	SetLabel(layer,ID_ARENA_CTRL_TEXT_WIN_COUNT,SafeN2S(winCount));
	
	local str=FormatTime(cd,1);
	SetLabel(layer,ID_ARENA_CTRL_TEXT_COOL_TIME,str);

	p.cdTime = cd;
	if p.cdTime > 0 then
		if cdTimeTag == -1 then
			cdTimeTag=RegisterTimer(p.OnTimer,1, "ArenaUI.SetSelfInfo");
			LogInfo("cdtimer tag[%d]",cdTimeTag);
		end
	end
	
	local button=GetButton(layer,ID_ARENA_CTRL_BUTTON_ADD_TIME);
	if CheckP(button) then
		if restCount <= 0 then
			--button:SetVisible(true);
		else
			--button:SetVisible(false);
		end
	end
	
	SetLabel(layer,ID_ARENA_CTRL_TEXT_CALL,name);
end

function p.SetReportInfo(index,name,battle_type,result,time,rank,id_battle)
	local str="";
	
    if time < 60 then
        str = str.."不久之";
	elseif time<1800 then
		str=str..SafeN2S(getIntPart(time/60)).."分钟";
	elseif time < 3600 then
		str=str.."半小时";
	elseif time < 86400 then
		str=str..SafeN2S(getIntPart(time/3600)).."小时";
	else
		str=str..SafeN2S(getIntPart(time/86400)).."天";
	end
	
	str=str.."前,";
	
	if battle_type == 0 then
		str=str..name.."挑战你，你";
	else
		str=str.."你挑战"..name..",你";
	end
	
	if result==0 then
		str=str.."失败了,";
		if battle_type == 0 and rank ~= 0 then
			str=str.."降至第"..rank.."名";
		else
			str=str.."排名不变";
		end
	else
		str=str.."获胜了,"
		if battle_type == 0 or rank == 0  then
			str=str.."排名不变";
		else
			str=str.."升至第"..rank.."名";
		end
	end
	LogInfo(str);
	local layer=p.GetParent();
	if index == 1 then
		SetLabel(layer,ID_ARENA_CTRL_TEXT_NEWS_1,str);
		p.battleID[1]=id_battle;
	elseif index == 2 then
		SetLabel(layer,ID_ARENA_CTRL_TEXT_NEWS_2,str);
		p.battleID[2]=id_battle;
	elseif index == 3 then
		SetLabel(layer,ID_ARENA_CTRL_TEXT_NEWS_3,str);
		p.battleID[3]=id_battle;
	elseif index == 4 then
		SetLabel(layer,ID_ARENA_CTRL_TEXT_NEWS_4,str);
		p.battleID[4]=id_battle;
	end
end

function p.CleanChallengeList()
		local layer=p.GetParent();
		if p.challengeID[1]~=nil then
			p.challengeID[1][1]=0;
			SetLabel(layer,ID_ARENA_CTRL_TEXT_PLAYER_NAME_1,"");
			SetLabel(layer,ID_ARENA_CTRL_TEXT_LEV_1,"");
			SetLabel(layer,ID_ARENA_CTRL_TEXT_TANK_1,"");
		end
		if p.challengeID[2]~=nil then
			p.challengeID[2][1]=0;
			SetLabel(layer,ID_ARENA_CTRL_TEXT_PLAYER_NAME_2,"");
			SetLabel(layer,ID_ARENA_CTRL_TEXT_LEV_2,"");
			SetLabel(layer,ID_ARENA_CTRL_TEXT_TANK_2,"");
		end
		if p.challengeID[3]~=nil then
			p.challengeID[3][1]=0;
			SetLabel(layer,ID_ARENA_CTRL_TEXT_PLAYER_NAME_3,"");
			SetLabel(layer,ID_ARENA_CTRL_TEXT_LEV_3,"");
			SetLabel(layer,ID_ARENA_CTRL_TEXT_TANK_3,"");
		end
		if p.challengeID[4]~=nil then
			p.challengeID[4][1]=0;
			SetLabel(layer,ID_ARENA_CTRL_TEXT_PLAYER_NAME_4,"");
			SetLabel(layer,ID_ARENA_CTRL_TEXT_LEV_4,"");
			SetLabel(layer,ID_ARENA_CTRL_TEXT_TANK_4,"");
		end
		if p.challengeID[5]~=nil then
			p.challengeID[5][1]=0;
			SetLabel(layer,ID_ARENA_CTRL_TEXT_PLAYER_NAME_5,"");
			SetLabel(layer,ID_ARENA_CTRL_TEXT_LEV_5,"");
			SetLabel(layer,ID_ARENA_CTRL_TEXT_TANK_5,"");
		end
end

function p.CleanReport()
	local layer=p.GetParent();
	p.battleID[0]=0;
	p.battleID[1]=0;
	p.battleID[2]=0;
	p.battleID[3]=0;
	p.battleID[4]=0;
	SetLabel(layer,ID_ARENA_CTRL_TEXT_NEWS_1,"");
	SetLabel(layer,ID_ARENA_CTRL_TEXT_NEWS_2,"");
	SetLabel(layer,ID_ARENA_CTRL_TEXT_NEWS_3,"");
	SetLabel(layer,ID_ARENA_CTRL_TEXT_NEWS_4,"");
end

function p.SetChallengeList(index,id,name,level,rank,lookfaceID)
	local layer=p.GetParent();
    local nPlayerId = GetPlayerId();
    LogInfo("p.SetChallengeList id = %d, nPlayerId = %d", id, nPlayerId);
    p.challengeID[index]={rank,id,name};  
    
	if index == 1 then
        if id == nPlayerId then
            local lbLev = GetLabel(layer, ID_ARENA_CTRL_TEXT_PLAYER_NAME_1);  
            local lbRank = GetLabel(layer, ID_ARENA_CTRL_TEXT_TANK_1); 
            lbLev:SetFontColor(ccc4(255,255,0, 255));
            lbRank:SetFontColor(ccc4(255,255,0, 255));
            p.challengeID[1][1] = 0;    
        end
        
		SetLabel(layer,ID_ARENA_CTRL_TEXT_PLAYER_NAME_1,"lv."..SafeN2S(level).."  "..name);
		SetLabel(layer,ID_ARENA_CTRL_TEXT_TANK_1,SafeN2S(rank));
		--local role_image=GetButton(layer,ID_ARENA_CTRL_BUTTON_ROLE_INFO_1);
        --local role_image=GetButton(layer,ID_ARENA_CTRL_PICTURE_ROLE_INFO_1);  
        local role_image = GetImage(layer,ID_ARENA_CTRL_PICTURE_ROLE_INFO_1);
        --local pic = GetPetPotraitPic(lookfaceID);
        local pic = GetPlayerPotraitTranPic(lookfaceID);      
        if CheckP(pic) then
            --role_image:SetImage(pic);
            role_image:SetPicture(pic);
        end
	elseif index == 2 then
        if id == nPlayerId then
            p.challengeID[2][1] = 0;     
            local lbLev = GetLabel(layer, ID_ARENA_CTRL_TEXT_PLAYER_NAME_2);  
            local lbRank = GetLabel(layer, ID_ARENA_CTRL_TEXT_TANK_2); 
            lbLev:SetFontColor(ccc4(255,255,0,255));
            lbRank:SetFontColor(ccc4(255,255,0,255));
       end
       
		SetLabel(layer,ID_ARENA_CTRL_TEXT_PLAYER_NAME_2,"lv."..SafeN2S(level).."  "..name);
		SetLabel(layer,ID_ARENA_CTRL_TEXT_TANK_2,SafeN2S(rank));
        local role_image = GetImage(layer,ID_ARENA_CTRL_PICTURE_ROLE_INFO_2);
        --local pic = GetPetPotraitPic(lookfaceID);
        local pic = GetPlayerPotraitTranPic(lookfaceID);      
        if CheckP(pic) then
            role_image:SetPicture(pic);
        end   
	elseif index == 3 then
        if id == nPlayerId then
            p.challengeID[3][1] = 0;     
            local lbLev = GetLabel(layer, ID_ARENA_CTRL_TEXT_PLAYER_NAME_3);  
            local lbRank = GetLabel(layer, ID_ARENA_CTRL_TEXT_TANK_3); 
            lbLev:SetFontColor(ccc4(255,255,0, 255));
            lbRank:SetFontColor(ccc4(255,255,0, 255));
        end
        
		SetLabel(layer,ID_ARENA_CTRL_TEXT_PLAYER_NAME_3,"lv."..SafeN2S(level).."  "..name);
		SetLabel(layer,ID_ARENA_CTRL_TEXT_TANK_3,SafeN2S(rank));
        local role_image = GetImage(layer,ID_ARENA_CTRL_PICTURE_ROLE_INFO_3);
        --local pic = GetPetPotraitPic(lookfaceID);
        local pic = GetPlayerPotraitTranPic(lookfaceID);      
        if CheckP(pic) then
            role_image:SetPicture(pic);
        end   
    elseif index == 4 then
        if id == nPlayerId then
            p.challengeID[4][1] = 0;     
            local lbLev = GetLabel(layer, ID_ARENA_CTRL_TEXT_PLAYER_NAME_4);  
            local lbRank = GetLabel(layer, ID_ARENA_CTRL_TEXT_TANK_4); 
            lbLev:SetFontColor(ccc4(255,255,0, 255));
            lbRank:SetFontColor(ccc4(255,255,0, 255));
        end
    
        if id == nPlayerId then
            local lbLev = GetLabel(layer, ID_ARENA_CTRL_TEXT_PLAYER_NAME_4);  
            local lbRank = GetLabel(pParent, ID_ARENA_CTRL_TEXT_TANK_4); 
            lbLev:SetFontColor(ccc4(255,255,0, 255));
            lbRank:SetFontColor(ccc4(255,255,0, 255)); 
        end
		p.challengeID[4]={rank,id,name};
		SetLabel(layer,ID_ARENA_CTRL_TEXT_PLAYER_NAME_4,"lv."..SafeN2S(level).."  "..name);
		SetLabel(layer,ID_ARENA_CTRL_TEXT_TANK_4,SafeN2S(rank));
        local role_image = GetImage(layer,ID_ARENA_CTRL_PICTURE_ROLE_INFO_4);
        --local pic = GetPetPotraitPic(lookfaceID);
        local pic = GetPlayerPotraitTranPic(lookfaceID);      
        if CheckP(pic) then
            role_image:SetPicture(pic);
        end   
	elseif index == 5 then
        if id == nPlayerId then
            p.challengeID[5][1] = 0;      
            local lbLev = GetLabel(layer, ID_ARENA_CTRL_TEXT_PLAYER_NAME_5);  
            local lbRank = GetLabel(layer, ID_ARENA_CTRL_TEXT_TANK_5); 
            lbLev:SetFontColor(ccc4(255,255,0, 255));
            lbRank:SetFontColor(ccc4(255,255,0, 255));
        end
        
		SetLabel(layer,ID_ARENA_CTRL_TEXT_PLAYER_NAME_5,"lv."..SafeN2S(level).."  "..name);
		SetLabel(layer,ID_ARENA_CTRL_TEXT_TANK_5,SafeN2S(rank));
        local role_image = GetImage(layer,ID_ARENA_CTRL_PICTURE_ROLE_INFO_5);
        --local pic = GetPetPotraitPic(lookfaceID);
        local pic = GetPlayerPotraitTranPic(lookfaceID);      
        if CheckP(pic) then
            role_image:SetPicture(pic);
        end   	
    end
	
end

function p.showRewardUI()
end

function p.RefreshUI()
	local layer = p.GetParent();
	
	local nPlayerId = GetPlayerId();
	if nil == nPlayerId then
		LogInfo("nil == nPlayerId");
		return;
	end
	
	local repute = GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_REPUTE);
	SetLabel(layer,ID_ARENA_CTRL_TEXT_VOICE,SafeN2S(repute));
    local nPetId = ConvertN(RolePetFunc.GetMainPetId(nPlayerId));
    local name = ConvertS(RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_NAME));  
	SetLabel(layer,ID_ARENA_CTRL_TEXT_USER_NAME,name);	
	local money = GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_MONEY);
	LogInfo("Arena money:%d",money);
	SetLabel(layer,ID_ARENA_CTRL_TEXT_COPPER_NUM,fomatBigNumber(money));
	LogInfo("Arena money2:%d",money);
    local emoney = GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_EMONEY);
	--local emoney = GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_ADVANCE_MONEY);
	SetLabel(layer,ID_ARENA_CTRL_TEXT_INGOT_NUM,fomatBigNumber(emoney));
    local LEVEL = PlayerFunc.GetUserAttr(GetPlayerId(),USER_ATTR.USER_ATTR_RANK);
    local l_label = GetLabel(layer, ID_ARENA_CTRL_TEXT_CALL);
    if LEVEL==0 then
        l_label:SetText("无");
    elseif LEVEL>0 then
        l_label:SetText(GetDataBaseDataS("rank_config",LEVEL,DB_RANK.RANK_NAME));
    end
end

function p.OnDeConstruct()
	if cdTimeTag ~=-1 then
		UnRegisterTimer(cdTimeTag);
	end
	
	if awardTimeTag ~= -1 then
		UnRegisterTimer(awardTimeTag);
	end
end

--设置查看按钮是否可见
function p.SetButtonVisible(iInfoNum)
   local layer=p.GetParent();
   local  nTotalNum = table.getn( tListItemBtnID );
   
   for i = 1, iInfoNum  do
        local pBtnCtr	= GetButton( layer,  tListItemBtnID[i]);
        pBtnCtr:SetVisible( true );
   end
   
   if iInfoNum >= nTotalNum then 
      return;
   end
   
   for i = iInfoNum + 1, nTotalNum  do
        local pBtnCtr	= GetButton( layer,  tListItemBtnID[i]);
        pBtnCtr:SetVisible( false );
    end
end


function p.LoadUI()
    LogInfo("p.LoadUIp.LoadUIp.LoadUIp.LoadUIp.LoadUIp.LoadUIp.LoadUIp.LoadUIp.LoadUIp.LoadUI");
	local scene=GetSMGameScene();
	if scene == nil then
		LogInfo("scene = nil,load bossui failed!");
		return;
	end
	
	
	local layer =createUIScrollContainer();
	if layer == nil then
		LogInfo("scene = nil,2");
		return  false;
	end
	--LogInfo("get layer");
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.Arena);
	local winsize = GetWinSize(); 
	layer:SetFrameRect(CGRectMake(0, 0, winsize.w, winsize.h));
	--layer:SetBackgroundColor(ccc4(125,125,125,125));
	scene:AddChildZ(layer,1);
	--_G.AddChild(scene, layer, NMAINSCENECHILDTAG.Arena);
	local uiLoad=createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		LogInfo("scene = nil,4");
		return false;
	end
	uiLoad:Load("SM_JJ_MAIN.ini",layer,p.OnUIEvent,0,0);
	uiLoad:Free();
	
	layer:SetDestroyNotify(p.OnDeConstruct);

	p.RefreshUI()
	
	
	--设置关闭音效
   	local closeBtn=GetButton(layer,ID_ARENA_CTRL_BUTTON_CLOSE);
   	closeBtn:SetSoundEffect(Music.SoundEffect.CLOSEBTN);
end