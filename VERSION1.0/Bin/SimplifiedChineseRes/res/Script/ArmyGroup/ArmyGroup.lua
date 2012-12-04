---------------------------------------------------
--描述: 军团
--时间: 2012.9.18
--作者: Guosen
---------------------------------------------------
-- 进入军团界面接口：		ArmyGroup.Entry()
---------------------------------------------------

ArmyGroup = {}
local p = ArmyGroup;


---------------------------------------------------
-- 菜单栏的控件ID
local ID_PIC_BORDER					= 1;	-- 菜单边框
local ID_BTN_CLOSE					= 3;	-- X
local ID_BTN_INFOR					= 6;	-- 本军团信息
local ID_BTN_MEMBER					= 7;	-- 本军团成员
local ID_BTN_SOLICIT				= 8;	-- 为本军团招募成员-入申请者审批
local ID_BTN_AG_LIST				= 9;	-- 军团列表

---------------------------------------------------
-- “军团信息”界面的控件ID
local ID_LABEL_AGNAME				= 8;	-- 军团名标签ID
local ID_LABEL_LEVEL				= 9;	-- 军团等级标签ID
local ID_LABEL_RANKING				= 10;	-- 军团排名签ID
local ID_LABEL_MEMBER				= 11;	-- 军团人数标签ID
local ID_LABEL_EXP					= 12;	-- 军团经验标签ID
local ID_LABEL_NOTICE				= 21;	-- 军团公告标签ID
local ID_LIST_MEMBER				= 28;	-- 成员列表控件ID
local ID_BTN_QUIT					= 13;	-- 退出按钮ID
local ID_BTN_EDIT					= 22;	-- 修改公告按钮ID
local ID_BTN_STATION				= 24;	-- 军团驻地按钮ID
local ID_LABEL_JOB					= 51;	-- “你的职务”标签
local ID_LABEL_POSITION				= 52;	-- 军团内职务名标签

---------------------------------------------------
-- 成员列表项的控件ID
local ID_PIC_MEMBER_BORDER			= 1;	-- 高亮背景，当边框
local ID_LABEL_MEMBER_NAME			= 3;	-- 成员名字
local ID_LABEL_MEMBER_LEVEL			= 4;	-- 成员等级
local ID_LABEL_MEMBER_CONTRIBUTE	= 5;	-- 成员贡献
local ID_BTN_MEMBER_TOUCH			= 6;	-- 按钮

---------------------------------------------------
-- 编辑公告窗口的控件ID
local ID_EDITNOTICEEDLG_BTN_CONFIRM			= 101;	-- 确定
local ID_EDITNOTICEEDLG_BTN_CANCEL			= 102;	-- 取消
local ID_EDITNOTICEEDLG_BTN_EDIT			= 104;	-- 编辑框

---------------------------------------------------
local AG_NOTICE_CHA_LIMIT				= 60;	-- 公告文字的字数限制

local SZ_QUIT_ER						= "身为军团长，你的军团还有其他成员，不可擅自退出……";
local SZ_QUIT_00						= "决定退出该军团？退出军团，所有的贡献信息都将归零……";

---------------------------------------------------
p.pLayerMainUI			= nil;
p.pLayerInformation		= nil;	-- 本军团信息层
p.pLayerMember			= nil;	-- 本军团成员层
p.pLayerSolicit			= nil;	-- 招募层
p.pLayerAGList			= nil;	-- 军团列表层
p.pBtnInformation		= nil;
p.pBtnMember			= nil;
p.pBtnSolicit			= nil;
p.pBtnAGList			= nil;
p.pChosenListItem		= nil;
p.nArmyGroupID			= nil;	-- 当前界面查看的军团ID
p.pLayerEditNotice		= nil;

---------------------------------------------------
-- 进入
function p.Entry()
	local nUserID = GetPlayerId();
	local nArmyGroupID = MsgArmyGroup.GetUserArmyGroupID( nUserID );
	if ( nArmyGroupID ~= nil ) then
		p.ShowArmyGroupMainUI( nArmyGroupID );
	else
		CreateOrJoinArmyGroup.ShowUI();
	end
end



---------------------------------------------------
-- 显示军团主界面
function p.ShowArmyGroupMainUI( nArmyGroupID )
p.pLayerMainUI			= nil;
p.pLayerInformation		= nil;
p.pLayerMember			= nil;
p.pLayerSolicit			= nil;
p.pLayerAGList			= nil;
p.pBtnInformation		= nil;
p.pBtnMember			= nil;
p.pBtnSolicit			= nil;
p.pBtnAGList			= nil;
p.pChosenListItem		= nil;
p.nArmyGroupID			= nil;
p.pLayerEditNotice		= nil;
	if ( nArmyGroupID == nil ) then
		return false;
	end
	--LogInfo( "ArmyGroup: LoadUI()" );
	local scene = GetSMGameScene();
	if not CheckP(scene) then
	LogInfo( "ArmyGroup: ShowArmyGroupMainUI failed! scene is nil" );
		return false;
	end
	
	local layer = createNDUILayer();
	if not CheckP(layer) then
		LogInfo( "ArmyGroup: ShowArmyGroupMainUI failed! layer is nil" );
		return false;
	end
	
	layer:SetPopupDlgFlag( true );
	layer:Init();
	layer:SetTag( NMAINSCENECHILDTAG.ArmyGroup );
	layer:SetFrameRect( RectFullScreenUILayer );
	scene:AddChildZ( layer, 1 );
	p.pLayerMainUI = layer;

	local uiLoad = createNDUILoad();
	if ( nil == uiLoad ) then
		layer:Free();
		LogInfo( "ArmyGroup: ShowArmyGroupMainUI failed! uiLoad is nil" );
		return false;
	end
	uiLoad:Load( "ArmyGroup/ArmyGroupUI_Main.ini", layer, p.OnUIEventMain, 0, 0 );
	uiLoad:Free();
	
	p.nArmyGroupID = nArmyGroupID;
	local nUserID = GetPlayerId();
	local nUserArmyGroupID = MsgArmyGroup.GetUserArmyGroupID( nUserID );
	local nPosition = MsgArmyGroup.GetUserArmyGroupPosition( nUserID );
	p.CreateArmyGroupInformationUI( layer );
	p.CreateArmyGroupMemberUI( layer );
	p.CreateSolicitMemberUI( layer );
	p.CreateArmyGroupList( layer );
	p.CreateArmyGroupMenu( layer );
	
	--
	p.pBtnInformation:TabSel(true);
	p.pBtnMember:TabSel(false);
	p.pBtnSolicit:TabSel(false);
	p.pLayerInformation:SetVisible(true);
	p.pLayerMember:SetVisible(false);
	p.pLayerSolicit:SetVisible(false);
	p.pLayerAGList:SetVisible(false);
	
	MsgArmyGroup.SendMsgGetArmyGroupInformation( p.nArmyGroupID );
	MsgArmyGroup.SendMsgGetArmyGroupMemberList( p.nArmyGroupID );
	MsgArmyGroup.SendMsgGetArmyGroupApplicantList( p.nArmyGroupID );
end

--
function p.CloseUI()
	local scene = GetSMGameScene();
	if ( scene ~= nil ) then
		scene:RemoveChildByTag( NMAINSCENECHILDTAG.ArmyGroup, true );--p.pLayerMainUI:RemoveFromParent( true );
p.pLayerMainUI			= nil;
p.pLayerInformation		= nil;
p.pLayerMember			= nil;
p.pLayerSolicit			= nil;
p.pLayerAGList			= nil;
p.pBtnInformation		= nil;
p.pBtnMember			= nil;
p.pBtnSolicit			= nil;
p.pBtnAGList			= nil;
p.pChosenListItem		= nil;
p.nArmyGroupID			= nil;
p.pLayerEditNotice		= nil;
	end
end

---------------------------------------------------
-- 创建军团菜单
function p.CreateArmyGroupMenu( pParentLayer )
	local layer = createNDUILayer();
	if not CheckP(layer) then
		LogInfo( "ArmyGroup: CreateArmyGroupMenu failed! layer is nil" );
		return false;
	end
	layer:Init();
	--layer:SetTag( NMAINSCENECHILDTAG.ArmyGroup );
	--layer:SetFrameRect( CGRectMake(0,0,960,76) );--( RectFullScreenUILayer );
	pParentLayer:AddChildZ( layer, 2 );

	local uiLoad = createNDUILoad();
	if ( nil == uiLoad ) then
		layer:Free();
		LogInfo( "ArmyGroup: CreateArmyGroupMenu failed! uiLoad is nil" );
		return false;
	end
	uiLoad:Load( "ArmyGroup/ArmyGroupUI_Menu.ini", layer, p.OnUIEventMain, 0, 0 );
	uiLoad:Free();
	
	local pNode = GetUiNode( layer, ID_PIC_BORDER );
	local tRect	= pNode:GetFrameRect();
	layer:SetFrameRect( tRect );
	
	p.pBtnInformation		= GetButton( layer, ID_BTN_INFOR );
	p.pBtnMember			= GetButton( layer, ID_BTN_MEMBER );
	p.pBtnSolicit			= GetButton( layer, ID_BTN_SOLICIT );
	p.pBtnAGList			= GetButton( layer, ID_BTN_AG_LIST );
end

---------------------------------------------------
-- 军团界面的事件响应
function p.OnUIEventMain( uiNode, uiEventType, param )
	local tag = uiNode:GetTag();
	if ( uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK ) then
        if ( ID_BTN_CLOSE == tag ) then
			p.CloseUI();
		elseif ( ID_BTN_INFOR == tag ) then
			p.pBtnInformation:TabSel(true);
			p.pBtnMember:TabSel(false);
			p.pBtnSolicit:TabSel(false);
			p.pBtnAGList:TabSel(false);
			p.pLayerInformation:SetVisible(true);
			p.pLayerMember:SetVisible(false);
			p.pLayerSolicit:SetVisible(false);
			ArmyGroupList.CloseUI()
		elseif ( ID_BTN_MEMBER == tag ) then
			p.pBtnInformation:TabSel(false);
			p.pBtnMember:TabSel(true);
			p.pBtnSolicit:TabSel(false);
			p.pBtnAGList:TabSel(false);
			p.pLayerInformation:SetVisible(false);
			p.pLayerMember:SetVisible(true);
			p.pLayerSolicit:SetVisible(false);
			ArmyGroupList.CloseUI()
		elseif ( ID_BTN_SOLICIT == tag ) then
			p.pBtnInformation:TabSel(false);
			p.pBtnMember:TabSel(false);
			p.pBtnSolicit:TabSel(true);
			p.pBtnAGList:TabSel(false);
			p.pLayerInformation:SetVisible(false);
			p.pLayerMember:SetVisible(false);
			p.pLayerSolicit:SetVisible(true);
			ArmyGroupList.CloseUI()
		elseif ( ID_BTN_AG_LIST == tag ) then
			p.pBtnInformation:TabSel(false);
			p.pBtnMember:TabSel(false);
			p.pBtnSolicit:TabSel(false);
			p.pBtnAGList:TabSel(true);
			p.pLayerInformation:SetVisible(false);
			p.pLayerMember:SetVisible(false);
			p.pLayerSolicit:SetVisible(false);
			ArmyGroupList.ShowUI()
        end
    end
    return true;
end



---------------------------------------------------
-- 创建“军团信息”界面
function p.CreateArmyGroupInformationUI( pParentLayer )
	local layer = createNDUILayer();
	if not CheckP(layer) then
		LogInfo( "ArmyGroup: ShowArmyGroupInformationUI failed! layer is nil" );
		return false;
	end
	layer:Init();
	--layer:SetTag( NMAINSCENECHILDTAG.ArmyGroup );
	layer:SetFrameRect( RectFullScreenUILayer );
	pParentLayer:AddChildZ( layer, 1 );

	local uiLoad = createNDUILoad();
	if ( nil == uiLoad ) then
		layer:Free();
		LogInfo( "ArmyGroup: ShowArmyGroupInformationUI failed! uiLoad is nil" );
		return false;
	end
	uiLoad:Load( "ArmyGroup/ArmyGroupUI_Information.ini", layer, p.OnUIEventInformation, 0, 0 );
	uiLoad:Free();
	p.pLayerInformation = layer;
	-- 隐藏
	local pBtnStation = GetButton( layer, ID_BTN_STATION );
	if ( pBtnStation ~= nil ) then
		pBtnStation:SetVisible( false );
	end
	local pBtnQuit	= GetButton( layer, ID_BTN_QUIT );
	local pBtnEdit	= GetButton( layer, ID_BTN_EDIT );
	local pLabelJob	= GetLabel( layer, ID_LABEL_JOB );
	local pLabelPosition = GetLabel( layer, ID_LABEL_POSITION );
	local nUserID	= GetPlayerId();
	local nUserArmyGroupID = MsgArmyGroup.GetUserArmyGroupID( nUserID );
	local nPosition = MsgArmyGroup.GetUserArmyGroupPosition( nUserID );
	if ( pBtnQuit ~= nil and nUserArmyGroupID ~= p.nArmyGroupID ) then
		pBtnQuit:SetVisible( false );
	end
	if ( pBtnEdit ~= nil and ( nUserArmyGroupID ~= p.nArmyGroupID or nPosition == ArmyGroupPositionGrade.AGPG_NONE  ) ) then
		pBtnEdit:SetVisible( false );
	end
	
	if ( nUserArmyGroupID ~= p.nArmyGroupID ) then
		pLabelJob:SetVisible( false );
		pLabelJob:SetVisible( false );
	else
		local szPosition = MsgArmyGroup.GetPositionString( nPosition );
		pLabelPosition:SetText( szPosition );
	end
	
	--local tArmyGroupInformation = MsgArmyGroup.GetArmyGroupInformation( p.nArmyGroupID );
	--p.FillInformation( layer, tArmyGroupInformation );
	--local tArmyGroupMemberList = MsgArmyGroup.GetArmyGroupMemberList( p.nArmyGroupID );
	--p.FillMemberList( layer, tArmyGroupMemberList )
end

---------------------------------------------------
-- 填充军团信息
function p.FillInformation( pLayer, tArmyGroupInformation )
	if ( pLayer == nil ) then
		LogInfo( "ArmyGroup: FillInformation failed! pLayer is nil" );
		return false;
	end
	if ( tArmyGroupInformation == nil ) then
		LogInfo( "ArmyGroup: FillInformation failed! tArmyGroupInformation is nil" );
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
	if ( tArmyGroupInformation == nil ) then
		LogInfo( "ArmyGroup: RefreshInformation failed! tArmyGroupInformation is nil" );
		return false;
	end
	if ( p.pLayerInformation == nil ) then
		LogInfo( "ArmyGroup: RefreshInformation failed!  is nil" );
		return false;
	end
	
	if ( tArmyGroupInformation.nArmyGroupID == p.nArmyGroupID ) then
		p.FillInformation( p.pLayerInformation, tArmyGroupInformation );
	end
	if ( p.pLayerAGList:IsVisibled() ) then
		return ArmyGroupInfor.RefreshInformation( tArmyGroupInformation );
	end
end

---------------------------------------------------
-- 填充成员列表
function p.FillMemberList( pLayer, tArmyGroupMemberList )
	if ( pLayer == nil ) then
		LogInfo( "ArmyGroup: FillMemberList() failed! pLayer is nil" );
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
		LogInfo( "ArmyGroup: FillMemberList() failed! pScrollViewContainer is nil" );
		return false;
	end
    pScrollViewContainer:EnableScrollBar(true);
	pScrollViewContainer:SetStyle( UIScrollStyle.Verical );
	pScrollViewContainer:SetViewSize( tSize );
	pScrollViewContainer:RemoveAllView();
	
	if ( tArmyGroupMemberList == nil ) then
		LogInfo( "ArmyGroup: FillMemberList() failed! tArmyGroupMemberList is nil" );
		return false;
	end
	
	local nMemberAmount = table.getn( tArmyGroupMemberList );
	if ( nMemberAmount == 0 ) then
		LogInfo( "ArmyGroup: FillMemberList() failed! nMemberAmount is 0" );
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
			LogInfo( "ArmyGroup: FillMemberList failed! uiLoad is nil" );
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
function p.RefreshMemberlist( tArmyGroupMemberList, nArmyGroupID )
	if ( p.pLayerInformation == nil ) then
		LogInfo( "ArmyGroup: RefreshMemberlist failed! p.pLayerInformation is nil" );
		return false;
	end
	if ( tArmyGroupMemberList == nil ) then
		LogInfo( "ArmyGroup: RefreshMemberlist failed! tArmyGroupMemberList is nil" );
		return false;
	end
	
	if ( p.pChosenListItem ~= nil ) then
		p.pChosenListItem = nil;
	end
	
	if ( nArmyGroupID == p.nArmyGroupID ) then
		Member.RefreshMemberlist( tArmyGroupMemberList );
		p.FillMemberList( p.pLayerInformation, tArmyGroupMemberList );
	end
	if ( p.pLayerAGList:IsVisibled() ) then
		return ArmyGroupInfor.RefreshMemberlist( tArmyGroupMemberList );
	end
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
			local nIndex		= uiNode:GetParent():GetTag();
			local tMemberList	= MsgArmyGroup.GetArmyGroupMemberList( p.nArmyGroupID );
			local tMember		= tMemberList[nIndex];
			HadleMember.CreateHandleMemberDlg( p.pLayerMainUI, p.nArmyGroupID, tMember );
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
        	local nUserID	= GetPlayerId();
			local nPosition	= MsgArmyGroup.GetUserArmyGroupPosition( nUserID );
			if ( nPosition == ArmyGroupPositionGrade.AGPG_LEGATUS ) then
				local nAGID 	= MsgArmyGroup.GetUserArmyGroupID( nUserID );
				local tAGInfor	= MsgArmyGroup.GetArmyGroupInformation( nAGID );
				if ( tAGInfor.nMember > 1 ) then
					CommonDlgNew.ShowYesDlg( SZ_QUIT_ER, nil, nil, 3 );
					return true;
				end
			end
			CommonDlgNew.ShowYesOrNoDlg( SZ_QUIT_00, p.CallBack_Quit );
		elseif ( ID_BTN_EDIT == tag ) then
			local pLayer = uiNode:GetParent():GetParent();
			p.CreateEditNoticeDlg( pLayer );
		elseif ( ID_BTN_STATION == tag ) then
        end
    end
    return true;
end

---------------------------------------------------
--
function p.CallBack_Quit(nEvent, param )
	if ( CommonDlgNew.BtnOk == nEvent ) then
		-- 发送退出军团消息
		MsgArmyGroup.SendMsgQuit();
	end
end

---------------------------------------------------
-- 创建“军团成员”界面
function p.CreateArmyGroupMemberUI( pParentLayer )
	local layer = createNDUILayer();
	if not CheckP(layer) then
		LogInfo( "ArmyGroup: ShowArmyGroupMemberUI failed! layer is nil" );
		return false;
	end
	
	layer:SetPopupDlgFlag( true );
	layer:Init();
	--layer:SetTag( NMAINSCENECHILDTAG.ArmyGroup );
	layer:SetFrameRect( RectFullScreenUILayer );
	pParentLayer:AddChildZ( layer, 1 );
	Member.InitializeMemberUI( layer );
	p.pLayerMember = layer;
end

---------------------------------------------------
-- 创建“招募成员”界面
function p.CreateSolicitMemberUI( pParentLayer )
	local layer = createNDUILayer();
	if not CheckP(layer) then
		LogInfo( "ArmyGroup: ShowArmyGroupMemberUI failed! layer is nil" );
		return false;
	end
	layer:Init();
	--layer:SetTag( NMAINSCENECHILDTAG.ArmyGroup );
	layer:SetFrameRect( RectFullScreenUILayer );
	pParentLayer:AddChildZ( layer, 1 );
	Solicit.InitializeSolicitUI( layer );
	p.pLayerSolicit = layer;
end

---------------------------------------------------
-- 创建“军团列表”界面
function p.CreateArmyGroupList( pParentLayer )
	local layer = createNDUILayer();
	if not CheckP(layer) then
		LogInfo( "ArmyGroup: ShowArmyGroupMemberUI failed! layer is nil" );
		return false;
	end
	layer:Init();
	--layer:SetTag( NMAINSCENECHILDTAG.ArmyGroup );
	layer:SetFrameRect( RectFullScreenUILayer );
	pParentLayer:AddChildZ( layer, 1 );
	ArmyGroupList.InitializeArmyGroupListUI( layer );
	p.pLayerAGList = layer;
end

---------------------------------------------------
-- 创建编辑公告窗口
function p.CreateEditNoticeDlg( pParentLayer )
	local layer = createNDUILayer();
	if not CheckP(layer) then
		LogInfo( "ArmyGroup: ShowArmyGroupMemberUI failed! layer is nil" );
		return false;
	end
	layer:Init();
	layer:SetFrameRect( RectFullScreenUILayer );
	pParentLayer:AddChildZ( layer, 2 );
	local uiLoad=createNDUILoad();
	uiLoad:Load( "ArmyGroup/ArmyGroupUI_EditNotice.ini", layer, p.OnUIEventEditNoticeDlg, 0, 0 );
	uiLoad:Free();
	
	local pUINode	= GetUiNode( layer, ID_EDITNOTICEEDLG_BTN_EDIT );
	local pEdit		= ConverToEdit( pUINode );
	if ( pEdit ~= nil ) then
		pEdit:SetMaxLength( AG_NOTICE_CHA_LIMIT );
	end
	p.pLayerEditNotice	= layer;
end

---------------------------------------------------
-- 编辑公告窗口的事件响应
function p.OnUIEventEditNoticeDlg( uiNode, uiEventType, param )
	local tag = uiNode:GetTag();
	if ( uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK ) then
        if ( ID_EDITNOTICEEDLG_BTN_CONFIRM == tag ) then
			local pNode = GetUiNode( p.pLayerEditNotice, ID_EDITNOTICEEDLG_BTN_EDIT );
			local pEdit = ConverToEdit( pNode );
			local szNotice = pEdit:GetText();
			-- 发送更改公告请求
			MsgArmyGroup.SendMsgSetNotice( szNotice );
		elseif ( ID_EDITNOTICEEDLG_BTN_CANCEL == tag ) then
			-- 
			uiNode:GetParent():RemoveFromParent( true );
			p.pLayerEditNotice	= nil;
        end
    end
    return true;
end


---------------------------------------------------
-- 公告更改成功后刷新
function p.RefreshEditNotice()
	if ( p.pLayerEditNotice	== nil ) then
		LogInfo( "ArmyGroup: RefreshNotice failed! p.pLayerEditNotice is nil" );
		return false;
	end
	if ( p.pLayerInformation == nil ) then
		LogInfo( "ArmyGroup: RefreshNotice failed! p.pLayerInformation is nil" );
		return false;
	end
	--local pNode			= GetUiNode( p.pLayerEditNotice, ID_EDITNOTICEEDLG_BTN_EDIT );
	--local pEdit			= ConverToEdit( pNode );
	--local szNotice		= pEdit:GetText();
	--local pLabelNotice	= GetLabel( p.pLayerInformation, ID_LABEL_NOTICE );
	--pLabelNotice:SetText( szNotice );
	p.pLayerEditNotice:RemoveFromParent( true );
	p.pLayerEditNotice	= nil;
	return true;
end


---------------------------------------------------
-- 权限改变而刷新
function p.RefreshForPermissionChange()
	if ( p.nArmyGroupID == nil ) then
		return;
	end
	local nUserID		= GetPlayerId();
	local nUserArmyGroupID = MsgArmyGroup.GetUserArmyGroupID( nUserID );
	local nPosition = MsgArmyGroup.GetUserArmyGroupPosition( nUserID );
	
	local pBtnQuit = GetButton( p.pLayerInformation, ID_BTN_QUIT );
	if ( pBtnQuit ~= nil and nUserArmyGroupID ~= p.nArmyGroupID ) then
		pBtnQuit:SetVisible( false );
	else
		pBtnQuit:SetVisible( true );
	end
	local pBtnEdit = GetButton( p.pLayerInformation, ID_BTN_EDIT );
	if ( pBtnEdit ~= nil and ( nUserArmyGroupID ~= p.nArmyGroupID or nPosition == ArmyGroupPositionGrade.AGPG_NONE  ) ) then
		pBtnEdit:SetVisible( false );
	else
		pBtnEdit:SetVisible( true );
	end
	if ( HadleMember.pLayerHandleMemberDlg ~= nil ) then
		HadleMember.CloseUI();
	end
	local pLabelPosition = GetLabel( p.pLayerInformation, ID_LABEL_POSITION );
	local szPosition = MsgArmyGroup.GetPositionString( nPosition );
	pLabelPosition:SetText( szPosition );
	
	Solicit.RefreshForPermissionChange()
end


---------------------------------------------------
-- 刷新军团列表
function p.RefreshAGList( tArmyGroupList )
	return ArmyGroupList.RefreshAGList( tArmyGroupList );
end

---------------------------------------------------
-- 刷新军团信息更新
function p.RefreshAGUpgrade( tNetDataPackete )
	local nArmyGroupID		= tNetDataPackete:ReadInt();
	local nUpgradeAction	= tNetDataPackete:ReadByte();
	if ( nUpgradeAction == AGUpgradeAction.AGUA_Legatus ) then
		local nLegatusID	= tNetDataPackete:ReadInt();
		local nLegatusName	= tNetDataPackete:ReadUnicodeString();
	elseif ( nUpgradeAction == AGUpgradeAction.AGUA_Member ) then
		local nMbrAmount	= tNetDataPackete:ReadInt();
	elseif ( nUpgradeAction == AGUpgradeAction.AGUA_Notice ) then
		local szNotice		= tNetDataPackete:ReadUnicodeString();
	elseif ( nUpgradeAction == AGUpgradeAction.AGUA_Level ) then
		local nLevel		= tNetDataPackete:ReadShort();
		local nExp			= tNetDataPackete:ReadInt();
	elseif ( nUpgradeAction == AGUpgradeAction.AGUA_Ranking ) then
		local nRanking		= tNetDataPackete:ReadShort();
	elseif ( nUpgradeAction == AGUpgradeAction.AGUA_Experience ) then
		local nExp			= tNetDataPackete:ReadInt();
	end
end


