---------------------------------------------------
--描述: 军团列表
--时间: 2012.9.19
--作者: Guosen
---------------------------------------------------

ArmyGroupList = {};
local p = ArmyGroupList;

---------------------------------------------------
-- 
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


---------------------------------------------------
p.pLayerArmyGroupList	= nil;

---------------------------------------------------
function p.ShowUI()
	p.pLayerArmyGroupList:SetVisible( true );
	--local tArmyGroupList	= MsgArmyGroup.GetArmyGroupList();
	--p.FillArmyGroupList( layer, tArmyGroupList );
	MsgArmyGroup.SendMsgGetArmyGroupList();
end

---------------------------------------------------
-- 显示创建军团列表界面
--function p.CreateUI( pLayer )
--	--LogInfo( "ArmyGroupList: ShowUI()" );
--	local scene = GetSMGameScene();
--	if not CheckP(scene) then
--	LogInfo( "ArmyGroupList: ShowUI failed! scene is nil" );
--		return false;
--	end
--	
--	local layer = createNDUILayer();
--	if not CheckP(layer) then
--		LogInfo( "ArmyGroupList: ShowUI failed! layer is nil" );
--		return false;
--	end
--	layer:Init();
--	layer:SetFrameRect( RectFullScreenUILayer );
--	pLayer:AddChildZ( layer, 1 );
--end
	
function p.InitializeArmyGroupListUI( pLayer )
p.pLayerArmyGroupList	= nil;
	local uiLoad = createNDUILoad();
	if ( nil == uiLoad ) then
		LogInfo( "ArmyGroupList: ShowUI failed! uiLoad is nil" );
		return false;
	end
	uiLoad:Load( "ArmyGroup/ArmyGroupUI_AGList.ini", pLayer, p.OnUIEventArmyGroupList, 0, 0 );
	uiLoad:Free();
	
	p.pLayerArmyGroupList = pLayer;
end

--
function p.CloseUI()
	p.pLayerArmyGroupList:SetVisible( false );
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
		LogInfo( "ArmyGroupList: FillArmyGroupList() failed! pScrollViewContainer is nil" );
		return false;
	end
    pScrollViewContainer:EnableScrollBar(true);
	pScrollViewContainer:SetStyle( UIScrollStyle.Verical );
	pScrollViewContainer:SetViewSize( tSize );
	pScrollViewContainer:RemoveAllView();
	for i = 1, nListItemAmount do
		local pListItem = createUIScrollView();
	
		if not CheckP( pListItem ) then
			LogInfo( "ArmyGroupList: pListItem == nil" );
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
			LogInfo( "ArmyGroupList: FillArmyGroupList failed! uiLoad is nil" );
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
-- 刷新列表
function p.RefreshAGList( tArmyGroupList )
	if ( p.pLayerArmyGroupList == nil ) then
		return;
	end
	p.FillArmyGroupList( p.pLayerArmyGroupList, tArmyGroupList);
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
			ArmyGroupInfor.ShowUI( ArmyGroup.pLayerMainUI, nArmyGroupID );
		--elseif ( ID_LISTTEM_BTN_CANCEL == tag ) then
		--	-- 发送取消请求
		--	if ( nArmyGroupID ~= nil ) then
		--		MsgArmyGroup.SendMsgCancelApply( nArmyGroupID );
		--	end
		--elseif ( ID_LISTTEM_BTN_APPLY == tag ) then
		--	-- 发送申请请求
		--	if ( nArmyGroupID ~= nil ) then
		--		MsgArmyGroup.SendMsgJoinArmyGroupApplication( nArmyGroupID );
		--	end
        end
    end
    return true;
end


