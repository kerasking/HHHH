---------------------------------------------------
--描述: 培养
--时间: 2012.7.8
--作者: Guosen
---------------------------------------------------
-- 进入培养界面接口：		RoleTrainUI.LoadUI()
---------------------------------------------------
RoleTrainUI = {}
local p = RoleTrainUI;

---------------------------------------------------

local ID_LIST_CONTAINER					= 10;	-- 左侧武将列表（容器）控件ID

local ID_ICON_PET_PORTRAIT				= 9;	-- 右侧头像控件ID

local ID_BTN_CLOSE						= 7;	-- X按钮ID
local ID_BTN_START_TRAIN				= 36;	-- 开始训练按钮ID
local ID_BTN_STOP_TRAIN					= 20;	-- 结束训练按钮ID
local ID_BTN_PICK_UP_EXP				= 19;	-- 提取经验按钮ID

local ID_BTN_TRAIN_NORMAL				= 22;	-- 普通训练按钮ID
local ID_BTN_TRAIN_ADVANCED				= 25;	-- 高级训练按钮ID
local ID_BTN_TRAIN_PLATINA				= 28;	-- 白金训练按钮ID
local ID_BTN_TRAIN_DIAMOND				= 31;	-- 金钻训练按钮ID
local ID_BTN_TRAIN_SUPREME				= 35;	-- 至尊训练按钮ID

local ID_LABEL_NAME						= 11;	-- 姓名标签ID
local ID_LABEL_LEV						= 13;	-- 等级+数值标签ID
local ID_LABEL_EXP						= 14;	-- 经验数值标签ID
local ID_LABEL_INTRO					= 16;	-- 简介标签ID
local ID_LABEL_DETAIL					= 18;	-- 正在训练提示
local ID_LABEL_TIMER					= 17;	-- 倒计时

-- 初始的每个列表项里头像控件ID
local tIconIDInListItem = { 2, 3 };
local ID_LIST_ITEM_BORDER				= 4;	-- 列表项的外框控件

local PET_NUM_PER_LISTITEM				= 2;	-- 每个列表项可显示的武将个数
local TRAIN_LIMIT_TIME					= 60*60*24;--训练的限制时间

---------------------------------------------------
-- 培养类型
TRAIN_TYPE = {
	ADVANCED	= 1,	-- 高级
	PLATINA		= 2,	-- 白金
	DIAMOND		= 3,	-- 金钻
	SUPREME		= 4,	-- 至尊
};

TRAIN_INFO = {
	NEEDGOLD	= 1,	-- 需要的金币数量
	INTRO		= 2,	-- 简介
	NEEDVIP		= 3,	-- 需要的VIP等级
	DETAIL		= 4,	-- 训练时提示
	EXPADD		= 5,	-- 额外经验加成比
};
-- 各类训练简介-{ nGold, szIntro, nVIP, szDetail }
local tTrainInfo = {
	{ 5, "消耗5金币，该武将可获得24小时高级训练经验；若是上阵武将在训练时间内通关副本或完成任务获得经验将增加20%。", 0, "普通训练进行中……", 20 },
	{ 10, "消耗10金币，该武将可获得24小时高级训练经验；若是上阵武将在训练时间内通关副本或完成任务获得经验将增加50%。需VIP1。", 1, "高级训练进行中……", 50 },
	{ 20, "消耗20金币，该武将可获得24小时金钻训练经验；若是上阵武将在训练时间内通关副本或完成任务获得经验将增加100%。需VIP4。", 4, "白金训练进行中……", 100 },
	{ 50, "消耗50金币，该武将可获得24小时至尊训练经验；若是上阵武将在训练时间内通关副本或完成任务获得经验将增加150%。需VIP8。", 8, "金钻训练进行中……", 150 },
};


---------------------------------------------------
p.pIconPetPortrait		= nil;	-- 头像控件
p.pBtnStart				= nil;	-- 开始训练按钮
p.pBtnStop				= nil;	-- 停止训练按钮
p.pBtnPickUp			= nil;	-- 提取经验按钮
p.pBtnCheckAdvanced		= nil;	-- 高级训练按钮
p.pBtnCheckPlatina		= nil;	-- 白金训练按钮
p.pBtnCheckDiamond		= nil;	-- 金钻训练按钮
p.pBtnCheckSupreme		= nil;	-- 至尊训练按钮
p.pLabelName			= nil;	-- 姓名标签
p.pLabelLev				= nil;	-- 等级+数值标签
p.pLabelExp				= nil;	-- 经验数值标签
p.pLabelIntro			= nil;	-- 简介标签
p.pLabelDetail			= nil;	-- 某训练进行中提示标签--倒计时标签
p.pLabelTimer			= nil;	-- 倒计时标签

p.nCheckedPetID			= nil;	-- 选中的武将ID
p.nPetTrainType			= nil;	-- 选中武将的训练类型,0=无
p.nCheckedTrainType		= nil;	-- 选中的训练类型
p.nTimerID				= nil;	-- 倒计时计时器的ID号
p.nEndMoment			= nil;	-- 结束时刻（开始时刻+需要时间）

---------------------------------------------------
-- 进入训练界面
function p.LoadUI( nChosenPetID)
	--LogInfo( "RoleTrainUI: LoadUI()" );
	--local scene = GetSMGameScene();
	if ( nChosenPetID == nil) then
		return false;
	end
	if ( nChosenPetID == RolePetFunc.GetMainPetId( GetPlayerId() ) ) then
		CommonDlgNew.ShowYesDlg( "主角不可哦！", nil, nil, 3 );
		return false;
	end
	
	local pDirector = DefaultDirector();
	if ( pDirector == nil ) then
		LogInfo( "RoleTrainUI: pDirector == nil" );
		return false;
	end
	local pScene = pDirector:GetRunningScene();
	if ( pScene == nil ) then
		LogInfo( "RoleTrainUI: LoadUI() failed! scene = nil" );
		return false;
	end
	
	local layer = createNDUILayer();
	if ( layer == nil ) then
		LogInfo( "RoleTrainUI: LoadUI() failed! layer = nil" );
		return false;
	end
	layer:Init();
	layer:SetTag( NMAINSCENECHILDTAG.RoleTrain );
	layer:SetFrameRect( RectFullScreenUILayer );
	layer:SetBackgroundColor( ccc4(125, 125, 125, 0) );
	pScene:AddChildZ( layer, 2 );--pScene:AddChild( layer );--
	
	--初始化ui
	local uiLoad = createNDUILoad();
	if not CheckP(uiLoad) then
		LogInfo( "RoleTrainUI: LoadUI() failed! uiLoad = nil" );
		return false;
	end
	
	uiLoad:Load( "RoleTrainUI_Main.ini", layer, p.OnUIEvent, 0, 0 );
	uiLoad:Free();
	
	-- 队伍中的武将PetID列表
	local tPetIDsInTeam		= RolePetUser.GetPetListPlayer( GetPlayerId() );
	local nPetAmount		= table.getn( tPetIDsInTeam );
	if ( nPetAmount == 0 ) then
		CommonDlgNew.ShowYesDlg( "无武将！", nil, nil, 3 );
		return false;
	end
	p.FillListContainer( layer, tPetIDsInTeam );
	
	p.pIconPetPortrait		= GetButton( layer, ID_ICON_PET_PORTRAIT );
	p.pBtnStart				= GetButton( layer, ID_BTN_START_TRAIN );
	p.pBtnStop				= GetButton( layer, ID_BTN_STOP_TRAIN );
	p.pBtnPickUp			= GetButton( layer, ID_BTN_PICK_UP_EXP );
	p.pBtnCheckAdvanced		= ConverToCheckBox( GetUiNode ( layer, ID_BTN_TRAIN_ADVANCED ) );
	p.pBtnCheckPlatina		= ConverToCheckBox( GetUiNode ( layer, ID_BTN_TRAIN_PLATINA ) );
	p.pBtnCheckDiamond		= ConverToCheckBox( GetUiNode ( layer, ID_BTN_TRAIN_DIAMOND ) );
	p.pBtnCheckSupreme		= ConverToCheckBox( GetUiNode ( layer, ID_BTN_TRAIN_SUPREME ) );
	p.pLabelName			= GetLabel( layer, ID_LABEL_NAME );
	p.pLabelLev				= GetLabel( layer, ID_LABEL_LEV );
	p.pLabelExp				= GetLabel( layer, ID_LABEL_EXP );
	p.pLabelIntro			= GetLabel( layer, ID_LABEL_INTRO );
	p.pLabelDetail			= GetLabel( layer, ID_LABEL_DETAIL );
	p.pLabelTimer			= GetLabel( layer, ID_LABEL_TIMER );
	
	p.pBtnStart:SetVisible( false );
	p.pBtnStop:SetVisible( false );
	p.pBtnPickUp:SetVisible( false );
	p.pLabelLev:SetVisible( false );
	p.pLabelExp:SetVisible( false );
	p.pLabelDetail:SetVisible( false );
	p.pLabelTimer:SetVisible( false );
	
--[[	local nFontSize		= 12;
	local tRectForm		= p.pLabelDetail:GetFrameRect();
	local pColorLabel	= _G.CreateColorLabel( "", nFontSize, tRectForm.size.w );
	pColorLabel:SetFrameRect( tRectForm );
	layer:AddChild(pColorLabel);
	p.pLabelDetail = pColorLabel;]]
	
	p.nTimerID = RegisterTimer( p.OnTimerCoutDownCounter, 1 );
	
	MsgRoleTrain.mUIListener = p.HandleNetMsg;
	
	p.nCheckedPetID	= nChosenPetID;--tPetIDsInTeam[2];
	p.RefreshRightZone( p.nCheckedPetID );
	return true;
end

---------------------------------------------------
-- 倒计时计时器的回调函数
function p.OnTimerCoutDownCounter( nTimerID )
	if not IsUIShow( NMAINSCENECHILDTAG.RoleTrain ) then
		UnRegisterTimer( nTimerID );
		return;
	end
	--
	local nTime	= 0;
	if ( p.nEndMoment ~= nil ) then
		nTime	= p.nEndMoment - GetCurrentTime();
		if ( nTime < 0 ) then
			nTime = 0;
		else
			-- 显示可提取的经验
			local tRecord = MsgRoleTrain.GetPetTrainRecord( p.nCheckedPetID );
			if ( tRecord ~= nil ) then
				--LogInfo( "RoleTrainUI: OnTimerCoutDownCounter() nTrainID:%d, nPetID:%d, nTrainType:%d, nEndTime:%d, nPickUpTime:%d",tRecord.nTrainID,tRecord.nPetID,tRecord.nTrainType,tRecord.nEndTime,tRecord.nPickUpTime );
				local nPlayerNextLvlExp	= RolePetFunc.GetNextLvlExp( RolePetFunc.GetMainPetId( GetPlayerId() ) );
				local nValidTime		= TRAIN_LIMIT_TIME - ( tRecord.nEndMoment - GetCurrentTime() ) - tRecord.nPickUpTime;
				local nScale			= tTrainInfo[tRecord.nTrainType][TRAIN_INFO.EXPADD];
				local nPetExp			= nPlayerNextLvlExp * nValidTime * nScale / TRAIN_LIMIT_TIME / 100;
				nPetExp					= math.ceil( nPetExp );
				--LogInfo( "RoleTrainUI: OnTimerCoutDownCounter() nValidTime:%d, nScale:%d, nPetExp:%d",nValidTime,nScale,nPetExp );
				p.pLabelExp:SetText( SafeN2S(nPetExp) );
			end
		end
	end
	p.pLabelTimer:SetText( p.GetTimeString( nTime ) );
end

---------------------------------------------------
-- 刷新右侧区域
function p.RefreshRightZone( nPetID )
	if ( RolePet.IsExistPet( nPetID ) ) then
		local tRecord = MsgRoleTrain.GetPetTrainRecord( nPetID );
		if ( tRecord == nil ) then
			--tRecord  = {};
			--tRecord.nTrainID		= 1;
			--tRecord.nPetID			= nPetID;
			--tRecord.nTrainType		= 1;
			--tRecord.nEndTime		= 60*60*20+60*15+35;
			--tRecord.nPickUpTime		= 0;
			--tRecord.nEndMoment		= tRecord.nEndTime + GetCurrentTime();
			--p.nPetTrainType	= 1;
			p.nPetTrainType	= 0;
		else
			p.nPetTrainType	= tRecord.nTrainType;
		end
		--LogInfo( "RefreshRightZone: RefreshRightZone() nPetID:%d",nPetID );
		local nPetType	= RolePet.GetPetInfoN( nPetID, PET_ATTR.PET_ATTR_TYPE )
		-- 头像
		local pic		= GetPetPotraitPic(nPetType);
		if CheckP(pic) and ( p.pIconPetPortrait ~= nil ) then
			p.pIconPetPortrait:SetImage( pic, true );
		end
		-- 名字
		local szPetName	= GetDataBaseDataS( "pet_config", nPetType, DB_PET_CONFIG.NAME );
		p.pLabelName:SetText( szPetName );
		-- 等级
		local nPetLevel	= RolePet.GetPetInfoN( nPetID, PET_ATTR.PET_ATTR_LEVEL );
		p.pLabelLev:SetText( "等级:" .. SafeN2S(nPetLevel) );
		p.pLabelLev:SetVisible( true );
		
		p.pLabelExp:SetVisible( true );
		if ( p.nPetTrainType > 0 ) then
			p.pBtnStart:SetVisible( false );
			p.pBtnStop:SetVisible( true );
			p.pBtnPickUp:SetVisible( true );
			p.pLabelIntro:SetVisible( false );
			p.pLabelDetail:SetVisible( true );
			p.pLabelTimer:SetVisible( true );
			p.ShowCheckBox( p.nPetTrainType );
			--
			local szDetail	= tTrainInfo[p.nPetTrainType][TRAIN_INFO.DETAIL]
			szDetail		= szDetail .. "\n剩余时间：\n";
			p.pLabelDetail:SetText( szDetail );
			p.nEndMoment = tRecord.nEndMoment;
			p.pLabelTimer:SetText( p.GetTimeString( p.nEndMoment - GetCurrentTime() ) );
			-- 经验
			local nPlayerNextLvlExp	= RolePetFunc.GetNextLvlExp( RolePetFunc.GetMainPetId( GetPlayerId() ) );
			--LogInfo( "RefreshRightZone: RefreshRightZone() nPlayerNextLvlExp:%d", nPlayerNextLvlExp );
			local nValidTime		= TRAIN_LIMIT_TIME - ( tRecord.nEndMoment - GetCurrentTime() ) - tRecord.nPickUpTime;
			local nScale			= tTrainInfo[tRecord.nTrainType][TRAIN_INFO.EXPADD];
			local nPetExp			= nPlayerNextLvlExp * nValidTime * nScale / TRAIN_LIMIT_TIME / 100;
			nPetExp					= math.ceil( nPetExp );
			p.pLabelExp:SetText( SafeN2S(nPetExp) );
		else
			p.pBtnStart:SetVisible( true );
			p.pBtnStop:SetVisible( false );
			p.pBtnPickUp:SetVisible( false );
			p.pLabelIntro:SetVisible( true );
			p.pLabelDetail:SetVisible( false );
			p.pLabelTimer:SetVisible( false );
			p.ShowCheckBox( TRAIN_TYPE.ADVANCED );
			--
			p.pLabelExp:SetText( "0" );
		end
	else
		--
		p.pLabelName:SetVisible( false );
		p.pLabelLev:SetVisible( false );
		p.pLabelExp:SetVisible( false );
	end
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
-- 主界面触摸事件响应
function p.OnUIEvent( uiNode, uiEventType, param )
	local tag = uiNode:GetTag();
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if ( ID_BTN_CLOSE == tag ) then
			local pScene = DefaultDirector():GetRunningScene();
			if ( pScene ~= nil ) then
				pScene:RemoveChildByTag( NMAINSCENECHILDTAG.RoleTrain, true );
			end
p.pIconPetPortrait		= nil;
p.pBtnStart				= nil;
p.pBtnStop				= nil;
p.pBtnPickUp			= nil;
p.pBtnCheckAdvanced		= nil;
p.pBtnCheckPlatina		= nil;
p.pBtnCheckDiamond		= nil;
p.pBtnCheckSupreme		= nil;
p.pLabelName			= nil;
p.pLabelLev				= nil;
p.pLabelExp				= nil;
p.pLabelIntro			= nil;
p.pLabelDetail			= nil;
p.pLabelTimer			= nil;
p.nCheckedPetID			= nil;
p.nPetTrainType			= nil;
p.nCheckedTrainType		= nil;
p.nTimerID				= nil;
p.nEndMoment			= nil;
			MsgRoleTrain.mUIListener = nil;
		elseif ( ID_BTN_START_TRAIN == tag ) then
			p.OnBtnStartTrain();
		elseif ( ID_BTN_STOP_TRAIN == tag ) then
			p.OnBtnStopTrain();
		elseif ( ID_BTN_PICK_UP_EXP == tag ) then
			MsgRoleTrain.SetMsgPickUpExp( p.nCheckedPetID );
		end
	elseif ( uiEventType == NUIEventType.TE_TOUCH_CHECK_CLICK ) then
		if ( p.nPetTrainType == nil ) then
			p.ShowCheckBox( 0 );
		elseif ( p.nPetTrainType == 0 ) then
			-- 选中武将无训练类型（非训练中）时才可选
			if ( ID_BTN_TRAIN_ADVANCED == tag ) then
				p.ShowCheckBox( TRAIN_TYPE.ADVANCED );
			elseif ( ID_BTN_TRAIN_PLATINA == tag ) then
				p.ShowCheckBox( TRAIN_TYPE.PLATINA );
			elseif ( ID_BTN_TRAIN_DIAMOND == tag ) then
				p.ShowCheckBox( TRAIN_TYPE.DIAMOND );
			elseif ( ID_BTN_TRAIN_SUPREME == tag ) then
				p.ShowCheckBox( TRAIN_TYPE.SUPREME );
			end
		elseif ( p.nPetTrainType > 0 ) then
			-- 选中武将有训练类型（在训练中）时只显示训练类型
			p.ShowCheckBox( p.nPetTrainType );
		end
	end
	return true;
end

---------------------------------------------------
-- 显示选择训练类型按钮
function p.ShowCheckBox( nTrainType )
	p.nCheckedTrainType = nTrainType;
	if ( TRAIN_TYPE.ADVANCED == nTrainType ) then
		p.pBtnCheckAdvanced:SetSelect( true );
		p.pBtnCheckPlatina:SetSelect( false );
		p.pBtnCheckDiamond:SetSelect( false );
		p.pBtnCheckSupreme:SetSelect( false );
		p.pLabelIntro:SetText( tTrainInfo[1][TRAIN_INFO.INTRO] );
	elseif ( TRAIN_TYPE.PLATINA == nTrainType ) then
		p.pBtnCheckAdvanced:SetSelect( false );
		p.pBtnCheckPlatina:SetSelect( true );
		p.pBtnCheckDiamond:SetSelect( false );
		p.pBtnCheckSupreme:SetSelect( false );
		p.pLabelIntro:SetText( tTrainInfo[2][TRAIN_INFO.INTRO] );
	elseif ( TRAIN_TYPE.DIAMOND == nTrainType ) then
		p.pBtnCheckAdvanced:SetSelect( false );
		p.pBtnCheckPlatina:SetSelect( false );
		p.pBtnCheckDiamond:SetSelect( true );
		p.pBtnCheckSupreme:SetSelect( false );
		p.pLabelIntro:SetText( tTrainInfo[3][TRAIN_INFO.INTRO] );
	elseif ( TRAIN_TYPE.SUPREME == nTrainType ) then
		p.pBtnCheckAdvanced:SetSelect( false );
		p.pBtnCheckPlatina:SetSelect( false );
		p.pBtnCheckDiamond:SetSelect( false );
		p.pBtnCheckSupreme:SetSelect( true );
		p.pLabelIntro:SetText( tTrainInfo[4][TRAIN_INFO.INTRO] );
	else
		p.pBtnCheckAdvanced:SetSelect( false );
		p.pBtnCheckPlatina:SetSelect( false );
		p.pBtnCheckDiamond:SetSelect( false );
		p.pBtnCheckSupreme:SetSelect( false );
		p.nCheckedTrainType = 0;
	end
end

---------------------------------------------------
-- 响应开始训练按键
function p.OnBtnStartTrain()
	if ( RolePet.IsExistPet( p.nCheckedPetID ) and p.nCheckedTrainType > 0 ) then
		local tRecord = MsgRoleTrain.GetPetTrainRecord( p.nCheckedPetID );
		if ( tRecord ~= nil ) then
			return;
		end
		local nPlayerID		= GetPlayerId();
		local nPlayerVIPLv	= GetRoleBasicDataN( nPlayerID, USER_ATTR.USER_ATTR_VIP_RANK );
		local nNeedVIPLv	= tTrainInfo[p.nCheckedTrainType][TRAIN_INFO.NEEDVIP];
		if ( nPlayerVIPLv < nNeedVIPLv ) then
			CommonDlgNew.ShowYesDlg( "VIP等级不够！", nil, nil, 3 );
			return;
		end
		local nPlayerGold	= GetRoleBasicDataN( nPlayerID, USER_ATTR.USER_ATTR_EMONEY );
		local nGold			= tTrainInfo[p.nCheckedTrainType][TRAIN_INFO.NEEDGOLD];
		if ( nPlayerGold < nGold ) then
			CommonDlgNew.ShowYesDlg( "金币不足！", nil, nil, 3 );
			return;
		end
		local nPetType		= RolePet.GetPetInfoN( p.nCheckedPetID, PET_ATTR.PET_ATTR_TYPE );
		local szPetName		= GetDataBaseDataS( "pet_config", nPetType, DB_PET_CONFIG.NAME );
		CommonDlgNew.ShowYesOrNoDlg( "您确定花费"..nGold.."金币训练『"..szPetName.."』？", p.CallBack_ConfirmStartTrain, true );
	end 
end
-- 对话框回调事件-确定消耗银币金币什么的来培养
function p.CallBack_ConfirmStartTrain( nId, nEvent, param )
	if ( CommonDlgNew.BtnOk == nId ) then
		-- 发送训练武将消息
		MsgRoleTrain.SetMsgStartTrain( p.nCheckedPetID, p.nCheckedTrainType );
	end
end

---------------------------------------------------
-- 响应停止训练按键
function p.OnBtnStopTrain()
	if ( RolePet.IsExistPet( p.nCheckedPetID ) ) then
		local tRecord = MsgRoleTrain.GetPetTrainRecord( p.nCheckedPetID );
		if ( tRecord == nil ) then
			return;
		end
		local nPetType		= RolePet.GetPetInfoN( p.nCheckedPetID, PET_ATTR.PET_ATTR_TYPE );
		local szPetName		= GetDataBaseDataS( "pet_config", nPetType, DB_PET_CONFIG.NAME );
		CommonDlgNew.ShowYesOrNoDlg( "您确定要停止训练『"..szPetName.."』？", p.CallBack_ConfirmStopTrain, true );
	end
end
-- 对话框回调事件-确定停止培养
function p.CallBack_ConfirmStopTrain( nId, nEvent, param )
	if ( CommonDlgNew.BtnOk == nId ) then
		-- 发送停止训练武将消息
		MsgRoleTrain.SetMsgStopTrain( p.nCheckedPetID );
	end
end

---------------------------------------------------
-- 填充左侧列表控件
function p.FillListContainer( pParentLayer, tPetTable )
	if ( pParentLayer == nil ) then
		LogInfo( "RoleTrainUI: FillListContainer() failed! pParentLayer is nil" );
		return false;
	end
	if ( tPetTable == nil ) then
		LogInfo( "RoleTrainUI: FillListContainer() failed! tPetTable is nil" );
		return false;
	end
	local nPetAmount		= table.getn( tPetTable );
	if ( nPetAmount == 0 ) then
		return false;
	end
	-- 获得滚屏容器
	local pScrollViewContainer = GetScrollViewContainer( pParentLayer,ID_LIST_CONTAINER );
	if nil == pScrollViewContainer then
		LogInfo( "RoleTrainUI: FillListContainer() failed! pScrollViewContainer is nil" );
		return false;
	end
	pScrollViewContainer:SetStyle( UIScrollStyle.Verical );
	pScrollViewContainer:SetViewSize( CGSizeMake( 58*2*2, 59*2*2 ) );-- 设置列表项的宽高--待定
	
	local nListItemAmount	= ( nPetAmount + ( PET_NUM_PER_LISTITEM - 1 ) ) / PET_NUM_PER_LISTITEM;
	for i = 1, nListItemAmount do
		local pListItem = createUIScrollView();
	
		if not CheckP( pListItem ) then
			LogInfo( "RoleTrainUI: pListItem == nil" );
			return false;
		end
	
		pListItem:Init( false );
		pListItem:SetScrollStyle( UIScrollStyle.Verical );
		pListItem:SetViewId( i );
		pListItem:SetTag( i );
		pScrollViewContainer:AddView( pListItem );
	
		--初始化ui
		local uiLoad = createNDUILoad();
		if not CheckP(uiLoad) then
			LogInfo( "RoleTrainUI: FillListContainer failed! uiLoad is nil" );
			return false;
		end
		uiLoad:Load( "RoleTrainUI_ListItem.ini", pListItem, p.OnListItemEvent, 0, 0 );
		uiLoad:Free();
		
		local pLeftBtn		= GetButton( pListItem, tIconIDInListItem[1] );
		local pRightBtn 	= GetButton( pListItem, tIconIDInListItem[2] );
		local nLeftPetID	= tPetTable[PET_NUM_PER_LISTITEM*i];
		local nRightPetID	= tPetTable[PET_NUM_PER_LISTITEM*i+1];
		
		if ( nLeftPetID ~= nil ) then
			local nPetType	= RolePet.GetPetInfoN( nLeftPetID, PET_ATTR.PET_ATTR_TYPE )
			local pPic		= GetPetPotraitPic(nPetType);
			if CheckP(pPic) then
				pLeftBtn:SetImage( pPic, true );
				pLeftBtn:SetTag( nLeftPetID );
			end
		else
			pLeftBtn:SetVisible( false );
		end
		
		if ( nRightPetID ~= nil ) then
			local nPetType	= RolePet.GetPetInfoN( nRightPetID, PET_ATTR.PET_ATTR_TYPE )
			local pPic		= GetPetPotraitPic(nPetType);
			if CheckP(pPic) then
				pRightBtn:SetImage( pPic, true );
				pRightBtn:SetTag( nRightPetID );
			end
		else
			pRightBtn:SetVisible( false );
		end
		
		local pBorder = GetImage( pListItem, ID_LIST_ITEM_BORDER );
		if ( pBorder ~= nil ) then
			pScrollViewContainer:SetViewSize( pBorder:GetFrameRect().size );
		end
		
	end
end

---------------------------------------------------
-- 响应列表项的事件
function p.OnListItemEvent( uiNode, uiEventType, param )
	local nTag = uiNode:GetTag();
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		--LogInfo( "RoleTrainUI: OnListItemEvent() nTag:%d", nTag );
		if ( p.nCheckedPetID ~= nTag ) then
			p.nCheckedPetID = nTag;
			p.RefreshRightZone( p.nCheckedPetID );
		end
	end
	return true;
end

---------------------------------------------------
-- 处理网络消息
function p.HandleNetMsg( nMsgID, param )
	if ( nMsgID == nil ) then
		LogInfo("RoleTrainUI: HandleNetMsg() nMsgID = nil" );
		return;
	end
	LogInfo("RoleTrainUI: HandleNetMsg() nMsgID:%d", nMsgID );
	if ( nMsgID == NMSG_Type._MSG_TRAIN_INFO_LIST ) then
		if ( p.nCheckedPetID ~= nil ) then
			p.RefreshRightZone( p.nCheckedPetID );
		end
	end
	--CloseLoadBar();
end

---------------------------------------------------

