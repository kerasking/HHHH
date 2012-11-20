---------------------------------------------------
--描述: 战斗界面的控件处理层
--时间: 2012.8.16
--作者: tzq
---------------------------------------------------
BattleMapCtrl = {}
local p = BattleMapCtrl;


local CTRL_BTN_1  = 1;        --速战速决
RectFastBtn = CGRectMake(0,  0, 88*ScaleFactor, 27*ScaleFactor);  
RectLayer = CGRectMake(196*ScaleFactor, 285*ScaleFactor, 88*ScaleFactor, 27*ScaleFactor);  --速战速决按钮


--加载战斗页面控件层
function p.LoadUI()
    
    CampBattle.SetBattle();
    --boss战不使用快速战斗
    if ArenaUI.isInChallenge == 3 or
        ArenaUI.isInChallenge == 5 then
        return;
    end
    
    --首先判断是否已经开启快速战斗vip功能
   if not GetVipIsOpen(DB_VIP_CONFIG.BATTLE_FAST_FLAG) then 
       return;
    end

    LogInfo("BattleMapCtrl function p.LoadUI()");  
    --------------------获得游戏主场景------------------------------------------
    local scene = GetSMGameScene();	
	if scene == nil then
		return;
	end
    
    --------------------添加页面控件层---------------------------------------
    local layer = createNDUILayer();
	if layer == nil then
		return false;
	end
    
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.BattleMapCtrl);
	layer:SetFrameRect(RectLayer);
	scene:AddChildZ(layer,1);

    LogInfo("BattleMapCtrl function p.LoadUI()");  
    -----------------初始化ui添加到 layer 层上---------------------------------
    local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end

	uiLoad:Load("BattleMapCtrl.ini", layer, p.OnUIEvent, 0, 0);
    LogInfo("BattleMapCtrl function p.LoadUI()");  
    
    
    local btnFastBattle = GetButton(layer, CTRL_BTN_1);
    btnFastBattle:SetFrameRect(RectFastBtn);
    
    return true;
end

-----------------------------UI层的事件处理---------------------------------
function p.OnUIEvent(uiNode, uiEventType, param)

    local tag = uiNode:GetTag();
    LogInfo("tzq p.OnUIEvent tag = %d, uiEventType = %d", tag, uiEventType);  
    
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
        if CTRL_BTN_1 == tag then                 --速战速决            
            LogInfo("tzq hit in suzhansujue");  
            FinishBattle();      
			--CloseUI(NMAINSCENECHILDTAG.DragonTactic);
        end  
    end
    
	return true;
end

function p.CloseUI()
        if IsUIShow(NMAINSCENECHILDTAG.BattleMapCtrl) then
            CloseUI(NMAINSCENECHILDTAG.BattleMapCtrl);
        end
end


