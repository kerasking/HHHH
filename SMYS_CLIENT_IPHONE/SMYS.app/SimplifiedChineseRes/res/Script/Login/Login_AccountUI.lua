---------------------------------------------------
--描述: 帐号录入登陆界面
--时间: 2012.3.25
--作者: HJQ
---------------------------------------------------

Login_AccountUI = {}
local p = Login_AccountUI;

local ID_ACCOUNTUI_LOGIN            = 29;--登陆
local ID_ACCOUNTUI_SAVEPWD          = 23;--保存密码checkbox
local ID_ACCOUNTUI_ACT_SERVERSEL    = 30;--帐号和服务器选择界面
local ID_ACCOUNTUI_TIP              = 20;--提示信息标签
local ID_ACCOUNTUI_INPUT_ACCOUNT    = 87;--帐号输入框
local ID_ACCOUNTUI_INPUT_PWD        = 88;--密码输入框

function p.LoadUI()
    local scene = GetSMLoginScene();
        if scene == nil then
            LogInfo("scene == nil,load Login_AccountUI failed!");
            return false;
    end
    scene:RemoveAllChildren(true);
    local layer = createNDUILayer();
    if layer == nil then
        return false;
    end
    layer:Init();
    layer:SetTag(NMAINSCENECHILDTAG.Login_AccountUI);
    layer:SetFrameRect(RectFullScreenUILayer);
    layer:SetBackgroundColor(ccc4(125, 125, 125, 125));
    scene:AddChild(layer);

    --初始化ui
    local uiLoad = createNDUILoad();
    if nil == uiLoad then
        layer:Free();
        return false;
    end

    uiLoad:Load("Register1_other.ini", layer, p.OnUIEvent, 0, 0);--注册帐号
    uiLoad:Free();
    p.Init();
    return true;
end

function p.getUiLayer()
    local scene = GetSMLoginScene();
    if not CheckP(scene) then
        return nil;
    end

    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.Login_AccountUI);
    if not CheckP(layer) then
        LogInfo("nil == layer")
        return nil;
    end
    return layer;
end

function p.Init()
    local uiLayer = p.getUiLayer();
    local pCheckBox = RecursiveCheckBox(uiLayer,{ID_ACCOUNTUI_SAVEPWD});
    if CheckP(pCheckBox) then
        pCheckBox:SetSelect(true);
        g_Record_Login = true;
    end
    
    if GetAccountListNum() < 1 then
    --无旧帐号，屏蔽按钮
        local BtnOldUser = GetButton(uiLayer,ID_ACCOUNTUI_ACT_SERVERSEL);
        if CheckP(BtnOldUser) then
            BtnOldUser:SetVisible(false);
        end
    end

    local pActEditUiNode = RecursiveUINode(uiLayer,{ID_ACCOUNTUI_INPUT_ACCOUNT});
    local pActEditPwd = ConverToEdit(pActEditUiNode);
    if CheckP(pActEditPwd) then
        pActEditPwd:SetMaxLength(15);
        pActEditPwd:SetMinLength(2);
    end

    local pEditUiNode = RecursiveUINode(uiLayer,{ID_ACCOUNTUI_INPUT_PWD});
    local pEditPwd = ConverToEdit(pEditUiNode);
    if CheckP(pEditPwd) then
        pEditPwd:SetPassword(true);
        pActEditPwd:SetMaxLength(12);
    end
end

function p.OnUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
        if tag == ID_ACCOUNTUI_LOGIN then
            if nil == g_Select_Account or nil == g_Account_Pwd then
                return ture;
            else
                LoginGame.LoginGame();
            end
        elseif tag == ID_ACCOUNTUI_ACT_SERVERSEL then
            g_Select_Account=nil;
            g_Select_Pwd=nil;
            Login_ActAndServerUI.LoadUI();
        end
    elseif uiEventType == NUIEventType.TE_TOUCH_TABLE_FOCUS then
    elseif uiEventType == NUIEventType.TE_TOUCH_EDIT_INPUT_FINISH then
    -- 用户按下键盘的返回键
        local edit = ConverToEdit(uiNode);
        if CheckP(edit) then
            if tag == ID_ACCOUNTUI_INPUT_ACCOUNT then
                g_Select_Account = edit:GetText();
                LogInfo("eidt text [%s][%s]", edit:GetText(),g_Select_Account);
            elseif tag == ID_ACCOUNTUI_INPUT_PWD then
                g_Account_Pwd = edit:GetText();
                --LogInfo("eidt text [%s][%s]", edit:GetText(),g_Select_Pwd);
            end 
        end
    elseif uiEventType == NUIEventType.TE_TOUCH_EDIT_TEXT_CHANGE then
    -- edit中的文本变更
        if tag == ID_ACCOUNTUI_INPUT_PWD then
        end
    end
	return true;
end