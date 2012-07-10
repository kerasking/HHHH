---------------------------------------------------
--描述: 竞技场结束奖励界面
--时间: 2012.4.13
--作者: cl

---------------------------------------------------
local _G = _G;

ArenaRewardUI={}
local p=ArenaRewardUI;

local ID_FIGHTEVALUATE_CTRL_BUTTON_PLAYBACK =71;
local ID_FIGHTEVALUATE_CTRL_BUTTON_CONFIRM =10;
local ID_FIGHTEVALUATE_CTRL_TEXT_INFO =9;
local ID_FIGHTEVALUATE_CTRL_PICTURE_STATE = 8;
local ID_FIGHTEVALUATE_CTRL_PICTURE_7=7;

function p.LoadUI()
	LogInfo("load,ArenaRewardUI");
	local scene=GetSMGameScene();
	if scene == nil then
		LogInfo("scene = nil,load ArenaRewardUI failed!");
		return;
	end
	local layer = createNDUILayer();
	if layer == nil then
		LogInfo("scene = nil,2");
		return  false;
	end
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.ArenaRewardUI);
	local winsize = GetWinSize();
	layer:SetFrameRect( CGRectMake(winsize.w * 0.18, winsize.h *0.28, winsize.w *0.63, winsize.h * 0.44));
	--layer:SetBackgroundColor(ccc4(125,125,125,125));
	scene:AddChild(layer);
	
	local uiLoad=createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		LogInfo("scene = nil,4");
		return false;
	end
	uiLoad:Load("FightEvaluate.ini",layer,p.OnUIEvent,0,0);
	uiLoad:Free();
end

function p.GetParent()
	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end
	
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.ArenaRewardUI);
	if nil == layer then
		return nil;
	end
	
	--local container = GetScrollViewContainer(layer, TAG_CONTAINER);
	return layer;
end

function p.SetResult(result,money,repute)
	local layer=p.GetParent();
	if nil==layer then
		return;
	end
	local bg=GetImage(layer,ID_FIGHTEVALUATE_CTRL_PICTURE_STATE);
	local pool = DefaultPicPool();
	if result ==1 then
		bg:SetPicture(pool:AddPicture(GetSMImgPath("word_success.png"), false),true);
	elseif result ==0 then
		bg:SetPicture(pool:AddPicture(GetSMImgPath("word_fail.png"), false),true);
	end
	
	local str="";

	if money > 0 then
		str="获得铜钱＋"..SafeN2S(money);
	end
	
	
	if repute > 0 then
		if money > 0 then
			str=str..",";
		end
		str=str.."获得声望+"..SafeN2S(repute);
	end
	
	SetLabel(layer,ID_FIGHTEVALUATE_CTRL_TEXT_INFO,str);
end


function p.OnUIEvent(uiNode,uiEventType,param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEvent[%d]",tag);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if ID_FIGHTEVALUATE_CTRL_BUTTON_CONFIRM == tag then
			local scene = GetSMGameScene();
			CloseBattle();
			if scene~= nil then
				scene:RemoveChildByTag(NMAINSCENECHILDTAG.ArenaRewardUI,true);
				return true;
			end

		elseif ID_FIGHTEVALUATE_CTRL_BUTTON_PLAYBACK == tag then
			restartLastBattle();
			local scene = GetSMGameScene();
			if scene~= nil then
				scene:RemoveChildByTag(NMAINSCENECHILDTAG.ArenaRewardUI,true);
				return true;
			end
		end
	end
end