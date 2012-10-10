---------------------------------------------------
--描述: 帐号和服务器选择界面登陆
--时间: 2012.3.25
--作者: HJQ
---------------------------------------------------

Login_ActAndServerUI = {}
local p = Login_ActAndServerUI;


p.AccountBtnTag=
{
    23,--帐号1
    24,--帐号2
    25,--帐号3
    26,--帐号4
    27,--帐号5
};

local ID_ACCOUNT_BTN_INPUT_ACCOUNT  = 443;
local ID_ACCOUNT_BTN_PAGE_UP        = 46;
local ID_ACCOUNT_BTN_PAGE_DOWN        = 47;

p.BtnAccountData={
--控件事件ID、帐号名、帐号密码
{23,'',''},
{24,'',''},
{25,'',''},
{26,'',''},
{27,'',''},
};

p.BtnServerBtg={
--控件ID、服务器名、服务器IP、服务器端口
{35,'','',0},
{36,'','',0},
{37,'','',0},
{38,'','',0},
{40,'','',0},
{41,'','',0},
{42,'','',0},
{43,'','',0},
{44,'','',0},
{45,'','',0},
}

p.ServerList={
--服务器ID,控件TAG,服务器别名,服务器名,服务器IP,服务器端口,内外服标记
{1,42,'1服内部测试','server01','192.168.9.104',5877,1},
{2,41,'2服内部测试','server02','192.168.9.104',5877,1},
{3,40,'3服内部测试','server03','192.168.9.104',5877,1},
{4,38,'4服内部测试','server04','192.168.9.104',5877,1},
{5,37,'5服内部测试','server05','192.168.9.104',5877,1},
{6,36,'6服内部测试','server06','192.168.9.104',5877,1},
{7,35,'7服外网测试','lyol4','121.207.255.120',5877,2},
};

local s_SelectAccount_Tag=0;
local s_SelectServer_Tag=0;

function p.LoadUI()
    local scene = GetSMLoginScene();
        if scene == nil then
            LogInfo("scene == nil,load Login_ServerAndAccountUI failed!");
            return false;
    end
    scene:RemoveAllChildren(true);
    local layer = createNDUILayer();
    if layer == nil then
        return false;
    end
    layer:Init();
    layer:SetTag(NMAINSCENECHILDTAG.Login_ServerAndAccountUI);
    layer:SetFrameRect(RectFullScreenUILayer);
    layer:SetBackgroundColor(ccc4(125, 125, 125, 125));
    scene:AddChild(layer);

    --初始化ui
    local uiLoad = createNDUILoad();
    if nil == uiLoad then
        layer:Free();
        return false;
    end

    uiLoad:Load("ServerChange.ini", layer, p.OnUIEvent, 0, 0);--帐号和服务器选择
    uiLoad:Free();
    p.InitUIData();
    return true;
end

function p.getUiLayer()
    local scene = GetSMLoginScene();
    if not CheckP(scene) then
        return nil;
    end

    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.Login_ServerAndAccountUI);
    if not CheckP(layer) then
        LogInfo("nil == layer")
        return nil;
    end
    return layer;
end

------------初始化－－－－－－－－
function p.InitUIData()
    --服务器列表排序，根据实际数量决定是否显示上一页和下一页的按钮
    local layer = p.getUiLayer();
    local PageUp=GetButton(layer,ID_ACCOUNT_BTN_PAGE_UP);
    if CheckP(PageUp) then
        PageUp:SetVisible(false);
    end

    local PageDown=GetButton(layer,ID_ACCOUNT_BTN_PAGE_DOWN);
    if CheckP(PageDown) then
        PageDown:SetVisible(false);
    end

    --先关闭所有帐号和服务器选项
    local nAccountBtnNum = table.getn(p.AccountBtnTag);
    for n=1,nAccountBtnNum do
        local BtnAccount=GetButton(layer,p.AccountBtnTag[n]);
        if CheckP(BtnAccount) then
            BtnAccount:SetVisible(false);
        end
    end
    
    local nServerBtnNum = table.getn(p.BtnServerBtg);
    for n=1,nServerBtnNum do
        local BtnServer=GetButton(layer,p.BtnServerBtg[n][1]);
        if CheckP(BtnServer) then
            BtnServer:SetVisible(false);
        end
    end

    --帐号列表+按钮显示
    local nActNum = GetAccountListNum();
    if nActNum > table.getn(p.BtnAccountData) then
        nActNum = table.getn(p.BtnAccountData)
    end

    for n=1,nActNum do
        local s_AccountName = GetRecAccountNameByIdx(n-1);
        local s_AccountPwd  = GetRecAccountPwdByIdx(n-1);
        p.BtnAccountData[n][2] = s_AccountName;
        p.BtnAccountData[n][3] = s_AccountPwd;
        local BtnAccount=GetButton(layer,p.BtnAccountData[n][1]);
        if CheckP(BtnAccount) then
            BtnAccount:SetVisible(true);
            BtnAccount:SetTitle(s_AccountName);
        end
    end

    --服务器列表
--[[
    local nServerNum = table.getn(p.ServerList);
    for n=1,nServerNum do
        local BtnServer=GetButton(layer,p.BtnServerBtg[n][1]);
        if CheckP(BtnServer) then
            BtnServer:SetVisible(true);
            BtnServer:SetTitle(p.ServerList[n][3]);
            p.BtnServerBtg[n][2] = p.ServerList[n][4];
            p.BtnServerBtg[n][3] = p.ServerList[n][5];
            p.BtnServerBtg[n][4] = p.ServerList[n][6];
--LogInfo("Login n[%d]btnTag[%d]ShowName[%s]Server[%s]Ip[%s]Port[%d]",n,p.BtnServerBtg[n][1], p.ServerList[n][3],p.BtnServerBtg[n][2],p.BtnServerBtg[n][3],p.BtnServerBtg[n][4]);
--LogInfo("Login n[%d]ShowName[%s]Server[%s]Ip[%s]Port[%d]",n,p.ServerList[n][3], p.ServerList[n][4],p.ServerList[n][5],p.ServerList[n][6]);
        end
    end
--]]
    return true;
end

----/*************事件处理********************/
function p.OnUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
        if tag == ID_ACCOUNT_BTN_INPUT_ACCOUNT then
--[[
            g_Select_Account = nil;
            g_Select_ServerName = nil;
            g_Select_ServerIp=nil;
            g_Select_ServerPort=nil;
            g_Account_Pwd=nil;
            Login_AccountUI.LoadUI();
--]]
            Login_Main.LoadUI();
            return true;
        else
--[[
            local nServerBtnNum = table.getn(p.BtnServerBtg);
            for n=1,nServerBtnNum do
                if p.BtnServerBtg[n][1] == tag then
                    g_Select_ServerName=p.BtnServerBtg[n][2];
                    g_Select_ServerIp=p.BtnServerBtg[n][3];
                    g_Select_ServerPort=p.BtnServerBtg[n][4];
--LogInfo("Login ServerTag[%s]ServerName[%s]Ip[%s]Port[%d]", p.BtnServerBtg[n][1],p.BtnServerBtg[n][2],p.BtnServerBtg[n][3],p.BtnServerBtg[n][4]);
                    --已经选择了帐号的开始登陆
                    if g_Select_Account ~= nil then
                        LoginGame.LoginGame();
                    else
                        return true;
                    end
                end
            end
--]]

            local nAccountBtnNum = table.getn(p.BtnAccountData);
            for n=1,nAccountBtnNum do
                if p.BtnAccountData[n][1] == tag then
                    --g_Select_Account=p.BtnAccountData[n][2];
                    --g_Account_Pwd=p.BtnAccountData[n][3];
                    Login_ServerUI.LoadUI(p.BtnAccountData[n][2],p.BtnAccountData[n][3]);
--[[
--LogInfo("Login AccountTag[%s]AccountName[%s]Pwd[%s]", p.BtnAccountData[n][1],p.BtnAccountData[n][2],p.BtnAccountData[n][3]);
                    if g_Select_ServerName ~= nil then
                        LoginGame.LoginGame();
                    else
                        return true;
                    end
--]]
                end
            end
        end
	elseif uiEventType == NUIEventType.TE_TOUCH_TABLE_FOCUS then
	end
	return true;
end