---------------------------------------------------
--描述: 邮箱界面
--时间: 2012.6.6
--作者: Guosen
---------------------------------------------------
-- 进入邮箱界面接口：		EmailLis.LoadUI();
-- 向好友发信接口：			EmailList.SendEmailToFriend( szName );
---------------------------------------------------
-- 2012.6.12 BUG
-- ListItem.ini 按钮控件有问题，点中进去，出来后，点其他位置会显示选择状态并一直保持
---------------------------------------------------

EmailList = {}
local p = EmailList;

-- 各层级界面
p.pLayerInbox						= nil;	-- 收件箱层
p.pLayerReceivedMail				= nil;	-- 已收到的邮件层
p.pLayerOutbox						= nil;	-- 发件箱层
p.pLayerSentMail					= nil;	-- 已发送的邮件层
p.pLayerComposeMail					= nil;	-- 撰写邮件层
p.pBtnInbox							= nil;	-- 收件箱按钮
p.pBtnOutbox						= nil;	-- 发件箱按钮
p.pBtnCompose						= nil;	-- 写邮件按钮
--
p.pEditName							= nil;	-- 名字编辑框
p.pEditSubject						= nil;	-- 主题编辑框
p.pEditContent						= nil;	-- 内容编辑框

---------------------------------------------------
-- 菜单按钮控件ID
local ID_BTN_CLOSE					= 6;	-- X
local ID_BTN_INBOX					= 3;	-- 收件箱
local ID_BTN_OUTBOX					= 4;	-- 发件箱
local ID_BTN_COMPOSE				= 5;	-- 写邮件

-- 收件箱的列表控件ID
-- 发件箱的列表控件ID
local ID_LIST_MAILS					= 1;	-- 邮件列表控件ID

local ID_BTN_CHOOSE_ALL				= 7;	-- 选择全部
local ID_BTN_DELETE					= 10;	-- 删除

-- 列表项控件ID
local ID_ITEM_BTN_CHOOSE			= 11;	-- 复选按钮
local ID_ITEM_BTN_TOUCH				= 10;	-- 触摸按钮(透明)
local ID_ITEM_LABEL_NAME			= 3;	-- 列表项-
local ID_ITEM_LABEL_SUBJECT			= 4;	-- 列表项-主题
local ID_ITEM_LABEL_DATE			= 5;	-- 列表项-删除时间
local ID_ITEM_PIC_READED			= 6;	-- 未读图片标识

-- 写邮件界面控件ID
local ID_EDIT_INPUT_NAME			= 20;	-- 编辑控件-名字
local ID_EDIT_INPUT_SUBJECT			= 21;	-- 编辑控件-主题
local ID_EDIT_INPUT_CONTENT			= 22;	-- 编辑控件-内容
local ID_BTN_FRIEND_LIST			= 8;	-- 按钮-好友列表
local ID_BTN_SEND					= 10;	-- 按钮-发送

-- 阅读邮件界面控件ID
local ID_READ_LABEL_NAME			= 10;	-- 名
local ID_READ_LABEL_SUBJECT			= 11;	-- 标题
local ID_READ_LABEL_CONTENT			= 12;	-- 内容
local ID_READ_BTN_BACK				= 13;	-- 返回
local ID_READ_BTN_REPLY				= 35;	-- 回复

---------------------------------------------------
local szSEND_ERROR_00				= "收件人不可为空！";
local szSEND_ERROR_01				= "主题不可为空！"
local szSEND_ERROR_02				= "内容不可为空！"


---------------------------------------------------
-- 各UI层标签
local TAG_LAYER_INBOX				= 100;	-- 收件箱界面
local TAG_LAYER_OUTBOX				= 101;	-- 发件箱界面
local TAG_LAYER_COMPOSE				= 102	-- 写邮件界面
local TAG_LAYER_MENU				= 103;
local TAG_LAYER_DISP_RECEIVED_MAIL	= 104;	-- 显示收件箱收到的邮件
local TAG_LAYER_DISP_SENT_MAIL		= 105;	-- 显示发件箱已发的邮件

---------------------------------------------------
local NAME_LENGTH_LIMIT				= 16;	-- 收件人限制字数
local SUBJECT_LENGTH_LIMIT			= 20;	-- 主题限制字数
local CONTENT_LENGTH_LIMIT			= 255;	-- 内容限制字数


---------------------------------------------------
function p.LoadUI()	
	--LogInfo( "EmailList: LoadUI()" );
	local scene = GetSMGameScene();
	if not CheckP(scene) then
	LogInfo( "EmailList: loadUserEmailList failed! scene is nil" );
		return false;
	end   
	 
	local layer = createNDUILayer();
	if not CheckP(layer) then
		LogInfo( "EmailList: loadUserEmailList failed! layer is nil" );
		return false;
	end
	layer:Init();
	layer:SetTag( NMAINSCENECHILDTAG.EmailList );
	layer:SetPopupDlgFlag( true );
	layer:SetFrameRect( RectFullScreenUILayer );
	scene:AddChildZ( layer, 1 );

	local uiLoad = createNDUILoad();
	if ( nil == uiLoad ) then
		layer:Free();
		LogInfo( "EmailList: loadUserEmailList failed! uiLoad is nil" );
		return false;
	end
	uiLoad:Load( "MailBoxUI_Main.ini", layer, p.OnUIEventMain, 0, 0 );
	uiLoad:Free();
	

   		
	--p.pUILayer = layer;
	--
	--local pic_id	= 2;
	--local pNode = GetUiNode( layer, pic_id );
	
	
 	p.CreateInboxLayer( layer );
 	p.CreateOutboxLayer( layer );
 	p.CreateComposeLayer( layer );
 	p.CreateReadReceivedMail( layer );
 	p.CreateReadSentMail( layer );
 	p.CreateMenuLayer( layer );
	--
	p.RefreshWithButtonTag( ID_BTN_INBOX );
	
    
    

    
	return true;
end

---------------------------------------------------
-- 发邮件-外部调用
function p.SendEmailToFriend( szName )
	if IsUIShow( NMAINSCENECHILDTAG.EmailList ) then
		p.RefreshWithButtonTag( ID_BTN_COMPOSE );
		p.pEditName:SetText( szName );
	else
		p.LoadUI();
		p.RefreshWithButtonTag( ID_BTN_COMPOSE );
		p.pEditName:SetText( szName );
	end
end

---------------------------------------------------
-- 主界面事件响应
function p.OnUIEventMain( uiNode, uiEventType, param )
	local tag = uiNode:GetTag();
	LogInfo("EmailList: p.OnUIEventMain[%d]",tag);
	if ( uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK ) then
		if ( ID_BTN_CLOSE == tag ) then
			local scene = GetSMGameScene();
			if ( scene ~= nil ) then
				scene:RemoveChildByTag( NMAINSCENECHILDTAG.EmailList, true );
				return true;
			end
		elseif ( ID_BTN_INBOX == tag ) then
		elseif ( ID_BTN_OUTBOX == tag ) then
		elseif ( ID_BTN_COMPOSE == tag ) then
		end
	end
	return true;
end

---------------------------------------------------
-- 创建菜单界面
function p.CreateMenuLayer( pParentLayer )
	if ( nil == pParentLayer ) then
		return false;
	end
	 
	local layer = createNDUILayer();
	if not CheckP(layer) then
		LogInfo( "EmailList: CreateMenuLayer failed! layer is nil" );
		return false;
	end
	layer:Init();
	layer:SetTag( TAG_LAYER_MENU );
	--layer:SetFrameRect( RectFullScreenUILayer );
	layer:SetFrameRect( CGRectMake( 0, 0, RectFullScreenUILayer.size.w, 100 ) );
	pParentLayer:AddChildZ( layer, 4 );
	--pParentLayer:AddChild( layer );

	local uiLoad = createNDUILoad();
	if ( nil == uiLoad ) then
		layer:Free();
		LogInfo( "EmailList: CreateMenuLayer failed! uiLoad is nil" );
		return false;
	end
	uiLoad:Load( "MailBoxUI_Menu.ini", layer, p.OnUIEventMenu, 0, 0 );
	uiLoad:Free();
	
	p.pBtnInbox		= GetButton( layer, ID_BTN_INBOX );
	p.pBtnOutbox	= GetButton( layer, ID_BTN_OUTBOX );
	p.pBtnCompose	= GetButton( layer, ID_BTN_COMPOSE );
	
	--设置关闭音效
   	local closeBtn=GetButton(layer,ID_BTN_CLOSE);
   	closeBtn:SetSoundEffect(Music.SoundEffect.CLOSEBTN);
   	
   	
	return true;
end

---------------------------------------------------
-- 菜单界面事件响应
function p.OnUIEventMenu( uiNode, uiEventType, param )
	local tag = uiNode:GetTag();
	--LogInfo("EmailList: p.OnUIEventMenu[%d]",tag);
	if ( uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK ) then
		if ( ID_BTN_CLOSE == tag ) then
			local scene = GetSMGameScene();
			if ( scene ~= nil ) then
				scene:RemoveChildByTag( NMAINSCENECHILDTAG.EmailList, true );
				return true;
			end
		elseif ( ID_BTN_INBOX == tag ) then
			--
			p.RefreshWithButtonTag( ID_BTN_INBOX );
		elseif ( ID_BTN_OUTBOX == tag ) then
			--
			p.RefreshWithButtonTag( ID_BTN_OUTBOX );
		elseif ( ID_BTN_COMPOSE == tag ) then
			--
			p.RefreshWithButtonTag( ID_BTN_COMPOSE );
		end
	end
	return true;
end

-- 刷新以按钮 Tag，（相当于显示哪个选项卡）
function p.RefreshWithButtonTag( nTag )
	if ( ID_BTN_INBOX == nTag ) then
		--
		p.pBtnInbox:SetChecked( true );
		p.pBtnOutbox:SetChecked( false );
		p.pBtnCompose:SetChecked( false );
		p.pLayerInbox:SetVisible( true );
		p.pLayerOutbox:SetVisible( false );
		p.pLayerComposeMail:SetVisible( false );
		p.pLayerReceivedMail:SetVisible( false );
		p.pLayerSentMail:SetVisible( false );
		p.pEditName:SetVisible( false );
		p.pEditSubject:SetVisible( false );
		p.pEditContent:SetVisible( false );
	elseif ( ID_BTN_OUTBOX == nTag ) then
		--
		p.pBtnInbox:SetChecked( false );
		p.pBtnOutbox:SetChecked( true );
		p.pBtnCompose:SetChecked( false );
		p.pLayerInbox:SetVisible( false );
		p.pLayerOutbox:SetVisible( true );
		p.pLayerComposeMail:SetVisible( false );
		p.pLayerReceivedMail:SetVisible( false );
		p.pLayerSentMail:SetVisible( false );
		p.pEditName:SetVisible( false );
		p.pEditSubject:SetVisible( false );
		p.pEditContent:SetVisible( false );
	elseif ( ID_BTN_COMPOSE == nTag ) then
		--
		p.pBtnInbox:SetChecked( false );
		p.pBtnOutbox:SetChecked( false );
		p.pBtnCompose:SetChecked( true );
		p.pLayerInbox:SetVisible( false );
		p.pLayerOutbox:SetVisible( false );
		p.pLayerComposeMail:SetVisible( true );
		p.pLayerReceivedMail:SetVisible( false );
		p.pLayerSentMail:SetVisible( false );
		p.pEditName:SetVisible( true );
		p.pEditSubject:SetVisible( true );
		p.pEditContent:SetVisible( true );
	end
end

---------------------------------------------------
-- 创建收件箱界面
function p.CreateInboxLayer( pParentLayer )
	if ( nil == pParentLayer ) then
		return false;
	end
	 
	local layer = createNDUILayer();
	if not CheckP(layer) then
		LogInfo( "EmailList: CreateInboxLayer failed! layer is nil" );
		return false;
	end
	layer:Init();
	layer:SetTag( TAG_LAYER_INBOX );
	layer:SetFrameRect( RectFullScreenUILayer );
	pParentLayer:AddChildZ( layer, 2 );
	--pParentLayer:AddChild( layer );

	local uiLoad = createNDUILoad();
	if ( nil == uiLoad ) then
		layer:Free();
		LogInfo( "EmailList: CreateInboxLayer failed! uiLoad is nil" );
		return false;
	end
	uiLoad:Load( "MailBoxUI_Inbox.ini", layer, p.OnUIEventInbox, 0, 0 );
	uiLoad:Free();
	
	p.pLayerInbox  = layer;
	
	p.FillInboxList();
	return true;
end

---------------------------------------------------
-- 收件箱界面事件响应
function p.OnUIEventInbox( uiNode, uiEventType, param )
	local tag = uiNode:GetTag();
	if ( uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK ) then
		if ( tag == ID_BTN_DELETE ) then
			-- 删除
			local pListReceivedMails = GetScrollViewContainer( p.pLayerInbox, ID_LIST_MAILS );
			if ( nil ~= pListReceivedMails ) then
				local nListItemAmount = pListReceivedMails:GetViewCount();
				if ( 0 ~= nListItemAmount ) then
					for i = 1, nListItemAmount do
						local pListItem = pListReceivedMails:GetView( i-1 );
						if ( nil ~= pListItem ) then
							local pCheckBox = ConverToCheckBox( GetUiNode ( pListItem, ID_ITEM_BTN_CHOOSE ) );
							if ( nil ~= pCheckBox ) then
								if ( pCheckBox:IsSelect() ) then
									local nEmailID = pListItem:GetTag();
									MsgUserEmail.DelEmail( nEmailID );
								end
							end	
						end
					end
				end
			end
		end
	elseif ( uiEventType == NUIEventType.TE_TOUCH_CHECK_CLICK ) then
		if ( ID_BTN_CHOOSE_ALL == tag ) then
			-- 选择全部
			local pSelectAll = ConverToCheckBox( uiNode );
			if ( pSelectAll:IsSelect() ) then
				local pListReceivedMails = GetScrollViewContainer( p.pLayerInbox, ID_LIST_MAILS );
				if ( nil ~= pListReceivedMails ) then
					local nListItemAmount = pListReceivedMails:GetViewCount();
					if ( 0 ~= nListItemAmount ) then
						for i = 1, nListItemAmount do
							local pListItem = pListReceivedMails:GetView( i-1 );
							if ( nil ~= pListItem ) then
								local pCheckBox = ConverToCheckBox( GetUiNode ( pListItem, ID_ITEM_BTN_CHOOSE ) );
								if ( nil ~= pCheckBox ) then
									pCheckBox:SetSelect( true );
								end	
							end
						end
					end
				end
			else
				local pListReceivedMails = GetScrollViewContainer( p.pLayerInbox, ID_LIST_MAILS );
				if ( nil ~= pListReceivedMails ) then
					local nListItemAmount = pListReceivedMails:GetViewCount();
					if ( 0 ~= nListItemAmount ) then
						for i = 1, nListItemAmount do
							local pListItem = pListReceivedMails:GetView( i-1 );
							if ( nil ~= pListItem ) then
								local pCheckBox = ConverToCheckBox( GetUiNode ( pListItem, ID_ITEM_BTN_CHOOSE ) );
								if ( nil ~= pCheckBox ) then
									pCheckBox:SetSelect( false );
								end	
							end
						end
					end
				end
			end
		end
	end
	return true;
end


---------------------------------------------------
-- 填充收件箱邮件列表框- EmailID来初始化
function p.FillInboxList()
	if ( nil == p.pLayerInbox ) then
		LogInfo( "EmailList: FillInboxList failed! p.pLayerInbox is nil" );
		return false;
	end
	
	local pListReceivedMails = GetScrollViewContainer( p.pLayerInbox, ID_LIST_MAILS );
	if ( nil == pListReceivedMails ) then
		LogInfo( "EmailList: FillInboxList failed! pListReceivedMails is nil" );
		return false;
	end
	
	local layer = createNDUILayer();
	layer:Init();
	local uiLoad=createNDUILoad();
	uiLoad:Load( "MailBoxUI_ListItem.ini", layer, nil, 0, 0 );
	uiLoad:Free();
	local pBorder = GetButton( layer, ID_ITEM_BTN_TOUCH );
	local nHeight = pBorder:GetFrameRect().size.h;
	layer:Free();
		
	pListReceivedMails:SetStyle( UIScrollStyle.Verical );
	pListReceivedMails:SetViewSize( CGSizeMake( pListReceivedMails:GetFrameRect().size.w, nHeight ) );
	pListReceivedMails:ShowViewByIndex(0);
	pListReceivedMails:RemoveAllView();
	
	local tReceiveMails = MsgUserEmail.GetReceivedEmails();
	local nAmount		= table.getn( tReceiveMails );
	if ( ( tReceiveMails == nil ) or ( nAmount == 0 ) ) then
		return false;
	end
	for i=1, nAmount do
		p.CreateListItem( pListReceivedMails, tReceiveMails[i], i, p.OnUIEventReceivedMailsListItem );
	end
	
	return true;
end

---------------------------------------------------
-- 删除收件箱列表项
function p.DeleteInboxListItem( nEmailID )
	if ( nil == p.pLayerInbox ) then
		return false;
	end
	
	local pListReceivedMails = GetScrollViewContainer( p.pLayerInbox, ID_LIST_MAILS );
	if ( nil == pListReceivedMails ) then
		return false;
	end
	
	pListReceivedMails:RemoveViewById( nEmailID );
	
	local nListItemAmount = pListReceivedMails:GetViewCount();
	if ( 0 == nListItemAmount ) then
		local pSelectAll = ConverToCheckBox( GetUiNode ( p.pLayerInbox, ID_BTN_CHOOSE_ALL ) );
		if ( nil ~= pSelectAll ) then
			pSelectAll:SetSelect( false );
		end
	end
end

---------------------------------------------------
-- 创建列表项
function p.CreateListItem( pListContainer, tMail, nIndex, pCallbackFunction  )
	if ( pListContainer == nil ) then
		LogInfo( "EmailList: CreateListItem failed! pListContainer is nil" );
		return false;
	end
	if ( tMail == nil ) then
		LogInfo( "EmailList: CreateListItem failed! tMail is nil" );
		return false;
	end
	
	local pListItem = createUIScrollView();
	if not CheckP( pListItem ) then
		LogInfo( "EmailList: CreateListItem failed! pListItem is nil" );
		return false;
	end
	
	local nEmailType	= tMail[EmailDataIndex.EDI_TYPE];
	local szName		= tMail[EmailDataIndex.EDI_NAME];
	local szSubject		= tMail[EmailDataIndex.EDI_SUBJECT];
	local nSendTime		= tMail[EmailDataIndex.EDI_SENDTIME];
	local nFlag			= tMail[EmailDataIndex.EDI_FLAG];
	local nEmailID		= tMail[EmailDataIndex.EDI_EMAILID];
	local nTime			= nSendTime + 24*60*60*30;-- 失效时间为发送时间加上30天
	local tTime			= os.date( "*t", nTime )
	local szTime		= tTime["year"] .. "年" .. tTime["month"] .. "月" .. tTime["day"] .. "日  ";-- .. tTime["hour"] .. ":" .. tTime["min"];

	pListItem:Init( false );
	pListItem:SetScrollStyle( UIScrollStyle.Verical );
	pListItem:SetViewId( nEmailID );
	pListItem:SetTag( nEmailID );	-- 列表项的 tag 置为 EmailID 
	pListContainer:AddView( pListItem );
		
	local uiLoad = createNDUILoad();
	if nil == uiLoad then
	    layer:Free();
	    return false;
	end
	uiLoad:Load( "MailBoxUI_ListItem.ini", pListItem, pCallbackFunction, 0, 0 );
	uiLoad:Free();
	
	local pLabelName	= GetLabel( pListItem, ID_ITEM_LABEL_NAME );
	local pLabelSubject = GetLabel( pListItem,ID_ITEM_LABEL_SUBJECT );
	local pLabelDate	= GetLabel( pListItem,ID_ITEM_LABEL_DATE );
	local pPicCtrl		= GetUiNode( pListItem, ID_ITEM_PIC_READED );
	
	pLabelName:SetText( szName );
	pLabelSubject:SetText( szSubject );
	pLabelDate:SetText( szTime );
	-- 显示未读标识
	if ( nFlag == 0 ) then
		pPicCtrl:SetVisible( true );
	else
		pPicCtrl:SetVisible( false );
	end
end

---------------------------------------------------
-- 响应收件箱列表项UI事件
function p.OnUIEventReceivedMailsListItem( uiNode, uiEventType, param )
	local tag = uiNode:GetTag();
	local pParentNode = uiNode:GetParent();	--获得控件所在的列表项UI，
	--LogInfo( "EmailList: touch item:%d", uiNode:GetParent() );
	if ( uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK ) then
		if ( tag == ID_ITEM_BTN_TOUCH ) then
			local nEmailID		= pParentNode:GetTag();
			local tReceiveMails = MsgUserEmail.GetReceivedEmails();
			local tEmail		= MsgUserEmail.GetEmail( tReceiveMails, nEmailID );
			local szContent		= tEmail[EmailDataIndex.EDI_CONTENT];
			if ( szContent == nil ) then
				-- 内容为空，发送阅读邮件请求消息
				MsgUserEmail.ReadEmailRequest( nEmailID );
			else
				local szName		= tEmail[EmailDataIndex.EDI_NAME];
				local szSubject		= tEmail[EmailDataIndex.EDI_SUBJECT];
				-- 内容非空，显示
				p.ShowReceivedMail( szName, szSubject, szContent );
			end
			--CommonDlg.ShowWithConfirm( szName.."发来:"..szSubject, nil );
		end
	elseif ( uiEventType == NUIEventType.TE_TOUCH_CHECK_CLICK ) then
		if ( ID_ITEM_BTN_CHOOSE == tag ) then
			local pCheckBox = ConverToCheckBox( uiNode );
			if ( pCheckBox:IsSelect() ) then
				local pListReceivedMails = GetScrollViewContainer( p.pLayerInbox, ID_LIST_MAILS );
				if ( nil ~= pListReceivedMails ) then
					local nListItemAmount = pListReceivedMails:GetViewCount();
					if ( 0 ~= nListItemAmount ) then
						for i = 1, nListItemAmount do
							local pListItem = pListReceivedMails:GetView( i-1 );
							if ( nil ~= pListItem ) then
								local pCheckBox = ConverToCheckBox( GetUiNode ( pListItem, ID_ITEM_BTN_CHOOSE ) );
								if ( nil ~= pCheckBox ) then
									if ( not pCheckBox:IsSelect() ) then
										local pSelectAll = ConverToCheckBox( GetUiNode ( p.pLayerInbox, ID_BTN_CHOOSE_ALL ) );
										if ( nil ~= pSelectAll ) then
											pSelectAll:SetSelect( false );
										end
										return true;
									end
								end	
							end
						end
						local pSelectAll = ConverToCheckBox( GetUiNode ( p.pLayerInbox, ID_BTN_CHOOSE_ALL ) );
						if ( nil ~= pSelectAll ) then
							pSelectAll:SetSelect( true );
						end
					end
				end
			else
				local pSelectAll = ConverToCheckBox( GetUiNode ( p.pLayerInbox, ID_BTN_CHOOSE_ALL ) );
				if ( nil ~= pSelectAll ) then
					pSelectAll:SetSelect( false );
				end
			end
		end
	end
	return true;
end

---------------------------------------------------
-- 创建收件箱邮件界面
function p.CreateReadReceivedMail( pParentLayer )
	if ( nil == pParentLayer ) then
		return false;
	end
	 
	local layer = createNDUILayer();
	if not CheckP(layer) then
		LogInfo( "EmailList: CreateReadReceivedMail failed! layer is nil" );
		return false;
	end
	layer:Init();
	layer:SetTag( TAG_LAYER_DISP_RECEIVED_MAIL );
	layer:SetFrameRect( RectFullScreenUILayer );
	pParentLayer:AddChildZ( layer, 1 );
	--pParentLayer:AddChild( layer );

	local uiLoad = createNDUILoad();
	if ( nil == uiLoad ) then
		layer:Free();
		LogInfo( "EmailList: CreateReadReceivedMail failed! uiLoad is nil" );
		return false;
	end
	uiLoad:Load( "MailBoxUI_ReceivedMail.ini", layer, p.OnUIEventDispInEmail, 0, 0 );
	uiLoad:Free();
	p.pLayerReceivedMail = layer;
	return true;
end

---------------------------------------------------
-- 显示收件箱邮件内容
function p.ShowReceivedMail( szName, szSubject, szContent )
	if ( nil == p.pLayerReceivedMail ) then
		return false;
	end
	local pLabelName = GetLabel( p.pLayerReceivedMail, ID_READ_LABEL_NAME );
	pLabelName:SetText( szName );
	local pLabelSubject = GetLabel( p.pLayerReceivedMail, ID_READ_LABEL_SUBJECT );
	pLabelSubject:SetText( szSubject );
	local pLabelContent = GetLabel( p.pLayerReceivedMail, ID_READ_LABEL_CONTENT );
	pLabelContent:SetText( szContent );
	
	p.pLayerInbox:SetVisible( false );
	p.pLayerReceivedMail:SetVisible( true );
end

---------------------------------------------------
-- 显示收件箱邮件内容界面的事件响应
function p.OnUIEventDispInEmail( uiNode, uiEventType, param )
	local tag = uiNode:GetTag();
	if ( uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK ) then
		if ( tag == ID_READ_BTN_BACK ) then
			-- 按下“返回”
			p.pLayerInbox:SetVisible( true );
			p.pLayerReceivedMail:SetVisible( false );
		elseif ( tag == ID_READ_BTN_REPLY ) then
			local pLabelName = GetLabel( p.pLayerReceivedMail, ID_READ_LABEL_NAME );
			local szName = pLabelName:GetText();
			p.RefreshWithButtonTag( ID_BTN_COMPOSE );
			p.pEditName:SetText( szName );
		end
	end
	return true;
end

---------------------------------------------------
-- 创建发件箱界面
function p.CreateOutboxLayer( pParentLayer )
	if ( nil == pParentLayer ) then
		return false;
	end
	 
	local layer = createNDUILayer();
	if not CheckP(layer) then
		LogInfo( "EmailList: CreateOutboxLayer failed! layer is nil" );
		return false;
	end
	layer:Init();
	layer:SetTag( TAG_LAYER_OUTBOX );
	layer:SetFrameRect( RectFullScreenUILayer );
	pParentLayer:AddChildZ( layer, 2 );
	--pParentLayer:AddChild( layer );

	local uiLoad = createNDUILoad();
	if ( nil == uiLoad ) then
		layer:Free();
		LogInfo( "EmailList: CreateOutboxLayer failed! uiLoad is nil" );
		return false;
	end
	uiLoad:Load( "MailBoxUI_Outbox.ini", layer, p.OnUIEventOutbox, 0, 0 );
	uiLoad:Free();
	
	p.pLayerOutbox  = layer;
	
	p.FillOutboxList();
	return true;
end

---------------------------------------------------
-- 发件箱界面事件响应
function p.OnUIEventOutbox( uiNode, uiEventType, param )
	local tag = uiNode:GetTag();
	if ( uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK ) then
		if ( tag == ID_BTN_DELETE ) then
			-- 删除
			local pListSentMails = GetScrollViewContainer( p.pLayerOutbox, ID_LIST_MAILS );
			if ( nil ~= pListSentMails ) then
				local nListItemAmount = pListSentMails:GetViewCount();
				if ( 0 ~= nListItemAmount ) then
					for i = 1, nListItemAmount do
						local pListItem = pListSentMails:GetView( i-1 );
						if ( nil ~= pListItem ) then
							local pCheckBox = ConverToCheckBox( GetUiNode ( pListItem, ID_ITEM_BTN_CHOOSE ) );
							if ( nil ~= pCheckBox ) then
								if ( pCheckBox:IsSelect() ) then
									local nEmailID = pListItem:GetTag();
									MsgUserEmail.DelEmail( nEmailID );
								end
							end	
						end
					end
				end
			end
		end
	elseif ( uiEventType == NUIEventType.TE_TOUCH_CHECK_CLICK ) then
		if ( ID_BTN_CHOOSE_ALL == tag ) then
			-- 选择全部
			local pSelectAll = ConverToCheckBox( uiNode );
			if ( pSelectAll:IsSelect() ) then
				local pListSentMails = GetScrollViewContainer( p.pLayerOutbox, ID_LIST_MAILS );
				if ( nil ~= pListSentMails ) then
					local nListItemAmount = pListSentMails:GetViewCount();
					if ( 0 ~= nListItemAmount ) then
						for i = 1, nListItemAmount do
							local pListItem = pListSentMails:GetView( i-1 );
							if ( nil ~= pListItem ) then
								local pCheckBox = ConverToCheckBox( GetUiNode ( pListItem, ID_ITEM_BTN_CHOOSE ) );
								if ( nil ~= pCheckBox ) then
									pCheckBox:SetSelect( true );
								end	
							end
						end
					end
				end
			else
				local pListSentMails = GetScrollViewContainer( p.pLayerOutbox, ID_LIST_MAILS );
				if ( nil ~= pListSentMails ) then
					local nListItemAmount = pListSentMails:GetViewCount();
					if ( 0 ~= nListItemAmount ) then
						for i = 1, nListItemAmount do
							local pListItem = pListSentMails:GetView( i-1 );
							if ( nil ~= pListItem ) then
								local pCheckBox = ConverToCheckBox( GetUiNode ( pListItem, ID_ITEM_BTN_CHOOSE ) );
								if ( nil ~= pCheckBox ) then
									pCheckBox:SetSelect( false );
								end	
							end
						end
					end
				end
			end
		end
	end
	return true;
end

---------------------------------------------------
-- 填充发件箱邮件列表框- EmailID来初始化
function p.FillOutboxList()
	if ( nil == p.pLayerInbox ) then
		LogInfo( "EmailList: FillOutboxList failed! p.pLayerInbox is nil" );
		return false;
	end
	
	local pListSentMails = GetScrollViewContainer( p.pLayerOutbox, ID_LIST_MAILS );
	if ( nil == pListSentMails ) then
		LogInfo( "EmailList: FillOutboxList failed! p.pListSentMails is nil" );
		return false;
	end
	local layer = createNDUILayer();
	layer:Init();
	local uiLoad=createNDUILoad();
	uiLoad:Load( "MailBoxUI_ListItem.ini", layer, nil, 0, 0 );
	uiLoad:Free();
	local pBorder = GetButton( layer, ID_ITEM_BTN_TOUCH );
	local nHeight = pBorder:GetFrameRect().size.h;
	layer:Free();
	
	pListSentMails:SetStyle( UIScrollStyle.Verical );
	pListSentMails:SetViewSize( CGSizeMake( pListSentMails:GetFrameRect().size.w, nHeight ) );
	pListSentMails:ShowViewByIndex(0);
	pListSentMails:RemoveAllView();
	
	local tSentMails	= MsgUserEmail.GetSentEmails();
	local nAmount		= table.getn( tSentMails );
	if ( ( tSentMails == nil ) or ( nAmount == 0 ) ) then
		return false;
	end
	for i=1, nAmount do
		p.CreateListItem( pListSentMails, tSentMails[i], i, p.OnUIEventSentMailsListItem );
	end
	
	return true;
end

---------------------------------------------------
-- 删除收件箱列表项
function p.DeleteOutboxListItem( nEmailID )
	if ( nil == p.pLayerInbox ) then
		return false;
	end
	
	local pListSentMails = GetScrollViewContainer( p.pLayerOutbox, ID_LIST_MAILS );
	if ( nil == pListSentMails ) then
		return false;
	end
	
	pListSentMails:RemoveViewById( nEmailID );
	
	local nListItemAmount = pListSentMails:GetViewCount();
	if ( 0 == nListItemAmount ) then
		local pSelectAll = ConverToCheckBox( GetUiNode ( p.pLayerOutbox, ID_BTN_CHOOSE_ALL ) );
		if ( nil ~= pSelectAll ) then
			pSelectAll:SetSelect( false );
		end
	end
end

---------------------------------------------------
-- 响应发件箱列表项UI事件
function p.OnUIEventSentMailsListItem( uiNode, uiEventType, param )
	local tag = uiNode:GetTag();
	local pParentNode = uiNode:GetParent();	--获得控件所在的列表项UI，
	--LogInfo( "EmailList: touch item:%d", uiNode:GetParent() );
	if ( uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK ) then
		if ( tag == ID_ITEM_BTN_TOUCH ) then
			local nEmailID		= pParentNode:GetTag();
			local tSentMails 	= MsgUserEmail.GetSentEmails();
			local tEmail		= MsgUserEmail.GetEmail( tSentMails, nEmailID );
			local szContent		= tEmail[EmailDataIndex.EDI_CONTENT];
			if ( szContent == nil ) then
				-- 内容为空，发送阅读邮件请求消息
				MsgUserEmail.ReadEmailRequest( nEmailID );
			else
				local szName	= tEmail[EmailDataIndex.EDI_NAME];
				local szSubject	= tEmail[EmailDataIndex.EDI_SUBJECT];
				-- 内容非空，显示
				p.ShowSentMail( szName, szSubject, szContent );
			end
		end
	elseif ( uiEventType == NUIEventType.TE_TOUCH_CHECK_CLICK ) then
		if ( ID_ITEM_BTN_CHOOSE == tag ) then
			local pCheckBox = ConverToCheckBox( uiNode );
			if ( pCheckBox:IsSelect() ) then
				local pListSentMails = GetScrollViewContainer( p.pLayerOutbox, ID_LIST_MAILS );
				if ( nil ~= pListSentMails ) then
					local nListItemAmount = pListSentMails:GetViewCount();
					if ( 0 ~= nListItemAmount ) then
						for i = 1, nListItemAmount do
							local pListItem = pListSentMails:GetView( i-1 );
							if ( nil ~= pListItem ) then
								local pCheckBox = ConverToCheckBox( GetUiNode ( pListItem, ID_ITEM_BTN_CHOOSE ) );
								if ( nil ~= pCheckBox ) then
									if ( not pCheckBox:IsSelect() ) then
										local pSelectAll = ConverToCheckBox( GetUiNode ( p.pLayerOutbox, ID_BTN_CHOOSE_ALL ) );
										if ( nil ~= pSelectAll ) then
											pSelectAll:SetSelect( false );
										end
										return true;
									end
								end	
							end
						end
						local pSelectAll = ConverToCheckBox( GetUiNode ( p.pLayerOutbox, ID_BTN_CHOOSE_ALL ) );
						if ( nil ~= pSelectAll ) then
							pSelectAll:SetSelect( true );
						end
					end
				end
			else
				local pSelectAll = ConverToCheckBox( GetUiNode ( p.pLayerOutbox, ID_BTN_CHOOSE_ALL ) );
				if ( nil ~= pSelectAll ) then
					pSelectAll:SetSelect( false );
				end
			end
		end
	end
	return true;
end

---------------------------------------------------
-- 创建收件箱邮件界面
function p.CreateReadSentMail( pParentLayer )
	if ( nil == pParentLayer ) then
		return false;
	end
	 
	local layer = createNDUILayer();
	if not CheckP(layer) then
		LogInfo( "EmailList: CreateReadSentMail failed! layer is nil" );
		return false;
	end
	layer:Init();
	layer:SetTag( TAG_LAYER_DISP_SENT_MAIL );
	layer:SetFrameRect( RectFullScreenUILayer );
	pParentLayer:AddChildZ( layer, 1 );
	--pParentLayer:AddChild( layer );

	local uiLoad = createNDUILoad();
	if ( nil == uiLoad ) then
		layer:Free();
		LogInfo( "EmailList: CreateReadSentMail failed! uiLoad is nil" );
		return false;
	end
	uiLoad:Load( "MailBoxUI_SentMail.ini", layer, p.OnUIEventDispOutEmail, 0, 0 );
	uiLoad:Free();
	p.pLayerSentMail = layer;
	return true;
end

-- 显示收件箱邮件内容
function p.ShowSentMail( szName, szSubject, szContent )
	if ( nil == p.pLayerSentMail ) then
		return false;
	end
	local pLabelName = GetLabel( p.pLayerSentMail, ID_READ_LABEL_NAME );
	pLabelName:SetText( szName );
	local pLabelSubject = GetLabel( p.pLayerSentMail, ID_READ_LABEL_SUBJECT );
	pLabelSubject:SetText( szSubject );
	local pLabelContent = GetLabel( p.pLayerSentMail, ID_READ_LABEL_CONTENT );
	pLabelContent:SetText( szContent );
	
	p.pLayerOutbox:SetVisible( false );
	p.pLayerSentMail:SetVisible( true );
end


---------------------------------------------------
-- 显示发件箱邮件内容界面的事件响应
function p.OnUIEventDispOutEmail( uiNode, uiEventType, param )
	local tag = uiNode:GetTag();
	if ( uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK ) then
		if ( tag == ID_READ_BTN_BACK ) then
			-- 按下“返回”
			p.pLayerOutbox:SetVisible( true );
			p.pLayerSentMail:SetVisible( false );
		end
	end
	return true;
end

---------------------------------------------------
-- 创建发件箱界面
function p.CreateComposeLayer( pParentLayer )
	if ( nil == pParentLayer ) then
		return false;
	end
	 
	local layer = createNDUILayer();
	if not CheckP(layer) then
		LogInfo( "EmailList: CreateComposeLayer failed! layer is nil" );
		return false;
	end
	layer:Init();
	layer:SetTag( TAG_LAYER_COMPOSE );
	layer:SetFrameRect( RectFullScreenUILayer );
	pParentLayer:AddChildZ( layer, 2 );
	--pParentLayer:AddChild( layer );

	local uiLoad = createNDUILoad();
	if ( nil == uiLoad ) then
		layer:Free();
		LogInfo( "EmailList: CreateComposeLayer failed! uiLoad is nil" );
		return false;
	end
	uiLoad:Load( "MailBoxUI_Compose.ini", layer, p.OnUIEventCompose, 0, 0 );
	uiLoad:Free();
	
	-- 名字编辑框
	local pUINode	= GetUiNode( layer, ID_EDIT_INPUT_NAME );
	p.pEditName		= ConverToEdit( pUINode );
	
	-- 标题编辑框
	pUINode			= GetUiNode( layer, ID_EDIT_INPUT_SUBJECT );
	p.pEditSubject	= ConverToEdit( pUINode );
	
	-- 内容编辑框
	pUINode			= GetUiNode( layer, ID_EDIT_INPUT_CONTENT );
	p.pEditContent	= ConverToEdit( pUINode );
	
	p.pEditName:SetMaxLength(NAME_LENGTH_LIMIT);
	--p.pEditName:SetText( "yyaa" );
	p.pEditSubject:SetMaxLength(SUBJECT_LENGTH_LIMIT);
	--p.pEditSubject:SetText( "title" );
	p.pEditContent:SetMaxLength(CONTENT_LENGTH_LIMIT);
	--p.pEditContent:SetText( "Content" );
	
	p.pLayerComposeMail  = layer;
	return true;
end

---------------------------------------------------
-- 写邮件界面事件响应
function p.OnUIEventCompose( uiNode, uiEventType, param )
	
	local tag = uiNode:GetTag();
	LogInfo( "OnUIEventCompose tag:"..tag);
	if ( uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK ) then
		if ( tag == ID_BTN_FRIEND_LIST ) then
			-- 按下“好友列表”
			local scene = GetSMGameScene();
			if ( scene ~= nil ) then
				-- 移除邮箱界面
				scene:RemoveChildByTag( NMAINSCENECHILDTAG.EmailList, true );
			end
			-- 装载好友界面
			if not IsUIShow(NMAINSCENECHILDTAG.Friend) then
				FriendUI.LoadUI();
			end
			return true;
		elseif ( tag == ID_BTN_SEND ) then
			-- 按下“发送”
			-- 判发件箱满/
			local szName	= p.pEditName:GetText();
			local szSubject	= p.pEditSubject:GetText();
			local szContent	= p.pEditContent:GetText();
			if ( "" == szName ) then
				CommonDlg.ShowWithConfirm( szSEND_ERROR_00, nil );
			elseif ( "" == szSubject ) then
				CommonDlg.ShowWithConfirm( szSEND_ERROR_01, nil );
			elseif ( "" == szContent ) then
				CommonDlg.ShowWithConfirm( szSEND_ERROR_02, nil );
			else
				--CommonDlg.ShowWithConfirm( "发送中", nil );
				MsgUserEmail.SendLetter( szName, szContent, szSubject );
			end
		end
    elseif ( uiEventType == NUIEventType.TE_TOUCH_EDIT_INPUT_FINISH ) then
	end
	return true;
end

---------------------------------------------------
-- 阅读邮件
function p.ShowEmail( tMail )
	local nEmailType	= tMail[EmailDataIndex.EDI_TYPE];
	local szName		= tMail[EmailDataIndex.EDI_NAME];
	local szSubject		= tMail[EmailDataIndex.EDI_SUBJECT];
	local nFlag			= tMail[EmailDataIndex.EDI_FLAG];
	local nEmailID		= tMail[EmailDataIndex.EDI_EMAILID];
	local szContent		= tMail[EmailDataIndex.EDI_CONTENT];
	if ( nEmailType == EmailType.ET_RECEIVED ) then
		-- 收件
		p.ShowReceivedMail( szName, szSubject, szContent );
		local pListReceivedMails = GetScrollViewContainer( p.pLayerInbox, ID_LIST_MAILS );
		if ( nil ~= pListReceivedMails ) then
			local pListItem = pListReceivedMails:GetViewById( nEmailID );
			if ( nil ~= pListItem ) then
				local pPicCtrl		= GetUiNode( pListItem, ID_ITEM_PIC_READED );
				pPicCtrl:SetVisible( false );
			end
		end
	else
		-- 发件
		p.ShowSentMail( szName, szSubject, szContent );
	end
end


-- 删邮件，删除显示的记录
function p.Callback_DeleteRecord( nEmailID, nEmailType )
	if ( EmailType.ET_RECEIVED == nEmailType ) then
		-- 收件
		p.DeleteInboxListItem( nEmailID );
	else
		-- 发件
		p.DeleteOutboxListItem( nEmailID );
	end
end


---------------------------------------------------
-- 刷新收件列表
function p.RefreshReceivedMailList()
	return p.FillInboxList();
end

---------------------------------------------------
-- 刷新发件列表
function p.RefreshSentMailList()
	return p.FillOutboxList();
end

---------------------------------------------------
-- 发送成功回调
function p.Callback_SendLetterSuccess()
	p.pEditName:SetText( "" );
	p.pEditSubject:SetText( "" );
	p.pEditContent:SetText( "" );
	p.RefreshWithButtonTag( ID_BTN_OUTBOX );
end

---------------------------------------------------
-- 显示查看邮件失败（确认按钮）……

-- 显示发送中（无按钮）……
-- 显示发送失败，及失败原因（确认按钮）……
-- 显示发送成功（确认按钮）……

-- 正在删除中……
-- 显示删除成功（确认按钮）……
-- 显示删除失败，及失败原因（确认按钮）……


---------------------------------------------------


