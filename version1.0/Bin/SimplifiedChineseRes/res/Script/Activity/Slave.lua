---------------------------------------------------
--描述: 斗地主
--时间: 2012.12.24
--作者: qbw
---------------------------------------------------
Slave = {}
local p = Slave;

local gMaxSlaveCount = 3;
local g_IndexChosen = 0;

local g_tSlaveData = {}
	g_tSlaveData[0] = nil
	g_tSlaveData[1] = nil
	g_tSlaveData[2] = nil
	
	
--奴隶主数据	
local g_OwnerId = 0;
local g_OwnerLeftTime = 0;
local g_OwnerName = "";
local g_OwnerLevel = 0;
local g_OwnerPro = 0;
				
local gType =0;
local gCatchCount= 0;
local gHelpCount = 0;
local gRevoltCount= 0;
local gActivityCount = 0;
local gSosCount = 0;
local gSlaveLevel1 = 0;
local nSlaveLevel2 = 0;
local gSlaveLevel3 = 0;
local gGained = 0;
local gMaxGain = 0;		
local gStore  = 0;
local gBawang = 0;
local gWuguiTime = 0;
local gRevoltCD = 0;
local gActivityCD = 0;
	 
local scrollSlave = nil;

p.CoinTimerTag = nil;
p.SlaveTimerTag = nil;

local tSlaveTypeAdd = {}
	tSlaveTypeAdd[0] = 1
	tSlaveTypeAdd[1] = 1.2
	tSlaveTypeAdd[2] = 1.5
	tSlaveTypeAdd[3] = 2.5
	
local gCatchUserId = 0;
local gSynSlaveId = 0;

local gAddCatchCount = 0;
local gAddHelpCount  = 0;
local gAddRevoltCount = 0;
local gAddActivityCount = 0;
local gAddSosCount = 0;


--求救军团信息
local g_SynSosList = {}
local g_tSynSlaveList = {}

function p.SetPayCount(nAddCatchCount,nAddHelpCount,nAddRevoltCount,nAddActivityCount,nAddSosCount)
	gAddCatchCount = nAddCatchCount;
	gAddHelpCount  = nAddHelpCount;
	gAddRevoltCount = nAddRevoltCount;
	gAddActivityCount = nAddActivityCount;
	gAddSosCount = nAddSosCount;	
end


--==刷新显示积累银币==--
function p.CoinTimerTick(tag)	
	 --如果为开启ui则关闭计时器
	if not IsUIShow(NMAINSCENECHILDTAG.SlaveUI) then
		UnRegisterTimer(tag);
		p.CoinTimerTag = nil;
		return;
	end	
	
	local coinlabel = RecursiveLabel(p.GetParent(),{49});	
	
	--计算一秒获取多少银币
	local ntmpcoin = 0;
	for i,v in pairs(g_tSlaveData) do
		if v ~= {} then
			local nSec = v[2];
			if nSec > 0 then	
				local slavelevel = v[4];
				local ranklevel = 0;
				if i == 0 then
				   	ranklevel = gSlaveLevel1;
				elseif i == 1 then
					ranklevel = gSlaveLevel2;
				else
					ranklevel = gSlaveLevel3;
				end
				
				ntmpcoin = ntmpcoin + ((slavelevel*1000+20000)*tSlaveTypeAdd[ranklevel])/(8*3600);								
			end
	
		end
	end
	
	gStore = gStore  + ntmpcoin;
	coinlabel:SetText(""..math.floor(gStore));
	
	
	local labelWuguitime 	=  RecursiveLabel(p.GetParent(),{58});
	if gWuguiTime>0 then
		gWuguiTime = gWuguiTime - 1;
		labelWuguitime:SetText(FormatTime(gWuguiTime,1));
	end

--local gRevoltCD = 0;
--local gActivityCD = 0;
	
	if gRevoltCD>0 then
		gRevoltCD = gRevoltCD - 1;
	end	
	
	if gActivityCD>0 then
		gActivityCD = gActivityCD - 1;
	end
	
end

function p.SlaveTimerTick(tag)
	--LogInfo("SlaveTimerTick1");
	 --如果为开启ui则关闭计时器
	if not IsUIShow(NMAINSCENECHILDTAG.SlaveUI) then
		UnRegisterTimer(tag);
		p.SlaveTimerTag = nil;
		return;
	end	
	---LogInfo("SlaveTimerTick2");
	if scrollSlave == nil then
		return;
	end
	--LogInfo("SlaveTimerTick3");
	if gType == tSlaveType.Slave  then
		local view = scrollSlave:GetViewById(0);
		local pLabeltime = RecursiveLabel(view, {63});
		
		if g_OwnerLeftTime > 0 then	
			g_OwnerLeftTime = g_OwnerLeftTime - 1;
			pLabeltime:SetText(""..FormatTime(g_OwnerLeftTime,1));
		else
			pLabeltime:SetText(GetTxtPri("DDZ_T1"));
		end
		
		return;
	end
	
	--
	
	
	--LogInfo("SlaveTimerTick4");
	for i,v in pairs(g_tSlaveData) do
		LogInfo("SlaveTimerTick i:"..i.." ");
		if v ~= nil then
			local nSec = v[2];
			local view = scrollSlave:GetViewById(i);
			local pLabeltime = RecursiveLabel(view, {63});
			
			--LogInfo(" g_tSlaveData[i][2]:".. g_tSlaveData[i][2])
			
			if nSec > 0 then
				g_tSlaveData[i][2] = nSec - 1;
		 		pLabeltime:SetText(""..FormatTime(g_tSlaveData[i][2],1));
			else 
				pLabeltime:SetText(GetTxtPri("DDZ_T1"));		
			end
		end
	end
end


function p.LoadUI()
	ArenaUI.isInChallenge = 7;
	
	if IsUIShow(NMAINSCENECHILDTAG.SlaveUI) then
		p.refreshUI();
		return;
	end
	
    --------------------获得游戏主场景------------------------------------------
    local scene = GetSMGameScene();	
	if scene == nil then
		return;
	end
    
    local layer = createNDUILayer();
	if layer == nil then
		return false;
	end
    
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.SlaveUI);
	layer:SetFrameRect(RectFullScreenUILayer);
	scene:AddChildZ(layer,UILayerZOrder.ActivityLayer);
    
    local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end
	uiLoad:Load("slave/slave_BG.ini", layer, p.OnUIEvent, 0, 0);	
	uiLoad:Free();

	
	----------------------------战报容器---------------------------------------
	--local rectX = winsize.w*0.3;
	--local rectW	= winsize.w*0.4;
	--local rect  = CGRectMake(rectX, winsize.h*0.23, rectW, winsize.h*0.5); 
	
	--全部战报
	scrollSlave =  GetScrollViewContainer(layer, 101);--createUIScrollViewContainer();
	if scrollSlave == nil then
		LogInfo("scrollSlave == nil!");
		return;
	end
	--scrollSlave:Init();
	--scrollSlave:SetFrameRect(rect);
	--layer:AddChild(scrollSlave);
	
	local rectview = scrollSlave:GetFrameRect();
	scrollSlave:SetStyle(UIScrollStyle.Verical);
	scrollSlave:SetViewSize(CGSizeMake(rectview.size.w, rectview.size.h / gMaxSlaveCount));
	scrollSlave:SetTopReserveDistance(rectview.size.h);
	scrollSlave:SetBottomReserveDistance(rectview.size.h);
	scrollSlave:EnableScrollBar(false);
	scrollSlave:SetLuaDelegate((p.OnUIEventSlaveScroll));
	
--[[==	
			local rectview = attContainer:GetFrameRect();
			if nil ~= rectview then
				local nWidth	= rectview.size.w*1.2;
				local nHeight	= rectview.size.h / MAX_PLAYER_NUM_PER_PAGE;
				attContainer:SetStyle(UIScrollStyle.Verical);
				attContainer:SetViewSize(CGSizeMake(nWidth, nHeight));
				attContainer:SetTopReserveDistance(rectview.size.h);
				attContainer:SetBottomReserveDistance(rectview.size.h);
				attContainer:EnableScrollBar(true);
			end	
--]]


	p.refreshUI();
	
	
	--金币银币显示刷新
	local GoldLabel 	=  RecursiveLabel(layer,{242});
	local SilverLabel 	=  RecursiveLabel(layer,{243});	
    local nPlayerId     = GetPlayerId();
	local nGold 		=  GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_EMONEY);
	local nSilverCoin 	= GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_MONEY);
	local sGold = fomatBigNumber(nGold);		
	GoldLabel:SetText(""..sGold);		
	local sSilverCoin = fomatBigNumber(nSilverCoin);		
	SilverLabel:SetText(""..sSilverCoin);


	
	--每秒获取银币计时器
	p.CoinTimerTag = RegisterTimer(p.CoinTimerTick,1, "Slave.CoinTimerTick");
	
	--奴隶倒计时器
	p.SlaveTimerTag = RegisterTimer(p.SlaveTimerTick,1, "Slave.SlaveTimerTag");
	
	
end

local tTypeDesc ={}
	tTypeDesc[tSlaveType.Slave] = GetTxtPri("DDZ_T2")
	tTypeDesc[tSlaveType.Free] = GetTxtPri("DDZ_T3")
	tTypeDesc[tSlaveType.Owner] = GetTxtPri("DDZ_T4")

local tPosTypeDesc = {}
	tPosTypeDesc[0]=GetTxtPri("DDZ_T5")
	tPosTypeDesc[1]=GetTxtPri("DDZ_T6")
	tPosTypeDesc[2]=GetTxtPri("DDZ_T7")
	tPosTypeDesc[3]=GetTxtPri("DDZ_T8")
	

function p.refreshUI()
	local tcolor = {}
	tcolor[0] =  ccc4(255,255,255,255);      --绿色1ced5d	
	tcolor[1] =  ccc4(28,237,93,255);      --绿色1ced5d	
	tcolor[2] =  ccc4(255,0,252,255);      --紫色ff00fc
	tcolor[3] =  ccc4(228,112,18,255);     --橙色e47012	
	
	
	local label1 	=  RecursiveLabel(p.GetParent(),{42});
	local label2 	=  RecursiveLabel(p.GetParent(),{44});
	local label3 	=  RecursiveLabel(p.GetParent(),{46});
	
	local labeltitle = RecursiveLabel(p.GetParent(),{56});
	
	
	--pLabel1:EnalbeGray(true);  
	local Helpbutton = RecursiveButton(p.GetParent(), {51});
				
	
				
	if gType == tSlaveType.Slave then
    
		label1:SetText(string.format(GetTxtPri("DDZ_T9"), gActivityCount));
		label2:SetText(string.format(GetTxtPri("DDZ_T10"), gSosCount));
		label3:SetText(string.format(GetTxtPri("DDZ_T11"), gRevoltCount));	
		Helpbutton:EnalbeGray(true); 
		labeltitle:SetText(GetTxtPri("DDZ_T14"));	
	else
		label1:SetText(string.format(GetTxtPri("DDZ_T9"), gActivityCount));
		label2:SetText(string.format(GetTxtPri("DDZ_T12"), gHelpCount));
		label3:SetText(string.format(GetTxtPri("DDZ_T13"), gCatchCount));	
		labeltitle:SetText(GetTxtPri("DDZ_T15"));	
		Helpbutton:EnalbeGray(false); 
	end
	
	
	local labelType 	=  RecursiveLabel(p.GetParent(),{47});
	labelType:SetText(GetTxtPri("DDZ_T16")..tTypeDesc[gType]);	
	
	local labelStore 	=  RecursiveLabel(p.GetParent(),{49});
	labelStore:SetText(""..gStore);	
	
	local labelGained 	=  RecursiveLabel(p.GetParent(),{48});
	labelGained:SetText(gGained.."/"..gMaxGain);
	

	local labelWuguitime 	=  RecursiveLabel(p.GetParent(),{58});
	labelWuguitime:SetText(""..FormatTime(gWuguiTime,1));
	local labelBawang 	=  RecursiveLabel(p.GetParent(),{59});
	labelBawang:SetText(gBawang.."");
	
	--=================刷新奴隶栏位===================--
	
	if scrollSlave ~= nil then
		local rectview		= scrollSlave:GetFrameRect();
		local nWidthLimit = rectview.size.w;
		
		scrollSlave:RemoveAllView();
		if  gType == tSlaveType.Slave then
		--玩家是奴隶
			
			local view = createUIScrollView();
 	
		 	if view ~= nil then
		 		view:Init(false);
		 		--view:SetViewId(nIndex);
	 		
		 		--初始化ui
        		 local uiLoad = createNDUILoad();
        		 if nil == uiLoad then
        	   		 return false;
        		 end
		 		uiLoad:Load("slave/slave_L_2.ini", view, nil, 0, 0);
        		
		 		scrollSlave:AddView(view);
		 		
				local pLabel1 = RecursiveButton(view, {97});
				local pLabel2 = RecursiveButton(view, {6});
				local pLabel3 = RecursiveButton(view, {7});

				pLabel1:SetLuaDelegate((p.OnUIEventSlaveScroll));
				pLabel2:SetLuaDelegate((p.OnUIEventSlaveScroll));
				pLabel3:SetLuaDelegate((p.OnUIEventSlaveScroll));
	
				--奴隶则隐藏升级按钮
				local pRankBtn = RecursiveButton(view, {18});
				pRankBtn:SetVisible(false);
							
				local pLabelname = RecursiveLabel(view, {217});
				local pLabellevel = RecursiveLabel(view, {8});
		
				local pLabeltime = RecursiveLabel(view, {63});
				pLabeltime:SetText("");
						
				pLabel1:SetTitle(GetTxtPri("DDZ_T17"));		 		
				pLabel2:SetTitle(GetTxtPri("DDZ_T18"));		 		
				pLabel3:SetTitle(GetTxtPri("DDZ_T19"));
				pLabelname:SetText(g_OwnerName);
				pLabellevel:SetText(g_OwnerLevel..GetTxtPri("DDZ_T22"));
				
				--屏蔽互动
				--pLabel1:EnalbeGray(true);  
				
				--刷新职业头像
				local HeadPic = GetImage(view, 206);
				local pic = GetPetPotraitPic(g_OwnerPro);	
				HeadPic:SetPicture(pic,true);
			end	
		else
		--玩家是地主或者自由人
		--
			for i=0,gMaxSlaveCount-1 do
			
			
				if g_tSlaveData[i] ~= nil then
					--有奴隶
					--LogInfo("有奴隶")
					local view = createUIScrollView();		
		 			if view ~= nil then
		 				view:Init(false);
		 				view:SetViewId(i);
	 				
		 				--初始化ui
        				 local uiLoad = createNDUILoad();
        				 if nil == uiLoad then
        			   		 return false;
        				 end
		 				uiLoad:Load("slave/slave_L_2.ini", view, nil, 0, 0);
        				uiLoad:Free();
        				
		 				scrollSlave:AddView(view);
		 				
						local pLabel1 = RecursiveButton(view, {97});
						local pLabel2 = RecursiveButton(view, {6});
						local pLabel3 = RecursiveButton(view, {7});
						
						local pRankBtn = RecursiveButton(view, {18});
						local btndesc = GetTxtPri("DDZ_T5")
						--pRankBtn:SetFontColor(Color);
	
						--pRankBtn:SetFontColor( tcolor[1] );  
						
						
						
		 				if i == 0 then
							btndesc = tPosTypeDesc[gSlaveLevel1];	
							pRankBtn:SetFontColor( tcolor[gSlaveLevel1] );  				
						elseif i == 1 then
							btndesc = tPosTypeDesc[gSlaveLevel2];
							pRankBtn:SetFontColor( tcolor[gSlaveLevel2] ); 						
						elseif i == 2 then
							btndesc = tPosTypeDesc[gSlaveLevel3];	
							pRankBtn:SetFontColor( tcolor[gSlaveLevel3] ); 					
						end		
						--]]	
						
						if btndesc == GetTxtPri("DDZ_T5") then
							pRankBtn:EnalbeGray(false);	
						else
							pRankBtn:EnalbeGray(true);	
						end
														
						pRankBtn:SetTitle(btndesc);
						pRankBtn:SetLuaDelegate((p.OnUIEventSlaveScroll));
						
						pLabel1:SetLuaDelegate((p.OnUIEventSlaveScroll));
						pLabel2:SetLuaDelegate((p.OnUIEventSlaveScroll));
						pLabel3:SetLuaDelegate((p.OnUIEventSlaveScroll));
						
						pLabel1:SetParam1(i);--btn:GetParam1();
						pLabel2:SetParam1(i);
						pLabel3:SetParam1(i);
						pRankBtn:SetParam1(i);	
						
						local pLabelname = RecursiveLabel(view, {217});
						local pLabellevel = RecursiveLabel(view, {8});
						local pLabeltime = RecursiveLabel(view, {63});
						pLabeltime:SetText(""..FormatTime(g_tSlaveData[i][2],1));
						--{nUserId,nStartTime,nProid,nLevel,sName}
						pLabel1:SetTitle(GetTxtPri("DDZ_T17"));		 		
						pLabel2:SetTitle(GetTxtPri("DDZ_T20"));		 		
						pLabel3:SetTitle(GetTxtPri("DDZ_T21"));
						pLabelname:SetText(g_tSlaveData[i][5]);
						pLabellevel:SetText(g_tSlaveData[i][4]..GetTxtPri("DDZ_T22"));
						
						--屏蔽互动
						--pLabel1:EnalbeGray(true);  
						
						--刷新职业头像
						local HeadPic = GetImage(view, 206);
						local pic = GetPetPotraitPic(g_tSlaveData[i][3]);	
						HeadPic:SetPicture(pic,true);
					end
				else
					--无奴隶
					--LogInfo("无奴隶")
					local view = createUIScrollView();		
		 			if view ~= nil then
		 				view:Init(false);
		 				view:SetViewId(i);
	 				
		 				--初始化ui
        				 local uiLoad = createNDUILoad();
        				 if nil == uiLoad then
        			   		 return false;
        				 end
		 				uiLoad:Load("slave/slave_L_1.ini", view, nil, 0, 0);
        				uiLoad:Free();
        				
		 				scrollSlave:AddView(view);
		 				
		 				local pLabelrank = RecursiveLabel(view, {8});
		 				--LogInfo("gSlaveLevel1:"..gSlaveLevel1)
		 				--LogInfo("gSlaveLevel2:"..gSlaveLevel2)
		 				--LogInfo("gSlaveLevel3:"..gSlaveLevel3)
						local pLabel1 = RecursiveButton(view, {1});
						local pLabel2 = RecursiveButton(view, {2});
						local pLabel3 = RecursiveButton(view, {3});						
						pLabel1:SetLuaDelegate((p.OnUIEventSlaveScroll));
						pLabel2:SetLuaDelegate((p.OnUIEventSlaveScroll));
						pLabel3:SetLuaDelegate((p.OnUIEventSlaveScroll));	 				
		 		
						pLabel1:SetParam1(i);--btn:GetParam1();
						pLabel2:SetParam1(i);
						pLabel3:SetParam1(i);
						
								
		 				if i == 0 then 
							pLabelrank:SetText(tPosTypeDesc[gSlaveLevel1]..GetTxtPri("DDZ_T24"));
							if gSlaveLevel1 ~= 0 then
								pLabel3:EnalbeGray(true);
								pLabelrank:SetFontColor( tcolor[gSlaveLevel1] );   
							end							
						elseif i == 1 then
							pLabelrank:SetText(tPosTypeDesc[gSlaveLevel2]..GetTxtPri("DDZ_T24"));
							if gSlaveLevel2 ~= 0 then
								pLabel3:EnalbeGray(true);   
								pLabelrank:SetFontColor( tcolor[gSlaveLevel2] );   
							end								
						elseif i == 2 then
							pLabelrank:SetText(tPosTypeDesc[gSlaveLevel3]..GetTxtPri("DDZ_T24"));
							if gSlaveLevel3 ~= 0 then
								pLabel3:EnalbeGray(true);   
								pLabelrank:SetFontColor( tcolor[gSlaveLevel3] );   
							end								
						end
					end						
										
				end
			end
		end
	end
	
	
end

function p.SetInfo(nType,nCatchCount,nHelpCount,nRevoltCount,nActivityCount,nSosCount,nSlaveLevel1,nSlaveLevel2,nSlaveLevel3,nStore,nGained,nMaxGain,nBawang,nWuguiTime,nRevoltCD,ActivityCD)
	 gType = nType;
	 gCatchCount= nCatchCount;
	 gHelpCount = nHelpCount;
	 gRevoltCount= nRevoltCount;
	 gActivityCount = nActivityCount;
	 gSosCount = nSosCount;
	 
	 gSlaveLevel1 = nSlaveLevel1;
	 gSlaveLevel2 = nSlaveLevel2;
	 gSlaveLevel3 = nSlaveLevel3;
	 gStore = nStore;
	 gGained = nGained;
	 gMaxGain = nMaxGain;
	 gBawang = nBawang;
	 gWuguiTime =nWuguiTime;
	 
	 
	 gRevoltCD = nRevoltCD;
	 gActivityCD = ActivityCD;
	 
end


function p.ClearSlaveData()
	g_tSlaveData[0] = nil
	g_tSlaveData[1] = nil
	g_tSlaveData[2] = nil
end


function p.SetSlaveInfo(nIndex,nUserId,nLeftTime,nProid,nLevel,sName)
	if nIndex <= gMaxSlaveCount - 1 then
		g_tSlaveData[nIndex] = {nUserId,nLeftTime,nProid,nLevel,sName}	
	end	
end

function p.SetOwnerInfo(nOwnerId,nLeftTime,nProid,nLevel,sName)
	g_OwnerId =nOwnerId;
	g_OwnerLeftTime =nLeftTime;
	g_OwnerName = sName;
	g_OwnerLevel = nLevel;
	g_OwnerPro = nProid;
end


--压榨
function p.CompleteSlaveWork(nId, param)
    if ( CommonDlgNew.BtnOk == nId ) then		
		MsgSlave.SendAction(SlaveActionType.ActionCompleteSlaveWork,g_IndexChosen);
	end
end

--释放
function p.FreeSlave(nId, param)
    if ( CommonDlgNew.BtnOk == nId ) then		
		MsgSlave.SendAction(SlaveActionType.ActionFreeSlave,g_IndexChosen);
	end
end








local gCatchUITag = 12345;
local gSynSlaveUITag = 12346;
local gSosUITag = 12347;
local gUpgradeUITag = 12348;

--======================加载捕获ui======================--
--加载升级兽栏界面
local tUpgradeConfig ={}
	--tUpgradeConfig[rank] = {1日消费,2日,3日}
	tUpgradeConfig[1] = {5,9,12}
	tUpgradeConfig[2] = {10,18,24}
	tUpgradeConfig[3] = {25,45,60}
	
local tTagday = {}	
	tTagday[22] = 1;
	tTagday[23] = 2;
	tTagday[24] = 3;
	
local tTagRank = {}
	tTagRank[93] = 1;
	tTagRank[15] = 2;
	tTagRank[17] = 3;
		
local gChooseday = 1;
local gChooseRank = 1;
function p.LoadUpgradeSlave()
 	local bglayer =p.GetParent();
    local layer = createNDUILayer();
	if layer == nil then
		return false;
	end
    
	layer:Init();
	layer:SetTag(gUpgradeUITag);
	layer:SetFrameRect(RectFullScreenUILayer);
	bglayer:AddChildZ(layer,2);
	
    local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end
	uiLoad:Load("slave/slave_M.ini", layer, p.OnUIEventUpgradeUI, 0, 0);	
	p.RefreshWithButtonTag(22);
	
end

function p.RefreshWithButtonTag(nTag)
	local bglayer = p.GetParent();
	local layer = RecursiveUILayer(bglayer, {gUpgradeUITag});
		
	local btn1 	= GetButton( layer, 22 ); 
	local btn2 	= GetButton( layer, 23 ); 
	local btn3 	= GetButton( layer, 24 ); 
	
	btn1:SetChecked( false );
	btn2:SetChecked( false );
	btn3:SetChecked( false );
		
	local selBtn 	= GetButton( layer, nTag ); 
	selBtn:SetChecked( true );
	
	local nday = tTagday[nTag];
	local label1 =  RecursiveLabel(layer, {19});
	local label2 =  RecursiveLabel(layer, {20});
	local label3 =  RecursiveLabel(layer, {21});
	label1:SetText(tUpgradeConfig[1][nday]..GetTxtPri("DDZ_T25"));
	label2:SetText(tUpgradeConfig[2][nday]..GetTxtPri("DDZ_T25"));
	label3:SetText(tUpgradeConfig[3][nday]..GetTxtPri("DDZ_T25"));
	gChooseday = nday;
end

function p.OnUIEventUpgradeUI(uiNode, uiEventType, param)
  local tag = uiNode:GetTag();
    LogInfo("qboy p.OnUIEventSynSlaveUI hit tag = %d", tag);
	local bglayer =p.GetParent();
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
	 	--关闭按钮
        if 70 == tag then    
			bglayer:RemoveChildByTag(gUpgradeUITag, true);
		elseif 22 <= tag and 24>=tag then
			p.RefreshWithButtonTag(tag)
		elseif 93== tag then
			gChooseRank = tTagRank[tag];
			CommonDlgNew.ShowYesOrNoDlg( GetTxtPri("DDZ_T26")..tUpgradeConfig[1][gChooseday]..GetTxtPri("DDZ_T27"), p.UpgradeSlave, true );
			
			
		elseif 15 == tag then
			gChooseRank = tTagRank[tag];
			CommonDlgNew.ShowYesOrNoDlg( GetTxtPri("DDZ_T26")..tUpgradeConfig[2][gChooseday]..GetTxtPri("DDZ_T28"), p.UpgradeSlave, true );
		elseif 17 == tag then
			gChooseRank = tTagRank[tag];
			CommonDlgNew.ShowYesOrNoDlg( GetTxtPri("DDZ_T26")..tUpgradeConfig[3][gChooseday]..GetTxtPri("DDZ_T29"), p.UpgradeSlave, true );
		end
	end
	return true;
end

--升级栏位
function p.UpgradeSlave(nId, param)
    if ( CommonDlgNew.BtnOk == nId ) then	
    	LogInfo("qboy p.UpgradeSlave g_IndexChosen:"..g_IndexChosen.." type:"..( (gChooseRank-1)*3 + gChooseday-1 )  );	
		MsgSlave.SendAction(SlaveActionType.ActionUpgradeSlave,g_IndexChosen, ( (gChooseRank-1)*3 + gChooseday-1  )  );
		
		local bglayer =p.GetParent();
	 	bglayer:RemoveChildByTag(gUpgradeUITag, true);
		
	end
end

--======================xxxxx=======================--



--可捕获玩家信息数据处理
local g_tCatchList = {}

function p.LoadEnemyUI()
	local bglayer =p.GetParent();
	local layer= RecursiveUILayer(bglayer, {gCatchUITag});
	local scrollCatch = nil;
	if CheckP(layer) == false then
        local layer = createNDUILayer();
		if layer == nil then
			return false;
		end
        
		layer:Init();
		layer:SetTag(gCatchUITag);
		layer:SetFrameRect(RectFullScreenUILayer);
		bglayer:AddChildZ(layer,5);
        
        local uiLoad = createNDUILoad();
		if nil == uiLoad then
			layer:Free();
			return false;
		end
		uiLoad:Load("slave/slave_Select.ini", layer, p.OnUIEventEnemyUI, 0, 0);	
		uiLoad:Free();
		--全部战报
		scrollCatch =  GetScrollViewContainer(layer, 101);--createUIScrollViewContainer();
		if scrollCatch == nil then
			LogInfo("scrollSlave == nil!");
			return;
		end

		
		local pLabelTitle = RecursiveLabel(layer, {56});
		pLabelTitle:SetText(GetTxtPri("DDZ_T30"));
						
						
						


		local rectview = scrollCatch:GetFrameRect();
		scrollCatch:SetStyle(UIScrollStyle.Verical);
		scrollCatch:SetViewSize(CGSizeMake(rectview.size.w, rectview.size.h / 5));
		scrollCatch:SetTopReserveDistance(rectview.size.h);
		scrollCatch:EnableScrollBar(true);
		scrollCatch:SetLuaDelegate((p.OnUIEventEnemyUI));		
	else
		scrollCatch = GetScrollViewContainer(layer, 101); 
		scrollCatch:RemoveAllView();		
	end

	
	for nUserId,v in pairs(g_tCatchList) do		
		LogInfo("LoadCatchUI nUserId"..nUserId);
		local view = createUIScrollView();		
		 if view ~= nil then
		 	view:Init(false);
		 	view:SetViewId(nUserId);
	 	
		 	--初始化ui
        	 local uiLoad = createNDUILoad();
        	 if nil == uiLoad then
           		 return false;
        	 end
		 	uiLoad:Load("slave/slave_L_4.ini", view, nil, 0, 0);
        	uiLoad:Free();
        	
		 	scrollCatch:AddView(view);
		 	
			local catchbtn = RecursiveButton(view, {6});
			catchbtn:SetParam1(nUserId);
			catchbtn:SetLuaDelegate((p.OnUIEventEnemyUI));	
			catchbtn:SetTitle(GetTxtPri("DDZ_T31"));
			
			local pLabelname = RecursiveLabel(view, {217});
			local pLabellevel = RecursiveLabel(view, {21});
			 		
			--{nUserId,nProid,nlevel,nWuguiState,sName};
			pLabelname:SetText(v[5]);
			pLabellevel:SetText(GetTxtPri("DDZ_T32")..v[3]);
			
			
			--刷新职业头像
			local HeadPic = GetImage(view, 206);
			local pic = GetPetPotraitPic(v[2]);	
			HeadPic:SetPicture(pic,true);
				
				
		end			
	end	

end


function p.LoadCatchUI()
	
	local bglayer =p.GetParent();
	local layer = RecursiveUILayer(bglayer, {gCatchUITag});
	local scrollCatch = nil;
	if CheckP(layer) == false then 	    
 	    local layer = createNDUILayer();
 		if layer == nil then
 			return false;
 		end
 	    
 		layer:Init();
 		layer:SetTag(gCatchUITag);
 		layer:SetFrameRect(RectFullScreenUILayer);
 		bglayer:AddChildZ(layer,5);
 	    
 	    local uiLoad = createNDUILoad();
 		if nil == uiLoad then
 			layer:Free();
 			return false;
 		end
 		uiLoad:Load("slave/slave_Select.ini", layer, p.OnUIEventCatchUI, 0, 0);	
 		uiLoad:Free();
 		--全部战报
 		scrollCatch =  GetScrollViewContainer(layer, 101);--createUIScrollViewContainer();
 		if scrollCatch == nil then
 			LogInfo("scrollSlave == nil!");
 			return;
 		end
 	
 		local rectview = scrollCatch:GetFrameRect();
 		scrollCatch:SetStyle(UIScrollStyle.Verical);
 		scrollCatch:SetViewSize(CGSizeMake(rectview.size.w, rectview.size.h / 5));
 		scrollCatch:SetTopReserveDistance(rectview.size.h);
 		scrollCatch:EnableScrollBar(true);
 		scrollCatch:SetLuaDelegate((p.OnUIEventCatchUI));	
 	else
 		scrollCatch = GetScrollViewContainer(layer, 101); 
 		scrollCatch:RemoveAllView();								
	end

	
	for nUserId,v in pairs(g_tCatchList) do		
		LogInfo("LoadCatchUI nUserId"..nUserId);
		local view = createUIScrollView();		
		 if view ~= nil then
		 	view:Init(false);
		 	view:SetViewId(nUserId);
	 	
		 	--初始化ui
        	 local uiLoad = createNDUILoad();
        	 if nil == uiLoad then
           		 return false;
        	 end
		 	uiLoad:Load("slave/slave_L_4.ini", view, nil, 0, 0);
        	uiLoad:Free();
        	
		 	scrollCatch:AddView(view);
		 	
			local catchbtn = RecursiveButton(view, {6});
			catchbtn:SetParam1(nUserId);
			catchbtn:SetLuaDelegate((p.OnUIEventCatchUI));	
			
			local pLabelname = RecursiveLabel(view, {217});
			local pLabellevel = RecursiveLabel(view, {21});
			 		
			--{nUserId,nProid,nlevel,nWuguiState,sName};
			pLabelname:SetText(v[5]);
			pLabellevel:SetText(GetTxtPri("DDZ_T32")..v[3]);
			
			
			--刷新职业头像
			local HeadPic = GetImage(view, 206);
			local pic = GetPetPotraitPic(v[2]);	
			HeadPic:SetPicture(pic,true);
				
				
		end			
	end	
end




function p.ClearCatchData()
	g_tCatchList = {};
end

function p.InsertCatchData(nUserId,nProid,nlevel,nWuguiState,sName,nType,sLandlordName)
	--储存名字
	g_tCatchList[nUserId] = {nUserId,nProid,nlevel,nWuguiState,sName,nType,sLandlordName};
end

function p.ClearSynslaveData()
	g_tSynSlaveList = {};
end

function p.InsertSynslaveData(nUserId,nProid,nlevel,nWuguiState,sName,nType,sLandlordName)
	--储存名字
	g_tSynSlaveList[nUserId] = {nUserId,nProid,nlevel,nWuguiState,sName,nType,sLandlordName};
end

--==加载解救界面==--
function p.LoadSynSlaveUI()
 	local bglayer =p.GetParent();
    
    local layer = createNDUILayer();
	if layer == nil then
		return false;
	end
    
	layer:Init();
	layer:SetTag(gSynSlaveUITag);
	layer:SetFrameRect(RectFullScreenUILayer);
	bglayer:AddChildZ(layer,2);
    
    local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end
	uiLoad:Load("slave/slave_ChooseMember.ini", layer, p.OnUIEventSynSlaveUI, 0, 0);	
	--全部战报
	local scrollCatch =  GetScrollViewContainer(layer, 50);--createUIScrollViewContainer();
	if scrollCatch == nil then
		LogInfo("scrollSlave == nil!");
		return;
	end
	--scrollCatch:Init();
	local rectview = scrollCatch:GetFrameRect();
	scrollCatch:SetStyle(UIScrollStyle.Verical);
	scrollCatch:SetViewSize(CGSizeMake(rectview.size.w, rectview.size.h / 5));
	scrollCatch:SetTopReserveDistance(rectview.size.h);	
	scrollCatch:EnableScrollBar(true);
	scrollCatch:SetLuaDelegate((p.OnUIEventSynSlaveUI));
	
	
	local nPlayerId =  GetPlayerId();
	
	for nUserId,v in pairs(g_tSynSlaveList) do		
		
		if nUserId ~= nPlayerId then
			local view = createUIScrollView();		
			 if view ~= nil then
			 	view:Init(false);
			 	view:SetViewId(nUserId);
	 	
			 	--初始化ui
      		 	local uiLoad = createNDUILoad();
      			 if nil == uiLoad then
      	   		 	return false;
      		 	end
			 	uiLoad:Load("slave/slave_MemberList.ini", view, nil, 0, 0);
      		
			 	scrollCatch:AddView(view);
			 	
				local catchbtn = RecursiveButton(view, {19});
				catchbtn:SetParam1(nUserId);
				catchbtn:SetLuaDelegate((p.OnUIEventSynSlaveUI));	
				
				local pLabelname = RecursiveLabel(view, {79});
				pLabelname:SetText(v[5]..GetTxtPri("DDZ_T32")..v[3]);				
			end			
		end
		
			
	end	
end

--[[
	tmpMemberList
		tMember[ArmyGroupMemberIndex.AGMI_USERID]		= nUserID;
		tMember[ArmyGroupMemberIndex.AGMI_NAME]			= szName;
		tMember[ArmyGroupMemberIndex.AGMI_LEVEL]		= nLevel;
		tMember[ArmyGroupMemberIndex.AGMI_POSITION]		= nPosition;
		tMember[ArmyGroupMemberIndex.AGMI_RANKING]		= nRanking;
		tMember[ArmyGroupMemberIndex.AGMI_REPUTTODAY]	= nReputeToday;
		tMember[ArmyGroupMemberIndex.AGMI_REPUTTOTAL]	= nReputeTotal;
		tMember[ArmyGroupMemberIndex.AGMI_CONTTODAY]	= nContributeToday;
		tMember[ArmyGroupMemberIndex.AGMI_CONTTOTAL]	= nContributeTotal;
		tMember[ArmyGroupMemberIndex.AGMI_ISONLINE]		= nIsOnline;
		tMember[ArmyGroupMemberIndex.AGMI_LASTLOGOUT]	= nLastLogoutTime;
]]
--加载求救页面
local g_tMemberlist = {}


	
function p.LoadUISynSos()
	local bglayer =p.GetParent();
    
    local layer = createNDUILayer();
	if layer == nil then
		return false;
	end
    
	layer:Init();
	layer:SetTag(gSosUITag);
	layer:SetFrameRect(RectFullScreenUILayer);
	bglayer:AddChildZ(layer,2);
    
    local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end
	uiLoad:Load("slave/slave_ChooseMember.ini", layer, p.OnUIEventSynSosUI, 0, 0);	
	--全部战报
	local scrollCatch =  GetScrollViewContainer(layer, 50);--createUIScrollViewContainer();
	if scrollCatch == nil then
		LogInfo("scrollSlave == nil!");
		return;
	end
	--scrollCatch:Init();
	local rectview = scrollCatch:GetFrameRect();
	scrollCatch:SetStyle(UIScrollStyle.Verical);
	scrollCatch:SetViewSize(CGSizeMake(rectview.size.w, rectview.size.h / 5));
	scrollCatch:SetTopReserveDistance(rectview.size.h);		
	scrollCatch:EnableScrollBar(true);
	scrollCatch:SetLuaDelegate((p.OnUIEventSynSosUI));
	
	--g_SynSosList[nUserId] = {nUserId,nLevel,nName};
	local nUserId =  GetPlayerId();
	
	
	for i,v in pairs(g_SynSosList) do
		if nUserId ~= i then
			local view = createUIScrollView();		
			 if view ~= nil then
			 	view:Init(false);
			 	view:SetViewId(i);
	 		
			 	--初始化ui
        		 local uiLoad = createNDUILoad();
        		 if nil == uiLoad then
        	   		 return false;
        		 end
			 	uiLoad:Load("slave/slave_MemberList.ini", view, nil, 0, 0);
        		
			 	scrollCatch:AddView(view);
			 	
				local catchbtn = RecursiveButton(view, {19});
				catchbtn:SetParam1(i);
				catchbtn:SetLuaDelegate((p.OnUIEventSynSosUI));
				catchbtn:SetTitle(GetTxtPri("DDZ_T18"));
				local pLabelname = RecursiveLabel(view, {79});
				pLabelname:SetText(v[3]..GetTxtPri("DDZ_T32")..v[2]);
			end				
		end			
	end		
end

--消耗霸王金牌抓奴隶
function p.BawangCatch(nId, param)
    if (CommonDlgNew.BtnOk == nId ) then		
  	 	 if gBawang <= 0 then   
  	 	 	CommonDlgNew.ShowYesDlg( GetTxtPri("DDZ_T33")); 	 	 	
   	 		return;
   		 end		
   		 
   		 LogInfo("qboy p.BawangCatch gCatchUserId:"..gCatchUserId);
		MsgSlave.SendAction(SlaveActionType.ActionCatch,gCatchUserId,g_IndexChosen);	
		local bglayer =p.GetParent();
  		bglayer:RemoveChildByTag(gCatchUITag, true);		
	end
end


function p.BawangEnemy(nId, param)
    if (CommonDlgNew.BtnOk == nId ) then		
  	 	 if gBawang <= 0 then   
  	 	 	CommonDlgNew.ShowYesDlg( GetTxtPri("DDZ_T33")); 	 	 	
   	 		return;
   		 end		
		MsgSlave.SendAction(SlaveActionType.ActionAttEnemy,gCatchUserId,g_IndexChosen);		
  		
  		local bglayer =p.GetParent();
  		bglayer:RemoveChildByTag(gCatchUITag, true);			
	end
end


function p.BawangSynSlave(nId, param)
    if (CommonDlgNew.BtnOk == nId ) then		
  	 	 if gBawang <= 0 then   
  	 	 	CommonDlgNew.ShowYesDlg( GetTxtPri("DDZ_T33")); 	 	 	
   	 		return;
   		 end
		MsgSlave.SendAction(SlaveActionType.ActionHelp,gSynSlaveId);	
		
		local bglayer =p.GetParent();
  		bglayer:RemoveChildByTag(gSynSlaveUITag, true);	
	end
end

function p.CloseUI()
	local scene = GetSMGameScene();
	scene:RemoveChildByTag(NMAINSCENECHILDTAG.SlaveUI,true);
end
			

	


function p.ClearSynSosData()
	g_SynSosList = {}
end		

function p.InsertSosData(nUserId,nLevel,nName)	
	g_SynSosList[nUserId] = {nUserId,nLevel,nName};
end

---------=====================触摸事件处理=====================---------

function p.CatchSlave2(nId, param)
    if (CommonDlgNew.BtnOk == nId ) then	
		MsgSlave.SendAction(SlaveActionType.ActionCatch,gCatchUserId,g_IndexChosen);
  		local bglayer =p.GetParent();
  		bglayer:RemoveChildByTag(gCatchUITag, true);			
	end
end

function p.CatchSlave(nId, param)
    if (CommonDlgNew.BtnOk == nId ) then	
    	if g_tCatchList[gCatchUserId][4] == 1 then
    		CommonDlgNew.ShowYesOrNoDlg( GetTxtPri("DDZ_T34"), p.BawangCatch, true );
  		else 		
  		  	MsgSlave.SendAction(SlaveActionType.ActionCatch,gCatchUserId,g_IndexChosen);
  			local bglayer =p.GetParent();
  			bglayer:RemoveChildByTag(gCatchUITag, true);	
       	end    	
    end
end

function p.OnUIEventCatchUI(uiNode, uiEventType, param)
  local tag = uiNode:GetTag();
    LogInfo("qboy p.OnUIEventCatchUI hit tag = %d", tag);
	local bglayer =p.GetParent();
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
	 	--关闭按钮
        if 14 == tag then    
			bglayer:RemoveChildByTag(gCatchUITag, true);
		elseif 6 ==tag then
   		 	local btn = ConverToButton(uiNode);
    		local nUserId = btn:GetParam1(); 	
    		gCatchUserId = nUserId;
  			
    		if g_tCatchList[nUserId][6] == tSlaveType.Slave then
    		--抢奴隶	
    			CommonDlgNew.ShowYesOrNoDlg( "【"..g_tCatchList[nUserId][5]..GetTxtPri("DDZ_T35")..g_tCatchList[nUserId][7]..GetTxtPri("DDZ_T36")..g_tCatchList[nUserId][7]..GetTxtPri("DDZ_T37"), p.CatchSlave, true );
    		elseif g_tCatchList[nUserId][6] == tSlaveType.Owner then
    		--抢奴隶	
 				CommonDlgNew.ShowYesOrNoDlg( "【"..g_tCatchList[nUserId][5]..GetTxtPri("DDZ_T38"), p.CatchSlave, true );			
    		else
    		--抓捕自由人
 				CommonDlgNew.ShowYesOrNoDlg( "【"..g_tCatchList[nUserId][5]..GetTxtPri("DDZ_T39"), p.CatchSlave, true );  				
    		end		    		
    		LogInfo("qboy p.OnUIEventCatchUI nUserId"..nUserId.." "..g_IndexChosen);

    	elseif 93 == tag then	  		
    		MsgSlave.SendAction(SlaveActionType.ActionGetTargetList);
		end
	end
	return true;
end




function p.CatchEnemy2(nId, param)
    if (CommonDlgNew.BtnOk == nId ) then	
		MsgSlave.SendAction(SlaveActionType.ActionAttEnemy,gCatchUserId,g_IndexChosen);
  		local bglayer =p.GetParent();
  		bglayer:RemoveChildByTag(gCatchUITag, true);		
	end
end

function p.CatchEnemy(nId, param)
    if (CommonDlgNew.BtnOk == nId ) then	   		
    	
    	
    	if g_tCatchList[gCatchUserId][4] == 1 then
    		CommonDlgNew.ShowYesOrNoDlg( GetTxtPri("DDZ_T34"), p.BawangEnemy, true );
  		else 		
  		  	MsgSlave.SendAction(SlaveActionType.ActionAttEnemy,gCatchUserId,g_IndexChosen);
  		  	local bglayer =p.GetParent();
  		  	bglayer:RemoveChildByTag(gCatchUITag, true);
  		  	
       	end       	
    end
end

function p.OnUIEventEnemyUI(uiNode, uiEventType, param)
  local tag = uiNode:GetTag();
    LogInfo("qboy p.OnUIEventEnemyUI hit tag = %d", tag);
	local bglayer =p.GetParent();
	
	--local nPlayerId =  GetPlayerId();
		
	
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
	 	--关闭按钮
        if 14 == tag then    
			bglayer:RemoveChildByTag(gCatchUITag, true);
		elseif 6 ==tag then
   		 	local btn = ConverToButton(uiNode);
    		local nUserId = btn:GetParam1(); 	
    		gCatchUserId = nUserId;
    		LogInfo("qboy p.OnUIEventEnemyUI nUserId"..nUserId.." "..g_IndexChosen);	

    			   			
    		if g_tCatchList[nUserId][6] == tSlaveType.Slave then
    		--抢奴隶	
    			CommonDlgNew.ShowYesOrNoDlg( "【"..g_tCatchList[nUserId][5]..GetTxtPri("DDZ_T35")..g_tCatchList[nUserId][7]..GetTxtPri("DDZ_T36")..g_tCatchList[nUserId][7]..GetTxtPri("DDZ_T37"), p.CatchEnemy, true );
    		elseif g_tCatchList[nUserId][6] == tSlaveType.Owner then
    		--抢奴隶	
 				CommonDlgNew.ShowYesOrNoDlg( "【"..g_tCatchList[nUserId][5]..GetTxtPri("DDZ_T38"), p.CatchEnemy, true );			
    		else
    		--抓捕自由人
 				CommonDlgNew.ShowYesOrNoDlg( "【"..g_tCatchList[nUserId][5]..GetTxtPri("DDZ_T39"), p.CatchEnemy, true );  				
    		end		    	  			

     	elseif 93 == tag then	  		
    		MsgSlave.SendAction(SlaveActionType.ActionGetEnemyList);   		
    		
		end
	end
	return true;
end




function p.HelpSynSlave(nId, param)
    if (CommonDlgNew.BtnOk == nId ) then 	
    	if g_tSynSlaveList[gSynSlaveId][4] == 1 then
    		CommonDlgNew.ShowYesOrNoDlg( GetTxtPri("DDZ_T40"), p.BawangSynSlave, true );
  		else
  		  	MsgSlave.SendAction(SlaveActionType.ActionHelp,gSynSlaveId);
  		  	
  		  	local bglayer =p.GetParent();
  		  	bglayer:RemoveChildByTag(gSynSlaveUITag, true);
       	end       	
    end
end

function p.OnUIEventSynSlaveUI(uiNode, uiEventType, param)
  local tag = uiNode:GetTag();
    LogInfo("qboy p.OnUIEventSynSlaveUI hit tag = %d", tag);
	local bglayer =p.GetParent();
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
	 	--关闭按钮
        if 49 == tag then    
			bglayer:RemoveChildByTag(gSynSlaveUITag, true);
		elseif 19 ==tag then
   		 	local btn = ConverToButton(uiNode);
    		local nUserId = btn:GetParam1(); 	
    		gSynSlaveId = nUserId;
    		
    		CommonDlgNew.ShowYesOrNoDlg( "【"..g_tSynSlaveList[nUserId][5]..GetTxtPri("DDZ_T35")..g_tSynSlaveList[nUserId][7]..GetTxtPri("DDZ_T36")..g_tSynSlaveList[nUserId][7]..GetTxtPri("DDZ_T37") , p.HelpSynSlave, true );	  		    		
		end
	end
	return true;
end




local g_nSoSUserid = 0;
function p.ConfirmSos(nId, param)
    if (CommonDlgNew.BtnOk == nId ) then		
		MsgSlave.SendAction(SlaveActionType.ActionSOS,g_nSoSUserid);
  		
  		local bglayer =p.GetParent();
  		bglayer:RemoveChildByTag(gSosUITag, true);			
	end
end

function p.OnUIEventSynSosUI(uiNode, uiEventType, param)
  local tag = uiNode:GetTag();
    LogInfo("qboy p.OnUIEventSynSosUI hit tag = %d", tag);
	local bglayer =p.GetParent();
   
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
	 	--关闭按钮      
        if 49 == tag then    
			bglayer:RemoveChildByTag(gSosUITag, true);
		elseif 19 ==tag then	
   		 	local btn = ConverToButton(uiNode);
    		local nUserId = btn:GetParam1(); 	
    		g_nSoSUserid = nUserId;
    		
			local sname = "";
			for i,v in pairs(g_SynSosList) do		
					if nUserId == v[1] then
						sname = v[3];				
					end
			end	 
			CommonDlgNew.ShowYesOrNoDlg( GetTxtPri("DDZ_T41")..sname..GetTxtPri("DDZ_T42"), p.ConfirmSos, true );
		end
	end
	return true;
end



function p.Revolt(nId, param)
    if (CommonDlgNew.BtnOk == nId ) then		
		MsgSlave.SendAction(SlaveActionType.ActionRevolt);
	end
end

function p.OnUIEventSlaveScroll(uiNode, uiEventType, param)
  local tag = uiNode:GetTag();
    LogInfo("qboy p.OnUIEventSlaveScroll hit tag = %d", tag);
    --

    
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
	   	 local btn = ConverToButton(uiNode);
   		 local nIndex = btn:GetParam1(); --获取槽位
   		 LogInfo("qboy p.OnUIEventSlaveScrolln Index = %d", nIndex);
   		 
   		 g_IndexChosen = nIndex;
		if  1 == tag then   
			--抓捕
			MsgSlave.SendAction(SlaveActionType.ActionGetTargetList);
		elseif 2== tag then
			--复仇
			MsgSlave.SendAction(SlaveActionType.ActionGetEnemyList);
		elseif 3== tag then
			--升级
			--MsgSlave.SendAction(SlaveActionType.ActionUpgradeSlave);
			p.LoadUpgradeSlave();
		elseif 97== tag then
			--互动
			--local gRevoltCD = 0;
			--local gActivityCD = 0;
			if gActivityCD > 0 then
				local sec = 0;
				local min = 0;
				
				if gActivityCD >= 60 then
					min = math.floor(gActivityCD/60);
					sec = gActivityCD - min*60;				
					CommonDlgNew.ShowTipDlg(GetTxtPri("DDZ_T43")..min..GetTxtPri("DDZ_T44")..sec..GetTxtPri("DDZ_T45"));
				else
					CommonDlgNew.ShowTipDlg(GetTxtPri("DDZ_T43")..gActivityCD..GetTxtPri("DDZ_T45")); 
				end				
				return true;
			end		
			
			MsgSlave.SendAction(SlaveActionType.ActionActivity);
		elseif 6 == tag then				  
			if  gType == tSlaveType.Slave then
				--求救
				local nUserID = GetPlayerId();
				
				--无军团返回
				local nAGID			= MsgArmyGroup.GetUserArmyGroupID( nUserID );
	
				if nAGID == nil then
					CommonDlgNew.ShowTipDlg(GetTxtPri("DDZ_T46")); 
					return true;
				end					
				
				MsgSlave.SendAction(SlaveActionType.ActionSosList);
			else
				--压榨	
				--g_IndexChosen
				local timeleft =  g_tSlaveData[g_IndexChosen][2];			
				local goldneed = 0;
				
				if timeleft <= 600 then
					goldneed = 1;
				else
					goldneed = math.floor(timeleft/600) + 1;
				end
						
				CommonDlgNew.ShowYesOrNoDlg( string.format(GetTxtPri("DDZ_T47"), goldneed), p.CompleteSlaveWork, true );
			end			
		elseif 7 == tag then	
			 
			if  gType == tSlaveType.Slave then
				--反抗
				if gRevoltCD > 0 then
					local sec = 0;
					local min = 0;
					
					if gRevoltCD >= 60 then
						min = math.floor(gRevoltCD/60);
						sec = gRevoltCD - min*60;				
						CommonDlgNew.ShowTipDlg(GetTxtPri("DDZ_T48")..min..GetTxtPri("DDZ_T44")..sec..GetTxtPri("DDZ_T45"));
					else
						CommonDlgNew.ShowTipDlg(GetTxtPri("DDZ_T48")..gRevoltCD..GetTxtPri("DDZ_T45")); 
					end				
					return true;
				end		
							
				
				CommonDlgNew.ShowYesOrNoDlg( string.format(GetTxtPri("DDZ_T49"), g_OwnerName), p.Revolt, true );
			else
				--释放 
				CommonDlgNew.ShowYesOrNoDlg( string.format(GetTxtPri("DDZ_T50"), g_tSlaveData[nIndex][5]), p.FreeSlave, true );
			end
		elseif 18 == tag then
			p.LoadUpgradeSlave();
		end	
	end

	return true;
end


--[[
local gAddCatchCount = 0;
local gAddHelpCount  = 0;
local gAddRevoltCount = 0;
local gAddActivityCount = 0;
local gAddSosCount = 0;
--]]
local gAddType = 0;
function p.AddCount(nId, param)
    if (CommonDlgNew.BtnOk == nId ) then 	
		MsgSlave.SendAction(gAddType);
	end
end


function p.OnUIEvent(uiNode, uiEventType, param)
  local tag = uiNode:GetTag();
    LogInfo("qboy p.OnUIEvent hit tag = %d", tag);
    --
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
        --关闭按钮      
        if 533 == tag then    
			--CloseUI(NMAINSCENECHILDTAG.SlaveUI);	
			UnRegisterTimer(p.CoinTimerTag);
			p.CoinTimerTag = nil;
			UnRegisterTimer(p.SlaveTimerTag);
			p.SlaveTimerTag = nil;

			MsgSlave.SendAction(SlaveActionType.ActionQuit) 			
		elseif 57 == tag then
			CommonDlgNew.ShowYesOrNoDlg( string.format(GetTxtPri("DDZ_T51"), (gAddActivityCount*2+2)), p.AddCount , true );
			gAddType = SlaveActionType.ActionAddActivityCount;
		elseif 43 == tag then	
			if  gType == tSlaveType.Slave then
				CommonDlgNew.ShowYesOrNoDlg( string.format(GetTxtPri("DDZ_T52"), (gAddSosCount*2+2)), p.AddCount , true );
				gAddType = SlaveActionType.ActionAddSOSCount;
			else
				CommonDlgNew.ShowYesOrNoDlg( string.format(GetTxtPri("DDZ_T53"), (gAddHelpCount*2+2)), p.AddCount , true );
				gAddType = SlaveActionType.ActionAddHelpCount;
			end		
		elseif 45 == tag then	
			if  gType == tSlaveType.Slave then
				CommonDlgNew.ShowYesOrNoDlg( string.format(GetTxtPri("DDZ_T54"), (gAddRevoltCount*2+2)), p.AddCount , true );
				gAddType = SlaveActionType.ActionAddRevoltCount
			else
				CommonDlgNew.ShowYesOrNoDlg( string.format(GetTxtPri("DDZ_T55"), (gAddCatchCount*2+2)), p.AddCount , true );
				gAddType = SlaveActionType.ActionAddCatchCount
			end
		elseif 51 == tag then
			--解救
			--无军团返回
			local nUserID		= GetPlayerId();
			local nAGID			= MsgArmyGroup.GetUserArmyGroupID( nUserID );
	
			if nAGID == nil then
				CommonDlgNew.ShowTipDlg(GetTxtPri("DDZ_T46")); 
				return true;
			end	
			
			MsgSlave.SendAction(SlaveActionType.ActionGetSyndicateSlave);			
		elseif 52 == tag then
			--提取
			if gGained >= gMaxGain then
				CommonDlgNew.ShowTipDlg(GetTxtPri("DDZ_T56")); 
				return true;
			end
			
			MsgSlave.SendAction(SlaveActionType.ActionExtractCoin);
        end
    end
    --]]
	return true;	
	
end


local gNotify = ""
p.NotifyTimerTag = nil;
--通知做个延时
function p.NotifyTimerOntime(tag)	
	UnRegisterTimer(tag);
	if gNotify ~= "" then
		CommonDlgNew.ShowYesDlg(gNotify);
	end	
end


function p.EndBattleNotify()
	p.NotifyTimerTag = RegisterTimer(p.NotifyTimerOntime,1, "Slave.NotifyTimerOntime");	
end

function p.SetNotify(sNotify)
	gNotify = sNotify;
end

-----------------------------获取父层layer---------------------------------
function p.GetParent()

	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end
	
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.SlaveUI);
	if nil == layer then
		return nil;
	end
	
	return layer;
end