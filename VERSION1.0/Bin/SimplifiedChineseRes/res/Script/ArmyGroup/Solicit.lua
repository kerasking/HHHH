---------------------------------------------------
--描述: 招募成员界面
--时间: 2012.9.21
--作者: Guosen
---------------------------------------------------

Solicit = {}
local p = Solicit;

---------------------------------------------------
local ID_BTN_INFOR					= 16;	-- “查看资料”按钮ID
local ID_BTN_FRIEND					= 17;	-- “加为好友”按钮ID
local ID_BTN_CHAT					= 18;	-- “私聊”按钮ID
local ID_BTN_APPROVE				= 19	-- “批准加入”按钮ID
local ID_BTN_REFUSE					= 20;	-- “拒绝申请”按钮ID

local ID_LIST_CONTAINER				= 10;	-- 申请人列表容器控件ID

---------------------------------------------------
local ID_PIC_BORDER					= 1;	-- 列表项边框
local ID_LABEL_NAME					= 12;	-- 名字
local ID_LABEL_LEVEL				= 13;	-- 等级
local ID_LABEL_RANKING				= 14;	-- 排名
local ID_LABEL_REPUTATION			= 15;	-- 声望
local ID_BTN_TOUCH					= 16;	-- 按钮

---------------------------------------------------
local SZ_ERROR_00					= "军团内人员已满……";

---------------------------------------------------
p.pChosenListItem		= nil;

---------------------------------------------------
--
function p.InitializeSolicitUI( pLayer )
p.pChosenListItem		= nil;
	local uiLoad = createNDUILoad();
	if ( nil == uiLoad ) then
		pLayer:Free();
		LogInfo( "Solicit: InitializeSolicitUI failed! uiLoad is nil" );
		return false;
	end
	uiLoad:Load( "ArmyGroup/ArmyGroupUI_Solicit.ini", pLayer, p.OnUIEventSolicit, 0, 0 );
	uiLoad:Free();
	
	local pBtnApprove	= GetButton( pLayer, ID_BTN_APPROVE );
	local pBtnRefuse	= GetButton( pLayer, ID_BTN_REFUSE );
	local nUserID = GetPlayerId();
	local nUserArmyGroupID = MsgArmyGroup.GetUserArmyGroupID( nUserID );
	local nPosition = MsgArmyGroup.GetUserArmyGroupPosition( nUserID );
	if ( nUserArmyGroupID == ArmyGroup.nArmyGroupID and nPosition ~= ArmyGroupPositionGrade.AGPG_NONE ) then
		-- 本军团的且有职位(本军团的军团长和副军团长才可以招募成员)
		pBtnApprove:SetVisible( true );
		pBtnRefuse:SetVisible( true );
	else
		pBtnApprove:SetVisible( false );
		pBtnRefuse:SetVisible( false );
	end
	
	local tApplicantList = MsgArmyGroup.GetArmyGroupApplicantList( ArmyGroup.nArmyGroupID );
	p.FillApplicantList( pLayer, tApplicantList );
	return true;
end

---------------------------------------------------
-- 军团招募成员界面的事件响应
function p.OnUIEventSolicit( uiNode, uiEventType, param )
	local tag = uiNode:GetTag();
	local tApplicantList = MsgArmyGroup.GetArmyGroupApplicantList( nArmyGroupID );
	--local nApplicantAmount = table.getn( tApplicantList );
	if ( uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK ) then
        if ( ID_BTN_INFOR == tag ) then
        	if ( p.pChosenListItem ~= nil ) then
        		local nOrdinal = p.pChosenListItem:GetTag();
        		local nUserID = tApplicantList[nOrdinal][ArmyGroupApplicantIndex.AGAI_USERID];
        		local szName = tApplicantList[nOrdinal][ArmyGroupApplicantIndex.AGAI_NAME];
				LogInfo( "Solicit: nUserID:%d, szName:%s",nUserID,szName );
        		-- 发送查看资料请求
        		--MsgFriend.SendGetFriendInfo( nUserID );
				MsgFriend.SendFriendSel( nUserID, szName, nil );
        	end
		elseif ( ID_BTN_FRIEND == tag ) then
        	if ( p.pChosenListItem ~= nil ) then
        		local nOrdinal = p.pChosenListItem:GetTag();
        		local nUserID = tApplicantList[nOrdinal][ArmyGroupApplicantIndex.AGAI_USERID];
        		-- 发送加好友请求
        		MsgFriend.SendFriendAdd( nUserID );
        	end
		elseif ( ID_BTN_CHAT == tag ) then
        	if ( p.pChosenListItem ~= nil ) then
        		local nOrdinal = p.pChosenListItem:GetTag();
        		local szName = tApplicantList[nOrdinal][ArmyGroupApplicantIndex.AGAI_NAME];
        		-- 发送私聊请求
        		ChatMainUI.LoadUIbyFriendName(szName);
        	end
		elseif ( ID_BTN_APPROVE == tag ) then
        	if ( p.pChosenListItem ~= nil ) then
        		local tAGInformation = MsgArmyGroup.GetArmyGroupInformation( ArmyGroup.nArmyGroupID );
        		if ( tAGInformation.nMember == tAGInformation.nMemberLimit ) then
					CommonDlgNew.ShowYesDlg( SZ_ERROR_00, nil, nil, 3 );
        			return true;
        		end
        		-- 发送批准消息
        		local nOrdinal = p.pChosenListItem:GetTag();
        		local nUserID = tApplicantList[nOrdinal][ArmyGroupApplicantIndex.AGAI_USERID];
        		MsgArmyGroup.SendMsgApproveApplication( nUserID );
        	end
		elseif ( ID_BTN_REFUSE == tag ) then
        	if ( p.pChosenListItem ~= nil ) then
        		-- 发送拒绝消息
        		local nOrdinal = p.pChosenListItem:GetTag();
        		local nUserID = tApplicantList[nOrdinal][ArmyGroupApplicantIndex.AGAI_USERID];
        		MsgArmyGroup.SendMsgRefuseApplication( nUserID );
        	end
        end
    end
    return true;
end

---------------------------------------------------
-- 填充申请者列表
function p.FillApplicantList( pLayer, tApplicantList )
	if ( pLayer == nil ) then
		LogInfo( "Solicit: FillApplicantList() failed! pLayer is nil" );
		return false;
	end
	if ( tApplicantList == nil ) then
		LogInfo( "Solicit: FillApplicantList() failed! tApplicantList is nil" );
		return false;
	end
	
	local layer = createNDUILayer();
	layer:Init();
	local uiLoad=createNDUILoad();
	uiLoad:Load( "ArmyGroup/ArmyGroupUI_ApplicantListItem.ini", layer, nil, 0, 0 );
	uiLoad:Free();
	local pBorder = GetImage( layer, ID_PIC_BORDER );
	local tSize = pBorder:GetFrameRect().size;
	layer:Free();
    
	-- 获得滚屏容器
	local pScrollViewContainer = GetScrollViewContainer( pLayer, ID_LIST_CONTAINER );
	if ( nil == pScrollViewContainer ) then
		LogInfo( "Solicit: FillApplicantList() failed! pScrollViewContainer is nil" );
		return false;
	end
    pScrollViewContainer:EnableScrollBar(true);
	pScrollViewContainer:SetStyle( UIScrollStyle.Verical );
	pScrollViewContainer:SetViewSize( tSize );
	pScrollViewContainer:RemoveAllView();
	
	local nApplicantAmount = table.getn( tApplicantList );
	if ( nApplicantAmount == 0 ) then
		LogInfo( "Solicit: FillApplicantList() failed! nApplicantAmount is 0" );
		return false;
	end
	for i = 1, nApplicantAmount do
		local pListItem = createUIScrollView();
	
		if not CheckP( pListItem ) then
			LogInfo( "Solicit: FillApplicantList() failed! pListItem == nil" );
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
			LogInfo( "Solicit: FillApplicantList failed! uiLoad is nil" );
			return false;
		end
		uiLoad:Load( "ArmyGroup/ArmyGroupUI_ApplicantListItem.ini", pListItem, p.OnUIEventApplicantListItem, 0, 0 );
		uiLoad:Free();
		
		local pLabelName		= GetLabel( pListItem, ID_LABEL_NAME );
		local pLabelLevel		= GetLabel( pListItem, ID_LABEL_LEVEL );
		local pLabelRanking		= GetLabel( pListItem, ID_LABEL_RANKING );
		local pLabelReputation	= GetLabel( pListItem, ID_LABEL_REPUTATION );
		LogInfo( "Solicit: FillApplicantList "..tApplicantList[i][ArmyGroupApplicantIndex.AGAI_USERID] );
		pLabelName:SetText( tApplicantList[i][ArmyGroupApplicantIndex.AGAI_NAME] );
		pLabelLevel:SetText( SafeN2S(tApplicantList[i][ArmyGroupApplicantIndex.AGAI_LEVEL]) );
		pLabelRanking:SetText( SafeN2S(tApplicantList[i][ArmyGroupApplicantIndex.AGAI_RANKING]) );
		pLabelReputation:SetText( SafeN2S(tApplicantList[i][ArmyGroupApplicantIndex.AGAI_REPUTE]) );
		local pBorder = GetImage( pListItem, ID_PIC_BORDER );
		pBorder:SetVisible(false);
	end
	return true;
end

---------------------------------------------------
-- 刷新申请者列表
function p.RefreshApplicantList( tArmyGroupApplicantList )
	if ( ArmyGroup.pLayerSolicit == nil ) then
		return false;
	end
	if ( tArmyGroupApplicantList == nil ) then
		return false;
	end
	p.pChosenListItem	= nil;
	return p.FillApplicantList( ArmyGroup.pLayerSolicit, tArmyGroupApplicantList );
end

---------------------------------------------------
-- 申请者列表项的事件响应
function p.OnUIEventApplicantListItem( uiNode, uiEventType, param )
	local tag = uiNode:GetTag();
	if ( uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK ) then
        if ( ID_BTN_TOUCH == tag ) then
        	if ( p.pChosenListItem ~= nil ) then
        		local pPicHighLight = GetImage( p.pChosenListItem, ID_PIC_BORDER );
				pPicHighLight:SetVisible(false);
        	end
        	p.pChosenListItem = uiNode:GetParent();
        	local pPicHighLight = GetImage( p.pChosenListItem, ID_PIC_BORDER );
			pPicHighLight:SetVisible(true);
        end
    end
    return true;
end

---------------------------------------------------
function p.RefreshForPermissionChange()
	if ( ArmyGroup.pLayerSolicit == nil ) then
		return false;
	end
	
	local pBtnApprove	= GetButton( ArmyGroup.pLayerSolicit, ID_BTN_APPROVE );
	local pBtnRefuse	= GetButton( ArmyGroup.pLayerSolicit, ID_BTN_REFUSE );
	local nUserID = GetPlayerId();
	local nUserArmyGroupID = MsgArmyGroup.GetUserArmyGroupID( nUserID );
	local nPosition = MsgArmyGroup.GetUserArmyGroupPosition( nUserID );
	if ( nUserArmyGroupID == ArmyGroup.nArmyGroupID and nPosition ~= ArmyGroupPositionGrade.AGPG_NONE ) then
		-- 本军团的且有职位(本军团的军团长和副军团长才可以招募成员)
		pBtnApprove:SetVisible( true );
		pBtnRefuse:SetVisible( true );
	else
		pBtnApprove:SetVisible( false );
		pBtnRefuse:SetVisible( false );
	end
end