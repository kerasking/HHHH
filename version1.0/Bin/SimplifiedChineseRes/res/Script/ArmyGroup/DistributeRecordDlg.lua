---------------------------------------------------
--描述: 分配记录面板
--时间: 2012.12.7
--作者: Guosen
---------------------------------------------------

DistributeRecordDlg = {}
local p = DistributeRecordDlg;

---------------------------------------------------
local ID_BTN_CLOSE					= 533;	-- X
local ID_LIST_RECORD				= 101;	-- 记录列表控件
-- = 14;??

local ID_BTN_PRE					= 14;	-- 前一页
local ID_BTN_NXT					= 15;	-- 下一页

local LIST_PER_PAGE_LIMIT			= 7;	-- 每页显示的记录条数限制

---------------------------------------------------

local tRecordList = {
 { 11111, "O","T", 111,22, 1101011, 20 },
 { 11111, "O","T", 111,22, 31000082, 30 },
};

local szTest = "2012年12月12日 22:22【军团长名字】将【什么什么物品X数量】分发给【接受者名字】";

---------------------------------------------------
p.pLayerDistributeRecordDlg		= nil;
p.tRecordList					= nil;
p.nShowIndex					= nil;	-- 当前页的从第几个记录开始显示

---------------------------------------------------
function p.CreateDistributeRecordDlg( pParentLayer )
	
	local layer = createNDUILayer();
	if not CheckP(layer) then
		LogInfo( "DistributeRecordDlg: CreateHadleMemberDlg failed! layer is nil" );
		return false;
	end
	layer:Init();
	layer:SetFrameRect( RectFullScreenUILayer );
	pParentLayer:AddChildZ( layer, 2 );
	local uiLoad = createNDUILoad();
	if ( nil == uiLoad ) then
		layer:Free();
		LogInfo( "DistributeRecordDlg: CreateHadleMemberDlg failed! uiLoad is nil" );
		return false;
	end
	uiLoad:Load( "ArmyGroup/ArmyGroupUI_Activity.ini", layer, p.OnUIEventDistributeRecordDlg, 0, 0 );
	uiLoad:Free();
	p.pLayerDistributeRecordDlg = layer;
	local pBtnPre = GetButton( p.pLayerDistributeRecordDlg, ID_BTN_PRE );
	pBtnPre:SetVisible( false );
	local pBtnNxt = GetButton( p.pLayerDistributeRecordDlg, ID_BTN_NXT );
	pBtnNxt:SetVisible( false );

	p.tRecordList = {};	
	MsgArmyGroup.SendMsgGetDistributeHistory( 0, 100 );
	return true;
end

---------------------------------------------------
function p.CloseUI()
	if ( p.pLayerDistributeRecordDlg ~= nil ) then
		p.pLayerDistributeRecordDlg:RemoveFromParent( true );
		p.pLayerDistributeRecordDlg		= nil;
		p.tRecordList					= nil;
		p.nShowIndex					= nil;
	end
end

---------------------------------------------------
-- 军团成员面板界面的事件响应
function p.OnUIEventDistributeRecordDlg( uiNode, uiEventType, param )
	local tag = uiNode:GetTag();
	if ( uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK ) then
		if ( ID_BTN_CLOSE == tag ) then
			p.CloseUI();
		elseif( tag == ID_BTN_PRE ) then
			local nShowIndex	= p.nShowIndex - LIST_PER_PAGE_LIMIT;
			local nRecordAmount = table.getn( p.tRecordList );
			if ( nShowIndex > 0 ) then
				if ( p.ShowDistributeRecordList( p.tRecordList, nShowIndex ) ) then
					if ( nShowIndex < LIST_PER_PAGE_LIMIT ) then
						local pBtnPre = GetButton( p.pLayerDistributeRecordDlg, ID_BTN_PRE );
						pBtnPre:SetVisible( false );
					end
					if ( nShowIndex+LIST_PER_PAGE_LIMIT < nRecordAmount ) then
						local pBtnNxt = GetButton( p.pLayerDistributeRecordDlg, ID_BTN_NXT );
						pBtnNxt:SetVisible( true );
					end
					p.nShowIndex = nShowIndex;     
				end
			end
		elseif( tag == ID_BTN_NXT ) then
			local nShowIndex	= p.nShowIndex + LIST_PER_PAGE_LIMIT;
			local nRecordAmount	= table.getn( p.tRecordList );
			if ( nShowIndex <= nRecordAmount ) then
				if ( p.ShowDistributeRecordList( p.tRecordList, nShowIndex ) )then
					if ( nShowIndex >= LIST_PER_PAGE_LIMIT ) then
						local pBtnPre = GetButton( p.pLayerDistributeRecordDlg, ID_BTN_PRE );
						pBtnPre:SetVisible( true );
					end
					if ( nShowIndex+LIST_PER_PAGE_LIMIT > nRecordAmount ) then
						local pBtnNxt = GetButton( p.pLayerDistributeRecordDlg, ID_BTN_NXT );
						pBtnNxt:SetVisible( false );
					end
					p.nShowIndex = nShowIndex;
				end
			end
        end
    end
    return true;
end

---------------------------------------------------
function p.Callback_FillRecordList( tList, bEnd )
	--LogInfo( "DistributeRecordDlg: Callback_FillRecordList" );
	for i,v in pairs( tList ) do
		table.insert( p.tRecordList, v );
	end
	if ( bEnd == 1 ) then
		p.InitScrollViewContainer();
		p.nShowIndex = 1;
		p.ShowDistributeRecordList( p.tRecordList, p.nShowIndex );
		local nRecordAmount	= table.getn( p.tRecordList );
		local pBtnPre = GetButton( p.pLayerDistributeRecordDlg, ID_BTN_PRE );
		local pBtnNxt = GetButton( p.pLayerDistributeRecordDlg, ID_BTN_NXT );
		if ( p.nShowIndex < LIST_PER_PAGE_LIMIT ) then
			pBtnPre:SetVisible( false );
		else
			pBtnPre:SetVisible( true );
		end
		if ( p.nShowIndex+LIST_PER_PAGE_LIMIT > nRecordAmount ) then
			pBtnNxt:SetVisible( false );
		else
			pBtnNxt:SetVisible( true );
		end
	end
end

---------------------------------------------------
-- 填充记录列表控件
--function p.FillDistributeRecordList( tRecordList )
--	--LogInfo( "DistributeRecordDlg: FillDistributeRecordList" );
--	if ( p.pLayerDistributeRecordDlg == nil ) then
--		LogInfo( "DistributeRecordDlg: FillDistributeRecordList() failed! p.pLayerDistributeRecordDlg is nil" );
--		return false;
--	end
--	if ( tRecordList == nil ) then
--		return false;
--	end
--    
--	-- 获得滚屏容器
--	local pScrollViewContainer = GetScrollViewContainer( p.pLayerDistributeRecordDlg, ID_LIST_RECORD );
--	if ( nil == pScrollViewContainer ) then
--		LogInfo( "DistributeRecordDlg: FillDistributeRecordList() failed! pScrollViewContainer is nil" );
--		return false;
--	end
--    pScrollViewContainer:EnableScrollBar(true);
--	pScrollViewContainer:SetStyle( UIScrollStyle.Verical );
--	--pScrollViewContainer:SetViewSize( tSize );
--	pScrollViewContainer:RemoveAllView();
--    
--    local nFontSize		= 12;
--    local rectview 		= pScrollViewContainer:GetFrameRect();
--    local nWidthLimit	= rectview.size.w;
--    --local pColorLabel	= _G.CreateColorLabel( szTest, nFontSize, nWidthLimit );
--    local tTextSize		= _G.GetHyperLinkTextSize( szTest, nFontSize, nWidthLimit );
--	pScrollViewContainer:SetViewSize( tTextSize );
--    
--	local nRecordAmount = table.getn( tRecordList );
--	if ( nRecordAmount == 0 ) then
--		return false;
--	end
--	
--	for i = 1, nRecordAmount do
--		local pListItem = createUIScrollView();
--	
--		if not CheckP( pListItem ) then
--			LogInfo( "DistributeRecordDlg: pListItem == nil" );
--			return false;
--		end
--	
--		pListItem:Init( false );
--		pListItem:SetScrollStyle( UIScrollStyle.Verical );
--		pListItem:SetViewId( i );
--		pListItem:SetTag( i );
--		pScrollViewContainer:AddView( pListItem );
--        
--
--        local tRecord = tRecordList[i];
--        local nTime         = tRecord[DistributeRecordIndex.DRI_TIME];
--        local szOName       = tRecord[DistributeRecordIndex.DRI_ONAME];
--        local szTName       = tRecord[DistributeRecordIndex.DRI_TNAME];
--        local nItemType     = tRecord[DistributeRecordIndex.DRI_ITEMTYPE];
--        local nItemAmount   = tRecord[DistributeRecordIndex.DRI_ITEMAMOUNT];
--        local tTime			= os.date( "*t", nTime )
--        local szTime		= tTime["year"] .. "年" .. tTime["month"] .. "月" .. tTime["day"] .. "日" .. tTime["hour"] ..":"..tTime["min"];
--		local szItemName	= ItemFunc.GetName( nItemType );
--        local szText = szTime .. "【" .. szOName .. "】将【" .. szItemName .."×" .. nItemAmount .. "】分发给【" .. szTName.. "】";
--		--LogInfo( "DistributeRecordDlg: "..szText );
--        --local pLabel = createNDUILabel();
--        --pLabel:Init();
--		--pLabel:SetFontSize( nFontSize );
--		--pLabel:SetTextAlignment( UITextAlignment.Left );
--		--pLabel:SetFrameRect( CGRectMake( 0, 0, tTextSize.w, tTextSize.h ) );
--		--pLabel:SetFontColor( ccc4(255, 255, 255, 255) );
--        -- pLabel:SetText(szText);
--        local szText = "<c54ff04" .. szTime .."/e<c35ffff【" .. szOName .. "】/e将<cfff815【" .. szItemName .."×" .. nItemAmount .. "】/e分发给<cff30ff【" .. szTName.. "】/e";
--        local pColorLabel	= _G.CreateColorLabel( szText, nFontSize, nWidthLimit );
--        pColorLabel:SetFrameRect( CGRectMake( 0, 0, tTextSize.w, tTextSize.h ) );
--        
--        pListItem:AddChild( pColorLabel );
--	end
--	return true;
--end


---------------------------------------------------
-- 初始列表控件容器
function p.InitScrollViewContainer()
	if ( p.pLayerDistributeRecordDlg == nil ) then
		LogInfo( "DistributeRecordDlg: SetScrollViewContainer() failed! p.pLayerDistributeRecordDlg is nil" );
		return false;
	end
	if ( tRecordList == nil ) then
		return false;
	end
    
	-- 获得滚屏容器
	local pScrollViewContainer = GetScrollViewContainer( p.pLayerDistributeRecordDlg, ID_LIST_RECORD );
	if ( nil == pScrollViewContainer ) then
		LogInfo( "DistributeRecordDlg: SetScrollViewContainer() failed! pScrollViewContainer is nil" );
		return false;
	end
    pScrollViewContainer:EnableScrollBar(true);
	pScrollViewContainer:SetStyle( UIScrollStyle.Verical );
    
    local nFontSize		= 12;
    local rectview 		= pScrollViewContainer:GetFrameRect();
    local nWidthLimit	= rectview.size.w;
    --local pColorLabel	= _G.CreateColorLabel( szTest, nFontSize, nWidthLimit );
    local tTextSize		= _G.GetHyperLinkTextSize( szTest, nFontSize, nWidthLimit );
	pScrollViewContainer:SetViewSize( tTextSize );
end


---------------------------------------------------
-- 从指定序号开始显示记录
function p.ShowDistributeRecordList( tRecordList, nIndex )
	if ( p.pLayerDistributeRecordDlg == nil ) then
		LogInfo( "DistributeRecordDlg: ShowDistributeRecordList() failed! p.pLayerDistributeRecordDlg is nil" );
		return false;
	end
	if ( tRecordList == nil ) then
		return false;
	end
    
	-- 获得滚屏容器
	local pScrollViewContainer = GetScrollViewContainer( p.pLayerDistributeRecordDlg, ID_LIST_RECORD );
	if ( nil == pScrollViewContainer ) then
		LogInfo( "DistributeRecordDlg: ShowDistributeRecordList() failed! pScrollViewContainer is nil" );
		return false;
	end
	
	local nRecordAmount = table.getn( tRecordList );
	if ( nRecordAmount == 0 ) then
		return false;
	end
	if ( nIndex <= 0 ) or ( nIndex > nRecordAmount ) then
		return false;
	end
	pScrollViewContainer:RemoveAllView();
    local nFontSize		= 12;
    local rectview 		= pScrollViewContainer:GetFrameRect();
    local nWidthLimit	= rectview.size.w;
    local tTextSize		= _G.GetHyperLinkTextSize( szTest, nFontSize, nWidthLimit );
	pScrollViewContainer:SetViewSize( tTextSize );
	for i = nIndex, nIndex+LIST_PER_PAGE_LIMIT-1 do
		if ( i > nRecordAmount ) then
			break;
		end
		local pListItem = createUIScrollView();
	
		if not CheckP( pListItem ) then
			LogInfo( "DistributeRecordDlg: pListItem == nil" );
			return false;
		end
	
		pListItem:Init( false );
		pListItem:SetScrollStyle( UIScrollStyle.Verical );
		pListItem:SetViewId( i );
		pListItem:SetTag( i );
		pScrollViewContainer:AddView( pListItem );
        
        local tRecord = tRecordList[i];
        local nTime         = tRecord[DistributeRecordIndex.DRI_TIME];
        local szOName       = tRecord[DistributeRecordIndex.DRI_ONAME];
        local szTName       = tRecord[DistributeRecordIndex.DRI_TNAME];
        local nItemType     = tRecord[DistributeRecordIndex.DRI_ITEMTYPE];
        local nItemAmount   = tRecord[DistributeRecordIndex.DRI_ITEMAMOUNT];
        local tTime			= os.date( "*t", nTime )
        local szTime		= tTime["year"] .. "年" .. tTime["month"] .. "月" .. tTime["day"] .. "日" .. tTime["hour"] ..":"..tTime["min"];
		local szItemName	= ItemFunc.GetName( nItemType );
        local szText = szTime .. "【" .. szOName .. "】将【" .. szItemName .."×" .. nItemAmount .. "】分发给【" .. szTName.. "】";
        local szText = "<c54ff04" .. szTime .."/e<c35ffff【" .. szOName .. "】/e将<cfff815【" .. szItemName .."×" .. nItemAmount .. "】/e分发给<cff30ff【" .. szTName.. "】/e";
        local pColorLabel	= _G.CreateColorLabel( szText, nFontSize, nWidthLimit );
        pColorLabel:SetFrameRect( CGRectMake( 0, 0, tTextSize.w, tTextSize.h ) );
        
        pListItem:AddChild( pColorLabel );
	end
	return true;
end
