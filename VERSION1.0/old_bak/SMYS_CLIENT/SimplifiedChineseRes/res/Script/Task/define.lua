--任务模块
TASK = {};

local _G = _G;
TASK.table				= _G.table;
TASK.type				= _G.type;
TASK.LogInfo			= _G.LogInfo;
TASK.LogError			= _G.LogError;
TASK.OpenTaskDlg		= _G.OpenTaskDlg;
TASK.CloseDlg			= _G.CloseDlg;
TASK.SetTitle			= _G.SetTitle;
TASK.SetContent			= _G.SetContent;
TASK.AddOpt				= _G.AddOpt;
TASK.GetOptCount		= _G.GetOptCount;
TASK.SetTaskAward		= _G.SetTaskAward;
TASK.SysChat			= _G.SysChat;
TASK.CheckN				= _G.CheckN;
TASK.CheckS				= _G.CheckS;
TASK.CheckT				= _G.CheckT;
TASK.DB_TASK_TYPE		= _G.DB_TASK_TYPE;
TASK.TASK_DATA			= _G.TASK_DATA;
TASK.SafeN2S			= _G.SafeN2S;
TASK.ConvertN			= _G.ConvertN;
TASK.NScriptData		= _G.NScriptData;
TASK.NRoleData			= _G.NRoleData;
TASK.GetDataBaseDataN	= _G.GetDataBaseDataN;
TASK.GetDataBaseDataS	= _G.GetDataBaseDataS;
TASK.ipairs				= _G.ipairs;
TASK.tostring			= _G.tostring;
TASK.DoFile				= _G.DoFile;

DoFile("Task/TaskEnum.lua");
DoFile("Task/TaskFunc.lua");
DoFile("Task/Task.lua");
DoFile("Task/TaskUI/define.lua");
DoFile("Task/TaskScript/define.lua");