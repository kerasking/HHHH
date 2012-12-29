---------------------------------------------------
--描述: 角色注册界面
--时间: 2012.3.25
--作者: HJQ
---------------------------------------------------

Login_RegRoleUI = {}
local p = Login_RegRoleUI;

local ID_ROLE_EDIT_NAME     = 5;    --名字输入控件
local ID_ROLE_GRIDDLE       = 6;    --色子
local ID_ROLE_START_GAME     = 11;   --开始游戏
local ID_ROLE_LIST          = 44;   --选择角色列表
local ID_ROLE_BACK          = 7;    --返回
local ID_ROLE_BG            = 1;
local ID_ROLE_ZY            = 2;    --职业图片
local ID_ROLE_ANIMATE       = 3;    --选人动画
local CONTAINTER_X = 0;
local CONTAINTER_Y = 0;

local RoleViewSize = CGSizeMake(140*ScaleFactor,180*ScaleFactor);

local AnimateGroups = {Stand = 0, CheckShow = 1, CheckStand = 2,}   --动画组说明 0.未选中    1.选中姿势    2.选中站立

p.nTimerID = nil;

--BTNID,PICID,LOOKFACE,职业ID
p.BtnTagList={
{10000001,1,"warriormale_reg.spr"},
{10000002,1,"warriorfemale_reg.spr"},
{10000003,2,"archermale_reg.spr"},
{10000004,2,"archerfemale_reg.spr"},
{10000005,3,"magemale_reg.spr"},
{10000006,3,"magefemale_reg.spr"},
};

p.Pic = {
    "register_word1.png",
    "register_word2.png",
    "register_word3.png",
}

p.TAG_DESCS = {19,20,21,}   --武将说明图片

p.Name=nil;
p.Profession=0;
p.Lookface=0;


function p.LoadUI()
    local bFlag = HideLoginUI(NMAINSCENECHILDTAG.Login_RegRoleUI);
    if(bFlag) then
        LogInfo("bFlag true");
        return true;
    end

    local scene = GetRunningScene();
        if scene == nil then
            LogInfo("scene == nil,load Login_MainUI failed!");
        return false;
    end
    --scene:RemoveAllChildren(true);
    local layer = createNDUILayer();
    if layer == nil then
        return false;
    end
    layer:Init();
    layer:SetTag(NMAINSCENECHILDTAG.Login_RegRoleUI);
    layer:SetFrameRect(RectFullScreenUILayer);
    scene:AddChild(layer);
    --初始化ui
    local uiLoad = createNDUILoad();
    if nil == uiLoad then
        layer:Free();
        return false;
    end
    uiLoad:Load("login_3.ini", layer, p.OnUIEvent, 0, 0);--创建角色
    uiLoad:Free();
    
    p.RefreshUI();
    
    p.InitUI();
    
    p.RandName();
    
    return true;
end

--刷新
function p.RefreshUI()
    local container = p.GetRoleListContainer();
    if(container == nil) then
        LogInfo("container is nil!");
    end
    container:SetSizeView(RoleViewSize);
    for i,v in ipairs(p.BtnTagList) do
        LogInfo("v:[%d]",v[1]);
        local view = createUIScrollViewExpand();
        
        view:Init(false);
        view:SetViewId(i);
        view:SetTag(i);
        

        --初始化ui
        local uiLoad = createNDUILoad();
        if nil == uiLoad then
            return false;
        end
	
        uiLoad:Load("login_3_L.ini", view, p.OnUIEvent, 0, 0);
           
        --实例化每一项
        p.RefreshRankItem(view,i);
        
        uiLoad:Free();
        
        container:AddView(view);
    end
    p.SetCurrentAnimate();
end

function p.RefreshRankItem(view, i)

    local zyimg = GetImage(view,ID_ROLE_ZY);
    zyimg:SetPicture(p.geZYPic(p.BtnTagList[i][2]));
    local zypic = zyimg:GetPicture();
    if(zypic) then
        zypic:SetIsTran(true);
    end
    
    local bgimg = GetImage(view,ID_ROLE_BG);
    local bgpic = bgimg:GetPicture();
    if(bgpic) then
        bgpic:SetIsTran(true);
    end
    
    local szAniPath = NDPath_GetAnimationPath();
    local ani = RecursivUISprite(view, {ID_ROLE_ANIMATE});
    ani:ChangeSprite( szAniPath .. p.BtnTagList[i][3]);
    
end

function p.geZYPic(index)
	local pool = DefaultPicPool();
	return pool:AddPicture(GetSMImg00Path("register/"..p.Pic[index]), false);
end

function p.getUiLayer()
    local scene = GetRunningScene();
    if not CheckP(scene) then
        return nil;
    end

    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.Login_RegRoleUI);
    if not CheckP(layer) then
        LogInfo("nil == layer")
        return nil;
    end
    return layer;
end

function p.InitUI()
    local nDataNum = table.getn(p.BtnTagList);
    if nDataNum < 1 then
        LogInfo("InitUI NULL Data!");
        return;
    end

    local pNameEditUiNode = RecursiveUINode(p.getUiLayer(),{ID_ROLE_EDIT_NAME});
    local pNameEdit = ConverToEdit(pNameEditUiNode);
    if CheckP(pNameEdit) then
        pNameEdit:SetMaxLength(5);
        pNameEdit:SetMinLength(2);
    end

    --默认职业
    --p.RefreshByDataIdx(1);
end

function p.RefreshByDataIdx(idx)
    local InitLayer = p.getUiLayer();
    
    local descIndex = math.ceil(idx/2);
    for i=1,#p.TAG_DESCS do
        local desc = GetImage(InitLayer,p.TAG_DESCS[i]);
        if(descIndex == i)then
            desc:SetVisible(true);
        else
            desc:SetVisible(false);
        end
    end
    
    
    p.Profession = p.BtnTagList[idx][2];
    p.LookFace   = p.BtnTagList[idx][3];
end

function p.OnUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
        if tag == ID_ROLE_START_GAME then
            --检查
            if nil == p.Name then
                --报提示
                return true;
            end
            LogInfo("CreateName===%s",p.Name);
            --MsgLogin.SendCreateRoleReq(p.Name,p.Profession,p.LookFace);
            
            
            local bFlag = p.LegalStrCheck(p.Name);
            if(bFlag == false) then
                CommonDlgNew.ShowTipDlg(GetTxtPri("LR_T1"), 2);
            end
            
            local roleContainer = p.GetRoleListContainer();
            local nIndex = roleContainer:GetCurrentIndex();
            local pRole = p.BtnTagList[nIndex+1];
            MsgLogin.SendCreateRoleReq(p.Name,pRole[2],pRole[1]);
        elseif tag == ID_ROLE_OLDUSER_LOGIN then
            Login_ServerUI.LoadUI();
            return true;
        elseif tag == ID_ROLE_GRIDDLE then
            --色子
            p.RandName();
        elseif tag == ID_ROLE_BACK then
            Login_ServerUI.LoadUI();
            Login_ServerUI.LoginGameNew()
        else
            local nProfNum = table.getn(p.BtnTagList);
            for i=1, nProfNum do
                if p.BtnTagList[i][1] == tag then
                    --p.RefreshByDataIdx(i);
                end
            end
        end
	elseif uiEventType == NUIEventType.TE_TOUCH_TABLE_FOCUS then
    elseif uiEventType == NUIEventType.TE_TOUCH_EDIT_INPUT_FINISH then
    -- 用户按下键盘的返回键
        if tag == ID_ROLE_EDIT_NAME then
            local edit = ConverToEdit(uiNode);
            if CheckP(edit) then
                p.Name = edit:GetText();
                LogInfo("eidt text [%s][%s]", edit:GetText(),p.Name);
            end
        end
    elseif uiEventType == NUIEventType.TE_TOUCH_EDIT_TEXT_CHANGE then
    -- edit中的文本变更
        if tag == ID_ROLE_EDIT_NAME then
        end
        
    elseif uiEventType == NUIEventType.TE_TOUCH_SC_VIEW_IN_BEGIN then
        if tag == ID_ROLE_LIST then
            p.StopCurrentAnimate();
        end
    elseif uiEventType == NUIEventType.TE_TOUCH_SC_VIEW_IN_END then
        if tag == ID_ROLE_LIST then
            p.SetCurrentAnimate();
        end
	end

	return true;
end


function p.RandName()
    local s_Name = G_COMMON_CREATE_NAME(2);
    local InitLayer = p.getUiLayer();
    local uiNode = GetUiNode(InitLayer,ID_ROLE_EDIT_NAME);
    if CheckP(uiNode) then
        local edit = ConverToEdit(uiNode);
        edit:SetText(s_Name);
        p.Name = s_Name;
    end
end


--停止当前动画
function p.StopCurrentAnimate()
    LogInfo("p.StopCurrentAnimate");
    local roleContainer = p.GetRoleListContainer();
    local tot = roleContainer:GetViewCount();
    local pre = roleContainer:GetPreIndex();
    
    local view = roleContainer:GetViewByIndex(pre);
    local ani = RecursivUISprite(view, {ID_ROLE_ANIMATE});
    ani:PlayAnimation(AnimateGroups.Stand,true);
    
    if(p.nTimerID) then
        UnRegisterTimer( p.nTimerID );
    end
end

--设置当前选中人物的动画
function p.SetCurrentAnimate()
    LogInfo("p.SetCurrentAnimate");
    local roleContainer = p.GetRoleListContainer();
    local tot = roleContainer:GetViewCount();
    local cur = roleContainer:GetCurrentIndex();
    
    local view = roleContainer:GetViewByIndex(cur);
    local ani = RecursivUISprite(view, {ID_ROLE_ANIMATE});
    
    
    ani:PlayAnimation(AnimateGroups.CheckShow,true);
    
    if ( p.nTimerID ) then
		UnRegisterTimer( p.nTimerID );
	end
    p.nTimerID = RegisterTimer( p.OnTimerCoutDownCounter, 1/24 );
    
end

function p.OnTimerCoutDownCounter( nTimerID )
    local roleContainer = p.GetRoleListContainer();
    if ( roleContainer == nil ) then
        LogInfo( "Login_RegRoleUI: OnTimerCoutDownCounter()  roleList is nil" );
		UnRegisterTimer( p.nTimerID );
		p.nTimerID	= nil;
		return;
    end
    
    local cur = roleContainer:GetCurrentIndex();
    local view = roleContainer:GetViewByIndex(cur);
    if( view == nil ) then
        LogInfo( "Login_RegRoleUI: OnTimerCoutDownCounter()  view is nil" );
		UnRegisterTimer( p.nTimerID );
		p.nTimerID	= nil;
		return;
    end
    
    local pSpriteNode = RecursivUISprite(view, {ID_ROLE_ANIMATE});
    if( pSpriteNode == nil ) then
        LogInfo( "Login_RegRoleUI: OnTimerCoutDownCounter()  pSpriteNode is nil" );
		UnRegisterTimer( p.nTimerID );
		p.nTimerID	= nil;
		return;
    end
    
    if ( pSpriteNode:IsAnimationComplete() ) then
        LogInfo( "Login_RegRoleUI: OnTimerCoutDownCounter()  IsAnimationComplete" );
        pSpriteNode:PlayAnimation(AnimateGroups.CheckStand,true);
		UnRegisterTimer( p.nTimerID );
		p.nTimerID			= nil;
    end
end


function p.LegalStrCheck( nStr )
    if( not CheckS(nStr) or nStr == "" ) then
        return false;
    end
    local nLen = string.len(nStr);
    for i=1,nLen do
        local ch = string.sub(nStr,i,1);
        if(ch == " ") then
            return false;
        elseif(ch == ";") then
            return false;
        elseif(ch == ",") then
            return false;
        elseif(ch == "/") then
            return false;
        elseif(ch == "\\") then
            return false;
        elseif(ch == "=") then
            return false;
        elseif(ch == "%") then
            return false;
        elseif(ch == "@") then
            return false;
        elseif(ch == "\'") then
            return false;
        elseif(ch == "#") then
            return false;
        end
    end
    
    return true;
end


--获得角色列表
function p.GetRoleListContainer()
    local layer =  p.getUiLayer();
    local container = GetScrollContainerExpand(layer,ID_ROLE_LIST);
    return container;
end
--RegisterGlobalEventHandler(GLOBALEVENT.GE_LOGIN_GAME,"Login_ServerUI.LoadUI", p.LoadUI);