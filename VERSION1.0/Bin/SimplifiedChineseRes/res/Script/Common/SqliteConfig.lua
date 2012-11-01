local _G = _G;

SqliteConfig = {}

local p = SqliteConfig;

local MaxRecordLimit = 1000;

local ServerListTableName = "ServerList";
local ServerListCreateScript = "CREATE TABLE ServerList (ServerID INTEGER, ServerName NVARCHAR(50), ServerIP NVARCHAR(50), ServePort INTEGER,ServerStatus INTEGER, Recommend NVARCHAR(200));";

local RoleInfoTableName = "RoleList";
local RoleInfoCreateScript = "CREATE TABLE RoleList (IdAccount INTEGER, ServerID INTEGER, RoleName NVARCHAR(10), Profession INTEGER, Level INTEGER, LastLogin INTEGER);";

        
local ServerListCountById = "SELECT * FROM ServerList WHERE ServerID = %d";
local ServerListAdd = "INSERT INTO ServerList VALUES(%d, \'%s\', \'%s\', %d, %d, \'%s\')";
local ServerListUpt = "UPDATE ServerList SET ServerName=\'%s\', ServerIP=\'%s\', ServePort=%d, ServerStatus=%d, Recommend=\'%s\' WHERE ServerID=%d";

local RoleInfoCountById = "SELECT * FROM RoleList WHERE IdAccount = %d and ServerID = %d";
local RoleInfoAdd = "INSERT INTO RoleList VALUES(%d, %d, \'%s\', %d, %d, %d)";
local RoleInfoUpt = "UPDATE RoleList SET ServerID=%d, RoleName=\'%s\', Profession=%d, Level=%d, LastLogin=%d WHERE IdAccount=%d and ServerID=%d";

local ServerInfoSelect = "SELECT s.ServerID,s.ServerName,s.ServerIP,s.ServePort,s.ServerStatus,s.Recommend,r.IdAccount,r.RoleName,r.Profession,r.Level,r.LastLogin FROM ServerList s left join RoleList r ON s.ServerID = r.ServerID ORDER BY s.ServerID DESC";


local RoleInfoNot = "SELECT * FROM RoleList WHERE IdAccount<>%d";
local RoleInfoDel = "DELETE FROM RoleList";


local ServerListSelect = "SELECT * FROM ServerList ORDER BY ServerID DESC";
local RoleListSelect = "SELECT * FROM RoleList";


--初始化数据库表
function p.InitDataBaseTable()
    LogInfo("Sqlite:InitDataBaseTable");
    
    --Sqlite_ExcuteSql("DROP TABLE ServerList");
    --Sqlite_ExcuteSql("DROP TABLE RoleList");
    
    p.CreateServerListTable();
    p.CreateRoleInfoTable();
    
    --p.InsertServerList({nServerID=222,sServerName="zzj",nServerIP="192.168.65.7",nServePort=9528,nServerStatus=2,sRecommend="ss"});
end

--创建服务器列表
function p.CreateServerListTable()
    LogInfo("Sqlite:CreateServerListTable");
    local isExists = Sqlite_IsExistTable(ServerListTableName);
    if(not isExists) then
        LogInfo("Sqlite:CreateServerListTable sql:[%s]",ServerListCreateScript);
        Sqlite_ExcuteSql(ServerListCreateScript);
    end
end

--创建角色列表
function p.CreateRoleInfoTable()
    LogInfo("Sqlite:p.CreateRoleInfoTable");
    local isExists = Sqlite_IsExistTable(RoleInfoTableName);
    if(not isExists) then
        LogInfo("Sqlite:CreateRoleInfoTable sql:[%s]",RoleInfoCreateScript);
        Sqlite_ExcuteSql(RoleInfoCreateScript);
    end
end

--插入服务器信息
function p.InsertServerList(record)
    local nIsExists = Sqlite_SelectData(string.format(ServerListCountById,record.nServerID),6);
    if(nIsExists > 0) then
        LogInfo("upt");
        Sqlite_ExcuteSql(string.format(ServerListUpt,record.sServerName,record.nServerIP,record.nServePort,record.nServerStatus,record.sRecommend,record.nServerID));
        return false;
    else
        LogInfo("add");
        Sqlite_ExcuteSql(string.format(ServerListAdd,record.nServerID,record.sServerName,record.nServerIP,record.nServePort,record.nServerStatus,record.sRecommend));
        return true;
    end
end


--插入角色信息
function p.InsertServerRoleInsert(record)
    LogInfo("p.InsertServerRoleInsert");
    local nIsExists = Sqlite_SelectData(string.format(RoleInfoCountById,record.nIdAccount,record.nServerID),6);
    if(nIsExists > 0) then
        LogInfo("upt");
        Sqlite_ExcuteSql(string.format(RoleInfoUpt,record.nServerID,record.sRoleName,record.nProfession,record.nLevel,record.nLastLogin,record.nIdAccount,record.nServerID));
        return false;
    else
        LogInfo("add");
        Sqlite_ExcuteSql(string.format(RoleInfoAdd,record.nIdAccount,record.nServerID,record.sRoleName,record.nProfession,record.nLevel,record.nLastLogin));
        return true;
    end
end

--查询服务器信息包括对应的角色
function p.SelectServerListAndRoleInfo()
    LogInfo("p.SelectServerListAndRoleInfo");
    
    local total = Sqlite_SelectData(ServerInfoSelect,11);
    LogInfo("p.SelectServerListAndRoleInfo total:[%d]",total);
    local records = {};
    for i=1,total do
        local index = i - 1;
        
        local record = {};
        
        record.nServerID = Sqlite_GetColDataN(index,0);
        record.sServerName = Sqlite_GetColDataS(index,1);
        record.nServerIP = Sqlite_GetColDataS(index,2);
        record.nServePort = Sqlite_GetColDataN(index,3);
        record.nServerStatus = Sqlite_GetColDataN(index,4);
        record.sRecommend = Sqlite_GetColDataS(index,5);
        
        record.nIdAccount = Sqlite_GetColDataN(index,6);
        record.sRoleName = Sqlite_GetColDataS(index,7);
        record.nProfession = Sqlite_GetColDataN(index,8);
        record.nLevel = Sqlite_GetColDataN(index,9);
        record.nLastLogin = Sqlite_GetColDataN(index,10);
        
        table.insert(records, record);
    end
    return records;
end


function p.SelectServerList()
    LogInfo("p.SelectServerList");
    
    local total = Sqlite_SelectData(ServerListSelect,6);
    LogInfo("p.SelectServerList total:[%d]",total);
    local records = {};
    for i=1,total do
        local index = i - 1;
        local record = {};
        record.nServerID = Sqlite_GetColDataN(index,0);
        record.sServerName = Sqlite_GetColDataS(index,1);
        record.nServerIP = Sqlite_GetColDataS(index,2);
        record.nServePort = Sqlite_GetColDataN(index,3);
        record.nServerStatus = Sqlite_GetColDataN(index,4);
        record.sRecommend = Sqlite_GetColDataS(index,5);
        table.insert(records, record);
    end
    return records;
end


function p.SelectRoleList(nAccountId)
    LogInfo("p.SelectRoleList");
    
    local total = Sqlite_SelectData(string.format(RoleListSelect,nAccountId),6);
    LogInfo("p.SelectRoleList total:[%d]",total);
    local records = {};
    for i=1,total do
        local index = i - 1;
        
        local record = {};
        record.nIdAccount = Sqlite_GetColDataN(index,0);
        record.nServerID = Sqlite_GetColDataN(index,1);
        record.sRoleName = Sqlite_GetColDataS(index,2);
        record.nProfession = Sqlite_GetColDataN(index,3);
        record.nLevel = Sqlite_GetColDataN(index,4);
        record.nLastLogin = Sqlite_GetColDataN(index,5);
        
        table.insert(records, record);
    end
    return records;
end


function p.DeleteRoleByAccountId(nAccountId)
    local total = Sqlite_SelectData(string.format(RoleInfoNot,nAccountId),6);
    LogInfo("p.DeleteRoleByAccountId nAccountId:[%d],total:[%d]",nAccountId,total); 
    if(total>0) then
        LogInfo("p.DeleteRoleByAccountId true1");
        Sqlite_ExcuteSql(RoleInfoDel);
        return true;
    end
    return false;
end

RegisterGlobalEventHandler(GLOBALEVENT.GE_LOGIN_GAME,"SqliteConfig.InitDataBaseTable", p.InitDataBaseTable);