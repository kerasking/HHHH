---------------------------------------------------
--描述: 宴会
--时间: 2012.10.19
--作者: Guosen
---------------------------------------------------
-- 进入宴会界面接口：		Banquet.Entry()
---------------------------------------------------

Banquet = {}
local p = Banquet;


---------------------------------------------------
-- 主界面控件
local ID_BTN_CLOSE					= 4;	-- X
local ID_LABEL_SELVER				= 243;	-- 银币值
local ID_LABEL_GOLD					= 242;	-- 金币值
local ID_PIC_LEFT_ZONE				= 2;	-- 左侧区域
local ID_PIC_RIGHTT_ZONE			= 3;	-- 右侧区域

-- 宴会说明界面控件
local ID_LABEL_PLAYERINFOR			= 30;	-- 玩家信息标签
local ID_BTN_PREPARE				= 817;	-- 筹备宴会按钮

-- 宴会界面控件-主办
local ID_BTN_CACEL					= 59;	-- 取消宴会按钮
local ID_BTN_START					= 58;	-- 开席按钮
local ID_BTN_GOLDSTART				= 817;	-- 金币开席按钮

-- 出席者列表项控件
local ID_LIST_ATTENDEE				= 148;	-- 出席者列表控件
local ID_BTN_SHOWTHEDOOR			= 4;	-- 驱逐按钮--
local ID_LEBEL_PLAYER_NAME			= 6;	-- 玩家名标签
local ID_LEBEL_PLAYER_LEVEL			= 7;	-- 等级标签

-- 宴会界面控件-宾客
local ID_BTN_LEAVE					= 58;	-- 离开按钮

-- 宴会列表界面控件
local ID_LIST_BANQUET				= 29;	-- 宴会列表控件
local ID_LABEL_HOSTNAME				= 5;	-- 主人名标签
local ID_LABEL_NUMBER				= 6;	-- 人数标签
local ID_BTN_JOIN					= 7;	-- 参加按钮
local ID_PIC_LIST_ITEM_BORDER		= 1;	-- 列表项的边框
local ID_LEBEL_BANQUET				= 2;	-- “宴会”静态标签
local ID_LEBEL_HOST					= 3;	-- “发起者”静态标签
local ID_LEBEL_ATTENDEE				= 4;	-- “参加人数”静态标签


---------------------------------------------------
local LEVEL_LIMIT					= 40;	-- 等级限制
local REPUTE_LIMIT					= 500;	-- 声望限制
local SOUL_LIMIT					= 100;	-- 将魂限制
local BANQUET_CARD					= 21000000;	-- 宴会卡的 ITEM_TYPE
local GOLD_LIMIT					= 10;	-- 金币开席的金币需求
local AMOUNT_LIMIT					= 3;	-- 开席的人数需求

---------------------------------------------------
local SZ_ERROR_00				= GetTxtPri("MB_T5");
local SZ_ERROR_01				= GetTxtPri("MB_T6");
local SZ_ERROR_02				= GetTxtPri("MB_T7");
local SZ_ERROR_03				= GetTxtPri("MB_T8");
local SZ_ERROR_04				= GetTxtPri("MB_T9");
local SZ_ERROR_05				= GetTxtPri("MB_T10");
local SZ_ERROR_06				= GetTxtPri("MB_T11");

---------------------------------------------------
local SZ_TIPS_GUEST				= GetTxtPri("MB_T12")
local SZ_TIPS_HOST				= GetTxtPri("MB_T13")
local SZ_TIPS_5					= GetTxtPri("MB_T14")
local SZ_TIPS_10				= GetTxtPri("MB_T15")

---------------------------------------------------
local SZ_PLAYER_INFO_00			= GetTxtPri("MB_T16");
local SZ_PLAYER_INFO_01			= GetTxtPri("MB_T17");--
local SZ_PLAYER_INFO_02			= GetTxtPri("MB_T18");--
local SZ_PLAYER_INFO_03			= GetTxtPri("MB_T19");

---------------------------------------------------
local SZ_START_SUCCEED			= GetTxtPri("MB_T20");
local SZ_GOLD_START_SUCCEED		= GetTxtPri("MB_T21");
local SZ_CANCEL_SUCCEED			= GetTxtPri("MB_T22");
local SZ_TIME_OUT				= GetTxtPri("MB_T23");
local SZ_SHOW_THE_DOOR			= GetTxtPri("MB_T24");

---------------------------------------------------

---------------------------------------------------
p.pLayerNotice				= nil;	-- 左侧公告（未到宴会时间才显示）
p.pLayerBanquetList			= nil;	-- 左侧宴会列表（到宴会时间才显示）
p.pLayerPlayerInfor			= nil;	-- 右侧提示（未到宴会时间不显示按钮）
p.pLayerBanquetInfor_Host	= nil;	-- 右侧宴会详细信息--主办
p.pLayerBanquetInfor_Guest	= nil;	-- 右侧宴会详细信息--来宾
p.tBanquetList				= nil;	-- 宴会列表--
p.BanquetStatus				= nil;	-- 宴会状态--
p.tBanquetInfor				= nil;	-- 宴会信息(包含出席者列表 tAttendeeList)
p.nTimerID					= nil;	-- 定时器
p.nFreeBanquetAmount		= nil;	-- 免费宴会次数

---------------------------------------------------
-- 进入--时间点到才可以
function p.Entry()
p.pLayerNotice				= nil;
p.pLayerBanquetList			= nil;
p.pLayerPlayerInfor			= nil;
p.pLayerBanquetInfor_Host	= nil;
p.pLayerBanquetInfor_Guest	= nil;
p.tBanquetList				= nil;
p.BanquetStatus				= nil;
p.tBanquetInfor				= nil;
p.nTimerID					= nil;
p.nFreeBanquetAmount		= nil;
	local nUserID		= GetPlayerId();
	local nPlayerPetID	= RolePetFunc.GetMainPetId( nUserID );
	local nPlayerLevel	= RolePet.GetPetInfoN( nPlayerPetID, PET_ATTR.PET_ATTR_LEVEL );
	if ( nPlayerLevel < LEVEL_LIMIT ) then
		CommonDlgNew.ShowYesDlg( SZ_ERROR_00, nil, nil, 3 );
		return;
	end
--	p.ShowBanquetMainUI();
	ShowLoadBar();--
	MsgBanquet.SendMsgGetFreeCardAmount();
end


---------------------------------------------------
-- 获得免费宴会次数回调
function p.CallBack_GetFreeCardAmount( nFreeBanquetAmount )
	CloseLoadBar();--
	p.nFreeBanquetAmount = nFreeBanquetAmount;
	if not IsUIShow( NMAINSCENECHILDTAG.Banquet ) then
		p.ShowBanquetMainUI();
	end
end



---------------------------------------------------
-- 检测玩家是否有某种道具
-- 参数：该道具的 ITEM_TYPE
function p.GetItemAmount( nItemType )
    local nCount = 0;
	local nUserID		= GetPlayerId();
	local tItemIDList	= ItemUser.GetBagItemList( nUserID );
	for i,v in ipairs( tItemIDList ) do
		local nItemTypeTmp	= Item.GetItemInfoN( v, Item.ITEM_TYPE );
		if( nItemTypeTmp == nItemType ) then
            nCount = Item.GetItemInfoN( v, Item.ITEM_AMOUNT );
			break;
		end
	end
	return nCount;
end

---------------------------------------------------
-- 显示宴会主界面
function p.ShowBanquetMainUI()
	--LogInfo( "Banquet: ShowBanquetMainUI()" );
	local scene = GetSMGameScene();
	if not CheckP(scene) then
	LogInfo( "Banquet: ShowBanquetMainUI failed! scene is nil" );
		return false;
	end
	
	local layer = createNDUILayer();
	if not CheckP(layer) then
		LogInfo( "Banquet: ShowBanquetMainUI failed! layer is nil" );
		return false;
	end
	layer:Init();
	layer:SetTag( NMAINSCENECHILDTAG.Banquet );
	layer:SetFrameRect( RectFullScreenUILayer );
	scene:AddChildZ( layer, UILayerZOrder.ActivityLayer );

	local uiLoad = createNDUILoad();
	if ( nil == uiLoad ) then
		layer:Free();
		LogInfo( "Banquet: ShowBanquetMainUI failed! uiLoad is nil" );
		return false;
	end
	uiLoad:Load( "Banquet/BanquetUI_Main.ini", layer, p.OnUIEventMain, 0, 0 );
	uiLoad:Free();
	p.RefreshMoney();--显示银币与金币
	
	local pLeftBoder	= GetImage( layer, ID_PIC_LEFT_ZONE );
	local tLeftRect		= pLeftBoder:GetFrameRect();
	local pRightBoder	= GetImage( layer, ID_PIC_RIGHTT_ZONE );
	local tRightRect	= pRightBoder:GetFrameRect();
	
	p.BanquetStatus = BanquetStatus.BS_NONE;
	p.CreateNoticeLayer( layer, tLeftRect );
	p.CreateBanquetListLayer( layer, tLeftRect );
	p.CreatePlayerInforLayer( layer, tRightRect );
	p.CreateBanquetInforLayer_Host( layer, tRightRect );
	p.CreateBanquetInforLayer_Guest( layer, tRightRect );
	p.pLayerNotice:SetVisible( false );
	p.pLayerBanquetInfor_Host:SetVisible( false );
	p.pLayerBanquetInfor_Guest:SetVisible( false );
end

-- 关闭宴会界面
function p.CloseUI()
	local scene = GetSMGameScene();
	if ( scene ~= nil ) then
		scene:RemoveChildByTag( NMAINSCENECHILDTAG.Banquet, true );--p.pLayerMainUI:RemoveFromParent( true );
	end
	if ( p.nTimerID ~= nil ) then
		UnRegisterTimer( p.nTimerID );
	end
p.pLayerNotice				= nil;
p.pLayerBanquetList			= nil;
p.pLayerPlayerInfor			= nil;
p.pLayerBanquetInfor_Host	= nil;
p.pLayerBanquetInfor_Guest	= nil;
p.tBanquetList				= nil;
p.BanquetStatus				= nil;
p.tBanquetInfor				= nil;
p.nTimerID					= nil;
p.nFreeBanquetAmount		= nil;
end

---------------------------------------------------
-- 宴会界面的事件响应
function p.OnUIEventMain( uiNode, uiEventType, param )
	local tag = uiNode:GetTag();
	if ( uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK ) then
		if ( ID_BTN_CLOSE == tag ) then
			if ( p.BanquetStatus ~= BanquetStatus.BS_NONE ) then
				MsgBanquet.SendMsgLeaveBanquet();
			end
			p.CloseUI();
		end
	end
	return true;
end

---------------------------------------------------
-- 创建左侧公告层
function p.CreateNoticeLayer( pParentLayer, tRect )
	local layer = createNDUILayer();
	if not CheckP(layer) then
		LogInfo( "Banquet: CreateNoticeLayer failed! layer is nil" );
		return false;
	end
	layer:Init();
	--layer:SetTag( NMAINSCENECHILDTAG.Banquet );
	--layer:SetFrameRect( RectFullScreenUILayer );
	layer:SetFrameRect( tRect );
	pParentLayer:AddChildZ( layer, 1 );

	local uiLoad = createNDUILoad();
	if ( nil == uiLoad ) then
		layer:Free();
		LogInfo( "Banquet: CreateNoticeLayer failed! uiLoad is nil" );
		return false;
	end
	uiLoad:Load( "Banquet/BanquetUI_Notice.ini", layer, nil, 0, 0 );
	uiLoad:Free();
	p.pLayerNotice = layer;
end

---------------------------------------------------
-- 创建左侧宴会列表层
function p.CreateBanquetListLayer( pParentLayer, tRect )
	local layer = createNDUILayer();
	if not CheckP(layer) then
		LogInfo( "Banquet: CreateNoticeLayer failed! layer is nil" );
		return false;
	end
	layer:Init();
	--layer:SetTag( NMAINSCENECHILDTAG.Banquet );
	--layer:SetFrameRect( RectFullScreenUILayer );
	layer:SetFrameRect( tRect );
	pParentLayer:AddChildZ( layer, 1 );

	local uiLoad = createNDUILoad();
	if ( nil == uiLoad ) then
		layer:Free();
		LogInfo( "Banquet: CreateNoticeLayer failed! uiLoad is nil" );
		return false;
	end
	uiLoad:Load( "Banquet/BanquetUI_BanquetList.ini", layer, nil, 0, 0 );
	uiLoad:Free();
	p.pLayerBanquetList = layer;
	
	--
	--local tBanquetList = MsgBanquet.GetBanquetList();--测试
	--p.RefreshBanquetList( tBanquetList );--测试
	MsgBanquet.SendMsgGetBanquetList();
	p.nTimerID = RegisterTimer( p.OnTimer_SendMsgGetBanquetList, 5 );--定时器-每5秒定时发送获取宴会列表消息
end


---------------------------------------------------
-- 创建右侧玩家信息层
function p.CreatePlayerInforLayer( pParentLayer, tRect )
	local layer = createNDUILayer();
	if not CheckP(layer) then
		LogInfo( "Banquet: CreatePlayerInforLayer failed! layer is nil" );
		return false;
	end
	layer:Init();
	--layer:SetTag( NMAINSCENECHILDTAG.Banquet );
	--layer:SetFrameRect( RectFullScreenUILayer );
	layer:SetFrameRect( tRect );
	pParentLayer:AddChildZ( layer, 1 );

	local uiLoad = createNDUILoad();
	if ( nil == uiLoad ) then
		layer:Free();
		LogInfo( "Banquet: CreatePlayerInforLayer failed! uiLoad is nil" );
		return false;
	end
	uiLoad:Load( "Banquet/BanquetUI_PlayerInfor.ini", layer, p.OnUIEventPlayerInforLayer, 0, 0 );
	uiLoad:Free();
	
	p.pLayerPlayerInfor = layer;
	p.InitPlayerInforLayer();
end

---------------------------------------------------
--
function p.InitPlayerInforLayer()
	if ( p.pLayerPlayerInfor == nil ) then
		return;
	end
	local pLabel	= GetLabel( p.pLayerPlayerInfor, ID_LABEL_PLAYERINFOR );
	local szInfor	= p.GetPlayerInfor();
	pLabel:SetText( szInfor );
end

---------------------------------------------------
-- 组织宴会说明文字
function p.GetPlayerInfor()
	local szHead = "";
	local nCardAmount = p.GetItemAmount( BANQUET_CARD );
	LogInfo( "Banquet: GetPlayerInfor nCardAmount:"..nCardAmount );
	if ( ( p.nFreeBanquetAmount ~= nil ) and ( p.nFreeBanquetAmount > 0 ) ) then
		szHead = SZ_PLAYER_INFO_00 .. string.format( SZ_PLAYER_INFO_01, p.nFreeBanquetAmount );
		if ( ( nCardAmount ~= nil ) and ( nCardAmount > 0 ) ) then
			szHead = szHead .. string.format( SZ_PLAYER_INFO_02, nCardAmount );
		end
	elseif ( ( nCardAmount ~= nil ) and ( nCardAmount > 0 ) ) then
		szHead = SZ_PLAYER_INFO_00 .. string.format( SZ_PLAYER_INFO_02, nCardAmount );
	end
	return ( szHead .. SZ_PLAYER_INFO_03 );
end

---------------------------------------------------
-- 右侧玩家信息界面的事件响应
function p.OnUIEventPlayerInforLayer( uiNode, uiEventType, param )
	local tag = uiNode:GetTag();
	if ( uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK ) then
		if ( tag == ID_BTN_PREPARE ) then
			local nUserID		= GetPlayerId();
			local nCardAmount	= p.GetItemAmount( BANQUET_CARD );
			if ( ( p.nFreeBanquetAmount == nil or p.nFreeBanquetAmount == 0 ) and ( nCardAmount == nil or nCardAmount == 0 ) ) then
				CommonDlgNew.ShowYesDlg( SZ_ERROR_01, nil, nil, 3 );
				return true;
			end
			local nRepute	= GetRoleBasicDataN( nUserID, USER_ATTR.USER_ATTR_REPUTE );
			if ( nRepute < REPUTE_LIMIT ) then
				CommonDlgNew.ShowYesDlg( SZ_ERROR_02, nil, nil, 3 );
				return true;
			end
			local nSoul	= GetRoleBasicDataN( nUserID, USER_ATTR.USER_ATTR_SOPH );
			if ( nSoul < SOUL_LIMIT ) then
				CommonDlgNew.ShowYesDlg( SZ_ERROR_03, nil, nil, 3 );
				return true;
			end
			ShowLoadBar();--
			MsgBanquet.SendMsgPrepareBanquet();
		end
	end
	return true;
end

---------------------------------------------------
-- 筹备成功回调
function p.CallBack_PrepareSucceed()
	CloseLoadBar();--
	p.BanquetStatus = BanquetStatus.BS_HOST;
	--
	p.pLayerPlayerInfor:SetVisible( false );
	p.pLayerBanquetInfor_Host:SetVisible( true );
	--
	local pScrollViewContainer = GetScrollViewContainer( p.pLayerBanquetList, ID_LIST_BANQUET );
	local nViewAmount = pScrollViewContainer:GetViewCount();
	for i=1, nViewAmount do
		local pView			= pScrollViewContainer:GetViewById( i );
		local pBtnJoin		= GetButton( pView, ID_BTN_JOIN )
		pBtnJoin:SetVisible( false );
	end
	--
	p.tBanquetInfor	= {};
	local nUserID	= GetPlayerId();
	local szName	= GetRoleBasicDataS( nUserID, USER_ATTR.USER_ATTR_NAME );
	local nPetID	= RolePetFunc.GetMainPetId( nUserID );
	local nLevel	= RolePet.GetPetInfoN( nPetID, PET_ATTR.PET_ATTR_LEVEL );
	p.tBanquetInfor.nHostUserID	= nUserID;
	p.tBanquetInfor.tAttendeeList		= {};
	p.tBanquetInfor.tAttendeeList[1]	= {};
	p.tBanquetInfor.tAttendeeList[1][ALDI.PlayerID]	= nUserID;
	p.tBanquetInfor.tAttendeeList[1][ALDI.Name]		= szName;
	p.tBanquetInfor.tAttendeeList[1][ALDI.Level]	= nLevel;
	p.FillBanquetInfor( p.pLayerBanquetInfor_Host, p.tBanquetInfor.tAttendeeList );
end


---------------------------------------------------
-- 创建右侧宴会信息层--主办
function p.CreateBanquetInforLayer_Host( pParentLayer, tRect )
	local layer = createNDUILayer();
	if not CheckP(layer) then
		LogInfo( "Banquet: CreatePlayerInforLayer failed! layer is nil" );
		return false;
	end
	layer:Init();
	--layer:SetTag( NMAINSCENECHILDTAG.Banquet );
	--layer:SetFrameRect( RectFullScreenUILayer );
	layer:SetFrameRect( tRect );
	pParentLayer:AddChildZ( layer, 1 );

	local uiLoad = createNDUILoad();
	if ( nil == uiLoad ) then
		layer:Free();
		LogInfo( "Banquet: CreatePlayerInforLayer failed! uiLoad is nil" );
		return false;
	end
	uiLoad:Load( "Banquet/BanquetUI_BanquetInfor0.ini", layer, p.OnUIEventBanquetInforLayer_Host, 0, 0 );
	uiLoad:Free();
	p.pLayerBanquetInfor_Host = layer;
	--local tBanquetInformation = MsgBanquet.GetBanquetInfor();--测试
	--p.FillBanquetInfor( p.pLayerBanquetInfor_Host, tBanquetInformation.tAttendeeList );--测试
end

---------------------------------------------------
-- 右侧宴会信息层--主办界面的事件响应
function p.OnUIEventBanquetInforLayer_Host( uiNode, uiEventType, param )
	local tag = uiNode:GetTag();
	if ( uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK ) then
	   if ( tag == ID_BTN_CACEL ) then
			ShowLoadBar();--
			MsgBanquet.SendMsgCancelBanquet();
		elseif ( tag == ID_BTN_START ) then
			--
			local nAmount = table.getn( p.tBanquetInfor.tAttendeeList );
			if ( nAmount < AMOUNT_LIMIT ) then
				CommonDlgNew.ShowYesDlg( SZ_ERROR_05, nil, nil, 3 );
				return true;
			end
			if ( nAmount < MsgBanquet.BanquetLimit ) then
				CommonDlgNew.ShowYesOrNoDlg( SZ_TIPS_5, p.CallBack_StartBanquet );
				return true;
			end
			ShowLoadBar();--
			MsgBanquet.SendMsgStartBanquet();
		elseif ( tag == ID_BTN_GOLDSTART ) then
			local nUserID = GetPlayerId();
			local nUserGold	= GetRoleBasicDataN( nUserID, USER_ATTR.USER_ATTR_EMONEY );
			if ( nUserGold < GOLD_LIMIT ) then
				CommonDlgNew.ShowYesDlg( SZ_ERROR_04, nil, nil, 3 );
				return true;
			end
			local nAmount = table.getn( p.tBanquetInfor.tAttendeeList );
			if ( nAmount < MsgBanquet.BanquetLimit ) then
				CommonDlgNew.ShowYesOrNoDlg( SZ_TIPS_10, p.CallBack_GoldStart );
				return true;
			end
			ShowLoadBar();--
			MsgBanquet.SendMsgGoldStart();
		end
	end
	return true;
end

---------------------------------------------------
function p.CallBack_StartBanquet( nEvent, param )
	if ( CommonDlgNew.BtnOk == nEvent ) then
		ShowLoadBar();--
		MsgBanquet.SendMsgStartBanquet();
	end
end

---------------------------------------------------
function p.CallBack_GoldStart( nEvent, param )
	if ( CommonDlgNew.BtnOk == nEvent ) then
		ShowLoadBar();--
		MsgBanquet.SendMsgGoldStart();
	end
end

---------------------------------------------------
-- 取消成功回调-(host取消，host和guest都收到)
function p.CallBack_CancelSucceed()
	CloseLoadBar();--
	CommonDlgNew.ShowYesDlg( SZ_CANCEL_SUCCEED, nil, nil, 3 );
	p.tBanquetInfor	= nil;
	p.BanquetStatus = BanquetStatus.BS_NONE;
	--
	p.pLayerPlayerInfor:SetVisible( true );
	p.pLayerBanquetInfor_Host:SetVisible( false );
	p.pLayerBanquetInfor_Guest:SetVisible( false );
	--
	local pScrollViewContainer = GetScrollViewContainer( p.pLayerBanquetList, ID_LIST_BANQUET );
	local nViewAmount = pScrollViewContainer:GetViewCount();
	for i=1, nViewAmount do
		local pView			= pScrollViewContainer:GetViewById( i );
		local pBtnJoin		= GetButton( pView, ID_BTN_JOIN )
		pBtnJoin:SetVisible( true );
	end
end

---------------------------------------------------
-- 开席成功回调
function p.CallBack_StartSucceed()
	CloseLoadBar();--
	CommonDlgNew.ShowYesDlg( SZ_START_SUCCEED, nil, nil, 3 );
	p.tBanquetInfor	= nil;
	p.BanquetStatus = BanquetStatus.BS_NONE;
	--
	if ( p.nFreeBanquetAmount ~= nil and p.nFreeBanquetAmount > 0 ) then
		p.nFreeBanquetAmount = p.nFreeBanquetAmount - 1;
	end
	p.InitPlayerInforLayer();--
	p.pLayerPlayerInfor:SetVisible( true );
	p.pLayerBanquetInfor_Host:SetVisible( false );
	p.pLayerBanquetInfor_Guest:SetVisible( false );
	--
	local pScrollViewContainer = GetScrollViewContainer( p.pLayerBanquetList, ID_LIST_BANQUET );
	local nViewAmount = pScrollViewContainer:GetViewCount();
	for i=1, nViewAmount do
		local pView			= pScrollViewContainer:GetViewById( i );
		local pBtnJoin		= GetButton( pView, ID_BTN_JOIN )
		pBtnJoin:SetVisible( true );
	end
end

---------------------------------------------------
-- 金币开席成功回调
function p.CallBack_GoldStartSucceed()
	CloseLoadBar();--
	CommonDlgNew.ShowYesDlg( SZ_GOLD_START_SUCCEED, nil, nil, 3 );
	p.tBanquetInfor	= nil;
	p.BanquetStatus = BanquetStatus.BS_NONE;
	--
	if ( p.nFreeBanquetAmount ~= nil and p.nFreeBanquetAmount > 0 ) then
		p.nFreeBanquetAmount = p.nFreeBanquetAmount - 1;
	end
	p.InitPlayerInforLayer();--
	p.pLayerPlayerInfor:SetVisible( true );
	p.pLayerBanquetInfor_Host:SetVisible( false );
	p.pLayerBanquetInfor_Guest:SetVisible( false );
	--
	local pScrollViewContainer = GetScrollViewContainer( p.pLayerBanquetList, ID_LIST_BANQUET );
	local nViewAmount = pScrollViewContainer:GetViewCount();
	for i=1, nViewAmount do
		local pView			= pScrollViewContainer:GetViewById( i );
		local pBtnJoin		= GetButton( pView, ID_BTN_JOIN )
		pBtnJoin:SetVisible( true );
	end
end

---------------------------------------------------
-- 创建右侧宴会信息层--来宾
function p.CreateBanquetInforLayer_Guest( pParentLayer, tRect )
	local layer = createNDUILayer();
	if not CheckP(layer) then
		LogInfo( "Banquet: CreatePlayerInforLayer failed! layer is nil" );
		return false;
	end
	layer:Init();
	--layer:SetTag( NMAINSCENECHILDTAG.Banquet );
	--layer:SetFrameRect( RectFullScreenUILayer );
	layer:SetFrameRect( tRect );
	pParentLayer:AddChildZ( layer, 1 );

	local uiLoad = createNDUILoad();
	if ( nil == uiLoad ) then
		layer:Free();
		LogInfo( "Banquet: CreatePlayerInforLayer failed! uiLoad is nil" );
		return false;
	end
	uiLoad:Load( "Banquet/BanquetUI_BanquetInfor1.ini", layer, p.OnUIEventBanquetInforLayer_Guest, 0, 0 );
	uiLoad:Free();
	p.pLayerBanquetInfor_Guest = layer;
	--
	--local tBanquetInformation = MsgBanquet.GetBanquetInfor();--测试
	--p.FillBanquetInfor( p.pLayerBanquetInfor_Guest, tBanquetInformation.tAttendeeList );--测试
end

---------------------------------------------------
-- 右侧宴会信息层--来宾界面的事件响应
function p.OnUIEventBanquetInforLayer_Guest( uiNode, uiEventType, param )
	local tag = uiNode:GetTag();
	if ( uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK ) then
		if ( tag == ID_BTN_LEAVE ) then
			ShowLoadBar();--
			MsgBanquet.SendMsgLeaveBanquet();
		end
	end
	return true;
end

---------------------------------------------------
-- 离开成功回调
function p.CallBack_LeaveSucceed()
	CloseLoadBar();--
	p.tBanquetInfor	= nil;
	p.BanquetStatus = BanquetStatus.BS_NONE;
	--
	p.pLayerPlayerInfor:SetVisible( true );
	p.pLayerBanquetInfor_Guest:SetVisible( false );
	--
	local pScrollViewContainer = GetScrollViewContainer( p.pLayerBanquetList, ID_LIST_BANQUET );
	local nViewAmount = pScrollViewContainer:GetViewCount();
	for i=1, nViewAmount do
		local pView			= pScrollViewContainer:GetViewById( i );
		local pBtnJoin		= GetButton( pView, ID_BTN_JOIN )
		pBtnJoin:SetVisible( true );
	end
end


---------------------------------------------------
-- 显示宴会列表
function p.ShowBanquetList()
end

-- 刷新宴会列表
function p.RefreshBanquetList( tBanquetList )
	if ( p.pLayerBanquetList == nil ) then
		LogInfo( "Banquet: RefreshBanquetList() failed! p.pLayerBanquetList is nil" );
		return false;
	end
	if ( tBanquetList == nil ) then
		return false;
	end
	p.tBanquetList = tBanquetList;
	
	local layer = createNDUILayer();
	layer:Init();
	local uiLoad=createNDUILoad();
	uiLoad:Load( "Banquet/BanquetUI_ListItem0.ini", layer, nil, 0, 0 );
	uiLoad:Free();
	local pBorder = GetImage( layer, ID_PIC_LIST_ITEM_BORDER );
	local tSize = pBorder:GetFrameRect().size;
	layer:Free();
	
	-- 获得滚屏容器
	local pScrollViewContainer = GetScrollViewContainer( p.pLayerBanquetList, ID_LIST_BANQUET );
	if ( nil == pScrollViewContainer ) then
		LogInfo( "Banquet: RefreshBanquetList() failed! pScrollViewContainer is nil" );
		return false;
	end
	pScrollViewContainer:EnableScrollBar(true);
	pScrollViewContainer:SetStyle( UIScrollStyle.Verical );
	pScrollViewContainer:SetViewSize( tSize );
	pScrollViewContainer:RemoveAllView();
	
	if ( tBanquetList == nil ) then
		LogInfo( "Banquet: RefreshBanquetList() failed! tBanquetList is nil" );
		return false;
	end
	
	local nListAmount = table.getn( tBanquetList );
	if ( nListAmount == 0 ) then
		return true;
	end
	--LogInfo( "Banquet: RefreshBanquetList() nListAmount:%d",nListAmount );
	for i = 1, nListAmount do
		local pListItem = createUIScrollView();
	
		if not CheckP( pListItem ) then
			LogInfo( "Banquet: RefreshBanquetList failed! pListItem == nil" );
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
			LogInfo( "ArmyGroup: RefreshBanquetList failed! uiLoad is nil" );
			return false;
		end
		uiLoad:Load( "Banquet/BanquetUI_ListItem0.ini", pListItem, p.OnUIEventBanquetListItem, 0, 0 );
		uiLoad:Free();
		
		local pLabelHostName	= GetLabel( pListItem, ID_LABEL_HOSTNAME );
		local pLabelNumber		= GetLabel( pListItem, ID_LABEL_NUMBER );
		local pBtnJoin			= GetButton( pListItem, ID_BTN_JOIN );
		
		local szHostName	= tBanquetList[i][BLIDI.HostName];
		local nNumber		= tBanquetList[i][BLIDI.AttendeeNumber];
		pLabelHostName:SetText( szHostName );
		pLabelNumber:SetText( nNumber .. "/" .. MsgBanquet.BanquetLimit );
		if ( p.BanquetStatus == BanquetStatus.BS_NONE ) then
			pBtnJoin:SetVisible( true );
		else
			pBtnJoin:SetVisible( false );
		end
		if ( p.tBanquetInfor ~= nil ) then
			local pLabelBanquet		= GetLabel( pListItem, ID_LEBEL_BANQUET );
			local pLabelHost		= GetLabel( pListItem, ID_LEBEL_HOST );
			local pLabelAttendee	= GetLabel( pListItem, ID_LEBEL_ATTENDEE );
			if ( p.tBanquetInfor.nHostUserID == tBanquetList[i][BLIDI.HostUserID] ) then
				pLabelHostName:SetFontColor( MsgArmyGroup.COLOR_YELLOW );
				pLabelNumber:SetFontColor( MsgArmyGroup.COLOR_YELLOW );
				pLabelBanquet:SetFontColor( MsgArmyGroup.COLOR_YELLOW );
				pLabelHost:SetFontColor( MsgArmyGroup.COLOR_YELLOW );
				pLabelAttendee:SetFontColor( MsgArmyGroup.COLOR_YELLOW );
			end
		end
	end
	
	return true;
end

---------------------------------------------------
-- 宴会列表项界面的事件响应
function p.OnUIEventBanquetListItem( uiNode, uiEventType, param )
	local tag = uiNode:GetTag();
	if ( uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK ) then
		if ( ID_BTN_JOIN == tag ) then
			local nUserID		= GetPlayerId();
			local nCardAmount	= p.GetItemAmount( BANQUET_CARD );
			if ( ( p.nFreeBanquetAmount == nil or p.nFreeBanquetAmount == 0 ) and ( nCardAmount == nil or nCardAmount == 0 ) ) then
				CommonDlgNew.ShowYesDlg( SZ_ERROR_01, nil, nil, 3 );
				return true;
			end
			local nRepute	= GetRoleBasicDataN( nUserID, USER_ATTR.USER_ATTR_REPUTE );
			if ( nRepute < REPUTE_LIMIT ) then
				CommonDlgNew.ShowYesDlg( SZ_ERROR_02, nil, nil, 3 );
				return true;
			end
			local nSoul	= GetRoleBasicDataN( nUserID, USER_ATTR.USER_ATTR_SOPH );
			if ( nSoul < SOUL_LIMIT ) then
				CommonDlgNew.ShowYesDlg( SZ_ERROR_03, nil, nil, 3 );
				return true;
			end
			local nIndex		= uiNode:GetParent():GetTag();
			local nAmount		= p.tBanquetList[nIndex][BLIDI.AttendeeNumber];
			if ( nAmount >= MsgBanquet.BanquetLimit ) then
				CommonDlgNew.ShowYesDlg( SZ_ERROR_06, nil, nil, 3 );
				return true;
			end
			local nHostUserID	= p.tBanquetList[nIndex][BLIDI.HostUserID];
			ShowLoadBar();--
			MsgBanquet.SendMsgJoinBanquet( nHostUserID );
		end
	end
	return true;
end

---------------------------------------------------
-- 加入成功回调
function p.CallBack_JoinSucceed()
	CloseLoadBar();--
	p.BanquetStatus = BanquetStatus.BS_GUEST;
	--
	p.pLayerPlayerInfor:SetVisible( false );
	p.pLayerBanquetInfor_Guest:SetVisible( true );
	--
	local pScrollViewContainer = GetScrollViewContainer( p.pLayerBanquetList, ID_LIST_BANQUET );
	local nViewAmount = pScrollViewContainer:GetViewCount();
	for i=1, nViewAmount do
		local pView			= pScrollViewContainer:GetViewById( i );
		local pBtnJoin		= GetButton( pView, ID_BTN_JOIN )
		pBtnJoin:SetVisible( false );
	end
	--p.FillBanquetInfor( p.pLayerBanquetInfor_Guest, tBanquetInformation.tAttendeeList );
	local pScrollViewContainer = GetScrollViewContainer( p.pLayerBanquetInfor_Guest, ID_LIST_ATTENDEE );
	pScrollViewContainer:RemoveAllView();
end


---------------------------------------------------
-- 显示宴会信息(人员及其他)
function p.ShowBanquetInformation()
end

-- 刷新宴会信息(人员及其他)
function p.RefreshBanquetInformation( tBanquetInformation )
	if ( p.BanquetStatus == BanquetStatus.BS_GUEST ) then
		if ( p.pLayerBanquetInfor_Guest == nil ) then
			return false;
		end
		p.tBanquetInfor = tBanquetInformation;
		p.FillBanquetInfor( p.pLayerBanquetInfor_Guest, p.tBanquetInfor.tAttendeeList );
	elseif ( p.BanquetStatus == BanquetStatus.BS_HOST ) then
		if ( p.pLayerBanquetInfor_Host == nil ) then
			return false;
		end
		p.tBanquetInfor = tBanquetInformation;
		p.FillBanquetInfor( p.pLayerBanquetInfor_Host, p.tBanquetInfor.tAttendeeList );
		-- 金币开席按钮在参与者达5个人后变灰
		local pBtnGoldStart = GetButton( p.pLayerBanquetInfor_Host, ID_BTN_GOLDSTART );
		if ( table.getn( p.tBanquetInfor.tAttendeeList ) < MsgBanquet.BanquetLimit ) then
			pBtnGoldStart:EnalbeGray( false );
		else
			pBtnGoldStart:EnalbeGray( true );
		end
	end
	return false;
end

-- 填充宴会信息出席者列表
function p.FillBanquetInfor( pLayer, tAttendeeList )
	if ( pLayer == nil ) then
		LogInfo( "Banquet: FillBanquetInfor() failed! pLayer is nil" );
		return false;
	end
	if ( tAttendeeList == nil ) then
		LogInfo( "Banquet: FillBanquetInfor() failed! tAttendeeList is nil" );
		return false;
	end
	
	
	local layer = createNDUILayer();
	layer:Init();
	local uiLoad=createNDUILoad();
	uiLoad:Load( "Banquet/BanquetUI_ListItem1.ini", layer, nil, 0, 0 );
	uiLoad:Free();
	local pBorder = GetImage( layer, ID_PIC_LIST_ITEM_BORDER );
	local tSize = pBorder:GetFrameRect().size;
	layer:Free();
	
	-- 获得滚屏容器
	local pScrollViewContainer = GetScrollViewContainer( pLayer, ID_LIST_ATTENDEE );
	if ( nil == pScrollViewContainer ) then
		LogInfo( "Banquet: FillBanquetInfor() failed! pScrollViewContainer is nil" );
		return false;
	end
	pScrollViewContainer:EnableScrollBar(true);
	pScrollViewContainer:SetStyle( UIScrollStyle.Verical );
	pScrollViewContainer:SetViewSize( tSize );
	pScrollViewContainer:RemoveAllView();
	
	if ( tAttendeeList == nil ) then
		LogInfo( "Banquet: FillBanquetInfor() failed! tAttendeeList is nil" );
		return false;
	end
	
	local nListAmount = table.getn( tAttendeeList );
	if ( nListAmount == 0 ) then
		LogInfo( "Banquet: FillBanquetInfor() failed! nListAmount is 0" );
		return false;
	end
	LogInfo( "Banquet: FillBanquetInfor() nListAmount:%d",nListAmount );
	local nUserID = GetPlayerId();
	for i = 1, nListAmount do
		local pListItem = createUIScrollView();
	
		if not CheckP( pListItem ) then
			LogInfo( "Banquet: RefreshBanquetList failed! pListItem == nil" );
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
			LogInfo( "ArmyGroup: FillBanquetInfor failed! uiLoad is nil" );
			return false;
		end
		uiLoad:Load( "Banquet/BanquetUI_ListItem1.ini", pListItem, p.OnUIEventBanquetInforItem, 0, 0 );
		uiLoad:Free();
		
		local pLabelName	= GetLabel( pListItem, ID_LEBEL_PLAYER_NAME );
		local pLabelLevel	= GetLabel( pListItem, ID_LEBEL_PLAYER_LEVEL );
		local pBtnX			= GetButton( pListItem, ID_BTN_SHOWTHEDOOR );
		
		local szName	= tAttendeeList[i][ALDI.Name];
		local nLevel	= tAttendeeList[i][ALDI.Level];
		local nPlayerID	= tAttendeeList[i][ALDI.PlayerID];
		pLabelName:SetText( szName );
		pLabelLevel:SetText( SafeN2S(nLevel) );
		if ( p.BanquetStatus == BanquetStatus.BS_HOST and nUserID ~= nPlayerID ) then
			pBtnX:SetVisible( true );
		else
			pBtnX:SetVisible( false );
		end
	end
	
end

---------------------------------------------------
-- 宴会信息列表项界面的事件响应
function p.OnUIEventBanquetInforItem( uiNode, uiEventType, param )
	local tag = uiNode:GetTag();
	if ( uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK ) then
		if ( ID_BTN_SHOWTHEDOOR == tag ) then
			if ( p.BanquetStatus ~= BanquetStatus.BS_HOST ) then
				return true;
			end
		end
		local nIndex	= uiNode:GetParent():GetTag();
		local nPlayerID	= p.tBanquetInfor.tAttendeeList[nIndex][ALDI.PlayerID];
		local nUserID	= GetPlayerId();
		if ( nPlayerID == nUserID ) then
			return true;
		end
		--
		ShowLoadBar();--
		MsgBanquet.SendMsgShowTheDoor( nPlayerID );
	end
	return true;
end

---------------------------------------------------
-- 驱逐成功回调
function p.CallBack_ShowTheDoorSucceed( nPlayerID )
	if ( p.BanquetStatus == BanquetStatus.BS_HOST ) then
		-- 当前玩发起驱逐
		CloseLoadBar();--
		for i, v in pairs( p.tBanquetInfor.tAttendeeList ) do
			if ( nPlayerID == v[ALDI.PlayerID] ) then
				table.remove( p.tBanquetInfor.tAttendeeList, i );
				break;
			end
		end
		p.FillBanquetInfor( p.pLayerBanquetInfor_Host, p.tBanquetInfor.tAttendeeList );
		-- 金币开席按钮在参与者达5个人后变灰
		local pBtnGoldStart = GetButton( p.pLayerBanquetInfor_Host, ID_BTN_GOLDSTART );
		if ( table.getn( p.tBanquetInfor.tAttendeeList ) < MsgBanquet.BanquetLimit ) then
			pBtnGoldStart:EnalbeGray( false );
		else
			pBtnGoldStart:EnalbeGray( true );
		end
	elseif ( p.BanquetStatus == BanquetStatus.BS_GUEST ) then
		-- 当前玩家被驱逐
		if ( nPlayerID == GetPlayerId() ) then
			p.tBanquetInfor	= nil;
			p.BanquetStatus = BanquetStatus.BS_NONE;
			--
			p.pLayerPlayerInfor:SetVisible( true );
			p.pLayerBanquetInfor_Guest:SetVisible( false );
			--
			local pScrollViewContainer = GetScrollViewContainer( p.pLayerBanquetList, ID_LIST_BANQUET );
			local nViewAmount = pScrollViewContainer:GetViewCount();
			for i=1, nViewAmount do
				local pView			= pScrollViewContainer:GetViewById( i );
				local pBtnJoin		= GetButton( pView, ID_BTN_JOIN )
				pBtnJoin:SetVisible( true );
			end
			CommonDlgNew.ShowYesDlg( SZ_SHOW_THE_DOOR, nil, nil, 3 );
		end
	end
end

---------------------------------------------------
-- 定时发送获取宴会列表请求
function p.OnTimer_SendMsgGetBanquetList( nTimerID )
	if not IsUIShow( NMAINSCENECHILDTAG.Banquet ) then
		UnRegisterTimer( nTimerID );
		return;
	end
	if ( p.pLayerBanquetList == nil ) then
		UnRegisterTimer( nTimerID );
		return;
	end
	MsgBanquet.SendMsgGetBanquetList();
end

---------------------------------------------------
-- 宴会时间过回调
function p.CallBack_TimeOut()
	CloseLoadBar();--
	CommonDlgNew.ShowYesDlg( SZ_TIME_OUT, nil, nil, 3 );
	p.tBanquetInfor	= nil;
	p.BanquetStatus = BanquetStatus.BS_NONE;
	p.pLayerPlayerInfor:SetVisible( true );
	p.pLayerNotice:SetVisible( true );
	p.pLayerBanquetList:SetVisible( false );
	p.pLayerBanquetInfor_Host:SetVisible( false );
	p.pLayerBanquetInfor_Guest:SetVisible( false );
	if ( p.nTimerID ~= nil ) then
		UnRegisterTimer( p.nTimerID );
		p.nTimerID = nil;
	end
	local pBtn = GetButton( p.pLayerPlayerInfor, ID_BTN_PREPARE );
	pBtn:EnalbeGray( true );
end


---------------------------------------------------
-- 显示出错文字
function p.ShowErrorString( nCode )
end


---------------------------------------------------
--刷新金钱
function p.RefreshMoney()
    LogInfo("Banquet: RefreshMoney");
    local pScene = GetSMGameScene();
    if( pScene == nil ) then
        return;
    end
    local pLayer = GetUiLayer( pScene, NMAINSCENECHILDTAG.Banquet );
    if( pLayer == nil ) then
        return;
    end
    local nUserID		= GetPlayerId();
    local szSilver		= MoneyFormat( GetRoleBasicDataN( nUserID, USER_ATTR.USER_ATTR_MONEY ) );
    local szGold		= SafeN2S( GetRoleBasicDataN( nUserID, USER_ATTR.USER_ATTR_EMONEY ) );
    
    _G.SetLabel( pLayer, ID_LABEL_SELVER, szSilver);
    _G.SetLabel( pLayer, ID_LABEL_GOLD, szGold);
end
GameDataEvent.Register( GAMEDATAEVENT.USERATTR, "Banquet.RefreshMoney", p.RefreshMoney );
