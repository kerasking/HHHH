--描述: 处理副本相关消息
--时间: 2012.4.9
--作者: cl
---------------------------------------------------

MsgDynMap = {}
local p = MsgDynMap;


function p.SendDynMapQuit()
	local netdata = createNDTransData(NMSG_Type._MSG_INSANCING_LEAVE);
	if nil == netdata then
		return false;
	end
	SendMsg(netdata);
	netdata:Free();
end

function p.SendDynMapGuide(round,nTypeId)
	LogInfo("sendGuide:%d",round);
	local netdata = createNDTransData(NMSG_Type._MSG_INSTANCING_BATTLE_LOG);
	if nil == netdata then
		return false;
	end
	netdata:WriteByte(round);
    netdata:WriteInt(nTypeId);
	SendMsg(netdata);
	netdata:Free();
end

function p.ProcessDynMapGuide(netdata)
	if not IsUIShow(NMAINSCENECHILDTAG.DynMapGuide) then
		DynMapGuide.LoadUI();
	end
	local count=netdata:ReadByte();
	for i=1,count do
		local id=netdata:ReadInt();
		local name=netdata:ReadUnicodeString();
		local level=netdata:ReadInt();
		LogInfo("guide_info%d"..name.."lv:%d",id,level);
		DynMapGuide.setContent(i,id,name,level);
	end
end


RegisterNetMsgHandler(NMSG_Type._MSG_INSTANCING_BATTLE_LOG, "p.ProcessDynMapGuide", p.ProcessDynMapGuide);