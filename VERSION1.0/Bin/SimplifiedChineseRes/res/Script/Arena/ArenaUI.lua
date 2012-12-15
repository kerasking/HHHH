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
local ID_ARENA_CTRL_TEXT_57      = 74;
local ID_ARENA_CTRL_PICTURE_M5     = 204;
local ID_ARENA_CTRL_PICTURE_M4     = 190;
local ID_ARENA_CTRL_PICTURE_M3     = 176;
local ID_ARENA_CTRL_PICTURE_M2     = 162;
local ID_ARENA_CTRL_PICTURE_M1     = 148;
local ID_ARENA_CTRL_TEXT_67      = 68;
local ID_ARENA_CTRL_BUTTON_REMOVE_TIME   = 214;
local ID_ARENA_CTRL_TEXT_COOL_TIME    = 213;

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
local ID_ARENA_CTRL_TEXT_NEWS_3     = 134;
local ID_ARENA_CTRL_TEXT_NEWS_2     = 132;
local ID_ARENA_CTRL_TEXT_NEWS_1     = 131;
local ID_ARENA_CTRL_TEXT_GET_TIME    = 98;
local ID_ARENA_CTRL_BUTTON_HERO     = 115;
local ID_ARENA_CTRL_PICTURE_ICON_3    = 129;
local ID_ARENA_CTRL_PICTURE_ICON_1    = 127;
local ID_ARENA_CTRL_PICTURE_ICON_2    = 128;
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

p.tbDbSportPrizeData = {};
p.PlayerRank = 0;
p.ctrId = {ctrText = {txtAwardRepute = 126, txtAwardMoney = 124, txtAwardEMoney = 125, 
                                 txtMoney = 243, txtEMoney = 242,},};

--当前挑战对象
p.CurChaIndex = nil;           


local ID_ARENA_CTRL_PICTURE_BG     = 215;

local ID_ARENA_CTRL_BUTTON_ROLE_INFO_1	= 308;
local ID_ARENA_CTRL_BUTTON_ROLE_INFO_2	= 309;
local ID_ARENA_CTRL_BUTTON_ROLE_INFO_3	= 310;
local ID_ARENA_CTRL_BUTTON_ROLE_INFO_4	= 311;
local ID_ARENA_CTRL_BUTTON_ROLE_INFO_5	= 312;


--chh 2012-12-06 --
local TAG_RANKING_CONTRINER = 57;

local TAG_RANKING_SIZE      = 4;
local TAG_RANKING_NAME      = 149;  
local TAG_RANKING_BTNPIC    = 308;
local TAG_RANKING_RANK      = 151;


p.infos = nil;
local RANK_SHOW_COUNT   = 5;
local TAG_BEGIN_ARROW = 1124;
local TAG_END_ARROW = 1125;


local awardTime=0;
p.cdTime=0;
local awardTimeTag=-1;
local cdTimeTag=-1;

local add_Time_Dlg_id=0;
local remove_cd_Dlg_id=0;

local addedCount=0;
local restFightCount=0;

p.challengeID = {};

--是否在竞技场,为了小版本不更新c++代码用,跟拦截功能区分开,以后大版本更新的时候改回来

p.isInChallenge = 1;     --1竞技场   2.运粮   3.boss战  4.副本  5.大乱斗


p.battleID=
{
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
					CommonDlg.ShowWithConfirm(GetTxtPri("RTUI_T13"), p.onCommonDlg);
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
                CommonDlgNew.ShowYesOrNoDlg(string.format(GetTxtPri("AREAUI_T1"),SafeN2S(cost)), p.onCommonDlg1, true);
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
                CommonDlgNew.ShowYesOrNoDlg(string.format(GetTxtPri("AREAUI_T1"),SafeN2S(cost)), p.onCommonDlg1, true);
                
			elseif p.cdTime>0 then
				local n= p.cdTime%60;
				local cost=getIntPart(p.cdTime/60);
				if n>0 then
					cost=cost+1;
				end
				if cost > 0 then
					--remove_cd_Dlg_id=CommonDlg.ShowNoPrompt("竞技场尚在冷却中，是否花费"..SafeN2S(cost).."金币取消冷却？", 
                    --p.onCommonDlg2, true);
                             CommonDlgNew.ShowYesOrNoDlg(string.format(GetTxtPri("AREAUI_T2"), SafeN2S(cost)), p.onCommonDlg2, true);
                
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
    elseif uiEventType == NUIEventType.TE_TOUCH_SC_VIEW_IN_BEGIN then
        if TAG_RANKING_CONTRINER == tag then 
            SetArrow(p.GetParent(),p.GetRankContainer(),RANK_SHOW_COUNT,TAG_BEGIN_ARROW,TAG_END_ARROW);
        end
	end
end

function p.StartChallenge(index)

    if(p.infos[index].id == GetPlayerId()) then
        return;
    end 

	if p.infos[index].id~=0 then
		if p.cdTime > 0 then
			remove_cd_Dlg_id=CommonDlg.ShowWithConfirm(GetTxtPri("AREAUI_T3"), nil);
			return;
		end
		
		if restFightCount == 0 then
			add_Time_Dlg_id=CommonDlg.ShowWithConfirm(GetTxtPri("AREAUI_T4"), nil);
			return;
		end
        
        p.CurChaIndex = index;
        CommonDlgNew.ShowYesOrNoDlg(GetTxtPri("AREAUI_T6").. p.challengeID[index][3], p.onChallengeDlg, true);
		--_G.MsgArena.SendChallenge(p.challengeID[index][1]);
	end
end


function p.onChallengeDlg(nId, param)
    if ( CommonDlgNew.BtnOk == nId ) then
        LogInfo("rank:[%d]",param);
        _G.MsgArena.SendChallenge(param);
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

function p.SetTimerNum(time)
	local layer=p.GetParent();
	LogInfo("awardTime:%d",time);
	local str=FormatTime(time,1);
	SetLabel(layer,ID_ARENA_CTRL_TEXT_GET_TIME,str);

	awardTime=time;
	if time > 0 then
		if awardTimeTag == -1 then
			awardTimeTag=RegisterTimer(p.OnTimer,1, "ArenaUI.SetTimerNum");
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
end

function p.SetReportInfo(index,name,battle_type,result,time,rank,id_battle)
	local str="";
	
    if time < 60 then
        str = str..GetTxtPri("AREAUI_T7");
	elseif time<1800 then
		str=str..SafeN2S(getIntPart(time/60))..GetTxtPri("AREAUI_T8");
	elseif time < 3600 then
		str=str..GetTxtPri("AREAUI_T18");
	elseif time < 86400 then
		str=str..SafeN2S(getIntPart(time/3600))..GetTxtPri("AREAUI_T9");
	else
		str=str..SafeN2S(getIntPart(time/86400))..GetTxtPri("AREAUI_T10");
	end
	
	str=str..GetTxtPri("AREAUI_T11");
	
	if battle_type == 0 then
		str=str..name..GetTxtPri("AREAUI_T12");
	else
		str=str..string.format(GetTxtPri("AREAUI_T13"),name);
	end
	
	if result==0 then
		str=str..GetTxtPri("AREAUI_T14");
		if battle_type == 0 and rank ~= 0 then
			str=str..string.format(GetTxtPri("AREAUI_T15"),rank);
		else
			str=str..GetTxtPri("AREAUI_T16");
		end
	else
		str=str..GetTxtPri("AREAUI_T17")
		if battle_type == 0 or rank == 0  then
			str=str..GetTxtPri("AREAUI_T16");
		else
            LogInfo("p.SetReportInfo rank = %d, rank = %s", rank, SafeN2S(rank));
			str=str..string.format(GetTxtPri("AREAUI_T20"),rank);
            --str=str.."升至第"..rank.."名";
		end
	end
    LogInfo("p.SetReportInfo index = %d, str = %s", index, str);
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
	p.battleID[1]=0;
	p.battleID[2]=0;
	p.battleID[3]=0;
	SetLabel(layer,ID_ARENA_CTRL_TEXT_NEWS_1,"");
	SetLabel(layer,ID_ARENA_CTRL_TEXT_NEWS_2,"");
	SetLabel(layer,ID_ARENA_CTRL_TEXT_NEWS_3,"");
end




function p.GetRankContainer()
	local container = GetScrollViewContainer(p.GetParent(), TAG_RANKING_CONTRINER);
	return container;
end


--刷新排行列表
--{{index=,id=,name=,level=,rank=,lookfaceID=},{index=,id=,name=,level=,rank=,lookfaceID=}}
function p.RefreshRankList(infos)
    p.infos = infos;
    local container = p.GetRankContainer();
    
    if(container == nil) then
        LogInfo("p.RefreshRankList container == nil");
        return;
    end
    
    container:RemoveAllView();
    
    local nPos = -1;
    for i,v in ipairs(infos)do
        if(v.id == GetPlayerId()) then
            nPos = i;
            p.PlayerRank = v.rank;
        end
        p.CreateRankItem(v);
    end
    
    nPos = nPos - 1;
    --设置玩家在中心位置
    local nMid = math.floor(RANK_SHOW_COUNT/2);
    local nMaxIndex = #infos-nMid-1;
    if(nPos>0) then
        if(nPos > nMid and nPos<nMaxIndex) then
            LogInfo("nPos > nMid and nPos<=nMaxIndex");
            nPos = nPos - nMid;
        elseif(nPos<=nMid) then
            LogInfo("nPos<=nMid");
            nPos = 0;
        elseif(nPos>=nMaxIndex) then
            LogInfo("nPos>=nMaxIndex");
            nPos = nMaxIndex - nMid ;
        end
        container:ShowViewByIndex(nPos);
    end
    
    LogInfo("nMid:[%d],nMaxIndex:[%d],nPos:[%d]",nMid,nMaxIndex,nPos);
    
    SetArrow(p.GetParent(),p.GetRankContainer(),RANK_SHOW_COUNT,TAG_BEGIN_ARROW,TAG_END_ARROW);
    
    p.RefreshUI();
end


function p.CreateRankItem(info)
    local container = p.GetRankContainer();
    local view = createUIScrollView();
    
    view:Init(false);
    view:SetScrollStyle(UIScrollStyle.Horzontal);
    view:SetViewId(info.id);
    view:SetTag(info.index);
    view:SetMovableViewer(container);
    view:SetScrollViewer(container);
    view:SetContainer(container);
    
    --初始化ui
    local uiLoad = createNDUILoad();
    if nil == uiLoad then
        return false;
    end

    uiLoad:Load("SM_JJ_List.ini", view, p.OnUIRankItemEvent, 0, 0);
       
    --实例化每一项
    p.RefreshRankItem(view,info);
    
    container:AddView(view);
    uiLoad:Free();
end

function p.RefreshRankItem(view,info)  
    local btn = GetButton(view, TAG_RANKING_BTNPIC);
    btn:SetParam1(info.index);
    local pic = GetArenaUIPlayerHeadPic(info.lookfaceID);  
    if CheckP(btn) then
        btn:SetImage(pic);
    end   
    
    local l_name = SetLabel(view, TAG_RANKING_NAME, string.format("lv.%d %s",info.level,info.name));
    local l_rank = SetLabel(view, TAG_RANKING_RANK, string.format("第%d名",info.rank));
    
    if(info.id == GetPlayerId()) then
        l_name:SetFontColor(ccc4(255,15,15,255));
        l_rank:SetFontColor(ccc4(255,15,15,255));
    end
    
    --设置容器大小
    local img = GetImage(view, TAG_RANKING_SIZE);
    local container = p.GetRankContainer();
    container:SetViewSize(img:GetFrameRect().size);
end

function p.OnUIRankItemEvent(uiNode, uiEventType, param)
    local tag = uiNode:GetTag();
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if TAG_RANKING_BTNPIC == tag then
            local btn = ConverToButton(uiNode);
			p.StartChallenge(btn:GetParam1());
        end
        
	end
	return true;

end
    
function p.SetChallengeList(index,id,name,level,rank,lookfaceID)
	local layer=p.GetParent();
    local nPlayerId = GetPlayerId();
    LogInfo("p.SetChallengeList id = %d, nPlayerId = %d", id, nPlayerId);
    p.challengeID[index]={rank,id,name};  
    
    if id == nPlayerId then
       p.PlayerRank = rank;
       p.RefreshUI();
    end
    
    
    
    
    
    
	if index == 1 then
        local lbLev = GetLabel(layer, ID_ARENA_CTRL_TEXT_PLAYER_NAME_1);  
        local lbRank = GetLabel(layer, ID_ARENA_CTRL_TEXT_TANK_1); 
        if id == nPlayerId then
            p.challengeID[1][1] = 0;   
            lbLev:SetFontColor(ccc4(255,255,0, 255));
            lbRank:SetFontColor(ccc4(255,255,0, 255));
        else
            lbLev:SetFontColor(ccc4(126,192, 238, 255));
            lbRank:SetFontColor(ccc4(126,192, 238, 255));
        end
        
		SetLabel(layer,ID_ARENA_CTRL_TEXT_PLAYER_NAME_1,"lv."..SafeN2S(level).."  "..name);
		SetLabel(layer,ID_ARENA_CTRL_TEXT_TANK_1,string.format(GetTxtPri("AREAUI_T21"),rank));
        local roleBtn = GetButton(layer, ID_ARENA_CTRL_BUTTON_ROLE_INFO_1);
        local pic = GetArenaUIPlayerHeadPic(lookfaceID);      
        if CheckP(pic) then
            roleBtn:SetImage(pic);
        end
	elseif index == 2 then
        local lbLev = GetLabel(layer, ID_ARENA_CTRL_TEXT_PLAYER_NAME_2);  
        local lbRank = GetLabel(layer, ID_ARENA_CTRL_TEXT_TANK_2); 

         if id == nPlayerId then
            p.challengeID[2][1] = 0;   
            lbLev:SetFontColor(ccc4(255,255,0, 255));
            lbRank:SetFontColor(ccc4(255,255,0, 255));
        else
            lbLev:SetFontColor(ccc4(126,192, 238, 255));
            lbRank:SetFontColor(ccc4(126,192, 238, 255));
        end

		SetLabel(layer,ID_ARENA_CTRL_TEXT_PLAYER_NAME_2,"lv."..SafeN2S(level).."  "..name);
		SetLabel(layer,ID_ARENA_CTRL_TEXT_TANK_2, string.format(GetTxtPri("AREAUI_T21"),rank));
        
        local roleBtn = GetButton(layer, ID_ARENA_CTRL_BUTTON_ROLE_INFO_2);
        local pic = GetArenaUIPlayerHeadPic(lookfaceID);      
        if CheckP(pic) then
            roleBtn:SetImage(pic);
        end   
        
	elseif index == 3 then
        local lbLev = GetLabel(layer, ID_ARENA_CTRL_TEXT_PLAYER_NAME_3);  
        local lbRank = GetLabel(layer, ID_ARENA_CTRL_TEXT_TANK_3);   
        if id == nPlayerId then
            p.challengeID[3][1] = 0;   
            lbLev:SetFontColor(ccc4(255,255,0, 255));
            lbRank:SetFontColor(ccc4(255,255,0, 255));
        else
            lbLev:SetFontColor(ccc4(126,192, 238, 255));
            lbRank:SetFontColor(ccc4(126,192, 238, 255));
        end

		SetLabel(layer,ID_ARENA_CTRL_TEXT_PLAYER_NAME_3,"lv."..SafeN2S(level).."  "..name);
		SetLabel(layer,ID_ARENA_CTRL_TEXT_TANK_3, string.format(GetTxtPri("AREAUI_T21"),rank));
        
        local roleBtn = GetButton(layer, ID_ARENA_CTRL_BUTTON_ROLE_INFO_3);
        local pic = GetArenaUIPlayerHeadPic(lookfaceID);      
        if CheckP(pic) then
            roleBtn:SetImage(pic);
        end   
    elseif index == 4 then
        local lbLev = GetLabel(layer, ID_ARENA_CTRL_TEXT_PLAYER_NAME_4);  
        local lbRank = GetLabel(layer, ID_ARENA_CTRL_TEXT_TANK_4); 
        if id == nPlayerId then
            p.challengeID[4][1] = 0;   
            lbLev:SetFontColor(ccc4(255,255,0, 255));
            lbRank:SetFontColor(ccc4(255,255,0, 255));
        else
            lbLev:SetFontColor(ccc4(126,192, 238, 255));
            lbRank:SetFontColor(ccc4(126,192, 238, 255));
        end

		SetLabel(layer,ID_ARENA_CTRL_TEXT_PLAYER_NAME_4,"lv."..SafeN2S(level).."  "..name);
		SetLabel(layer,ID_ARENA_CTRL_TEXT_TANK_4, string.format(GetTxtPri("AREAUI_T21"),rank));
        
        local roleBtn = GetButton(layer, ID_ARENA_CTRL_BUTTON_ROLE_INFO_4);
        local pic = GetArenaUIPlayerHeadPic(lookfaceID);      
        if CheckP(pic) then
            roleBtn:SetImage(pic);
        end   
	elseif index == 5 then
        local lbLev = GetLabel(layer, ID_ARENA_CTRL_TEXT_PLAYER_NAME_5);  
        local lbRank = GetLabel(layer, ID_ARENA_CTRL_TEXT_TANK_5); 
        if id == nPlayerId then
            p.challengeID[5][1] = 0;   
            lbLev:SetFontColor(ccc4(255,255,0, 255));
            lbRank:SetFontColor(ccc4(255,255,0, 255));
        else
            lbLev:SetFontColor(ccc4(126,192, 238, 255));
            lbRank:SetFontColor(ccc4(126,192, 238, 255));
        end
        
		SetLabel(layer,ID_ARENA_CTRL_TEXT_PLAYER_NAME_5,"lv."..SafeN2S(level).."  "..name);
		SetLabel(layer,ID_ARENA_CTRL_TEXT_TANK_5, string.format(GetTxtPri("AREAUI_T21"),rank));
    
        local roleBtn = GetButton(layer, ID_ARENA_CTRL_BUTTON_ROLE_INFO_5);
        local pic = GetArenaUIPlayerHeadPic(lookfaceID);   
        if CheckP(pic) then
            roleBtn:SetImage(pic);
        end   	
    end
	
end

function p.showRewardUI()
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
        if pBtnCtr ~= nil then
            pBtnCtr:SetVisible( true );
        end
   end
   
   if iInfoNum >= nTotalNum then 
      return;
   end
   
   for i = iInfoNum + 1, nTotalNum  do
        local pBtnCtr	= GetButton( layer,  tListItemBtnID[i]);
        if(pBtnCtr) then
            pBtnCtr:SetVisible( false );
        end
    end
end


function p.LoadUI()
    p.isInChallenge = 1;
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
	scene:AddChildZ(layer,UILayerZOrder.NormalLayer);
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

    p.InitData();
	--p.RefreshUI();
	
	
	--设置关闭音效
   	local closeBtn=GetButton(layer,ID_ARENA_CTRL_BUTTON_CLOSE);
   	closeBtn:SetSoundEffect(Music.SoundEffect.CLOSEBTN);
end

function p.InitData()
    local Ids = GetDataBaseIdList("sports_prize");
    p.tbDbSportPrizeData = {};
    
    for i, v in pairs(Ids) do
        local Record = {};
        Record.nRank = GetDataBaseDataN("sports_prize", v, DB_SPORTS_PRIZE.RANKING);
        Record.nMoney = GetDataBaseDataN("sports_prize", v, DB_SPORTS_PRIZE.MONEY); 
        Record.nRepute = GetDataBaseDataN("sports_prize", v, DB_SPORTS_PRIZE.REPUTE); 
        Record.nItem      = GetDataBaseDataN("sports_prize", v, DB_SPORTS_PRIZE.ITEM); 
        Record.nItemCount = GetDataBaseDataN("sports_prize", v, DB_SPORTS_PRIZE.ITEMCOUNT); 
        Record.nEMoney = GetDataBaseDataN("sports_prize", v, DB_SPORTS_PRIZE.EMONEY);     
        table.insert(p.tbDbSportPrizeData, Record);
    end
    
    if p.tbDbSportPrizeData ~= nil then
        table.sort(p.tbDbSportPrizeData, function(a,b) return a.nRank < b.nRank  end);
    end 
    
    for i, v in pairs(p.tbDbSportPrizeData) do
        LogInfo("p.InitData  rank = %d, Money = %d, EMoney = %d", v.nRank, v.nMoney, v.nEMoney);
    end
end

function p.RefreshUI()
    LogInfo("p.RefreshUI");
	local layer = p.GetParent();
	
	local nPlayerId = GetPlayerId();
	if nil == nPlayerId then
        LogInfo("p.RefreshUI 2");
		LogInfo("nil == nPlayerId");
		return;
	end
	
    --显示排名奖励部分ui
    if p.PlayerRank == 0 then
        LogInfo("p.RefreshUI 2");
        return;
    end
    
    p.RefreshMoney();
    
    if p.PlayerRank > 1000 then
         LogInfo("p.RefreshUI 3");
        --显示银币,金币,声望
        SetLabel(layer, p.ctrId.ctrText.txtAwardMoney, SafeN2S(0));
        SetLabel(layer, p.ctrId.ctrText.txtAwardEMoney, SafeN2S(0));  
        SetLabel(layer, p.ctrId.ctrText.txtAwardRepute, SafeN2S(0));     
    else
        LogInfo("p.RefreshUI 2");
        local tbInfo = {};
        for i, v in pairs(p.tbDbSportPrizeData) do
            if v.nRank >= p.PlayerRank then
                tbInfo = v;
                break;
            end
        end
        --显示银币,声望,奖励
        SetLabel(layer, p.ctrId.ctrText.txtAwardMoney, SafeN2S(tbInfo.nMoney));
        SetLabel(layer, p.ctrId.ctrText.txtAwardRepute, SafeN2S(tbInfo.nRepute));   
        local str = "";
        local ItemName = ItemFunc.GetName(tbInfo.nItem);
        str = str .. ItemName.. "X" .. tbInfo.nItemCount;
        SetLabel(layer, p.ctrId.ctrText.txtAwardEMoney, str);       
    end

    --LogInfo("p.RefreshUI  rank = %d, Money = %d, EMoney = %d", p.PlayerRank, tbInfo.nMoney, tbInfo.nEMoney);
end

function p.RefreshMoney()
    local nPlayerId = GetPlayerId();
	if nil == nPlayerId then
		LogInfo("nil == nPlayerId");
		return;
	end
    local layer = p.GetParent();
    
    local nMoney 		=  GetRoleBasicDataN(nPlayerId, USER_ATTR.USER_ATTR_MONEY);
    local nEMoney 	= GetRoleBasicDataN(nPlayerId, USER_ATTR.USER_ATTR_EMONEY);
    SetLabel(layer, p.ctrId.ctrText.txtMoney, fomatBigNumber(nMoney));
    SetLabel(layer, p.ctrId.ctrText.txtEMoney, fomatBigNumber(nEMoney)); 
end

GameDataEvent.Register(GAMEDATAEVENT.USERATTR,"ArenaUI.RefreshMoney",p.RefreshMoney);
