---------------------------------------------------
--描述: 充值奖励界面
--时间: 2012.9.3
--作者: tzq
---------------------------------------------------
RechargeReward = {}
local p = RechargeReward;



p.UiCtr = {btnClose = 533, btnGet = 24, btnRecharge = 26, contText = 23, timeText = 27, broadText = 22, awardText = 34, rightListTitleText = 31,};

p.UiList = {ListLeft = {ListContaner = nil, ListCtrId = 20, btnId = 2, crtlText = 3, CurFocus = 1,}, 
                   ListRight = {ListContaner = nil, ListCtrId = 30, btnId = 4, crtlText = 3, CurFocus = 1, listTitle = 31, }};
                                      
                                      
local LeftListSize = CGSizeMake(110*CoordScaleX, 40*CoordScaleY);              
local RightListSize = CGSizeMake(100*CoordScaleX, 28*CoordScaleY);                      
                   
p.LeftTitleLIst = {};   --存储左边列表数据
p.EventConfig = {};   
p.EventReward = {};  

--活动数据是否下发标志
p.NeedDownFlag = false;  


p.RechargeState = { First = {Num = 0, Flag = 0,},
                                   OnceFlag = {0, 0 , 0, 0, 0, 0, 0, 0, 0, 0,0, 0 , 0, 0, 0, 0, 0, 0, 0, 0,0, 0 , 0, 0, 0, 0, 0, 0, 0, 0,}, 
                                   TotalFlag = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0, 0 , 0, 0, 0, 0, 0, 0, 0, 0,},
                                   DailyFlag = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0, 0 , 0, 0, 0, 0, 0, 0, 0, 0,0, 0 , 0, 0, 0, 0, 0, 0, 0, 0,},};

p.RechargeTimeBegin = {First = 0,  OnceFlag = 0, TotalFlag = 0, DailyFlag = 0,};                                

                   
--活动类型
p.ActionType =
{
    FIRST_PAY = 3,             --首次充值
    ONCE_PAY = 4,             --单次充值  
    TOTAL_PAY = 5,           --累计充值
    DAILY_PAY = 7,           --每日充值
    DAILY_RETURN = 8,           --每日返還   
    ONLINE_RETURN = 9,           --在線返還  
    
};               

--加载充值活动主界面
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
    
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.RechargeReward);
	layer:SetFrameRect(RectFullScreenUILayer);
	scene:AddChildZ(layer,UILayerZOrder.NormalLayer );
    
    local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end
	uiLoad:Load("VIPgift.ini", layer, p.OnUIEvent, 0, 0);

    ------------------------------------初始化数据------------------------------------------------------------------
    p.InitData();
    p.Refresh();
    
    return true;
end

-----------------------------获取父层layer---------------------------------
function p.InitData()
	if p.NeedDownFlag then
		p.InitDataWhenDown();
	else
		p.InitDataWhenReadDb();
	end
end

function p.InitDataWhenDown()

    p.LeftTitleLIst = {};   --存储左边列表数据
 
    if p.EventConfig ~= nil then
        table.sort(p.EventConfig, function(a,b) return a.Id < b.Id   end);
    end 
    
    if p.EventReward ~= nil then
        table.sort(p.EventReward, function(a,b) return a.Id < b.Id   end);
    end 
	
    for i,v in pairs(p.EventConfig) do
        --获取活动的类型
        local nType = v.Type;
        
        local delFlag = 0;
        for j, k in pairs(MsgPlayerAction.PLAYER_ACTION_STATION) do
            if k.type == nType and k.IsExit == 0 then
                LogInfo("initdata type  = %d, IsExit  = %d has been delete",  k.type,  k.IsExit);    
                delFlag = 1;  --说明这个活动已经删除
                break;
            end
        end 

        --获取所有活动所属的组别,同一组别在同一个列表显示
        local nUiGroup = v.Group;
        if nUiGroup == 3 and delFlag ~= 1 then   
			 v.RightListTable = {}; 
		      --获取右侧列表要显示的内容      
            for j, k in pairs(p.EventReward) do
                if v.Id == k.IdEventConfig then
					table.insert(v.RightListTable, k);
                end
            end   
            
            table.insert(p.LeftTitleLIst, v);               			        
        end
    end
end

function p.InitDataWhenReadDb()

    p.LeftTitleLIst = {};   --存储左边列表数据
    --左边标题列表数据的获取
    local idCofigTemp = GetDataBaseIdList("event_config");
    local idAwards = GetDataBaseIdList("event_award");
    local idCofigs = {};
    
    local nPreSerId, nCurSerId = Login_ServerUI.GetPreCurSerId();
    for i, v in pairs(idCofigTemp) do
        local nSerId = GetDataBaseDataN("event_config", v, DB_EVENT_CONFIG.SERVERID);
        if nSerId == nCurSerId then
        --if nSerId == 2 then
            table.insert(idCofigs, v);
        end
    end
    
    LogInfo("initdata nPreSerId = %d, nCurSerId  = %d, IdtotalNum = %d, idCurNum = %d", nPreSerId, nCurSerId, table.getn(idCofigTemp), table.getn(idCofigs));
    
    if idCofigs ~= nil then
        table.sort(idCofigs, function(a,b) return a < b   end);
    end 
    
    if idAwards ~= nil then
        table.sort(idAwards, function(a,b) return a < b   end);
    end 
    
    for i,v in pairs(idCofigs) do
        --获取活动的类型
        local nType = GetDataBaseDataN("event_config", v, DB_EVENT_CONFIG.TYPE);
        
        local delFlag = 0;
        for j, k in pairs(MsgPlayerAction.PLAYER_ACTION_STATION) do
            if k.type == nType and k.IsExit == 0 then
                LogInfo("initdata type  = %d, IsExit  = %d has been delete",  k.type,  k.IsExit);    
                delFlag = 1;  --说明这个活动已经删除
                break;
            end
        end 

        --获取所有活动所属的组别,同一组别在同一个列表显示
        local nUiGroup = GetDataBaseDataN("event_config", v, DB_EVENT_CONFIG.UI_GROUP);
        if nUiGroup == 3 and delFlag ~= 1 then
            local Record = {};
            Record.Id = v;
            Record.Name = GetDataBaseDataS("event_config", v, DB_EVENT_CONFIG.NAME); 
            Record.Content = GetDataBaseDataS("event_config", v, DB_EVENT_CONFIG.CONTENT);    
            Record.Broad = GetDataBaseDataS("event_config", v, DB_EVENT_CONFIG.BROAD);   
            Record.Type = GetDataBaseDataN("event_config", v, DB_EVENT_CONFIG.TYPE);  
            Record.TimeType = GetDataBaseDataN("event_config", v, DB_EVENT_CONFIG.TIME_TYPE);             
            Record.BeginTime = GetDataBaseDataN("event_config", v, DB_EVENT_CONFIG.TIME_BEGIN);      
            Record.EndTime = GetDataBaseDataN("event_config", v, DB_EVENT_CONFIG.TIME_END); 
            Record.RightListTable = {};                  
            --获取右侧列表要显示的内容      
            for j, k in pairs(idAwards) do
                local Config_id = GetDataBaseDataN("event_award", k, DB_EVENT_AWARD.CONFIG_ID);
                if v == Config_id then
                    local rightTable = {};  
                    rightTable.Stage = GetDataBaseDataN("event_award", k, DB_EVENT_AWARD.STAGE);                --阶段
                    rightTable.StageCondition  = GetDataBaseDataN("event_award", k, DB_EVENT_AWARD.STAGE_CONDITION);    --阶段条件
                    rightTable.ItemType = GetDataBaseDataN("event_award", k, DB_EVENT_AWARD.ITEM_TYPE);  --奖励物品类型
                    rightTable.ItemCount = GetDataBaseDataN("event_award", k, DB_EVENT_AWARD.ITEM_AMOUNT);  --物品数
                    rightTable.Emoney= GetDataBaseDataN("event_award", k, DB_EVENT_AWARD.EMONEY);                --金币
                    rightTable.Stamina = GetDataBaseDataN("event_award", k, DB_EVENT_AWARD.STAMINA);  --军令
                    rightTable.Money = GetDataBaseDataN("event_award", k, DB_EVENT_AWARD.MONEY);  --银币  
                    rightTable.Soph = GetDataBaseDataN("event_award", k, DB_EVENT_AWARD.SOPH);                --将魂
                    rightTable.Repute = GetDataBaseDataN("event_award", k, DB_EVENT_AWARD.REPUTE);  --声望
                    
                    LogInfo("initdata Config_id  = %d, Stage = %d Emoney = %d",  Config_id,  rightTable.Stage, rightTable.Emoney);       
                    table.insert(Record.RightListTable, rightTable);
                end
            end                  
            table.insert(p.LeftTitleLIst, Record);
        end
    end
end

function p.GetParent()

	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end
	
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.RechargeReward);
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
        if p.UiCtr.btnClose == tag then                
			CloseUI(NMAINSCENECHILDTAG.RechargeReward);
            
        elseif p.UiCtr.btnRecharge == tag then  
            PlayerVIPUI.LoadUI();    
        
        elseif p.UiCtr.btnGet == tag then  
            p.SendRechargeInfo();        
        end  
        
    end
    
	return true;
end

---------------------------按钮重置功能-------------------------------------------------
function p.Refresh()
    LogInfo("function p.Refresh() begin");
    
    --如果每日签到页面打开着,那么重新刷新
    if not IsUIShow(NMAINSCENECHILDTAG.RechargeReward) then 
        return;
    end
    
    local layer = p.GetParent();    
    
    --显示左侧list控件
    local LeftListCont = GetScrollViewContainer(layer, p.UiList.ListLeft.ListCtrId);
    if LeftListCont == nil then
        return;
    end
    p.UiList.ListLeft.ListContaner = LeftListCont;
    
    LeftListCont:SetViewSize(LeftListSize);
    LeftListCont:EnableScrollBar(false);
    LeftListCont:RemoveAllView();
    
      --添加左侧list列表元素
    for i, v in pairs(p.LeftTitleLIst) do
       p.AddLeftListViewItem(LeftListCont,  i,  "VIPgift_1_L.ini");
    end
    
    LogInfo("p.Refresh setFocuse id = %d", p.UiList.ListLeft.CurFocus);
    p.SetLeftListFocus(p.UiList.ListLeft.CurFocus);
    
    --刷新显示右侧list列表等
    p.RefreshRightListContainer();
end

---------------------------刷新显示右侧list列表等-------------------------------------------------
function p.RefreshRightListContainer()
   
    local layer = p.GetParent();   

    --显示右侧list控件
    local RightListCont = GetScrollViewContainer(layer, p.UiList.ListRight.ListCtrId);
    if RightListCont == nil then
        return;
    end
    p.UiList.ListRight.ListContaner = RightListCont;
    
    RightListCont:SetViewSize(RightListSize);
    RightListCont:EnableScrollBar(false);
    RightListCont:RemoveAllView();
    
      --添加右侧list列表元素
    local num = table.getn(p.LeftTitleLIst[p.UiList.ListLeft.CurFocus].RightListTable);
    LogInfo("p.UiList.ListLeft.CurFocus = %d, num = %d",p.UiList.ListLeft.CurFocus,  num);
    
    for i, v in pairs(p.LeftTitleLIst[p.UiList.ListLeft.CurFocus].RightListTable) do
       p.AddRightListViewItem(RightListCont,  i,  "VIPgift_2_L.ini");  
    end
    
    p.UiList.ListRight.CurFocus = 1;
    p.SetRightListFocus(p.UiList.ListRight.CurFocus);
end
---------------------------将int型时间转换成string类型-------------------------------------
function p.ConvertIntTimeToString(nBegin, nEnd)  
    --例如 nBegin = 20120809  nEnd = 20120810
    --转化成 2012年08月09日00:00:00---2012年08月10日23:59:59
    local year = math.floor(nBegin/10000);
    local month = math.floor(nBegin%10000/100);
    if month < 10 then
        month = "0"..month;
    end
    local day = math.floor(nBegin%100);
    if day < 10 then
        day = "0"..day;
    end
    
    local yearEnd = math.floor(nEnd/10000);
    local monthEnd = math.floor(nEnd%10000/100);
    if monthEnd < 10 then
        monthEnd = "0"..monthEnd;
    end
    local dayEnd = math.floor(nEnd%100);
    if dayEnd < 10 then
        dayEnd = "0"..dayEnd;
    end
    
    local time = year..GetTxtPub("year")..month..GetTxtPub("month")..day..GetTxtPub("day").."00:00:00".."---"..yearEnd..GetTxtPub("year")..monthEnd..GetTxtPub("month")..dayEnd..GetTxtPub("day").."23:59:59"
    return time;
end
---------------------------设置左侧list控件焦点-------------------------------------
function p.SetLeftListFocus(nIndex)  
    local ScrollView = nil;
    local BtnFocus = nil; 
    local layer = p.GetParent();
    
    LogInfo("p.SetLeftListFocus focusid = %d, newId = %d",p.UiList.ListLeft.CurFocus,  nIndex);
       
    if p.UiList.ListLeft.CurFocus ~= nIndex then
        ScrollView = p.UiList.ListLeft.ListContaner:GetViewById(p.UiList.ListLeft.CurFocus);
        BtnFocus = GetButton(ScrollView, p.UiList.ListLeft.btnId);
        BtnFocus: TabSel(false);
        BtnFocus: SetFocus(false);
        LogInfo("p.SetLeftListFocus focusid = %d false",p.UiList.ListLeft.CurFocus);
    end

    p.UiList.ListLeft.CurFocus = nIndex;
    ScrollView = p.UiList.ListLeft.ListContaner:GetViewById(nIndex);
    BtnFocus = GetButton(ScrollView, p.UiList.ListLeft.btnId);
    BtnFocus: TabSel(true);
    BtnFocus: SetFocus(true); 
    LogInfo("p.SetLeftListFocus NewId = %d True",p.UiList.ListLeft.CurFocus);

    --显示活动内容,活动时间,广播内容
    local Info = p.LeftTitleLIst[p.UiList.ListLeft.CurFocus];    
    if Info == nil then
        return;
    end
    SetLabel(layer, p.UiCtr.contText, Info.Content);
    SetLabel(layer, p.UiCtr.broadText, Info.Broad);    
    SetLabel(layer, p.UiCtr.rightListTitleText, Info.Name .. GetTxtPub("shoe"));     

    local strTime = "";    
    LogInfo("TimeType = %d, InfoType = %d, First = %d, once = %d, total = %d", 
                    Info.TimeType, Info.Type, p.RechargeTimeBegin.First, p.RechargeTimeBegin.OnceFlag, p.RechargeTimeBegin.TotalFlag);
    
  
    --if Info.TimeType == 0 then --永久
    if Info.TimeType == 1 then --服务端配置起始结束时间
        strTime = p.ConvertIntTimeToString(Info.BeginTime, Info.EndTime);
    elseif Info.TimeType == 2 then --创建号码后多少天
        local iBeginTime = 0;
        if Info.Type == 3 then --首次充值
            iBeginTime = p.RechargeTimeBegin.First;
        elseif Info.Type == 4 then --单次充值 
            iBeginTime = p.RechargeTimeBegin.OnceFlag;
        elseif Info.Type == 5 then --累计充值
            iBeginTime = p.RechargeTimeBegin.TotalFlag;
        elseif Info.Type == 7 then --每日充值
            iBeginTime = p.RechargeTimeBegin.DailyFlag;     
        end
        local iEndTime = iBeginTime + Info.BeginTime * 24 * 60 * 60 - 1;  
                    
        local tTime = os.date( "*t", iBeginTime)
        strTime = strTime .. tTime["year"] .. GetTxtPub("year") .. tTime["month"] .. GetTxtPub("month") .. tTime["day"] .. GetTxtPub("day");
        strTime = strTime .. tTime["hour"] .. ":" .. tTime["min"] .. ":" .. tTime["sec"];     
        tTime = os.date( "*t", iEndTime)
        strTime = strTime .. "---"..tTime["year"] .. GetTxtPub("year") .. tTime["month"] .. GetTxtPub("month") .. tTime["day"] .. GetTxtPub("day");
        strTime = strTime .. tTime["hour"] .. ":" .. tTime["min"] .. ":" .. tTime["sec"];     
        LogInfo("strTime = %s", strTime);
    end

    
    SetLabel(layer, p.UiCtr.timeText, strTime);    

end

---------------------------设置右侧list控件焦点-------------------------------------
function p.SetRightListFocus(nIndex)  
    local layer = p.GetParent();   
    local ScrollView = nil;
    local BtnFocus = nil; 

    if p.UiList.ListRight.CurFocus ~= nIndex then
        ScrollView = p.UiList.ListRight.ListContaner:GetViewById(p.UiList.ListRight.CurFocus);
        BtnFocus = GetButton(ScrollView, p.UiList.ListRight.btnId);
        BtnFocus: TabSel(false);
        BtnFocus: SetFocus(false);
    end
    
    p.UiList.ListRight.CurFocus = nIndex;
    ScrollView = p.UiList.ListRight.ListContaner:GetViewById(nIndex);
    BtnFocus = GetButton(ScrollView, p.UiList.ListRight.btnId);
    BtnFocus: TabSel(true);
    BtnFocus: SetFocus(true); 
    
    local Info = p.LeftTitleLIst[p.UiList.ListLeft.CurFocus].RightListTable[p.UiList.ListRight.CurFocus];    
    if Info == nil then
        return;
    end
    
    --设置领取按钮是否可用
    local InfoLeft = p.LeftTitleLIst[p.UiList.ListLeft.CurFocus];

    --获取领取按钮控件
    local btnGet = GetButton(layer, p.UiCtr.btnGet);
    
    if InfoLeft.Type ==  p.ActionType.FIRST_PAY  then -- 首次充值
       --如果首充已领取或者充值金额不足那么置灰
       if p.RechargeState.First.Flag > 0 or p.RechargeState.First.Num <  Info.StageCondition  then
            btnGet:EnalbeGray(true);
       else
            btnGet:EnalbeGray(false);
       end
    elseif InfoLeft.Type ==  p.ActionType.ONCE_PAY  then -- 单次充值
        if p.RechargeState.OnceFlag[p.UiList.ListRight.CurFocus] < 1 then 
            btnGet:EnalbeGray(true);
       else
            btnGet:EnalbeGray(false);
       end
    elseif InfoLeft.Type ==  p.ActionType.TOTAL_PAY  then -- 累计充值
        if p.RechargeState.TotalFlag[p.UiList.ListRight.CurFocus] < 1 then 
            btnGet:EnalbeGray(true);
       else
            btnGet:EnalbeGray(false);
       end
    elseif InfoLeft.Type ==  p.ActionType.DAILY_PAY  then -- 每日充值
        if p.RechargeState.DailyFlag[p.UiList.ListRight.CurFocus] < 1 then 
            btnGet:EnalbeGray(true);
       else
            btnGet:EnalbeGray(false);
       end    
    end
    
    --领取的奖励提示
    local ShowText = "";
    
    if InfoLeft.Type == p.ActionType.DAILY_RETURN 
       or InfoLeft.Type == p.ActionType.ONLINE_RETURN  then
       ShowText = ShowText ..GetTxtPri("Daily_return").."\n";
       btnGet:EnalbeGray(true);
    end
    
    --奖励物品
    if (Info.ItemType ~= 0) and  (Info.ItemCount ~= 0) then
        ShowText = ShowText .."  ".. ItemFunc.GetName(Info.ItemType) .."X"..Info.ItemCount.."\n";
    end
    --金币
    if Info.Emoney ~= 0 then
        ShowText = ShowText .."  "..GetTxtPub("shoe").."X"..Info.Emoney.."\n";
    end
    --军令
    if Info.Stamina ~= 0 then
        ShowText = ShowText .."  "..GetTxtPub("Stamina").."X"..Info.Stamina.."\n";
    end
    --银币
    if Info.Money ~= 0 then
        ShowText = ShowText .."  "..GetTxtPub("coin").."X"..Info.Money.."\n";
    end
    --将魂
    if Info.Soph ~= 0 then
        ShowText = ShowText .."  "..GetTxtPub("JianHun").."X"..Info.Soph.."\n";
    end
    --声望
    if Info.Repute ~= 0 then
        ShowText = ShowText .."  "..GetTxtPub("ShenWan").."X"..Info.Repute.."\n";
    end  
    
    if InfoLeft.Type == p.ActionType.DAILY_RETURN 
       or InfoLeft.Type == p.ActionType.ONLINE_RETURN  then
       ShowText = ShowText ..string.format(GetTxtPri("Return_day"), Info.Param1).."\n";
    end
    
    SetLabel(layer, p.UiCtr.awardText, ShowText);
end
---------------------------添加左侧list控件元素-------------------------------------
function p.AddLeftListViewItem(container, nIndex, uiFile)

    LogInfo("function p.AddLeftListViewItem begin nIndex = %d", nIndex);
    local view = createUIScrollView();
    if view == nil then
        LogInfo("createUIScrollView failed");
        return;
    end
    
    container:SetViewSize(LeftListSize);
    
    view:Init(false);
    view:SetViewId(nIndex);
    view:SetTag(nIndex);  
    container:AddView(view);
    
    --初始化ui
    local uiLoad = createNDUILoad();
    if nil == uiLoad then
        layer:Free();
        return false;
    end

    uiLoad:Load(uiFile, view, p.OnLeftListViewUIEvent, 0, 0);
    p.refreshLeftListViewItem(view, nIndex);
end

---------------------------添加右侧list控件元素-------------------------------------
function p.AddRightListViewItem(container, nIndex, uiFile)

    LogInfo("function p.AddRightListViewItem begin nIndex = %d", nIndex);
    local view = createUIScrollView();
    if view == nil then
        LogInfo("createUIScrollView failed");
        return;
    end
    
    container:SetViewSize(RightListSize);
    
    view:Init(false);
    view:SetViewId(nIndex);
    view:SetTag(nIndex);  
    container:AddView(view);
    
    --初始化ui
    local uiLoad = createNDUILoad();
    if nil == uiLoad then
        layer:Free();
        return false;
    end

    uiLoad:Load(uiFile, view, p.OnRightListViewUIEvent, 0, 0);
    p.refreshRightListViewItem(view, nIndex);
end

---------------------------刷新控件元素-------------------------------------
function p.refreshRightListViewItem(view, iNum)
    LogInfo("p.refreshRightListViewItem Emoney = %d", p.LeftTitleLIst[p.UiList.ListLeft.CurFocus].RightListTable[iNum].StageCondition);
    SetLabel(view, p.UiList.ListRight.crtlText, SafeN2S(p.LeftTitleLIst[p.UiList.ListLeft.CurFocus].RightListTable[iNum].StageCondition)); 
    local btn = GetButton(view, p.UiList.ListRight.btnId);
    btn:SetParam1(iNum);   
    
    local  Textlabel = GetLabel(view, p.UiList.ListRight.crtlText); 
    Textlabel:SetFontColor(ccc4(255,255,255, 255));
    
    return;
end
  
  
---------------------------刷新控件元素-------------------------------------
function p.refreshLeftListViewItem(view, iNum)
    local  Textlabel = GetLabel(view, p.UiList.ListLeft.crtlText); 
    SetLabel(view, p.UiList.ListLeft.crtlText, p.LeftTitleLIst[iNum].Name); 
    Textlabel:SetFontColor(ccc4(255,255,255, 255));
    local btn = GetButton(view, p.UiList.ListLeft.btnId);
    btn:SetParam1(iNum);   
    
    return;
end

------------------左侧列表控件按键响应-------------------------------
function p.OnLeftListViewUIEvent(uiNode, uiEventType, param)
    local tag = uiNode:GetTag();
    LogInfo("p.OnUIEvent hit tag = %d", tag);
    local layer = p.GetParent();    
    
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
        
        if tag == p.UiList.ListLeft.btnId then  --左侧列表button按钮
            local btn = ConverToButton(uiNode);
            if(btn == nil) then
                LogInfo("btn is nil!");
                return;
            end
            
            p.SetLeftListFocus(btn:GetParam1()); 
            p.RefreshRightListContainer();
        end
    end
	return true;
end

------------------右侧列表控件按键响应-------------------------------
function p.OnRightListViewUIEvent(uiNode, uiEventType, param)
    local tag = uiNode:GetTag();
    LogInfo("p.OnUIEvent hit tag = %d", tag);
    local layer = p.GetParent();    
    
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
        
        if tag == p.UiList.ListRight.btnId then  --右侧列表button按钮
            local btn = ConverToButton(uiNode);
            if(btn == nil) then
                LogInfo("btn is nil!");
                return;
            end
            
            p.SetRightListFocus(btn:GetParam1()); 
        end
    end
	return true;
end

------------------首次充值消息响应---iRechNum重置金额-----iHasGet是否已经领取-----------------------
function p.SetFirstRechargeInfo(iRechNum, iHasGet, iBeginTime)
    LogInfo("First iRechNum = %d, iHasGet = %d", iRechNum, iHasGet);
    p.RechargeState.First.Num = iRechNum;
    p.RechargeState.First.Flag = iHasGet;
    p.RechargeTimeBegin.First = iBeginTime;
    p.Refresh();       
    LogInfo("First end");
end

------------------单次充值消息响应-----------iData从后开始每一位代表一个阶梯是否已经领取--------------------
function p.SetOnceRechargeInfo(iData, iBeginTime)

    local ReceiveData = iData;
    local temp = ReceiveData;
    LogInfo("tangziqin Once ReceiveData = %d, temp = %d", ReceiveData, temp);
    p.RechargeTimeBegin.OnceFlag = iBeginTime;

    for i = 25, 1, -1 do
        local num1 = 1;
        for j = i - 1, 1, -1 do
            num1 = num1*2;
        end
        
        local num2 = math.floor(temp/num1);
        p.RechargeState.OnceFlag[i] =  num2;
        
        if num2 > 0 then
            temp = temp - num1;
        end
   end
    
   for i, v in pairs(p.RechargeState.OnceFlag) do
       LogInfo("once v = %d", v);
   end           
            
    p.Refresh();    
    
    LogInfo("Once end");                                                      
end

------------------累计充值消息响应-----------------iData从后开始每一位代表一个阶梯是否已经领取---------------
function p.SetTotalRechargeInfo(iData, iBeginTime)
    local ReceiveData = iData;
    local temp = ReceiveData;
    p.RechargeTimeBegin.TotalFlag = iBeginTime;

    LogInfo("Total ReceiveData = %d, temp = %d", ReceiveData, temp);
    
    for i = 25, 1, -1 do
        local num1 = 1;
        for j = i - 1, 1, -1 do
            num1 = num1*2;
        end
        
        local num2 = math.floor(temp/num1);
        p.RechargeState.TotalFlag[i] =  num2;
        
        if num2 > 0 then
            temp = temp - num1;
        end
   end
   
   for i, v in pairs(p.RechargeState.TotalFlag) do
       LogInfo("total v = %d", v);
   end    

    p.Refresh();     
    
    LogInfo("total end");                                                                                                                                                                                              
end

------------------累计充值消息响应-----------------iData从后开始每一位代表一个阶梯是否已经领取---------------
function p.SetDailyRechargeInfo(iData, iBeginTime)
    local ReceiveData = iData;
    local temp = ReceiveData;
    p.RechargeTimeBegin.DailyFlag = iBeginTime;

    LogInfo("Total ReceiveData = %d, temp = %d", ReceiveData, temp);
    
    for i = 25, 1, -1 do
        local num1 = 1;
        for j = i - 1, 1, -1 do
            num1 = num1*2;
        end
        
        local num2 = math.floor(temp/num1);
        p.RechargeState.DailyFlag[i] =  num2;
        
        if num2 > 0 then
            temp = temp - num1;
        end
   end
   
   for i, v in pairs(p.RechargeState.DailyFlag) do
       LogInfo("daily v = %d", v);
   end    

    p.Refresh();     
    
    LogInfo("daily end");                                                                                                                                                                                              
end

------------------首次充值消息响应-------------------------------
function p.SendRechargeInfo()  
    LogInfo("send begin"); 

	local netdata = createNDTransData(NMSG_Type._MSG_PLAYER_ACTION_OPERATE);
    
    LogInfo("send begin leftIndex = %d, rightIndex = %d", p.UiList.ListLeft.CurFocus, p.UiList.ListRight.CurFocus); 
    
    local InfoLeft = p.LeftTitleLIst[p.UiList.ListLeft.CurFocus];
    
    if InfoLeft.Type ==  p.ActionType.FIRST_PAY  then -- 首次充值
        LogInfo("send 5"); 
        netdata:WriteByte(5);
    elseif InfoLeft.Type ==  p.ActionType.ONCE_PAY  then -- 单次充值
        LogInfo("send 6"); 
        netdata:WriteByte(6);
    elseif InfoLeft.Type ==  p.ActionType.TOTAL_PAY  then -- 累计充值
        LogInfo("send 7"); 
        netdata:WriteByte(7);
    elseif InfoLeft.Type ==  p.ActionType.DAILY_PAY  then -- 每日充值
        LogInfo("send 8"); 
        netdata:WriteByte(8);   
    end
    local Num = p.UiList.ListRight.CurFocus;
    netdata:WriteInt(Num);	
    netdata:WriteInt(0);	   
	SendMsg(netdata);	
	netdata:Free();	
    LogInfo("send  end"); 
	return true;	
end


--获取活动数据是否需要下发的标志
function p.GetIfNeedDown()  
	return p.NeedDownFlag;
end
