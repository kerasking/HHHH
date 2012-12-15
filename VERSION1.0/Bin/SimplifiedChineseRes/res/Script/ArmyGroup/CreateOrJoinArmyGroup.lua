---------------------------------------------------
--描述: 创建或加入军团
--时间: 2012.9.19
--作者: Guosen
---------------------------------------------------

CreateOrJoinArmyGroup = {};
local p = CreateOrJoinArmyGroup;

---------------------------------------------------
-- 菜单按钮控件ID
local ID_BTN_CLOSE					= 3;	-- X
local ID_BTN_CREATE					= 17;	-- 创建军团按钮ID
local ID_LIST_CONTAINER				= 43;	-- 军团列表控件ID

local ID_LISTTEM_PIC_BORDER				= 1;	-- 军团列表列表项的边框ID
local ID_LISTTEM_BTN_CANCEL				= 21;	-- 取消按钮ID
local ID_LISTTEM_BTN_APPLY				= 22;	-- 申请按钮ID
local ID_LISTTEM_LABEL_RANKING			= 44;	-- 排名
local ID_LISTTEM_LABEL_AGNAME			= 45;	-- 军团名
local ID_LISTTEM_LABEL_ONAME			= 46;	-- 军团长名
local ID_LISTTEM_LABEL_LEVEL			= 47;	-- 等级
local ID_LISTTEM_LABEL_MEMBER			= 48;	-- 成员数量
local ID_LISTTEM_BTN_TOUCH				= 16;	-- 按钮

-- 创建军团对话框的控件ID
local ID_CREATEDLG_BTN_CONFIRM			= 101;	-- 确定
local ID_CREATEDLG_BTN_CANCEL			= 102;	-- 取消
local ID_CREATEDLG_LABEL_TITLE			= 103;	-- 提示
local ID_CREATEDLG_EDIT_INPUT			= 104;	-- 输入框


---------------------------------------------------
local AG_CREATE_LEVEL					= 30;	-- 允许创建军团等级
local AG_NAME_CHA_LIMIT					= 7;	-- 限制军团昵称字数
local AG_CREATE_COST					= 200000;-- 创建军团费用-20万银币
local SZ_CREATE_TIPS					= "创建军团需要消耗20万银币。";
local SZ_CREATE_ER						= "创建军团需要消耗20万银币。您银币不足。";
local SZ_CREATE_LEVEL					= "创建军团需要30级及以上";
local SZ_CREATE_ER00					= "你已申请加入其他军团，请取消申请～";
local SZ_APPLY_ER00						= "你已达到申请上限～";

---------------------------------------------------
p.pLayerCreateOrJoinArmyGroup	= nil;

---------------------------------------------------
function p.ShowUI()
p.pLayerCreateOrJoinArmyGroup	= nil;
	--LogInfo( "CreateOrJoinArmyGroup: ShowUI()" );
	local scene = GetSMGameScene();
	if not CheckP(scene) then
	LogInfo( "CreateOrJoinArmyGroup: ShowUI failed! scene is nil" );
		return false;
	end
	
	local layer = createNDUILayer();
	if not CheckP(layer) then
		LogInfo( "CreateOrJoinArmyGroup: ShowUI failed! layer is nil" );
		return false;
	end
	layer:Init();
	layer:SetTag( NMAINSCENECHILDTAG.CreateOrJoinArmyGroup );
	layer:SetFrameRect( RectFullScreenUILayer );
	scene:AddChildZ( layer, UILayerZOrder.NormalLayer );

	local uiLoad = createNDUILoad();
	if ( nil == uiLoad ) then
		layer:Free();
		LogInfo( "CreateOrJoinArmyGroup: ShowUI failed! uiLoad is nil" );
		return false;
	end
	uiLoad:Load( "ArmyGroup/ArmyGroupUI_CreateOrJoin.ini", layer, p.OnUIEventArmyGroupList, 0, 0 );
	uiLoad:Free();
	
	p.pLayerCreateOrJoinArmyGroup = layer;
	
	--local nUserID		= GetPlayerId();
	--local nAGID			= MsgArmyGroup.GetUserArmyGroupID( nUserID );
	--local tApplyList	= MsgArmyGroup.GetArmyGroupApplyList( nUserID );
	--local nApplyAmount	= table.getn( tApplyList );
	--if ( ( nAGID ~= nil ) or ( nApplyAmount > 0 ) ) then
	--	local pBtnCreate = GetButton( layer, ID_BTN_CREATE );
	--	if ( pBtnCreate ~= nil ) then
	--		pBtnCreate:SetVisible( false );
	--	end
	--end
	
	--local tArmyGroupList	= MsgArmyGroup.GetArmyGroupList();
	--p.FillArmyGroupList( layer, tArmyGroupList );
	MsgArmyGroup.SendMsgGetArmyGroupList();
end

---------------------------------------------------
-- 显示创建军团或加入军团界面
function p.CreateOrJoinArmyGroup()
	return p.ShowUI();
end

--
function p.CloseUI()
	local scene = GetSMGameScene();
	if ( scene ~= nil ) then
		scene:RemoveChildByTag( NMAINSCENECHILDTAG.CreateOrJoinArmyGroup, true );
	end
	p.pLayerCreateOrJoinArmyGroup	= nil;
end

---------------------------------------------------
-- 创建或加入军团界面的事件响应
function p.OnUIEventArmyGroupList( uiNode, uiEventType, param )
	local tag = uiNode:GetTag();
	if ( uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK ) then
        if ( ID_BTN_CLOSE == tag ) then
			p.CloseUI();
		elseif ( ID_BTN_CREATE == tag ) then
			local nUserID	= GetPlayerId();
			local nPlayerID	= RolePetFunc.GetMainPetId( nUserID );
			local nLevel	= RolePet.GetPetInfoN( nPlayerID, PET_ATTR.PET_ATTR_LEVEL );
			if ( nLevel < AG_CREATE_LEVEL ) then
				CommonDlgNew.ShowYesDlg( SZ_CREATE_LEVEL, nil, nil, 3 );
				return true;
			end
			local nAGID			= MsgArmyGroup.GetUserArmyGroupID( nUserID );
			local tApplyList	= MsgArmyGroup.GetArmyGroupApplyList( nUserID );
			local nApplyAmount	= table.getn( tApplyList );
			if ( nApplyAmount > 0 ) then
				CommonDlgNew.ShowYesDlg( SZ_CREATE_ER00, nil, nil, 3 );
				return true;
			end
			local nPlayerSilver	= GetRoleBasicDataN( nUserID, USER_ATTR.USER_ATTR_MONEY );
			if ( nPlayerSilver < AG_CREATE_COST ) then
				CommonDlgNew.ShowYesDlg( SZ_CREATE_ER, nil, nil, 3 );
				return true;
			end
			local pParentLayer = ConverToUiLayer( uiNode:GetParent() );
			p.ShowCreateArmyGroupUI( pParentLayer );
        end
    end
    return true;
end
	
---------------------------------------------------
--显示军团列表
function p.FillArmyGroupList( pParentLayer, tArmyGroupList )
	if ( tArmyGroupList == nil )  then
		return;
	end
	local nListItemAmount = table.getn( tArmyGroupList );
	if ( nListItemAmount == 0 ) then
		return;
	end
	local nUserID		= GetPlayerId();
	local nAGID			= MsgArmyGroup.GetUserArmyGroupID( nUserID );
	local tApplyList	= MsgArmyGroup.GetArmyGroupApplyList( nUserID );
	local nApplyAmount	= table.getn( tApplyList );
    
	local layer = createNDUILayer();
	layer:Init();
	local uiLoad=createNDUILoad();
	uiLoad:Load( "ArmyGroup/ArmyGroupUI_ArmyGroupListItem.ini", layer, nil, 0, 0 );
	uiLoad:Free();
	local pBorder = GetImage( layer, ID_LISTTEM_PIC_BORDER );
	local tSize = pBorder:GetFrameRect().size;
	layer:Free();
	
	-- 获得滚屏容器
	local pScrollViewContainer = GetScrollViewContainer( pParentLayer, ID_LIST_CONTAINER );
	if nil == pScrollViewContainer then
		LogInfo( "CreateOrJoinArmyGroup: FillArmyGroupList() failed! pScrollViewContainer is nil" );
		return false;
	end
    pScrollViewContainer:EnableScrollBar(true);
	pScrollViewContainer:SetStyle( UIScrollStyle.Verical );
	pScrollViewContainer:SetViewSize( tSize );
	pScrollViewContainer:RemoveAllView();
	for i = 1, nListItemAmount do
		local pListItem = createUIScrollView();
	
		if not CheckP( pListItem ) then
			LogInfo( "CreateOrJoinArmyGroup: pListItem == nil" );
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
			LogInfo( "CreateOrJoinArmyGroup: FillArmyGroupList failed! uiLoad is nil" );
			return false;
		end
		uiLoad:Load( "ArmyGroup/ArmyGroupUI_ArmyGroupListItem.ini", pListItem, p.OnUIEventArmyGroupListItem, 0, 0 );
		uiLoad:Free();
		
		local pLabelRanking		= GetLabel( pListItem, ID_LISTTEM_LABEL_RANKING );
		local pLabelAGName		= GetLabel( pListItem, ID_LISTTEM_LABEL_AGNAME );
		local pLabelOName		= GetLabel( pListItem, ID_LISTTEM_LABEL_ONAME );
		local pLabelLevel		= GetLabel( pListItem, ID_LISTTEM_LABEL_LEVEL );
		local pLabelMember		= GetLabel( pListItem, ID_LISTTEM_LABEL_MEMBER );
		local pBtnCancel		= GetButton( pListItem, ID_LISTTEM_BTN_CANCEL );
		local pBtnApply			= GetButton( pListItem, ID_LISTTEM_BTN_APPLY );
		
		local nArmyGroupID		= tArmyGroupList[i][ArmyGroupRecordIndex.AGRI_ID];
		local nRanking			= tArmyGroupList[i][ArmyGroupRecordIndex.AGRI_RANKING];
		local szAGName			= tArmyGroupList[i][ArmyGroupRecordIndex.AGRI_AGNAME];
		local szOName			= tArmyGroupList[i][ArmyGroupRecordIndex.AGRI_ONAME];
		local nLevel			= tArmyGroupList[i][ArmyGroupRecordIndex.AGRI_LEVEL];
		local nMember			= tArmyGroupList[i][ArmyGroupRecordIndex.AGRI_MEMBER];
		local nMemberLimit		= tArmyGroupList[i][ArmyGroupRecordIndex.AGRI_MEMBERLIMIT];
		
		pLabelRanking:SetText( SafeN2S(nRanking) );
		pLabelAGName:SetText( szAGName );
		pLabelOName:SetText( szOName );
		pLabelLevel:SetText( SafeN2S(nLevel) );
		pLabelMember:SetText( nMember .."/".. nMemberLimit );
		if ( nAGID == nil ) then
			if ( nApplyAmount > 0 ) then
				if ( nApplyAmount >= MsgArmyGroup.ArmyGroupApplyLimit ) then-- >5
					pBtnApply:SetVisible( false );
				else
					pBtnApply:SetVisible( true );
				end
				pBtnCancel:SetVisible( false );
				for i, v in ipairs(tApplyList) do
					if ( v == nArmyGroupID ) then
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
		
		local pBorder = GetImage( pListItem, ID_LISTTEM_PIC_BORDER );
		pBorder:SetVisible(false);
	end
	
end

---------------------------------------------------
-- 刷新军团列表
function p.RefreshAGList( tArmyGroupList )
	if ( p.pLayerCreateOrJoinArmyGroup == nil ) then
		return;
	end
	p.FillArmyGroupList( p.pLayerCreateOrJoinArmyGroup, tArmyGroupList);
end

---------------------------------------------------
-- 刷新申请列表(申请按钮、取消按钮)
function p.RefreshApplyList()
	local pScrollViewContainer = GetScrollViewContainer( p.pLayerCreateOrJoinArmyGroup, ID_LIST_CONTAINER );
	local nViewAmount = pScrollViewContainer:GetViewCount();
	if ( nViewAmount == 0 ) then
		return;
	end
	local nUserID			= GetPlayerId();
	local nAGID				= MsgArmyGroup.GetUserArmyGroupID( nUserID );
	local tApplyList		= MsgArmyGroup.GetArmyGroupApplyList( nUserID );
	local nApplyAmount		= table.getn( tApplyList );
	local tArmyGroupList	= MsgArmyGroup.GetArmyGroupList();
	for i=1, nViewAmount do
		local pView			= pScrollViewContainer:GetViewById( i );
		local pBtnCancel	= GetButton( pView, ID_LISTTEM_BTN_CANCEL );
		local pBtnApply		= GetButton( pView, ID_LISTTEM_BTN_APPLY );
		pBtnCancel:SetVisible( false );
		pBtnApply:SetVisible( false );
		local nArmyGroupID	= tArmyGroupList[i][ArmyGroupRecordIndex.AGRI_ID];
		if ( nAGID == nil ) then
			if ( nApplyAmount > 0 ) then
				if ( nApplyAmount >= MsgArmyGroup.ArmyGroupApplyLimit ) then-- >5
					pBtnApply:SetVisible( false );
				else
					pBtnApply:SetVisible( true );
				end
				pBtnCancel:SetVisible( false );
				for i, v in ipairs(tApplyList) do
					if ( v == nArmyGroupID ) then
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
	if ( ArmyGroupInfor.pLayerInformation ~= nil ) then
		ArmyGroupInfor.RefreshApplyCancelBtn();
	end
end

---------------------------------------------------
-- 成员列表项的事件响应
function p.OnUIEventArmyGroupListItem( uiNode, uiEventType, param )
	local tag = uiNode:GetTag();
	local nIndex			= uiNode:GetParent():GetTag();
	local tArmyGroupList	= MsgArmyGroup.GetArmyGroupList();
	local nArmyGroupID		= tArmyGroupList[nIndex][ArmyGroupRecordIndex.AGRI_ID];
	if ( uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK ) then
        if ( ID_LISTTEM_BTN_TOUCH == tag ) then
			--p.CloseUI();
			ArmyGroupInfor.ShowUI( p.pLayerCreateOrJoinArmyGroup, nArmyGroupID );
		elseif ( ID_LISTTEM_BTN_CANCEL == tag ) then
			-- 发送取消请求
			if ( nArmyGroupID ~= nil ) then
				MsgArmyGroup.SendMsgCancelApply( nArmyGroupID );
			end
		elseif ( ID_LISTTEM_BTN_APPLY == tag ) then
			local nUserID		= GetPlayerId();
			local nAGID			= MsgArmyGroup.GetUserArmyGroupID( nUserID );
			local tApplyList	= MsgArmyGroup.GetArmyGroupApplyList( nUserID );
			local nApplyAmount	= table.getn( tApplyList );
			if ( nApplyAmount >= MsgArmyGroup.ArmyGroupApplyLimit ) then-- >5
				CommonDlgNew.ShowYesDlg( SZ_APPLY_ER00, nil, nil, 3 );
				return true;
			end
			-- 发送申请请求
			if ( nArmyGroupID ~= nil ) then
				MsgArmyGroup.SendMsgJoinArmyGroupApplication( nArmyGroupID );
			end
        end
    end
    return true;
end

---------------------------------------------------
-- 显示创建军团对话框
function p.ShowCreateArmyGroupUI( pParentLayer )
	local layer = createNDUILayer();
	if not CheckP(layer) then
		LogInfo( "CreateOrJoinArmyGroup: ShowArmyGroupListUI failed! layer is nil" );
		return false;
	end  
	layer:Init();
	--layer:SetTag( NMAINSCENECHILDTAG.CreateOrJoinArmyGroup );
	layer:SetFrameRect( RectFullScreenUILayer );
	pParentLayer:AddChildZ( layer, 1 );

	local uiLoad = createNDUILoad();
	if ( nil == uiLoad ) then
		layer:Free();
		LogInfo( "CreateOrJoinArmyGroup: ShowArmyGroupListUI failed! uiLoad is nil" );
		return false;
	end
	uiLoad:Load( "ArmyGroup/ArmyGroupUI_CreateDlg.ini", layer, p.OnUIEventCreateArmyGroupDlg, 0, 0 );
	uiLoad:Free();
	
	local pLabel = GetLabel( layer, ID_CREATEDLG_LABEL_TITLE );
	if ( pLabel ~= nil ) then
		pLabel:SetText( SZ_CREATE_TIPS );
	end
	
	local pUINode	= GetUiNode( layer, ID_CREATEDLG_EDIT_INPUT );
	local pEdit		= ConverToEdit( pUINode );
	if ( pEdit ~= nil ) then
		pEdit:SetMaxLength( AG_NAME_CHA_LIMIT );--
	end
end

---------------------------------------------------
-- 创建军团对话框界面的事件响应
function p.OnUIEventCreateArmyGroupDlg( uiNode, uiEventType, param )
	local tag = uiNode:GetTag();
	if ( uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK ) then
        if ( ID_CREATEDLG_BTN_CANCEL == tag ) then
			uiNode:GetParent():RemoveFromParent( true );
		elseif ( ID_CREATEDLG_BTN_CONFIRM == tag ) then
			local pLayer	= uiNode:GetParent();
			local pUINode	= GetUiNode( pLayer, ID_CREATEDLG_EDIT_INPUT );
			local pEdit		= ConverToEdit( pUINode );
			local szAGName	= pEdit:GetText();
			if ( szAGName ~= nil and szAGName ~= "" ) then
				MsgArmyGroup.SendMsgCreateArmyGroup( szAGName );
			end
        end
    end
    return true;
end



---------------------------------------------------
-- 刷新军团信息
function p.RefreshInformation( tArmyGroupInformation )
	return ArmyGroupInfor.RefreshInformation( tArmyGroupInformation );
end

-- 刷新成员
function p.RefreshMemberlist( tArmyGroupMemberList )
	return ArmyGroupInfor.RefreshMemberlist( tArmyGroupMemberList );
end
