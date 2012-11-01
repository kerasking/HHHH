---------------------------------------------------
--描述: 征收界面
--时间: 2012.4.6
--作者: cl

---------------------------------------------------
local _G = _G;

Levy={}
local p=Levy;


local nLeftTime = nil;
local nBuyedLevy = nil;

local nAvailBuyTime = nil;

local tGoldNeeded = {}
for i=0,100 do
    if i <=9 then
        tGoldNeeded[i] = i*2 
    elseif i<=20 then
        tGoldNeeded[i] = 20
    elseif i<=50 then
        tGoldNeeded[i] = 50
    elseif i<=101 then
        tGoldNeeded[i] = 100
    end
end

p.TagClose = 3;
p.TagOK = 6;
p.TagNum = 11;
p.TagOKVip = 29;
p.TagBatchOKVip = 28;

p.TagMoneyText = 24;

--[[
p.TagGmoney =24;
p.TagSmoney =27;
]]



function p.LoadUI()
    local scene=GetSMGameScene();
    if scene == nil then
        LogInfo("scene = nil,load BattleFail failed!");
        return;
    end
    
    local layer = createNDUILayer();
    if layer == nil then
        LogInfo("scene = nil,2");
        return  false;
    end
    layer:Init();
    layer:SetTag(NMAINSCENECHILDTAG.Levy);
    local winsize = GetWinSize();
    layer:SetFrameRect(RectFullScreenUILayer);
    --layer:SetBackgroundColor(ccc4(125,125,125,125));
    scene:AddChild(layer);

    local uiLoad=createNDUILoad();
    if nil == uiLoad then
        layer:Free();
        LogInfo("scene = nil,4");
        return false;
    end
    uiLoad:Load("Levy.ini",layer,p.OnUIEvent,0,0);
    uiLoad:Free();
    
    local moneyText= GetLabel(p.getUiLayer(), p.TagMoneyText); 
    
    
    p.refresh(0);
    
    p.SetVipFunc();
    
    --设置关闭音效
   	local closeBtn=GetButton(layer,  p.TagClose);
   	closeBtn:SetSoundEffect(Music.SoundEffect.CLOSEBTN);
   	
end

function p.refresh(nId)
    local nPlayerId = GetPlayerId();

    local nVipRank = GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_VIP_RANK);

    local nPetId = ConvertN(RolePetFunc.GetMainPetId(nPlayerId));
    local userLevel = ConvertN(RolePet.GetPetInfoN(nPetId, PET_ATTR.PET_ATTR_LEVEL))

    nBuyedLevy = GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_BUYED_LEVY);  
    nAvailBuyTime = GetVipVal(DB_VIP_CONFIG.LEVY_NUM); --每天可征收次数
    nLeftTime = nAvailBuyTime - nBuyedLevy;   --每天还可次征收数
   
    
    local num = GetLabel(p.getUiLayer(), p.TagNum);
    
    if CheckP(num) then
        num:SetText(string.format("%d", nLeftTime));
    end

    local gmoneyX = tGoldNeeded[nBuyedLevy+1+nId];
    local smoneyX = 20000+userLevel*750;
    
    local moneyText= GetLabel(p.getUiLayer(), p.TagMoneyText); 
    moneyText:SetText(string.format(GetTxtPri("ZS_Txt"),gmoneyX,smoneyX));
end

function p.ProcessLevyResult(netdatas)
    CloseLoadBar();
    local isSuccess=netdatas:ReadByte();
    if(isSuccess ~= 0) then
    	--成功音效    
   		Music.PlayEffectSound(Music.SoundEffect.LEVY);
		
		--引导任务事件触发
		GlobalEvent.OnEvent(GLOBALEVENT.GE_GUIDETASK_ACTION,TASK_GUIDE_PARAM.LEVY);

        p.refresh(0);
        LogInfo("+++++++p.refresh(1);+++++++++");
    end
end


function p.OnUIEvent(uiNode,uiEventType,param)
    local tag = uiNode:GetTag();
    LogInfo("p.OnUIEvent[%d]",tag);
    if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
        if p.TagClose == tag then
            CloseUI(NMAINSCENECHILDTAG.Levy);
            --QuitGame();
            return true;
        elseif p.TagOK == tag or p.TagOKVip == tag then
            LogInfo("+++++++p.TagOK;+++++++++");
            
            p.OnLevyEvent(1);
            
        elseif tag == p.TagBatchOKVip then
            local count = AssistantUI.allowLevyCount();
            LogInfo("count:[%d]",count);
            if(count>10) then
                p.OnLevyEvent(10);
            else
                p.OnLevyEvent(count);
            end
        end
    end
    
    return true;
end

--征收事件
function p.OnLevyEvent(nNum)
    LogInfo("nNum:[%d]",nNum);
    --征收次数判断
    if nLeftTime < nNum then
        CommonDlgNew.ShowYesDlg(GetTxtPri("ZZ_CountBuZhu"),nil,nil,3);
        return;
    end
    
    --征收上限判断
    if nBuyedLevy >= #tGoldNeeded then
        CommonDlgNew.ShowYesDlg(GetTxtPri("ZZ_MaxLimit"),nil,nil,3);
        return;
    end
    
    --征收使用的金额判断
    local nMoney = GetRoleBasicDataN(GetPlayerId(),USER_ATTR.USER_ATTR_EMONEY);
    local nNeedMoney = p.CalculateEMoney(nNum);
    if nNeedMoney > nMoney then
        CommonDlgNew.ShowYesDlg(GetTxtPri("ZZ_JINBIBUZHU"));
        return;
    end
    
    if(nNum>1) then
        local sTip = "";
        local nEMoney = p.CalculateEMoney(nNum);
        local nMoney = p.CalculateMoney(nNum);
        if(nNum==10) then
            sTip = string.format(GetTxtPri("ZZ_ShiCount"),nNum,nEMoney,nMoney,0);
        else
            sTip = string.format(GetTxtPri("ZZ_ShengYuCount"),nNum,nEMoney,nMoney);
        end
        
        CommonDlgNew.ShowYesOrNoDlg(sTip, p.OnUIEventUseNum,nNum);
    else
        p.SendMsgLevy(nNum);
    end
    
end

--计算消耗金币
function p.CalculateEMoney(nNum)
    local nEMoney = 0;
    local alert_levy = GetRoleBasicDataN(GetPlayerId(),USER_ATTR.USER_ATTR_BUYED_LEVY);
    for i=alert_levy+1,alert_levy+nNum do
        nEMoney = nEMoney + tGoldNeeded[i];
    end
    return nEMoney;
end

--计算获得的银币
function p.CalculateMoney(nNum)
    local nPetId = ConvertN(RolePetFunc.GetMainPetId(nPlayerId));
    local userLevel = ConvertN(RolePet.GetPetInfoN(nPetId, PET_ATTR.PET_ATTR_LEVEL))
    local smoneyX = (20000+userLevel*750)*nNum;
    
    return smoneyX;
end


function p.OnUIEventUseNum(nEventType, param, val)
    if(CommonDlgNew.BtnOk == nEventType) then
    
        local nNum = val;
        LogInfo("nNum:[%d]",nNum);
        p.SendMsgLevy(nNum);
        
    end
end


function p.SendMsgLevy(nNum)
    LogInfo("SendMsgLevySendMsgLevySendMsgLevy");
    local netdata = createNDTransData(NMSG_Type._MSG_BUY_LEVY);
    netdata:WriteInt(nNum);
    
    SendMsg(netdata);
    netdata:Free();
    ShowLoadBar();
    return true;
end

function p.getUiLayer()
    local scene = GetSMGameScene();
    if not CheckP(scene) then
        return nil;
    end

    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.Levy);
    if not CheckP(layer) then
        LogInfo("nil == layer")
    return nil;
    end

    return layer;
end

--vip功能开启
function p.SetVipFunc()
    local btnOk = GetButton(p.getUiLayer(), p.TagOK);
    local btnOkVip = GetButton(p.getUiLayer(), p.TagOKVip);
    local btnBatchOkVip = GetButton(p.getUiLayer(), p.TagBatchOKVip);
    
    if(GetVipIsOpen(DB_VIP_CONFIG.BATCH_LEVY)) then
        btnOk:SetVisible(false);
        btnOkVip:SetVisible(true);
        btnBatchOkVip:SetVisible(true);
    else
        btnOk:SetVisible(true);
        btnOkVip:SetVisible(false);
        btnBatchOkVip:SetVisible(false);
    end
end

RegisterNetMsgHandler(NMSG_Type._MSG_BUY_LEVY,"p.ProcessLevyResult",p.ProcessLevyResult);