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
	scene:AddChildZ(layer,2);
	--_G.AddChild(scene, layer, NMAINSCENECHILDTAG.ArenaRewardUI);
		
        
	local uiLoad=createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		LogInfo("scene = nil,4");
		return false;
	end
    if  ArenaUI.isInChallenge == 8 then
    	-- 古迹寻宝
		--uiLoad:Load("Treasure/FightResult.ini",layer,p.OnUIEvent,0,0);
		--local ID_LIST_CONTAINER = 9;
		--local pScrollViewContainer = GetScrollViewContainer( layer, ID_LIST_CONTAINER );
		uiLoad:Load("SM_FIGHT_RESULT.ini",layer,p.OnUIEvent,0,0);
		local pLabel	= GetLabel( layer, ID_FIGHTEVALUATE_CTRL_TEXT_INFO );
		local szPrize	= MsgTreasureHunt.GetPrizeString()
		pLabel:SetText( szPrize );
    else
		uiLoad:Load("SM_FIGHT_RESULT.ini",layer,p.OnUIEvent,0,0);
	end
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

--军团战胜利
function p.ReviveCallbackArmyBattleSucc(nEventType, param)
    if(CommonDlgNew.BtnOk == nEventType) then
    	SyndicateBattleUI.AutoJoinNextBattle();
        p.CloseBattle();
    end
end

--军团战失败
function p.ReviveCallbackArmyBattleFail(nEventType, param)
    if(CommonDlgNew.BtnOk == nEventType) then
    	SyndicateBattleUI.FailInBattle();
        p.CloseBattle();	        
    end
end



--斗地主战结束
function p.ReviveCallbackLandlords(nEventType, param)
    if(CommonDlgNew.BtnOk == nEventType) then
		p.CloseBattle();
		Slave.EndBattleNotify();
    end
end



--local nTag

function p.SetResult(result,money,repute,soph,emoney)

    if( ArenaUI.isInChallenge == 3 ) then   --boss战 战斗结算
        local layer=p.GetParent();
        if layer then
            layer:SetVisible(false);
        end
        LogInfo("repute:[%d]",repute);
        local str = nil;
        if result ==1 then --胜利
            if(repute>0) then
                str = string.format(GetTxtPri("ARU2_T1"), money, ItemFunc.GetName(repute));
            else
                str = string.format(GetTxtPri("ARU2_T2"), money,soph);
            end
            
            Music.PlayEffectSound(1094);
        elseif result ==0 then --失败
            
            if(repute>0) then
                str = string.format(GetTxtPri("ARU2_T3"), money, ItemFunc.GetName(repute));
            else
                str = string.format(GetTxtPri("ARU2_T4"), money);
            end
            
            
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
            if(money>0) then
                 str = string.format(GetTxtPri("ARU2_T5"), repute, ItemFunc.GetName(money));
            else
                 str = string.format(GetTxtPri("ARU2_T511"), repute);               
            end
            
            Music.PlayEffectSound(1094);
        elseif result ==0 then --失败
            if(money>0) then
                str = string.format(GetTxtPri("ARU2_T6"), repute, ItemFunc.GetName(money));
            else
                str = string.format(GetTxtPri("ARU2_T611"), repute);               
            end
            Music.PlayEffectSound(1093);
        end
        

        if result == 1 then
        	CommonDlgNew.ShowYesDlg(str, p.ReviveCallbackCampBattleSucc, nil,3);
        else
        	CommonDlgNew.ShowYesDlg(str, p.ReviveCallbackCampBattleFail, nil,3);
        end
    
    elseif  ArenaUI.isInChallenge == 6 then
    --军团战
        local layer=p.GetParent();
        if layer then
            layer:SetVisible(false);
        end
        
        local str = nil;
        if result ==1 then --胜利
            str = string.format(GetTxtPri("ARU2_T7"));
            Music.PlayEffectSound(1094);
        elseif result ==0 then --失败
            str = string.format(GetTxtPri("ARU2_T8"));
            Music.PlayEffectSound(1093);
        end
        
        if result == 1 then
        	CommonDlgNew.ShowYesDlg(str, p.ReviveCallbackArmyBattleSucc, nil,3);
        else
        	CommonDlgNew.ShowYesDlg(str, p.ReviveCallbackArmyBattleFail, nil,3);
        end
        
                

    elseif  ArenaUI.isInChallenge == 8 then
		-- 古迹寻宝
        local layer	= p.GetParent();
        if nil == layer then
            return;
        end
        local bg	= GetImage(layer,ID_FIGHTEVALUATE_CTRL_PICTURE_STATE);
        local pool	= DefaultPicPool();
		if result ==1 then --战斗胜利
			bg:SetPicture(pool:AddPicture(GetSMImgPath("battle/battle_icon3.png"), false), true);
		elseif result ==0 then --战斗失败
			bg:SetPicture(pool:AddPicture(GetSMImgPath("battle/battle_icon2.png"), false), true);
		end

    elseif 7 == ArenaUI.isInChallenge then
    --斗地主
       local layer=p.GetParent();
        if layer then
            layer:SetVisible(false);
        end
        
        local str = nil;
        if result ==1 then --胜利
            str = string.format(GetTxtPri("ARU2_T7"));
            Music.PlayEffectSound(1094);
        elseif result ==0 then --失败
            str = string.format(GetTxtPri("ARU2_T8"));
            Music.PlayEffectSound(1093);
        end
        
        CommonDlgNew.ShowYesDlg(str, p.ReviveCallbackLandlords, nil,3);
 
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
                bg:SetPicture(pool:AddPicture(GetSMImg00Path("battle/battle_icon4.png"), false), true);
            elseif ArenaUI.isInChallenge == 2 then
                bg:SetPicture(pool:AddPicture(GetSMImg00Path("transport/icon_transport3.png"), false), true);
            end
            str = GetTxtPri("ARU_T1");
            SetLabel(layer,ID_FIGHTEVALUATE_CTRL_PICTURE_7,str);
            
            Music.PlayEffectSound(1094);

        elseif result ==0 then   
          if ArenaUI.isInChallenge == 1 then    
                bg:SetPicture(pool:AddPicture(GetSMImg00Path("battle/battle_icon5.png"), false),true);
          elseif  ArenaUI.isInChallenge == 2 then
                bg:SetPicture(pool:AddPicture(GetSMImg00Path("transport/icon_transport4.png"), false), true);
          end
          str = GetTxtPri("ARU_T2");
          SetLabel(layer,ID_FIGHTEVALUATE_CTRL_PICTURE_7,str);

          Music.PlayEffectSound(1093);

        elseif resule ==3 then
        
        end

        str="";

        if money > 0 then
            str=GetTxtPri("ARU_T3")..SafeN2S(money);
        end

        if repute > 0 then
            if money > 0 then
                str=str.."\n";
            end
        
            if ArenaUI.isInChallenge == 1 then
                str=str..GetTxtPri("ARU_T4")..SafeN2S(repute);
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
	BattleUI_Title.CloseUI();--
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