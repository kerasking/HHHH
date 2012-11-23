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
p.UIN=298845082;

--p.worldIP='192.168.64.32';--qbw
p.worldIP='192.168.9.47';--common
--p.worldIP='192.168.65.7';--qbw
--p.worldIP='222.77.177.209';--外网
p.worldPort=9500;
p.recvServerFlag=0;
p.recvIndex=0;

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
	PrintLog("entry p.LoadUI()");
	local dirtor = DefaultDirector();
    local scene = dirtor:GetRunningScene();
    if scene == nil then
        PrintLog("scene is null");
        return false;
    end

	PrintLog("ready to get layer");
    local layer = createNDUILayer();
    if layer == nil then
        return false;
    end

    p.recvIndex = 0;
    layer:Init();
   -- layer:SetTag(NMAINSCENECHILDTAG.Login_ServerUI);
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
    
    --doNDSdkLogin();--Guosen 2012.8.3
    
    return true;
end


RegisterGlobalEventHandler( 103,"Login_ServerUI.LoginGame", p.LoadUI );