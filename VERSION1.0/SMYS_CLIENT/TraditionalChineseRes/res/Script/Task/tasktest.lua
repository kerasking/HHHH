Task = {};

local p = Task;

function p.ProcessNpcDlg(netdata)
    local npcid     = netdata:ReadInt();
    local usData    = netdata:ReadShort();
    local iDx       = netdata:ReadByte();
    local ucAction  = netdata:ReadByte();
    
    LogInfo("npcid[%d], usdata[%d], idx[%d], ucAction[%d]",
            npcid, usData, iDx, ucAction);

    return 1;
end

RegisterNetMsgHandler(NMSG_Type.TASK_NPC_MSG, "p.ProcessNpcDlg", p.ProcessNpcDlg);

