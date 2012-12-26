---------------------------------------------------
--描述: 主线关卡扫荡（自动战斗）
--时间: 2012.6.14
--作者: Guosen
---------------------------------------------------
--从副本界面进入接口：		
--ClearUpSettingUI.LoadUI( nBattleID );
-- 参数：怪物点ID

--从登录时刻进入接口：		
--ClearUpSettingUI.LoadUIForLogin( nBattleID, nRemain, nTotal );
--参数： 怪物点ID, 剩余次数， 总数

---------------------------------------------------

ClearUpSettingUI = {}
local p = ClearUpSettingUI;

p.nBattleID						= 0;	-- 怪物点ID
p.nFightNumber					= 0;	-- 扫荡次数
p.nClearStage					= 0;	-- 已扫荡次数
p.nEndMoment					= 0;	-- 结束时刻（开始时刻+需要时间）
p.nTimerID						= 0;	-- 倒计时计时器的ID号
p.pEditFightNumber				= nil;	-- 输入扫荡次数的编辑控件
p.pLayerPrepare					= nil;	-- 预备扫荡层
p.pLayerFighting				= nil;	-- 正在扫荡层
p.nCancelFlag					= 0;	-- 停止还是离开0:stop,1:X
p.nExpAmount					= 0;	-- 累积奖励之经验
p.nMoneyAmount					= 0;	-- 累积奖励之银币
p.tItemsAmount					= {};	-- 累积奖励之道具--下标为道具名

p.pLabelCoutDownCounter			= nil;	-- 倒计时时间标签

---------------------------------------------------
local ID_LIST_CONTANER			= 5;	-- 列表项容器ID，Prepare.ini Fighting.ini 里一样
local ID_LABEL_TIME				= 12;	-- 显示时间"00:00:00"文本标签，Prepare.ini(预计时间) Fighting.ini(剩余时间) 里一样
local ID_LABEL_ENEMY_INFO		= 17;	-- 显示战斗遇到的敌人信息
local ID_LABEL_REWARD_INFO		= 17;	-- 显示战斗可获得的奖励累积信息
local ID_LABEL_CLEAR_STAGE		= 44;	-- 显示通关累计次数
local ID_EDIT_FIGHT_NUMBER		= 821;	-- 扫荡（自动战斗）次数
local ID_LABEL_TASK_NAME		= 3;	-- 副本名称
local ID_LIST_LABEL_CONT		= 148;	-- 右侧列表项容器ID--放文字

local ID_BTN_CLOSE				= 4;	-- 关闭按钮ID，Prepare.ini Fighting.ini 里一样
local ID_BTN_MAX				= 22;	-- 最大按钮ID，设置最大扫荡次数
local ID_BTN_START				= 18;	-- 开始按钮ID，开始扫荡
local ID_BTN_STOP				= 817;	-- 停止按钮ID，
local ID_BTN_FINISH				= 16;	-- 加速按钮ID，
local ID_BTN_BACK				= 18;	-- 返回按钮ID，

local ID_LIST_ITEM_LABEL		= 1;	-- 列表项文字标签
--** chh 2012-08-13 **--
p.ID_BTN_FINISH = ID_BTN_FINISH;

--
local SECONDS_PER_FIGHT			= 180;	-- 每次战斗的时间(单位秒)，3分钟
local ZORDER_LAYER				= 200;	-- 扫荡层的Z次序
local LIST_ITEM_HEIGHT			= 100;	-- 列表项高度
local DEFAULT_FIGHT_NUM			= 10;	-- 缺省扫荡次数，若军令小于该值则为实际值

---------------------------------------------------
-- 进入扫荡的接口，参数为怪物点ID
function p.LoadUI( nBattleID )
    p.nFightNumber				= 0;
    p.nClearStage				= 0;
    p.nEndMoment				= 0;
    p.nTimerID					= 0;
    p.pEditFightNumber			= nil;
    p.pLayerPrepare				= nil;
    p.pLayerFighting			= nil;
    p.pLabelCoutDownCounter		= nil;
    p.nCancelFlag				= 0;
	--LogInfo("ClearUpSetting: nBattleID is %d",nBattleID);
	p.nBattleID = nBattleID;
    
	local scene = GetSMGameScene();	
	if ( nil == scene ) then
		LogInfo("ClearUpSetting: LoadUI() failed! scene is nil");
		return;
	end
    
	local layer = createNDUILayer();
	if ( nil == layer ) then
		LogInfo("ClearUpSetting: LoadUI() failed! layer is nil");
		return false;
	end
    
    layer:SetPopupDlgFlag(true);
	layer:Init();
	layer:SetTag( NMAINSCENECHILDTAG.AffixBossClearUp );
	layer:SetFrameRect( RectFullScreenUILayer );
	--layer:SetBackgroundColor( ccc4(0, 0, 0, 0) );
	scene:AddChildZ( layer,ZORDER_LAYER );
	
	--初始化ui
	local uiLoad = createNDUILoad();
	if not CheckP(uiLoad) then
		LogInfo("ClearUpSetting: LoadUI() failed! uiLoad is nil");
		return false;
	end
	
	uiLoad:Load("AutoFightUI_Prepare.ini", layer, p.OnUIEventPrepare, 0, 0 );

	MsgAffixBoss.mUIListener = p.HandleNetMsg;	-- 设置网络消息的响应
	
	p.InitPrepareUI( layer );
	p.CreateFightingUI( layer );
	p.BackToPrepareUI();
end

---------------------------------------------------
function p.CloseUI()
	CloseUI( NMAINSCENECHILDTAG.AffixBossClearUp );
	MsgAffixBoss.mUIListener = nil;	-- 取消响应网络消息
    p.pEditFightNumber			= nil;
    p.pLayerPrepare				= nil;
    p.pLayerFighting			= nil;
    p.pLabelCoutDownCounter		= nil;
end

---------------------------------------------------
-- 返回时间格式字符串"00:00:00"，参数XX秒
function p.GetTimeString( nTime )
	local nH = math.floor( nTime / 3600 );
	local nM = math.floor( (nTime%3600) / 60 );
	local nS = nTime % 60;
	return string.format( "%02d:%02d:%02d", nH, nM, nS );
end

---------------------------------------------------
-- 初始化 Prepare UI--准备扫荡
function p.InitPrepareUI( pLayerPrepare )
	p.pLayerPrepare = pLayerPrepare;
	
	-- 输入框
	p.nFightNumber		= 0;
	local pUINode		= GetUiNode( p.pLayerPrepare, ID_EDIT_FIGHT_NUMBER );
	p.pEditFightNumber	= ConverToEdit( pUINode ) 
	p.pEditFightNumber:SetFlag( 1 );		-- 仅可输入数字
	p.pEditFightNumber:SetText( SafeN2S( p.nFightNumber ) );
	
	-- 时间标签
	local nAmountTime	= p.nFightNumber * SECONDS_PER_FIGHT;
	local pLabelTime	= GetLabel( p.pLayerPrepare, ID_LABEL_TIME );
	pLabelTime:SetText( p.GetTimeString( nAmountTime ) );
	
	-- 副本名
	local szName 		= AffixBossFunc.findName( p.nBattleID );
	local pLabelTaskName= GetLabel( p.pLayerPrepare, ID_LABEL_TASK_NAME );
	pLabelTaskName:SetText( szName );
	
	-- 左侧提示
	-- 容器
	local container 	= GetScrollViewContainer( p.pLayerPrepare, ID_LIST_CONTANER );
	if not CheckP(container) then
		LogInfo("ClearUpSetting: InitPrepareUI() failed! container is nil");
		return;
	end
    --container:EnableScrollBar(true);
	container:SetStyle( UIScrollStyle.Verical );
	local rectview		= container:GetFrameRect();
	container:SetViewSize( CGSizeMake(rectview.size.w, LIST_ITEM_HEIGHT) );
	
	-- 列表项
	local view = createUIScrollView();
	if not CheckP(view) then
		LogInfo("ClearUpSetting: InitPrepareUI() failed! view is nil");
		return;
	end
	view:Init(false);
	view:SetScrollStyle(UIScrollStyle.Verical);
	view:SetViewId(1);
	view:SetMovableViewer(container);
	view:SetScrollViewer(container);
	view:SetContainer(container);
	container:AddView(view);
	local nWidthLimit = rectview.size.w;
	local fontsize = 14;
	local str = GetTxtPri("CUSU_T1_1").."\n"..GetTxtPri("CUSU_T1_2").."\n"..GetTxtPri("CUSU_T1_3");
	local pLabelTips = _G.CreateColorLabel( str, fontsize, nWidthLimit );
	
	if CheckP(pLabelTips) then
		pLabelTips:SetFrameRect(CGRectMake(10, 20, nWidthLimit, 20 * ScaleFactor));
		view:AddChild(pLabelTips);
	end
	
	-- 敌军信息--
	local pLabelEnemyInfo = GetLabel( p.pLayerPrepare, ID_LABEL_ENEMY_INFO );
	if ( nil == pLabelEnemyInfo ) then
		LogInfo("ClearUpSetting: InitPrepareUI() failed! pLabelEnemyInfo is nil");
	end
	
	local szEnemyInfo	= "";
	
	local nGenerateRuleID	= GetDataBaseDataN( "mapzone", p.nBattleID, DB_MAPZONE.GENERATE_RULE_ID )
	local nMonsterType	= 0;
	local szMonsterName	= "";
	nMonsterType	= GetDataBaseDataN( "monster_generate", nGenerateRuleID, DB_MONSTER_GENERATE.STATIONS1 )
	if ( nMonsterType ~= nil ) and ( nMonsterType > 0 ) then
		szMonsterName	= GetDataBaseDataS( "monstertype", nMonsterType, DB_MONSTERTYPE.NAME );
		szEnemyInfo	= szEnemyInfo .. szMonsterName .."\n";
	end
	nMonsterType	= GetDataBaseDataN( "monster_generate", nGenerateRuleID, DB_MONSTER_GENERATE.STATIONS2 )
	if ( nMonsterType ~= nil ) and ( nMonsterType > 0 ) then
		szMonsterName	= GetDataBaseDataS( "monstertype", nMonsterType, DB_MONSTERTYPE.NAME );
		szEnemyInfo	= szEnemyInfo .. szMonsterName .."\n";
	end
	nMonsterType	= GetDataBaseDataN( "monster_generate", nGenerateRuleID, DB_MONSTER_GENERATE.STATIONS3 )
	if ( nMonsterType ~= nil ) and ( nMonsterType > 0 ) then
		szMonsterName	= GetDataBaseDataS( "monstertype", nMonsterType, DB_MONSTERTYPE.NAME );
		szEnemyInfo	= szEnemyInfo .. szMonsterName .."\n";
	end
	nMonsterType	= GetDataBaseDataN( "monster_generate", nGenerateRuleID, DB_MONSTER_GENERATE.STATIONS4 )
	if ( nMonsterType ~= nil ) and ( nMonsterType > 0 ) then
		szMonsterName	= GetDataBaseDataS( "monstertype", nMonsterType, DB_MONSTERTYPE.NAME );
		szEnemyInfo	= szEnemyInfo .. szMonsterName .."\n";
	end
	nMonsterType	= GetDataBaseDataN( "monster_generate", nGenerateRuleID, DB_MONSTER_GENERATE.STATIONS5 )
	if ( nMonsterType ~= nil ) and ( nMonsterType > 0 ) then
		szMonsterName	= GetDataBaseDataS( "monstertype", nMonsterType, DB_MONSTERTYPE.NAME );
		szEnemyInfo	= szEnemyInfo .. szMonsterName .."\n";
	end
	nMonsterType	= GetDataBaseDataN( "monster_generate", nGenerateRuleID, DB_MONSTER_GENERATE.STATIONS6 )
	if ( nMonsterType ~= nil ) and ( nMonsterType > 0 ) then
		szMonsterName	= GetDataBaseDataS( "monstertype", nMonsterType, DB_MONSTERTYPE.NAME );
		szEnemyInfo	= szEnemyInfo .. szMonsterName .."\n";
	end
	nMonsterType	= GetDataBaseDataN( "monster_generate", nGenerateRuleID, DB_MONSTER_GENERATE.STATIONS7 )
	if ( nMonsterType ~= nil ) and ( nMonsterType > 0 ) then
		szMonsterName	= GetDataBaseDataS( "monstertype", nMonsterType, DB_MONSTERTYPE.NAME );
		szEnemyInfo	= szEnemyInfo .. szMonsterName .."\n";
	end
	nMonsterType	= GetDataBaseDataN( "monster_generate", nGenerateRuleID, DB_MONSTER_GENERATE.STATIONS8 )
	if ( nMonsterType ~= nil ) and ( nMonsterType > 0 ) then
		szMonsterName	= GetDataBaseDataS( "monstertype", nMonsterType, DB_MONSTERTYPE.NAME );
		szEnemyInfo	= szEnemyInfo .. szMonsterName .."\n";
	end
	nMonsterType	= GetDataBaseDataN( "monster_generate", nGenerateRuleID, DB_MONSTER_GENERATE.STATIONS9 )
	if ( nMonsterType ~= nil ) and ( nMonsterType > 0 ) then
		szMonsterName	= GetDataBaseDataS( "monstertype", nMonsterType, DB_MONSTERTYPE.NAME );
		szEnemyInfo	= szEnemyInfo .. szMonsterName .."\n";
	end
		--LogInfo("ClearUpSetting: InitPrepareUI()  MonsterType:%d", nMonsterType);
		--local nLookface	= GetDataBaseDataN( "monstertype", nMonsterType, DB_MONSTERTYPE.LOOKFACE );
		--LogInfo("ClearUpSetting: InitPrepareUI()  MonsterName:%s, Lookface:%d", szMonsterName, nLookface);
	pLabelEnemyInfo:SetText(szEnemyInfo);
	
end




---------------------------------------------------
-- 响应 Prepare 界面 UI 事件--准备扫荡
function p.OnUIEventPrepare( uiNode, uiEventType, param )
	local tag = uiNode:GetTag();	
	local nStamina = PlayerFunc.GetStamina( GetPlayerId() );
	if ( uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK ) then
		if ( ID_BTN_CLOSE == tag ) then
			p.CloseUI();
			if ( NormalBossListUI.nCampaignID ~= nil ) then
				WorldMap(NormalBossListUI.nCampaignID); 
			end
			NormalBossListUI.Redisplay();
			return true;
		elseif ( ID_BTN_MAX == tag ) then
			-- 点击“最大”
			p.nFightNumber		= nStamina;
			p.pEditFightNumber:SetText( SafeN2S(p.nFightNumber) );
			local nAmountTime	= p.nFightNumber * SECONDS_PER_FIGHT;
			local pLabelTime	= GetLabel( p.pLayerPrepare, ID_LABEL_TIME );
			pLabelTime:SetText( p.GetTimeString( nAmountTime ) );
		elseif ( ID_BTN_START == tag ) then
			-- 点击“开始”
			p.OnBtnStart();
		end
	elseif ( uiEventType == NUIEventType.TE_TOUCH_EDIT_INPUT_FINISH ) then
    	local pEdit = ConverToEdit(uiNode);
    	if CheckP(pEdit) then
			if tag == ID_EDIT_FIGHT_NUMBER then
			    local nInputNumber = SafeS2N( pEdit:GetText() );
			    if ( nStamina < nInputNumber ) then
			    	p.nFightNumber = nStamina;
			    else
			    	p.nFightNumber = nInputNumber;
			    end
			    pEdit:SetText( SafeN2S(p.nFightNumber) );
			    
				local nAmountTime	= p.nFightNumber * SECONDS_PER_FIGHT;
				local pLabelTime	= GetLabel( p.pLayerPrepare, ID_LABEL_TIME );
				pLabelTime:SetText( p.GetTimeString( nAmountTime ) );
			end 
    	end
	end
	return true;
end

---------------------------------------------------
-- 响应“开始”按钮
function p.OnBtnStart()
	if ( p.pLayerFighting == nil ) then
		LogInfo("ClearUpSetting: OnBtnStart() failed! pLayerFighting is nil");
		return;
	end
	local nStamina = PlayerFunc.GetStamina( GetPlayerId() );
	if ( nStamina < 1  ) then
		CommonDlgNew.ShowYesDlg( GetTxtPri("CUSU_T2"), nil, nil, nil );
		return true;
	end
	if ( p.nFightNumber < 1 ) then
		LogInfo("ClearUpSetting: OnBtnStart() failed! nFightNumber < 1");
		CommonDlgNew.ShowYesDlg( GetTxtPri("CUSU_T3"), nil, nil, 3 );
		return;
	end

	--
	p.nClearStage	= 0;
	
	-- 发送消息给服务端，开始扫荡
	MsgAffixBoss.sendNmlClean( p.nBattleID, p.nFightNumber, true );
	--p.ShowFightingUI();
end
	
---------------------------------------------------
--显示自动战斗界面
function p.ShowFightingUI()
	local container 	= GetScrollViewContainer( p.pLayerFighting, ID_LIST_CONTANER );
	if not CheckP(container) then
		LogInfo("ClearUpSetting: ShowFightingUI() failed! container is nil");
		return;
	end
	local layer = createNDUILayer();
	layer:Init();
	local uiLoad=createNDUILoad();
	uiLoad:Load( "AutoFightUI_Fighting_L.ini", layer, nil, 0, 0 );
	uiLoad:Free();
	local pBorder = GetLabel( layer, ID_LIST_ITEM_LABEL );
	local tSize = pBorder:GetFrameRect().size;
	layer:Free();
	
	container:SetStyle( UIScrollStyle.Verical );
	--local rectview 		= container:GetFrameRect();
	container:SetViewSize(tSize);--(CGSizeMake(rectview.size.w, 150));--rectview.size.h));
	container:RemoveAllView();
	container:EnableScrollBar(true);
    
	local pBtnStop		= GetButton( p.pLayerFighting, ID_BTN_STOP );
	local pBtnFinish	= GetButton( p.pLayerFighting, ID_BTN_FINISH );
	local pBtnBack		= GetButton( p.pLayerFighting, ID_BTN_BACK );
	local pLabelClearStage		= GetLabel( p.pLayerFighting, ID_LABEL_CLEAR_STAGE );
	p.pLabelCoutDownCounter	= GetLabel( p.pLayerFighting, ID_LABEL_TIME );
	
	pBtnStop:SetVisible( true );
	pBtnFinish:SetVisible( true );
	pBtnBack:SetVisible( false );
	
	p.nEndMoment	= p.nFightNumber * SECONDS_PER_FIGHT + GetCurrentTime();
	
	-- 累积奖励信息
	p.nExpAmount			= 0;
	p.nMoneyAmount			= 0;
	p.tItemsAmount			= {};
	local pLabelRewardInfo	= GetLabel( p.pLayerFighting, ID_LABEL_REWARD_INFO );
	if ( nil == pLabelRewardInfo ) then
		LogInfo("ClearUpEliteSettingUI: CreateFightingUI() failed! pLabelRewardInfo is nil");
	end
	local szRewardInfo = "";--"经验+XYZ\n银币+LMN\n待定";
	pLabelRewardInfo:SetText( szRewardInfo );
	
	-- 已战斗次数统计
	pLabelClearStage:SetText( p.nClearStage .. "/" .. p.nFightNumber );
	p.pLabelCoutDownCounter:SetText( p.GetTimeString( p.nEndMoment - GetCurrentTime() ) );
	
	--
	p.AppendListItemLabel( GetTxtPri("CUSU_T4"), ccc4(0x10,0x33,0xcc,255) );
	
	-- 创建计时器，每1秒回调一次
	p.nTimerID = RegisterTimer( p.OnTimerCoutDownCounter, 1 );
	
	--
	p.pEditFightNumber:SetVisible( false );
	p.pLayerFighting:SetVisible( true );
end

---------------------------------------------------
-- 倒计时计时器的回调函数
function p.OnTimerCoutDownCounter( nTimerID )
	if not IsUIShow( NMAINSCENECHILDTAG.AffixBossClearUp ) then
		UnRegisterTimer( nTimerID );
		return;
	end
	local nTime	= p.nEndMoment - GetCurrentTime();
	if ( nTime <= 0 ) then
		nTime = 0;
		UnRegisterTimer( p.nTimerID );
		p.nTimerID = 0;
		CommonDlgNew.CloseOneDlg();--关闭掉“加速”弹出的消耗金币对话框、或“停止”弹出的确认框
	end
	p.pLabelCoutDownCounter:SetText( p.GetTimeString( nTime ) );
end

---------------------------------------------------
-- 创建 Fighting UI--正在扫荡
function p.CreateFightingUI( pParentLayer )
	local layer = createNDUILayer();
	if ( nil == layer ) then
		LogInfo("ClearUpSetting: CreateFightingUI() failed! layer is nil");
		return false;
	end
	layer:Init();
	layer:SetTag( NMAINSCENECHILDTAG.AffixBossClearUp );
	layer:SetFrameRect( RectFullScreenUILayer );
	--layer:SetBackgroundColor( ccc4(0, 0, 0, 0) );
	pParentLayer:AddChildZ( layer,3 );
	
	--初始化ui
	local uiLoad = createNDUILoad();
	if not CheckP(uiLoad) then
		LogInfo("ClearUpSetting: CreateFightingUI() failed! uiLoad is nil");
		return false;
	end
	
	uiLoad:Load("AutoFightUI_Fighting.ini", layer, p.OnUIEventFighting, 0, 0 );
	
	-- 副本名
	local szName 			= AffixBossFunc.findName( p.nBattleID );
	local pLabelTaskName	= GetLabel( layer, ID_LABEL_TASK_NAME );
	pLabelTaskName:SetText( szName );
	
	-- 累积奖励信息
	p.nExpAmount			= 0;
	p.nMoneyAmount			= 0;
	p.tItemsAmount			= {};
	local pLabelRewardInfo = GetLabel( layer, ID_LABEL_REWARD_INFO );
	if ( nil == pLabelRewardInfo ) then
		LogInfo("ClearUpSetting: CreateFightingUI() failed! pLabelRewardInfo is nil");
	end
	local szRewardInfo = "";--"经验+0\n银币+0";
	pLabelRewardInfo:SetText( szRewardInfo );
	
	p.pLayerFighting = layer;
end

---------------------------------------------------
-- 响应 Fighting 界面 UI 事件--正在扫荡
function p.OnUIEventFighting( uiNode, uiEventType, param )
	local tag = uiNode:GetTag();	
	if ( uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK ) then
		if ( ID_BTN_CLOSE == tag ) then
			--点击 "X"-- 从扫荡中返回到准备扫荡
			local pBtnBack		= GetButton( p.pLayerFighting, ID_BTN_BACK );
			if ( pBtnBack:IsVisibled() ) then
				p.BackToPrepareUI();
			else
				CommonDlgNew.ShowYesOrNoDlg( GetTxtPri("CUSU_T5"), p.Callback_StopAndBack, true );
			end
		elseif ( ID_BTN_STOP == tag ) then
			-- 点击“停止”
			p.OnBtnStop();
		elseif ( ID_BTN_FINISH == tag ) then
			-- 点击“加速”
			p.OnBtnFinish();
		elseif ( ID_BTN_BACK == tag ) then
			-- 点击“返回”
			p.BackToPrepareUI();
		end
	end
	return false;
end

---------------------------------------------------
-- 从正在扫荡界面返回到准备扫荡界面
function p.BackToPrepareUI()
	p.nFightNumber		= DEFAULT_FIGHT_NUM;
	local nStamina		= PlayerFunc.GetStamina( GetPlayerId() );
	if ( nStamina < DEFAULT_FIGHT_NUM  ) then
		p.nFightNumber		= nStamina;
	end
	local nAmountTime	= p.nFightNumber * SECONDS_PER_FIGHT;
	local pLabelTime	= GetLabel( p.pLayerPrepare, ID_LABEL_TIME );
	pLabelTime:SetText( p.GetTimeString( nAmountTime ) );
	p.pEditFightNumber:SetText( SafeN2S( p.nFightNumber ) );
	
	if ( p.nTimerID ~= 0 ) then
		UnRegisterTimer( p.nTimerID );
		p.nTimerID = 0;
	end
	
	p.pLayerFighting:SetVisible( false );
	p.pEditFightNumber:SetVisible( true );
end

---------------------------------------------------
-- 确定停止扫荡的回调
function p.Callback_StopAndBack( nId, param )
	if ( CommonDlgNew.BtnOk == nId ) then
		-- 发送取消扫荡消息
		p.nCancelFlag	= 1;
		MsgAffixBoss.sendNmlCancel( p.nBattleID );
		--以下改成在响应取消消息里执行
		--p.nEndMoment		= GetCurrentTime();
		--local pBtnStop		= GetButton( p.pLayerFighting, ID_BTN_STOP );
		--local pBtnFinish	= GetButton( p.pLayerFighting, ID_BTN_FINISH );
		--local pBtnBack		= GetButton( p.pLayerFighting, ID_BTN_BACK );
		--pBtnStop:SetVisible( false );
		--pBtnFinish:SetVisible( false );
		--pBtnBack:SetVisible( true );
		--p.BackToPrepareUI();
	end
end

---------------------------------------------------
-- 响应按下“停止”按钮，
function p.OnBtnStop()
	local pBtnBack		= GetButton( p.pLayerFighting, ID_BTN_BACK );
	if ( pBtnBack:IsVisibled() ) then
		return;
	end
	CommonDlgNew.ShowYesOrNoDlg( GetTxtPri("CUSU_T6"), p.Callback_StopAutoFight, true );
end

---------------------------------------------------
-- 确定停止扫荡的回调
function p.Callback_StopAutoFight( nId, param )
	if ( CommonDlgNew.BtnOk == nId ) then
		-- 发送取消扫荡消息
		p.nCancelFlag	= 0;
		MsgAffixBoss.sendNmlCancel( p.nBattleID );
		--以下改成在响应取消消息里执行
		--p.nEndMoment		= GetCurrentTime();
		--local pBtnStop		= GetButton( p.pLayerFighting, ID_BTN_STOP );
		--local pBtnFinish	= GetButton( p.pLayerFighting, ID_BTN_FINISH );
		--local pBtnBack		= GetButton( p.pLayerFighting, ID_BTN_BACK );
		--pBtnStop:SetVisible( false );
		--pBtnFinish:SetVisible( false );
		--pBtnBack:SetVisible( true );
	end
end


---------------------------------------------------
-- 响应按下“加速”按钮，实际上就是用金币换立即完成
function p.OnBtnFinish()
	local nTime = p.nEndMoment - GetCurrentTime();-- 剩余时间
	if ( nTime < 1 ) then
		return;
	end
	local nGold = ( nTime ) / 60;	-- 剩余时间转金币个数（每60秒1个）
	nGold = math.ceil( nGold );
	CommonDlgNew.ShowYesOrNoDlg( string.format(GetTxtPri("CUSU_T7"),nGold), p.Callback_CostGoldToFinish, true );
end

---------------------------------------------------
-- 确定消耗金币完成扫荡的回调
function p.Callback_CostGoldToFinish( nId, param )
	if ( CommonDlgNew.BtnOk == nId ) then
		local nPlayerID		= GetPlayerId();--User表中的ID
		local nPlayerGold	= GetRoleBasicDataN( nPlayerID, USER_ATTR.USER_ATTR_EMONEY );
		local nTime = p.nEndMoment - GetCurrentTime();-- 剩余时间
		if ( nTime < 1 ) then
			return;
		end
		local nGold = ( nTime ) / 60;	-- 剩余时间转金币个数（每60秒1个）
		nGold = math.ceil( nGold );
		if ( nPlayerGold >= nGold ) then
			MsgAffixBoss.sendNmlFinish( p.nBattleID );--发送"_MSG_AFFIX_BOSS_NML_FINISH"消息
		else
			CommonDlgNew.ShowYesDlg( GetTxtPri("CUSU_T8"), nil, nil, nil );
		end
	end
end


---------------------------------------------------
-- 处理网络消息
function p.HandleNetMsg( nMsgID, param )
    LogInfo("function p.HandleNetMsg( nMsgID, param ) nMsgID = %d", nMsgID);
	if ( nMsgID == nil ) then
		return;
	end
	if ( nMsgID == NMSG_Type._MSG_AFFIX_BOSS_NML_CLEARUP ) then
		-- 开始扫荡
		p.ShowFightingUI();
	elseif ( nMsgID == NMSG_Type._MSG_AFFIX_BOSS_CLEANUP_BATTLE ) then
		-- 战斗奖励（完成一次战斗）
		p.ShowRewardOnce( param );
		p.ShowTotalReward( param );
		-- 完成的战斗次数与时间从包里读取(待与服务器约定)/预定战斗次数也可从包里读，兼容之后Login进入
		p.nClearStage 		= p.nClearStage + 1;
		if ( p.nClearStage >= p.nFightNumber ) then
			--全部完成
			p.nClearStage	= p.nFightNumber;
		end
		p.nEndMoment		= GetCurrentTime()  + ( p.nFightNumber - p.nClearStage ) * SECONDS_PER_FIGHT;
		local pLabelClearStage	= GetLabel( p.pLayerFighting, ID_LABEL_CLEAR_STAGE );
		pLabelClearStage:SetText( p.nClearStage .. "/" .. p.nFightNumber );
		
		--杀怪事件 qbw
		TASK.ClearUpKillMonster(p.nBattleID);
		
		
	elseif ( nMsgID == NMSG_Type._MSG_AFFIX_BOSS_CLEANUP_RAISE ) then
		-- 副本奖励
	elseif ( nMsgID == NMSG_Type._MSG_AFFIX_BOSS_NML_FINISH ) then
		-- 完成
        p.nClearStage	= p.nFightNumber;
		p.nEndMoment	= GetCurrentTime()  + ( p.nFightNumber - p.nClearStage ) * SECONDS_PER_FIGHT;
		local pLabelClearStage	= GetLabel( p.pLayerFighting, ID_LABEL_CLEAR_STAGE );
		pLabelClearStage:SetText( p.nClearStage .. "/" .. p.nFightNumber );
        p.nClearStage	= p.nFightNumber;
		p.nEndMoment	= GetCurrentTime()  + ( p.nFightNumber - p.nClearStage ) * SECONDS_PER_FIGHT;
		local pLabelClearStage	= GetLabel( p.pLayerFighting, ID_LABEL_CLEAR_STAGE );
		pLabelClearStage:SetText( p.nClearStage .. "/" .. p.nFightNumber );
        
		local pBtnStop		= GetButton( p.pLayerFighting, ID_BTN_STOP );
		local pBtnFinish	= GetButton( p.pLayerFighting, ID_BTN_FINISH );
		local pBtnBack		= GetButton( p.pLayerFighting, ID_BTN_BACK );
		pBtnStop:SetVisible( false );
		pBtnFinish:SetVisible( false );
		pBtnBack:SetVisible( true );
		p.AppendListItemLabel( GetTxtPri("CUSU_T9"), ccc4(0x10,0x10,0xff,255) );
	elseif ( nMsgID == NMSG_Type._MSG_AFFIX_BOSS_NML_CANCEL ) then
		-- 取消
		local nBattleID			= param:ReadInt();
		local nServerCancelFlag	= param:ReadByte();--0普通，1背包满
		if ( nServerCancelFlag == 1 ) then
			p.AppendListItemLabel( GetTxtPri("CUSU_T10"), ccc4(0xff,0x0,0x0,255) );
		else
			p.AppendListItemLabel( GetTxtPri("CUSU_T11"), ccc4(0x10,0x10,0xff,255) );
		end
		p.nEndMoment		= GetCurrentTime();
		local pBtnStop		= GetButton( p.pLayerFighting, ID_BTN_STOP );
		local pBtnFinish	= GetButton( p.pLayerFighting, ID_BTN_FINISH );
		local pBtnBack		= GetButton( p.pLayerFighting, ID_BTN_BACK );
		pBtnStop:SetVisible( false );
		pBtnFinish:SetVisible( false );
		pBtnBack:SetVisible( true );
		if ( p.nCancelFlag	== 1 ) then--0停止1退出
			p.BackToPrepareUI();
		end
	end
end

---------------------------------------------------
-- 显示奖励累积
function p.ShowTotalReward( tData )
	p.nExpAmount		= p.nExpAmount + tData.nExp;
	p.nMoneyAmount		= p.nMoneyAmount + tData.nMoney;
	for i = 1, #tData.tItems do
		local nItemType		= tData.tItems[i].nItemType;
		local nItemAmount	= tData.tItems[i].nItemAmount;
		local szItemName	= ItemFunc.GetName( nItemType );
		if ( p.tItemsAmount[szItemName] ~= nil ) then
			nItemAmount = nItemAmount + p.tItemsAmount[szItemName];
		end
		p.tItemsAmount[szItemName] = nItemAmount;
	end	

	local szReward = GetTxtPub("exp").."+" .. p.nExpAmount .. "\n"..GetTxtPub("coin").."+" .. p.nMoneyAmount; 
	for key, value in pairs( p.tItemsAmount ) do
		szReward	= szReward .. "\n" .. key .. " × " .. value ;
	end
	local pLabelRewardInfo	= GetLabel( p.pLayerFighting, ID_LABEL_REWARD_INFO );
	pLabelRewardInfo:SetText( szReward );
end

---------------------------------------------------
-- 显示一次战斗奖励
function p.ShowRewardOnce( tData )
	local nExp			= tData.nExp;
	local nMoney		= tData.nMoney;
	local nItemCount	= table.getn( tData.tItems );
	local szResult		= GetTxtPri("CUSU_T13");
	p.AppendListItemLabel( szResult, ccc4(0x0,0xff,0x0,255) );
	local szResult		= GetTxtPri("CUSU_T12") .. nExp .. GetTxtPub("exp") .."，" .. nMoney .. GetTxtPub("coin");
	p.AppendListItemLabel( szResult );
	for i = 1, nItemCount do
		local nItemType		= tData.tItems[i].nItemType;
		local nItemAmount	= tData.tItems[i].nItemAmount;
		local szItemName	= ItemFunc.GetName( nItemType );
		szResult = szItemName .. " × " .. nItemAmount ;
		p.AppendListItemLabel( szResult );
	end	
end

---------------------------------------------------
-- 获得战斗奖励信息字符串
--function p.GetBattleItemInfo( tData )--d
--	local nExp			= tData.nExp;
--	local nMoney		= tData.nMoney;
--	local nItemCount	= table.getn( tData.tItems );
--	local szResult = "战斗胜利!\n获得：" .. nExp .. "经验，" .. nMoney .. "银币";
--	for i = 1, nItemCount do
--		local nItemType		= tData.tItems[i].nItemType;
--		local nItemAmount	= tData.tItems[i].nItemAmount;
--		local szItemName	= ItemFunc.GetName( nItemType );
--		szResult = szResult .. "\n" .. szItemName .. " × " .. nItemAmount ;
--	end	
--	return szResult;
--end


---------------------------------------------------
-- 获得副本奖励信息字符串（服务端未定该消息数据包结构）
--function p.GetRaiseItemInfo( data )
--	local rtn = "副本评价奖励\n"
--	local soph = data.soph;
--	local money = data.money;
--	local itemId = data.item;
--	local count = data.count;
--	local lst = data.list;
--	for i = 1, count do
--		local strPetName = ConvertS(RolePetFunc.GetPropDesc(lst[i].petId, PET_ATTR.PET_ATTR_NAME));
--		strPetName = strPetName or ""
--		if (i ~= 1) then
--		rtn = rtn ..","
--		end
--		local sexp = SafeN2S(lst[i].petExp);
--	    --local SexP = SafeS2N(lst[i].petExp);
--	    --LogInfo(sexp);
--	    --LogInfo("SexP%d", SexP);
--	        --allExp = SexP+allExp;
--		rtn = rtn .. strPetName .."<c00ff00经验+" .. sexp .. "/e";
--	end
--	rtn = rtn .. "\n副本奖励 " ;
--	if soph > 0 then
--		local ssoph = SafeN2S(soph)
--		rtn  = rtn .. "<cfb6003阅历+" .. ssoph .. "/e";
--	end
--	if money > 0 then
--		local smoney = SafeN2S(money);
--		rtn = rtn .. " <c00ff00银币+" .. smoney .. "/e";
--	end
--	rtn = rtn .."\n战利品 "
--	if (itemId > 0) then
--		local name = ItemFunc.GetName(itemId);
--		name = name or "无";
--		if name == "" then
--			name = "无";
--		end
--		rtn = rtn .. name;
--	else
--		rtn = rtn .. "无"
--	end
--	
--	LogInfo("rase boss rtn%s", rtn);
--	
--	return rtn;
--	
--end


---------------------------------------------------
-- 增加左侧的列表项()
--function p.AppendLeftListItem( strData )
--	
--	if ( strData == nil or strData == "" ) then
--		LogInfo("ClearUpSetting: AppendLeftListItem() failed! strData is nil");
--		return;
--	end
--
--	-- 左侧提示
--	local container 	= GetScrollViewContainer( p.pLayerFighting, ID_LIST_CONTANER );
--	if not CheckP(container) then
--		LogInfo("ClearUpSetting: AppendLeftListItem() failed! container is nil");
--		return;
--	end
--	container:SetStyle( UIScrollStyle.Verical );
--	local rectview 		= container:GetFrameRect();
--	container:SetViewSize(CGSizeMake(rectview.size.w, 150));--rectview.size.h));
--	
--	local nFontSize		= 12;
--	local nWidthLimit	= rectview.size.w;
--	local tTextSize		= _G.GetHyperLinkTextSize( strData, nFontSize, nWidthLimit );
--	local pColorLabel	= _G.CreateColorLabel( strData, nFontSize, nWidthLimit );
--	
--	local view = createUIScrollView();
--	view:Init(false);
--	view:SetScrollStyle(UIScrollStyle.Verical);
--	--view:SetViewId(i);
--	view:SetMovableViewer(container);
--	view:SetScrollViewer(container);
--	view:SetContainer(container);
--	container:AddView(view);
--	pColorLabel:SetFrameRect( CGRectMake( 0, 0, nWidthLimit, tTextSize.h ) );
--	view:AddChild(pColorLabel);
--end


---------------------------------------------------
-- 添加列表项标签
function p.AppendListItemLabel( szText, tColor )
	if ( szText == nil or szText == "" ) then
		LogInfo("ClearUpSetting: AppendListItemLabel() failed! szText is nil");
		return;
	end
	local container 	= GetScrollViewContainer( p.pLayerFighting, ID_LIST_CONTANER );
	if not CheckP(container) then
		LogInfo("ClearUpSetting: AppendListItemLabel() failed! container is nil");
		return;
	end
	local view = createUIScrollView();
	view:Init(false);
	view:SetScrollStyle(UIScrollStyle.Verical);
	view:SetMovableViewer(container);
	view:SetScrollViewer(container);
	view:SetContainer(container);
	container:AddView(view);
	local uiLoad = createNDUILoad();
	uiLoad:Load( "AutoFightUI_Fighting_L.ini", view, nil, 0, 0 );
	uiLoad:Free();
	local pLabel = GetLabel( view, ID_LIST_ITEM_LABEL );
	if ( pLabel == nil ) then
		LogInfo("ClearUpSetting: AppendListItemLabel() failed! pLabel is nil");
		return;
	end
	pLabel:SetText( szText );
	if ( tColor ~= nil ) then
		pLabel:SetFontColor( tColor );
	end
	--view:SetBackgroundColor( ccc4(125, 125, 125, 0) );

	-- 尽量显示末行
	local rectview	= container:GetFrameRect();
	local tSize		= pLabel:GetFrameRect().size;
	local nLineNum	= rectview.size.h/tSize.h;
	local nVewCount	= container:GetViewCount();
	if ( nVewCount > nLineNum ) then
		container:ShowViewByIndex( nVewCount-nLineNum );
	end
end


---------------------------------------------------
-- 登录时刻，有处于扫荡状态则进入扫荡界面
function p.LoadUIForLogin( nBattleID, nRemain, nTotal )
    LogInfo( "function p.LoadUIForLogin( nBattleID = %d, nRemain = %d, nTotal = %d ) ", nBattleID, nRemain, nTotal);
	p.LoadUI( nBattleID );
	p.nFightNumber = nTotal;
	p.nClearStage	= nTotal - nRemain;
	p.ShowFightingUI();
end
