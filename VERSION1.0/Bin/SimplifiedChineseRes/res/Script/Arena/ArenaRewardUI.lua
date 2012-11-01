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

function p.ReviveCallback(nEventType, param)
    if(CommonDlgNew.BtnOk == nEventType) then
        p.CloseBattle();
    end
end

--大乱斗胜利
function p.ReviveCallbackCampBattleSucc(nEventType, param)
    if(CommonDlgNew.BtnOk == nEventType) then
    	CampBattle.AutoJoinNextBattle();
        p.CloseBattle();
		        
    end
end

--大乱斗失败
function p.ReviveCallbackCampBattleFail(nEventType, param)
    if(CommonDlgNew.BtnOk == nEventType) then
    	CampBattle.FailInBattle();
        p.CloseBattle();		        
    end
end

--local nTag

function p.SetResult(result,money,repute)

    if( ArenaUI.isInChallenge == 3 ) then   --boss战 战斗结算
        local layer=p.GetParent();
        if layer then
            layer:SetVisible(false);
        end
        
        local str = nil;
        if result ==1 then --胜利
            str = string.format("你消灭了boss, 获得银币: %d, 获得将魂: %d", money, repute);
            Music.PlayEffectSound(1094);
        elseif result ==0 then --失败
            str = string.format("战斗失败, 获得银币: %d, 获得将魂: %d", money, repute);
            Music.PlayEffectSound(1093);
        end
        CommonDlgNew.ShowYesDlg(str, p.ReviveCallback, nil, 5);
    elseif  ArenaUI.isInChallenge == 5 then
        local layer=p.GetParent();
        if layer then
            layer:SetVisible(false);
        end
        
        local str = nil;
        if result ==1 then --胜利
            str = string.format("你获胜了, 获得银币: %d, 获得声望: %d", money, repute);
            Music.PlayEffectSound(1094);
        elseif result ==0 then --失败
            str = string.format("战斗失败, 获得银币: %d, 获得声望: %d", money, repute);
            Music.PlayEffectSound(1093);
        end
        
        --if CampBattle.IsAutoFight() then
        --	CommonDlgNew.ShowYesDlg(str, p.ReviveCallback, nil, 3);  
        --else
        --	CommonDlgNew.ShowYesDlg(str, p.ReviveCallback, nil,3);  	 
        --end
        if result == 1 then
        	CommonDlgNew.ShowYesDlg(str, p.ReviveCallbackCampBattleSucc, nil,3);
        else
        	CommonDlgNew.ShowYesDlg(str, p.ReviveCallbackCampBattleFail, nil,3);
        end
    else
        LogInfo("+++++++++++result[%d]+++++++++++",result);
        local layer=p.GetParent();
        if nil==layer then
            return;
        end
        local bg=GetImage(layer,ID_FIGHTEVALUATE_CTRL_PICTURE_STATE);
        local pool = DefaultPicPool();
        
        local str="";
        
        if result ==1 then         
            if ArenaUI.isInChallenge == 1 then    
                bg:SetPicture(pool:AddPicture(GetSMImgPath("battle/battle_icon4.png"), false), true);
            elseif ArenaUI.isInChallenge == 2 then
                bg:SetPicture(pool:AddPicture(GetSMImgPath("transport/icon_transport3.png"), false), true);
            end
            str = "强者为尊应让我，英雄只此敢争先.";
            SetLabel(layer,ID_FIGHTEVALUATE_CTRL_PICTURE_7,str);
            
            Music.PlayEffectSound(1094);

        elseif result ==0 then   
          if ArenaUI.isInChallenge == 1 then    
                bg:SetPicture(pool:AddPicture(GetSMImgPath("battle/battle_icon5.png"), false),true);
          elseif  ArenaUI.isInChallenge == 2 then
                bg:SetPicture(pool:AddPicture(GetSMImgPath("transport/icon_transport4.png"), false), true);
          end
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
                str=str.."\n";
            end
        
            if ArenaUI.isInChallenge == 1 then
                str=str.."获得声望+"..SafeN2S(repute);
            elseif ArenaUI.isInChallenge == 2 then 
                str=str..ItemFunc.GetName(repute).."X1";
            end
        end
        
        SetLabel(layer,ID_FIGHTEVALUATE_CTRL_TEXT_INFO,str);
    
    end



    
end

function p.CloseBattle()
    local scene = GetSMGameScene();
    CloseBattle();
    if scene~= nil then
        scene:RemoveChildByTag(NMAINSCENECHILDTAG.ArenaRewardUI,true);
        return true;
    end
end


function p.OnUIEvent(uiNode,uiEventType,param)
    local tag = uiNode:GetTag();
    --LogInfo("p.OnUIEvent[%d]",tag);
    if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
        if ID_FIGHTEVALUATE_CTRL_BUTTON_CONFIRM == tag then
            LogInfo("on event tag = %d",tag);
            p.CloseBattle();


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
    return true;
end