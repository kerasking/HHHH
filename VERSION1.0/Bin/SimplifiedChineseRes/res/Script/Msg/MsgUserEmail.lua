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

-- 邮件类型
EmailType = {
	ET_RECIVED		= 0;	-- 收到的邮件
	ET_SENT			= 1;	-- 发送的邮件
};
-- Email 数据 字段索引
EmailDataIndex = {
	EDI_TYPE		= 0;	-- 邮件类型，收/发(EmailType.ET_RECIVED/EmailType.ET_SENT)
	EDI_FAILTIME	= 1;	-- 失效时间
	EDI_NAME		= 2;	-- 发/收件人
	EDI_SUBJECT		= 3;	-- 主题
	EDI_CONTENT		= 4;	-- 内容
	EDI_FLAG		= 5;	-- 标志(0未读，1已读)
};
		
---------------------------------------------------
-- 响应服务器消息-收到邮件
function p.ProcessReceivedLetter( netdata ) 
    CloseLoadBar();
	--LogInfo( "MsgUserEmail: p.ProcessReceivedLetter(netdata)"  );
	local m			= netdata:ReadByte();  
	local btAction	= BitwiseAnd( m, 3 );  
	local nCount	= RightShift( m, 2 );
	local nRoleId	= ConvertN( GetPlayerId() );
	for i = 1, nCount do
		local nEmailID		= netdata:ReadInt();
		local nSendTime		= netdata:ReadInt();-- 要转成 XXXX年XX月XX日形式
		local nAttachState	= netdata:ReadByte();
		local nEmailType	= netdata:ReadByte();
		local szSubject		= netdata:ReadUnicodeString();
		local szName		= netdata:ReadUnicodeString();
		local szContent		= "";
		local nTime = nSendTime + 24*60*60*30;-- 失效时间为发送时间加上30天
		local tTime = os.date( "*t", nTime )
		local szTime = tTime["year"] .. "年" .. tTime["month"] .. "月" .. tTime["day"] .. "日  ";-- .. tTime["hour"] .. ":" .. tTime["min"];
		local nFlag			= netdata:ReadByte();--

		SetGameDataS( NScriptData.eRole, nRoleId, NRoleData.eUserEmail, nEmailID, EmailDataIndex.EDI_TYPE, SafeN2S(nEmailType) );
		SetGameDataS( NScriptData.eRole, nRoleId, NRoleData.eUserEmail, nEmailID, EmailDataIndex.EDI_NAME, szName );
		SetGameDataS( NScriptData.eRole, nRoleId, NRoleData.eUserEmail, nEmailID, EmailDataIndex.EDI_SUBJECT, szSubject );
		SetGameDataS( NScriptData.eRole, nRoleId, NRoleData.eUserEmail, nEmailID, EmailDataIndex.EDI_FAILTIME, szTime );
		SetGameDataS( NScriptData.eRole, nRoleId, NRoleData.eUserEmail, nEmailID, EmailDataIndex.EDI_CONTENT, szContent );
		SetGameDataS( NScriptData.eRole, nRoleId, NRoleData.eUserEmail, nEmailID, EmailDataIndex.EDI_FLAG, SafeN2S(nFlag) );
		--LogInfo( "MsgUserEmail: EmailId:%d, SendTime:%d, AttachState:%d, EmailType:%d, Name:%s, Subject:%s", 
		--			nEmailID, nSendTime, nAttachState, nEmailType, szName, szSubject  );
		--LogInfo( "MsgUserEmail: Name:" .. szName  );
		
		-- 邮箱UI开启...
		if IsUIShow( NMAINSCENECHILDTAG.EmailList ) then
			EmailList.Callback_AppendRecord( nEmailID, nEmailType );
		end
		-- 未读？
		if ( ( nEmailType == 0 ) and ( nFlag == 0 ) ) then
			local pBtnNewEmail = MainUI.GetNewEmailButton();
			if ( pBtnNewEmail ~= nil ) then
				pBtnNewEmail:SetVisible( true );
			end
		end
		--
	end
	--if ( LETTER_EXIST == btAction ) then
	--	-- 初次连接服务器，此时邮箱UI未开启
	--elseif ( LETTER_NEW == btAction ) then
	--	-- 已连接服务器后，有新邮件来，
	--end
	-- 测试用
	--p.FillTestData();
end

--测试邮件功能自定义数据
p.tMails = {
	{ 1, 0, "2012.12.21", "Xiaoli", "Hello 2012", "2012终于来了～～" },
	{ 2, 0, "2012.12.21", "Lilei", "I'm fine, thank you, and you?", "如题" },
	{ 3, 0, "2012.12.21", "韩MM", "就不告诉你", "……" },
	{ 4, 1, "2012.12.21", "Xiaoli", "Hello 2013", "眺望2013～～" },
	{ 5, 1, "2012.12.21", "Lilei", "How are you?", "嘿～" },
	{ 6, 1, "2012.12.21", "韩MM", "告诉我你的生日吧", "如题" },
	{ 7, 1, "2012.12.21", "Lilei", "....", "美国太空总署（NASA）每两年会进行一轮公开透明的宇航员征募，你可以在NASA的网站上查阅到相关的招聘信息。如果你想应征宇航员，必须在www.usajobs.gov政府网站上填妥相关的171表格（政府就业申请）。" },
};
--{ EmailID, Time, Name, Subject, Content }
--装入测试数据
function p.FillTestData()
	local nRoleId		= ConvertN( GetPlayerId() );
	local nEmailsAmount = table.getn( p.tMails );
		
	for i = 1 , nEmailsAmount do
		local nEmailID		= p.tMails[i][1];
		local nEmailType	= p.tMails[i][2];
		local szSendTime	= p.tMails[i][3];
		local szName		= p.tMails[i][4];
		local szSubject		= p.tMails[i][5];
		local szContent		= p.tMails[i][6];
		
		SetGameDataS( NScriptData.eRole, nRoleId, NRoleData.eUserEmail, nEmailID, EmailDataIndex.EDI_TYPE, SafeN2S(nEmailType) );
		SetGameDataS( NScriptData.eRole, nRoleId, NRoleData.eUserEmail, nEmailID, EmailDataIndex.EDI_FAILTIME, szSendTime );
		SetGameDataS( NScriptData.eRole, nRoleId, NRoleData.eUserEmail, nEmailID, EmailDataIndex.EDI_NAME, szName );
		SetGameDataS( NScriptData.eRole, nRoleId, NRoleData.eUserEmail, nEmailID, EmailDataIndex.EDI_SUBJECT, szSubject );
		SetGameDataS( NScriptData.eRole, nRoleId, NRoleData.eUserEmail, nEmailID, EmailDataIndex.EDI_CONTENT, szContent );
	end
	
end

---------------------------------------------------
-- 响应服务器消息-邮件信息
function p.ProcessLetterInfo( netdata ) 
    CloseLoadBar();
	local nRoleId	= ConvertN( GetPlayerId() );
	local nEmailID	= netdata:ReadInt();
	local uFailTime = netdata:ReadInt();
	local btLetterInfo = netdata:ReadByte(); 
	local szContent	= netdata:ReadUnicodeString();	 
	SetGameDataS( NScriptData.eRole, nRoleId, NRoleData.eUserEmail, nEmailID, EmailDataIndex.EDI_CONTENT, szContent );
	SetGameDataS( NScriptData.eRole, nRoleId, NRoleData.eUserEmail, nEmailID, EmailDataIndex.EDI_FLAG, "1" );
	-- 邮箱UI开启...
	if IsUIShow( NMAINSCENECHILDTAG.EmailList ) then
		EmailList.ReadEmail( nEmailID );
	end
	--
	if ( p.IsHaveNewEmail() ) then
		local pBtnNewEmail = MainUI.GetNewEmailButton();
		if ( pBtnNewEmail ~= nil ) then
			pBtnNewEmail:SetVisible( true );
		end
	else
		local pBtnNewEmail = MainUI.GetNewEmailButton();
		if ( pBtnNewEmail ~= nil ) then
			pBtnNewEmail:SetVisible( false );
		end
	end
end

---------------------------------------------------
-- 响应服务器消息-邮件请求
function p.ProcessLetterRequest( netdata ) 
    CloseLoadBar();
	LogInfo( "MsgUserEmail: ProcessLetterRequest" );
	local nEmailID	= netdata:ReadInt();
	local action	= netdata:ReadByte();
	if ( LETTER_DEL_SUCCESS == action ) then
		-- 删除邮件成功
		local nRoleId		= ConvertN( GetPlayerId() );
		local szEmailType	= GetGameDataS( NScriptData.eRole, nRoleId, NRoleData.eUserEmail, nEmailID, EmailDataIndex.EDI_TYPE );
		DelRoleSubGameDataById( NScriptData.eRole, nRoleId, NRoleData.eUserEmail, nEmailID );
		--邮箱UI开启
		if IsUIShow( NMAINSCENECHILDTAG.EmailList ) then
			EmailList.Callback_DeleteRecord( nEmailID, szEmailType );
		end
	elseif ( LETTER_DEL_FAIL == action ) then
		-- 删除邮件失败
		--邮箱UI开启
	end
	--
	if ( p.IsHaveNewEmail() ) then
		local pBtnNewEmail = MainUI.GetNewEmailButton();
		if ( pBtnNewEmail ~= nil ) then
			pBtnNewEmail:SetVisible( true );
		end
	else
		local pBtnNewEmail = MainUI.GetNewEmailButton();
		if ( pBtnNewEmail ~= nil ) then
			pBtnNewEmail:SetVisible( false );
		end
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
	LogInfo( "MsgUserEmail: Name:%s, Subject:%s, Content:%s", szName, szSubject, szContent );
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

-- 发消息给服务端-删邮件
function p.DelEmail( nEmailID )
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
	local nRoleId		= ConvertN( GetPlayerId() );
	local tEmailIDList	= GetGameDataIdList( NScriptData.eRole, nRoleId, NRoleData.eUserEmail );
	local nEmailAmount	= table.getn( tEmailIDList );
	if ( 0 == nEmailAmount ) then
		return false;
	end
	
	for nIndex, nEmailID in ipairs( tEmailIDList ) do
		local szEmailType	= GetGameDataS( NScriptData.eRole, nRoleId, NRoleData.eUserEmail, nEmailID, EmailDataIndex.EDI_TYPE );
		local szFlag		= GetGameDataS( NScriptData.eRole, nRoleId, NRoleData.eUserEmail, nEmailID, EmailDataIndex.EDI_FLAG );
		if ( ( szEmailType == "0" ) and ( szFlag == "0" ) ) then
			return true;
		end
	end
	return false;
end

---------------------------------------------------

RegisterNetMsgHandler( NMSG_Type._MSG_RECEIED_LETTER, "p.ProcessReceiedLetter", p.ProcessReceivedLetter );
RegisterNetMsgHandler( NMSG_Type._MSG_LETTER_INFO, "p.ProcessLetterInfo", p.ProcessLetterInfo );
RegisterNetMsgHandler( NMSG_Type._MSG_LETTER_REQUEST, "p.ProcessLetterRequest", p.ProcessLetterRequest );


