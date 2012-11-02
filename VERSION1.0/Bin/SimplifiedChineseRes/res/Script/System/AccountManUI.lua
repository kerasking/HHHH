---------------------------------------------------
--描述: 账号管理界面
--时间: 2012.5.26
--作者: LLF
---------------------------------------------------

AccountManUI = {}
local p = AccountManUI

local ID_ACCOUNT_CTRL_BUTTON_474    = 474;  --关闭
local ID_ACCOUNT_CTRL_BUTTON_471       = 471;        --上一页
local ID_ACCOUNT_CTRL_BUTTON_472       = 472;        --下一页
local ID_TEXT_387                       =387;   --文本
local ID_CTRL_VERTICAL_LIST_388     = 388;  --帐号列表容器

local ID_CTRL_SERVER_BTN_434        = 434;
local ID_CTRL_SERVER_BTN_435        = 435;
local ID_CTRL_SERVER_BTN_436        = 436;
local ID_CTRL_SERVER_BTN_437        = 437;
local ID_CTRL_SERVER_BTN_438        = 438;
local ID_CTRL_SERVER_BTN_439        = 439;
local ID_CTRL_SERVER_BTN_440        = 440;
local ID_CTRL_SERVER_BTN_441        = 441;
local ID_CTRL_SERVER_BTN_442        = 442;
local ID_CTRL_SERVER_BTN_443        = 443;
--local ID_CTRL_SERVER_BTN_444        = 444;

local ID_CTRL_BUTTON_446            = 446; ---列表中的帐号
local winsize = GetWinSize();

p.AccountList={};
p.CustomServerTag={}; --最后登陆列表
p.OtherServerTag={};--其他服务器列表
p.PageNum=1;
p.CurPage=1;
p.SelAccount=nil;
p.SelServer=nil;
p.Custom = false;

function p.GetParent()
	local scene = GetSMGameScene();
	if nil == scene then   
		return nil;
	end
	
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.AccountManUI);
	if nil == layer then
		return nil;
	end
	
	return layer;
end

function p.LoadUI()
	LogInfo("p.LoadUI")
	local scene=GetSMGameScene();
	if scene == nil then
		LogInfo("scene = nil,load ProblemUI failed!");
		return;
	end
	local layer = createNDUILayer(); 
	if layer == nil then
		LogInfo("scene = nil,2");
		return  false;
	end
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.AccountManUI);
	layer:SetFrameRect(CGRectMake(winsize.w*0.08, winsize.h*0.08, winsize.w, winsize.h));
	_G.AddChild(scene, layer, NMAINSCENECHILDTAG.AccountManUI);	
	
	local uiLoad=createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		LogInfo("scene = nil,4");
		return false;
	end
	LogInfo("before SM_SYS_Account.ini")
	uiLoad:Load("SM_SYS_Account.ini",layer,p.OnUIEvent,0,0);
	LogInfo("after SM_SYS_Account.ini")
	uiLoad:Free();

    local containter = GetScrollViewContainer(layer,ID_CTRL_VERTICAL_LIST_388);
    if (nil == containter) then
        layer:Free();
        LogInfo("scene = nil,3");
        return false;
    end
    containter:SetViewSize(CGSizeMake(containter:GetFrameRect().size.w, containter:GetFrameRect().size.h/8));
    p.Init();
end

function p.InitAccountData()
    local nAccount = table.getn(p.AccountList);
    for i=0,nAccount do
        table.remove(p.AccountList);
    end
    local nRowNum = Sqlite_SelectData("SELECT name,pwd FROM account ORDER BY login_time DESC;",2);
    if nRowNum > 0 then
        for n=1,nRowNum do
            table.insert(p.AccountList,{n,Sqlite_GetColDataS(n-1,0),SimpleDecode(Sqlite_GetColDataS(n-1,1))});
        end
    end
end

function p.InitServerData()
    local nSrvNum = table.getn(p.CustomServerTag);
    LogInfo("table.insert[%d][%d]",nSrvNum,table.getn(p.OtherServerTag));
    for i=0,nSrvNum do
        table.remove(p.CustomServerTag);
    end
    nSrvNum = table.getn(p.OtherServerTag);
    for i=0,nSrvNum do
        table.remove(p.OtherServerTag);
    end
    LogInfo("table.insert[%d][%d]",nSrvNum,table.getn(p.OtherServerTag));
    --初始化列表
    local nRowNum = Sqlite_SelectData("SELECT show_name,login_name,state,login_time FROM server WHERE type > 0 ORDER BY login_time DESC;",4);
    if nRowNum > 0 then
        local nCustCnt = 0;
        for n=1,nRowNum do
            if Sqlite_GetColDataN(n-1,3) > 0 and nCustCnt < 4 then
                nCustCnt=nCustCnt+1;
                table.insert(p.CustomServerTag,{n,Sqlite_GetColDataS(n-1,0),Sqlite_GetColDataS(n-1,1),Sqlite_GetColDataN(n-1,2)});
            else
                table.insert(p.OtherServerTag,{n,Sqlite_GetColDataS(n-1,0),Sqlite_GetColDataS(n-1,1),Sqlite_GetColDataN(n-1,2)});
            end
        end
    end   
    p.PageNum = getIntPart(table.getn(p.OtherServerTag)/6);
    if table.getn(p.OtherServerTag)%6 > 0 then
        p.PageNum = p.PageNum+1;
    end
end

function p.Init()
    p.InitAccountData();
    p.InitServerData();
    p.SelAccount=nil;
    p.SelServer=nil;
    --初始化帐号和服务器界面
    local container = GetScrollViewContainer(p.getUiLayer(),ID_CTRL_VERTICAL_LIST_388);
    if nil == container then
        LogInfo("nil == container");
        return;
    end
    container:RemoveAllView();
    local nAccount = table.getn(p.AccountList);
    for i=1,nAccount do
        local view = createUIScrollView();
        if view ~= nil then
            local szAccount = p.AccountList[i][2];
            LogInfo("createUIScrollView==i[%d]nAccount[%d][%s]",i,nAccount,szAccount);
            view:Init(true);
            --local nOffsetY	= container:GetViewSize().h + (i-1);
            --LogInfo("createUIScrollView==nOffsetY[%d]", nOffsetY);
            view:SetViewId(i);
            container:AddView(view);
            local uiLoad = createNDUILoad();
            if uiLoad ~= nil then
                uiLoad:Load("SM_SYS_Account_L.ini",view,p.OnSelActUIEvent,8,0);
                uiLoad:Free();
            end
LogInfo("QueryButton[%d]",ID_CTRL_BUTTON_446);
            local pAcctBtn = GetButton(view, ID_CTRL_BUTTON_446);
            if CheckP(pAcctBtn) then
LogInfo("2====QueryButton[%d]",ID_CTRL_BUTTON_446);
                --LogInfo("CheckBox[%s]===", p.AccountList[i][2]);
                pAcctBtn:SetTitle(szAccount);
                --LogInfo("CheckBox[%s]", p.AccountList[i][2]);
            end
        end
    end
    --初始化服务器
LogInfo("2====p.PageNum[%d]",p.PageNum);
    if p.PageNum > 1 then
        local strPage = "1/"..p.PageNum;
        local label = GetLabel(p.getUiLayer(),ID_TEXT_387);
        if CheckP(label) then
            label:SetText(strPage);
        end
        local pageUpBtn = RecursiveUINode(p.getUiLayer(),{ID_ACCOUNT_CTRL_BUTTON_471});
        if CheckP(pageUpBtn) then
            pageUpBtn:SetVisible(false);
        end
    else
        local pageDownBtn = RecursiveUINode(p.getUiLayer(),{ID_ACCOUNT_CTRL_BUTTON_472});
        if CheckP(pageDownBtn) then
            pageDownBtn:SetVisible(false);
        end
        local pageUpBtn = RecursiveUINode(p.getUiLayer(),{ID_ACCOUNT_CTRL_BUTTON_471});
        if CheckP(pageUpBtn) then
            pageUpBtn:SetVisible(false);
        end
    end
    --初始化最近登陆
    local nSrvNo = 1;
    local srvNum = table.getn(p.CustomServerTag);
    for n=ID_CTRL_SERVER_BTN_434,ID_CTRL_SERVER_BTN_437 do
        local BtnUiNode = RecursiveUINode(p.getUiLayer(),{n});
        local srvBtn = GetButton(p.getUiLayer(),n);
        if CheckP(srvBtn) then
            if nSrvNo <= srvNum then
                local serverName = p.CustomServerTag[nSrvNo][2];
                srvBtn:SetTitle(serverName);
                BtnUiNode:SetVisible(true);
            else
                BtnUiNode:SetVisible(false);
            end
        end
        nSrvNo = nSrvNo+1;
    end
    --初始化服务器列表
    nSrvNo = 1;
    srvNum = table.getn(p.OtherServerTag);
    for n=ID_CTRL_SERVER_BTN_438,ID_CTRL_SERVER_BTN_443 do
        local BtnUiNode = RecursiveUINode(p.getUiLayer(),{n});
        local srvBtn = GetButton(p.getUiLayer(),n);
        if CheckP(srvBtn) then
            if nSrvNo <= srvNum then
                local serverName = p.OtherServerTag[nSrvNo][2];
                srvBtn:SetTitle(serverName);
                BtnUiNode:SetVisible(true);
            else
                BtnUiNode:SetVisible(false);
            end
LogInfo("BtnID[%d]ServerName[%s]",n,p.OtherServerTag[nSrvNo][2]);
            nSrvNo = nSrvNo+1;
        end
    end
end

function p.getUiLayer()
    local scene = GetSMGameScene();
    if not CheckP(scene) then
        return nil;
    end

    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.AccountManUI);
    if not CheckP(layer) then
        LogInfo("nil == layer")
        return nil;
    end
    return layer;
end

function p.OnUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		local scene = GetSMGameScene();
		if ID_ACCOUNT_CTRL_BUTTON_474 == tag then
			scene:RemoveChildByTag(NMAINSCENECHILDTAG.AccountManUI, true);
		elseif ID_ACCOUNT_CTRL_BUTTON_471 == tag then
            p.PageUp();
        elseif ID_ACCOUNT_CTRL_BUTTON_472 == tag then
            p.PageDown();
        else
            p.SelectServer(tag);
		end
	end
	
	return true;
end

function p.PageUp()
    if p.CurPage < 2 then
        local pageUpBtn = RecursiveUINode(p.getUiLayer(),{ID_ACCOUNT_CTRL_BUTTON_471});
        if CheckP(pageUpBtn) then
            pageUpBtn:SetVisible(false);
        end
        return;
    else
        p.CurPage = p.CurPage-1;
        if p.CurPage == 1 then
            local pageUpBtn = RecursiveUINode(p.getUiLayer(),{ID_ACCOUNT_CTRL_BUTTON_471});
            if CheckP(pageUpBtn) then
                pageUpBtn:SetVisible(false);
            end
        end
    end
    
    --刷新列表
    local nSrvNo = (p.CurPage-1)*6+1;
    local srvNum = table.getn(p.OtherServerTag);
    for n=ID_CTRL_SERVER_BTN_438,ID_CTRL_SERVER_BTN_443 do
        local BtnUiNode = RecursiveUINode(p.getUiLayer(),{n});
        local srvBtn = GetButton(p.getUiLayer(),n);
        if CheckP(srvBtn) then
            if nSrvNo <= srvNum then
                local serverName = p.OtherServerTag[nSrvNo][2];
                srvBtn:SetTitle(serverName);
                BtnUiNode:SetVisible(true);
            else
                BtnUiNode:SetVisible(false);
            end
            nSrvNo = nSrvNo+1;
        end
    end
end

function p.PageDown()
    if p.CurPage >= p.PageNum then
        return;
    else
        p.CurPage = p.CurPage+1;
        if p.CurPage >= p.PageNum then
            local pageDownBtn = RecursiveUINode(p.getUiLayer(),{ID_ACCOUNT_CTRL_BUTTON_472});
            if CheckP(pageDownBtn) then
                pageDownBtn:SetVisible(false);
            end
            local pageUpBtn = RecursiveUINode(p.getUiLayer(),{ID_ACCOUNT_CTRL_BUTTON_471});
            if CheckP(pageUpBtn) then
                pageUpBtn:SetVisible(true);
            end
        end
        local strPage = p.CurPage.."/"..p.PageNum;
        local label = GetLabel(p.getUiLayer(),ID_TEXT_387);
        if CheckP(label) then
            label:SetText(strPage);
        end
    end
    --刷新服务器列表
    local nSrvNo = (p.CurPage-1)*6+1;
    local srvNum = table.getn(p.OtherServerTag);
    for n=ID_CTRL_SERVER_BTN_438,ID_CTRL_SERVER_BTN_443 do
        local BtnUiNode = RecursiveUINode(p.getUiLayer(),{n});
        local srvBtn = GetButton(p.getUiLayer(),n);
        if CheckP(srvBtn) then
            if nSrvNo <= srvNum then
                local serverName = p.OtherServerTag[nSrvNo][2];
                srvBtn:SetTitle(serverName);
                BtnUiNode:SetVisible(true);
            else
                BtnUiNode:SetVisible(false);
            end
            nSrvNo = nSrvNo+1;
        end
    end
end

function p.SelectServer(id)
    if id >= ID_CTRL_SERVER_BTN_434 and id < ID_CTRL_SERVER_BTN_438 then
        p.SelServer = id-ID_CTRL_SERVER_BTN_434+1;--p.CustomServerTag[id-ID_CTRL_SERVER_BTN_434+1][1];
        p.Custom = true;
    elseif id >= ID_CTRL_SERVER_BTN_438 and id <= ID_CTRL_SERVER_BTN_443 then
        p.SelServer = (p.CurPage-1)*6+id-ID_CTRL_SERVER_BTN_438+1;--p.OtherServerTag[(p.CurPage-1)*6+id-ID_CTRL_SERVER_BTN_438+1][1];
    end

    if p.SelAccount ~= nil then
        --选全开始登陆
        QuitGame();
        LoadingSceneUI.ShowSceneLoading("正在登陆请稍后.....",p.QuitGame,10);
        p.Login();
    end

    --[[
    for n=ID_CTRL_SERVER_BTN_434,ID_CTRL_SERVER_BTN_443 do
        local Btn = RecursiveUINode(p.getUiLayer(),{n});
        if CheckP(Btn) and n ~= id then
            Btn:SetFocus(false);
        end
    end
    --]]
end

function p.QuitGame()
    --判断是否登陆成功
    QuitGame();
    Login_ServerUI.LoadUI();
    CommonDlg.ShowTipInfo("系统错误", "登陆游戏服务器超时,请稍候尝试!", nil, 30);
end

function p.SelectAccount(id)
    p.SelAccount = id;
    if p.SelServer ~= nil then
        --选全开始登陆
        local scene = GetSMGameScene();
        scene:RemoveChildByTag(NMAINSCENECHILDTAG.AccountManUI, true);
        --Login_LoadingUI.LoadUI();
        QuitGame();
        LoadingSceneUI.ShowSceneLoading("正在登陆请稍后.....",p.QuitGame(),60);
        p.Login();
    else
        --保持一个焦点
        local container = GetScrollViewContainer(p.getUiLayer(),ID_CTRL_VERTICAL_LIST_388);
        if nil == container then
            LogInfo("nil == container");
            return;
        end
        local nAccount = table.getn(p.AccountList);
        for i=1,nAccount do
            local view = container:GetViewById(i);
            local bActBtn = RecursiveUINode(view,{ID_CTRL_BUTTON_446});
            if CheckP(bActBtn) and id ~= i then
                local bBtn = ConverToButton(bActBtn);
                if CheckP(bBtn) then
                    bBtn:SetFocus(false);
                end
            elseif CheckP(bActBtn) then
                local bBtn = ConverToButton(bActBtn);
                if CheckP(bBtn) then
                    bBtn:SetFocus(true);
                end
            end
        end
    end
end

function p.Login()
LogInfo("p.Login()=====>1");
    if p.SelAccount == nil or p.SelServer == nil then
        return;
    end
LogInfo("p.Login()=====>2");
    local Account=p.AccountList[p.SelAccount][2];
    local Password=p.AccountList[p.SelAccount][3];
    local Server=nil;
LogInfo("p.Login()=====>3");
    if p.Custom == true then
       Server =  p.CustomServerTag[p.SelServer][3];
    else
       Server =  p.OtherServerTag[p.SelServer][3];
    end
LogInfo("p.Login()=====>4");
    SwichKeyToServer(Account,Password,Server);
LogInfo("p.Login()=====>5");
    local sTime = os.date("%Y%m%d%H%M", os.time());
LogInfo("p.Login()=====>6");
    local SqlUpdSrvTime = "UPDATE server SET login_time ="..sTime.." where login_name =\'"..Server.."\';";
    local SqlUpdActTime="UPDATE account SET login_time ="..sTime.." where name =\'"..Account.."\';";
    Sqlite_ExcuteSql(SqlUpdSrvTime);
    Sqlite_ExcuteSql(SqlUpdActTime);
end

function p.OnSelActUIEvent(uiNode, uiEventType, param)
    local tag = uiNode:GetTag();
    if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
        if ID_CTRL_BUTTON_446 == tag then
            local view=PRecursiveSV(uiNode, 1);
            if not CheckP(view) then
                return true;
            end
            local id=view:GetViewId();
            p.SelectAccount(id);
        end
    elseif uiEventType == NUIEventType.TE_TOUCH_TABLE_FOCUS then
    end
    return true;
end