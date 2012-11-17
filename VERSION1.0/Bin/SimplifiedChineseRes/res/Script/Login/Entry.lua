---------------------------------------------------
--描述: 入口界面
--时间: 2012.8.7
--作者: Guosen
---------------------------------------------------

Entry = {}
local p = Entry;


---------------------------------------------------
local ID_BTN_TOUCH						= 3;	-- 按钮控件ID
local ID_BTN_LOCAL_SERVER				= 2;	-- 内服按钮控件ID


---------------------------------------------------
local LOCAL_WORLD_SERVER_IP				= "121.207.239.91"	-- 内网世界服务器IP
--local EXTERNAL_WORLD_SERVER_IP			= "222.77.177.209"	-- 外网世界服务器IP
local EXTERNAL_WORLD_SERVER_IP				= "121.207.239.91"	-- 内网世界服务器IP
--local EXTERNAL_WORLD_SERVER_IP			= "222.77.177.176"	-- 外网世界服务器IP mobage测试
---------------------------------------------------
p.nAccountID	= nil;

---------------------------------------------------
function p.GetCurrentScene()
	local pScene = GetSMLoginScene();
	if ( pScene == nil ) then
		LogInfo( "Entry: GetCurrentScene() pScene is nil" );
	end
	return pScene;
end

---------------------------------------------------
-- 所在层
function p.GetUILayer()
    local pScene = p.GetCurrentScene();
    local pLayer = GetUiLayer( pScene, NMAINSCENECHILDTAG.Entry );
    if not CheckP( pLayer ) then
        LogInfo( "Entry: GetUILayer() pLayer is nil" );
        return nil;
    end
    return pLayer;
end

---------------------------------------------------
--装载UI并显示
function p.ShowUI( nAccountID )
	LogInfo( "Entry: ShowUI() nAccountID:%d",nAccountID );
    local pScene = p.GetCurrentScene();
    if ( pScene == nil ) then
		LogInfo( "Entry: ShowUI() failed! pScene is nil" );
        return false;
    end
	
	local pLayer = createNDUILayer();
	if ( pLayer == nil ) then
		LogInfo( "Entry: ShowUI() failed! pLayer is nil" );
		return false;
	end
	pLayer:Init();
	pLayer:SetTag( NMAINSCENECHILDTAG.Entry );
	pLayer:SetFrameRect( RectFullScreenUILayer );
	--layer:SetBackgroundColor( ccc4(125, 125, 125, 0) );
	pScene:AddChild( pLayer );
	
	--初始化ui
	local uiLoad = createNDUILoad();
	if not CheckP(uiLoad) then
		LogInfo( "Entry: ShowUI() failed! uiLoad = nil" );
		return false;
	end
	uiLoad:Load( "EntryUI.ini", pLayer, p.OnUIEvent, 0, 0 );
	uiLoad:Free();
	
	local pBtn = GetButton( pLayer, ID_BTN_LOCAL_SERVER );
	if ( pBtn ~= nil ) then
		pBtn:SetVisible( false );
	end
	
	p.nAccountID = nAccountID;
	--播放背景音乐
	Music.PlayLoginMusic();
    return true;
end

---------------------------------------------------
function p.CloseUI()
	local scene = p.GetCurrentScene();
	if scene ~= nil then
		scene:RemoveChildByTag( NMAINSCENECHILDTAG.Entry, true );
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
				Login_ServerUI.worldIP	= EXTERNAL_WORLD_SERVER_IP;
				Login_ServerUI.LoadUI();
				Login_ServerUI.LoginOK_Normal( nAccountID )
			end
		elseif ( ID_BTN_LOCAL_SERVER == tag ) then
				nAccountID = p.nAccountID;
				p.CloseUI();
				SqliteConfig.InitDataBaseTable();
				Login_ServerUI.worldIP	= LOCAL_WORLD_SERVER_IP;
				Login_ServerUI.LoadUI();
				Login_ServerUI.LoginOK_Normal( nAccountID )
		end
	end
	return true;
end

---------------------------------------------------