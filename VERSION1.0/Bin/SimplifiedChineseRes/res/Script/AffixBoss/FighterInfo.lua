---------------------------------------------------
--描述: 战斗中查看交战者信息小窗口UI
--时间: 2012.7.3
--作者: Guosen
---------------------------------------------------
--战斗中创建查看信息窗口：		FighterInfo.LoadUI( iX, iY );

---------------------------------------------------
--设置名称绝技等级神马：		FighterInfo.SetFighterInfo( szName, szSkillName, nLevel );
--参数： szName:名称, szSkillName:绝技名, nLevel:等级

---------------------------------------------------
--FighterInfo.UpdateHp(hp,maxHp)
--FighterInfo.UpdateMp(mp,maxMp)
---------------------------------------------------
local _G = _G;

FighterInfo = {};
local p = FighterInfo;

---------------------------------------------------
local ID_BTN_CLOSE						= 5;	-- X
local ID_LABEL_ROLE_NAME				= 2;	-- 角色名空间ID
local ID_LABEL_SKILL_NAME				= 11;	-- 技能名控件ID
local ID_CTRL_BLOOD_BAR					= 14;	-- 血条
local ID_CTRL_MOMENTUM_BAR				= 15;	-- 气条


---------------------------------------------------
-- 获得ui指针
function p.GetFighterInfoUILayer()
	local scene = GetSMGameScene();
	if ( nil == scene ) then
		LogInfo( "FighterInfo: GetFighterInfoUILayer() failed! scene = nil" );
		return nil;
	end
	
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.FighterInfo);
	if ( nil == layer ) then
		LogInfo( "FighterInfo: GetFighterInfoUILayer() failed! layer = nil" );
		return nil;
	end

	return layer;
end

---------------------------------------------------
-- 事件响应
function p.OnUIEvent(uiNode,uiEventType,param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEvent[%d]",tag);
	if ( uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK ) then
		if ( ID_BTN_CLOSE == tag ) then
			local scene = GetSMGameScene();
			if ( scene~= nil ) then
				scene:RemoveChildByTag( NMAINSCENECHILDTAG.FighterInfo, true );
				return true;
			end
		end
	end
end

---------------------------------------------------
-- 创建信息窗口
function p.LoadUI(x,y)
	LogInfo( "FighterInfo: p.LoadUI()" );
	local scene=GetSMGameScene();
	if scene == nil then
		LogInfo( "FighterInfo: LoadUI() failed! scene = nil" );
		return;
	end
	local layer = createNDUILayer();
	if layer == nil then
		LogInfo( "FighterInfo: LoadUI() failed! layer = nil" );
		return  false;
	end
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.FighterInfo);
	local winsize = GetWinSize();
	if (x+winsize.w/2)>winsize.w then
		x=x-winsize.w/2;
	end
	
	if (y+winsize.h*0.4)>winsize.h then
		y=y-winsize.h*0.4;
	end
	
	layer:SetFrameRect( CGRectMake(x, y, winsize.w /2, winsize.h * 0.4));
	--layer:SetBackgroundColor(ccc4(125,125,125,125));
	scene:AddChild(layer);
	
	local uiLoad=createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		LogInfo( "FighterInfo: LoadUI() failed! uiLoad = nil" );
		return false;
	end
	uiLoad:Load("FighterInfoUI.ini",layer,p.OnUIEvent,0,0);
	uiLoad:Free();
end

---------------------------------------------------
-- 关闭信息窗口
function p.CloseFighterInfo()
	local scene = GetSMGameScene();
	if ( scene~= nil ) then
		scene:RemoveChildByTag(NMAINSCENECHILDTAG.FighterInfo,true);
		return true;
	end
end

---------------------------------------------------
-- 更新生命值进度条
function p.UpdateHp(hp,maxHp)
	local layer=p.GetFighterInfoUILayer();
	if nil==layer then
		return false;
	end
	local lifeBar = RecursivUIExp(layer, {ID_CTRL_BLOOD_BAR} );
	if CheckP(lifeBar) then
		--LogInfo("setBossHP:%d/%d",currentlife,totalLife);
		lifeBar:SetProcess(hp);
		-- todo
		lifeBar:SetTotal(maxHp);
	else
		LogInfo("lifeBar not find");
	end
    
    
    if( ArenaUI.isInChallenge == 3 and maxHp >= 24000000 and MsgBossBattle.TempCurLift >= 24000000) then
        lifeBar:SetProcess(MsgBossBattle.TempMaxLift/24000000.0 * hp);
        -- todo
        lifeBar:SetTotal(MsgBossBattle.TempMaxLift);
        
    else
        lifeBar:SetProcess(hp);
        -- todo
        lifeBar:SetTotal(maxHp);
    end
    
    
    
end

---------------------------------------------------
-- 更新魔法值进度条
function p.UpdateMp(mp,maxMp)
	local layer=p.GetFighterInfoUILayer();
	if nil==layer then
		return false;
	end
	local manaBar = RecursivUIExp(layer, {ID_CTRL_MOMENTUM_BAR} );
	if CheckP(manaBar) then
		--LogInfo("setBossHP:%d/%d",currentlife,totalLife);
		manaBar:SetProcess(mp);
		-- todo
		manaBar:SetTotal(maxMp);
	else
		LogInfo("manaBar not find");
	end
end

---------------------------------------------------
-- 设置信息，名称，技能，等级
function p.SetFighterInfo( szName, szSkillName, nLevel )
	local pLayer = p.GetFighterInfoUILayer();
	if ( nil == pLayer ) then
		LogInfo( "FighterInfo: SetFighterInfo() failed! pLayer = nil" );
		return false;
	end
	nLevel = nLevel or 1;
	SetLabel( pLayer, ID_LABEL_ROLE_NAME, szName .. "("..nLevel..GetTxtPub("Level")..")" );
	SetLabel( pLayer, ID_LABEL_SKILL_NAME, szSkillName );
	return true;
end