
LogInClearData = {};
local p = LogInClearData;


--登录时清理动态数据
function p.Clear()
    p.ClearPet();
    p.ClearMarial();
    p.ClearFete();
    p.ClearMount();
    MsgPlayerAction.ClearActionInfo();
end


--清理武将信息
function p.ClearPet()
    LogInfo("p.ClearPet");
    
end


--清理阵法数据
function p.ClearMarial()
    LogInfo("p.ClearMarial");
    local count,ids = MsgMagic.getRoleMatrixCount();
    for i=1,count do
        _G.DelRoleDataId(NScriptData.eMagic, MsgMagic.RoleMagicCategory.CIDS, MsgMagic.RoleMagicType.TIDS, 0, 0,ids[i]);
    end
end

--清理祭祀数据
function p.ClearFete()
    LogInfo("p.ClearFete");
    Fete.flag = 0;
    Fete.bTwiceConfirm = false;
end


--清理坐骑信息
function p.ClearMount()
    LogInfo("p.ClearMount");
    MsgMount.RolePetInfo = {   
    pre_exp = nil;      --上一次经验
    exp     = 0,        --经验
    star    = 0,        --星级
    ride    = 0,        --0.休息 1.骑
    illusionId = 0,     --幻化等级
};

end


RegisterGlobalEventHandler( GLOBALEVENT.GE_LOGIN_GAME,"LogInClearData.Clear", p.Clear );



