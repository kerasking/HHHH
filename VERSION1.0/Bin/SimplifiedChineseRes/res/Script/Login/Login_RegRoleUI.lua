---------------------------------------------------
--描述: 角色注册界面
--时间: 2012.3.25
--作者: HJQ
---------------------------------------------------

Login_RegRoleUI = {}
local p = Login_RegRoleUI;

local CONTAINTER_X = 0;
local CONTAINTER_Y = 0;

local ID_PROFESSION_LABEL      =52;  --职业标签
local ID_PROFESSION_DES_LABEL  =55;  --职业描述
local ID_PROFESSION_OTHER_DES_LABEL = 57; --其他属性描述
local ID_ROLE_START_GAME = 35; --开始游戏
local ID_ROLE_OLDUSER_LOGIN = 56;--老玩家登陆
local ID_ROLE_GRIDDLE = 42; --色子
local ID_ROLE_EDIT_NAME=53; --名字输入控件

--BTNID,职业标签，职业标签图片,职业描述，其他属性描述,职业ID,对应LOOKFACE
p.BtnTagList={
{38,'拳宗','create_role/word_boxing_r.png','近战物理攻击职业,拥有较高的韧性与格挡能力.拳宗格挡后的反击往往会在战斗中起到关键的作用.','韧性+20%\r\n格挡+25%',3,10000005},
{39,'拳宗','create_role/word_boxing_r.png','近战物理攻击职业,拥有较高的韧性与格挡能力.拳宗格挡后的反击往往会在战斗中起到关键的作用.','韧性+20%\r\n格挡+25%',3,10000006},
{48,'剑圣','create_role/word_sword_r.png','近战物理攻击职业,拥有较高的命中率和闪避率.剑圣用其飘逸的身法闪避着对手的攻击,并总是能击中对手.','闪避+15%\r\n暴击+15%\r\n命中+15%',1,10000001},
{49,'剑圣','create_role/word_sword_r.png','近战物理攻击职业,拥有较高的命中率和闪避率.剑圣用其飘逸的身法闪避着对手的攻击,并总是能击中对手.','闪避+15%\r\n暴击+15%\r\n命中+15%',1,10000002},
{50,'奇侠','create_role/word_chivalrous_r.png','远程物理攻击职业,拥有较高的暴击与暴击伤害.没有任何一个职业不惧怕奇侠的暴击,在战斗中总能给对手致命一击.','暴击+30%\r\n必杀+10%\r\n闪避+5%',2,10000003},
{51,'奇侠','create_role/word_chivalrous_r.png','远程物理攻击职业,拥有较高的暴击与暴击伤害.没有任何一个职业不惧怕奇侠的暴击,在战斗中总能给对手致命一击.','暴击+30%\r\n必杀+10%\r\n闪避+5%',2,10000004},
};

p.Name=nil;
p.Profession=0;
p.Lookface=0;


function p.LoadUI()
    local scene = GetSMLoginScene();
        if scene == nil then
            LogInfo("scene == nil,load Login_MainUI failed!");
        return false;
    end
    scene:RemoveAllChildren(true);
    local layer = createNDUILayer();
    if layer == nil then
        return false;
    end
    layer:Init();
    layer:SetTag(NMAINSCENECHILDTAG.Login_RegRoleUI);
    layer:SetFrameRect(RectFullScreenUILayer);
    layer:SetBackgroundColor(ccc4(125, 125, 125, 125));
    scene:AddChild(layer);
    --初始化ui
    local uiLoad = createNDUILoad();
    if nil == uiLoad then
        layer:Free();
        return false;
    end
    uiLoad:Load("login_3.ini", layer, p.OnUIEvent, 0, 0);--创建角色
    uiLoad:Free();

    p.InitUI();--error here
    return true;
end

function p.getUiLayer()
    local scene = GetSMLoginScene();
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
    local nDataNum = table.getn(p.BtnTagList);--error here
    if nDataNum < 1 then
        LogInfo("InitUI NULL Data!");
        return;
    end

    local pNameEditUiNode = RecursiveUINode(p.getUiLayer(),{ID_ROLE_EDIT_NAME});
    local pNameEdit = ConverToEdit(pNameEditUiNode);
    if CheckP(pNameEdit) then
        pNameEdit:SetMaxLength(15);
        pNameEdit:SetMinLength(2);
    end

    --默认职业
    p.RefreshByDataIdx(1);
end

function p.RefreshByDataIdx(idx)
    local InitLayer = p.getUiLayer();
    local ProfImage =GetImage(InitLayer,ID_PROFESSION_LABEL);
    if CheckP(ProfImage) then
        local pool = DefaultPicPool();
        local pic  = pool:AddPicture(GetSMImgPath(p.BtnTagList[idx][3]), false);
        ProfImage:SetPicture(pic,true);
    end

    local ProfDesc =GetLabel(InitLayer,ID_PROFESSION_DES_LABEL);
    if CheckP(ProfDesc) then
        ProfDesc:SetText(p.BtnTagList[idx][4]);
    end 

    local ProfOtherDesc =GetLabel(InitLayer,ID_PROFESSION_OTHER_DES_LABEL);
        if CheckP(ProfOtherDesc) then
        ProfOtherDesc:SetText(p.BtnTagList[idx][5]);
    end
    
    p.Profession = p.BtnTagList[idx][6];
    p.LookFace   = p.BtnTagList[idx][7];
    
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
            MsgLogin.SendCreateRoleReq(p.Name,p.Profession,p.LookFace);
        elseif tag == ID_ROLE_OLDUSER_LOGIN then
            Login_Main.LoadUI();
            return true;
        elseif tag == ID_ROLE_GRIDDLE then
            --色子
            local s_Name = G_COMMON_CREATE_NAME(2);
            local InitLayer = p.getUiLayer();
            local uiNode = GetUiNode(InitLayer,ID_ROLE_EDIT_NAME);
            if CheckP(uiNode) then
                local edit = ConverToEdit(uiNode);
                edit:SetText(s_Name);
                p.Name = s_Name;
            end
        else
            local nProfNum = table.getn(p.BtnTagList);
            for i=1, nProfNum do
                if p.BtnTagList[i][1] == tag then
                    p.RefreshByDataIdx(i);
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
	end

	return true;
end
