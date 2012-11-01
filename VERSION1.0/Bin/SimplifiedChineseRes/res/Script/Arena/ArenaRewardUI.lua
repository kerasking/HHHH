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
--NMAINSCENECHILDTAG.ArenaRewardUI=96890;

function p.LoadUI()
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
	local ui_size=186*ScaleFactor;
	layer:SetFrameRect(CGRectMake(0, 0, winsize.w, winsize.h));
	--layer:SetBackgroundColor(ccc4(125,125,125,125));
	scene:AddChildZ(layer,1);
	--_G.AddChild(scene, layer, NMAINSCENECHILDTAG.ArenaRewardUI);
		
        
	local uiLoad=createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		LogInfo("scene = nil,4");
		return false;
	end
	uiLoad:Load("SM_FIGHT_RESULT.ini",layer,p.OnUIEvent,0,0);
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
    LogInfo("+++++++++++result[%d]+++++++++++",result);
    local layer=p.GetParent();
    if nil==layer then
        return;
    end
    local bg=GetImage(layer,ID_FIGHTEVALUATE_CTRL_PICTURE_STATE);
    local pool = DefaultPicPool();
    
    local str="";
    
    if result ==1 then             
        bg:SetPicture(pool:AddPicture(GetSMImgPath("battle/battle_icon4.png"), false), true);
        str = "强者为尊应让我，英雄只此敢争先.";
        SetLabel(layer,ID_FIGHTEVALUATE_CTRL_PICTURE_7,str);

        Music.PlayEffectSound(1094);

    elseif result ==0 then    
      bg:SetPicture(pool:AddPicture(GetSMImgPath("battle/battle_icon5.png"), false),true);
      str = "虽败犹荣望天叹,血染钢刀不回头.";
      SetLabel(layer,ID_FIGHTEVALUATE_CTRL_PICTURE_7,str);

      Music.PlayEffectSound(1093);

    elseif resule ==3 then
    
    end

    str="";

    if money > 0 then
        str="获得银币＋"..SafeN2S(money);
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
    --LogInfo("p.OnUIEvent[%d]",tag);
    if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
        if ID_FIGHTEVALUATE_CTRL_BUTTON_CONFIRM == tag then
         LogInfo("p.OnUIEvent111111[%d]",tag);
            local scene = GetSMGameScene();
            CloseBattle();
        if scene~= nil then
            --local layer = GetUiLayer(scene,NMAINSCENECHILDTAG.ArenaRewardUI);
            --layer:SetVisible(false);
            scene:RemoveChildByTag(NMAINSCENECHILDTAG.ArenaRewardUI,true);
            return true;
        end

    elseif ID_FIGHTEVALUATE_CTRL_BUTTON_PLAYBACK == tag then
            LogInfo("p.OnUIEvent111111[%d]",tag);
            restartLastBattle();
        local scene = GetSMGameScene();
        if scene~= nil then
            --local layer = GetUiLayer(scene,NMAINSCENECHILDTAG.ArenaRewardUI);
            --layer:SetVisible(false);
            scene:RemoveChildByTag(NMAINSCENECHILDTAG.ArenaRewardUI,true);
            return true;
            end
        end
    end
end