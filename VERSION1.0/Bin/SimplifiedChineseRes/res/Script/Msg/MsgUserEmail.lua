---------------------------------------------------
--描述: 邮件的网络消息处理
--时间: 2012.6.8
--作者: Guosen
---------------------------------------------------

MsgUserEmail = {}
local p = MsgUserEmail;

---------------------------------------------------
local LETTER_EXIST						= 0;	-- 初连服务器，所有邮件
local LETTER_NEW						= 1;	-- 已连服务器，新邮件

--
local LETTER_LOOK						= 0;	-- 查看邮件
local LETTER_ATTACH_ACCEPT				= 1;	-- 接收附件
local LETTER_ATTACH_REJECT				= 2;	-- 拒收附件
local LETTER_DEL						= 3;	-- 删除邮件

--
local ATTACH_ACCEPT_NOT_ENOUGH_MONEY	= 1;	-- 银币不足
local ATTACH_ACCEPT_NOT_ENOUGH_EMONEY	= 2;	-- 金币不足
local ATTACH_ACCEPT_BAG_FULL			= 3;	-- 背包已满
local ATTACH_ACCEPT_FAIL				= 4;	-- 其它异常引起的失败
local ATTACH_REJECT_SUCCESS				= 5;	-- 拒收成功
local ATTACH_REJECT_SYSTEM_NOT_ALLOWED	= 6;	-- 系统附件不允许拒收
local ATTACH_REJECT_FAIL				= 7;	-- 其它异常引起的失败
local LETTER_DEL_SUCCESS				= 8;	-- 删除邮件成功
local LETTER_DEL_ATTACH_NOT_ALLOW		= 9;	-- 有附件禁止删除
local LETTER_DEL_FAIL					= 10;	-- 其它异常引起的失败

-- 发送邮件时的返回结果
local SEND_LETTER_SUCCESS				= 1;
local NAME_IS_NOT_EXSITED				= 2;
local NAME_IS_SELF						= 3;
local MAILBOX_IS_FULL					= 4;

local szSEND_LETTER_SUCCESS				= GetTxtPri("MUE2_T1");
local szNAME_IS_NOT_EXSITED				= GetTxtPri("MUE2_T2");
local szNAME_IS_SELF					= GetTxtPri("MUE2_T3");
local szMAILBOX_IS_FULL					= GetTxtPri("MUE2_T4");

-- 邮件类型
EmailType = {
	ET_RECEIVED		= 0,	-- 收到的邮件
	ET_SENT			= 1,	-- 发送的邮件
};
-- Email 数据 字段索引
EmailDataIndex = {
	EDI_TYPE		= 1,	-- 邮件类型，收/发(EmailType.ET_RECEIVED/EmailType.ET_SENT)
	EDI_SENDTIME	= 2,	-- 失效时间
	EDI_NAME		= 3,	-- 发/收件人
	EDI_SUBJECT		= 4,	-- 主题
	EDI_CONTENT		= 5,	-- 内容
	EDI_FLAG		= 6,	-- 标志(0未读，1已读)
	EDI_EMAILID		= 7,
};

---------------------------------------------------
--p.tEmails	= nil;--p.tEmail={};p.tEmail[nUserID]={};p.tEmail[nUserID][ET_RECEIVED]={};p.tEmail[nUserID][ET_SENT]={};
p.tReceivedEmails	= {};
p.tSentEmails	= {};


----测试邮件功能自定义数据
----{ EmailID, Time, Name, Subject, Content }
--local tMails = {
--	{ 1, 0, "2012.12.21", "Xiaoli", "Hello 2012", "2012终于来了～～" },
--	{ 2, 0, "2012.12.21", "Lilei", "I'm fine, thank you, and you?", "如题" },
--	{ 3, 0, "2012.12.21", "韩MM", "就不告诉你", "……" },
--	{ 4, 1, "2012.12.21", "Xiaoli", "Hello 2013", "眺望2013～～" },
--	{ 5, 1, "2012.12.21", "Lilei", "How are you?", "嘿～" },
--	{ 6, 1, "2012.12.21", "韩MM", "告诉我你的生日吧", "如题" },
--	{ 7, 1, "2012.12.21", "Lilei", "....", "美国太空总署（NASA）每两年会进行一轮公开透明的宇航员征募，你可以在NASA的网站上查阅到相关的招聘信息。如果你想应征宇航员，必须在www.usajobs.gov政府网站上填妥相关的171表格（政府就业申请）。" },
--};

---------------------------------------------------
--function p.Clear()
--	p.tEmail = nil;
--end

-- 获取收件箱邮件（已收到的）
function p.GetReceivedEmails()
	return p.tReceivedEmails;
end

--
function p.GetEmail( tEmails, nEmailID )
	if ( tEmails == nil or nEmailID == nil ) then
		return nil;
	end
	for i,v in pairs( tEmails ) do
		if ( v[EmailDataIndex.EDI_EMAILID]	== nEmailID ) then
			return v;
		end
	end
	return nil;
end

-- 获取发件箱邮件（已发送的）
function p.GetSentEmails()
	return p.tSentEmails;
end

---------------------------------------------------
-- 响应服务器消息-收到邮件信息
function p.ProcessReceivedLetter( netdata ) 
	LogInfo( "MsgUserEmail: ProcessReceivedLetter"  );
	local m			= netdata:ReadByte();  
	local btAction	= BitwiseAnd( m, 3 );-- 0:init 1:new
	if ( btAction == 0 ) then
		p.tReceivedEmails	= {};
		p.tSentEmails	= {};
	end
	local nCount	= RightShift( m, 2 );
	local nRoleId	= ConvertN( GetPlayerId() );
	local nReceivedMailCount	= 0;	-- 收到的邮件计数
	local nSentMailCount		= 0;	-- 发送的邮件计数
	for i = 1, nCount do
		local nEmailID		= netdata:ReadInt();
		local nSendTime		= netdata:ReadInt();-- 要转成 XXXX年XX月XX日形式
		local nAttachState	= netdata:ReadByte();
		local nEmailType	= netdata:ReadByte();
		local szSubject		= netdata:ReadUnicodeString();
		local szName		= netdata:ReadUnicodeString();
		local nFlag			= netdata:ReadByte();--

		--LogInfo( "MsgUserEmail: EmailId:%d, SendTime:%d, AttachState:%d, EmailType:%d, Name:%s, Subject:%s, nFlag:%d", 
		--			nEmailID, nSendTime, nAttachState, nEmailType, szName, szSubject, nFlag  );
		tMail = {};
		tMail[EmailDataIndex.EDI_TYPE]		= nEmailType;
		tMail[EmailDataIndex.EDI_NAME]		= szName;
		tMail[EmailDataIndex.EDI_SUBJECT]	= szSubject;
		tMail[EmailDataIndex.EDI_SENDTIME]	= nSendTime;
		tMail[EmailDataIndex.EDI_FLAG]		= nFlag;
		tMail[EmailDataIndex.EDI_EMAILID]	= nEmailID;
		if ( nEmailType == EmailType.ET_RECEIVED ) then
			nReceivedMailCount = nReceivedMailCount + 1;
			table.insert( p.tReceivedEmails, tMail );
		elseif ( nEmailType == EmailType.ET_SENT ) then
			nSentMailCount = nSentMailCount + 1;
			table.insert( p.tSentEmails, tMail );
		end
		
		-- 收到底邮件有未读邮件
		if ( ( nEmailType == EmailType.ET_RECEIVED ) and ( nFlag == 0 ) ) then
			local pBtnNewEmail = MainUI.GetNewEmailButton();
			if ( pBtnNewEmail ~= nil ) then
				pBtnNewEmail:SetVisible( true );
			end
		end
		--
	end
	LogInfo( "MsgUserEmail: ProcessReceivedLetter btAction:%d, nReceivedMailCount:%d, nSentMailCount:%d",btAction,nReceivedMailCount,nSentMailCount  );
	if ( nReceivedMailCount > 0 ) then
		table.sort( p.tReceivedEmails, p.SortBySendTimeFlag );--==
		if IsUIShow( NMAINSCENECHILDTAG.EmailList ) then
			EmailList.RefreshReceivedMailList();
		end
	end
	if ( nSentMailCount > 0 ) then
		--p.Sort( p.tSentEmails, p.SortBySendTime );--
		table.sort( p.tSentEmails, p.SortBySendTime );
		if IsUIShow( NMAINSCENECHILDTAG.EmailList ) then
			EmailList.RefreshSentMailList();
		end
	end
			
	--if ( LETTER_EXIST == btAction ) then
	--	-- 初次连接服务器，此时邮箱UI未开启
	--elseif ( LETTER_NEW == btAction ) then
	--	-- 已连接服务器后，有新邮件来，
	--end
	-- 测试用
end

---------------------------------------------------
--- 按时间和未读标志排序（时间降序，未读升序） 函数子
function p.SortBySendTimeFlag( a, b )
	if ( a[EmailDataIndex.EDI_SENDTIME] >= b[EmailDataIndex.EDI_SENDTIME] ) then
		return ( a[EmailDataIndex.EDI_FLAG] <= b[EmailDataIndex.EDI_FLAG] );
	else
		return ( a[EmailDataIndex.EDI_FLAG] < b[EmailDataIndex.EDI_FLAG] );
	end
end

--- 仅按时间先后排序（降序） 函数子
function p.SortBySendTime( a, b )
	return ( a[EmailDataIndex.EDI_SENDTIME] >= b[EmailDataIndex.EDI_SENDTIME] );
end

-- 按未读标志排序（升序） 函数子
function p.SortByEmailFlag( a, b )
	return ( a[EmailDataIndex.EDI_FLAG] <= b[EmailDataIndex.EDI_FLAG] );
end
-- function ( a, b ) return ( a[EmailDataIndex.EDI_FLAG] <= b[EmailDataIndex.EDI_FLAG] ) end

-- 排序
-- 待排序的表，函数子
function p.Sort( tTable, pFunction )
	if ( tTable == nil ) then
		LogInfo( "MsgUserEmail: Sort tTable == nil" );
	end
	if ( pFunction == nil ) then
		LogInfo( "MsgUserEmail: Sort pFunction == nil" );
		return;
	end
	local nAmount = table.getn( tTable );
	if ( nAmount <= 1 ) then
		return;
	end
	for i=1, nAmount-1 do
		for j=i, nAmount-1 do
			local tA = tTable[j];
			local tB = tTable[j+1];
			if ( not pFunction( tA, tB ) ) then
				tTable[j]	= tB;
				tTable[j+1]	= tA;
			end
		end
	end
end

---------------------------------------------------
-- 响应服务器消息-邮件信息
function p.ProcessLetterInfo( netdata ) 
    CloseLoadBar();
	local nEmailID		= netdata:ReadInt();
	local nEmailType	= netdata:ReadByte();
	local btLetterInfo	= netdata:ReadByte();
	local szContent		= netdata:ReadUnicodeString();
	local tMail			= nil;
	if ( nEmailType == EmailType.ET_RECEIVED ) then
		for i, v in pairs( p.tReceivedEmails ) do
			if ( v[EmailDataIndex.EDI_EMAILID]	== nEmailID ) then
				local bSort = ( p.tReceivedEmails[i][EmailDataIndex.EDI_FLAG] == 0 );
				p.tReceivedEmails[i][EmailDataIndex.EDI_FLAG]		= 1;
				p.tReceivedEmails[i][EmailDataIndex.EDI_CONTENT]	= szContent;
				tMail	= p.tReceivedEmails[i];
				if ( bSort ) then
					table.sort( p.tReceivedEmails, p.SortBySendTimeFlag );--==
				end
				break;
			end
		end
	else
		for i, v in pairs( p.tSentEmails ) do
			if ( v[EmailDataIndex.EDI_EMAILID]	== nEmailID ) then
				p.tSentEmails[i][EmailDataIndex.EDI_CONTENT]	  = szContent;
				tMail	= p.tSentEmails[i];
				break;
			end
		end
	end
	
	-- 邮箱UI开启...
	if IsUIShow( NMAINSCENECHILDTAG.EmailList ) then
		if ( nEmailType == EmailType.ET_RECEIVED ) then
			EmailList.RefreshReceivedMailList();
		end
		EmailList.ShowEmail( tMail );
	end
	
	--
	if ( nEmailType == EmailType.ET_RECEIVED ) then
		local pBtnNewEmail = MainUI.GetNewEmailButton();
		if ( pBtnNewEmail ~= nil ) then
			if ( p.IsHaveNewEmail() ) then
				pBtnNewEmail:SetVisible( true );
			else
				pBtnNewEmail:SetVisible( false );
			end
		end
	end
end

---------------------------------------------------
-- 响应服务器消息-邮件请求
function p.ProcessLetterRequest( netdata ) 
    CloseLoadBar();
	LogInfo( "MsgUserEmail: ProcessLetterRequest" );
	local nEmailID		= netdata:ReadInt();
	local nEmailType	= netdata:ReadByte();
	local action		= netdata:ReadByte();
	LogInfo( "MsgUserEmail: nEmailID:%d, nEmailType:%d, action:%d",nEmailID,nEmailType,action );
	if ( LETTER_DEL_SUCCESS == action ) then
		-- 删除邮件成功
		if ( nEmailType == EmailType.ET_RECEIVED ) then
			for i, v in pairs( p.tReceivedEmails ) do
				if ( v[EmailDataIndex.EDI_EMAILID]	== nEmailID ) then
					table.remove( p.tReceivedEmails, i );
					break;
				end
			end
		else
			for i, v in pairs( p.tSentEmails ) do
				if ( v[EmailDataIndex.EDI_EMAILID]	== nEmailID ) then
					table.remove( p.tSentEmails, i );
					break;
				end
			end
		end
		--邮箱UI开启
		if IsUIShow( NMAINSCENECHILDTAG.EmailList ) then
			EmailList.Callback_DeleteRecord( nEmailID, nEmailType );
		end
	elseif ( LETTER_DEL_FAIL == action ) then
		-- 删除邮件失败
		--邮箱UI开启
	end
	--
	local pBtnNewEmail = MainUI.GetNewEmailButton();
	if ( pBtnNewEmail ~= nil ) then
		if ( p.IsHaveNewEmail() ) then
			pBtnNewEmail:SetVisible( true );
		else
			pBtnNewEmail:SetVisible( false );
		end
	end
end

---------------------------------------------------
-- 响应服务器消息-发邮件
function p.ProcessSendLetter( netdata )
	LogInfo( "MsgUserEmail: ProcessSendLetter" );
    CloseLoadBar();
    local btAttachState	= netdata:ReadByte(); 
    local nEmailID		= netdata:ReadInt(); 
	local nResult		= netdata:ReadByte();
	LogInfo( "MsgUserEmail: nEmailID:%d, nResult:%d",nEmailID,nResult );
	if ( nResult == SEND_LETTER_SUCCESS ) then
		CommonDlgNew.ShowYesDlg( szSEND_LETTER_SUCCESS, nil, nil, 3 );
		if IsUIShow( NMAINSCENECHILDTAG.EmailList ) then
			-- 发送成功清空写邮件界面
			EmailList.Callback_SendLetterSuccess();
		end
	elseif ( nResult == NAME_IS_NOT_EXSITED ) then
		CommonDlgNew.ShowYesDlg( szNAME_IS_NOT_EXSITED, nil, nil, 3 );
	elseif ( nResult == NAME_IS_SELF ) then
		CommonDlgNew.ShowYesDlg( szNAME_IS_SELF, nil, nil, 3 );
	elseif ( nResult == MAILBOX_IS_FULL ) then
		CommonDlgNew.ShowYesDlg( szMAILBOX_IS_FULL, nil, nil, 3 );
	end
end

---------------------------------------------------
-- 发消息给服务端-发邮件
function p.SendLetter( szName, szContent, szSubject )
	local netdata		= createNDTransData( NMSG_Type._MSG_SENDLETTER );
	if ( nil == netdata ) then
		LogInfo( "MsgUserEmail: SendLetter failed" );
		return false;
	end  
	--LogInfo( "MsgUserEmail: Name:%s, Subject:%s, Content:%s", szName, szSubject, szContent );
	local btAttachState	= 0;
	netdata:WriteByte( btAttachState );
	netdata:WriteStr( szName );
	netdata:WriteStr( szContent );
	netdata:WriteStr( szSubject );
	SendMsg( netdata );
	netdata:Free();
    ShowLoadBar();
	return true;
end

---------------------------------------------------
-- 发消息给服务端-删邮件
function p.DelEmail( nEmailID )
	LogInfo( "MsgUserEmail: DelEmail nEmailID:%d",nEmailID );
	local netdata = createNDTransData( NMSG_Type._MSG_LETTER_REQUEST );
	if ( nil == netdata ) then
		LogInfo( "MsgUserEmail: DelEmail failed" );
		return false;
	end  
	netdata:WriteInt( nEmailID );
	netdata:WriteInt( LETTER_DEL );
	SendMsg( netdata );
	netdata:Free();
    ShowLoadBar();
	return true;
end

-- 发消息给服务端-读邮件
function p.ReadEmailRequest( nEmailID )
	local netdata = createNDTransData( NMSG_Type._MSG_LETTER_REQUEST );
	if ( nil == netdata ) then
		LogInfo( "MsgUserEmail: DelEmail failed" );
		return false;
	end  
	netdata:WriteInt( nEmailID );
	netdata:WriteInt( LETTER_LOOK );
	SendMsg( netdata );
	netdata:Free();
    ShowLoadBar();
	return true;
end


-- 是否有未读的收到的邮件
function p.IsHaveNewEmail()
	if ( ( p.tReceivedEmails == nil ) or ( table.getn( p.tReceivedEmails ) == 0 ) ) then
		return false;
	end
	
	for nIndex, tEmail in pairs( p.tReceivedEmails ) do
		if ( tEmail[EmailDataIndex.EDI_FLAG] == 0 ) then
			return true;
		end
	end
	return false;
end

---------------------------------------------------

RegisterNetMsgHandler( NMSG_Type._MSG_RECEIED_LETTER, "p.ProcessReceiedLetter", p.ProcessReceivedLetter );
RegisterNetMsgHandler( NMSG_Type._MSG_LETTER_INFO, "p.ProcessLetterInfo", p.ProcessLetterInfo );
RegisterNetMsgHandler( NMSG_Type._MSG_LETTER_REQUEST, "p.ProcessLetterRequest", p.ProcessLetterRequest );
RegisterNetMsgHandler( NMSG_Type._MSG_SENDLETTER, "p.ProcessSendLetter", p.ProcessSendLetter );


