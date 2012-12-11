---------------------------------------------------
--描述: 军团战赛程界面
--时间: 2012.10.24
--作者: qbw
---------------------------------------------------
SyndicateBattleResultUI = {}
local p = SyndicateBattleResultUI;


local ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_67						= 69;
local ID_ARMYGROUPBATTLESCHEDULE_CTRL_PICTURE_65					= 68;
local ID_ARMYGROUPBATTLESCHEDULE_CTRL_PICTURE_64					= 67;
local ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_66						= 66;
local ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_65						= 65;
local ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_64						= 64;
local ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_63						= 63;
local ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_62						= 62;
local ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_61						= 61;
local ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_60						= 60;
local ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_59						= 59;
local ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_58						= 58;
local ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_57						= 57;
local ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_56						= 56;
local ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_55						= 55;
local ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_54						= 54;
local ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_53						= 53;
local ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_52						= 52;
local ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_16						= 16;
local ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_15						= 15;
local ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_14						= 14;
local ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_13						= 13;
local ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_12						= 12;
local ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_11						= 11;
local ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_10						= 10;
local ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_9						= 9;
local ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_8						= 8;
local ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_7						= 7;
local ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_6						= 6;
local ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_5						= 5;
local ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_4						= 4;
local ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_3						= 3;
local ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_2						= 2;
local ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_1						= 1;
local ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_51						= 51;
local ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_50						= 50;
local ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_49						= 49;
local ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_48						= 48;
local ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_47						= 47;
local ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_46						= 46;
local ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_45						= 45;
local ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_44						= 44;
local ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_43						= 43;
local ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_42						= 42;
local ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_41						= 41;
local ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_40						= 40;
local ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_39						= 39;
local ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_38						= 38;
local ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_37						= 37;
local ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_36						= 36;
local ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_35						= 35;
local ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_34						= 34;
local ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_33						= 33;
local ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_32						= 32;
local ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_31						= 31;
local ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_30						= 30;
local ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_29						= 29;
local ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_28						= 28;
local ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_27						= 27;
local ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_26						= 26;
local ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_25						= 25;
local ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_24						= 24;
local ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_23						= 23;
local ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_22						= 22;
local ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_21						= 21;
local ID_ARMYGROUPBATTLESCHEDULE_CTRL_PICTURE_100					= 100;


local tSyndicateBtnTag = {} 
	tSyndicateBtnTag[16] = ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_16
	tSyndicateBtnTag[15] = ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_15
	tSyndicateBtnTag[14] = ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_14
	tSyndicateBtnTag[13] = ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_13
	tSyndicateBtnTag[12] = ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_12
	tSyndicateBtnTag[11] = ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_11
	tSyndicateBtnTag[10] = ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_10
	tSyndicateBtnTag[9] = ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_9	
	tSyndicateBtnTag[8] = ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_8	
	tSyndicateBtnTag[7] = ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_7	
	tSyndicateBtnTag[6] = ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_6	
	tSyndicateBtnTag[5] = ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_5	
	tSyndicateBtnTag[4] = ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_4	
	tSyndicateBtnTag[3] = ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_3	
	tSyndicateBtnTag[2] = ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_2	
	tSyndicateBtnTag[1] = ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_1	


local tLineBtnTag = {}
	  --tLineBtnTag[nBattleId] = {attk,deff}
	  tLineBtnTag[0] ={ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_21,ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_22}
	  tLineBtnTag[1] ={ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_23,ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_24}
	  tLineBtnTag[2] ={ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_25,ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_26}
	  tLineBtnTag[3] ={ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_27,ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_28}
	  tLineBtnTag[4] ={ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_29,ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_30}
	  tLineBtnTag[5] ={ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_31,ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_32}
	  tLineBtnTag[6] ={ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_33,ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_34}
	  tLineBtnTag[7] ={ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_35,ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_36}
	  tLineBtnTag[8] ={ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_37,ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_38}
	  tLineBtnTag[9] ={ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_39,ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_40}
	  tLineBtnTag[10] ={ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_41,ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_42}
	  tLineBtnTag[11] ={ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_43,ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_44}
	  tLineBtnTag[12] ={ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_45,ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_46}
	  tLineBtnTag[13] ={ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_47,ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_48}
	  tLineBtnTag[14] ={ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_49,ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_50}



local tLineState = {
	LOSE =0;
	WIN = 1;
	CHAMPION = 2;
}

local tBattleType ={
	Result  = 0;
	Eight 	= 1;
	Four	= 2;
	Two	    = 3;
	One		= 4;
}

local NameColor = {
	ATTLIST = ccc4(0,198,213,255),
	GREEN = ccc4(28,237,93,255),      --绿色
	YELLOW = ccc4(255, 255, 0, 255),
	DEFLIST = ccc4(248,66,0,255),
	GRAY =ccc4(128,128,128,255),
	WINNER =ccc4(255,215,0,255),
	WHITE = ccc4(255,255,255,255),
	LOSER = ccc4(90,90,90,255),
}


local g_BattleType = tBattleType.Result;

--============================改变线条显示状态===============================--
--pic文件名
local tLinePicName = {}
	for battleid = 0,3 do
	 	tLinePicName[battleid] = {"ArmyGroupBattle/ArmyGroupBattle01.png","ArmyGroupBattle/ArmyGroupBattle02.png"};
	end

	for battleid = 4,7 do
	 	tLinePicName[battleid] = {"ArmyGroupBattle/ArmyGroupBattle08.png","ArmyGroupBattle/ArmyGroupBattle09.png"};
	end
	
	for battleid = 8,9 do
	 	tLinePicName[battleid] = {"ArmyGroupBattle/ArmyGroupBattle03.png","ArmyGroupBattle/ArmyGroupBattle04.png"};
	end
	
	for battleid = 10,11 do
	 	tLinePicName[battleid] = {"ArmyGroupBattle/ArmyGroupBattle10.png","ArmyGroupBattle/ArmyGroupBattle11.png"};
	end	
	
	tLinePicName[12] = {"ArmyGroupBattle/ArmyGroupBattle05.png","ArmyGroupBattle/ArmyGroupBattle06.png"};
	
	tLinePicName[13] = {"ArmyGroupBattle/ArmyGroupBattle12.png","ArmyGroupBattle/ArmyGroupBattle13.png"};
	
	tLinePicName[14] = {"ArmyGroupBattle/ArmyGroupBattle07.png","ArmyGroupBattle/ArmyGroupBattle07.png"};
	

--rect  灰 白 红
local tLineRect = {}
	tLineRect[1] = {CGRectMake(0, 0, 68, 36) ,CGRectMake(0, 36, 68, 36) ,CGRectMake(0, 72, 68, 36) }
	tLineRect[2] = {CGRectMake(0, 0, 65, 71) ,CGRectMake(0, 71, 65, 71) ,CGRectMake(0, 142, 65, 71) }
	tLineRect[3] = {CGRectMake(0, 0, 67, 143) ,CGRectMake(0, 143, 67, 143) ,CGRectMake(0, 286, 67, 143) }
	tLineRect[4] = {CGRectMake(0, 0, 79, 2) ,CGRectMake(0, 2,  79, 2) ,CGRectMake(0, 5, 79, 2) }


--设置状态  按钮 战斗id 是否为攻击方 设置状态
function p.SetLineState(linebtn,battleid,nIfAttk,nState)
	local pool = DefaultPicPool();
	local scene = GetSMGameScene();

	local sPicName = tLinePicName[battleid][nIfAttk];
	
	local cutRect = nil;
	if  battleid <= 7 then
		cutRect = tLineRect[1][nState];
	elseif battleid <=11 then
		cutRect = tLineRect[2][nState];
	elseif battleid <= 13 then
		cutRect = tLineRect[3][nState];
	else
		cutRect = tLineRect[4][nState];
	end
	
	local pic = pool:AddPicture(GetSMImgPath(sPicName), false);
 	pic:Cut(cutRect);
 		
	linebtn:SetImage(pic);
	linebtn:EnableEvent(true);		
end 	
 	
 	
local winsize	= GetWinSize();
local tresultdata ={}
local g_Count = 0;


local g_tResultData = {}

--[[
        step.battleID = netdata:ReadInt()
        step.attSynID = netdata:ReadInt()
        step.defSynID = netdata:ReadInt()
        step.result = netdata:ReadInt()
    	step.Attname = netdata:ReadUnicodeString();
        step.Defname = netdata:ReadUnicodeString();
--]]

	  --tLineBtnTag[nBattleId] = {attk,deff}


local tBattleIdBattleResultBtn = {}
		tBattleIdBattleResultBtn[14] = ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_66;
		tBattleIdBattleResultBtn[13] = ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_65;
		tBattleIdBattleResultBtn[12] = ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_64;
		tBattleIdBattleResultBtn[11] = ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_63;
		tBattleIdBattleResultBtn[10] = ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_62;
		tBattleIdBattleResultBtn[9 ] = ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_61;
		tBattleIdBattleResultBtn[8 ] = ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_60;
		tBattleIdBattleResultBtn[7 ] = ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_59;
		tBattleIdBattleResultBtn[6 ] = ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_58;
		tBattleIdBattleResultBtn[5 ] = ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_57;
		tBattleIdBattleResultBtn[4 ] = ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_56;
		tBattleIdBattleResultBtn[3 ] = ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_55;
		tBattleIdBattleResultBtn[2 ] = ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_54;
		tBattleIdBattleResultBtn[1 ] = ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_53;
		tBattleIdBattleResultBtn[0 ] = ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_52;

--==========================刷新显示赛程==========================--
function p.RefreshResult()
	local layer = p.GetParent();
	local nUserID		= GetPlayerId();
	local nAGID			= MsgArmyGroup.GetUserArmyGroupID( nUserID );
	
	--屏蔽触摸查看按钮
	for i,v in pairs(tBattleIdBattleResultBtn) do
		local checkbtn = GetButton(layer, v);
   		checkbtn:SetFocus( true );		
	end
	
	
	--显示参赛军团
	for i,v in pairs(g_tResultData) do
		if v.battleID <= 7 then
			local attktag =  tSyndicateBtnTag[(v.battleID+1)*2-1];
			local defftag =  tSyndicateBtnTag[(v.battleID+1)*2];
			    
   			local attkbtn = GetButton(layer, attktag);
   			local deffbtn = GetButton(layer, defftag);
   			
   			attkbtn:SetTitle(v.Attname);
   			deffbtn:SetTitle(v.Defname); 	
   			
   			
   			local  nAttBattleId = p.GetBattleId(v.attSynID);
   			local  nDefBattleId = p.GetBattleId(v.defSynID);
   			LogInfo("qboy 999 nAttBattleId:"..nAttBattleId.." nDefBattleId:"..nDefBattleId);
			
   			if  nAttBattleId == -1 or nAttBattleId== -2 then 			
   				attkbtn:SetFontColor(NameColor.LOSER);		
   			else
   				--att win
   				attkbtn:SetFontColor(NameColor.WHITE);
   			end
   			
   			
   			if nDefBattleId == -1 or nDefBattleId== -2 then
   				deffbtn:SetFontColor(NameColor.LOSER);	
   			else
   			--def win
   				deffbtn:SetFontColor(NameColor.WHITE);
   			end
 
   			--自己的军团获胜则标红
 			if nAGID ~= nil then
				if nAGID == v.attSynID and nAttBattleId ~= -2 then
					attkbtn:SetFontColor(NameColor.DEFLIST);
				elseif  nAGID == v.defSynID and nDefBattleId ~= -2 then
					deffbtn:SetFontColor(NameColor.DEFLIST);
				end
			end
			   			
		end
	end
	
	--获取冠军军团id 无则返回-99
	local nFinalWinerId = -99
	local sFinalWinerName = "";
	
		for i,v in pairs(g_tResultData) do
			LogInfo("i:"..i);
			if v.battleID == 14 then
				LogInfo("battle 14 v.result:"..v.result);
				if v.result == 1 then
					nFinalWinerId = v.attSynID;
					sFinalWinerName = v.Attname;
      
				elseif v.result == 0 then
					nFinalWinerId = v.defSynID
					sFinalWinerName = v.Defname;
				end
			end
		end
	
	--冠军决出
	if sFinalWinerName~= "" then
		local winerbtn = GetButton(layer, 51);
   		winerbtn:SetTitle(sFinalWinerName);	
   		winerbtn:SetFontColor(NameColor.WINNER);
   		
   		--隐藏参加按钮
   		local joinbtn = GetButton(layer, 70);
   		joinbtn:SetVisible(false);
   		
   		--显示上方label
		local CDlabel = p.GetEnterEndCDLabel();
		CDlabel:SetText("--:--:--");
		local DescLabel = p.GetDescLabel();
   		DescLabel:SetText(" 军团战结果:");
   		
   		
   	else
   		local joinbtn = GetButton(layer, 70);
   		joinbtn:SetVisible(true);
   		   		
	end

	--准备阶段
	if g_BattleType == 5 then
		--显示上方label
		local CDlabel = p.GetEnterEndCDLabel();
		CDlabel:SetText("--:--:--");
		local DescLabel = p.GetDescLabel();
   		DescLabel:SetText(" 军团战准备中:");		
		
	end

	
	--根据战斗结果显示赛程图
	for i,v in pairs(g_tResultData) do
		
		local AttLinetag =  tLineBtnTag[v.battleID][1];
		local DefLinetag =  tLineBtnTag[v.battleID][2];
		
		local AttLinebtn = GetButton(layer, AttLinetag);
		local DefLinebtn = GetButton(layer, DefLinetag);

		local tag = tBattleIdBattleResultBtn[v.battleID];
		local btncheck = GetButton(layer, tag);
		
		if v.result == 1 then
			--att赢
			if nFinalWinerId == v.attSynID then
				p.SetLineState(AttLinebtn,v.battleID,1,3)
			else
				p.SetLineState(AttLinebtn,v.battleID,1,2)
			end	
			
			p.SetLineState(DefLinebtn,v.battleID,2,1)
			btncheck:SetFontColor(NameColor.WHITE);
			btncheck:SetFocus( false );
		elseif v.result == 0 then
			--def赢
			LogInfo("battle  v.result 2");
			if nFinalWinerId == v.defSynID then
				p.SetLineState(DefLinebtn,v.battleID,2,3)
			else
				p.SetLineState(DefLinebtn,v.battleID,2,2)
			end
			
			p.SetLineState(AttLinebtn,v.battleID,1,1)
			--WHITE
			btncheck:SetFontColor(NameColor.WHITE);
			btncheck:SetFocus( false );
		else
			--设置查看按钮颜色
			btncheck:SetFontColor(NameColor.GRAY);
			
		end
		
	end
end


--=========重置数据=======----
function p.ResetData()
	g_tResultData = {}

end


function p.LoadResultData(ntype,tresultdata,nTimeLeft,nBattleEndTime)
	g_BattleType = ntype;
	p.updateEnterEndCount(nTimeLeft,nBattleEndTime);
	
	--界面未显示且战斗界面也未显示则打开界面
	if not IsUIShow(NMAINSCENECHILDTAG.SyndicateBattleResultUI) and not IsUIShow(NMAINSCENECHILDTAG.SyndicateBattleUI) then
		p.ResetData();
		g_tResultData = tresultdata;
		p.LoadUI();
	elseif not IsUIShow(NMAINSCENECHILDTAG.SyndicateBattleResultUI) and  IsUIShow(NMAINSCENECHILDTAG.SyndicateBattleUI)  then
	--如果界面未显示 但是战斗界面显示,则加载数据。
		p.ResetData();
		g_tResultData = tresultdata;
	else
	--如果界面已显示则刷新显示。
		g_tResultData = tresultdata;
		p.RefreshResult();
	end
	
	--刷新cd时间
	--nTimeLeft
	

end


--=======================参战倒计时========================---
local g_EnterEndTime = 0;
local g_BattleEndTime = 0;


p.TimerTag = nil;
local nRefreshCount = 0;
--更新倒计时
function p.updateEnterEndCount(restCount,nBattleEndTime)
	g_EnterEndTime = restCount;
	g_BattleEndTime = nBattleEndTime;
	
	local CDlabel = p.GetEnterEndCDLabel();
	local DescLabel = p.GetDescLabel();
	

	
	if CDlabel ~= nil then
		--LogInfo("qboy CDlabel nil:"); 
		if restCount <= 0 and nBattleEndTime<= 0  then

			DescLabel:SetText(" 军团战结果:");
			CDlabel:SetText("--:--:--");
		elseif restCount > 0 then
			CDlabel:SetText(FormatTime(restCount,1));
		elseif 	nBattleEndTime >= 0 then
			CDlabel:SetText(FormatTime(nBattleEndTime,1));
		end
	end

end


local tDescBattleType = {}
	tDescBattleType[0] = " 军团战结果:";
	tDescBattleType[1] = "八强赛进行中:";
	tDescBattleType[2] = "四强赛进行中:";
	tDescBattleType[3] = "半决赛进行中:";
	tDescBattleType[4] = "决赛进行中:";
	tDescBattleType[5] = " 军团战准备中:";



function p.TimerTick(tag)
	 --如果为开启ui则关闭计时器
	if not IsUIShow(NMAINSCENECHILDTAG.SyndicateBattleResultUI)  and not IsUIShow(NMAINSCENECHILDTAG.SyndicateBattleUI)  then
		UnRegisterTimer(tag);
		p.TimerTag = nil;
		return;
	end
	
	
	--每隔x秒进行刷新时间
	nRefreshCount = nRefreshCount+1;
	
	if nRefreshCount >= 20 then
		nRefreshCount = 0
		
		--刷新
		LogInfo("qboy p.TimerTick");
		MsgSyndicateBattle.GetStepInfo();
	end
	

	
	
	if tag == p.TimerTag then
	
		--1秒才刷新
		if nRefreshCount%2 == 0 then
				g_EnterEndTime = g_EnterEndTime - 1;
				g_BattleEndTime = g_BattleEndTime - 1;
				--刷新计数文字
				if g_EnterEndTime <= 0 then
					g_EnterEndTime = 0;
				end
			
				if g_BattleEndTime <= 0 then
					g_BattleEndTime = 0;
				end	
		end
		

		
		if IsUIShow(NMAINSCENECHILDTAG.SyndicateBattleUI) then
			local BattleUIlabel  = SyndicateBattleUI.GetBattleEndCDLabel();
			local BattleUIDesclabel = SyndicateBattleUI.GetDescLabel();
			if g_EnterEndTime > 0 then
					BattleUIlabel:SetText(FormatTime(g_EnterEndTime,1));
					BattleUIDesclabel:SetText("参战倒计时: ");
					
					--闪光提示
					if nRefreshCount%2 == 0 then
						BattleUIlabel:SetFontColor(NameColor.DEFLIST);
					else
						BattleUIlabel:SetFontColor(NameColor.WHITE);
					end
						
			else
					BattleUIlabel:SetText(FormatTime(g_BattleEndTime,1));
					BattleUIDesclabel:SetText(tDescBattleType[g_BattleType]);
					BattleUIlabel:SetFontColor(NameColor.WHITE);
					
			end							
	
		elseif IsUIShow(NMAINSCENECHILDTAG.SyndicateBattleResultUI) then
			local CDLabel = p.GetEnterEndCDLabel();
			if g_EnterEndTime > 0 then
				local DescLabel = p.GetDescLabel();
				DescLabel:SetText("参战倒计时: ");
				CDLabel:SetText(FormatTime(g_EnterEndTime,1));	
				
				--闪光提示
				if nRefreshCount%2 == 0 then
						CDLabel:SetFontColor(NameColor.DEFLIST);
				else
						CDLabel:SetFontColor(NameColor.WHITE);
				end
						
			else
				local DescLabel = p.GetDescLabel();
				DescLabel:SetText(tDescBattleType[g_BattleType]);				
				CDLabel:SetText(FormatTime(g_BattleEndTime,1));
				CDLabel:SetFontColor(NameColor.WHITE);
				if g_BattleType == 0 or g_BattleType == 5  then
					CDLabel:SetText("--:--:--");
				end
			end				
			
			if g_EnterEndTime <= 0 and g_BattleEndTime <= 0 then
				--LogInfo("qboy UnRegisterTimer1 :"); 
				--UnRegisterTimer(p.TimerTag);
				--p.TimerTag = nil;
	
				if CDLabel ~= nil then
					CDLabel:SetText("--:--:--");	
					CDLabel:SetFontColor(NameColor.WHITE);				
				end
			end								
		end			

	end
end



function p.GetBattleEndTime()
	return g_BattleEndTime;
end

function p.GetEnterEndTime()
	return g_EnterEndTime;
end

function p.GetEnterEndCDLabel()
	local layer = p.GetParent();
	local label = RecursiveLabel(layer, {72});
	return label;		
end

function p.GetDescLabel()
	local layer = p.GetParent();
	local label = RecursiveLabel(layer, {71});
	return label;	
end


--================================XXXXXXXX====================================--



--查看战斗结果
local tBattleResultBtnBattleId = {}	
		tBattleResultBtnBattleId[ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_66] = 14;
		tBattleResultBtnBattleId[ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_65] = 13;
		tBattleResultBtnBattleId[ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_64] = 12;
		tBattleResultBtnBattleId[ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_63] = 11;
		tBattleResultBtnBattleId[ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_62] = 10;
		tBattleResultBtnBattleId[ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_61] = 9 ;
		tBattleResultBtnBattleId[ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_60] = 8 ;
		tBattleResultBtnBattleId[ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_59] = 7 ;
		tBattleResultBtnBattleId[ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_58] = 6 ;
		tBattleResultBtnBattleId[ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_57] = 5 ;
		tBattleResultBtnBattleId[ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_56] = 4 ;
		tBattleResultBtnBattleId[ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_55] = 3 ;
		tBattleResultBtnBattleId[ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_54] = 2 ;
		tBattleResultBtnBattleId[ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_53] = 1 ;
		tBattleResultBtnBattleId[ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_52] = 0 ;

	

function p.LoadUI()
    --------------------获得游戏主场景------------------------------------------
  
	-- 
    local scene = GetSMGameScene();	
	if scene == nil then
		return;
	end
    
    --------------------添加每日签到层（窗口）---------------------------------------
    local layer = createNDUILayer();
	if layer == nil then
		return false;
	end
    
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.SyndicateBattleResultUI);
	layer:SetFrameRect(RectFullScreenUILayer);
	scene:AddChild(layer);
    
    local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end
	uiLoad:Load("ArmyGroupBattle/ArmyGroupBattleSchedule.ini", layer, p.OnUIEvent, 0, 0);

	p.RefreshResult();
	
	
	
	--定时器 用来刷新stepinfo
	if p.TimerTag ~= nil then
		UnRegisterTimer(p.TimerTag);
		p.TimerTag = nil;
	end		
	p.TimerTag=RegisterTimer(p.TimerTick,0.5, "SyndicateBattleResultUI.TimerTick");
	
		
    return true;--]]
end


--==================显示战斗结果==================--
local nBattleResultInfoLayerTag = 12345
p.UserList = {};
function p.ShowBattleResult(winSynID,winSynName,loseSynID,loseSynName)
	local bglayer = p.GetParent();
	--p.UserList  id,winCount,repute,money,name,bIfwin
	
	--加载界面
    local layer = createNDUILayer();
	if layer == nil then
		return false;
	end
    
	layer:Init();
	layer:SetTag(nBattleResultInfoLayerTag);
	layer:SetFrameRect(RectFullScreenUILayer);
	bglayer:AddChildZ(layer,2);
    
    local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end
	uiLoad:Load("ArmyGroupBattle/ArmyGroupBattleReport.ini", layer, p.OnUIEventBattleResultInfoLayer, 0, 0);
	
	
	local ArmyMemberContainer = GetScrollViewContainer(layer, 41);  	
	ArmyMemberContainer:RemoveAllView();
	if ArmyMemberContainer then
			local rectview = ArmyMemberContainer:GetFrameRect();
			if nil ~= rectview then
				local nWidth	= rectview.size.w*1.2;
				local nHeight	= rectview.size.h / 6;
				ArmyMemberContainer:SetStyle(UIScrollStyle.Verical);
				ArmyMemberContainer:SetViewSize(CGSizeMake(nWidth, nHeight));
				ArmyMemberContainer:SetTopReserveDistance(rectview.size.h);
				ArmyMemberContainer:SetBottomReserveDistance(rectview.size.h);
				ArmyMemberContainer:EnableScrollBar(true);
			end
	end
	LogInfo("qboy #p.UserList:"..#p.UserList);
	--根据击杀次数排序
	if #p.UserList >1 then
		for i=1,#p.UserList-1 do
			for j = 1, #p.UserList-i do
					if p.UserList[j].winCount	 < p.UserList[j+1].winCount then
						p.UserList[j],p.UserList[j+1] = p.UserList[j+1],p.UserList[j]
					end	
			end
		end	
	end
	--先加入未入场玩家
	for i ,v in pairs(p.UserList) do
		p.AddArmyMember(ArmyMemberContainer, v);			
	end	
		
end


function p.GetResultTable()
	return p.UserList;
end

--向列表增加玩家
function p.AddArmyMember(container, cell)

	if not CheckP(container) or not cell == nil then
		LogInfo("qboy AddArmy container or cell nil");
		return;
	end

	local sArmyName = cell.name;
	if "" == sArmyName or  sArmyName == nil then
		LogInfo("qboy AddArmy sArmyName nil");
		sArmyName = "无"; --return;
	end

		
	local pool = DefaultPicPool();
	

	local view = createUIScrollView();
	if view ~= nil then
		view:Init(false);
		view:SetViewId(cell.id );
		
		
		--初始化ui
       	 local uiLoad = createNDUILoad();
       	 if nil == uiLoad then
        	 return false;
       	 end
		uiLoad:Load("ArmyGroupBattle/ArmyGroupBattleReport_L.ini", view, nil, 0, 0);
		
		local sizeview		= view:GetFrameRect().size;
		local str = "";
		local pLabelName	 = RecursiveLabel(view, {20});
		local pLabelArmy	 = RecursiveLabel(view, {21});
		local pLabelwinCount = RecursiveLabel(view, {22});
		local pLabelRepute 	 = RecursiveLabel(view, {23});
		local pLabelMoney	 = RecursiveLabel(view, {24});
		--p.UserList  id,winCount,repute,money,name,bIfwin,ArmyName
	
		pLabelName:SetText(""..sArmyName);
		pLabelArmy:SetText(""..cell.ArmyName);
		pLabelwinCount:SetText(""..cell.winCount);	
		pLabelRepute:SetText(""..cell.repute);	
		pLabelMoney:SetText(""..cell.money);	
		
		if cell.bIfwin == false then
			pLabelName:SetFontColor(ccc4(255,0,0, 255));
			pLabelArmy:SetFontColor(ccc4(255,0,0, 255));
			pLabelwinCount:SetFontColor(ccc4(255,0,0, 255));
			pLabelRepute:SetFontColor(ccc4(255,0,0, 255));
			pLabelMoney:SetFontColor(ccc4(255,0,0, 255));
		end
		

		
		--[[增加个背景按钮
		local bgBtn = createNDUIButton();
		bgBtn:Init();
		bgBtn:SetTag(cell.id );
		local sizeview = view:GetFrameRect().size;
		local width = container:GetFrameRect().size.w*0.9
		local Height = width*0.16;
		bgBtn:SetFrameRect(CGRectMake(-width*0.2, 0, width*2 , Height*2));
		view:AddChildZ(bgBtn,1);
		--bgBtn:SetLuaDelegate((p.OnCampListcontainerUIEvent));
		bgBtn:CloseFrame();
		--]]
		
		container:AddView(view);
	end
end

	
-----------------------------获取父层layer---------------------------------
function p.GetParent()

	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end
	
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.SyndicateBattleResultUI);
	if nil == layer then
		return nil;
	end
	
	return layer;
end


local tNextBattleId ={}
	tNextBattleId[0] = 8
	tNextBattleId[1] = 8
	tNextBattleId[2] = 9
	tNextBattleId[3] = 9
	tNextBattleId[4] = 10
	tNextBattleId[5] = 10
	tNextBattleId[6] = 11
	tNextBattleId[7] = 11
	tNextBattleId[8] = 12
	tNextBattleId[9] = 12
	tNextBattleId[10] = 13
	tNextBattleId[11] = 13
	tNextBattleId[12] = 14
	tNextBattleId[13] = 14



--获取参战battleid

--返回-1 没参加
--返回-2 淘汰
function p.GetBattleId(nAGID)
	--LogInfo("qboy  Enter  nAGID:"..nAGID);
	
	if nAGID == nil then
		return -1;
	end
	
	local nTmpId = -1;
	--local nResult = -1;
	for i,v in pairs(g_tResultData) do
			if nAGID == v.attSynID or  nAGID == v.defSynID then
 				if v.battleID >= nTmpId then
 					nTmpId = v.battleID;
 					--nResult = v.result;
 					
 					--没打 直接返回
 					if v.result == -1 then
 					
 						return nTmpId;
 					end
 				end
 				
 				if (v.result == 1 and v.defSynID == nAGID ) or
 				--战败
 					(v.result == 0 and v.attSynID == nAGID ) then
					
					return -2;
				end

			end
	end	
	
	
	--打赢了
	if nTmpId < 14 and nTmpId >= 0 then
		local nNextBattleId = tNextBattleId[nTmpId];
		return nNextBattleId;
	end
	
	return nTmpId;

end	



local tBattleIdToBattleType = {}
	tBattleIdToBattleType[0] = 1
	tBattleIdToBattleType[1] = 1
	tBattleIdToBattleType[2] = 1
	tBattleIdToBattleType[3] = 1
	tBattleIdToBattleType[4] = 1
	tBattleIdToBattleType[5] = 1
	tBattleIdToBattleType[6] = 1
	tBattleIdToBattleType[7] = 1
	tBattleIdToBattleType[8] = 2
	tBattleIdToBattleType[9] = 2
	tBattleIdToBattleType[10] = 2
	tBattleIdToBattleType[11] = 2
	tBattleIdToBattleType[12] = 3
	tBattleIdToBattleType[13] = 3
	tBattleIdToBattleType[14] = 4



-----------------------------背景层事件处理---------------------------------
function p.OnUIEvent(uiNode, uiEventType, param)

    local tag = uiNode:GetTag();
    LogInfo("qboy p.OnUIEvent hit tag = %d", tag);
    --
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
        --关闭按钮
        if ID_ARMYGROUPBATTLESCHEDULE_CTRL_BUTTON_67 == tag then    
            
            --测试用
           -- MsgSyndicateBattle.Leave();
			MsgSyndicateBattle.CloseUI();
			
			CloseUI(NMAINSCENECHILDTAG.SyndicateBattleResultUI);		
			return true;
		
		elseif  tag >= 52 and tag <= 66 then
		--查看结果按钮
			local battleid = tBattleResultBtnBattleId[tag];
			
			--有结果才发送 无则返回
			for i,v in pairs(g_tResultData) do
				if v.battleID == battleid and  ( v.result == 1  or v.result == 0 ) then
					MsgSyndicateBattle.GetBattleDetail(battleid);
				end
			end
			
			return true;
			
		elseif tag == 70 then
		--参战
			--军团战还未开始
			if g_BattleType == 5 then
				CommonDlgNew.ShowTipDlg("军团战尚未开始！");
				return true;
			end
			
			--军团战已结束
			if g_BattleType == 0 then
				CommonDlgNew.ShowTipDlg("本次军团战已经结束！");
				return true;
			end			
		
			
			--无军团 军团未参加返回
			local nUserID		= GetPlayerId();
			local nAGID			= MsgArmyGroup.GetUserArmyGroupID( nUserID );
			local nbattleid = p.GetBattleId(nAGID);
			
			
			if nbattleid == -1 then
				CommonDlgNew.ShowTipDlg("抱歉！您未参加这次活动！");
				 LogInfo("qboy 无军团 或 军团未参加");
			elseif nbattleid == -2 then	
				 LogInfo("qboy 已淘汰");
				 CommonDlgNew.ShowTipDlg("您的军团已战败！");
			elseif g_EnterEndTime <= 0 then
				CommonDlgNew.ShowTipDlg("本轮准备时间已过，无法参加战斗。");
			else
				--轮空了
				if tBattleIdToBattleType[nbattleid] ~= g_BattleType then
					CommonDlgNew.ShowTipDlg("您的军团当前轮空。");
					return true;
				end
			
				LogInfo("qboy 参加战斗 id:"..nbattleid);
				MsgSyndicateBattle.Enter(nbattleid);
			end
		end	
    end
    
	return true;
end

-----------------------------战斗结果层事件处理---------------------------------
function p.OnUIEventBattleResultInfoLayer(uiNode, uiEventType, param)

    local tag = uiNode:GetTag();
    LogInfo("qboy p.OnUIEventBattleResultInfoLayer hit tag = %d", tag);
    --
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
        --关闭按钮      
        if 533 == tag then
        	--MsgSyndicateBattle.CloseUI();
        	
        	local layer = p.GetParent();
            layer:RemoveChildByTag(nBattleResultInfoLayerTag, true);		
			
			
			return true;
        end     
    end
	return true;
end




