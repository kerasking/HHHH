---------------------------------------------------
--描述: BOSS战界面
--时间: 2012.3.15
--作者: cl

---------------------------------------------------
local _G = _G;

bossUI={}
local p=bossUI;


local MSG_BOSS_BATTLE_ACT_NONE = 0;
local MSG_BOSS_BATTLE_ACT_REBORN =1;
local MSG_BOSS_BATTLE_ACT_FIRE_REBORN =2;

local winsize	= GetWinSize();
local rankNum	= 10;
local rankContainer;

local ID_BOSSS_CTRL_TEXT_S_7     = 501;
local ID_BOSSS_CTRL_TEXT_S_4     = 500;
local ID_BOSSS_CTRL_TEXT_S_10     = 499;
local ID_BOSSS_CTRL_TEXT_S_9     = 498;
local ID_BOSSS_CTRL_TEXT_S_8     = 497;
local ID_BOSSS_CTRL_TEXT_S_6     = 496;
local ID_BOSSS_CTRL_TEXT_S_5     = 495;
local ID_BOSSS_CTRL_TEXT_S_3     = 494;
local ID_BOSSS_CTRL_TEXT_S_2     = 493;
local ID_BOSSS_CTRL_TEXT_S_1     = 492;

local ID_BOSSS_CTRL_TEXT_NAME_9     = 448;
local ID_BOSSS_CTRL_TEXT_NAME_8     = 447;
local ID_BOSSS_CTRL_TEXT_NAME_7     = 446;
local ID_BOSSS_CTRL_TEXT_NAME_6     = 445;
local ID_BOSSS_CTRL_TEXT_NAME_5     = 444;
local ID_BOSSS_CTRL_TEXT_NAME_4     = 443;
local ID_BOSSS_CTRL_TEXT_NAME_3     = 442;
local ID_BOSSS_CTRL_TEXT_NAME_2     = 441;
local ID_BOSSS_CTRL_TEXT_NAME_1     = 440;
local ID_BOSSS_CTRL_TEXT_NAME_10    = 449;

local ID_BOSSS_CTRL_TEXT_HURT_9     = 468;
local ID_BOSSS_CTRL_TEXT_HURT_8     = 467;
local ID_BOSSS_CTRL_TEXT_HURT_7     = 466;
local ID_BOSSS_CTRL_TEXT_HURT_6     = 465;
local ID_BOSSS_CTRL_TEXT_HURT_1     = 460;
local ID_BOSSS_CTRL_TEXT_HURT_10    = 469;
local ID_BOSSS_CTRL_TEXT_HURT_2     = 461;
local ID_BOSSS_CTRL_TEXT_HURT_3     = 462;
local ID_BOSSS_CTRL_TEXT_HURT_4     = 463;
local ID_BOSSS_CTRL_TEXT_HURT_5     = 464;

local ID_BOSSS_CTRL_BUTTON_POP		= 39;

local ID_BOSSS_CTRL_BUTTON_EXIT     = 467;
local ID_BOSSS_CTRL_TEXT_BOSS_HURT    = 466;
local ID_BOSSS_CTRL_TEXT_465     = 465;
local ID_BOSSS_CTRL_TEXT_BOSS_TIME    = 464;
local ID_BOSSS_CTRL_TEXT_463     = 463;
local ID_BOSSS_CTRL_TEXT_461     = 461;
local ID_BOSSS_CTRL_EXP_BOSS_LIFE    = 460;
local ID_BOSSS_CTRL_TEXT_BOSS_NAME    = 458;
local ID_BOSSS_CTRL_TEXT_INSPIRE_INFO   = 456;
local ID_BOSSS_CTRL_BUTTON_REVIVE    = 454;
local ID_BOSSS_CTRL_BUTTON_INSPIRE_DESIRE  = 453;
local ID_BOSSS_CTRL_BUTTON_INSPIRE_SEE   = 452;
local ID_BOSSS_CTRL_BUTTON_INSPIRE_INGOT  = 451;
local ID_BOSSS_CTRL_CHECK_BUTTON_JOIN   = 502;

local bossCurrentLife=0;
local bossTotalLife=0;
local restTime=0;
local timerTag=-1;
local selfDamage=0;

local foldX=winsize.w-0.058*winsize.w;
local unFoldX=winsize.w-0.55*winsize.w;

function p.SetBossLife(currentlife,totalLife)
	local layer = p.GetParent();
	if nil == layer then
		return;
	end
	
	bossCurrentLife=currentlife;
	
	bossTotalLife=totalLife;
	
	if selfDamage ~=0 then
		local percent=0;
		if bossTotalLife ~= 0 then
			percent=selfDamage*100/bossTotalLife;
		end
		LogInfo("dmg:%d,life:%d,per:%f",selfDamage,bossTotalLife,percent);
		percent=GetNumDot(percent,2);
		LogInfo("percent:%f",percent);
		local str=GetTxtPri("BOSSUI_T1")..SafeN2S(selfDamage);
		
		SetLabel(layer,ID_BOSSS_CTRL_TEXT_BOSS_HURT,str);
	end
	

	
	local lifeBar = RecursivUIExp(layer, {ID_BOSSS_CTRL_EXP_BOSS_LIFE} );
	if CheckP(lifeBar) then
		LogInfo("setBossHP:%d/%d",currentlife,totalLife);
		lifeBar:SetProcess(currentlife);
		-- todo
		lifeBar:SetTotal(totalLife);
	else
		LogInfo("lifeBar not find");
	end

end

function p.SetRestTime(time)
	local layer = p.GetParent();
	if nil == layer then
		return;
	end
	
	restTime=time;
	SetLabel(layer,ID_BOSSS_CTRL_TEXT_BOSS_TIME,FormatTime(time,1));
	if timerTag == -1 then
		timerTag=RegisterTimer(p.OnTimer,1);
	end
end

function p.OnTimer(tag)
	if tag == timerTag then
		p.SetRestTime(restTime - 1);
		if restTime == 0 then
			UnRegisterTimer(timerTag);
			timerTag=-1;
		end
	end
end

function p.SetRankInfo(rank,name,damage)
	local nameTag=ID_BOSSS_CTRL_TEXT_NAME_1+rank-1;
	local hurtTag=ID_BOSSS_CTRL_TEXT_HURT_1+rank-1;
	
	SetLabel(rankContainer,nameTag,name);
	SetLabel(rankContainer,hurtTag,SafeN2S(damage));
end

function p.SetSelfDamage(damage)
	selfDamage = damage;
	local layer = p.GetParent();
	if nil == layer then
		return;
	end
	
	local percent=0;
	if bossTotalLife ~= 0 then
		percent=damage*100/bossTotalLife;
	end
	LogInfo("dmg:%d,life:%d,per:%f",damage,bossTotalLife,percent);
	percent=GetNumDot(percent,2);
	LogInfo("percent:%f",percent);
	local str="你的伤害:"..SafeN2S(damage);
	
	SetLabel(layer,ID_BOSSS_CTRL_TEXT_BOSS_HURT,str);
end



function p.Showing()
	local scene = GetSMGameScene();
	if scene == nil then
		return false;
	end
	
	local layer = scene:GetChild(NMAINSCENECHILDTAG.bossUI);
	if layer == nil then
		return false;
	end
	
	return true;
end

function p.GetParent()
	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end
	
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.bossUI);
	if nil == layer then
		return nil;
	end
	
	--local container = GetScrollViewContainer(layer, TAG_CONTAINER);
	return layer;
end

function p.ToggleRankList()
	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end
	LogInfo("ToggleRankList");
	if IsUIShow(NMAINSCENECHILDTAG.bossRankUI) then
		LogInfo("ToggleRankList2");
		local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.bossRankUI);
		if nil == layer then
			return nil;
		end
		local o_rect = layer:GetFrameRect();
		if o_rect.origin.x >= foldX-1 then
			LogInfo("ToggleRankList_unfold");
			local rectX = unFoldX;
			local rectW	= winsize.w*0.55;
			local rect  = CGRectMake(rectX, winsize.h*0.3, rectW, winsize.h*0.62); 
			layer:SetFrameRect(rect);
		else
			LogInfo("ToggleRankList_fold");
			local rectX = foldX;
			local rectW	= winsize.w*0.55;
			local rect  = CGRectMake(rectX, winsize.h*0.3, rectW, winsize.h*0.62); 
			layer:SetFrameRect(rect);
		end

	end
end

function p.OnUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEvent[%d]", tag);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if ID_BOSSS_CTRL_BUTTON_POP == tag then
			p.ToggleRankList();
		elseif ID_BOSSS_CTRL_BUTTON_REVIVE == tag then
			_G.MsgBoss.SendReVive(MSG_BOSS_BATTLE_ACT_REBORN);
		elseif ID_BOSSS_CTRL_BUTTON_INSPIRE_DESIRE == tag then
			_G.MsgBoss.SendReVive(MSG_BOSS_BATTLE_ACT_FIRE_REBORN);
		elseif ID_BOSSS_CTRL_BUTTON_EXIT  == tag then
			_G.MsgBoss.QuitBossBattle();
		end
	elseif uiEventType == NUIEventType.TE_TOUCH_CHECK_CLICK then
		if ID_BOSSS_CTRL_CHECK_BUTTON_JOIN == tag then
			local layer=p.GetParent();
			if layer == nil then
				LogInfo("layer == nil");
				return  false;
			end
			local checkBox=RecursiveCheckBox(layer,{ID_BOSSS_CTRL_CHECK_BUTTON_JOIN});
			if CheckP(checkBox) then
				local isAuto=checkBox:IsSelect();
				local mapLayer=GetMapLayer();
				mapLayer:setAutoBossFight(isAuto);
			else
				LogInfo("can not find checkBox");
			end
		end
	end
	 
end

function p.LoadRankUI()
	local scene = GetSMGameScene();
	if scene == nil then
		LogInfo("scene == nil,load BottomSpeedBar failed!");
		return;
	end
	
	rankContainer = createUIScrollContainer();
	if rankContainer == nil then
		LogInfo("container == nil,load rankUI failed!");
		return;
	end
	
	local rectX = foldX;
	local rectW	= winsize.w*0.55;
	local rect  = CGRectMake(rectX, winsize.h*0.3, rectW, winsize.h*0.62); 
	
	rankContainer:Init();
	rankContainer:SetTag(NMAINSCENECHILDTAG.bossRankUI);
	rankContainer:SetFrameRect(rect);
	--rankContainer:SetLeftReserveDistance(rect.size.w);
	--rankContainer:SetRightReserveDistance((p.BtnWidth + p.Btninner)* 2.5);
	scene:AddChild(rankContainer);
	
	local uiLoad=createNDUILoad();
	if nil == uiLoad then
		rankContainer:Free();
		LogInfo("scene = nil,4");
		return false;
	end
	uiLoad:Load("Boss_rank.ini",rankContainer,p.OnUIEvent,0,0);
	uiLoad:Free();
	
	local mapLayer=GetMapLayer();
	local isBattle = mapLayer:IsBattleBackground();
	
	if isBattle then
		rankContainer:SetVisible(false);
	end
end



function p.LoadUI()
	local scene=GetSMGameScene();
	if scene == nil then
		LogInfo("scene = nil,load bossui failed!");
		return;
	end
	
	local layer = createUIScrollContainer();
	if layer == nil then
		LogInfo("scene = nil,2");
		return  false;
	end
	--LogInfo("get layer");
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.bossUI);
	local winsize = GetWinSize(); 
	layer:SetFrameRect(CGRectMake(0, 0, winsize.w, winsize.h));
	--layer:SetBackgroundColor(ccc4(125,125,125,125));
	scene:AddChild(layer);
	--LogInfo("load boss ui");
	local uiLoad=createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		LogInfo("scene = nil,4");
		return false;
	end
	uiLoad:Load("boss.ini",layer,p.OnUIEvent,0,0);
	uiLoad:Free();
	--LogInfo("load boss ui succeed");
	
	local nPlayerId = GetPlayerId();
	if nil == nPlayerId then
		LogInfo("nil == nPlayerId");
		return;
	end
	
	local vipLevel = GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_VIP_RANK);
	if vipLevel < 6 then
		local button=GetUiNode(layer,ID_BOSSS_CTRL_CHECK_BUTTON_JOIN);
		if CheckP(button) then
			button:SetVisible(false);
		end
	end
	
	local mapLayer=GetMapLayer();
	local isBattle = mapLayer:IsBattleBackground();
	
	if isBattle then
		layer:SetVisible(false);
	end
	
	p.LoadRankUI();
end
