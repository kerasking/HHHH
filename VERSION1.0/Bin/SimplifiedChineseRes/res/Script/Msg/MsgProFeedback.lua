---------------------------------------------------
--描述: 问题反馈
--时间: 2012.5.28
--作者: LLF
---------------------------------------------------

MsgProFeedback = {}
local p = MsgProFeedback;

--发送问题反馈消息
function p.SendProFeedback(proType, content)
LogInfo("proType= %d, content= %s ", proType, content);
	local netdata = createNDTransData(NMSG_Type._MSG_GM_MAIL);
	if nil == netdata then
		return false;
	end

	netdata:WriteByte(proType);
	netdata:WriteStr(content);
	
	SendMsg(netdata);
	netdata:Free();
	ShowLoadBar();
	LogInfo("SendPro send end......")
	return true;
end

function p.ProcessProFeedback(netdatas)
	LogInfo("p.ProcessProFeedback....")
	CloseLoadBar();
	if nil == netdatas then
		LogInfo("nil == netdatas")
		return false;
	end
	--scene:RemoveChildByTag(NMAINSCENECHILDTAG.ProblemUI, true);
	--CommonDlg.ShowTipInfo("提示", "提交成功，感谢您的反馈！", nil, 2);
	CommonDlgNew.ShowYesDlg( "提交成功，感谢您的反馈！", nil, nil, 2);
	
	_G.MsgProFeedback.CheckProFeedback();
									  
	LogInfo("p.ProcessProFeedback end....")
	
	return true;
end

--查看问题
function p.CheckProFeedback()
LogInfo("p.CheckProFeedback() begin")
	local netdata = createNDTransData(NMSG_Type._MSG_GM_MAIL_LIST);
	if nil == netdata then
		return false;
	end
	
	SendMsg(netdata);
	netdata:Free();
	ShowLoadBar();
	LogInfo("Check send end......")
	return true;
end

function p.ProcessCheckProFeedback(netdatas)
LogInfo("p.ProcessCheckProFeedback....")
	CloseLoadBar();
	if nil == netdatas then
		LogInfo("nil == netdatas")
		return false;
	end
	local count=netdatas:ReadByte();
	LogInfo("count= %d", count)
	
	if not IsUIShow(NMAINSCENECHILDTAG.GMProblemUI) then
		GMProblemUI.LoadUI();
		
	end
	
	GMProblemUI.ShowLayer(0);
		
	--清空信息
	GMProblemUI.ResetContent();
	
	
	for i=1, count do
		local enquire = netdatas:ReadUnicodeString();  --询问内容
		local reply = netdatas:ReadUnicodeString();    --反馈内容

		
		if nil == reply then
			GMProblemUI.AddTextContent(GMProblemUI.sendContent.strPlayerName, enquire, 
									  GMProblemUI.sendContent.gm, GMProblemUI.sendContent.gmTipsMsg);
		else
			GMProblemUI.sendContent.gmTipsMsg = reply;
			GMProblemUI.AddTextContent(GMProblemUI.sendContent.strPlayerName, enquire, 
									  GMProblemUI.sendContent.gm, GMProblemUI.sendContent.gmTipsMsg);
		end
	end
	
	
	
	LogInfo("p.ProcessCheckProFeedback end....")
end

RegisterNetMsgHandler(NMSG_Type._MSG_GM_MAIL, "p.ProcessProFeedback", p.ProcessProFeedback);
RegisterNetMsgHandler(NMSG_Type._MSG_GM_MAIL_LIST, "p.ProcessCheckProFeedback", p.ProcessCheckProFeedback);


