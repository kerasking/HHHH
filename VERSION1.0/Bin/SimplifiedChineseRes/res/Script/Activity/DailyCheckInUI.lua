---------------------------------------------------
--描述: 每日签到界面
--时间: 2012.8.30
--作者: tzq
---------------------------------------------------
DailyCheckInUI = {}
local p = DailyCheckInUI;


p.CheckInBtnId = {13, 14, 15, 16, 17, 101, 102, 103, 104, 105,  Reset = 33, Close = 533};

p.UiCtrId = {VipText = 27, VipFinPic = 106, ResetText = 34, ResetBtn = 33, RechargeBtn = 26,};

p.CheckInImgIndex = {{18, 11, 12, 22,},            --第一天(图片控件id, 未领取, 领取, 已领取）
                                      {19, 11, 13, 23,},             --第二天
                                      {20, 11, 14, 24,},             --第三天zheg
                                      {21, 11, 31, 41,},             --第四天
                                      {22, 11, 32, 42,},             --第五天
                                      {44, 11, 33, 43,},             --vip
                                      };
p.BoxAwardInfo = {};     

                        
p.ImgFileName = "CheckInBtnImg";   --宝箱图片                                      

p.BtnCheckInFlag = { 0, 0, 0, 0, 0,};
p.VipCheckInFlag = 0;

p.PreCheckInTime = 0;
p.CurCheckInTime = 0;

--加载每日签到主界面
function p.LoadUI()
   
    --------------------获得游戏主场景------------------------------------------
    local scene = GetSMGameScene();	
	if scene == nil then
		return;
	end
    
    --------------------添加每日签到层（窗口）---------------------------------------
    local layer = createNDUILayer();
	if layer == nil then
		return false;
	end
    
    layer:SetPopupDlgFlag( true );
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.DailyCheckIn);
	layer:SetFrameRect(RectFullScreenUILayer);
	--scene:AddChildZ(layer, 2);
	scene:AddChildZ(layer,UILayerZOrder.NormalLayer );
    
    local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end
	uiLoad:Load("CheckIn.ini", layer, p.OnUIEvent, 0, 0);

    ------------------------------------初始化数据------------------------------------------------------------------
    
    p.InitData();
    --刷新显示
    p.Refresh();
    
    return true;
end


function p.InitData()
	if RechargeReward.GetIfNeedDown() then
		p.InitDataWhenDown();
	else
		p.InitDataWhenReadDb();
	end
end


function  p.InitDataWhenDown()
    p.BoxAwardInfo = {};    

    if RechargeReward.EventConfig ~= nil then
        table.sort(RechargeReward.EventConfig, function(a,b) return a.Id < b.Id   end);
    end 
    
    if RechargeReward.EventReward ~= nil then
        table.sort(RechargeReward.EventReward, function(a,b) return a.Id < b.Id   end);
    end 
    
    p.BoxAwardInfo.Normal = {};
    p.BoxAwardInfo.Vip = {};   
    
    for i, v in pairs(RechargeReward.EventConfig) do
        --获取活动的类型
        local nType = v.Type;
        
		if nType == MsgPlayerAction.PLAYER_ACTION_TYPE.VIP_CHECK_IN then
			for j, k in pairs(RechargeReward.EventReward) do
                local Config_id = k.IdEventConfig;
				if v.Id == Config_id then
					table.insert(p.BoxAwardInfo.Vip, k);
                end
            end  
		end
		
        if nType == MsgPlayerAction.PLAYER_ACTION_TYPE.CHECK_IN  then  --登入签到
             for j, k in pairs(RechargeReward.EventReward) do
             
                local Config_id = k.IdEventConfig;
				
				if v.Id == Config_id then
                    table.insert(p.BoxAwardInfo.Normal, k);
                end
             end  
            
        end
    end
end

function  p.InitDataWhenReadDb()
    p.BoxAwardInfo = {};    

    local idCofigs = GetDataBaseIdList("event_config");
    local idAwards = GetDataBaseIdList("event_award");
    
    if idCofigs ~= nil then
        table.sort(idCofigs, function(a,b) return a < b   end);
    end 
    
    if idAwards ~= nil then
        table.sort(idAwards, function(a,b) return a < b   end);
    end 
    
    p.BoxAwardInfo.Normal = {};
    p.BoxAwardInfo.Vip = {};   
    
    for i, v in pairs(idCofigs) do
        --获取活动的类型
        local nType = GetDataBaseDataN("event_config", v, DB_EVENT_CONFIG.TYPE);
        
        if nType == MsgPlayerAction.PLAYER_ACTION_TYPE.CHECK_IN  then  --登入签到
             for j, k in pairs(idAwards) do
                local Config_id = GetDataBaseDataN("event_award", k, DB_EVENT_AWARD.CONFIG_ID);
                if v == Config_id then
                    local Record = {}; 
                    Record.Stage = GetDataBaseDataN("event_award", k, DB_EVENT_AWARD.STAGE);                --阶段
                    Record.StageCondition  = GetDataBaseDataN("event_award", k, DB_EVENT_AWARD.STAGE_CONDITION);    --阶段条件
                    Record.ItemType = GetDataBaseDataN("event_award", k, DB_EVENT_AWARD.ITEM_TYPE);  --奖励物品类型
                    Record.ItemCount = GetDataBaseDataN("event_award", k, DB_EVENT_AWARD.ITEM_AMOUNT);  --物品数
                    Record.Emoney= GetDataBaseDataN("event_award", k, DB_EVENT_AWARD.EMONEY);                --金币
                    Record.Stamina = GetDataBaseDataN("event_award", k, DB_EVENT_AWARD.STAMINA);  --军令
                    Record.Money = GetDataBaseDataN("event_award", k, DB_EVENT_AWARD.MONEY);  --银币  
                    Record.Soph = GetDataBaseDataN("event_award", k, DB_EVENT_AWARD.SOPH);                --将魂
                    Record.Repute = GetDataBaseDataN("event_award", k, DB_EVENT_AWARD.REPUTE);  --声望
                    
                    LogInfo("initdata Stage = %d", Record.Stage);
                    table.insert(p.BoxAwardInfo.Normal, Record);
                elseif 100000 == Config_id then
                    local Record = {}; 
                    Record.Stage = GetDataBaseDataN("event_award", k, DB_EVENT_AWARD.STAGE);                --阶段
                    Record.StageCondition  = GetDataBaseDataN("event_award", k, DB_EVENT_AWARD.STAGE_CONDITION);    --阶段条件
                    Record.ItemType = GetDataBaseDataN("event_award", k, DB_EVENT_AWARD.ITEM_TYPE);  --奖励物品类型
                    Record.ItemCount = GetDataBaseDataN("event_award", k, DB_EVENT_AWARD.ITEM_AMOUNT);  --物品数
                    Record.Emoney= GetDataBaseDataN("event_award", k, DB_EVENT_AWARD.EMONEY);                --金币
                    Record.Stamina = GetDataBaseDataN("event_award", k, DB_EVENT_AWARD.STAMINA);  --军令
                    Record.Money = GetDataBaseDataN("event_award", k, DB_EVENT_AWARD.MONEY);  --银币  
                    Record.Soph = GetDataBaseDataN("event_award", k, DB_EVENT_AWARD.SOPH);                --将魂
                    Record.Repute = GetDataBaseDataN("event_award", k, DB_EVENT_AWARD.REPUTE);  --声望
                    
                    LogInfo("initdata Stage = %d", Record.Stage);
                    table.insert(p.BoxAwardInfo.Vip, Record);
                end
                
            end  
            
            break;
       end
    end
end
-----------------------------获取父层layer---------------------------------
function p.GetParent()

	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end
	
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.DailyCheckIn);
	if nil == layer then
		return nil;
	end
	
	return layer;
end
-----------------------------背景层事件处理---------------------------------
function p.OnUIEvent(uiNode, uiEventType, param)

    local tag = uiNode:GetTag();
    LogInfo("p.OnUIEvent hit tag = %d", tag);
    
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
        
        --关闭按钮      
        if p.CheckInBtnId.Close == tag then                
			CloseUI(NMAINSCENECHILDTAG.DailyCheckIn);
        elseif  p.CheckInBtnId.Reset == tag then  
            p.SendReset();
        elseif  p.UiCtrId.RechargeBtn == tag then  
            PlayerVIPUI.LoadUI();    
        else
        
            for i, v in pairs(p.CheckInImgIndex) do
                LogInfo("v[%d] = %d, tag = %d", i, v[1], tag);
                if v[1] == tag then
                    local str = p.GetAwardStr(i);
                    CommonDlgNew.ShowYesDlg( str, nil, nil, 3 );
                    break;
                end
            end
        
            local btnNum = 5;
            for i = 1, btnNum do
                if p.CheckInBtnId[i] == tag then
                    p.SendCheckIn(i);
                    break;
                end            
            end
        end
    end
    
	return true;
end



-----------------------------获取某一天的奖励信息--------------------------------
function  p.GetAwardStr(nDayIndex)
    LogInfo("p.GetAwardStr  nDayIndex = %d", nDayIndex);
    
    local Info = {};
    if nDayIndex <= 5 then
        Info = p.BoxAwardInfo.Normal[nDayIndex];
    else 
        local CurVipLev = GetRoleBasicDataN( GetPlayerId(), USER_ATTR.USER_ATTR_VIP_RANK );
        if CurVipLev == 0 then
            CurVipLev = 1;
        end
        Info = p.BoxAwardInfo.Vip[CurVipLev];
    end
    
    if Info == nil then
        LogInfo("nil");
        return "";
    end
    LogInfo("p.GetAwardStr  nDayIndex = %d", nDayIndex);
    
    local ShowText = "";
    
    --奖励物品
    if (Info.ItemType ~= 0) and  (Info.ItemCount ~= 0) then
        ShowText = ShowText .. ItemFunc.GetName(Info.ItemType) .."X"..Info.ItemCount.."\n";
    end
    --金币
    if Info.Emoney ~= 0 then
        ShowText = ShowText ..GetTxtPub("shoe").."X"..Info.Emoney.."\n";
    end
    --军令
    if Info.Stamina ~= 0 then
        ShowText = ShowText ..GetTxtPub("Stamina").."X"..Info.Stamina.."\n";
    end
    --银币
    if Info.Money ~= 0 then
        ShowText = ShowText ..GetTxtPub("coin").."X"..Info.Money.."\n";
    end
    --将魂
    if Info.Soph ~= 0 then
        ShowText = ShowText ..GetTxtPub("JianHun").."X"..Info.Soph.."\n";
    end
    --声望
    if Info.Repute ~= 0 then
        ShowText = ShowText ..GetTxtPub("ShenWan").."X"..Info.Repute.."\n";
    end  

    return ShowText;
end

-----------------------------通过服务器下发的消息设置页面的显示---------------------------------
--iPreTime最近一个的签到时间, iData总共4个字节,32位,1到5位分别表示第一天到第五天的签到情况 0:未签到 1:已签到  iCurTime服务器当前时间
function p.SetUiInfo(iPreTime, iData, iCurTime)

      LogInfo("p.SetUiInfo iPreTime = %d, iData = %d, iCurTime = %d", iPreTime, iData, iCurTime);
            
     --取得时间间隔
     p.PreCheckInTime = iPreTime;
     p.CurCheckInTime = iCurTime;  
     
    local temp = iData;
    
    for i = 5, 1, -1 do
        local num1 = 1;
        for j = i - 1, 1, -1 do
            num1 = num1*2;
        end
        LogInfo("i = %d, num1 = %d,  ", i, num1);
        
        local num2 = math.floor(temp/num1);
        p.BtnCheckInFlag[i] =  num2;
        LogInfo("i = %d, num1 = %d, temp = %d,  num2 = %d", i, num1, temp, num2);
        if num2 > 0 then
            temp = temp - num1;
        end
    end
    
    for i, v in pairs(p.BtnCheckInFlag) do
        LogInfo("p.SetUiInfo p.BtnCheckInFlag[%d] = %d", i, p.BtnCheckInFlag[i]);
    end
    
    p.Refresh();
end

---------------------------获取当前的vip等级,显示内容以及图片-----iState 1:当前有显示签到或者续签的时候 2:签到或者续签点击之后-----------------------------

function  p.ShowVipContentAndPic()
    LogInfo("tangziqin showvip begin");
    local layer = p.GetParent();
    
    local N_W = 120;
	local N_H = 120;
    local pool = _G.DefaultPicPool();

    --获取当前vip等级
    local CurVipLev = GetRoleBasicDataN( GetPlayerId(), USER_ATTR.USER_ATTR_VIP_RANK );
    --local btnPic = GetImage(layer, p.CheckInImgIndex[6][1]);
    local btnPic = GetButton(layer, p.CheckInImgIndex[6][1]);  
    local PicFinish = GetImage(layer, p.UiCtrId.VipFinPic);    
    LogInfo("tangziqin showvip CurVipLev = %d, p.VipCheckInFlag = %d, btnId = %d", CurVipLev, p.VipCheckInFlag, p.CheckInImgIndex[6][1]);
    --vip为0级的默认显示
    if CurVipLev == 0 then  
        SetLabel(layer, p.UiCtrId.VipText, GetTxtPri("DCI_v1"));
        local nRow			= _G.Num2(p.CheckInImgIndex[6][2]);
        local nCol			= _G.Num1(p.CheckInImgIndex[6][2]);
        local nCutX		= N_W*(nCol - 1);
        local nCutY		= N_H*(nRow - 1);
        local Pic = pool:AddPicture( _G.GetSMImgPath( "action/"..p.ImgFileName..".png" ), false);  
        Pic:Cut( _G.CGRectMake( nCutX, nCutY, N_W, N_H ) );
        --btnPic:SetPicture(Pic);
        btnPic:SetImage(Pic);
        PicFinish:SetVisible(false);
        return;
    end
    
    --有签到或者续签的时候
    if p.VipCheckInFlag == 1 then
        SetLabel(layer, p.UiCtrId.VipText, GetTxtPri("DCI_v2")..CurVipLev..GetTxtPri("DCI_v3")..CurVipLev..GetTxtPri("DCI_v4"));
        local nRow			= _G.Num2(p.CheckInImgIndex[6][3]);
        local nCol			= _G.Num1(p.CheckInImgIndex[6][3]);
        local nCutX		= N_W*(nCol - 1);
        local nCutY		= N_H*(nRow - 1);
        LogInfo("tangziqin nRow = %d, nCol = %d, nCutX = %d, nCutY = %d", nRow, nCol, nCutX, nCutX);
        local Pic = pool:AddPicture( _G.GetSMImgPath( "action/"..p.ImgFileName..".png" ), false);  
        Pic:Cut( _G.CGRectMake( nCutX, nCutY, N_W, N_H ) );
        btnPic:SetImage(Pic);
        --btnPic:SetPicture(Pic);
        PicFinish:SetVisible(false);
    elseif p.VipCheckInFlag == 2 then
        SetLabel(layer, p.UiCtrId.VipText, GetTxtPri("DCI_v2")..CurVipLev..GetTxtPri("DCI_v3")..CurVipLev..GetTxtPri("DCI_v4"));
        local nRow			= _G.Num2(p.CheckInImgIndex[6][4]);
        local nCol			= _G.Num1(p.CheckInImgIndex[6][4]);
        local nCutX		= N_W*(nCol - 1);
        local nCutY		= N_H*(nRow - 1);
        local Pic = pool:AddPicture( _G.GetSMImgPath( "action/"..p.ImgFileName..".png" ), false);  
        Pic:Cut( _G.CGRectMake( nCutX, nCutY, N_W, N_H ) );
        btnPic:SetImage(Pic);
        --btnPic:SetPicture(Pic);
        PicFinish:SetVisible(true);
    end
end
---------------------------按钮重置功能-------------------------------------------------
function p.Refresh()
    LogInfo("function p.Refresh() begin");
    --如果每日签到页面打开着,那么重新刷新
    if not IsUIShow(NMAINSCENECHILDTAG.DailyCheckIn) then 
        return;
    end
    
    local layer = p.GetParent();
    local btnReset = GetButton(layer, p.UiCtrId.ResetBtn);
    local LableReset = GetLabel(layer, p.UiCtrId.ResetText); 
    btnReset:SetVisible(false);
    LableReset:SetVisible(false);
        
    local iTimelast = p.GetTiemLast(p.PreCheckInTime, p.CurCheckInTime);
    if p.PreCheckInTime  == 0 or iTimelast >= 3 then
        p.Reset();
    end
    
    local N_W = 120;
	local N_H = 120;
    local pool = _G.DefaultPicPool();

    --按照标志位先标示上已签到跟未签到
    for i, v in pairs(p.BtnCheckInFlag) do
         local btn = GetButton(layer, p.CheckInBtnId[i]);
         local btnPic = GetButton(layer, p.CheckInImgIndex[i][1]);  
         local PicFinish = GetImage(layer, p.CheckInBtnId[i + 5]);    
         if btnPic == nil then
            return;
         end

         if v ~= 0 then
            btn:SetTitle(GetTxtPri("DCI_AlertSign")); 
            btn:EnalbeGray(true); 
            local nRow			= _G.Num2(p.CheckInImgIndex[i][4]);
            local nCol			= _G.Num1(p.CheckInImgIndex[i][4]); 
            local nCutX		= N_W*(nCol - 1);
            local nCutY		= N_H*(nRow - 1);
            local PicItem = pool:AddPicture( _G.GetSMImgPath( "action/"..p.ImgFileName..".png" ), false);  
            PicItem:Cut( _G.CGRectMake( nCutX, nCutY, N_W, N_H ) );
            btnPic:SetImage(PicItem);
            PicFinish:SetVisible(true);
            p.VipCheckInFlag = 2;
         else
            btn:SetTitle(GetTxtPri("DCI_NotSign")); 
            btn:EnalbeGray(true); 
            local nRow			= _G.Num2(p.CheckInImgIndex[i][2]);
            local nCol			= _G.Num1(p.CheckInImgIndex[i][2]);
            
            local nCutX		= N_W*(nCol - 1);
            local nCutY		= N_H*(nRow - 1);
            local PicItem = pool:AddPicture( _G.GetSMImgPath( "action/"..p.ImgFileName..".png" ), false);  
            PicItem:Cut( _G.CGRectMake( nCutX, nCutY, N_W, N_H ) );
            btnPic:SetImage(PicItem);
            PicFinish:SetVisible(false);
         end
    end  
    
    --找到第一个未签到的处理
    for i, v in pairs(p.BtnCheckInFlag) do
         if v == 0 then
            local btn = GetButton(layer, p.CheckInBtnId[i]);
            local btnPic = GetButton(layer, p.CheckInImgIndex[i][1]);
            local PicFinish = GetImage(layer, p.CheckInBtnId[i + 5]);     
                  
            if iTimelast == 1 then
                LogInfo("if iTimelast == 1 then");
                btn:SetTitle(GetTxtPri("DCI_Sign")); 
                btn:EnalbeGray(false); 
                
                local nRow			= _G.Num2(p.CheckInImgIndex[i][3]);
                local nCol			= _G.Num1(p.CheckInImgIndex[i][3]);
                
                local nCutX		= N_W*(nCol - 1);
                local nCutY		= N_H*(nRow - 1);
                LogInfo("nCutX = %d, nCutY = %d, nRow = %d, nCol = %d", nCutX, nCutY, nRow, nCol);
                local PicItem = pool:AddPicture( _G.GetSMImgPath( "action/"..p.ImgFileName..".png" ), false);  
                PicItem:Cut( _G.CGRectMake( nCutX, nCutY, N_W, N_H ) );
                btnPic:SetImage(PicItem);
                PicFinish:SetVisible(false);
                p.VipCheckInFlag = 1;
            elseif iTimelast == 2 then
                LogInfo("if iTimelast == 2 then");
                btn:SetTitle(GetTxtPri("DCI_Renewal")); 
                btn:EnalbeGray(false); 
                local nRow			= _G.Num2(p.CheckInImgIndex[i][3]);
                local nCol			= _G.Num1(p.CheckInImgIndex[i][3]);
                
                local nCutX		= N_W*(nCol - 1);
                local nCutY		= N_H*(nRow - 1);
                LogInfo("nCutX = %d, nCutY = %d, nRow = %d, nCol = %d", nCutX, nCutY, nRow, nCol);              
                local PicItem = pool:AddPicture( _G.GetSMImgPath( "action/"..p.ImgFileName..".png" ), false);  
                PicItem:Cut( _G.CGRectMake( nCutX, nCutY, N_W, N_H ) );
                btnPic:SetImage(PicItem);
                PicFinish:SetVisible(false);
                p.VipCheckInFlag = 1;
                btnReset:SetVisible(true);
                LableReset:SetVisible(true);
            end
            LogInfo("iTimelast 111== %d", iTimelast);
            
            if i == 1 then
                if iTimelast == 0 then
                    btn:SetTitle(GetTxtPri("DCI_Sign")); 
                    btn:EnalbeGray(false); 
                    local nRow			= _G.Num2(p.CheckInImgIndex[i][3]);
                    local nCol			= _G.Num1(p.CheckInImgIndex[i][3]);
                    local nCutX		= N_W*(nCol - 1);
                    local nCutY		= N_H*(nRow - 1);
                    LogInfo("nCutX = %d, nCutY = %d, nRow = %d, nCol = %d", nCutX, nCutY, nRow, nCol);      
                    local PicItem = pool:AddPicture( _G.GetSMImgPath( "action/"..p.ImgFileName..".png" ), false);  
                    PicItem:Cut( _G.CGRectMake( nCutX, nCutY, N_W, N_H ) );
                    btnPic:SetImage(PicItem);
                    PicFinish:SetVisible(false);    
                    p.VipCheckInFlag = 1;               
                    break;
                end
            end
            break;
         end
    end  
    
    --获取当前的vip等级,显示内容以及图片
    p.ShowVipContentAndPic();
    
    LogInfo("function p.Refresh() end");
end
---------------------------按钮重置功能-------------------------------------------------
function p.Reset()
    p.PreCheckInTime = 0;
    
    for i, v in pairs(p.BtnCheckInFlag) do
       p.BtnCheckInFlag[i] = 0;
    end
end
-----------------------------获取上一次签到跟现在的距离,返回天数---------------------------------
function p.GetTiemLast(iPreTime, iCurTime)
    LogInfo("iPreTime = %d", iPreTime);
    if iPreTime == 0 then
        return 0;
    else
        local SecPerDay = 24*3600;

        --local iCurTime = GetCurrentTime(); 
        local PreNum = math.floor((iPreTime + 8 * 3600)/SecPerDay);
        local CurNum = math.floor((iCurTime + 8 * 3600)/SecPerDay);
        
        LogInfo("PreNum = %d, iCurTime = %d, CurNum = %d", PreNum, iCurTime, CurNum);

        if math.floor(CurNum - PreNum) > 2 then
            return 0;
        end
        return math.floor(CurNum - PreNum);
    end
end


--发送签到消息   iDayIndex哪一天签到
function p.SendCheckIn(iDayIndex)  
    LogInfo("p.SendTacticListViewStatus  begin iDayIndex = %d", iDayIndex); 

	local netdata = createNDTransData(NMSG_Type._MSG_PLAYER_ACTION_OPERATE);
    
    --签到的类型是1
    netdata:WriteByte(1);
    netdata:WriteInt(iDayIndex);	
    
	SendMsg(netdata);	
	netdata:Free();	
    LogInfo("p.SendTacticListViewStatus  end"); 
	return true;	
end

--发送重置消息
function p.SendReset()  
    LogInfo("p.SendReset  begin"); 

	local netdata = createNDTransData(NMSG_Type._MSG_PLAYER_ACTION_OPERATE);
   
    --重置的类型是4
    netdata:WriteByte(4);
    
	SendMsg(netdata);	
	netdata:Free();	
    LogInfo("p.SendReset  end"); 
	return true;	
end



function p.GetTimeLastNum(iPreTime, iCurTime)

    if iPreTime == 0 then
        return 1;
    else
        local SecPerDay = 24*3600;

        local PreNum = math.floor((iPreTime + 8 * 3600)/SecPerDay);
        local CurNum = math.floor((iCurTime + 8 * 3600)/SecPerDay);
        
        return math.floor(CurNum - PreNum);
    end
end

function p.HasSigh()
    local nTimeLast = p.GetTimeLastNum(p.PreCheckInTime, p.CurCheckInTime);
    LogInfo("nTimeLast:[%d]",nTimeLast);
    if(nTimeLast > 0) then
        return true;
    end
    
    return false;
end



