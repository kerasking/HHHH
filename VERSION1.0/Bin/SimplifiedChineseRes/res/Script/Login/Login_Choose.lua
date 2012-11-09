---------------------------------------------------
--描述: 选择登陆模式
--时间: 2012.6.30
--作者: chh
---------------------------------------------------


Login_Choose={}
local p = Login_Choose;

local TAG_BEGIN_GAME        = 1;--开始游戏Btn
local TAG_CHANGE_ACCOUNT    = 2;--更换帐号Btn


function p.LoadUI()
    local scene = GetSMLoginScene();
    if scene == nil then
        LogInfo("scene == nil,load Login_Choose failed!");
        return false;
    end

    scene:RemoveAllChildren(true);
    local layer = createNDUILayer();
    if layer == nil then
        return false;
    end
    

	
	
    layer:Init();
    layer:SetTag(NMAINSCENECHILDTAG.Login_Choose);
    layer:SetFrameRect(RectFullScreenUILayer);
    scene:AddChild(layer);

    --初始化ui
    local uiLoad = createNDUILoad();
    if nil == uiLoad then
        layer:Free();
        return false;
    end

    uiLoad:Load("login_1.ini", layer, p.OnUIEvent, 0, 0);
    uiLoad:Free();
    
    return true;
end

function p.getUiLayer()
    local scene = GetSMLoginScene();
    if not CheckP(scene) then
        return nil;
    end

    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.Login_Choose);
    if not CheckP(layer) then
        LogInfo("nil == layer")
        return nil;
    end
    return layer;
end

function p.OnUIEvent(uiNode, uiEventType, param)
    local tag = uiNode:GetTag();
    if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
        if tag == TAG_BEGIN_GAME then
            
            local nActNum = GetAccountListNum();
            if nActNum > 0 then
                Login_ServerUI.LoadUI( GetRecAccountNameByIdx(0),GetRecAccountPwdByIdx(0));
            else
                Login_Main.LoadUI();
            end
            
        elseif tag == TAG_CHANGE_ACCOUNT then
            
            Login_Main.LoadUI();
            
        else
            return false;
        end
    end
    return true;
end
--RegisterGlobalEventHandler(GLOBALEVENT.GE_LOGIN_GAME,"Login_Choose.LoadUI", p.LoadUI);