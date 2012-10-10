--Npc模块
NPC = {};

local _G = _G;
NPC.table				= _G.table;
NPC.type				= _G.type;
NPC.LogInfo				= _G.LogInfo;
NPC.LogError			= _G.LogError;
NPC.OpenNpcDlg			= _G.OpenNpcDlg;
NPC.SetTitle			= _G.SetTitle;
NPC.SetContent			= _G.SetContent;
NPC.AddOpt				= _G.AddOpt;
NPC.CloseDlg			= _G.CloseDlg;
NPC.SendOpt				= _G.MsgNpc.SendOpt;
NPC.OnDealTask			= _G.OnDealTask;
NPC.DB_NPC				= _G.DB_NPC;
NPC.ipairs				= _G.ipairs;
NPC.DoFile				= _G.DoFile;

DoFile("Npc/NpcFunc.lua");
DoFile("Npc/Npc.lua");
DoFile("Npc/NpcConfigUI.lua");
DoFile("Npc/NpcScript/define.lua");
