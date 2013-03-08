---------------------------------------------------
--描述: 服务器选择界面
--时间: 2012.07.24
--作者: CHH
---------------------------------------------------

Login_ServerUI = {}
local p = Login_ServerUI;

p.curSel=0;
p.Account=nil;
p.Pwd="";
p.UIN=317003333;

p.LoginWait = true;
p.LoginUiUpdate = false;          --在服务器列表是否要检测版本更新的标志

p.SerName = "";
p.SerIp = "";
p.SerPort = "";

p.nCurSerId = -1;
p.nPreSerId = -1;

--推荐服务器(15--21)
local ID_SERVER_SELECT_1 = 15;
local ID_SERVER_SELECT_2 = 16;
local ID_SERVER_SELECT_3 = 17;
local ID_SERVER_SELECT_4 = 18;
local ID_SERVER_SELECT_5 = 20;
local ID_SERVER_SELECT_6 = 21;


--server list tag
local TAG_CONTAINER             = 3;
local TAG_CONTAINER_BTN         = 17;
local TAG_CONTAINER_NAME        = 18;
local TAG_CONTAINER_ROLE        = 19;
local TAG_NEW_SERVER_FLAG       = 42;
local TAG_NEW_SERVER            = 36;
local TAG_NEW_SERVER_BTN        = 16;
local TAG_NEW_SERVER_RECOMMEND  = 15;

local TAG_Close_BTN             = 22;
local TAG_URL_BTN               = 226;

local TAG_CUR_SERVER_BTN        = 16;
local TAG_CUR_SERVER_NAME       = 36;
local TAG_CUR_SERVER_FLAG       = 38;
local TAG_CUR_SERVER_RECOMMEND  = 15;
local TAG_CUR_SERVER_TITLE      = 14;

--按钮编号
local ID_SERVER_SELECT_PAGE_UP                      = 22;
local ID_SERVER_SELECT_PAGE_DOWN                    = 23;

local ID_SERVER_BUTTON_START = 7;
local ID_SERVER_BUTTON_END   = 22;

local RECOMMEND_ID          = 10000;

local ServerItemSize = CGSizeMake(470*ScaleFactor,45*ScaleFactor);

--p.worldIP='192.168.64.32';--qbw
p.worldIP = nil;--common
p.worldPort= nil;
--p.worldIP='192.168.65.7';--qbw
--p.worldIP='222.77.177.209';--外网

p.recvServerFlag=0;
p.recvIndex=0;

p.szGameForumURL = "";

local ServerStatus = {
    {GetTxtPri("StateWeiHu"),ccc4(138,138,138,255)},
    {GetTxtPri("StateTuiJian"),ccc4(0,255,0,255)},
    {GetTxtPri("StateYongJi"),ccc4(255,255,0,255)},
    {GetTxtPri("StateBaoMan"),ccc4(255,0,0,255)},
    {GetTxtPri("StateNoStart"),ccc4(138,138,138,255)},
    {GetTxtPri("StateNewServer"),ccc4(0,255,0,255)},
};

local LastLoginInfo = {
    GetTxtPri("LastLogin"),
    GetTxtPri("NewServerTuiJian"),
};

p.ServerListTag = {
    --{nServerID=222,sServerName="zzj",nServerIP="192.168.65.105",nServePort=9528,nServerStatus=2,sRecommend="ss",sUrl=""}
};
p.RoleListTag = {};


--p.mTimerTaskTag = nil;
--
--function p.PlayLoginMusic()
--	if (p.mTimerTaskTag) then
--		UnRegisterTimer(p.mTimerTaskTag);
--		p.mTimerTaskTag = nil;
--	end	
--	Music.PlayLoginMusic()
--	--PlayVideo("480_0.mp4",false);
--end
	
function p.LoadUI()
    p.ProcessNotifyClient2();
    
    local bFlag = HideLoginUI(NMAINSCENECHILDTAG.Login_ServerUI);
    if(bFlag) then
        return true;
    end
    p.IsShow = true;
    
--    LogInfo("test qbw 111")
--	--播放背景音乐
--    --SetSceneMusicAndMap(99,4);
--   -- SetBgMusicVolume(100);
--   -- SetEffectSoundVolune(400);
--	p.mTimerTaskTag = RegisterTimer(p.PlayLoginMusic, 3);--Guosen 2012.8.4
--
--	LogInfo("TEST VIDEO ");
--	--PlayVideo("480_0.mp4",true);
--	
--	
    local scene = GetRunningScene();
    if scene == nil then
        LogInfo("scene == nil,load Login_ServerUI failed!");
        return false;
    end

    --scene:RemoveAllChildren(true);
    local layer = createNDUILayer();
    if layer == nil then
        return false;
    end

    p.recvIndex = 0;
    layer:Init();
    layer:SetTag(NMAINSCENECHILDTAG.Login_ServerUI);
    layer:SetFrameRect(RectFullScreenUILayer);
    scene:AddChild(layer);

    --初始化ui
    local uiLoad = createNDUILoad();
    if nil == uiLoad then
        layer:Free();
        return false;
    end

    uiLoad:Load("login_2.ini", layer, nil, 0, 0);--选择服务器
    uiLoad:Free();
    
    local btn = GetButton(layer,TAG_Close_BTN);
    btn:SetLuaDelegate(p.OnUIEventClose);
    
    local btn = GetButton(layer,TAG_URL_BTN);
    btn:SetLuaDelegate(p.OnUiEventUrl);
    
    p.Init();
    p.Refresh();
    
    --doNDSdkLogin();--Guosen 2012.8.3
    
    return true;
end


function p.OnUiEventUrl(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
    LogInfo("p.OnUiEventUrl tag:[%d]",tag);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
        if(TAG_URL_BTN == tag) then
            if( p.szGameForumURL and p.szGameForumURL ~= "" ) then
                LogInfo("open url:[%s]",p.szGameForumURL);
                OpenURL( p.szGameForumURL );
            end
        end
	end
	return true;
end

function p.Init()
    --p.ServerListTag = SqliteConfig.SelectServerList();
    --p.RoleListTag = SqliteConfig.SelectRoleList(p.UIN);
    
    --先不显示所有的serverbutton和分页按钮
    
    --[[
    local layer = p.getUiLayer();
    local PageUp=GetButton(layer,ID_SERVER_SELECT_PAGE_UP);
    if CheckP(PageUp) then
        PageUp:SetVisible(false);
    end

    local PageDown=GetButton(layer,ID_SERVER_SELECT_PAGE_DOWN);
    if CheckP(PageDown) then
        PageDown:SetVisible(false);
    end
    
    for nBtnSerialNo=ID_SERVER_BUTTON_START,ID_SERVER_BUTTON_END do
        local BtnServer=GetButton(layer,nBtnSerialNo);
        if CheckP(BtnServer) then
            BtnServer:SetVisible(false);
        end
    end
    ]]
end


function p.getUiLayer()
    local scene = GetSMLoginScene();
    if not CheckP(scene) then
        return nil;
    end

    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.Login_ServerUI);
    if not CheckP(layer) then
        LogInfo("nil == layer")
        return nil;
    end
    return layer;
end

function p.OnUIEventClose(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
    LogInfo("p.OnUIEventClose tag:[%d]",tag);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
        if(TAG_Close_BTN == tag) then
            doNDSdkChangeLogin();
        end
	end
	return true;
end

function p.AddItem(i)
    local container = p.GetViewContainer();
    
    if i == 1 then
        container:SetViewSize(ServerItemSize);
    end
    local info = p.ServerListTag[i];

    if(info.nServerID == RECOMMEND_ID ) then
        LogInfo("p.AddItem info.nServerID == RECOMMEND_ID");
        return;
    end

    local view = createUIScrollView();
    if view == nil then
        LogInfo("p.LoadUI createUIScrollView failed");
        return;
    end
    
    view:Init(false);
	view:bringToTop();
    view:SetViewId(i);
    container:AddView(view);
    
    --初始化ui
    local uiLoad = createNDUILoad();
    if nil == uiLoad then
        layer:Free();
        return false;
    end

    uiLoad:Load("login_2_L.ini", view, p.OnUIEvent, 0, 0);
    p.refreshServerListItem(i);
end

function p.Refresh()
    
    p.ServerListTag = {};
    p.RoleListTag = {};
    local container = p.GetViewContainer();
    if(container == nil) then
        LogInfo("p.Refresh container is nil!");
        return;
    end
    container:RemoveAllView();
    container:EnableScrollBar(true);
    
    --[[
    local layer = p.getUiLayer();
    local container = p.GetViewContainer();
    if(container == nil) then
        LogInfo("container is nil!");
        return;
    end
    container:RemoveAllView();
    container:SetViewSize(ServerItemSize);
    container:EnableScrollBar(true);
    for i=1, #p.ServerListTag do
        p.AddItem(container, i);
    end
    ]]
end


function p.refreshServerListItem(i)
    LogInfo("p.refreshServerListItem :i[%d]",i);
    if(i==0) then
        return;
    end
    local container = p.GetViewContainer();
    if(container==nil) then
        return;
    end
    
    local view  = container:GetViewById(i);
    if(view==nil) then
        return;
    end

    local info = p.ServerListTag[i];
    if(info.nServerID == RECOMMEND_ID ) then
        return;
    end

    SetLabel(view, TAG_CONTAINER_NAME, info.sServerName);
    
    local flag = GetLabel(view, TAG_NEW_SERVER_FLAG);
    flag:SetText(ServerStatus[info.nServerStatus+1][1]);
    flag:SetFontColor(ServerStatus[info.nServerStatus+1][2]);
    LogInfo("ServerStatus[info.nServerStatus+1][1]:[%s],info.nServerStatus:[%d]",ServerStatus[info.nServerStatus+1][1],info.nServerStatus);

    local rInfo = p.GetRoleInfoByServerId(info.nServerID);
    
    if(rInfo) then
        local sRoleInfo = string.format("%s %s %d%s",rInfo.sRoleName,RolePetFunc.GetJobDesc(rInfo.nProfession),rInfo.nLevel,GetTxtPub("Level"));
        SetLabel(view, TAG_CONTAINER_ROLE, sRoleInfo);
    else
        SetLabel(view, TAG_CONTAINER_ROLE, GetTxtPri("LSUI_T1"));
    end
    
    local btn = GetButton(view, TAG_CONTAINER_BTN);
    btn:SetParam1(i);
    
    p.FindCurrServer();
end

--查找当前服务器
function p.FindCurrServer()
    --选找该用户是否有帐号
    LogInfo("p.FindCurrServer");
    local nServerIndex = 0;
    
    local layer = p.getUiLayer();
    if(layer == nil) then
        return;
    end
    
    local title = GetLabel(layer,TAG_CUR_SERVER_TITLE);
    if(#p.RoleListTag>0) then
        LogInfo("exist role!");
        local nServerId = p.RoleListTag[1].nServerID;
        local nLastLogin = p.RoleListTag[1].nLastLogin;
        for i,v in ipairs(p.RoleListTag) do
            if(nLastLogin<v.nLastLogin) then
                nLastLogin  = v.nLastLogin;
                nServerId   = v.nServerID;
            end
        end
        nServerIndex = p.GetServerIndexByServerId(nServerId);
        title:SetText(LastLoginInfo[1]);
    elseif(#p.ServerListTag>0) then
        LogInfo("not exist role,exist server!");
        local nServerId = p.ServerListTag[1].nServerID;
        nServerIndex = 1;
        local nServerStatus = 0;
        for i,v in ipairs(p.ServerListTag) do
            if(1 == v.nServerStatus or 5 == v.nServerStatus) then
                
                if(v.nServerStatus > nServerStatus) then
                    nServerStatus = v.nServerStatus;
                    
                    nServerStatus = v.nServerStatus;
                    nServerId = v.nServerID;
                    nServerIndex = i;
                end
                --break;
            end
        end
        title:SetText(LastLoginInfo[2]);
    end
    
    p.SetCurrServer(nServerIndex);
end

--设置当前服务器
function p.SetCurrServer(nServerIndex)
    if(nServerIndex == 0) then
        LogInfo("Set Current ServerList Error!,ServerList num is 0!");
        return;
    end
    local layer = p.getUiLayer();
    if(layer == nil) then
        return;
    end
    
    local CurrServerInfo = p.ServerListTag[nServerIndex];
    
    local server_name = GetLabel(layer,TAG_CUR_SERVER_NAME);
    server_name:SetText(CurrServerInfo.sServerName);
    
    local flag = GetLabel(layer, TAG_CUR_SERVER_FLAG);
    flag:SetText(ServerStatus[CurrServerInfo.nServerStatus+1][1]);
    flag:SetFontColor(ServerStatus[CurrServerInfo.nServerStatus+1][2]);
    
    local btn = GetButton(layer, TAG_CUR_SERVER_BTN);
    btn:SetParam1(nServerIndex);
    btn:SetLuaDelegate(p.OnUIEvent);
end



--获得角色根据服务器ID
function p.GetRoleInfoByServerId(nServerId)
    for i,v in ipairs(p.RoleListTag) do
        LogInfo("v.nServerID[%d] == nServerId[%d]",v.nServerID,nServerId);
        if(v.nServerID == nServerId) then
            return v;
        end
    end
    return nil;
end

function p.GetServerIndexByServerId(nServerId)
    for i,v in ipairs(p.ServerListTag) do
        if(v.nServerID == nServerId) then
            return i;
        end
    end
    return 0;
end

function p.GetRoleIndexByServerId(nServerId)
    for i,v in ipairs(p.RoleListTag) do
         if(v.nServerID == nServerId) then
            return i;
        end
    end
    return 0;
end

function p.GetViewContainer()
	local layer = p.getUiLayer();
    if(layer == nil) then
        return nil;
    end
	local svc	= GetScrollViewContainer(layer, TAG_CONTAINER);
	return svc;
end

function p.LoginGame(strServerName,strServerIp,strServerPort)
    LogInfo("strServerName[%s],strServerIp[%s],strServerPort[%d],p.UIN[%d]",strServerName,strServerIp,strServerPort,p.UIN);
    --发起登陆
    local bSucc=SwichKeyToServer(strServerIp,strServerPort,SafeN2S(p.UIN),p.Pwd,strServerName);
    
    if bSucc == false then
        CommonDlgNew.ShowYesDlg(GetTxtPri("LoginFailReLogin"));
    else
        if p.LoginWait then
            ShowLoadBar();
        else
            --进入Loading界面
            Login_LoadingUI.LoadUI();
            Login_LoadingUI.SetProcess(10);
        end
    end
end

function p.OnUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
    LogInfo("p.OnUIEvent tag:[%d]",tag);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
        
        local btn = ConverToButton(uiNode);
        if(btn == nil) then
            LogInfo("btn is nil!");
            return;
        end
        
        LogInfo("index:[%d]",btn:GetParam1());
        
        local info = p.ServerListTag[btn:GetParam1()];
        
        if(info == nil) then
            LogInfo("server info error!");
            return;
        end
        
        if(info.nServerStatus == 0 or info.nServerStatus == 4) then 
            CommonDlgNew.ShowYesDlg(info.sRecommend);
            return true;
        end
        
        local sServerName = info.sServerName;
        --local sServerIp = StrInt2StrIP(info.nServerIP);
        local sServerIp = info.nServerIP;
        local nServerPort = info.nServePort;
        p.SerName = sServerName;
        p.SerIp = sServerIp;
		 p.SerPort = nServerPort;
        
        p.nPreSerId = p.nCurSerId;
        p.nCurSerId = info.nServerID;
        
        LogInfo("登录服务器名:[%s],ip:[%s],port:[%d]",sServerName,sServerIp,nServerPort);
        
        if p.LoginUiUpdate then
			--检测当前是否有版本更新
			p.SendDataToCheckVision();
		 else
			p.LoginGame(sServerName,sServerIp,nServerPort);
		 end
	end
	return true;
end


function p.LoginOK_Guest(param)
    p.UIN = param;
    LogInfo("p.LoginOK_Guest uin:[%d]",param);
    p.ChangeUserLogin(p.UIN);
    p.RunGetServerListTimer();
    LogInfo("p.LoginOK_Guest p.worldIP:[%s]",p.worldIP);
end

function p.LoginOK_Normal(param)
    LogInfo("@@ Login_ServerUI::LoginOK_Normal()" );
    
    p.UIN = param;
    LogInfo("p.LoginOK_Normal uin:[%d]",param);
    p.ChangeUserLogin(p.UIN);
    p.RunGetServerListTimer();
    LogInfo("p.LoginOK_Normal p.worldIP:[%s]",p.worldIP);
end

function p.LoginOK_Guest2Normal(param)
    p.UIN = param;
    LogInfo("p.LoginOK_Guest2Normal uin:[%d]",param);
    p.ChangeUserLogin(p.UIN);
    p.RunGetServerListTimer();
    LogInfo("p.LoginOK_Guest2Normal p.worldIP:[%s]",p.worldIP);
end

p.nTimerID = nil;
function p.RunGetServerListTimer()
    if(p.nTimerID == nil) then
        LogInfo("p.RunGetServerListTimer send!");
        sendMsgConnect(p.worldIP, p.worldPort, p.UIN);
        p.nTimerID = RegisterTimer( p.TimerGetServerList, 10 );
    end
end

--定时向服务器取列表
function p.TimerGetServerList(nTimer)
    --if(#p.ServerListTag>0) then
    
        if(p.getUiLayer() == nil) then
            if(p.nTimerID) then
                UnRegisterTimer( p.nTimerID );
                p.nTimerID = nil;
                return;
            end
        end
    
    --end
    sendMsgConnect(p.worldIP, p.worldPort, p.UIN);
end

function p.ChangeUserLogin(nUIN)
    --[[
    local nIsUinChange = SqliteConfig.DeleteRoleByAccountId(nUIN);
    if(nIsUinChange) then
        p.Init();
        p.Refresh();
    end
    ]]
    p.Init();
    p.Refresh();
end

function p.LoginError(param)
    LogInfo("p.LoginError uin:[%d]",param);
    p.UIN = 0;
    CommonDlgNew.ShowYesDlg(GetTxtPri("LoginFailReLogin"));
end

function p.RefreshServer(nEventType)
    if(nEventType == CommonDlgNew.BtnOk) then
        Login_ServerUI.LoadUI();
    end
end

p.IsShow = false;
function p.ProcessServerList(netdatas)
	LogInfo("receive_serverlist");
    if(p.IsShow) then
        p.GetNotice();
        p.IsShow = false;
    end
    
    local record = {};
    record.nServerID = netdatas:ReadShort();
    record.nServerStatus = netdatas:ReadShort();
    record.nServerIP = netdatas:ReadInt();
	record.nServePort = netdatas:ReadShort();
    record.sServerName = netdatas:ReadUnicodeString();
    
    record.nServerIP = Int2StrIP(record.nServerIP);
    
    record.sRecommend   = netdatas:ReadUnicodeString();
    record.sUrl         = netdatas:ReadUnicodeString();

    LogInfo("nServerID:[%d],nServerStatus[%d],nServerIP[%s],nServePort[%d],sServerName:[%s],sRecommend:[%s]",record.nServerID,record.nServerStatus,record.nServerIP,record.nServePort,record.sServerName,record.sRecommend);
    
    if(record.nServerID == RECOMMEND_ID ) then
        local layer = p.getUiLayer();
        if(layer == nil) then
            return;
        end
        local server_recommend = GetLabel(layer,TAG_CUR_SERVER_RECOMMEND);
        server_recommend:SetText(record.sRecommend);
        p.szGameForumURL = record.sUrl;
        return;
    end

    --更新变量
    local nIndex = p.GetServerIndexByServerId(record.nServerID);
    if(nIndex == 0) then
        LogInfo("nIndex == 0");
        nIndex = #p.ServerListTag + 1;
        p.ServerListTag[nIndex] = record;
        p.AddItem(nIndex);
    else
        LogInfo("nIndex ~= 0:[%d]",nIndex);
        
        if(p.ServerListTag[nIndex] == nil) then
            p.ServerListTag[nIndex] = {};
        end
        
        p.ServerListTag[nIndex].nServerID = record.nServerID;
        p.ServerListTag[nIndex].nServerStatus = record.nServerStatus;
        p.ServerListTag[nIndex].nServerIP = record.nServerIP;
        p.ServerListTag[nIndex].nServePort = record.nServePort;
        p.ServerListTag[nIndex].sServerName = record.sServerName;
        p.ServerListTag[nIndex].nServerIP = record.nServerIP;
        p.ServerListTag[nIndex].sRecommend   = record.sRecommend;
        p.ServerListTag[nIndex].sUrl         = record.sUrl;
        
        p.refreshServerListItem(nIndex);
    end
    
end

function p.ProcessServerRole(netdatas)
	LogInfo("receive_serverrole");
    local record = {};
    
    record.nIdAccount = netdatas:ReadInt();
    record.nServerID = netdatas:ReadShort();
    record.nServerStatus = netdatas:ReadShort();
    record.nServerIP = netdatas:ReadInt();
    record.nServePort = netdatas:ReadShort();
    record.nProfession = netdatas:ReadShort();
    record.nLevel = netdatas:ReadInt();
    record.nLastLogin = netdatas:ReadInt();
    record.sRoleName=netdatas:ReadUnicodeString();
    
    --测试使用
    if(record.nLevel < 0 or record.nLevel > 1000) then
        return;
    end

    LogInfo("nIdAccount:[%d],nServerID:[%d],nServerStatus:[%d],nProfession:[%d],nLevel:[%d],nLastLogin:[%d],sRoleName:[%s]",record.nIdAccount,record.nServerID,record.nServerStatus,record.nProfession,record.nLevel,record.nLastLogin,record.sRoleName);
    
    --更新数据库
    SqliteConfig.InsertServerRoleInsert(record);
    
    
    --更新变量
    local nIndex = p.GetRoleIndexByServerId(record.nServerID);
    if(nIndex == 0) then
        nIndex = #p.RoleListTag + 1;
    end
    p.RoleListTag[nIndex] = record;
    
    
    --更新UI
    LogInfo("record.nServerID:[%d]",record.nServerID);
    local nIndex = p.GetServerIndexByServerId(record.nServerID);
    local container = p.GetViewContainer();
    if(container == nil) then
        return;
    end
    local view = container:GetViewById(nIndex);
    LogInfo("nIndex:[%d]",nIndex);
    
    p.refreshServerListItem(nIndex);
end

--退出游戏进行选帐号
function p.ExitGameChangeAccount()
    


end

--退出游戏进行选服
function p.ExitGameChangeServer()
    

end

--获取服务器id,为了区分不同的服务器,活动配置不同
function p.GetPreCurSerId()
    return p.nPreSerId, p.nCurSerId;
end

function p.SetPreCurSerId(nPre, nCur)
    p.nPreSerId = nPre;
    p.nCurSerId = nCur;
end

--_G.RegisterGlobalEventHandler(_G.GLOBALEVENT.GE_LOGINOK_GUEST,"Login_ServerUI.LoginGuest",p.LoginOK_Guest);--Guosen 2012.8.4
--_G.RegisterGlobalEventHandler(_G.GLOBALEVENT.GE_LOGINOK_NORMAL,"Login_ServerUI.LoginNormal",p.LoginOK_Normal);
--_G.RegisterGlobalEventHandler(_G.GLOBALEVENT.GE_LOGINOK_GUEST2NORMAL,"Login_ServerUI.LoginGuest2Normal",p.LoginOK_Guest2Normal);
--_G.RegisterGlobalEventHandler(_G.GLOBALEVENT.GE_LOGINERROR,"Login_ServerUI.LoginError",p.LoginError);

RegisterNetMsgHandler(NMSG_Type._MSG_SERVERROLE,"p.ProcessServerRole",p.ProcessServerRole);
RegisterNetMsgHandler(NMSG_Type._MSG_SERVERLISTITEM,"p.ProcessServerList",p.ProcessServerList);

function p.SetAccountID( nAccountID )
	p.UIN = nAccountID;
end
function p.GetAccountID()
	return p.UIN;
end


function p.GetNotice()
    local record = SqliteConfig.SelectNotice(1);
    --ActivityNoticeUI.ShowUI(record.VER);
end

--踢人
function p.ProcessNotifyClient2()
    local usAction = MsgLogin.TT_Status;
    if(not CheckN(usAction)) then
        MsgLogin.TT_Status = nil;
        return;
    end
    if(usAction == 0) then
        local sTip = GetTxtPri("GMCOMM_T01");
        CommonDlgNew.ShowYesDlg(sTip);
    elseif(usAction == 1) then
        local sTip = GetTxtPri("GMCOMM_T02");
        CommonDlgNew.ShowYesDlg(sTip);
    elseif(usAction == 2) then
        local sTip = GetTxtPri("GMCOMM_T03");
        CommonDlgNew.ShowYesDlg(sTip);
    elseif(usAction == 3) then
        local sTip = GetTxtPri("GMCOMM_T04");
        CommonDlgNew.ShowYesDlg(sTip);
    elseif(usAction == 4) then
        local sTip = GetTxtPri("GMCOMM_T05");
        CommonDlgNew.ShowYesDlg(sTip);
    end
    MsgLogin.TT_Status = nil;
end

--++Guosen 2012.8.4
function p.LoginGameNew()
	LogInfo( "@@ Login_ServerUI: LoginGameNew()" );
	Music.PlayLoginMusic()
	p.LoadUI();
	p.LoginOK_Normal( p.UIN )
end
RegisterGlobalEventHandler( GLOBALEVENT.GE_LOGIN_GAME,"Login_ServerUI.LoginGame", p.LoginGameNew );



---------新加在服务器列表页面增加版本判断功能-----------tzq 2013-2-1 begin---------------

--向世界服务器发送数据请求版本验证
function p.SendDataToCheckVision()
	local WorldSerIp = GetGameConfig("world_server_ip");
	local WorldSerPort = GetWorldServerPort();
	
	LoginUICheckClientVersion(WorldSerIp, WorldSerPort);
	--LogInfo( "LogSerUI CheckVision WorldSerIp = %s, WorldSerPort = %d", WorldSerIp, WorldSerPort);
end

--服务器列表更新版本后登入
function p.LoguiLoginGame()
   p.LoginGame(p.SerName, p.SerIp, p.SerPort);
end




---------新加在服务器列表页面增加版本判断功能-----------tzq 2013-2-1 end---------------
