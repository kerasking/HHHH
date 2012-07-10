---------------------------------------------------
--描述: 竞技场界面
--时间: 2012.3.15
--作者: cl

---------------------------------------------------
local _G = _G;

ArenaUI={}
local p=ArenaUI;
local ID_ARENA_CTRL_BUTTON_ADD_TIME		=81;
local ID_ARENA_CTRL_TEXT_60      = 77;
local ID_ARENA_CTRL_TEXT_59      = 76;
local ID_ARENA_CTRL_TEXT_ARENA_ACCOUNT   = 75;
local ID_ARENA_CTRL_TEXT_57      = 74;
local ID_ARENA_CTRL_PICTURE_M5     = 73;
local ID_ARENA_CTRL_PICTURE_M4     = 72;
local ID_ARENA_CTRL_PICTURE_M3     = 71;
local ID_ARENA_CTRL_PICTURE_M2     = 70;
local ID_ARENA_CTRL_PICTURE_M1     = 69;
local ID_ARENA_CTRL_TEXT_67      = 68;
local ID_ARENA_CTRL_BUTTON_REMOVE_TIME   = 67;
local ID_ARENA_CTRL_TEXT_COOL_TIME    = 66;
local ID_ARENA_CTRL_TEXT_PLAYER_NAME_5   = 65;
local ID_ARENA_CTRL_TEXT_PLAYER_NAME_4   = 64;
local ID_ARENA_CTRL_TEXT_PLAYER_NAME_3   = 63;
local ID_ARENA_CTRL_TEXT_TANK_5     = 62;
local ID_ARENA_CTRL_TEXT_LEV_5     = 61;
local ID_ARENA_CTRL_TEXT_TANK_4     = 60;
local ID_ARENA_CTRL_TEXT_LEV_4     = 59;
local ID_ARENA_CTRL_TEXT_TANK_3     = 58;
local ID_ARENA_CTRL_TEXT_LEV_3     = 57;
local ID_ARENA_CTRL_TEXT_TANK_2     = 56;
local ID_ARENA_CTRL_TEXT_LEV_2     = 55;
local ID_ARENA_CTRL_TEXT_PLAYER_NAME_2   = 52;
local ID_ARENA_CTRL_TEXT_NEWS_5     = 47;
local ID_ARENA_CTRL_TEXT_NEWS_4     = 46;
local ID_ARENA_CTRL_TEXT_NEWS_3     = 45;
local ID_ARENA_CTRL_TEXT_NEWS_2     = 43;
local ID_ARENA_CTRL_TEXT_GET_TIME    = 185;
local ID_ARENA_CTRL_TEXT_CALL     = 183;
local ID_ARENA_CTRL_TEXT_182     = 182;
local ID_ARENA_CTRL_TEXT_TANK_1     = 80;
local ID_ARENA_CTRL_TEXT_LEV_1     = 32;
local ID_ARENA_CTRL_TEXT_PLAYER_NAME_1   = 30;
local ID_ARENA_CTRL_BUTTON_HERO     = 372;
local ID_ARENA_CTRL_TEXT_NEWS_1     = 366;
local ID_ARENA_CTRL_PICTURE_ICON_5    = 360;
local ID_ARENA_CTRL_PICTURE_ICON_4    = 359;
local ID_ARENA_CTRL_PICTURE_ICON_3    = 358;
local ID_ARENA_CTRL_PICTURE_ICON_1    = 356;
local ID_ARENA_CTRL_PICTURE_ICON_2    = 357;
local ID_ARENA_CTRL_TEXT_VOICE     = 355;
local ID_ARENA_CTRL_TEXT_350     = 350;
local ID_ARENA_CTRL_TEXT_349     = 349;
local ID_ARENA_CTRL_TEXT_348     = 348;
local ID_ARENA_CTRL_BUTTON_CLOSE    = 347;
local ID_ARENA_CTRL_TEXT_346     = 346;
local ID_ARENA_CTRL_TEXT_COPPER_NUM    = 343;
local ID_ARENA_CTRL_PICTURE_COPPER    = 342;
local ID_ARENA_CTRL_TEXT_INGOT_NUM    = 341;
local ID_ARENA_CTRL_BUTTON_R_1     = 363;
local ID_ARENA_CTRL_BUTTON_R_5     = 367;
local ID_ARENA_CTRL_PICTURE_INGOT    = 340;
local ID_ARENA_CTRL_BUTTON_R_2     = 40;
local ID_ARENA_CTRL_BUTTON_R_3     = 41;
local ID_ARENA_CTRL_BUTTON_R_4     = 42;
local ID_ARENA_CTRL_PICTURE_BG     = 78;

local ID_ARENA_CTRL_BUTTON_ROLE_1	= 79;
local ID_ARENA_CTRL_BUTTON_ROLE_2	= 82;
local ID_ARENA_CTRL_BUTTON_ROLE_3	= 83;
local ID_ARENA_CTRL_BUTTON_ROLE_4	= 84;
local ID_ARENA_CTRL_BUTTON_ROLE_5	= 85;

local awardTime=0;
local cdTime=0;
local awardTimeTag=-1;
local cdTimeTag=-1;

p.challengeID = 
{
	0,
	0,
	0,
	0,
	0,
};

p.battleID=
{
	0,
	0,
	0,
	0,
	0,
};

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
				return true;
			end
		elseif ID_ARENA_CTRL_BUTTON_ADD_TIME == tag then
			_G.MsgArena.SendAddTime();
		elseif ID_ARENA_CTRL_BUTTON_REMOVE_TIME == tag then
			_G.MsgArena.SendClearTime();
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
		elseif ID_ARENA_CTRL_BUTTON_ROLE_1 == tag then
			if p.challengeID[1]~=0 then
				_G.MsgArena.SendChallenge(p.challengeID[1]);
			end
		elseif ID_ARENA_CTRL_BUTTON_ROLE_2 == tag then
			if p.challengeID[2]~=0 then
				_G.MsgArena.SendChallenge(p.challengeID[2]);
			end
		elseif ID_ARENA_CTRL_BUTTON_ROLE_3 == tag then
			if p.challengeID[3]~=0 then
				_G.MsgArena.SendChallenge(p.challengeID[3]);
			end
		elseif ID_ARENA_CTRL_BUTTON_ROLE_4 == tag then
			if p.challengeID[4]~=0 then
				_G.MsgArena.SendChallenge(p.challengeID[4]);
			end
		elseif ID_ARENA_CTRL_BUTTON_ROLE_5 == tag then
			if p.challengeID[5]~=0 then
				_G.MsgArena.SendChallenge(p.challengeID[5]);
			end
		end
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
	
	local str=FormatTime(time,1);
	SetLabel(layer,ID_ARENA_CTRL_TEXT_GET_TIME,"领取时间:"..str);
	
	str="金钱:"..SafeN2S(awardMoney).." 声望:"..SafeN2S(awardRepute);
	SetLabel(layer,ID_ARENA_CTRL_TEXT_350,str);
	
	awardTime=time;
	if time > 0 then
		if awardTimeTag == -1 then
			awardTimeTag=RegisterTimer(p.OnTimer,1);
			LogInfo("awardtimer tag[%d]",awardTimeTag);
		end
	end
end

function p.updateTime(cd)
	local layer=p.GetParent();
	local str=FormatTime(cd,1);
	SetLabel(layer,ID_ARENA_CTRL_TEXT_COOL_TIME,str);

	cdTime = cd;
	if cdTime > 0 then
		if cdTimeTag == -1 then
			cdTimeTag=RegisterTimer(p.OnTimer,1);
			LogInfo("cdtimer tag[%d]",cdTimeTag);
		end
	end
	
end

function p.updateCount(restCount)
	local layer=p.GetParent();
	SetLabel(layer,ID_ARENA_CTRL_TEXT_ARENA_ACCOUNT,SafeN2S(restCount));
		
	local button=GetButton(layer,ID_ARENA_CTRL_BUTTON_ADD_TIME);
	if CheckP(button) then
		if restCount <= 0 then
			button:SetVisible(true);
		else
			button:SetVisible(false);
		end
	end
end

function p.OnTimer(tag)
	--LogInfo("timer tag[%d]",tag);
	local layer=p.GetParent();
	if tag == awardTimeTag then

		local str=FormatTime(awardTime,1);
		SetLabel(layer,ID_ARENA_CTRL_TEXT_GET_TIME,"领取时间:"..str);
		if awardTime <= 0 then
			UnRegisterTimer(awardTimerTag);
			awardTimerTag=-1;
		end
		awardTime=awardTime-1;
	elseif tag == cdTimeTag then
		
		local str=FormatTime(cdTime,1);
		SetLabel(layer,ID_ARENA_CTRL_TEXT_COOL_TIME,str);
		if cdTime <= 0 then
			UnRegisterTimer(cdTimeTag);
			cdTimeTag=-1;
		end
		cdTime=cdTime-1;
	end
end

function p.SetSelfInfo(rank,restCount,cd,name)
	local layer=p.GetParent();
	
	SetLabel(layer,ID_ARENA_CTRL_TEXT_348 ,SafeN2S(rank));	
	
	SetLabel(layer,ID_ARENA_CTRL_TEXT_ARENA_ACCOUNT,SafeN2S(restCount));
	
	local str=FormatTime(cd,1);
	SetLabel(layer,ID_ARENA_CTRL_TEXT_COOL_TIME,str);

	cdTime = cd;
	if cdTime > 0 then
		if cdTimeTag == -1 then
			cdTimeTag=RegisterTimer(p.OnTimer,1);
			LogInfo("cdtimer tag[%d]",cdTimeTag);
		end
	end
	
	local button=GetButton(layer,ID_ARENA_CTRL_BUTTON_ADD_TIME);
	if CheckP(button) then
		if restCount <= 0 then
			button:SetVisible(true);
		else
			button:SetVisible(false);
		end
	end
	
	SetLabel(layer,ID_ARENA_CTRL_TEXT_CALL,name);
end

function p.SetReportInfo(index,name,battle_type,result,time,rank,id_battle)
	local str="";
	
	if time<1800 then
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
	local bg;
	local layer=p.GetParent();
	if index == 1 then
		p.battleID[1]=id_battle;
		SetLabel(layer,ID_ARENA_CTRL_TEXT_NEWS_1,str);
		bg=GetImage(layer,ID_ARENA_CTRL_PICTURE_ICON_1);
	elseif index == 2 then
		p.battleID[2]=id_battle;
		SetLabel(layer,ID_ARENA_CTRL_TEXT_NEWS_2,str);
		bg=GetImage(layer,ID_ARENA_CTRL_PICTURE_ICON_2);
	elseif index == 3 then
		p.battleID[3]=id_battle;
		SetLabel(layer,ID_ARENA_CTRL_TEXT_NEWS_3,str);
		bg=GetImage(layer,ID_ARENA_CTRL_PICTURE_ICON_3);
	elseif index == 4 then
		p.battleID[4]=id_battle;
		SetLabel(layer,ID_ARENA_CTRL_TEXT_NEWS_4,str);
		bg=GetImage(layer,ID_ARENA_CTRL_PICTURE_ICON_4);
	elseif index == 5 then
		p.battleID[5]=id_battle;
		SetLabel(layer,ID_ARENA_CTRL_TEXT_NEWS_5,str);
		bg=GetImage(layer,ID_ARENA_CTRL_PICTURE_ICON_5);
	end
	local pool = DefaultPicPool();
	if CheckP(bg) then
		bg:SetPicture(pool:AddPicture(GetSMImgPath("mark_attack.png"), false),true);
	end
end

function p.CleanChallengeList()
		local layer=p.GetParent();
		p.challengeID[1]=0;
		SetLabel(layer,ID_ARENA_CTRL_TEXT_PLAYER_NAME_1,"");
		SetLabel(layer,ID_ARENA_CTRL_TEXT_LEV_1,"");
		SetLabel(layer,ID_ARENA_CTRL_TEXT_TANK_1,"");
		p.challengeID[2]=0;
		SetLabel(layer,ID_ARENA_CTRL_TEXT_PLAYER_NAME_2,"");
		SetLabel(layer,ID_ARENA_CTRL_TEXT_LEV_2,"");
		SetLabel(layer,ID_ARENA_CTRL_TEXT_TANK_2,"");
		p.challengeID[3]=0;
		SetLabel(layer,ID_ARENA_CTRL_TEXT_PLAYER_NAME_3,"");
		SetLabel(layer,ID_ARENA_CTRL_TEXT_LEV_3,"");
		SetLabel(layer,ID_ARENA_CTRL_TEXT_TANK_3,"");
		p.challengeID[4]=0;
		SetLabel(layer,ID_ARENA_CTRL_TEXT_PLAYER_NAME_4,"");
		SetLabel(layer,ID_ARENA_CTRL_TEXT_LEV_4,"");
		SetLabel(layer,ID_ARENA_CTRL_TEXT_TANK_4,"");
		p.challengeID[5]=0;
		SetLabel(layer,ID_ARENA_CTRL_TEXT_PLAYER_NAME_5,"");
		SetLabel(layer,ID_ARENA_CTRL_TEXT_LEV_5,"");
		SetLabel(layer,ID_ARENA_CTRL_TEXT_TANK_5,"");
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
	SetLabel(layer,ID_ARENA_CTRL_TEXT_NEWS_5,"");
end

function p.SetChallengeList(index,id,name,level,rank)
	local layer=p.GetParent();
	if index == 1 then
		p.challengeID[1]=rank;
		SetLabel(layer,ID_ARENA_CTRL_TEXT_PLAYER_NAME_1,name);
		SetLabel(layer,ID_ARENA_CTRL_TEXT_LEV_1,"lv"..SafeN2S(level));
		SetLabel(layer,ID_ARENA_CTRL_TEXT_TANK_1,"排名"..SafeN2S(rank));
	elseif index == 2 then
		p.challengeID[2]=rank;
		SetLabel(layer,ID_ARENA_CTRL_TEXT_PLAYER_NAME_2,name);
		SetLabel(layer,ID_ARENA_CTRL_TEXT_LEV_2,"lv"..SafeN2S(level));
		SetLabel(layer,ID_ARENA_CTRL_TEXT_TANK_2,"排名"..SafeN2S(rank));
	elseif index == 3 then
		p.challengeID[3]=rank;
		SetLabel(layer,ID_ARENA_CTRL_TEXT_PLAYER_NAME_3,name);
		SetLabel(layer,ID_ARENA_CTRL_TEXT_LEV_3,"lv"..SafeN2S(level));
		SetLabel(layer,ID_ARENA_CTRL_TEXT_TANK_3,"排名"..SafeN2S(rank));
	elseif index == 4 then
		p.challengeID[4]=rank;
		SetLabel(layer,ID_ARENA_CTRL_TEXT_PLAYER_NAME_4,name);
		SetLabel(layer,ID_ARENA_CTRL_TEXT_LEV_4,"lv"..SafeN2S(level));
		SetLabel(layer,ID_ARENA_CTRL_TEXT_TANK_4,"排名"..SafeN2S(rank));
	elseif index == 5 then
		p.challengeID[5]=rank;
		SetLabel(layer,ID_ARENA_CTRL_TEXT_PLAYER_NAME_5,name);
		SetLabel(layer,ID_ARENA_CTRL_TEXT_LEV_5,"lv"..SafeN2S(level));
		SetLabel(layer,ID_ARENA_CTRL_TEXT_TANK_5,"排名"..SafeN2S(rank));
	end
	
end

function p.RefreshUI()
	local layer = p.GetParent();
	
	local nPlayerId = GetPlayerId();
	if nil == nPlayerId then
		LogInfo("nil == nPlayerId");
		return;
	end
	
	local repute = RolePet.GetPetInfoN(nPlayerId,USER_ATTR.USER_ATTR_REPUTE);
	SetLabel(layer,ID_ARENA_CTRL_TEXT_VOICE,SafeN2S(repute));
	
	local money = RolePet.GetPetInfoN(PlayerId,USER_ATTR.USER_ATTR_MONEY);
	SetLabel(layer,ID_ARENA_CTRL_TEXT_COPPER_NUM,SafeN2S(money));
	
	local emoney = RolePet.GetPetInfoN(PlayerId,USER_ATTR.USER_ATTR_EMONEY);
	SetLabel(layer,ID_ARENA_CTRL_TEXT_INGOT_NUM,SafeN2S(emoney));
	
	local bg=GetImage(layer,ID_ARENA_CTRL_PICTURE_BG);
	local pool = DefaultPicPool();
	if CheckP(bg) then
		bg:SetPicture(pool:AddPicture(GetSMImgPath("bg/bg_home.png"), false),true);
	end
end

function p.LoadUI()
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
	scene:AddChild(layer);
	local uiLoad=createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		LogInfo("scene = nil,4");
		return false;
	end
	uiLoad:Load("Arena.ini",layer,p.OnUIEvent,0,0);
	uiLoad:Free();

	p.RefreshUI()
end