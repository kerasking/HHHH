---------------------------------------------------
--描述: 登入等待界面
--时间: 2012.10.11
--作者: tzq
---------------------------------------------------
LoginListUI = {}
local p = LoginListUI;

p.ctrId = {btnClose = 101, txtName = 103, txtNum = 5, txtTime = 7,};
p.tbTimer = { LableTime = 13, CountDownNum = 0, TimerTag = -1, };   --等待定时器


function p.LoadUI(sName, pNum, nTime)
    LogInfo( "function p.LoadUI(sName = %s, pNum = %d, nTime = %d)", sName, pNum, nTime);
    --------------------获得游戏主场景------------------------------------------
    local scene = GetRunningScene();	
	if scene == nil then
		return;
	end
    
    --------------------添加页面控件层---------------------------------------
    local layer = createNDUILayer();
	if layer == nil then
		return false;
	end
    
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.LoginListUI);
	layer:SetFrameRect(RectFullScreenUILayer);
	scene:AddChildZ(layer,1);

    -----------------初始化ui添加到 layer 层上---------------------------------
    local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end
	uiLoad:Load("loginList.ini", layer, p.OnUIEvent, 0, 0);
    
    p.RefreshUI(sName, pNum, nTime);
    return true;
end  

------------------刷新显示---------------------------
function p.RefreshUI(sName, pNum, nTimes)
     local layer = p.GetParent();
     --p.ctrId = {btnClose = 101, txtName = 103, txtNum = 5, txtTime = 7,};
     local name = "["..sName.."]"..GetTxtPri("LLUI2_T1");
     SetLabel(layer, p.ctrId.txtName, name);
     SetLabel(layer, p.ctrId.txtNum, SafeN2S(pNum));  
     SetLabel(layer, p.ctrId.txtTime, string.format(GetTxtPri("LLUI2_T1"),nTimes));    
     
     if nTimes > 0 then
        p.tbTimer.CountDownNum = nTimes;
        p.tbTimer.TimerTag = RegisterTimer(p.OnTimer, 1);  
     end
end

function p.OnTimer(tag)
	local layer=p.GetParent();
    if layer == nil then
        return;
    end
    
	if tag == p.tbTimer.TimerTag then  --拦截倒计时
    
		if p.tbTimer.CountDownNum <= 0 then
            if p.tbTimer.TimerTag ~= -1 then
                UnRegisterTimer(p.tbTimer.TimerTag);
                p.tbTimer.TimerTag = -1;
                local scene = GetRunningScene();
                scene:RemoveChildByTag(NMAINSCENECHILDTAG.LoginListUI, true);
                --进入Loading界面
                Login_LoadingUI.LoadUI();
                Login_LoadingUI.SetProcess(10);
            end
            return;
		else
			p.tbTimer.CountDownNum = p.tbTimer.CountDownNum - 1;
		end
             
        SetLabel(layer, p.ctrId.txtTime, string.format(GetTxtPri("LLUI2_T1"),p.tbTimer.CountDownNum));    
    end
end

function p.FreeData()
    if p.tbTimer.TimerTag ~= -1 then
        UnRegisterTimer(p.tbTimer.TimerTag);
        p.tbTimer.TimerTag = -1;
    end
end

------------------响应函数---------------------------
function p.OnUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
    LogInfo( "p.OnListEvent tag = %d, p.ctrId.btnClose = %d", tag, p.ctrId.btnClose);
    local BtnClick = NUIEventType.TE_TOUCH_BTN_CLICK;
    
    if uiEventType == BtnClick then
		if p.ctrId.btnClose == tag then    
            local scene = GetRunningScene();
            scene:RemoveChildByTag(NMAINSCENECHILDTAG.LoginListUI, true);
            sendMsgConnect("127.0.0.1", 0, 0);
            LogInfo( "on end");
            p.FreeData();
        end
    end
    return true;
end


function p.GetParent()
	local scene = GetRunningScene();
	if nil == scene then
		return nil;
	end
    
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.LoginListUI);
	if nil == layer then
		return nil;
	end
	return layer;
end



-----登入排队开始
function p.LoginQueueBegin(netdatas)
    LogInfo( "receive QueueBegin" );
    local PNum = netdatas:ReadInt();                      --登入玩家个数
    local TimeAward = netdatas:ReadShort();        --登入时间间隔个数  
    local Time = math.floor(PNum*TimeAward/1000);
    
    CloseLoadBar();
    if PNum > 0 then
        LogInfo( "load SerName = %s, PNum = %d, Time = %d", Login_ServerUI.SerName, PNum, Time); 
        p.LoadUI(Login_ServerUI.SerName, PNum, Time);
    else
        --进入Loading界面
        Login_LoadingUI.LoadUI();
        Login_LoadingUI.SetProcess(10);
    end
    LogInfo( "receive QueueBegin PNum = %d, TimeAward = %d",  PNum, TimeAward); 
end

-----登入排队结束
function p.LoginQueueEnd(netdatas)
    LogInfo( "receive QueueEnd" );
     if IsUIShow(NMAINSCENECHILDTAG.LoginListUI) then
            p.FreeData();
            local scene = GetRunningScene();
            scene:RemoveChildByTag(NMAINSCENECHILDTAG.LoginListUI, true);
     end
     
    --进入Loading界面
    Login_LoadingUI.LoadUI();
    Login_LoadingUI.SetProcess(10);
    
    LogInfo( "receive QueueEnd" );
end


RegisterNetMsgHandler( NMSG_Type._MSG_QUEUE_BEGIN, "p.LoginQueueBegin", p.LoginQueueBegin );
RegisterNetMsgHandler( NMSG_Type._MSG_QUEUE_END, "p.LoginQueueEnd", p.LoginQueueEnd );

