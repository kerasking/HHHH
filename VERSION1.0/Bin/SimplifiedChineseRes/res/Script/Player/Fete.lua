---------------------------------------------------
--描述: 祭祀界面
--时间: 2012.4.6
--作者: cl

---------------------------------------------------
local _G = _G;

Fete={}
local p=Fete;

local count = 0;
p.mList = {};

local tVIPMilOrder = {}
tVIPMilOrder[0] = 10
tVIPMilOrder[1] = 20
tVIPMilOrder[2] = 20
tVIPMilOrder[3] = 20
tVIPMilOrder[4] = 30
tVIPMilOrder[5] = 40
tVIPMilOrder[6] = 40
tVIPMilOrder[7] = 50
tVIPMilOrder[8] = 70
tVIPMilOrder[9] = 100
tVIPMilOrder[10] = 100

local tMultiples = {}

tMultiples[1] = 1
tMultiples[2] = 2
tMultiples[3] = 4
tMultiples[4] = 10



local tGoldNeeded = {}
    for i=0,100 do
    if i <=9 then
        tGoldNeeded[i] = i*2 
    elseif i<=20 then
        tGoldNeeded[i] = 20
    elseif i<=50 then
        tGoldNeeded[i] = 50
    elseif i<=100 then
        tGoldNeeded[i] = 100
    end
end

p.TagClose = 3;


p.TagBtn1 = 7;
p.TagBtn2 = 8;
p.TagBtn3 = 9;
p.TagBtn4 = 10;

p.TagBtn = {
    [40] = {btn = 7, lock = 102, dis = 106},
    [50] = {btn = 8, lock = 103, dis = 107},
    [60] = {btn = 9, lock = 104, dis = 108},
    [70] = {btn = 10, lock = 105, dis = 109},
};



p.TextBtn1 = 11;
p.TextBtn2 = 16;
p.TextBtn3 = 17;
p.TextBtn4 = 18;

local num1 =0;
local num2 =0;
local num3 =0;
local num4 =0;

local Anid = nil;
local flag = 0;


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
    layer:SetTag(NMAINSCENECHILDTAG.Fete);
    local winsize = GetWinSize();
    layer:SetFrameRect(RectFullScreenUILayer);
    --layer:SetBackgroundColor(ccc4(125,125,125,125));
    scene:AddChildZ(layer,145);

    local uiLoad=createNDUILoad();
    if nil == uiLoad then
        layer:Free();
        LogInfo("scene = nil,4");
        return false;
    end
    uiLoad:Load("Fete.ini",layer,p.OnUIEvent,0,0);
    
    
    --[[
    local bTn1 = GetButton(layer, p.TagBtn1);
        bTn1:SetVisible(false);
    local bTn2 = GetButton(layer, p.TagBtn2);
        bTn2:SetVisible(false);
    local bTn3 = GetButton(layer, p.TagBtn3);
        bTn3:SetVisible(false);
    local bTn4 = GetButton(layer, p.TagBtn4);
        bTn4:SetVisible(false);
    ]]
    
    
    
    uiLoad:Free();
    p.refreshBtn();
    p.refresh(0,0,0,0);
    
    --设置关闭音效
   	local closeBtn=GetButton(layer,  p.TagClose);
   	closeBtn:SetSoundEffect(Music.SoundEffect.CLOSEBTN);
end

function p.refreshBtn()
    local nPlayerId = GetPlayerId();
    local nPetId = ConvertN(RolePetFunc.GetMainPetId(nPlayerId));
    local userLevel = ConvertN(RolePet.GetPetInfoN(nPetId, PET_ATTR.PET_ATTR_LEVEL));
     LogInfo("userLevel[%d]",userLevel);
     
     for i,v in pairs(p.TagBtn) do
        --local btn = GetButton(p.getUiLayer(), v.btn);
        local lock = GetImage(p.getUiLayer(), v.lock);
        local dis = GetButton(p.getUiLayer(), v.dis);
        if(userLevel>=i) then 
            lock:SetVisible(false);
            dis:SetVisible(false);
        else
            lock:SetVisible(false);
            dis:SetVisible(false);
            --lock:SetVisible(true);
            --dis:SetVisible(true);
        end
     end
end


function p.OnUIEvent(uiNode,uiEventType,param)
    local tag = uiNode:GetTag();
    LogInfo("p.OnUIEvent[%d]",tag);
    if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
        if p.TagClose == tag then
            CloseUI(NMAINSCENECHILDTAG.Fete);
            return true;
        elseif p.TagBtn1 == tag then
                 LogInfo("++++++count[%d]++++",count);
             for i = 1, count do
                local t = p.mList[i];
                if (t.type == 1) then
                    local nId = t.id;
                    local xnum1 = t.num;
                    LogInfo("++++++nId[%d]++++",nId);
                    local needmoney1 = xnum1*2+2;
                    LogInfo("++++++needmoney[%d]++++",needmoney1);
                    local nPlayerId = GetPlayerId();
                    local nMoney = GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_EMONEY);
                    if nMoney >= needmoney1 then
                        p.SendMsgFete(nId);
                        p.refresh(1,0,0,0);
                        flag=1;
                        Anid =1;
                    elseif nMoney < needmoney1 then
                           LogInfo("++++++nMoney < needmoney++++");
                       CommonDlgNew.ShowTipDlg(GetTxtPri("JinBiBuZhu"));
                        return;
                    end
                end
            end
        elseif p.TagBtn2 == tag then
           
            LogInfo("++++++count[%d]++++",count);
            for i = 1, count do
                local t = p.mList[i];
                if (t.type == 2) then
                    local nId = t.id;
                    local xnum2 = t.num;
                    LogInfo("++++++nId[%d]++++",nId);
                    local needmoney2 = xnum2*3+3;
                    LogInfo("++++++needmoney[%d]++++",needmoney2);
                    local nPlayerId = GetPlayerId();
                    local nMoney = GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_EMONEY);
                    if nMoney >= needmoney2 then
                        p.SendMsgFete(nId);
                        p.refresh(0,1,0,0);
                        flag=1;
                        Anid =2;
                    elseif nMoney < needmoney2 then
                        LogInfo("++++++nMoney < needmoney++++");
                        CommonDlgNew.ShowTipDlg(GetTxtPri("JinBiBuZhu"));
                        return;
                    end
                end
            end
        elseif p.TagBtn3 == tag then
            LogInfo("++++++count[%d]++++",count);
            for i = 1, count do
            local t = p.mList[i];
                if (t.type == 3) then
                    local nId = t.id;
                    local xnum3 = t.num;
                    LogInfo("++++++nId[%d]++++",nId);
                    local needmoney3 = xnum3*4+4;
                    LogInfo("++++++needmoney[%d]++++",needmoney3);
                    local nPlayerId = GetPlayerId();
                    local nMoney = GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_EMONEY);
                    if nMoney >= needmoney3 then
                        p.SendMsgFete(nId);
                        p.refresh(0,0,1,0);
                        flag=1;
                        Anid =3;
                    elseif nMoney < needmoney3 then
                        LogInfo("++++++nMoney < needmoney++++");
                        CommonDlgNew.ShowTipDlg(GetTxtPri("JinBiBuZhu"));
                        return;
                    end
                end
            end
        elseif p.TagBtn4 == tag then
            LogInfo("++++++count[%d]++++",count);
            for i = 1, count do
            local t = p.mList[i];
                if (t.type == 4) then
                    local nId = t.id;
                    LogInfo("++++++nId[%d]++++",nId);
                    local xnum4 = t.num;
                    local needmoney4 = xnum4*2+5;
                    LogInfo("++++++needmoney[%d]++++",needmoney4);
                    local nPlayerId = GetPlayerId();
                    local nMoney = GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_EMONEY);
                    if nMoney >= needmoney4 then
                        p.SendMsgFete(nId);
                        p.refresh(0,0,0,1);
                        flag=1;
                        Anid =4;
                    elseif nMoney < needmoney4 then
                        LogInfo("++++++nMoney < needmoney++++");
                        CommonDlgNew.ShowTipDlg(GetTxtPri("JinBiBuZhu"));
                        return;
                    end
                end
            end



        end
    end
end

function p.getUiLayer()
    local scene = GetSMGameScene();
    if not CheckP(scene) then
        return nil;
    end

    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.Fete);
    if not CheckP(layer) then
        LogInfo("nil == layer")
        return nil;
    end

    return layer;
end
function p.processSacrificeList(netdata)

    LogInfo("process 7004");
    count	= netdata:ReadByte();
        LogInfo(" count:" .. count);
    local m={};
    for i = 1, count do
        local t = {};
        t.id	= netdata:ReadInt();
        t.type = netdata:ReadInt();
        t.num = netdata:ReadByte();
        t.multiples = netdata:ReadByte();
        LogInfo("t.id[%d]",t.id);
        m[i] = t;
        --p.setRoleMatrixAdd(m);
    end
    
    CloseLoadBar();
    p.mList = m;
    if flag==1 then
        p.showMessage(Anid);
    end
    
    --引导任务事件触发
	GlobalEvent.OnEvent(GLOBALEVENT.GE_GUIDETASK_ACTION,TASK_GUIDE_PARAM.WORSHIP);

end

function p.SendMsgFete(nTypeId)
     ShowLoadBar();
        LogInfo("==========6005=========");
    local netdata = createNDTransData(NMSG_Type._MSG_CONFIRM_SACRIFICE);
        netdata:WriteInt(nTypeId);
        SendMsg(netdata);
        netdata:Free();
    return true;
end
function p.showMessage(nId)
    local nPlayerId = GetPlayerId();
    LogInfo(nPlayerId);
    local nPetId = ConvertN(RolePetFunc.GetMainPetId(nPlayerId));
    local userLevel = ConvertN(RolePet.GetPetInfoN(nPetId, PET_ATTR.PET_ATTR_LEVEL));
    LogInfo(" +++++p.showMessage(nId)userLevel:+++++++" .. userLevel);
    local titlex = "倍暴击，获得";
    local titley = "获得";
    
    for i = 1, count do
    local t = p.mList[i];
        if (t.type == nId) then
            local multiplesV = t.multiples;
            --LogInfo("++++++nId[%d]++++",nId);   
            local multiplesX = tMultiples[multiplesV];
            --LogInfo("++++++multiplesX[%d]++++",multiplesX); 
            local smoney = (2000+userLevel*750)*multiplesX;
            --LogInfo("++++++smoney[%d]++++",smoney); 
            local soph =  (100+userLevel*5)*multiplesX;
            --LogInfo("++++++soph[%d]++++",soph); 
            local repute = (500+userLevel*50)*multiplesX;
            --LogInfo("++++++repute[%d]++++",repute); 
            local gemstone = multiplesX;
             --LogInfo("++++++gemstone[%d]++++",gemstone); 
             
             
            if nId == 1 then
                local title1 = string.format("%s%d%s", titley,smoney,GetTxtPub("coin"));
                local title2 = string.format("%d%s%d%s", multiplesX, titlex,smoney,GetTxtPub("coin"));
                if multiplesX == 1 then
                    LogInfo("++++++multiplesX[%d]++++",multiplesX); 
                    --CommonDlgNew.ShowYesDlg(title1,nil,nil,1,1,1);
                    CommonDlgNew.ShowTipsDlg({{title1,FeteColor[1]}});
                    
                elseif multiplesX ==2 or multiplesX == 4 or multiplesX == 10 then
                    LogInfo("++++++multiplesX[%d]++++",multiplesX); 
                    --CommonDlgNew.ShowYesDlg(title2,nil,nil,1,multiplesX,1);
                    CommonDlgNew.ShowTipsDlg({{title2,FeteColor[multiplesX]}});
                end
            elseif nId == 2 then
                local title1 = string.format("%s%d%s", titley,soph,GetTxtPub("JianHun"));
                local title2 = string.format("%d%s%d%s", multiplesX, titlex,soph,GetTxtPub("JianHun"));
                if multiplesX == 1 then
                    --CommonDlgNew.ShowYesDlg(title1,nil,nil,1,1,1);
                    CommonDlgNew.ShowTipsDlg({{title1,FeteColor[1]}});
                    
                elseif multiplesX ==2 or multiplesX == 4 or multiplesX == 10 then
                    --CommonDlgNew.ShowYesDlg(title2,nil,nil,1,multiplesX,1);
                    CommonDlgNew.ShowTipsDlg({{title2,FeteColor[multiplesX]}});
                end
            elseif nId == 3 then
                local title1 = string.format("%s%d%s", titley,repute,GetTxtPub("ShenWan"));
                local title2 = string.format("%d%s%d%s", multiplesX, titlex,repute,GetTxtPub("ShenWan"));
                if multiplesX == 1 then
                    --CommonDlgNew.ShowYesDlg(title1,nil,nil,1,1,1);
                    CommonDlgNew.ShowTipsDlg({{title1,FeteColor[1]}});
                    
                elseif multiplesX ==2 or multiplesX == 4 or multiplesX == 10 then
                    --CommonDlgNew.ShowYesDlg(title2,nil,nil,1,multiplesX,1);
                    CommonDlgNew.ShowTipsDlg({{title2,FeteColor[multiplesX]}});
                end
            elseif nId == 4 then
                local title1 = string.format("%s%d%s", titley,gemstone,GetTxtPub("DaiShi"));
                local title2 = string.format("%d%s%d%s", multiplesX, titlex,gemstone,GetTxtPub("DaiShi"));
                if multiplesX == 1 then
                    --CommonDlgNew.ShowYesDlg(title1,nil,nil,1,1,1);
                    CommonDlgNew.ShowTipsDlg({{title1,FeteColor[1]}});
                elseif multiplesX ==2 or multiplesX == 4 or multiplesX == 10 then
                    --CommonDlgNew.ShowYesDlg(title2,nil,nil,1,multiplesX,1);
                    CommonDlgNew.ShowTipsDlg({{title2,FeteColor[multiplesX]}});
                end
            end        
        end
    end

end

function p.refresh(nId1,nId2,nId3,nId4)
    LogInfo("p.refreshp.refreshp.refresh");
    for i = 1, count do
    local t = p.mList[i];
    if (t.type == 1) then
        num1 = t.num;
    LogInfo(" +++++++!!!!!!num1***********" .. num1);
    elseif t.type == 2 then
        num2 = t.num;
    elseif t.type == 3 then
        num3 = t.num;
    elseif t.type == 4 then
        num4 = t.num;
    end
end

    local text1 = GetLabel(p.getUiLayer(), p.TextBtn1);
    local ntext1 = "金币";
    LogInfo(" +++++++!!!!!!num1:+++++++" .. num1);
    local btn1needmoney = (num1+nId1)*2+2;
    local title = string.format("%d%s", btn1needmoney,ntext1);
    if CheckP(text1) then
        LogInfo("++++text1++++");  
        text1:SetText(title);
    end
    local text2 = GetLabel(p.getUiLayer(), p.TextBtn2);
    LogInfo(" +++++++!!!!!!num2:+++++++" .. num2);
    local btn2needmoney = (num2+nId2)*3+3;
    local title = string.format("%d%s", btn2needmoney,ntext1);
    if CheckP(text2) then
        LogInfo("++++text1++++");  
        text2:SetText(title);
    end
    LogInfo(" +++++++!!!!!!num3:+++++++" .. num3);
    local text3 = GetLabel(p.getUiLayer(), p.TextBtn3);
    local btn3needmoney = (num3+nId3)*4+4;
    local title = string.format("%d%s", btn3needmoney,ntext1);
    if CheckP(text3) then
        LogInfo("++++text1++++");  
        text3:SetText(title);
    end
    LogInfo(" +++++++!!!!!!num4:+++++++" .. num4);
    local text4 = GetLabel(p.getUiLayer(), p.TextBtn4);
    local btn4needmoney = (num4+nId4)*2+5;
    local title = string.format("%d%s", btn4needmoney,ntext1);
    if CheckP(text4) then
        LogInfo("++++text1++++");  
        text4:SetText(title);
    end
end

RegisterNetMsgHandler(NMSG_Type._MSG_SACRIFICE_INFO_LIST, "p.processSacrificeList", p.processSacrificeList);






