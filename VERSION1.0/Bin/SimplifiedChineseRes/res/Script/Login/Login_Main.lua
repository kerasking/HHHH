---------------------------------------------------
--描述: 登陆主界面
--时间: 2012.4.11
--作者: HJQ
---------------------------------------------------
local ID_LOGIN_MAIN_CTRL_PICTURE_27					= 27;
local ID_LOGIN_MAIN_CTRL_BUTTON_26					= 26;--登陆
local ID_LOGIN_MAIN_CTRL_BUTTON_25					= 25;--选择账号
local ID_LOGIN_MAIN_CTRL_INPUT_BUTTON_24			= 24;--输入密码
local ID_LOGIN_MAIN_CTRL_PICTURE_23					= 23;
local ID_LOGIN_MAIN_CTRL_PICTURE_22					= 22;
local ID_LOGIN_MAIN_CTRL_INPUT_BUTTON_21			= 21;--输入账号

Login_Main={}
local p = Login_Main;

p.Login_Account=nil;
p.Login_Pwd=nil;

function p.LoadUI()
   local scene = GetSMLoginScene();
    if scene == nil then
        LogInfo("scene == nil,load Login_Main failed!");
        return false;
    end

    scene:RemoveAllChildren(true);
    local layer = createNDUILayer();
    if layer == nil then
        return false;
    end
    layer:Init();
    layer:SetTag(NMAINSCENECHILDTAG.Login_MainUI);
    layer:SetFrameRect(RectFullScreenUILayer);
    layer:SetBackgroundColor(ccc4(125, 125, 125, 125));
    scene:AddChild(layer);

    --初始化ui
    local uiLoad = createNDUILoad();
    if nil == uiLoad then
        layer:Free();
        return false;
    end

    uiLoad:Load("Login_Main.ini", layer, p.OnUIEvent, 0, 0);--选择服务器
    uiLoad:Free();

    p.Init();
    p.Refresh();
    return true;
end

function p.Init()
    local layer = p.getUiLayer();
    local pNameEditUiNode = RecursiveUINode(layer,{ID_LOGIN_MAIN_CTRL_INPUT_BUTTON_21});
    local pNameEdit = ConverToEdit(pNameEditUiNode);
    if not CheckP(pNameEdit) then
        return false;
    end
    pNameEdit:SetMaxLength(12);

    local pPwdEditUiNode = RecursiveUINode(layer,{ID_LOGIN_MAIN_CTRL_INPUT_BUTTON_24});
    local pPwdEdit = ConverToEdit(pPwdEditUiNode);
    if not CheckP(pPwdEdit) then
        return false;
    end
    pPwdEdit:SetPassword(true);
    pPwdEdit:SetMaxLength(12);
    
    local pLoginBtnUiNode = RecursiveUINode(layer,{ID_LOGIN_MAIN_CTRL_BUTTON_26});
    local pLoginBtn = ConverToButton(pLoginBtnUiNode);
    if not CheckP(pLoginBtn) then
        return false;
    end

    --判断是否存在登陆过的帐号，如果有，则在输入框中显示最后登陆的帐号和密码，否则聚焦到帐号输入框
    local nActNum = GetAccountListNum();
    if nActNum > 0 then
        pNameEdit:SetText(GetRecAccountNameByIdx(nActNum-1));
        pPwdEdit:SetText(GetRecAccountPwdByIdx(nActNum-1));
        p.Login_Account=pNameEdit:GetText();
        p.Login_Pwd=pPwdEdit:GetText();
        layer:SetFocus(pLoginBtnUiNode);
    else
        layer:SetFocus(pNameEditUiNode);
    end
end


function p.getUiLayer()
    local scene = GetSMLoginScene();
    if not CheckP(scene) then
        return nil;
    end

    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.Login_MainUI);
    if not CheckP(layer) then
        LogInfo("nil == layer")
        return nil;
    end
    return layer;
end

function p.Refresh()
end

function p.OnUIEvent(uiNode, uiEventType, param)
    local tag = uiNode:GetTag();
    if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
        if tag == ID_LOGIN_MAIN_CTRL_BUTTON_26 then
            if p.Login_Account == nil or p.Login_Pwd == nil then
                return false;
            end
            Login_ServerUI.LoadUI( p.Login_Account,p.Login_Pwd);
        elseif tag == ID_LOGIN_MAIN_CTRL_BUTTON_25 then
            Login_ActAndServerUI.LoadUI();
        else
            return false;
        end
    elseif uiEventType == NUIEventType.TE_TOUCH_TABLE_FOCUS then
    elseif uiEventType == NUIEventType.TE_TOUCH_EDIT_INPUT_FINISH then
        -- 用户按下键盘的返回键
        local edit = ConverToEdit(uiNode);
        if CheckP(edit) then
            if tag == ID_LOGIN_MAIN_CTRL_INPUT_BUTTON_21 then
                p.Login_Account = edit:GetText();
            elseif tag == ID_LOGIN_MAIN_CTRL_INPUT_BUTTON_24 then
                p.Login_Pwd = edit:GetText();
            end 
        end
    elseif uiEventType == NUIEventType.TE_TOUCH_EDIT_TEXT_CHANGE then
    end
    return true;
end
