---------------------------------------------------
--描述: 军团信息
--时间: 2012.9.18
--作者: Guosen
---------------------------------------------------

ArmyGroupInfor = {}
local p = ArmyGroupInfor;


---------------------------------------------------
-- “军团信息”界面的控件ID
local ID_LABEL_AGNAME				= 8;	-- 军团名标签ID
local ID_LABEL_LEVEL				= 9;	-- 军团等级标签ID
local ID_LABEL_RANKING				= 10;	-- 军团排名签ID
local ID_LABEL_MEMBER				= 11;	-- 军团人数标签ID
local ID_LABEL_EXP					= 12;	-- 军团经验标签ID
local ID_LABEL_NOTICE				= 21;	-- 军团公告标签ID
local ID_LIST_MEMBER				= 28;	-- 成员列表控件ID
local ID_LABEL_JOB					= 51;	-- “你的职务”标签
local ID_LABEL_POSITION				= 52;	-- 军团内职务名标签
--local ID_BTN_QUIT					= 13;	-- 退出按钮ID
--local ID_BTN_EDIT					= 22;	-- 修改公告按钮ID
--local ID_BTN_OTHERAG				= 23;	-- 其他军团按钮ID
--local ID_BTN_STATION				= 24;	-- 军团驻地按钮ID
local ID_BTN_APPLY					= 24;	-- 申请
local ID_BTN_CANCEL					= 32;	-- 取消
local ID_BTN_CLOSE					= 31;	-- 离开

---------------------------------------------------
-- 成员列表项的控件ID
local ID_PIC_MEMBER_BORDER			= 1;	-- 高亮背景，当边框
local ID_LABEL_MEMBER_NAME			= 3;	-- 成员名字
local ID_LABEL_MEMBER_LEVEL			= 4;	-- 成员等级
local ID_LABEL_MEMBER_CONTRIBUTE	= 5;	-- 成员贡献
local ID_BTN_MEMBER_TOUCH			= 6;	-- 按钮

---------------------------------------------------

---------------------------------------------------
p.pLayerInformation		= nil;	-- 本军团信息层
p.nArmyGroupID			= nil;	-- 当前界面查看的军团ID
p.tMemberList			= nil;	-- 当前界面查看的军团的成员列表
p.pChosenListItem		= nil;	-- 成员列表中选中的列表项


---------------------------------------------------
-- 显示军团主界面
function p.ShowUI( pLayer, nArmyGroupID )
p.pLayerInformation		= nil;
p.nArmyGroupID			= nil;
p.tMemberList			= nil;
p.pChosenListItem		= nil;
	if ( pLayer == nil ) then
		return false;
	end
	if ( nArmyGroupID == nil ) then
		return false;
	end
	p.nArmyGroupID = nArmyGroupID;
	p.CreateArmyGroupInformationUI( pLayer );
	MsgArmyGroup.SendMsgGetArmyGroupInformation( p.nArmyGroupID );
	MsgArmyGroup.SendMsgGetArmyGroupMemberList( p.nArmyGroupID );
	
	local pLabelPosition	= GetLabel( p.pLayerInformation, ID_LABEL_POSITION );
	local pLabelJob			= GetLabel( p.pLayerInformation, ID_LABEL_JOB );
	local nUserID			= GetPlayerId();
	local nUserArmyGroupID	= MsgArmyGroup.GetUserArmyGroupID( nUserID );
	local nPosition = MsgArmyGroup.GetUserArmyGroupPosition( nUserID );
	if ( nUserArmyGroupID ~= p.nArmyGroupID ) then
		pLabelJob:SetVisible( false );
		pLabelPosition:SetVisible( false );
	else
		local szPosition = MsgArmyGroup.GetPositionString(nPosition);
		pLabelPosition:SetText( szPosition );
	end
	-- 
	p.RefreshApplyCancelBtn();
	return true;
end

--
function p.CloseUI()
	if ( p.pLayerInformation ~= nil ) then
		p.pLayerInformation:RemoveFromParent( true );
p.pLayerInformation		= nil;
p.nArmyGroupID			= nil;
p.tMemberList			= nil;
p.pChosenListItem		= nil;
	end
end

---------------------------------------------------
-- 创建“军团信息”界面
function p.CreateArmyGroupInformationUI( pParentLayer )
	local layer = createNDUILayer();
	if not CheckP(layer) then
		LogInfo( "ArmyGroupInfor: ShowArmyGroupInformationUI failed! layer is nil" );
		return false;
	end
	layer:Init();
	--layer:SetTag( NMAINSCENECHILDTAG.ArmyGroupInfor );
	layer:SetFrameRect( RectFullScreenUILayer );
	pParentLayer:AddChildZ( layer, 2 );

	local uiLoad = createNDUILoad();
	if ( nil == uiLoad ) then
		layer:Free();
		LogInfo( "ArmyGroupInfor: ShowArmyGroupInformationUI failed! uiLoad is nil" );
		return false;
	end
	uiLoad:Load( "ArmyGroup/ArmyGroupUI_AGInfor.ini", layer, p.OnUIEventInformation, 0, 0 );
	uiLoad:Free();
	p.pLayerInformation = layer;
end

---------------------------------------------------
-- 填充军团信息
function p.FillInformation( pLayer, tArmyGroupInformation )
	if ( pLayer == nil ) then
		LogInfo( "ArmyGroupInfor: FillInformation failed! pLayer is nil" );
		return false;
	end
	if ( tArmyGroupInformation == nil ) then
		LogInfo( "ArmyGroupInfor: FillInformation failed! tArmyGroupInformation is nil" );
		return false;
	end
	
	local pLabelAGName	= GetLabel( pLayer, ID_LABEL_AGNAME );
	local pLabelLevel	= GetLabel( pLayer, ID_LABEL_LEVEL );
	local pLabelRanking	= GetLabel( pLayer, ID_LABEL_RANKING );
	local pLabelMember	= GetLabel( pLayer, ID_LABEL_MEMBER );
	local pLabelExp		= GetLabel( pLayer, ID_LABEL_EXP );
	local pLabelNotice	= GetLabel( pLayer, ID_LABEL_NOTICE );
	
	pLabelAGName:SetText( tArmyGroupInformation.szAGName );
	pLabelLevel:SetText( SafeN2S(tArmyGroupInformation.nLevel) );
	pLabelRanking:SetText( SafeN2S(tArmyGroupInformation.nRanking) );
	pLabelMember:SetText( tArmyGroupInformation.nMember.."/"..tArmyGroupInformation.nMemberLimit );
	pLabelExp:SetText( tArmyGroupInformation.nExperience.."/"..tArmyGroupInformation.nExpNextLevel );
	pLabelNotice:SetText( tArmyGroupInformation.szNotice );
	
	return true;
end

---------------------------------------------------
-- 刷新军团信息
function p.RefreshInformation( tArmyGroupInformation )
	if ( p.pLayerInformation == nil or tArmyGroupInformation == nil ) then
		LogInfo( "ArmyGroupInfor: RefreshInformation failed!  is nil" );
		return false;
	end
	if ( tArmyGroupInformation == nil ) then
		LogInfo( "ArmyGroupInfor: RefreshInformation failed! tArmyGroupInformation is nil" );
		return false;
	end
	
	if ( tArmyGroupInformation.nArmyGroupID == p.nArmyGroupID ) then
		return p.FillInformation( p.pLayerInformation, tArmyGroupInformation );
	end
end

---------------------------------------------------
-- 填充成员列表
function p.FillMemberList( pLayer, tArmyGroupMemberList )
	if ( pLayer == nil ) then
		LogInfo( "ArmyGroupInfor: FillMemberList() failed! pLayer is nil" );
		return false;
	end
	
	local layer = createNDUILayer();
	layer:Init();
	local uiLoad=createNDUILoad();
	uiLoad:Load( "ArmyGroup/ArmyGroupUI_MemberListItem0.ini", layer, nil, 0, 0 );
	uiLoad:Free();
	local pBorder = GetImage( layer, ID_PIC_MEMBER_BORDER );
	local tSize = pBorder:GetFrameRect().size;
	layer:Free();
    
	-- 获得滚屏容器
	local pScrollViewContainer = GetScrollViewContainer( pLayer, ID_LIST_MEMBER );
	if ( nil == pScrollViewContainer ) then
		LogInfo( "ArmyGroupInfor: FillMemberList() failed! pScrollViewContainer is nil" );
		return false;
	end
    pScrollViewContainer:EnableScrollBar(true);
	pScrollViewContainer:SetStyle( UIScrollStyle.Verical );
	pScrollViewContainer:SetViewSize( tSize );
	pScrollViewContainer:RemoveAllView();
	
	if ( tArmyGroupMemberList == nil ) then
		LogInfo( "ArmyGroupInfor: FillMemberList() failed! tArmyGroupMemberList is nil" );
		return false;
	end
	
	local nMemberAmount = table.getn( tArmyGroupMemberList );
	if ( nMemberAmount == 0 ) then
		LogInfo( "ArmyGroupInfor: FillMemberList() failed! nMemberAmount is 0" );
		return false;
	end
	local nUserID	= GetPlayerId();
	for i = 1, nMemberAmount do
		local pListItem = createUIScrollView();
	
		if not CheckP( pListItem ) then
			LogInfo( "ArmyGroupInfor: pListItem == nil" );
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
			LogInfo( "ArmyGroupInfor: FillMemberList failed! uiLoad is nil" );
			return false;
		end
		uiLoad:Load( "ArmyGroup/ArmyGroupUI_MemberListItem0.ini", pListItem, p.OnUIEventMemberListItem, 0, 0 );
		uiLoad:Free();
		
		local pLabelName		= GetLabel( pListItem, ID_LABEL_MEMBER_NAME );
		local pLabelLevel		= GetLabel( pListItem, ID_LABEL_MEMBER_LEVEL );
		local pLabelContribute	= GetLabel( pListItem, ID_LABEL_MEMBER_CONTRIBUTE );
		pLabelName:SetText( tArmyGroupMemberList[i][ArmyGroupMemberIndex.AGMI_NAME] );
		pLabelLevel:SetText( SafeN2S(tArmyGroupMemberList[i][ArmyGroupMemberIndex.AGMI_LEVEL]) );
		pLabelContribute:SetText( SafeN2S(tArmyGroupMemberList[i][ArmyGroupMemberIndex.AGMI_CONTTOTAL]+tArmyGroupMemberList[i][ArmyGroupMemberIndex.AGMI_REPUTTOTAL]) );
		local pBorder = GetImage( pListItem, ID_PIC_MEMBER_BORDER );
		pBorder:SetVisible(false);
		if ( nUserID == tArmyGroupMemberList[i][ArmyGroupMemberIndex.AGMI_USERID] ) then
			pLabelName:SetFontColor( MsgArmyGroup.COLOR_YELLOW );
			pLabelLevel:SetFontColor( MsgArmyGroup.COLOR_YELLOW );
			pLabelContribute:SetFontColor( MsgArmyGroup.COLOR_YELLOW );
		elseif ( tArmyGroupMemberList[i][ArmyGroupMemberIndex.AGMI_ISONLINE] == 0 ) then
			pLabelName:SetFontColor( MsgArmyGroup.COLOR_GRAY );
			pLabelLevel:SetFontColor( MsgArmyGroup.COLOR_GRAY );
			pLabelContribute:SetFontColor( MsgArmyGroup.COLOR_GRAY );
		end
	end
	return true;
end

---------------------------------------------------
-- 刷新成员列表
function p.RefreshMemberlist( tArmyGroupMemberList )
	if ( p.pLayerInformation == nil ) then
		LogInfo( "ArmyGroupInfor: RefreshMemberlist failed! p.pLayerInformation is nil" );
		return false;
	end
	if ( tArmyGroupMemberList == nil ) then
		LogInfo( "ArmyGroupInfor: RefreshMemberlist failed! tArmyGroupMemberList is nil" );
		return false;
	end
	
	if ( p.pChosenListItem ~= nil ) then
		p.pChosenListItem = nil;
	end
	p.tMemberList = tArmyGroupMemberList;
	return p.FillMemberList( p.pLayerInformation, tArmyGroupMemberList );
end


---------------------------------------------------
-- “军团信息”界面的成员列表项的事件响应
function p.OnUIEventMemberListItem( uiNode, uiEventType, param )
	local tag = uiNode:GetTag();
	if ( uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK ) then
        if ( ID_BTN_MEMBER_TOUCH == tag ) then
        	if ( p.pChosenListItem ~= nil ) then
        		local pPicHighLight = GetImage( p.pChosenListItem, ID_PIC_MEMBER_BORDER );
				pPicHighLight:SetVisible(false);
        	end
        	p.pChosenListItem = uiNode:GetParent();
        	local pPicHighLight = GetImage( p.pChosenListItem, ID_PIC_MEMBER_BORDER );
			pPicHighLight:SetVisible(true);
			--
			if ( ( p.tMemberList ~= nil ) and ( p.pLayerInformation ~= nil ) ) then
				local nIndex		= uiNode:GetParent():GetTag();
				local tMember		= p.tMemberList[nIndex];
				HadleMember.CreateHandleMemberDlg( p.pLayerInformation:GetParent(), p.nArmyGroupID, tMember );
			end
        end
    end
    return true;
end


---------------------------------------------------
-- “军团信息”界面的事件响应
function p.OnUIEventInformation( uiNode, uiEventType, param )
	local tag = uiNode:GetTag();
	if ( uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK ) then
        if ( ID_BTN_QUIT == tag ) then
		elseif ( ID_BTN_CANCEL == tag ) then
			-- 发送取消请求
			if ( p.nArmyGroupID ~= nil ) then
				MsgArmyGroup.SendMsgCancelApply( p.nArmyGroupID );
			end
		elseif ( ID_BTN_APPLY == tag ) then
			-- 发送申请请求
			if ( p.nArmyGroupID ~= nil ) then
				MsgArmyGroup.SendMsgJoinArmyGroupApplication( p.nArmyGroupID );
			end
		elseif ( ID_BTN_CLOSE == tag ) then
			p.CloseUI();
        end
    end
    return true;
end

---------------------------------------------------
-- 刷新(申请按钮、取消按钮)
function p.RefreshApplyCancelBtn()
	if ( p.pLayerInformation == nil ) then
		return;
	end
	local pBtnApply		= GetButton( p.pLayerInformation, ID_BTN_APPLY );
	local pBtnCancel	= GetButton( p.pLayerInformation, ID_BTN_CANCEL );
	
	local nUserID			= GetPlayerId();
	local nAGID				= MsgArmyGroup.GetUserArmyGroupID( nUserID );
	local tApplyList		= MsgArmyGroup.GetArmyGroupApplyList( nUserID );
	local nApplyAmount		= table.getn( tApplyList );
	local tArmyGroupList	= MsgArmyGroup.GetArmyGroupList();
	if ( nAGID == nil ) then
		if ( nApplyAmount > 0 ) then
			if ( nApplyAmount >= MsgArmyGroup.ArmyGroupApplyLimit ) then-- >5
				pBtnApply:SetVisible( false );
			else
				pBtnApply:SetVisible( true );
			end
			pBtnCancel:SetVisible( false );
			for i, v in ipairs(tApplyList) do
				if ( v == p.nArmyGroupID ) then
					pBtnCancel:SetVisible( true );
					pBtnApply:SetVisible( false );
					break;
				end
			end
		else
			pBtnCancel:SetVisible( false );
			pBtnApply:SetVisible( true );
		end 
	else
		pBtnCancel:SetVisible( false );
		pBtnApply:SetVisible( false );
	end
end
