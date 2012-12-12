---------------------------------------------------
--描述: 在线签到活动
--时间: 2012.9.4
--作者: qbw
---------------------------------------------------
OnlineCheckIn = {}
local p = OnlineCheckIn;

local g_Count = 0;
local g_GiftMark = 255;
local g_bIfShow = false;
p.TimerTag = nil;

--领取礼包
function p.GetGift()
	p.SendGetGift();
end

--是否显示按钮
function p.IsFunctionOpen()
	if g_bIfShow then
		LogInfo("qboy IsFunctionOpen true"); 
		return g_bIfShow;
	else
		LogInfo("qboy IsFunctionOpen false"); 
		return g_bIfShow;
	end
end

--获取按钮
function p.GetBtn()
	local layer = MainUI.GetTopBar();
	
	if CheckP(layer) == false then
		LogInfo("qboy MainUI.GetTopBar() nil"); 
		return nil;
	end
	
	local btnOL = 	GetButton(layer,39);
	
	
	if CheckP(btnOL) == false then
		LogInfo("qboy btnOL nil"); 
		return nil;
	end
	
	return btnOL;
end

--获取计时器label
function p.GetCDLabel()
	
	local layer = MainUI.GetTopBar();
	
	if CheckP(layer) == false then
		LogInfo("qboy MainUI.GetTopBar() nil"); 
		return nil;
	end
	
	local btnOL = 	GetButton(layer,39);
	
	
	if CheckP(btnOL) == false then
		LogInfo("qboy btnOL nil"); 
		return nil;
	end
	
	
	local label = RecursiveLabel(btnOL, {99});
	
	if CheckP(label) == false then
		LogInfo("qboy label nil"); 
	
		return nil;
	end

	return label;
end




--更新倒计时
function p.updateCount(restCount)
	g_Count = restCount;
	LogInfo("qboy updateCount restCount:"..restCount); 
		
	local CDlabel = p.GetCDLabel();
	
    if CDlabel ~= nil then
        LogInfo("qboy CDlabel nil:"); 
        if restCount <= 0 then
            CDlabel:SetText(GetTxtPri("OCI_ClickGet"));
        else

            CDlabel:SetText(FormatTime(restCount,1));
        end	
    end


	if p.TimerTag ~= nil then
		UnRegisterTimer(p.TimerTag);
	end
	
	if restCount > 0 then
		LogInfo("qboy RegisterTimer TimerTick"); 
		p.TimerTag=RegisterTimer(p.TimerTick,1, "OnlineCheckIn.TimerTick");
	end

end


function p.TimerTick(tag)
	if tag == p.TimerTag then
		g_Count = g_Count - 1;

		--刷新计数文字
		if g_Count <= 0 then
			g_Count = 0;
		end

		if g_GiftMark >= 255 then
			g_bIfShow = false;
		else
			g_bIfShow = true;
		end
		
		local CDLabel = p.GetCDLabel();

		if CDLabel ~= nil then
			CDLabel:SetText(FormatTime(g_Count,1));
		end
		
		
		if g_Count <= 0 then
            LogInfo("qboy TimerTick UnRegisterTimer(p.TimerTag)"); 
			UnRegisterTimer(p.TimerTag);
			p.TimerTag = nil;
			--CDLabel:SetText(GetTxtPri("OCI_ClickGet"));
			
			if CDLabel ~= nil then
				CDLabel:SetText(GetTxtPri("OCI_ClickGet"));
			end
		end		
	end
end

--处理网络数据 p1:上次领取时间 p2领取标识 p3倒计时数（秒）
function p.ProccessNetMsg(nParam1,nParam2,nParam3)
	
	
	LogInfo("qboy ProccessNetMsg nParam1,nParam2,nParam3:"..nParam1.." "..nParam2.." "..nParam3); 
	

	
	g_GiftMark = nParam2;
	
	--所有都领取则返回
	if nParam2 >= 255 then
		--隐藏按钮
		g_bIfShow = false
		return;
	end
	
	
	g_bIfShow = true;
	--添加倒计时
	p.updateCount(nParam3)
	MainUI.RefreshFuncIsOpen();
	
	
end

--刷新cd时间
function p.RefreshTimeLabel()

		--全部领完则消失 否则显示
        if g_GiftMark >= 255 then
                --隐藏按钮
				g_bIfShow = false;
				
                return;
        else
				g_bIfShow = true;
				
        end
        
		
		if g_Count <= 0 then
			g_Count = 0;
		end
		
		local CDLabel = p.GetCDLabel();
		
		
		if g_Count <= 0 then
			CDLabel:SetText(GetTxtPri("OCI_ClickGet"));
		else
			CDLabel:SetText(FormatTime(g_Count,1));
		end	
		
		MainUI.RefreshFuncIsOpen();
end


local tStage = {}
tStage[1]=1
tStage[2]=2
tStage[3]=4
tStage[4]=8
tStage[5]=16
tStage[6]=32
tStage[7]=64
tStage[8]=128


--获取奖励阶段 0表示未领取任何奖励
function p.GetStage(nMark)
	local result = 1;
	for stage = 7,1,-1 do	
		if nMark - 2^(stage-1) >= 0 then
		--if nMark - tStage[stage] >= 0 then
			--该stage已领取;
			return stage;	
		end
	end
	return 0;
end


--发送领取消息 
function p.SendGetGift()  
    LogInfo("qboy p.SendGetGift "); 
	local nStage = p.GetStage(g_GiftMark); 
    if nStage == 8 then
    	 LogInfo("qboy p.SendGetGift 今日礼包已全部取完"); 
    	return;
    end
    
    
	local netdata = createNDTransData(NMSG_Type._MSG_PLAYER_ACTION_OPERATE);
    
     LogInfo("qboy p.SendGetGift nStage g_GiftMark"..nStage.." "..g_GiftMark); 
    netdata:WriteByte(2);
    netdata:WriteInt(nStage + 1);	
    netdata:WriteInt(0);	
    netdata:WriteInt(0);	
    netdata:WriteInt(0);	
    
	SendMsg(netdata);	
	netdata:Free();	
    LogInfo("qboy p.SendGetGift  end"); 
	return true;	
end


--重置数据
function p.ResetData()
	 g_Count = 0;
	 g_GiftMark = 255;
	 g_bIfShow = false;
	 		
	if p.TimerTag ~= nil then
		UnRegisterTimer(p.TimerTag);
		p.TimerTag = nil;
	end		
end

--城市ID
p.RuoYanCityId = 1;
p.ChangAnCityId = 2;

p.RuoYanCity = {
    NMAINSCENECHILDTAG.AffixNormalBoss,
    NMAINSCENECHILDTAG.AffixBossClearUp,
    NMAINSCENECHILDTAG.AffixBossClearUpElite,
    NMAINSCENECHILDTAG.bossUI,
    NMAINSCENECHILDTAG.WorldMap,
};

--是否在主城
function p.InInCity()
    if(p.RuoYanCityId == GetMapId() or p.ChangAnCityId == GetMapId()) then
        if(p.IsShowLayer(p.RuoYanCity)) then
            return false;
        else
            
            local scene = GetSMGameScene();
            if(scene) then
                local bs = GetUiLayer(scene,NMAINSCENECHILDTAG.BottomSpeedBar);
                if(bs) then
                    if(bs:IsVisibled()) then
                        return true;
                    end
                end
            end
            
            return false;
        end
    end
    return false;
end

function p.IsShowLayer(arrays)
    for i,v in ipairs(arrays) do
        local isShow = IsUIShow(v);
        if(isShow) then
            LogInfo("p.IsShowLayer Tag:[%d]",v);
            return true;
        end
    end
    return false;
end


RegisterGlobalEventHandler(GLOBALEVENT.GE_GENERATE_GAMESCENE, "OnlineCheckIn.RefreshTimeLabel", p.RefreshTimeLabel);
_G.RegisterGlobalEventHandler(_G.GLOBALEVENT.GE_LOGIN_GAME, "OnlineCheckIn.ResetData", p.ResetData);

