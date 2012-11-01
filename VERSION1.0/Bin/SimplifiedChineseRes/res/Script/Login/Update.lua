---------------------------------------------------
--描述: 更新界面
--时间: 2012.8.2
--作者: Guosen
---------------------------------------------------

Update = {}
local p = Update;


---------------------------------------------------
local ID_LABEL_PROMPT					= 4;	-- 文字标签控件ID
local ID_CTRL_PROGRESS					= 2;	-- 进度条控件ID
local ID_BTN_TOUCH						= 3;	-- 按钮控件ID

---------------------------------------------------
-- 更新界面的各种状态
local UpdateUIStatus = {
	Nothing								= 0,	-- 啥都木有，初始状态
	Disapearing							= 1,	-- 梦宝谷界面消失中，MobageDispear
	Checking							= 2,	-- 检查版本中
	Downloading							= 3,	-- 下载中
	Installing							= 4,	-- 安装中
	WaitingTouch						= 5,	-- 等待触摸
};

--
local szUpdateURL						= "192.168.9.47"--"192.168.9.47";--"192.168.65.77";	-- 更新服务器的地址

local szDownloading						= "版本下载中……";
local szInstalling						= "正在安装更新……";
local szTouch							= "点击屏幕进入游戏";
local szError							= "连接网络失败……";

local nTimeInterval						= 1/24;	-- 时间间隔
local nTotal							= 100;
local nStep								= 1;

---------------------------------------------------
p.pCtrlProgress							= nil;	-- 进度条控件
p.pLabelPromtp							= nil;	-- 文字标签控件
p.pBtnTouch								= nil;	-- 按钮
p.nAccountID							= nil;	-- 登录成功的账户ID
p.nUIStatus								= nil;	-- 状态

---------------------------------------------------
-- 所在场景
function p.GetCurrentScene()
	--local pDirector = DefaultDirector();
	--if ( pDirector == nil ) then
	--	LogInfo( "PlayEffectAnimation: pDirector == nil" );
	--	return nil;
	--end
	--local pScene = pDirector:GetRunningScene();
	local pScene = GetSMLoginScene();
	if ( pScene == nil ) then
		LogInfo( "Update: GetCurrentScene() pScene is nil" );
	end
	return pScene;
end

---------------------------------------------------
-- 所在层
function p.GetUILayer()
    local pScene = p.GetCurrentScene();
    local pLayer = GetUiLayer( pScene, NMAINSCENECHILDTAG.Update );
    if not CheckP( pLayer ) then
        LogInfo( "Update: GetUILayer() pLayer is nil" );
        return nil;
    end
    return pLayer;
end

---------------------------------------------------
--装载UI并显示
function p.ShowUI()
    local pScene = p.GetCurrentScene();
    if ( pScene == nil ) then
        LogInfo( "Update: ShowUI() failed! pScene is nil" );
        return false;
    end
	
	local pLayer = createNDUILayer();
	if ( pLayer == nil ) then
		LogInfo( "Update: ShowUI() failed! pLayer is nil" );
		return false;
	end
	pLayer:Init();
	pLayer:SetTag( NMAINSCENECHILDTAG.Update );
	pLayer:SetFrameRect( RectFullScreenUILayer );
	--layer:SetBackgroundColor( ccc4(125, 125, 125, 0) );
	pScene:AddChild( pLayer );
	
	--初始化ui
	local uiLoad = createNDUILoad();
	if not CheckP(uiLoad) then
		LogInfo( "Update: ShowUI() failed! uiLoad = nil" );
		return false;
	end
	uiLoad:Load( "UpdateUI.ini", pLayer, p.OnUIEvent, 0, 0 );
	uiLoad:Free();
	
	--
	p.pCtrlProgress	= RecursivUIExp( pLayer, { ID_CTRL_PROGRESS } );
	if ( p.pCtrlProgress == nil ) then
		LogInfo( "Update: ShowUI() failed! pCtrlProgress = nil" );
	end
	p.pCtrlProgress:SetProcess(0);
	p.pCtrlProgress:SetTotal(100);
	p.pCtrlProgress:SetStyle(2);
	p.pCtrlProgress:SetVisible(false);
	
	--
	p.pLabelPromtp	= GetLabel( pLayer, ID_LABEL_PROMPT );
	p.pLabelPromtp:SetVisible(false);
	
	--
	p.nUIStatus		= UpdateUIStatus.Nothing;
	
	doNDSdkLogin();
	--p.InitCheck();--测试
	
    return true;
end

---------------------------------------------------
-- 关闭界面
function p.CloseUI()
	local scene = p.GetCurrentScene();
	if scene ~= nil then
		scene:RemoveChildByTag( NMAINSCENECHILDTAG.Update, true );
	end
end

---------------------------------------------------
--响应事件
function p.OnUIEvent( uiNode, uiEventType, param )
	local tag = uiNode:GetTag();
	if ( uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK ) then
        if ( ID_BTN_TOUCH == tag ) then
			if ( p.nAccountID ~= nil ) then
				nAccountID = p.nAccountID;
				p.CloseUI();
				SqliteConfig.InitDataBaseTable();
				Login_ServerUI.LoadUI();
				Login_ServerUI.LoginOK_Normal( nAccountID )
			end
		end
	end
	return true;
end


---------------------------------------------------
--
function p.InitCheck()
	LogInfo( "Update: p.InitCheck()" );
	p.nUIStatus	=  UpdateUIStatus.Checking;
	--
	-- 发送检测版本请求
	if ( CheckClientVersion( szUpdateURL ) ) then
	else
		p.InitWaitingTouch();
	end
	--p.InitDownload();
end


---------------------------------------------------
-- 响应检测版本回调
function p.CallBack_CheckVersion( iParam )
end
-- 响应检测版本的消息
function p.OnMsg_CheckVersion( tNetData )
	LogInfo( "Update: OnMsg_CheckVersion()" );
	if ( p.GetUILayer == nil ) then
		LogInfo( "Update: OnMsg_CheckVersion() failed! layer is nil" );
		return;
	end
	local bLatest		= tNetData:ReadByte();
	local bForceUpdate	= tNetData:ReadByte();
	local FromVersion	= tNetData:ReadInt();
	local ToVersion		= tNetData:ReadInt();
	local UpdatePath	= tNetData:ReadUnicodeString();
	LogInfo( "Update: OnMsg_CheckVersion() bLatest:%d, bForceUpdate:%d, FromVersion:%d, ToVersion:%d",bLatest,bForceUpdate,FromVersion,ToVersion );
	LogInfo( "Update: OnMsg_CheckVersion() URL:" .. UpdatePath );
	
	local bNeedUpdate	= false;
	if ( bForceUpdate ~= 0 ) then
		LogInfo( "Update: OnMsg_CheckVersion() bForceUpdate is true" );
		p.pLabelPromtp:SetText( "请用户到重新下载最新游戏版本" );
		p.pLabelPromtp:SetVisible(true);
		return;
	elseif ( (FromVersion == ToVersion) and ( bLatest ~= 0) ) then
		LogInfo( "Update: OnMsg_CheckVersion() version is new" );
		p.pLabelPromtp:SetText( "当前版本是最新游戏版本" );
		p.InitWaitingTouch();
		return;
	elseif ( (FromVersion == ToVersion) and (bLatest == 0) ) then
		LogInfo( "Update: OnMsg_CheckVersion() version matching error" );
		p.pLabelPromtp:SetText( "当前版本太旧，请更新最新版本" );
		return;
	elseif ( (FromVersion == 0) and (ToVersion == 0) ) then
		LogInfo( "Update: OnMsg_CheckVersion() version information error" );
		p.pLabelPromtp:SetText( "版本信息被损坏，请重新下载" );
		return;
	else
		bNeedUpdate = true;
	end
	InitUpdateURLQueue( UpdatePath );
	if (  bLatest ~= 0 ) then
		-- 检测是否开启 WIFI ,是继续，否转哪？
		-- ...
		local bWIFIIsOn	= true;--
		--
		if ( bWIFIIsOn ) then
			StartUpdate();
		else
			--
			CommonDlgNew.ShowYesOrNoDlg( "未开启WIFI，继续？", p.Callback_Confirm, true );
		end
	end
	--return;
end

-- 不开启WIFI确认
function p.Callback_Confirm( nId, param )
	if ( CommonDlgNew.BtnOk == nId ) then
		StartUpdate();
	end
end

-- 开始下载--外部调用
function p.StartDownload()
	p.nUIStatus	=  UpdateUIStatus.Downloading;
	--
	p.pCtrlProgress:SetVisible(true);
	p.pCtrlProgress:SetProcess(0);
	p.pCtrlProgress:SetTotal(100);
	p.pCtrlProgress:SetStyle(2);
	--
	p.pLabelPromtp:SetVisible(true);
	p.pLabelPromtp:SetText( szDownloading );
end

---------------------------------------------------
function p.InitDownload()
	p.nUIStatus	=  UpdateUIStatus.Downloading;
	RegisterTimer( p.OnTimer_Download, nTimeInterval );
	--
	p.pCtrlProgress:SetVisible(true);
	p.pCtrlProgress:SetProcess(0);
	p.pCtrlProgress:SetTotal(100);
	p.pCtrlProgress:SetStyle(2);
	--
	p.pLabelPromtp:SetVisible(true);
	p.pLabelPromtp:SetText( szDownloading );
end

---------------------------------------------------
-- 响应计时器-下载---------------模拟下载进度
function p.OnTimer_Download( nTimerID )
	if ( p.nUIStatus ~=  UpdateUIStatus.Downloading ) then
		UnRegisterTimer(nTimerID);
		return;
	end
	local nProgress = p.pCtrlProgress:GetProcess();--
	local nTotal	= p.pCtrlProgress:GetTotal();
	nProgress = nProgress + nStep;
	if ( nTotal*0.9 <= nProgress ) then
		UnRegisterTimer(nTimerID);
		p.InitInstall();
	end
	p.pCtrlProgress:SetProcess(nProgress);
end

function p.ShowDownloadProgress( nPercent )
	p.pCtrlProgress:SetProcess(nPercent);
	p.pCtrlProgress:SetTotal(100);
end

function p.StartInstall()
	p.nUIStatus	=  UpdateUIStatus.Installing;
	--
	p.pLabelPromtp:SetVisible(true);
	p.pLabelPromtp:SetText( szInstalling );
end


---------------------------------------------------
-- 
function p.InitInstall()
	p.nUIStatus	=  UpdateUIStatus.Installing;
	RegisterTimer( p.OnTimer_Install, nTimeInterval );
	--
	p.pLabelPromtp:SetVisible(true);
	p.pLabelPromtp:SetText( szInstalling );
end


---------------------------------------------------
-- 响应计时器-安装---------------模拟安装进度
function p.OnTimer_Install( nTimerID )
	if ( p.nUIStatus ~=  UpdateUIStatus.Installing ) then
		UnRegisterTimer(nTimerID);
		return;
	end
	local nProgress = p.pCtrlProgress:GetProcess();--
	local nTotal	= p.pCtrlProgress:GetTotal();
	nProgress = nProgress + nStep;
	if ( nTotal <= nProgress ) then
		nProgress = nTotal;
		UnRegisterTimer(nTimerID);
		p.InitWaitingTouch();
	end
	p.pCtrlProgress:SetProcess(nProgress);
end

function p.ShowInstallProgress( nPercent )
	p.pCtrlProgress:SetProcess(nPercent);
	p.pCtrlProgress:SetTotal(100);
end


---------------------------------------------------
-- 安装完毕
function p.InitWaitingTouch()
	--p.nUIStatus	=  UpdateUIStatus.WaitingTouch;
	--p.pCtrlProgress:SetVisible(false);
	--p.pBtnTouch:SetVisible(true);
	--p.pLabelPromtp:SetVisible(true);
	--p.pLabelPromtp:SetText( szTouch );
	--p.pLabelPromtp:SetFontColor( ccc4(0xda,0xa5,0x20,255) );
	---- 摆中间
	--local tRect		= p.pLabelPromtp:GetFrameRect();
	--local tWinSize	= GetWinSize();
	--tRect			= CGRectMake( tWinSize.w/2 - tRect.size.w/2, tRect.origin.y, tRect.size.w, tRect.size.h );
	--p.pLabelPromtp:SetFrameRect( tRect );
	
	if ( p.nAccountID ~= nil ) then
		local nAccountID	= p.nAccountID;
		p.CloseUI();
		Entry.ShowUI( nAccountID );
	end
end


---------------------------------------------------
function p.LoginOK_Guest( nAccountID )
	if ( p.GetUILayer() == nil ) then
		LogInfo( "Update: LoginOK_Guest() failed! layer is nil" );
		return;
	end
	p.nAccountID = nAccountID;
	p.InitCheck();
end

function p.LoginOK_Normal( nAccountID )
	if ( p.GetUILayer() == nil ) then
		LogInfo( "Update: LoginOK_Normal() failed! layer is nil" );
		return;
	end
	p.nAccountID = nAccountID;
	p.InitCheck();
end

function p.LoginOK_Guest2Normal( nAccountID )
	if ( p.GetUILayer() == nil ) then
		LogInfo( "Update: LoginOK_Guest2Normal() failed! layer is nil" );
		return;
	end
	p.nAccountID = nAccountID;
	p.InitCheck();
end

function p.LoginError( nErrorCode )
	if ( p.GetUILayer() == nil ) then
		LogInfo( "Update: LoginError() failed! layer is nil" );
		return;
	end
	p.nAccountID = nil;
	p.pLabelPromtp:SetVisible(true);
	p.pLabelPromtp:SetText( szError );
	p.pLabelPromtp:SetFontColor( ccc4(255,0,0,255) );
end

---------------------------------------------------
--RegisterGlobalEventHandler( GLOBALEVENT.GE_UPDATE_GAME, "Update.ShowUI", p.ShowUI );
--
--RegisterGlobalEventHandler( GLOBALEVENT.GE_LOGINOK_GUEST, "Update.LoginOK_Guest", p.LoginOK_Guest );
--RegisterGlobalEventHandler( GLOBALEVENT.GE_LOGINOK_NORMAL, "Update.LoginOK_Normal", p.LoginOK_Normal );
--RegisterGlobalEventHandler( GLOBALEVENT.GE_LOGINOK_GUEST2NORMAL, "Update.LoginOK_Guest2Normal", p.LoginOK_Guest2Normal );
--RegisterGlobalEventHandler( GLOBALEVENT.GE_LOGINERROR, "Update.LoginError", p.LoginError);

--RegisterNetMsgHandler( NMSG_Type._MSG_CLIENT_VERSION, "Update.OnMsg_CheckVersion", p.OnMsg_CheckVersion );