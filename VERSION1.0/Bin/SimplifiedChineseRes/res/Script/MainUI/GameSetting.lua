---------------------------------------------------
--描述: 游戏设置界面
--时间: 2012.7.26
--作者: Guosen
---------------------------------------------------
--进入界面				GameSetting.ShowUI()
---------------------------------------------------
--是否显示其他玩家		GameSetting.IsShowOtherRole()
---------------------------------------------------

GameSetting = {}
local p = GameSetting;

---------------------------------------------------
local ID_BTN_CLOSE					= 6;	-- X
local ID_BTN_CHANGE_ACCOUNT			= 1;	-- 更换账号按钮ID
local ID_BTN_CHANGE_SERVER			= 2;	-- 更换服务器按钮ID
local ID_BTN_CALL_GM				= 3;	-- 联系GM按钮ID
local ID_BTN_VISIT_GAME_FORUM		= 4;	-- 访问游戏论坛按钮ID
local ID_CHECK_PLAY_BGM				= 15;	-- 播放背景音乐选择控件ID
local ID_CHECK_PLAY_EFFECT			= 16;	-- 播放音效选择控件ID
local ID_CHECK_SHOW_OTHER_PLAYER	= 17;	-- 查看其它玩家选择控件ID

---------------------------------------------------
local szGameSettingTableName		= "GameSetting";
local szGameSettingCreate			= "CREATE TABLE GameSetting ( SettingID INTEGER, BGMusic INTEGER, SoundEffect INTEGER, ViewOtherPlayer INTEGER );";
local szGameSettingUpdate			= "UPDATE GameSetting SET SettingID=1, BGMusic=%d, SoundEffect=%d, ViewOtherPlayer=%d WHERE SettingID=1";
local szGameSettingInsert			= "INSERT INTO GameSetting VALUES(1, %d, %d, %d)";
local szGameSettingSelect			= "Select * From GameSetting";
local szGameForumURL				= "http://bbs.18183.com/forum-54-1.html"--"http://mobage.com.cn/";--论坛地址，先测试

---------------------------------------------------
local DEFAULT_BGMUSIC				= 1;	-- 缺省设置播放背景音乐
local DEFAULT_EFFECT				= 1;	-- 缺省设置播放音效
local DEFAULT_VIEWPLAYER			= 1;	-- 缺省设置显示其他玩家

local MUSIC_VOLUME_MAX				= 100;	-- 音乐的最大音量
local EFFECT_VOLUME_MAX				= 100;	-- 音效的最大音量

---------------------------------------------------
p.iPlayBGMEnable					= nil;	-- 能否播放背景音乐
p.iPlayEffectEnable					= nil;	-- 能否播放音效
p.iShowOtherPlayerEnable			= nil;	-- 能否显示其他玩家

---------------------------------------------------
function p.GetCurrentScene()
	--local pDirector = DefaultDirector();
	--if ( pDirector == nil ) then
	--	LogInfo( "PlayEffectAnimation: pDirector == nil" );
	--	return nil;
	--end
	--local pScene = pDirector:GetRunningScene();
	local pScene = GetSMGameScene();
	if ( pScene == nil ) then
		LogInfo( "GameSetting: GetCurrentScene() pScene is nil" );
	end
	return pScene;
end

---------------------------------------------------
-- 所在层
function p.GetAniLayer()
    local pScene = p.GetCurrentScene();
    local pLayer = GetUiLayer( pScene, NMAINSCENECHILDTAG.GameSetting );
    if not CheckP( pLayer ) then
		LogInfo( "GameSetting: GetAniLayer() pLayer is nil" );
		return nil;
    end
    return pLayer;
end

---------------------------------------------------
--装载UI并显示
function p.ShowUI()
    local pScene = p.GetCurrentScene();
    if ( pScene == nil ) then
		LogInfo( "GameSetting: ShowUI() failed! pScene is nil" );
		return false;
    end
	
	local pLayer = createNDUILayer();
	if ( pLayer == nil ) then
		LogInfo( "GameSetting: ShowUI() failed! pLayer is nil" );
		return false;
	end
	
	pLayer:SetPopupDlgFlag( true );
	pLayer:Init();
	pLayer:SetTag( NMAINSCENECHILDTAG.GameSetting );
	pLayer:SetFrameRect( RectFullScreenUILayer );
	--layer:SetBackgroundColor( ccc4(125, 125, 125, 0) );
	pScene:AddChild( pLayer );
	
	--初始化ui
	local uiLoad = createNDUILoad();
	if not CheckP(uiLoad) then
		LogInfo( "GameSetting: ShowUI() failed! uiLoad = nil" );
		return false;
	end
	uiLoad:Load( "GameSettingUI.ini", pLayer, p.OnUIEvent, 0, 0 );
	uiLoad:Free();
	p.InitializeUI( pLayer );
	local pBtn = GetButton( pLayer, ID_BTN_CALL_GM );
	if ( pBtn ~= nil ) then
		pBtn:SetVisible( false );
	end

    local closeBtn=GetButton(pLayer,ID_BTN_CLOSE);
    closeBtn:SetSoundEffect(Music.SoundEffect.CLOSEBTN);

    return true;
end

---------------------------------------------------
function p.CloseUI()
	local scene = p.GetCurrentScene(); 
	if scene ~= nil then
		scene:RemoveChildByTag( NMAINSCENECHILDTAG.GameSetting, true );
		return true;
	end
	return false;
end

---------------------------------------------------
function p.InitializeUI( pLayer )
	p.LoadData();
	local pBtnChkPlayBGM		= RecursiveCheckBox ( pLayer, {ID_CHECK_PLAY_BGM} );
	local pBtnChkPlayEffect		= RecursiveCheckBox ( pLayer, {ID_CHECK_PLAY_EFFECT} );
	local pBtnChkPlayViewPlayer	= RecursiveCheckBox ( pLayer, {ID_CHECK_SHOW_OTHER_PLAYER} );
	if ( p.iPlayBGMEnable == 0 ) then
		pBtnChkPlayBGM:SetSelect( false );
	else
		pBtnChkPlayBGM:SetSelect( true );
	end
	if ( p.iPlayEffectEnable == 0 ) then
		pBtnChkPlayEffect:SetSelect( false );
	else
		pBtnChkPlayEffect:SetSelect( true );
	end
	if ( p.iShowOtherPlayerEnable == 0 ) then
		pBtnChkPlayViewPlayer:SetSelect( false );
	else
		pBtnChkPlayViewPlayer:SetSelect( true );
	end
end

---------------------------------------------------
--响应事件
function p.OnUIEvent( uiNode, uiEventType, param )
	local tag = uiNode:GetTag();
	if ( uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK ) then
		if ( ID_BTN_CLOSE == tag ) then
			p.CloseUI();
		elseif ( ID_BTN_CHANGE_ACCOUNT == tag ) then
			p.OnBtnChangeAccount();
		elseif ( ID_BTN_CHANGE_SERVER == tag ) then
			p.OnBtnChangeServer();
		elseif ( ID_BTN_CALL_GM == tag ) then
			p.OnBtnCallGM();
		elseif ( ID_BTN_VISIT_GAME_FORUM == tag ) then
			p.OnBtnVisitGameForum();
		end
	elseif ( uiEventType == NUIEventType.TE_TOUCH_CHECK_CLICK ) then
		if ( ID_CHECK_PLAY_BGM == tag ) then
			local pCheckBox = ConverToCheckBox( uiNode );
			if ( pCheckBox:IsSelect() ) then
				p.iPlayBGMEnable = 1;
			else
				p.iPlayBGMEnable = 0;
			end
			p.SaveData();
			-- 设置音乐音量
			if ( p.iPlayBGMEnable == 1 ) then
				StartBGMusic();
				--SetBgMusicVolume( MUSIC_VOLUME_MAX );
			else
				StopBGMusic();
				--SetBgMusicVolume( 0 );
			end
		elseif ( ID_CHECK_PLAY_EFFECT == tag ) then
			local pCheckBox = ConverToCheckBox( uiNode );
			if ( pCheckBox:IsSelect() ) then
				p.iPlayEffectEnable = 1;
			else
				p.iPlayEffectEnable = 0;
			end
			p.SaveData();
			-- 设置音效音量
			if ( p.iPlayEffectEnable == 1 ) then
				ResumeAllEffectSound();
				SetEffectSoundVolune( EFFECT_VOLUME_MAX );
			else
				StopEffectSound();
				--SetEffectSoundVolune( 0 );
			end
		elseif ( ID_CHECK_SHOW_OTHER_PLAYER == tag ) then
			local pCheckBox = ConverToCheckBox( uiNode );
			if ( pCheckBox:IsSelect() ) then
				p.iShowOtherPlayerEnable = 1;
			else
				p.iShowOtherPlayerEnable = 0;
			end
			p.SaveData();
    		ShowOtherRole( p.iShowOtherPlayerEnable == 1 );
		end
	end
	return true;
end


---------------------------------------------------
function p.OnBtnChangeAccount()
	p.CloseUI();
	doNDSdkChangeLogin();
end

---------------------------------------------------
function p.OnBtnChangeServer()
	p.CloseUI();
	QuitGame();
end

---------------------------------------------------
function p.OnBtnCallGM()
	--p.CloseUI();
	--GMProblemUI.LoadUI();
    p.TestButtonClick();
    
end


function p.TestButtonClick()
	CommonDlgNew.ShowYesOrNoDlg(GetTxtPri("GS2_T1"), p.SendMsgDelPlayer1, true);	
end

function p.SendMsgDelPlayer1(nEventType , nEvent, param)
	if(CommonDlgNew.BtnOk == nEventType) then
		LogInfo("p.SendMsgDelPlayer1")	
		
   		CommonDlgNew.ShowYesOrNoDlg(GetTxtPri("GS2_T2"), p.SendMsgDelPlayer2, true);	
   	end
end

function p.SendMsgDelPlayer2(nEventType , nEvent, param)
	if(CommonDlgNew.BtnOk == nEventType) then
		local netdata = createNDTransData(1053);
		if nil == netdata then
			return false;
		end
		--netdata:WriteByte(nAction);
		netdata:WriteInt(GetPlayerId());
		SendMsg(netdata);
		netdata:Free();
		LogInfo("p.SendMsgDelPlayer");
        QuitGame();
	end
end



---------------------------------------------------
function p.OnBtnVisitGameForum()
	p.CloseUI();
	OpenURL( szGameForumURL );
end

---------------------------------------------------
function p.LoadData()
    local isExists = Sqlite_IsExistTable(szGameSettingTableName);
    LogInfo("guohao %s",szGameSettingTableName);
    if not isExists then
		LogInfo( "GameSetting: CreateTable:" .. szGameSettingTableName );
		Sqlite_ExcuteSql(szGameSettingCreate);
		p.iPlayBGMEnable			= DEFAULT_BGMUSIC;
		p.iPlayEffectEnable			= DEFAULT_EFFECT;
		p.iShowOtherPlayerEnable	= DEFAULT_VIEWPLAYER;
		Sqlite_ExcuteSql( string.format(szGameSettingInsert, p.iPlayBGMEnable, p.iPlayEffectEnable, p.iShowOtherPlayerEnable) );
		--LogInfo( "GameSetting: LoadData() nobody [%d], [%d], [%d]", p.iPlayBGMEnable, p.iPlayEffectEnable, p.iShowOtherPlayerEnable );
    else
    	local nCount				= Sqlite_SelectData( szGameSettingSelect, 4 );
		p.iPlayBGMEnable			= Sqlite_GetColDataN(0,1);
		p.iPlayEffectEnable			= Sqlite_GetColDataN(0,2);
		p.iShowOtherPlayerEnable	= Sqlite_GetColDataN(0,3);
		LogInfo( "GameSetting: LoadData() Exists [%d], [%d], [%d]", p.iPlayBGMEnable, p.iPlayEffectEnable, p.iShowOtherPlayerEnable );
    end
    -- 设置音乐音量
	if ( p.iPlayBGMEnable == 1 ) then
		SetBgMusicVolume( MUSIC_VOLUME_MAX );
	else
		StopBGMusic();
		--SetBgMusicVolume( 0 );
	end
    -- 设置音效音量
	if ( p.iPlayEffectEnable == 1 ) then
		SetEffectSoundVolune( EFFECT_VOLUME_MAX );
	else
		StopEffectSound();
		--SetEffectSoundVolune( 0 );
	end
    ShowOtherRole( p.iShowOtherPlayerEnable == 1 );
end

-- 是否显示其他玩家
function p.IsShowOtherRole()
	return ( p.iShowOtherPlayerEnable == 1 );
end

---------------------------------------------------
function p.SaveData()
    --local isExists = Sqlite_IsExistTable(szGameSettingTableName);
    local nCount = Sqlite_SelectData( szGameSettingSelect, 4 );
    if nCount > 0 then
		--LogInfo( "GameSetting: SaveData() Exists [%d], [%d], [%d]", p.iPlayBGMEnable, p.iPlayEffectEnable, p.iShowOtherPlayerEnable );
		Sqlite_ExcuteSql( string.format(szGameSettingUpdate, p.iPlayBGMEnable, p.iPlayEffectEnable, p.iShowOtherPlayerEnable) );
    else
    end
end


