---------------------------------------------------
--描述: 登陆过程控制
--时间: 2012.3.25
--作者: HJQ
---------------------------------------------------

LoginGame = {}
local p = LoginGame;

--------------------------------------------------------------------------------
--启动登陆流程控制
--新玩家登陆
--创建角色-->选择服务器--》->自动分配帐号－－》登陆游戏
--老玩家新机器登陆
--创建角色-->老玩家登陆－－》存在帐号列表－－》帐号和服务器选择列表（帐号增加新建项）－－》登陆
--                              -->>不存帐号列表－》输入帐号和密码－－》登陆游戏
--老玩家老机器登陆
-->按最后登陆的帐号和服务器直接登陆《帐号和服务器的切换通过游戏内部的菜单进行切换>
--****待优化******--
--1.缺少服务器开启状态检查
--2.错误提示框
--3.进度条处理
--4.帐号和服务器选择界面缺最初的预设
--5.帐号输入密码框做＊号处理
--------------------------------------------------------------------------------
g_Select_Profession = 1;
g_Select_LookFace = 1;
g_Select_Name =nil;
g_Select_Account=nil;
g_Account_Pwd=nil;
g_Select_ServerName=nil;
g_Select_ServerIp=nil;
g_Select_ServerPort=0;
g_Record_Login=false;
g_Inter_Server=0;
g_Create_Role_Reason=0; --0表示客户端预先创建角色 1表示服务器提示创建触发

function p.Start()
    --如果存在登陆信息，则直接登陆，否则进入创建角色界面
    --local nActNum = GetAccountListNum();
    --if nActNum > 0 then
    --    if false == LoginByLastData() then
    --        Login_ActAndServerUI.LoadUI();
    --    end
    --else
        Login_RegRoleUI.LoadUI();
    --end
end

function p.FreeLoginData()
    g_Select_Profession = 1;
    g_Select_LookFace = 1;
    g_Select_Name =nil;
    g_Select_Account=nil;
    g_Account_Pwd=nil;
    g_Select_ServerName=nil;
    g_Select_ServerIp=nil;
    g_Select_ServerPort=0;
    g_Record_Login=false;
    g_Inter_Server=0;
end

function p.FreeRoleData()
    g_Select_Profession = 1;
    g_Select_LookFace = 1;
    g_Select_Name =nil;
end


function p.LoginGame()
    if nil ~= g_Select_Account then
        LogInfo("LoginGame Start!__Account[%s]",g_Select_Account);
    end
    if nil ~= g_Account_Pwd then
        LogInfo("LoginGame Start!__Pwd[%s]",g_Account_Pwd);
    end

    if  g_Select_Account == nil then
        Login_AccountUI.LoadUI();
        return true;
    elseif g_Select_ServerName == nil then
        --缺服务器选择转服务器选择
        Login_ServerUI.LoadUI();
        return true;
    end
LogInfo("Login Game-------------Start------");
LogInfo("Ip[%s]Port[%d]",g_Select_ServerIp,g_Select_ServerPort);
LogInfo("Account[%s]",g_Select_Account);
LogInfo("IPwd[%s]",g_Account_Pwd);
LogInfo("Name[%s]",g_Select_ServerName);
LogInfo("Login Game-------------End------");
    --进入Loading界面
    Login_LoadingUI.LoadUI();
    Login_LoadingUI.SetStyle(1);

    --发起登陆
LogInfo("Ip[%s]Port[%d]",g_Select_ServerIp,g_Select_ServerPort);
LogInfo("Account[%s]",g_Select_Account);
LogInfo("IPwd[%s]",g_Account_Pwd);
LogInfo("Name[%s]",g_Select_ServerName);
    local bSucc=SwichKeyToServer(g_Select_ServerIp,g_Select_ServerPort,g_Select_Account,g_Account_Pwd,g_Select_ServerName);
    if bSucc == false then
        Login_ServerUI.LoadUI();
        p.FreeLoginData();
    else
        Login_LoadingUI.SetProcess(10);
    end
    --p.FreeLoginData();
end

RegisterGlobalEventHandler(GLOBALEVENT.GE_LOGIN_GAME,"LoginGame.Start", p.Start);