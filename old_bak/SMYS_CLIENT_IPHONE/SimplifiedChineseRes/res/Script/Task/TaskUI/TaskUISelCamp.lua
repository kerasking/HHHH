---------------------------------------------------
--描述: 玩家任务选择阵营UI
--时间: 2012.4.9
--作者: jhzheng
---------------------------------------------------
TaskUISelCamp = {}

local p = TaskUISelCamp;

local ID_FACTION_CTRL_BUTTON_CLOSE					= 13;
local ID_FACTION_CTRL_BUTTON_JOIN_HQ				= 12;
local ID_FACTION_CTRL_BUTTON_JOIN_YH				= 11;
local ID_FACTION_CTRL_PICTURE_HQ_BG					= 10;
local ID_FACTION_CTRL_PICTURE_YH_BG					= 9;
local ID_FACTION_CTRL_PICTURE_8						= 8;
local ID_FACTION_CTRL_PICTURE_7						= 7;
local ID_FACTION_CTRL_PICTURE_6						= 6;
local ID_FACTION_CTRL_PICTURE_5						= 5;
local ID_FACTION_CTRL_PICTURE_4						= 4;
local ID_FACTION_CTRL_PICTURE_TITLE					= 3;
local ID_FACTION_CTRL_PICTURE_TITLE_BG				= 2;
local ID_FACTION_CTRL_PICTURE_FACTION_BG			= 1;

function p.LoadUI()
	local scene = GetSMGameScene();
	if nil == scene then
		LogInfo("scene == nil,load TaskUISelCamp failed!");
		return;
	end
	
	local layer = createNDUILayer();
	if layer == nil then
		return false;
	end
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.TASKUISELCAMP);
	layer:SetFrameRect(RectUILayer);
	scene:AddChild(layer);

	--初始化ui
	local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end
	uiLoad:Load("Faction.ini", layer, p.OnMainUIEvent, 0, 0);
	uiLoad:Free();
end

function p.OnMainUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnMainUIEvent[%d]", tag);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if ID_FACTION_CTRL_BUTTON_CLOSE == tag then
			local scene = GetSMGameScene();
			if scene ~= nil then
				scene:RemoveChildByTag(NMAINSCENECHILDTAG.TASKUISELCAMP, true);
				return true;
			end
		elseif ID_FACTION_CTRL_BUTTON_JOIN_YH == tag then
			p.SendSelCamp(CAMP_TYPE.YU_HUA);
		elseif ID_FACTION_CTRL_BUTTON_JOIN_HQ == tag then
			p.SendSelCamp(CAMP_TYPE.HUANG_QUAN);
		end
	elseif uiEventType == NUIEventType.TE_TOUCH_CHECK_CLICK then
		
	end
	return true;
end

function p.SendSelCamp(nCamp)
	if not CheckN(nCamp) then
		return;
	end
	
	local netdata = createNDTransData(NMSG_Type._MSG_CHOOSE_CAMP);
	if nil == netdata then
		LogInfo("发送p.SendSelCamp,内存不够");
		return false;
	end
	netdata:WriteByte(nCamp);
	SendMsg(netdata);
	netdata:Free();
	CloseMainUI();
end