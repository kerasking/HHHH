---------------------------------------------------
--描述: 军团成员界面
--时间: 2012.9.24
--作者: Guosen
---------------------------------------------------

Member = {}
local p = Member;

---------------------------------------------------

local ID_LIST_CONTAINER				= 10;	-- 申请人列表容器控件ID

---------------------------------------------------
local ID_PIC_BORDER					= 1;	-- 列表项边框
local ID_LABEL_NAME					= 31;	-- 名字
local ID_LABEL_LEVEL				= 32;	-- 等级
local ID_LABEL_POSITION				= 33;	-- 职位
local ID_LABEL_RANKING				= 34;	-- 排名
local ID_LABEL_REPUTTODAY			= 35;	-- 今日声望
local ID_LABEL_REPUTTOTAL			= 36;	-- 总声望
local ID_LABEL_LASTONLINE			= 20;	-- 最后在线
local ID_BTN_TOUCH					= 16;	-- 按钮

---------------------------------------------------
p.pChosenListItem		= nil;

---------------------------------------------------
--
function p.InitializeMemberUI( pLayer )
p.pChosenListItem		= nil;
	LogInfo( "Member: InitializeMemberUI" );
	local uiLoad = createNDUILoad();
	if ( nil == uiLoad ) then
		pLayer:Free();
		LogInfo( "Member: InitializeMemberUI failed! uiLoad is nil" );
		return false;
	end
	uiLoad:Load( "ArmyGroup/ArmyGroupUI_Member.ini", pLayer, nil, 0, 0 );
	uiLoad:Free();
	--local nArmyGroupID = ArmyGroup.nArmyGroupID;
	--local tArmyGroupMemberList = MsgArmyGroup.GetArmyGroupMemberList( nArmyGroupID );
	--p.FillMemberList( pLayer, tArmyGroupMemberList );
	return true;
end

---------------------------------------------------
-- 填充成员列表
function p.FillMemberList( pLayer, tArmyGroupMemberList )
	if ( pLayer == nil ) then
		LogInfo( "Member: FillMemberList() failed! pLayer is nil" );
		return false;
	end
	local layer = createNDUILayer();
	layer:Init();
	local uiLoad=createNDUILoad();
	uiLoad:Load( "ArmyGroup/ArmyGroupUI_MemberListItem1.ini", layer, nil, 0, 0 );
	uiLoad:Free();
	local pBorder = GetImage( layer, ID_PIC_BORDER );
	local tSize = pBorder:GetFrameRect().size;
	layer:Free();
    
	-- 获得滚屏容器
	local pScrollViewContainer = GetScrollViewContainer( pLayer, ID_LIST_CONTAINER );
	if ( nil == pScrollViewContainer ) then
		LogInfo( "Member: FillMemberList() failed! pScrollViewContainer is nil" );
		return false;
	end
    pScrollViewContainer:EnableScrollBar(true);
	pScrollViewContainer:SetStyle( UIScrollStyle.Verical );
	pScrollViewContainer:SetViewSize( tSize );
	pScrollViewContainer:RemoveAllView();
	
	if ( tArmyGroupMemberList == nil ) then
		LogInfo( "Member: FillMemberList() failed! tArmyGroupMemberList is nil" );
		return false;
	end
	
	local nMemberAmount = table.getn( tArmyGroupMemberList );
	if ( nMemberAmount == 0 ) then
		LogInfo( "Member: FillMemberList() failed! nMemberAmount is 0" );
		return false;
	end
	local nUserID	= GetPlayerId();
	for i = 1, nMemberAmount do
		local pListItem = createUIScrollView();
	
		if not CheckP( pListItem ) then
			LogInfo( "ArmyGroup: pListItem == nil" );
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
			LogInfo( "Member: FillListContainer failed! uiLoad is nil" );
			return false;
		end
		uiLoad:Load( "ArmyGroup/ArmyGroupUI_MemberListItem1.ini", pListItem, p.OnUIEventMemberListItem, 0, 0 );
		uiLoad:Free();
		
		local pLabelName		= GetLabel( pListItem, ID_LABEL_NAME );
		local pLabelLevel		= GetLabel( pListItem, ID_LABEL_LEVEL );
		local pLabelPosition	= GetLabel( pListItem, ID_LABEL_POSITION );
		local pLabelRanking		= GetLabel( pListItem, ID_LABEL_RANKING );
		local pLabelReputtoday	= GetLabel( pListItem, ID_LABEL_REPUTTODAY );
		local pLabelReputtotal	= GetLabel( pListItem, ID_LABEL_REPUTTOTAL );
		local pLabelLastOnline	= GetLabel( pListItem, ID_LABEL_LASTONLINE );
		pLabelName:SetText( tArmyGroupMemberList[i][ArmyGroupMemberIndex.AGMI_NAME] );
		pLabelLevel:SetText( SafeN2S(tArmyGroupMemberList[i][ArmyGroupMemberIndex.AGMI_LEVEL]) );
		pLabelPosition:SetText( MsgArmyGroup.GetPositionString(tArmyGroupMemberList[i][ArmyGroupMemberIndex.AGMI_POSITION]) );
		pLabelRanking:SetText( SafeN2S(tArmyGroupMemberList[i][ArmyGroupMemberIndex.AGMI_RANKING]) );
		pLabelReputtoday:SetText( SafeN2S(tArmyGroupMemberList[i][ArmyGroupMemberIndex.AGMI_REPUTTODAY]) );
		pLabelReputtotal:SetText( SafeN2S(tArmyGroupMemberList[i][ArmyGroupMemberIndex.AGMI_REPUTTOTAL]) );
		if ( tArmyGroupMemberList[i][ArmyGroupMemberIndex.AGMI_ISONLINE] == 0 ) then
			local nTime = GetCurrentTime() - tArmyGroupMemberList[i][ArmyGroupMemberIndex.AGMI_LASTLOGOUT];
			if ( nTime < 0 ) then
				nTime = 0;
			end
			local szLogoutTime	= MsgArmyGroup.GetLogoutString( nTime );
			pLabelLastOnline:SetText( szLogoutTime );
		else
			pLabelLastOnline:SetText( MsgArmyGroup.GetIsOnlineString(tArmyGroupMemberList[i][ArmyGroupMemberIndex.AGMI_ISONLINE]) );
		end
		--LogInfo( "Member:  %s, nLogoutTime:%d, nCurrentTime:%d, nGreenwichTime:%d",tArmyGroupMemberList[i][ArmyGroupMemberIndex.AGMI_NAME],tArmyGroupMemberList[i][ArmyGroupMemberIndex.AGMI_LASTLOGOUT], GetCurrentTime(), os.time() );
		local pBorder = GetImage( pListItem, ID_PIC_BORDER );
		pBorder:SetVisible(false);
		if ( nUserID == tArmyGroupMemberList[i][ArmyGroupMemberIndex.AGMI_USERID] ) then
			pLabelName:SetFontColor( MsgArmyGroup.COLOR_YELLOW );
			pLabelLevel:SetFontColor( MsgArmyGroup.COLOR_YELLOW );
			pLabelPosition:SetFontColor( MsgArmyGroup.COLOR_YELLOW );
			pLabelRanking:SetFontColor( MsgArmyGroup.COLOR_YELLOW );
			pLabelPosition:SetFontColor( MsgArmyGroup.COLOR_YELLOW );
			pLabelReputtoday:SetFontColor( MsgArmyGroup.COLOR_YELLOW );
			pLabelReputtotal:SetFontColor( MsgArmyGroup.COLOR_YELLOW );
			pLabelLastOnline:SetFontColor( MsgArmyGroup.COLOR_YELLOW );
		elseif ( tArmyGroupMemberList[i][ArmyGroupMemberIndex.AGMI_ISONLINE] == 0 ) then
			pLabelName:SetFontColor( MsgArmyGroup.COLOR_GRAY );
			pLabelLevel:SetFontColor( MsgArmyGroup.COLOR_GRAY );
			pLabelPosition:SetFontColor( MsgArmyGroup.COLOR_GRAY );
			pLabelRanking:SetFontColor( MsgArmyGroup.COLOR_GRAY );
			pLabelPosition:SetFontColor( MsgArmyGroup.COLOR_GRAY );
			pLabelReputtoday:SetFontColor( MsgArmyGroup.COLOR_GRAY );
			pLabelReputtotal:SetFontColor( MsgArmyGroup.COLOR_GRAY );
			pLabelLastOnline:SetFontColor( MsgArmyGroup.COLOR_GRAY );
		end
	end
	return true;
end

---------------------------------------------------
function p.RefreshMemberlist( tArmyGroupMemberList )
	if ( p.pChosenListItem ~= nil ) then
		p.pChosenListItem = nil;
	end
	p.FillMemberList( ArmyGroup.pLayerMember, tArmyGroupMemberList );
end

---------------------------------------------------
-- 成员列表项的事件响应
function p.OnUIEventMemberListItem( uiNode, uiEventType, param )
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
			--
			local nIndex		= uiNode:GetParent():GetTag();
			local tMemberList	= MsgArmyGroup.GetArmyGroupMemberList( ArmyGroup.nArmyGroupID );
			local tMember		= tMemberList[nIndex];
			HadleMember.CreateHandleMemberDlg( ArmyGroup.pLayerMainUI, ArmyGroup.nArmyGroupID, tMember );
        end
    end
    return true;
end
