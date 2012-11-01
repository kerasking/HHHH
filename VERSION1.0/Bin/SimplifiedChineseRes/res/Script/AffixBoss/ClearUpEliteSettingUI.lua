---------------------------------------------------
--描述: 精英副本的扫荡
--时间: 2012.6.16
--作者: Guosen
---------------------------------------------------
--从副本界面进入接口：		
--ClearUpEliteSettingUI.LoadUI( nCampaignID );
-- 参数：片区点ID

--从登录时刻进入接口：		
--ClearUpEliteSettingUI.LoadUIForLogin( nCampaignID, nRemain, nTotal );
--参数： 副本点ID, 剩余次数， 总数

---------------------------------------------------

ClearUpEliteSettingUI = {}
local p = ClearUpEliteSettingUI;


p.nCampaignID					= 0;	-- 副本片区点ID-戰役ID
p.nFightNumber					= 0;	-- 扫荡次数
p.nClearStage					= 0;	-- 已扫荡次数
p.nEndMoment					= 0;	-- 结束时刻（开始时刻+需要时间）
p.nTimerID						= 0;	-- 倒计时计时器的ID号
p.pLayerPrepare					= nil;	-- 预备扫荡层
p.pLayerFighting				= nil;	-- 正在扫荡层
p.nCancelFlag					= 0;	-- 停止还是离开0:stop,1:X
p.nExpAmount					= 0;	-- 累积奖励之经验
p.nMoneyAmount					= 0;	-- 累积奖励之银币
p.tItemsAmount					= {};	-- 累积奖励之道具--下标为道具名
p.tEnemyID						= {};	-- 可扫荡的敌人ID表
p.nCrtIndex						= 1;	-- 当前敌人ID在敌人ID表的索引

p.pLabelCoutDownCounter			= nil;	-- 倒计时时间标签

---------------------------------------------------
local ID_LIST_CONTANER			= 5;	-- 列表项容器ID，Prepare.ini Fighting.ini 里一样
local ID_LABEL_TIME				= 12;	-- 显示时间"00:00:00"文本标签，Prepare.ini(预计时间) Fighting.ini(剩余时间) 里一样
local ID_LABEL_ENEMY_INFO		= 17;	-- 显示战斗遇到的敌人信息
local ID_LABEL_REWARD_INFO		= 17;	-- 显示战斗可获得的奖励信息
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

--
local SECONDS_PER_FIGHT			= 180;	-- 每次战斗的时间(单位秒)，3分钟
local ZORDER_LAYER				= 200;	-- 扫荡层的Z次序
local LIST_ITEM_HEIGHT			= 100;	-- 列表项高度
--local N_GOLD_RESET				= 10;	-- 重置一次精英副本需要的金币
local N_GOLD_RESET ={[0]=100,[1]=300,[2]=500}


---------------------------------------------------
-- 进入扫荡的接口，参数为战役ID/副本片区MAP ID
function p.LoadUI( nCampaignID )
p.nFightNumber				= 0;
p.nClearStage				= 0;
p.nEndMoment				= 0;
p.nTimerID					= 0;
p.pLayerPrepare				= nil;
p.pLayerFighting			= nil;
p.pLabelCoutDownCounter		= nil;
p.nCancelFlag				= 0;
p.tEnemyID					= {};
p.nCrtIndex					= 1;
	--LogInfo("ClearUpEliteSettingUI: nCampaignID is %d",nCampaignID);
	p.nCampaignID = nCampaignID;
	local scene = GetSMGameScene();	
	if ( nil == scene ) then
		LogInfo("ClearUpEliteSettingUI: LoadUI() failed! scene is nil");
		return;
	end
	local layer = createNDUILayer();
	if ( nil == layer ) then
		LogInfo("ClearUpEliteSettingUI: LoadUI() failed! layer is nil");
		return false;
	end
	layer:Init();
	layer:SetTag( NMAINSCENECHILDTAG.AffixBossClearUpElite );
	layer:SetFrameRect( RectFullScreenUILayer );
	--layer:SetBackgroundColor( ccc4(0, 0, 0, 0) );
	scene:AddChildZ( layer,ZORDER_LAYER );
	
	--初始化ui
	local uiLoad = createNDUILoad();
	if not CheckP(uiLoad) then
		LogInfo("ClearUpEliteSettingUI: LoadUI() failed! uiLoad is nil");
		return false;
	end
	
	uiLoad:Load("AutoFightUI_Prepare.ini", layer, p.OnUIEventPrepare, 0, 0 );

	MsgAffixBoss.mUIListener = p.HandleNetMsg;	-- 设置网络消息的响应
	
	p.InitPrepareUI( layer );
	p.CreateFightingUI( layer );
	p.pLayerFighting:SetVisible( false );
	p.BackToPrepareUI();
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
	
	--扫荡次数标签
	local pLabel		= GetLabel( p.pLayerPrepare, 20 );
	pLabel:SetVisible( false );
	
	-- 最大按钮=重置按钮
	local pBtnMax		= GetButton( p.pLayerPrepare, ID_BTN_MAX );
	--pBtnMax:SetVisible( false );
	local nResetNumber	= RolePetFunc.GetResetNumber(p.nCampaignID);
	local szTitle		= "重置";
	if ( nResetNumber > 0 ) then
		szTitle			= szTitle .. "(" .. nResetNumber .. ")";
	end
	pBtnMax:SetTitle( szTitle );
	
	-- 输入框
	local pUINode		= GetUiNode( p.pLayerPrepare, ID_EDIT_FIGHT_NUMBER );
	pUINode:SetVisible(false);
	
	-- 时间标签
	local nAmountTime	= p.nFightNumber * SECONDS_PER_FIGHT;
	local pLabelTime	= GetLabel( p.pLayerPrepare, ID_LABEL_TIME );
	pLabelTime:SetText( p.GetTimeString( nAmountTime ) );
	
	-- 副本名
	local szName 		= AffixBossFunc.findName( p.nCampaignID );
	local pLabelTaskName= GetLabel( p.pLayerPrepare, ID_LABEL_TASK_NAME );
	pLabelTaskName:SetText( szName );
	
	-- 隐藏一些图像控件
	local pImage		= GetImage( p.pLayerPrepare, 51 );
	pImage:SetVisible( false );
	pImage		= GetImage( p.pLayerPrepare, 52 );
	pImage:SetVisible( false );
	pImage		= GetImage( p.pLayerPrepare, 53 );
	pImage:SetVisible( false );
	pImage		= GetImage( p.pLayerPrepare, 54 );
	pImage:SetVisible( false );
	pImage		= GetImage( p.pLayerPrepare, 55 );
	pImage:SetVisible( false );
	pImage		= GetImage( p.pLayerPrepare, 56 );
	pImage:SetVisible( false );
	pImage		= GetImage( p.pLayerPrepare, 57 );
	pImage:SetVisible( false );
	pImage		= GetImage( p.pLayerPrepare, 58 );
	pImage:SetVisible( false );
	pImage		= GetImage( p.pLayerPrepare, 59 );
	pImage:SetVisible( false );
	
	-- 左侧提示
	-- 容器
	local container 	= GetScrollViewContainer( p.pLayerPrepare, ID_LIST_CONTANER );
	if not CheckP(container) then
		LogInfo("ClearUpEliteSettingUI: InitPrepareUI() failed! container is nil");
		return;
	end
    --container:EnableScrollBar(true);
	container:SetStyle( UIScrollStyle.Verical );
	local rectview		= container:GetFrameRect();
	container:SetViewSize( CGSizeMake(rectview.size.w, LIST_ITEM_HEIGHT) );
	
	-- 列表项
	local view = createUIScrollView();
	if not CheckP(view) then
		LogInfo("ClearUpEliteSettingUI: InitPrepareUI() failed! view is nil");
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
	local str = "<cffff00扫荡提示：\n<cffffff1、请保证背包有足够的空间来拾取战利品\n2、离线也可进行副本扫荡……";
	local pLabelTips = _G.CreateColorLabel( str, fontsize, nWidthLimit );
	
	if CheckP(pLabelTips) then
		pLabelTips:SetFrameRect(CGRectMake(10, 20, nWidthLimit, 20 * ScaleFactor));
		view:AddChild(pLabelTips);
	end
	
	-- 右侧信息列表容器
	local containerRight 	= GetScrollViewContainer( p.pLayerPrepare, ID_LIST_LABEL_CONT );
	local layer = createNDUILayer();
	layer:Init();
	local uiLoad=createNDUILoad();
	uiLoad:Load( "AutoFightUI_Prepare_L.ini", layer, nil, 0, 0 );
	uiLoad:Free();
	local pBorder = GetLabel( layer, ID_LIST_ITEM_LABEL );
	local tSize = pBorder:GetFrameRect().size;
	layer:Free();
	
	containerRight:SetStyle( UIScrollStyle.Verical );
	containerRight:SetViewSize(tSize);
	
end

---------------------------------------------------
-- 响应 Prepare 界面 UI 事件--准备扫荡
function p.OnUIEventPrepare( uiNode, uiEventType, param )
	local tag = uiNode:GetTag();	
	local nStamina = PlayerFunc.GetStamina( GetPlayerId() );
	if ( uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK ) then
		if ( ID_BTN_CLOSE == tag ) then
			CloseUI( NMAINSCENECHILDTAG.AffixBossClearUpElite );
			MsgAffixBoss.mUIListener = nil;	-- 取消响应网络消息
			if ( NormalBossListUI.nCampaignID ~= nil ) then
				WorldMap(NormalBossListUI.nCampaignID); 
			end
			NormalBossListUI.Redisplay();
			return true;
		elseif ( ID_BTN_MAX == tag ) then
			--重置
			p.OnBtnReset();
		elseif ( ID_BTN_START == tag ) then
			-- 点击“开始”
			p.OnBtnStart();
		end
	end
	return true;
end

---------------------------------------------------
-- 响应“开始”按钮
function p.OnBtnStart()
	if ( p.nFightNumber < 1 ) then
		LogInfo("ClearUpEliteSettingUI: OnBtnStart() failed! nFightNumber < 1");
		CommonDlgNew.ShowYesDlg( "木有可以扫荡的副本，请等待复位！", nil, nil, 3 );
		return;
	end
	
	--
	p.nClearStage	= 0;
	
	--p.ShowFightingUI();
	
	-- 发送消息给服务端，开始扫荡
	if ( p.tEnemyID ~= nil ) then
		MsgAffixBoss.sendNmlClean( p.tEnemyID[p.nCrtIndex], 1, true );
	end
end

---------------------------------------------------
-- 响应重置按钮
function p.OnBtnReset()
	--local nPlayerVIPLv	= GetRoleBasicDataN( GetPlayerId(), USER_ATTR.USER_ATTR_VIP_RANK );
	--if ( nPlayerVIPLv < 3 ) then
    if ( GetGetVipLevel_ELITE_MAP_RESET_NUM()<=0 ) then
		CommonDlgNew.ShowYesDlg( "VIP等级3及以上才可以重置冷却时间哦……", nil, nil, 3 );
		return;
	end
    local nResetCount	= GetRoleBasicDataN( GetPlayerId(), USER_ATTR.USER_ATTR_INSTANCING_RESET_COUNT );
    nResetCount = ConvertReset(nResetCount, p.nCampaignID);
	local nResetNumber	= RolePetFunc.GetResetNumber(p.nCampaignID);
	if ( nResetNumber > 0 ) then
		CommonDlgNew.ShowYesOrNoDlg( "消耗"..N_GOLD_RESET[nResetCount].."金币重置精英副本？", p.Callback_CostGoldToReset, true );
	else
		CommonDlgNew.ShowYesDlg( "木有重置次数了……", nil, nil, 3 );
	end
end

---------------------------------------------------
-- 确定重置精英副本的回调
function p.Callback_CostGoldToReset( nId, param )
	if ( CommonDlgNew.BtnOk == nId ) then
		local nPlayerID		= GetPlayerId();--User表中的ID
		local nPlayerGold	= GetRoleBasicDataN( nPlayerID, USER_ATTR.USER_ATTR_EMONEY );
        
        local nResetCount	= GetRoleBasicDataN( GetPlayerId(), USER_ATTR.USER_ATTR_INSTANCING_RESET_COUNT );
        nResetCount = ConvertReset(nResetCount, p.nCampaignID);
		local nResetNumber	= RolePetFunc.GetResetNumber(p.nCampaignID);
        if ( nPlayerGold < N_GOLD_RESET[nResetCount] ) then
			CommonDlgNew.ShowYesDlg( "金币不足请充值……", nil, nil, nil );
		else
		-- 发送重置精英副本的消息
			MsgAffixBoss.sendNmlReset( p.nCampaignID );
		end
	end
end
	
---------------------------------------------------
--显示自动战斗界面
function p.ShowFightingUI()
	local container 	= GetScrollViewContainer( p.pLayerFighting, ID_LIST_CONTANER );
	if not CheckP(container) then
		LogInfo("ClearUpEliteSettingUI: ShowFightingUI() failed! container is nil");
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
	
	-- 累积奖励信息
	p.nExpAmount			= 0;
	p.nMoneyAmount			= 0;
	p.tItemsAmount			= {};
	local pLabelRewardInfo	= GetLabel( p.pLayerFighting, ID_LABEL_REWARD_INFO );
	if ( nil == pLabelRewardInfo ) then
		LogInfo("ClearUpEliteSettingUI: ShowFightingUI() failed! pLabelRewardInfo is nil");
	end
	local szRewardInfo = "";--"经验+XYZ\n银币+LMN\n待定";
	pLabelRewardInfo:SetText( szRewardInfo );
	
	p.nEndMoment	= p.nFightNumber * SECONDS_PER_FIGHT + GetCurrentTime();
	
	-- 已战斗次数统计
	pLabelClearStage:SetText( p.nClearStage .. "/" .. p.nFightNumber );
	p.pLabelCoutDownCounter:SetText( p.GetTimeString( p.nEndMoment - GetCurrentTime() ) );
	
	--
	p.AppendListItemLabel( "～开始扫荡～", ccc4(0x10,0x33,0xcc,255) );
	
	-- 创建计时器，每1秒回调一次
	p.nTimerID = RegisterTimer( p.OnTimerCoutDownCounter, 1 );
	
	--
	p.pLayerFighting:SetVisible( true );
end

---------------------------------------------------
-- 倒计时计时器的回调函数
function p.OnTimerCoutDownCounter( nTimerID )
	if not IsUIShow( NMAINSCENECHILDTAG.AffixBossClearUpElite ) then
		UnRegisterTimer( nTimerID );
		return;
	end
	local nTime	= p.nEndMoment - GetCurrentTime();
	if ( nTime <= 0 ) then
		nTime = 0;
		UnRegisterTimer( nTimerID );
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
		LogInfo("ClearUpEliteSettingUI: CreateFightingUI() failed! layer is nil");
		return false;
	end
	layer:Init();
	layer:SetTag( NMAINSCENECHILDTAG.AffixBossClearUpElite );
	layer:SetFrameRect( RectFullScreenUILayer );
	--layer:SetBackgroundColor( ccc4(0, 0, 0, 0) );
	pParentLayer:AddChildZ( layer,3 );
	
	--初始化ui
	local uiLoad = createNDUILoad();
	if not CheckP(uiLoad) then
		LogInfo("ClearUpEliteSettingUI: CreateFightingUI() failed! uiLoad is nil");
		return false;
	end
	
	uiLoad:Load("AutoFightUI_Fighting.ini", layer, p.OnUIEventFighting, 0, 0 );
	
	-- 副本名
	local szName 		= AffixBossFunc.findName( p.nCampaignID );
	local pLabelTaskName= GetLabel( layer, ID_LABEL_TASK_NAME );
	pLabelTaskName:SetText( szName );
	
	-- 累积奖励信息
	p.nExpAmount			= 0;
	p.nMoneyAmount			= 0;
	p.tItemsAmount			= {};
	local pLabelRewardInfo	= GetLabel( layer, ID_LABEL_REWARD_INFO );
	if ( nil == pLabelRewardInfo ) then
		LogInfo("ClearUpEliteSettingUI: CreateFightingUI() failed! pLabelRewardInfo is nil");
	end
	local szRewardInfo = "";--"经验+XYZ\n银币+LMN\n待定";
	pLabelRewardInfo:SetText( szRewardInfo );
	
	p.pLayerFighting = layer;
	
	-- 右侧信息列表容器
	local containerRight 	= GetScrollViewContainer( p.pLayerFighting, ID_LIST_LABEL_CONT );
	local layer = createNDUILayer();
	layer:Init();
	local uiLoad=createNDUILoad();
	uiLoad:Load( "AutoFightUI_Prepare_L.ini", layer, nil, 0, 0 );
	uiLoad:Free();
	local pBorder = GetLabel( layer, ID_LIST_ITEM_LABEL );
	local tSize = pBorder:GetFrameRect().size;
	layer:Free();
	containerRight:SetStyle( UIScrollStyle.Verical );
	containerRight:SetViewSize(tSize);
	containerRight:EnableScrollBar(true);
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
				CommonDlgNew.ShowYesOrNoDlg( "您确定要停止扫荡并返回？", p.Callback_StopAndBack, true );
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
	-- 最大按钮=重置按钮
	local pBtnMax		= GetButton( p.pLayerPrepare, ID_BTN_MAX );
	--pBtnMax:SetVisible( false );
	local nResetNumber	= RolePetFunc.GetResetNumber(p.nCampaignID);
	local szTitle		= "重置";
	if ( nResetNumber > 0 ) then
		szTitle			= szTitle .. "(" .. nResetNumber .. ")";
	end
	pBtnMax:SetTitle( szTitle );
	
	-- 敌军信息--
	--local pLabelEnemyInfo = GetLabel( p.pLayerPrepare, ID_LABEL_ENEMY_INFO );
	--if ( nil == pLabelEnemyInfo ) then
	--	LogInfo("ClearUpEliteSettingUI: BackToPrepareUI() failed! pLabelEnemyInfo is nil");
	--end
	--local szEnemyName	= "";
	--local tList, nCount = AffixBossFunc.findBossList( p.nCampaignID, 1 );--获得指定片区里的精英副本信息列表
	----List{ typeid, name, rank, status, time, pic, order, elite, }
	---- { id, 名字, 曾经战胜过, 状态, 时间？, pic？, order？, 是否精英 }
	----local nCurrentTime = GetCurrentTime();
	--p.nFightNumber	= 0;
	--p.tEnemyID	= {};
	--for i = 1, nCount do
	--	--LogInfo("ClearUpEliteSettingUI: typeid:%d, elite:%d, rank:%d, name:%s, time:%d",tList[i].typeid,tList[i].elite,tList[i].rank,tList[i].name,tList[i].time);
	--	--if ( tList[i].elite == 1 ) and ( tList[i].rank == 1 ) and ( tList[i].time < nCurrentTime ) then
	--	if ( tList[i].elite == 1 ) and ( tList[i].rank == 1 ) and ( tList[i].time == 0 ) then
	--		p.tEnemyID[ #p.tEnemyID + 1 ] = tList[i].typeid;
	--		szEnemyName = szEnemyName .. tList[i].name .. "\n";
	--		p.nFightNumber	= p.nFightNumber + 1;
	--	--LogInfo("ClearUpEliteSettingUI: typeid:%d, elite:%d, rank:%d, name:%s",p.tEnemyID[ #p.tEnemyID ],tList[i].elite,tList[i].rank,tList[i].name);
	--	end
	--end
	--pLabelEnemyInfo:SetText( szEnemyName );
	p.InitEnemyInfo();
	
	local nAmountTime	= p.nFightNumber * SECONDS_PER_FIGHT;
	local pLabelTime	= GetLabel( p.pLayerPrepare, ID_LABEL_TIME );
	pLabelTime:SetText( p.GetTimeString( nAmountTime ) );
	
	if ( p.nTimerID ~= 0 ) then
		UnRegisterTimer( p.nTimerID );
		p.nTimerID = 0;
	end
	
	p.pLayerFighting:SetVisible( false );
end

---------------------------------------------------
-- 初始并显示敌军信息
function p.InitEnemyInfo()
	local containerRight 	= GetScrollViewContainer( p.pLayerPrepare, ID_LIST_LABEL_CONT );
	containerRight:RemoveAllView();
	local tList, nCount = AffixBossFunc.findBossList( p.nCampaignID, 1 );--获得指定片区里的精英副本信息列表
	p.nFightNumber	= 0;
	p.tEnemyID	= {};
	for i = 1, nCount do
		if ( tList[i].elite == 1 ) and ( tList[i].rank == 1 ) and ( tList[i].time == 0 ) then
			p.tEnemyID[ #p.tEnemyID + 1 ] = tList[i].typeid;
			p.AppendRightItemLabel( containerRight, tList[i].name, ccc4(0,255,255,255) );
			p.nFightNumber	= p.nFightNumber + 1;
		end
	end
end

---------------------------------------------------
-- 确定停止扫荡的回调
function p.Callback_StopAndBack( nId, param )
	if ( CommonDlgNew.BtnOk == nId ) then
		-- 发送取消扫荡消息
		p.nCancelFlag	= 1;
		MsgAffixBoss.sendNmlCancel( p.tEnemyID[p.nCrtIndex] );
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
	CommonDlgNew.ShowYesOrNoDlg( "您确定要停止扫荡？", p.Callback_StopAutoFight, true );
end

---------------------------------------------------
-- 确定停止扫荡的回调
function p.Callback_StopAutoFight( nId, param )
	if ( CommonDlgNew.BtnOk == nId ) then
		-- 发送取消扫荡消息
		p.nCancelFlag	= 0;
		MsgAffixBoss.sendNmlCancel( p.tEnemyID[p.nCrtIndex] );
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
	CommonDlgNew.ShowYesOrNoDlg( "消耗 "..nGold.." 金币直接完成扫荡？", p.Callback_CostGoldToFinish, true );
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
			MsgAffixBoss.sendNmlFinish( p.nCampaignID );--( p.tEnemyID[p.nCrtIndex] );--发送"_MSG_AFFIX_BOSS_NML_FINISH"消息
		else
			CommonDlgNew.ShowYesDlg( "金币不足请充值……", nil, nil, nil );
		end
	end
end


---------------------------------------------------
-- 处理网络消息
function p.HandleNetMsg( nMsgID, param )
	if ( nMsgID == nil ) then
		return;
	end
	if ( nMsgID == NMSG_Type._MSG_AFFIX_BOSS_NML_CLEARUP ) then
		-- 开始扫荡
		p.ShowFightingUI();
	elseif ( nMsgID == NMSG_Type._MSG_AFFIX_BOSS_CLEANUP_BATTLE ) then
		-- 战斗奖励（完成一次战斗）
		p.nClearStage 		= p.nClearStage + 1;
		if ( p.nClearStage >= p.nFightNumber ) then
			--全部完成
			p.nClearStage	= p.nFightNumber;
		end
		p.nEndMoment		= GetCurrentTime()  + ( p.nFightNumber - p.nClearStage ) * SECONDS_PER_FIGHT;
		local pLabelClearStage	= GetLabel( p.pLayerFighting, ID_LABEL_CLEAR_STAGE );
		pLabelClearStage:SetText( p.nClearStage .. "/" .. p.nFightNumber );
		p.ShowRewardOnce( param );
		p.ShowTotalReward( param );
	elseif ( nMsgID == NMSG_Type._MSG_AFFIX_BOSS_CLEANUP_RAISE ) then
		-- 副本奖励
		--
	elseif ( nMsgID == NMSG_Type._MSG_AFFIX_BOSS_NML_FINISH ) then
		-- 结束(当前结束)
		--local nBattleID			= param:ReadInt();
		--local nServerFinishFlag	= param:ReadByte();--0正常完成，1用金币购买的完成
		--p.nCrtIndex			= p.nCrtIndex + 1;
		--if ( p.tEnemyID[p.nCrtIndex] and ( nServerFinishFlag == 1 ) ) then
		--	MsgAffixBoss.sendNmlClean( p.tEnemyID[p.nCrtIndex], 1, true );
		--else
		--	-- 所有结束
		--	local pBtnStop		= GetButton( p.pLayerFighting, ID_BTN_STOP );
		--	local pBtnFinish	= GetButton( p.pLayerFighting, ID_BTN_FINISH );
		--	local pBtnBack		= GetButton( p.pLayerFighting, ID_BTN_BACK );
		--	pBtnStop:SetVisible( false );
		--	pBtnFinish:SetVisible( false );
		--	pBtnBack:SetVisible( true );
		--end
		local pBtnStop		= GetButton( p.pLayerFighting, ID_BTN_STOP );
		local pBtnFinish	= GetButton( p.pLayerFighting, ID_BTN_FINISH );
		local pBtnBack		= GetButton( p.pLayerFighting, ID_BTN_BACK );
		pBtnStop:SetVisible( false );
		pBtnFinish:SetVisible( false );
		pBtnBack:SetVisible( true );
		p.AppendListItemLabel( "～扫荡完毕～", ccc4(0x10,0x10,0xff,255) );
	elseif ( nMsgID == NMSG_Type._MSG_AFFIX_BOSS_NML_CANCEL ) then
		-- 取消
		local nBattleID			= param:ReadInt();
		local nServerCancelFlag	= param:ReadByte();--0普通，1背包满
		if ( nServerCancelFlag == 1 ) then
			p.AppendListItemLabel( "您的背包满咯～", ccc4(0xff,0x0,0x0,255) );
		else
			p.AppendListItemLabel( "～扫荡停止～", ccc4(0x10,0x10,0xff,255) );
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
	elseif ( nMsgID == NMSG_Type._MSG_AFFIX_BOSS_NML_RESET ) then
		-- 重置
		if ( p.pLayerPrepare ~= nil ) and ( not p.pLayerFighting:IsVisibled() ) then
			--LogInfo( "ClearUpEliteSettingUI: HandleNetMsg() nMsgID:%d", nMsgID );
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

	--local szReward = "经验+" .. p.nExpAmount .. "\n银币+" .. p.nMoneyAmount; 
	--for key, value in pairs( p.tItemsAmount ) do
	--	szReward	= szReward .. "\n" .. key .. " × " .. value ;
	--end
	--local pLabelRewardInfo	= GetLabel( p.pLayerFighting, ID_LABEL_REWARD_INFO );
	--pLabelRewardInfo:SetText( szReward );
	p.ShowTotalReward_WithList();
end

---------------------------------------------------
--
function p.ShowTotalReward_WithList()
	local containerRight 	= GetScrollViewContainer( p.pLayerFighting, ID_LIST_LABEL_CONT );
	containerRight:RemoveAllView();
	local szTitle = "经验+" .. p.nExpAmount;
	p.AppendRightItemLabel( containerRight, szTitle, ccc4(0,255,255,255) );
	szTitle = "银币+" .. p.nMoneyAmount; 
	p.AppendRightItemLabel( containerRight, szTitle, ccc4(0,255,255,255) );
	for key, value in pairs( p.tItemsAmount ) do
		szTitle = key .. " × " .. value ;
		p.AppendRightItemLabel( containerRight, szTitle, ccc4(0,255,255,255) );
	end
end


---------------------------------------------------
-- 显示一次战斗奖励
function p.ShowRewardOnce( tData )
	local nExp			= tData.nExp;
	local nMoney		= tData.nMoney;
	local nItemCount	= table.getn( tData.tItems );
	local szResult		= "战斗胜利！";
	p.AppendListItemLabel( szResult, ccc4(0x0,0xff,0x0,255) );
	local szResult		= "获得：" .. nExp .. "经验，" .. nMoney .. "银币";
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
--	local szResult = "战斗胜利!\n获得：<c00ff00" .. nExp .. "/e经验，<c00ff00" .. nMoney .. "/e银币";
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
--	if not strData then
--		LogInfo("ClearUpEliteSettingUI: AppendLeftListItem() failed! strData is nil");
--		return;
--	end
--
--	-- 左侧提示
--	local container 	= GetScrollViewContainer( p.pLayerFighting, ID_LIST_CONTANER );
--	if not CheckP(container) then
--		LogInfo("ClearUpEliteSettingUI: AppendLeftListItem() failed! container is nil");
--		return;
--	end
--	container:SetStyle( UIScrollStyle.Verical );
--	local rectview 		= container:GetFrameRect();
--	container:SetViewSize(CGSizeMake(rectview.size.w, 150));--rectview.size.h));
--	--container:EnableScrollBar(true);
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
		LogInfo("ClearUpEliteSettingUI: AppendListItemLabel() failed! szText is nil");
		return;
	end
	local container 	= GetScrollViewContainer( p.pLayerFighting, ID_LIST_CONTANER );
	if not CheckP(container) then
		LogInfo("ClearUpEliteSettingUI: AppendListItemLabel() failed! container is nil");
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
		LogInfo("ClearUpEliteSettingUI: AppendListItemLabel() failed! pLabel is nil");
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
-- 添加左侧列表项标签--（两个页面）
function p.AppendRightItemLabel( pContainer, szText, tColor )
	if ( pContainer == nil ) then
		LogInfo("ClearUpSetting: AppendRightItemLabel() failed! pContainer is nil");
		return;
	end
	if ( szText == nil or szText == "" ) then
		LogInfo("ClearUpSetting: AppendRightItemLabel() failed! szText is nil");
		return;
	end
	local view = createUIScrollView();
	view:Init(false);
	view:SetScrollStyle(UIScrollStyle.Verical);
	view:SetMovableViewer(pContainer);
	view:SetScrollViewer(pContainer);
	view:SetContainer(pContainer);
	pContainer:AddView(view);
	local uiLoad = createNDUILoad();
	uiLoad:Load( "AutoFightUI_Prepare_L.ini", view, nil, 0, 0 );
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
end


---------------------------------------------------
-- 登录时刻，有处于扫荡状态则进入扫荡界面
function p.LoadUIForLogin( nBattleID, nRemain, nTotal )
	--LogInfo( "ClearUpEliteSettingUI: LoadUIForLogin EnemyID:%d", nBattleID );
	p.LoadUI( AffixBossFunc.findMapId( 1, nBattleID ) );
	p.ShowFightingUI();
end

---------------------------------------------------
