---------------------------------------------------
--描述: 玩家状态UI
--时间: 2013.1.23
--作者: qbw
---------------------------------------------------



Buff = {}
local p = Buff;
local buffcontainer = nil;


local winsize = GetWinSize();
local Screenwidth =  winsize.w;
local Screenheight = winsize.h;


function p.LoadUI()
	LogInfo("Buff 1");
	local scene = GetSMGameScene();	
	if scene == nil then
		LogInfo("scene == nil,load UI failed!");
		return;
	end
	LogInfo("Buff 2");
	local layer = createNDUILayer();
	if layer == nil then
		return false;
	end
	LogInfo("Buff 3");
	layer:Init();
	LogInfo("Buff 4");
	layer:SetTag(NMAINSCENECHILDTAG.Buff);
	LogInfo("Buff 5");
	layer:SetFrameRect(RectFullScreenUILayer);
	LogInfo("Buff 6");
	scene:AddChildZ(layer,UILayerZOrder.NormalLayer);

	--初始化ui
	local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end
LogInfo("Buff 7");
	--bg
	uiLoad:Load("MainUI_buff.ini", layer, p.OnUIEvent, 0, 0);
	uiLoad:Free();	
LogInfo("Buff 8");
	buffcontainer = RecursiveSVC(scene, { NMAINSCENECHILDTAG.Buff, 101});
	if not CheckP(buffcontainer) then
		layer:Free();
		return false;
	end

	buffcontainer:SetStyle(UIScrollStyle.Verical);
	buffcontainer:SetViewSize(CGSizeMake(buffcontainer:GetFrameRect().size.w, buffcontainer:GetFrameRect().size.h/4));
	buffcontainer:EnableScrollBar(true);
	
	p.SendRequest()
end

  
local g_tBuffList = {}
	    

function p.ClearBuffList()
	g_tBuffList = {}	
end
  

  
function p.RefreshList()
	if buffcontainer ~= nil then
		local rectview		= buffcontainer:GetFrameRect();
		local nWidthLimit = rectview.size.w;
		
		buffcontainer:RemoveAllView();
		
		for i,v in pairs(g_tBuffList) do
			local view = createUIScrollView();		
		 	if view ~= nil then
		 		view:Init(false);
		 		view:SetViewId(i*2);
	 		
		 		--初始化ui
        		local uiLoad = createNDUILoad();
        		if nil == uiLoad then
        		   return false;
        		end		 		 
		 		uiLoad:Load("MainUI_buff_L.ini", view, nil, 0, 0);
        		uiLoad:Free();     		 
		 		buffcontainer:AddView(view);
		 				
		 		local pLabelTitle = RecursiveLabel(view, {2});
		 		pLabelTitle:SetText(v[1]);
		 		
		 		local pLabelDesc = RecursiveLabel(view, {15});
		 		pLabelDesc:SetText(v[2]);
		 				
	 		end	
	 				 		
	 		
		end
		
	end
end
  
  
  
  
  
  
function p.SendRequest()
	local netdata = createNDTransData(NMSG_Type._MSG_MAP_BUFF_ACTION);
	if nil == netdata then
		return false;
	end 
	SendMsg(netdata);
	netdata:Free();
	--ShowLoadBar();
	return true;
end

function p.ProcessRequestRet(netdata)
	CloseLoadBar();
end

function p.ProcessList(netdata)
	--p.ClearBuffList()
	local nCount = netdata:ReadByte();
	LogInfo("buff ProcessList nCount:"..nCount);
	
    for i=1,nCount do
    	local stitle = netdata:ReadUnicodeString();
    	
    	local sDescribe = netdata:ReadUnicodeString();
    	
    	g_tBuffList[i] = {stitle,sDescribe};
    end
    
    if IsUIShow(NMAINSCENECHILDTAG.Buff) then
		p.RefreshList();
	else
		--
		local btn =  MainUI.GetBuffButton();
		if nCount > 0 then
			btn:SetVisible(true);	
		else
			btn:SetVisible(false);	
		end
	end   
    
end


---------------
--UI事件处理回调函数
---------------

function p.OnUIEvent(uiNode, uiEventType, param)
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
	    local tag = uiNode:GetTag();
		if tag == 533 then
			--关闭界面
			CloseUI(NMAINSCENECHILDTAG.Buff);
	    end
	end
	return true;
end

RegisterNetMsgHandler(NMSG_Type._MSG_MAP_BUFF_ACTION_RET, "p.ProcessRequestRet", p.ProcessRequestRet);
RegisterNetMsgHandler(NMSG_Type._MSG_MAP_BUFF_BUFFLIST, "p.ProcessList", p.ProcessList);



