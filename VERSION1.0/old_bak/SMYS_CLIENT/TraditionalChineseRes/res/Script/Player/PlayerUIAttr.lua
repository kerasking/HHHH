---------------------------------------------------
--描述: 玩家属性UI
--时间: 2012.2.1
--作者: jhzheng
---------------------------------------------------

PlayerUIAttr = {}
local p = PlayerUIAttr;

local ID_ROLEATTR_CTRL_BUTTON_CLOSE				= 71;
local ID_ROLEATTR_CTRL_TEXT_FIGHTING				= 70;
local ID_ROLEATTR_CTRL_TEXT_69					= 69;
local ID_ROLEATTR_CTRL_TEXT_KILL					= 68;
local ID_ROLEATTR_CTRL_TEXT_67					= 67;
local ID_ROLEATTR_CTRL_TEXT_BLOCK					= 66;
local ID_ROLEATTR_CTRL_TEXT_65					= 65;
local ID_ROLEATTR_CTRL_TEXT_WRECK					= 64;
local ID_ROLEATTR_CTRL_TEXT_63					= 63;
local ID_ROLEATTR_CTRL_TEXT_DODGE					= 62;
local ID_ROLEATTR_CTRL_TEXT_61					= 61;
local ID_ROLEATTR_CTRL_TEXT_HIT					= 60;
local ID_ROLEATTR_CTRL_TEXT_59					= 59;
local ID_ROLEATTR_CTRL_TEXT_TENACITY				= 58;
local ID_ROLEATTR_CTRL_TEXT_57					= 57;
local ID_ROLEATTR_CTRL_TEXT_CRIT					= 56;
local ID_ROLEATTR_CTRL_TEXT_55					= 55;
local ID_ROLEATTR_CTRL_TEXT_MAGIC_DEFENSE			= 54;
local ID_ROLEATTR_CTRL_TEXT_MAGIC_53				= 53;
local ID_ROLEATTR_CTRL_TEXT_MAGIC_ATTACK			= 52;
local ID_ROLEATTR_CTRL_TEXT_51					= 51;
local ID_ROLEATTR_CTRL_TEXT_STUNT_DEFENSE			= 50;
local ID_ROLEATTR_CTRL_TEXT_49					= 49;
local ID_ROLEATTR_CTRL_TEXT_STUNT_ATTACK			= 48;
local ID_ROLEATTR_CTRL_TEXT_47					= 47;
local ID_ROLEATTR_CTRL_TEXT_NORMAL_DEFENSE		= 46;
local ID_ROLEATTR_CTRL_TEXT_45					= 45;
local ID_ROLEATTR_CTRL_TEXT_NORMAL_ATTACK			= 44;
local ID_ROLEATTR_CTRL_TEXT_43					= 43;
local ID_ROLEATTR_CTRL_TEXT_ROLE_LIFE				= 42;
local ID_ROLEATTR_CTRL_TEXT_41					= 41;
local ID_ROLEATTR_CTRL_TEXT_LEVEL					= 40;
local ID_ROLEATTR_CTRL_TEXT_39					= 39;
local ID_ROLEATTR_CTRL_TEXT_SKILLNAME				= 38;
local ID_ROLEATTR_CTRL_TEXT_37					= 37;
local ID_ROLEATTR_CTRL_TEXT_WORK					= 36;
local ID_ROLEATTR_CTRL_TEXT_35					= 35;
local ID_ROLEATTR_CTRL_TEXT_NAME					= 34;
local ID_ROLEATTR_CTRL_TEXT_33					= 33;
local ID_ROLEATTR_CTRL_BUTTON_ROLE_ICON			= 32;
local ID_ROLEATTR_CTRL_BUTTON_LEAVE				= 30;
local ID_ROLEATTR_CTRL_BUTTON_PILL				= 29;
local ID_ROLEATTR_CTRL_BUTTON_TRAIN				= 28;
local ID_ROLEATTR_CTRL_TEXT_MAGIC					= 27;
local ID_ROLEATTR_CTRL_TEXT_26					= 26;
local ID_ROLEATTR_CTRL_TEXT_SKILL					= 25;
local ID_ROLEATTR_CTRL_TEXT_24					= 24;
local ID_ROLEATTR_CTRL_TEXT_ABILITY				= 23;
local ID_ROLEATTR_CTRL_TEXT_22					= 22;
local ID_ROLEATTR_CTRL_TEXT_LIFE					= 21;
local ID_ROLEATTR_CTRL_TEXT_20					= 20;
local ID_ROLEATTR_CTRL_TEXT_FORCE					= 19;
local ID_ROLEATTR_CTRL_TEXT_18					= 18;
local ID_ROLEATTR_CTRL_TEXT_JOB					= 17;
local ID_ROLEATTR_CTRL_TEXT_16					= 16;
local ID_ROLEATTR_CTRL_TEXT_EXPERIENCE			= 15;
local ID_ROLEATTR_CTRL_TEXT_14					= 14;
local ID_ROLEATTR_CTRL_BUTTON_INHERIT				= 13;
local ID_ROLEATTR_CTRL_BUTTON_SHOES				= 12;
local ID_ROLEATTR_CTRL_BUTTON_DRESS				= 11;
local ID_ROLEATTR_CTRL_BUTTON_HELMET				= 10;
local ID_ROLEATTR_CTRL_BUTTON_ROLE_IMAGE			= 9;
local ID_ROLEATTR_CTRL_BUTTON_WEAPON				= 8;
local ID_ROLEATTR_CTRL_BUTTON_AMULET				= 7;
local ID_ROLEATTR_CTRL_BUTTON_SOUL				= 6;
local ID_ROLEATTR_CTRL_TEXT_SHOW					= 3;
local ID_ROLEATTR_CTRL_BUTTON_1					= 1;
local ID_ROLEATTR_CTRL_PICTURE_5					= 5;
local ID_ROLEATTR_CTRL_PICTURE_31					= 31;

function p.LoadUI()
	local scene = Scene();
	if scene == nil then
		return false;
	end
	
	local layer = createNDUILayer();
	if layer == nil then
		return false;
	end

	--初始化ui
	local rectLayer = CGRectMake(0, 0, 480, 320);
	layer:Init();
	layer:SetFrameRect(rectLayer);
	LogInfo("ready for scene:AddChild(layer);");
	scene:AddChild(layer);
	
	local uiLoad = createNDUILoad();
	uiLoad:Load("RoleAttr.ini", layer, p.OnUIEvent, 0, 0);
	uiLoad:Free();	

	local director = DefaultDirector();
	director:PushScene(scene, false);

	return true;
end

function p.OnUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEvent[%d]", tag);
	if uiEventType == NUIEvent_Type.TE_TOUCH_BTN_CLICK then
		if ID_ROLEATTR_CTRL_BUTTON_CLOSE == tag then
			local director = DefaultDirector();
			if director ~= nil then
				director:PopScene(true);
			end
		end
	elseif uiEventType == NUIEvent_Type.TE_TOUCH_TABLE_FOCUS then
	end
	return true;
end