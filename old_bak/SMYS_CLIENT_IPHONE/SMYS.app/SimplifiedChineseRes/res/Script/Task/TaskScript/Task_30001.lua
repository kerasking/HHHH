
local _G = _G;
setfenv(1, TASK);

---精英任务1（羽化门）---

function TASK_FUNCTION_30001(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("想不到掌门这么早就给你开放精英任务了，不过我要你降服的可都是修行甚高之辈，虽然对修道很有益处，却也危险重重。敢与不敢就看你有没这个胆识了。");
		AddOpt("弟子定不后退半步。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("你真是厉害得出乎我的意料啊！ ");
		AddOpt("长老过奖了。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_30001(nTaskId, nAction)
	local ret = false;
	if 1 == nAction then
		--未接
		ret = TASK_FUNCTION_COMMON(nTaskId);
	elseif 2 == nAction then
		--任务已被接受
		ret = TASK_FUNCTION_COMMON(nTaskId);
	end
	
	return ret;
end

---精英任务2（羽化门）---

function TASK_FUNCTION_30002(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("水蛊魔王修炼出了邪蛊摧意术，杀败众多修道高手，你去击杀了它吧，也可以为我门派增加声誉。");
		AddOpt("弟子正有意去领教下它的威力。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("哈哈哈，你又为门派立功啦。 ");
		AddOpt("长老过奖了。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_30002(nTaskId, nAction)
	local ret = false;
	if 1 == nAction then
		--未接
		ret = TASK_FUNCTION_COMMON(nTaskId);
	elseif 2 == nAction then
		--任务已被接受
		ret = TASK_FUNCTION_COMMON(nTaskId);
	end
	
	return ret;
end

---精英任务3（羽化门）---

function TASK_FUNCTION_30003(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("大威德魔王竟敢向本派搦战，简直是不知死活。你就去灭了此妖，振我门威！");
		AddOpt("弟子定不负众望。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("哼哼，看看这下还有何方妖孽敢猖狂。 ");
		AddOpt("弟子定叫其有来无回。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_30003(nTaskId, nAction)
	local ret = false;
	if 1 == nAction then
		--未接
		ret = TASK_FUNCTION_COMMON(nTaskId);
	elseif 2 == nAction then
		--任务已被接受
		ret = TASK_FUNCTION_COMMON(nTaskId);
	end
	
	return ret;
end


---精英任务4（羽化门）---

function TASK_FUNCTION_30004(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("血夜之王果然强悍，竟然打败了门派中多个真传弟子，真是有损本派的威名啊！不知你可否战胜它？");
		AddOpt("弟子定将它斩杀。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("果然是我门派中的得意弟子啊。 ");
		AddOpt("长老过奖了。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_30004(nTaskId, nAction)
	local ret = false;
	if 1 == nAction then
		--未接
		ret = TASK_FUNCTION_COMMON(nTaskId);
	elseif 2 == nAction then
		--任务已被接受
		ret = TASK_FUNCTION_COMMON(nTaskId);
	end
	
	return ret;
end

---精英任务5---

function TASK_FUNCTION_30005(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("听说过‘星月神话’么？好厉害啊，真是太可怕了，太可怕了！");
		AddOpt("我倒想见识见识！", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("你更厉害，看来‘星月神话’只能成为传说了！ ");
		AddOpt("姑娘谬赞了。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_30005(nTaskId, nAction)
	local ret = false;
	if 1 == nAction then
		--未接
		ret = TASK_FUNCTION_COMMON(nTaskId);
	elseif 2 == nAction then
		--任务已被接受
		ret = TASK_FUNCTION_COMMON(nTaskId);
	end
	
	return ret;
end

---精英任务6---

function TASK_FUNCTION_30006(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("邪月王子扬言要成为第二个‘星月神话’，看他的实力倒不是不可能啊？");
		AddOpt("哼哼，那我就让他成为不可能！", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("你又破除了一个神话，佩服佩服！ ");
		AddOpt("道友谬赞了。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_30006(nTaskId, nAction)
	local ret = false;
	if 1 == nAction then
		--未接
		ret = TASK_FUNCTION_COMMON(nTaskId);
	elseif 2 == nAction then
		--任务已被接受
		ret = TASK_FUNCTION_COMMON(nTaskId);
	end
	
	return ret;
end

---精英任务7---

function TASK_FUNCTION_30007(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("‘星辰陨落，独月难支’，现在是消灭刺月的最佳时机了，你可要好好把握这个机会啊！");
		AddOpt("我自然不会错过这等好时机。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("时机把握得很好嘛！ ");
		AddOpt("必当乘胜追击。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_30007(nTaskId, nAction)
	local ret = false;
	if 1 == nAction then
		--未接
		ret = TASK_FUNCTION_COMMON(nTaskId);
	elseif 2 == nAction then
		--任务已被接受
		ret = TASK_FUNCTION_COMMON(nTaskId);
	end
	
	return ret;
end

---精英任务8---

function TASK_FUNCTION_30008(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("那夺魂血王蜂妖法非同小可，一定要趁现在除掉它，不然以后就更难对付了！");
		AddOpt("好，我现在就去！", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("哈哈，除掉了就好，除掉了就好！ ");
		AddOpt("此乃在下本分。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_30008(nTaskId, nAction)
	local ret = false;
	if 1 == nAction then
		--未接
		ret = TASK_FUNCTION_COMMON(nTaskId);
	elseif 2 == nAction then
		--任务已被接受
		ret = TASK_FUNCTION_COMMON(nTaskId);
	end
	
	return ret;
end

---精英任务9---

function TASK_FUNCTION_30009(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("连魔皇都出现了，这蓝月城真是吸引力十足啊！只是这么多高手到这来是为了什么呢？");
		AddOpt("我去打探一番便知！", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("你怎么没问完就把它给绞杀了呢！ ");
		AddOpt("此等魔物怎能不除？", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_30009(nTaskId, nAction)
	local ret = false;
	if 1 == nAction then
		--未接
		ret = TASK_FUNCTION_COMMON(nTaskId);
	elseif 2 == nAction then
		--任务已被接受
		ret = TASK_FUNCTION_COMMON(nTaskId);
	end
	
	return ret;
end

---精英任务10---

function TASK_FUNCTION_30010(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("水凌圣母是水凌派的开宗鼻祖，如今她转世为烟水一，想必那女子身上必定蕴含着丰富的水灵之气！");
		AddOpt("刚好我急需大量水灵之气的滋补，真是送上门来的！", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("看来真是给你送上门来的！ ");
		AddOpt("哈哈，定时如此！", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_30010(nTaskId, nAction)
	local ret = false;
	if 1 == nAction then
		--未接
		ret = TASK_FUNCTION_COMMON(nTaskId);
	elseif 2 == nAction then
		--任务已被接受
		ret = TASK_FUNCTION_COMMON(nTaskId);
	end
	
	return ret;
end

---精英任务11---

function TASK_FUNCTION_30011(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("出大事了，出大事了！我看见一条火龙凌空飞起，然后直钻地底，怕是很厉害的妖物所在啊！");
		AddOpt("有这等事？我马上去查看下！", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("原来是龙道人啊！ ");
		AddOpt("也不过如此而已。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_30011(nTaskId, nAction)
	local ret = false;
	if 1 == nAction then
		--未接
		ret = TASK_FUNCTION_COMMON(nTaskId);
	elseif 2 == nAction then
		--任务已被接受
		ret = TASK_FUNCTION_COMMON(nTaskId);
	end
	
	return ret;
end

---精英任务12---

function TASK_FUNCTION_30012(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("我看见有一道人的功法诡异，所过之处寸草不生，想必是他强行吸走了土木灵气，这可不是正道修行之法啊！");
		AddOpt("哼，我最厌恶这等假道修行之人了！", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("可惜这木道人选错了修行之法！ ");
		AddOpt("不可坐视不理。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_30012(nTaskId, nAction)
	local ret = false;
	if 1 == nAction then
		--未接
		ret = TASK_FUNCTION_COMMON(nTaskId);
	elseif 2 == nAction then
		--任务已被接受
		ret = TASK_FUNCTION_COMMON(nTaskId);
	end
	
	return ret;
end

---精英任务13---

function TASK_FUNCTION_30013(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("那黄金海蚺是蟒中巨无霸，若再不铲除它，怕是要修炼成海龙了，到时的祸害可就大了！");
		AddOpt("放心，我不会让它修成龙身的！", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("还好你及时剿杀了此物，不然等它修出龙身还真难对付。 ");
		AddOpt("此言有理。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_30013(nTaskId, nAction)
	local ret = false;
	if 1 == nAction then
		--未接
		ret = TASK_FUNCTION_COMMON(nTaskId);
	elseif 2 == nAction then
		--任务已被接受
		ret = TASK_FUNCTION_COMMON(nTaskId);
	end
	
	return ret;
end

---精英任务14---

function TASK_FUNCTION_30014(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("黑水王蛇比黄金海蚺更加厉害，要是修炼得道就是入云龙了，到时只怕它为所欲为起来没几个人能抵挡！");
		AddOpt("看来得趁早降服它！", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("降服了就好，也免得日后后患无穷！ ");
		AddOpt("必当如此。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_30014(nTaskId, nAction)
	local ret = false;
	if 1 == nAction then
		--未接
		ret = TASK_FUNCTION_COMMON(nTaskId);
	elseif 2 == nAction then
		--任务已被接受
		ret = TASK_FUNCTION_COMMON(nTaskId);
	end
	
	return ret;
end

---精英任务15---

function TASK_FUNCTION_30015(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("那阎乃是神蛇之王修炼而成，快要蜕变为天龙了！要是他发起灾难来，只怕半个凡间都要毁灭！");
		AddOpt("放心，我就是拼了性命也不能让它蜕变为天龙！", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("你降服了此龙，相当于拯救了半个玄黄大世界啊！ ");
		AddOpt("此乃在下本分。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_30015(nTaskId, nAction)
	local ret = false;
	if 1 == nAction then
		--未接
		ret = TASK_FUNCTION_COMMON(nTaskId);
	elseif 2 == nAction then
		--任务已被接受
		ret = TASK_FUNCTION_COMMON(nTaskId);
	end
	
	return ret;
end

---精英任务16---

function TASK_FUNCTION_30016(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("那绝命岛主是这里海妖组织中的一个头目，铲除了它就相当于瓦解了这个组织的一部分。");
		AddOpt("对啊，我怎么没想到呢！这可比一只一只地剿杀海妖快捷多了，我这就去办！", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("太好了，海妖们明显没那么张狂了！ ");
		AddOpt("定当有一杀一！", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_30016(nTaskId, nAction)
	local ret = false;
	if 1 == nAction then
		--未接
		ret = TASK_FUNCTION_COMMON(nTaskId);
	elseif 2 == nAction then
		--任务已被接受
		ret = TASK_FUNCTION_COMMON(nTaskId);
	end
	
	return ret;
end

---精英任务17---

function TASK_FUNCTION_30017(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("想必是你杀了它太多手下，不然海妖统帅也不会亲自出场！");
		AddOpt("我杀它手下就是为了引它出来，今天我要将它一举歼灭！", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("太难以置信了，竟然海妖统帅都不是你的对手！ ");
		AddOpt("老板过奖了。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_30017(nTaskId, nAction)
	local ret = false;
	if 1 == nAction then
		--未接
		ret = TASK_FUNCTION_COMMON(nTaskId);
	elseif 2 == nAction then
		--任务已被接受
		ret = TASK_FUNCTION_COMMON(nTaskId);
	end
	
	return ret;
end

---精英任务18---

function TASK_FUNCTION_30018(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("‘海皇出洞，万劫不复’，好多门派高手都死在了他手上！你还是赶紧跑路吧，不然来不及了！");
		AddOpt("我不走！它来得正好，我要与他决一死战！", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("天哪，你竟然胜过了远古海皇，这海皇一死，海妖一族也就瓦解了。 ");
		AddOpt("今日便让其消失于世。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_30018(nTaskId, nAction)
	local ret = false;
	if 1 == nAction then
		--未接
		ret = TASK_FUNCTION_COMMON(nTaskId);
	elseif 2 == nAction then
		--任务已被接受
		ret = TASK_FUNCTION_COMMON(nTaskId);
	end
	
	return ret;
end

---精英任务19---

function TASK_FUNCTION_30019(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("这万归宗弟子万连山竟然敢叫嚣无人能敌，分明就是向众门派挑衅，你出战吧！");
		AddOpt("遵命！", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("做得好，看他还敢不敢叫嚣！ ");
		AddOpt("必当严惩。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_30019(nTaskId, nAction)
	local ret = false;
	if 1 == nAction then
		--未接
		ret = TASK_FUNCTION_COMMON(nTaskId);
	elseif 2 == nAction then
		--任务已被接受
		ret = TASK_FUNCTION_COMMON(nTaskId);
	end
	
	return ret;
end

---精英任务20---

function TASK_FUNCTION_30020(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("万归宗如此嚣张，肯定与他们宗主脱不了干系！这可真是修道界的耻辱啊！");
		AddOpt("那我就去抹掉这个耻辱！", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("这下修道界干净些了！ ");
		AddOpt("此乃在下本分。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_30020(nTaskId, nAction)
	local ret = false;
	if 1 == nAction then
		--未接
		ret = TASK_FUNCTION_COMMON(nTaskId);
	elseif 2 == nAction then
		--任务已被接受
		ret = TASK_FUNCTION_COMMON(nTaskId);
	end
	
	return ret;
end

---精英任务21---

function TASK_FUNCTION_30021(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("那神仙茶树可是被贬入凡间的大妖啊，若不将它制服，只怕人间又有大劫了！");
		AddOpt("竟然这么严重！我一定竭尽所能将它制服！", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("将它制服啦？那就好，那就好！ ");
		AddOpt("此乃在下本分。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_30021(nTaskId, nAction)
	local ret = false;
	if 1 == nAction then
		--未接
		ret = TASK_FUNCTION_COMMON(nTaskId);
	elseif 2 == nAction then
		--任务已被接受
		ret = TASK_FUNCTION_COMMON(nTaskId);
	end
	
	return ret;
end

---精英任务1（黄泉宗）---

function TASK_FUNCTION_31001(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("想不到掌门这么早就给你开放精英任务了，不过我要你降服的可都是修行甚高之辈，虽然对修道很有益处，却也危险重重。敢与不敢就看你有没这个胆识了。");
		AddOpt("弟子定不后退半步。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("你真是厉害得出乎我的意料啊！ ");
		AddOpt("长老过奖了。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_31001(nTaskId, nAction)
	local ret = false;
	if 1 == nAction then
		--未接
		ret = TASK_FUNCTION_COMMON(nTaskId);
	elseif 2 == nAction then
		--任务已被接受
		ret = TASK_FUNCTION_COMMON(nTaskId);
	end
	
	return ret;
end

---精英任务2（黄泉宗）---

function TASK_FUNCTION_31002(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("水蛊魔王修炼出了邪蛊摧意术，杀败众多修道高手，你去击杀了它吧，也可以为我门派增加声誉。");
		AddOpt("弟子正有意去领教下它的威力。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("哈哈哈，你又为门派立功啦。 ");
		AddOpt("长老过奖了。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_31002(nTaskId, nAction)
	local ret = false;
	if 1 == nAction then
		--未接
		ret = TASK_FUNCTION_COMMON(nTaskId);
	elseif 2 == nAction then
		--任务已被接受
		ret = TASK_FUNCTION_COMMON(nTaskId);
	end
	
	return ret;
end

---精英任务3（黄泉宗）---

function TASK_FUNCTION_31003(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("大威德魔王竟敢向本派搦战，简直是不知死活。你就去灭了此妖，振我门威！");
		AddOpt("弟子定不负众望。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("哼哼，看看这下还有何方妖孽敢猖狂。 ");
		AddOpt("弟子定叫其有来无回。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_31003(nTaskId, nAction)
	local ret = false;
	if 1 == nAction then
		--未接
		ret = TASK_FUNCTION_COMMON(nTaskId);
	elseif 2 == nAction then
		--任务已被接受
		ret = TASK_FUNCTION_COMMON(nTaskId);
	end
	
	return ret;
end


---精英任务4（黄泉宗）---

function TASK_FUNCTION_31004(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("血夜之王果然强悍，竟然打败了门派中多个真传弟子，真是有损本派的威名啊！不知你可否战胜它？");
		AddOpt("弟子定将它斩杀。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("果然是我门派中的得意弟子啊。 ");
		AddOpt("长老过奖了。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_31004(nTaskId, nAction)
	local ret = false;
	if 1 == nAction then
		--未接
		ret = TASK_FUNCTION_COMMON(nTaskId);
	elseif 2 == nAction then
		--任务已被接受
		ret = TASK_FUNCTION_COMMON(nTaskId);
	end
	
	return ret;
end
