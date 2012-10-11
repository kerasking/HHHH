
local _G = _G;
setfenv(1, TASK);

--该函数若处理了需要返回true,不处理返回fale,就走默认的接任务流程
---任务1---
function TASK_FUNCTION_10001(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("谢谢你救了我，我一定要我爹爹好好谢谢你！");
		AddOpt("馨儿客气了，我送你回去吧！", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("真是英雄出少年啊，多谢你救了我女儿！");
		AddOpt("哪里哪里，路见不平拔刀相助而已！", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10001(nTaskId, nAction)
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

---任务2---

function TASK_FUNCTION_10002(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("小女突然精神恍惚起来，怕是受惊吓过度造成的！要是有安魂草就好了，你可否再帮老夫采些安魂草来解救小女？");
		AddOpt("这个当然，救人要紧，我马上去。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("有了这安魂草，小女有救啦！ ");
		AddOpt("真是太好了", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10002(nTaskId, nAction)
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


---任务3---

function TASK_FUNCTION_10003(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("最近不知为何，村子附近常有蛇妖出没，小女此次差点被他们所害，以后村民们可就危险了。");
		AddOpt("村长不必多虑，我这就去铲除它们！", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("真是好身手，你为村子除了一大害，老夫实在感激不尽。");
		AddOpt("太客气了。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10003(nTaskId, nAction)
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

---任务4---

function TASK_FUNCTION_10004(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("你可否去找黄武师一趟？他托我找些体格健壮的青年，我看你挺合适的。");
		AddOpt("哦？那我这就动身！", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("是老村长让你来的么？就是你为村子解除了妖患么？");
		AddOpt("正是。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10004(nTaskId, nAction)
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

---任务5---

function TASK_FUNCTION_10005(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("你有所不知，前日我从村外回来，看见一只黄金巨蟒，彪悍无比，怕是成了妖了。");
		AddOpt("竟有这种事！那不是又要祸害村民了吗？", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("你真的把那黄金巨蟒杀啦？呵呵呵，不错不错，真是少年英才啊！");
		AddOpt("您过奖了！", 3);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10005(nTaskId, nAction)
	local ret = false;
	if 1 == nAction then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("正是啊，所以请你来是希望你能去消灭这祸害，保村子一方平安。");
		AddOpt("那好，我这就去灭了它！", 2);
		return true;
	elseif 2 == nAction then
		--未接
		ret = TASK_FUNCTION_COMMON(nTaskId);
	elseif 3 == nAction then
		--任务已被接受
		ret = TASK_FUNCTION_COMMON(nTaskId);
	end
	
	return ret;
end

---任务6---

function TASK_FUNCTION_10006(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("想不到你如此英勇，倘若得到高人指点，必能修为大进。你不妨去拜访下武道人，将这封信交给他，看他能否给你指点一二？");
		AddOpt("武道人？素闻大名，我这就去！", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("来者何人，打搅了我修道的清静？");
		AddOpt("晚辈为道人带来黄武师的书信一封。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10006(nTaskId, nAction)
	local ret = false;
	if 1 == nAction then
		--未接
		ret = TASK_FUNCTION_COMMON(nTaskId);
	elseif 2 == nAction then
		--任务已被接受
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("哦？让我看看……嗯，是黄老弟的笔迹！");
		AddOpt("如您所见。", 3);
		return true;
	elseif 3 == nAction then
		--任务已被接受
		ret = TASK_FUNCTION_COMMON(nTaskId);
	end
	
	return ret;
end

---任务7---

function TASK_FUNCTION_10007(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("想不到我黄老弟如此看好你，要我指点你一二……那我先考验你一下吧，不知你修为如何，能否夺来一只熊掌？");
		AddOpt("请前辈稍等片刻，我这就去。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("那幼年熊妖如此凶残，你竟然轻松就到手了，看来是有几分天赋！");
		AddOpt("您过奖了。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10007(nTaskId, nAction)
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

---任务8---

function TASK_FUNCTION_10008(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("你根骨奇佳，颇有修道的天资，想必是得过大际遇！这样吧，你若能成功斩杀成年熊妖，我便授你一项绝技。");
		AddOpt("若能得到前辈指点，晚辈感激不尽，我这就去击杀此怪。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("很好，果然没看错你。现在我就授你一门技能，你可听好了，我只传授一次。");
		AddOpt("多谢前辈！", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10008(nTaskId, nAction)
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

---任务9---

function TASK_FUNCTION_10009(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("不知你的技能学得如何了？修道之事当持之以恒方有成果！现在可否替我把这颗丹药交给云婆婆？她正急着用呢！");
		AddOpt("婆婆客气了。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("这是武道人托你送来的丹药么？太好了，我正愁缺少丹药呢！多谢了！");
		AddOpt("多谢前辈！", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10009(nTaskId, nAction)
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

---任务10---

function TASK_FUNCTION_10010(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("唉，我那鹤仙子怎么还没回来，我让她去采千年灵芝，这么久未归，会不会是碰到厚背熊王了，那可就危险了？你可否帮婆婆去看看？");
		AddOpt("婆婆放心，我这就前去。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("鹤仙子终于回来了，真是担心死婆婆我了！还好有你及时搭救，婆婆我万分感谢。");
		AddOpt("婆婆言重了。鹤仙子受了伤，还是为鹤仙子疗伤要紧。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10010(nTaskId, nAction)
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

---任务11---

function TASK_FUNCTION_10011(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("鹤仙子已经伤愈得差不多了，当时多亏有你及时搭救！");
		AddOpt("哪里哪里，举手之劳而已。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("以后有伙伴时记得来客栈招募啊！");
		AddOpt("一定。", 4);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10011(nTaskId, nAction)
	local ret = false;
	if 1 == nAction then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("看你身手非凡，日后必成大器。若不嫌弃，我想让鹤仙子追随于你，增强她的修为，不知你愿意与否？");
		AddOpt("承蒙婆婆如此看重，来日必不负婆婆。", 2);	
		return true;
	elseif 2 == nAction then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("那你快去客栈招募她吧！");
		AddOpt("好的。", 3);	
		return true;
	elseif 3 == nAction then
	--未接
	ret = TASK_FUNCTION_COMMON(nTaskId);
	elseif 4 == nAction then
		--任务已被接受
	ret = TASK_FUNCTION_COMMON(nTaskId);
	end
	
	return ret;
end

---任务12---

function TASK_FUNCTION_10012(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("鹤仙子能跟着你修行，想必日后定有所成。也算了了我一桩心愿。对了，刚才老村长来过，似乎有紧急的事情找你，赶紧去看看吧！");
		AddOpt("莫非又出了什么妖魔？那我这就过去，晚辈告辞。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("你来得正好，我正四处找你呢，有要事与你商量！");
		AddOpt("慢说莫急。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10012(nTaskId, nAction)
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

---任务13---

function TASK_FUNCTION_10013(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("这几日，伏虎林中出现了凶狠的狼群，村民的牲畜多被所伤。所以我想拜托你再次为民除害，不知你可否愿意？");
		AddOpt("此事义不容辞，老村长放心，我定将它剿杀！", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("狼群都剿灭啦？你果然神勇啊，村子总算安全了！");
		AddOpt("此乃分内之事", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10013(nTaskId, nAction)
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

---任务14---

function TASK_FUNCTION_10014(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("村中能出你这样的神勇之人实在是村民之福。你可以去找武道人了，他曾嘱托过谁能剿杀狼群就让谁去找他。");
		AddOpt("既然如此，那我先告辞了。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("是你剿灭了狼群么？嗯，看来不出我所料……");
		AddOpt("小事一桩。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10014(nTaskId, nAction)
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

---任务15---

function TASK_FUNCTION_10015(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("年纪轻轻能有如此修为，确实是有几分奇缘，日后说不定能有所成。让我看看你应变能力如何，你能否从狡诈的银狼手中夺得银光舍利？");
		AddOpt("晚辈愿意前往一试。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("你既然能拿到银光舍利，证明你的应变能力不错……");
		AddOpt("前辈过奖了。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10015(nTaskId, nAction)
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

---任务16---

function TASK_FUNCTION_10016(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("你确实很有修道的天资，最后就要看看你胆识如何了！黄金狼王凶残无比，多少修道弟子都死在它魔爪之下，你敢去剿杀吗？");
		AddOpt("有何不敢，前辈稍等，我去去就来。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("竟然连黄金狼王都不是你对手……看来上天冥冥之中安排的那个人就是你了……");
		AddOpt("前辈过奖了。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10016(nTaskId, nAction)
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

---任务17---

function TASK_FUNCTION_10017(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("早在二十年前，我卜卦出这小渔村将出一位具有永生仙缘之人，你能斩杀如此多妖魔，或许那个人就是你。你拿着我的这张玉符到龙渊省，找我师弟潼道人，他会给你些指引，至于将来能不能修得永生就看你自己的造化啦……");
		AddOpt("感谢前辈引荐，晚辈必全力以赴。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("这是师兄的玉符啊！他隐居山林二十年，说是要等一位有修道奇缘的人出现，莫不成就是你？");
		AddOpt("正是。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10017(nTaskId, nAction)
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

---任务18---

function TASK_FUNCTION_10018(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("嗯，看你筋骨奇佳，是块可造之才，也难怪师兄如此看好你。我就把你引荐给白海禅大师吧，他一直想收个弟子，希望你好好跟他深造。");
		AddOpt("多谢前辈。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("看你气质不凡，定有过人之处，不然潼道人也不会推荐给我。不错不错，甚合我意，我就收你为徒了。");
		AddOpt("师父在上，受徒儿一拜。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10018(nTaskId, nAction)
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

---任务19---

function TASK_FUNCTION_10019(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("先让为师看看你的资质如何。龙渊城外最近出了个枯木树妖，专门吸食人类魂魄，甚是凶猛。你若是能将它斩杀，我就交你一门奇术。");
		AddOpt("谨听师父吩咐，徒儿这就前往。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("嗯，果然没看错人，做得很好，为师也不食言，这就教你一门奇术，你可看好了……");
		AddOpt("徒儿谨遵师父教诲", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10019(nTaskId, nAction)
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

---任务20---

function TASK_FUNCTION_10020(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("为师教你的技法学得如何了？听闻城外树妖横行，你去铲除了它们吧，就当给你练练手了。");
		AddOpt("是，师父。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("这么快就回来啦？看来你学得很快啊！");
		AddOpt("师父过奖了", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10020(nTaskId, nAction)
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

---任务21---

function TASK_FUNCTION_10021(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("看你日日精进，为师甚感欣慰。以你现在的能力，可以去会会红怡郡主了，要是能将它抓来为你所用，对你日后修行更是大有裨益。给你一张捆仙符，说不定你能用得着。");
		AddOpt("是，师父，徒儿立马动身。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("哈哈，你果然把红怡郡主给捆来了，不错，不错。看来你的肉身已经修行到位，是时候传授你打坐之法了。");
		AddOpt("多谢师父的传授。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10021(nTaskId, nAction)
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

---任务22---

function TASK_FUNCTION_10022(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("我已为红怡郡主驱除了魔性，现已全心归顺我门下。就让她跟随你修行吧，可以做你的左膀右臂，让你修炼得更快。");
		AddOpt("多谢师父。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("有了红怡郡主的加入，你真是如虎添翼啊！");
		AddOpt("真是太好了。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10022(nTaskId, nAction)
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

---任务23---

function TASK_FUNCTION_10023(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("有了助手，你的修为又精进了不少啊。替我把这件法衣送给潼道人吧，算是对他当日将你推荐于我的感谢。");
		AddOpt("是，师父。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("这可是件上等法衣啊，白师傅真是太过客气了。你能跟着白师傅修行也是你注定的造化，我不过是顺手推舟罢了。");
		AddOpt("滴水之恩，他日定当涌泉相报。", 2);	
		return true;
	end
	
	--local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10023(nTaskId, nAction)
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

---任务24---

function TASK_FUNCTION_10024(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("看你精气磅礴，血色汹涌，想必跟白师傅习了不少道术。刚好听说剧毒蜂妖修行成精，怕是又要祸害人间了，你可否前往降服呢？");
		AddOpt("这个当然，我定不让妖孽祸害人间。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
		return false;
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("那蜂妖怕是有近千年的修为了吧，你竟杀得如此轻松，果然是奇才！");
		AddOpt("前辈过奖了。", 2);	
		return true;
	end
	
	--local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10024(nTaskId, nAction)
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

---任务25---

function TASK_FUNCTION_10025(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("这几日我正在炼制回魂丹，用以救治被蜂毒迷魂的百姓，只可惜还差蜂元精魄作为药引。没有这原料，我的丹药难以大成啊！这可如何是好……");
		AddOpt("前辈不必担心，这事交给我好了。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("蜂元精魄到手了啦？太好了，丹药成矣！");
		AddOpt("可喜可贺。", 2);	
		return true;
	end
	
	--local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10025(nTaskId, nAction)
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

---任务26---

function TASK_FUNCTION_10026(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("百姓的毒都已经解了，多亏你及时采到了药引。不过那玄蜂妖母还未铲除，只怕还会继续用蜂毒迷魂世人，终究是个隐患啊……");
		AddOpt("那我去把它铲除好了。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("那祸害铲除啦？甚好甚好！");
		AddOpt("为民除害乃是我等本分。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10026(nTaskId, nAction)
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

---任务27---

function TASK_FUNCTION_10027(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("实在是感激你这几日为老夫和龙渊百姓所做的事情，请将这巨神丹交于你师父，以表我答谢之情。");
		AddOpt("那我先代家师谢过前辈了，告辞。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("这巨神丹可聚气养元，对我突破元气极限大有裨益，潼道人真是太客气了。");
		AddOpt("恭喜师父。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10027(nTaskId, nAction)
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

---任务28---

function TASK_FUNCTION_10028(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("现在我将五行修身之法传授于你，这是一门上乘神通，你要用心习练！不过修炼此术首先要储备充足的五灵之气，刚好冥煞狂狼的五灵之气充足，你若炼化此妖应该对你的修行大有帮助。");
		AddOpt("那徒儿这就去炼化此妖。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("嗯，你一下就精进了不少啊！");
		AddOpt("略有小成而已。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10028(nTaskId, nAction)
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

---任务29---

function TASK_FUNCTION_10029(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("你的五行之术炼入几层了？也该让为师检验你一下了。暴戾狼妖是这一带最为凶残的妖物，看你能否以五行之术将它降服？");
		AddOpt("徒儿必定手刃此怪。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("呵呵，做得不错，不枉费我一番栽培！");
		AddOpt("徒儿定当不负师恩。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10029(nTaskId, nAction)
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

---任务30---

function TASK_FUNCTION_10030(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("你可知龙女之事？");
		AddOpt("徒儿不知，望师父明示。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("事情原来是这样，好吧，我就为她驱除妖法，让她跟随你修炼道法吧。");
		AddOpt("谢师父。", 3);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10030(nTaskId, nAction)
	local ret = false;
	if 1 == nAction then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("最近出了一个龙女，名叫龙萱，乃龙族后裔。话说她出身正道名门，理应心性纯正，却不知为何近来到处兴风作浪，你不妨去看看。");
		AddOpt("是，师父。", 2);
		return true;
	elseif 2 == nAction then
		--未接
		ret = TASK_FUNCTION_COMMON(nTaskId);
	elseif 3 == nAction then
		--任务已被接受
		ret = TASK_FUNCTION_COMMON(nTaskId);
	end
	
	return ret;
end

---任务31---

function TASK_FUNCTION_10031(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("你的修为速度真可谓神速，这龙渊省已经难以增长你的修为了，择日我就带你进大离皇宫吧。现在你去找下潼道人，看他是否有事交代？");
		AddOpt("是，师父。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("听说你师父要带你进大离皇宫修炼？嗯，以你的修为潜力也该如此。");
		AddOpt("此行必定有所收获。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10031(nTaskId, nAction)
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

---任务32---

function TASK_FUNCTION_10032(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("我这有锦盒一个，麻烦你进入大离皇宫后转交给你师父，他自会发落。");
		AddOpt("晚辈这就前往。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("潼道人要你把这盒子交给我？让我看看里面有什么？");
		AddOpt("请师父查看。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10032(nTaskId, nAction)
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


---任务33---

function TASK_FUNCTION_10033(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("这颗霹雳剑珠是潼道人托我转交给九鼎仙尊的，你代我跑一趟吧，且替我打听下万古书的下落。");
		AddOpt("徒儿这就去。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("霹雳剑珠？真是太好了，终于送来了。");
		AddOpt("请收好。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10033(nTaskId, nAction)
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

---任务34---

function TASK_FUNCTION_10034(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("这颗霹雳剑珠可是价值连城的宝物啊，多谢你为我送来。");
		AddOpt("前辈言重了，我只是受人之托而已。对了，晚辈想替家师询问下有关万古书的下落，不知前辈知道与否？", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("你要打听‘万古书’的下落？哈哈，最近可是很多人来问啊。");
		AddOpt("还望相告。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10034(nTaskId, nAction)
	local ret = false;
	if 1 == nAction then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("万古书乃是修炼永生之法的奇书，多少神魔高手为此争夺不休。只道是失踪良久，想不到又重现人间了，不过具体情况我却不知？你可以去询问下云锦，她的消息十分灵通。");
		AddOpt("多谢前辈提醒。", 2);
		return true;
	elseif 2 == nAction then
		--未接
		ret = TASK_FUNCTION_COMMON(nTaskId);
	elseif 3 == nAction then
		--任务已被接受
		ret = TASK_FUNCTION_COMMON(nTaskId);
	end
	
	return ret;
end

---任务35---

function TASK_FUNCTION_10035(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("‘万古书’的秘密我可不是谁都告诉，但看在白师傅的面上，告诉你也无妨。我听说‘万古书’在大离皇宫出现过，其他就不知道了。");
		AddOpt("这消息很重要，多谢了，我这就去告诉师父。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("原来如此，‘万古书’果然流落到了大离皇宫，看来我们来得正是时候！");
		AddOpt("果然不虚此行。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10035(nTaskId, nAction)
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

---任务36---

function TASK_FUNCTION_10036(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("那‘万古书’是一本仙书，暗藏百种修道大法，若得此书便可修成永生之道，所以神魔高手们一直对此书争夺不休。既然此书流落到了大离皇宫，你不妨看看能不能从离火刺客口中得到消息。");
		AddOpt("我这就去。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("想不到那离火刺客如此顽固，竟然宁死不说。");
		AddOpt("看来必须另寻他法。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10036(nTaskId, nAction)
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

---任务37---

function TASK_FUNCTION_10037(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("想不到就这样断了‘万古书’的消息！不过你的修行可不能中断，你要多出去实战历练。这里到处都是高手，对你的修为很有增益！当然也顺便打听下古书的下落。");
		AddOpt("谨听师父教诲。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("虽然没有打听到古书的下落，但你的修为倒是精进不少。");
		AddOpt("师父过奖了。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10037(nTaskId, nAction)
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

---任务38---

function TASK_FUNCTION_10038(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("近闻出了个神秘高手，必定也是为了那古书而来。徒儿不妨去看看，看能否得出些线索。");
		AddOpt("是，师父。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
		return false;
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("好不容易得道古书的消息，竟然又被盗啦？");
		AddOpt("我们来迟一步。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10038(nTaskId, nAction)
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

---任务39---

function TASK_FUNCTION_10039(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("我打听到是精锐燎天卫盗走了‘万古书’，你现在赶紧去找他，并将古书抢夺过来，这可是难得的机会，万不敢让别人抢了先。");
		AddOpt("是，师父。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("那个突然出现的魔雾到底是谁所为呢？难道邪魔高手也来争夺古书了么？");
		AddOpt("定是如此。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10039(nTaskId, nAction)
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

---任务40---

function TASK_FUNCTION_10040(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("那魔雾居然往离火殿深处去了……这下有些难办了，要知道离火殿深处险象丛生，可不好对付！不过用来隐藏万古书倒是上佳之选……");
		AddOpt("师父不必担心，徒儿愿去看看。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("它竟然是阿修罗魔女！只是可惜让它给逃了。");
		AddOpt("下次定当将其捉住。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10040(nTaskId, nAction)
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

---任务41---

function TASK_FUNCTION_10041(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("想不到她竟然是魔道中的阿修罗魔女，看来魔门也对万古书动手了，你再去会会她吧，将她捉拿过来，我自有用处。这是天公绳，你会用得上的。");
		AddOpt("是，师父。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("古书又被盗了？真是可恶！不过抓到这阿修罗魔女也不错，此女深通魔门修道之法，用来做你的助手可以神魔同修，让你道法加倍。");
		AddOpt("多谢师父。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10041(nTaskId, nAction)
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

---任务42---

function TASK_FUNCTION_10042(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("包龙图包大人对你这几日连连斩杀妖魔甚是赞赏，特意向我借用你几天。这也好，你可以通过官府的人脉打听下那股巫风的来历。现在你就去找包大人吧。");
		AddOpt("徒儿这就前往。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("你就是白师傅的高徒？嗯，果然是一表人才啊！");
		AddOpt("过奖了。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10042(nTaskId, nAction)
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

---任务43---

function TASK_FUNCTION_10043(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("素闻白师傅的高徒神勇无比，今日一见果然名不虚传。只是近来诸多神秘妖魔袭扰皇宫，惹得皇上龙颜大怒。所以希望你能帮我彻查此事。");
		AddOpt("大人不必担忧，我定查个水落石出。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("原来是这烈焰傀儡作恶，这下我可以和皇上禀报了。");
		AddOpt("希望此事就此了结。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10043(nTaskId, nAction)
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

---任务44---

function TASK_FUNCTION_10044(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("想不到那烈焰傀儡还有同伙，叫什么赤炎傀儡，还望你能再次出战，这次一定要斩草除根啊！");
		AddOpt("居然还有同伙？那我再去斩杀它一次好了。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("你真是降妖除魔的能手啊，这下皇宫安宁多了。");
		AddOpt("此乃分内之事。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10044(nTaskId, nAction)
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

---任务45---

function TASK_FUNCTION_10045(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("老夫的女儿珈蓝，昨日被一神秘人抓走了，他说要为死去的同族们报仇，指名道姓要你去，如若不然就……哎，真是急死我了，你可要救救我女儿啊！");
		AddOpt("大人请勿担忧，我已知道是何人所为，这就去救出珈蓝小姐。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("多谢你救出了我女儿。小女珈蓝十分佩服你的道法，更想为拯救玄黄大世界苍生尽一点力，愿追随你修行练道，不知可否？");
		AddOpt("难得珈蓝小姐有如此善心，我自然是愿意。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10045(nTaskId, nAction)
	local ret = false;
	if 1 == nAction then
		--未接
		ret = TASK_FUNCTION_COMMON(nTaskId);
	elseif 2 == nAction then
		--任务已被接受
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("这就好，这就好，快回去向你师父复命吧！");
		AddOpt("好，我马上去。", 3);	
		return true;
	elseif 3 == nAction then
		--任务已被接受	
		ret = TASK_FUNCTION_COMMON(nTaskId);
	end
	
	return ret;
end

---任务46---

function TASK_FUNCTION_10046(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("不知你这段日子打听到什么消息？");
		AddOpt("回禀师父，那神秘人原来是域外巫族的巫君，‘万古书’正是被他所盗。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
		CloseDlg();
		_G.TaskUISelCamp.LoadUI();
		return true;
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		CloseDlg();
		_G.TaskUISelCamp.LoadUI();
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10046(nTaskId, nAction)
	local ret = false;
	if 1 == nAction then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("什么？域外巫族已经潜入玄黄大世界啦？万年之前的玄巫大战震撼环宇，难道这场旷世灾难又将重演吗！唉，看来一场大劫在所难免了！");
		AddOpt("玄巫大战？事情竟然会这么严重？那我玄黄大世界之生灵该怎么办？", 2);
		return true;
	elseif 2 == nAction then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("别无它法，这注定是一场浩劫。我们修道之人惟有修成永生大法，与天地共享寿元方能抵抗巫族的进攻。你有着绝佳的天资，但仅靠我的传授恐怕难以突破极境。恰好这几日是天下两大修道宗派‘仙道羽化门’和‘魔道黄泉宗’招收新弟子的日子，这是习得上乘神通的好机会，以你的天资，或许能悟得真道，拯救玄黄大世界于一线！快去报名吧！");
		AddOpt("谢谢师父这段时间以来的栽培，我定不负师父期望。", 3);
		return true;
	elseif 3 == nAction then
		--未接
		--ret = TASK_FUNCTION_COMMON(nTaskId);
		TASK_OPTION_COMMON(nTaskId, SM_TASK_OPTION_ACTION.ACCEPT);
		_G.TaskUISelCamp.LoadUI();
	end
	
	return ret;
end

---任务47（羽化门）---

function TASK_FUNCTION_10047(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("我仙道羽化门乃修道界第一大派，修炼之法九万八千种，门门都是神通。所以，想要进本门派，先过了暗黑蜂后这一关吧，只有通关者才能成为见习弟子。");
		AddOpt("这有何难。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("看来你确实颇有天分，好吧，你已经是我门派的见习弟子了。");
		AddOpt("定当不负师门。", 2);	
		return true;
		elseif 4 == nAction then
		--任务已被接受
		ret = TASK_FUNCTION_COMMON(nTaskId);
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10047(nTaskId, nAction)
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

---任务48（羽化门）---

function TASK_FUNCTION_10048(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("你现在只是见习弟子，要想习得门派高级修炼之法，就得获得正式弟子的资格。不过这个资格可有风险，看你敢不敢接受了？");
		AddOpt("要是能成为正式弟子，再大的风险又何惧？", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("不错，不错，看来是个可造之才，你去向天刑长老报到吧！");
		AddOpt("好，我这就去。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10048(nTaskId, nAction)
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

---任务49（羽化门）---

function TASK_FUNCTION_10049(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("现在你已通过考核，获得了正式弟子的资格。不过也只是获得资格而已，你还需斩杀一只飞天夜叉才能成为正式弟子。");
		AddOpt("那我这就去。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("真是难得的修行奇才！好吧，我就授你正式弟子身份！");
		AddOpt("多谢长老。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10049(nTaskId, nAction)
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

---任务50（羽化门）---

function TASK_FUNCTION_10050(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("想不到你道法如此深厚，能收到你这样的弟子也算是我门派之幸事。我倒是有意晋升你为真传弟子，不过你得先拿实力来证明啊！");
		AddOpt("弟子这就去证明……", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("我果然没看错，确实是修道的材料！");
		AddOpt("还请长老收下。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10050(nTaskId, nAction)
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

---任务51（羽化门）---

function TASK_FUNCTION_10051(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("你确实天资超群，若能得到高人指点，日后必有所成。我就授你真传弟子的资格，你带着这玉牌去拜见掌门羽化至尊吧，不过成与不成还得掌门人定夺！");
		AddOpt("多谢引荐，弟子感激不尽。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("嗯，倒是个人才，必是得过大际遇吧！");
		AddOpt("掌教过奖了。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10051(nTaskId, nAction)
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

---任务52（羽化门）---

function TASK_FUNCTION_10052(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("既然你已拜入我门下，门派自然会传授你修道之法。只是想成为我的真传弟子可没那么容易，毕竟真传弟子是本门的砥柱力量，没有降服得了幽芒蝰蛇的本事其他都免谈！");
		AddOpt("弟子愿去一搏。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("甚好，甚好，看来你比我想象中要强得多！");
		AddOpt("掌教过奖了。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10052(nTaskId, nAction)
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

---任务53（羽化门）---

function TASK_FUNCTION_10053(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("我就授予你真传弟子的身份，以后由我传授本门神通于你。现在我要先磨练你的心性，看你能否抵挡得住魔帅心魂之法的历练。");
		AddOpt("是！", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("看来你心性纯正？可以给你开放精英任务了，这样能加快你的修炼速度。");
		AddOpt("多谢掌门。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10053(nTaskId, nAction)
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

---任务54（羽化门）---

function TASK_FUNCTION_10054(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("你修炼神速，看来我门派之中又多了一个非凡之才啊。现在我就要考验你的意志如何了，接受历练吧。");
		AddOpt("谨遵掌门法旨。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("想不到通过这场历练，不仅你的意志得到了加强，连肉体根骨也隐约中显现出道骨的灵性了……");
		AddOpt("掌门过奖了。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10054(nTaskId, nAction)
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


---任务55（羽化门）---

function TASK_FUNCTION_10055(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("你的肉身已经修炼到了极限，就要蜕变为道骨了。我现在授你道骨修炼秘法，你去找天神幻影历练吧！");
		AddOpt("多谢掌门指点，弟子这就去。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("嗯，你身上的灵气越来越明显了，看来我的想法是对的。");
		AddOpt("弟子谨遵教诲。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10055(nTaskId, nAction)
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

---任务56（羽化门）---

function TASK_FUNCTION_10056(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("你的根骨灵气越来越浑厚，已经到了蜕变的顶峰！要是能一举蜕变为道骨，对修炼我门派神通就能有更深的参悟，法力定然倍增。你再出去历练下，应该就能把道骨蜕变出来了。");
		AddOpt("弟子谨遵掌门法旨。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("竟然还未蜕变，这倒出乎我的意料。看来只能走‘九阳圣水’这一步了……");
		AddOpt("弟子这就前往寻早圣水。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10056(nTaskId, nAction)
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

---任务57（羽化门）---

function TASK_FUNCTION_10057(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("血夜之王炼制的九阳圣水有脱胎换骨的奇效，应该说对你蜕变道骨有大用处。只是那圣水药性极烈，不是一般人能忍受的，还有殒命的危险……");
		AddOpt("弟子不惧，愿意一试。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("那九阳圣水果然发挥奇效了，你现在已经蜕变出了道骨，实在是我门派之福啊！");
		AddOpt("弟子日后定当努力回报。", 3);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10057(nTaskId, nAction)
	local ret = false;
	if 1 == nAction then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("好，勇气可嘉，我果然没有看错你。");
		AddOpt("那我这就去找血夜之王。", 2);
		return true;
	elseif 2 == nAction then
		--未接
		ret = TASK_FUNCTION_COMMON(nTaskId);	
	elseif 3 == nAction then
		--任务已被接受
		ret = TASK_FUNCTION_COMMON(nTaskId);
	end
	
	return ret;
end

---任务58（羽化门）---

function TASK_FUNCTION_10058(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("你现在速去蓝月城，土洪星君已经先行一步到达了那里，有要事吩咐你去做！");
		AddOpt("是，我马上启程！", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("你来啦！甚好甚好。");
		AddOpt("有何难事尽管道来。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10058(nTaskId, nAction)
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

---任务47（黄泉宗）---

function TASK_FUNCTION_11047(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("我魔道黄泉宗乃修道界第一大派，修炼之法九万八千种，门门都是神通。所以，想要进本门派，先过了暗黑蜂后这一关吧，只有通关者才能成为见习弟子。");
		AddOpt("这有何难。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("看来你确实颇有天分，好吧，你已经是我门派的见习弟子了。");
		AddOpt("定当不负师门。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_11047(nTaskId, nAction)
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

---任务48（黄泉宗）---

function TASK_FUNCTION_11048(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("你现在只是见习弟子，要想习得门派高级修炼之法，就得获得正式弟子的资格。不过这个资格可有风险，看你敢不敢接受了？");
		AddOpt("要是能成为正式弟子，再大的风险又何惧？", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("不错，不错，看来是个可造之才，你去向天恒魔王报到吧！");
		AddOpt("好，我这就去。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_11048(nTaskId, nAction)
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

---任务49（黄泉宗）---

function TASK_FUNCTION_11049(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("现在你已通过考核，获得了正式弟子的资格。不过也只是获得资格而已，你还需斩杀一只飞天夜叉才能成为正式弟子。");
		AddOpt("那我这就去。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("真是难得的修行奇才！好吧，我就授你正式弟子身份！");
		AddOpt("多谢长老。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_11049(nTaskId, nAction)
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

---任务50（黄泉宗）---

function TASK_FUNCTION_11050(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("想不到你道法如此深厚，能收到你这样的弟子也算是我门派之幸事。我倒是有意晋升你为真传弟子，不过你得先拿实力来证明啊！");
		AddOpt("弟子这就去证明……", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("我果然没看错，确实是修道的材料！");
		AddOpt("还请长老收下。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_11050(nTaskId, nAction)
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

---任务51（黄泉宗）---

function TASK_FUNCTION_10051(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("你确实天资超群，若能得到高人指点，日后必有所成。我就授你真传弟子的资格，你带着这玉牌去拜见掌门黄泉大帝吧，不过成与不成还得掌门人定夺！");
		AddOpt("多谢引荐，弟子感激不尽。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("嗯，倒是个人才，必是得过大际遇吧！");
		AddOpt("掌教过奖了。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10051(nTaskId, nAction)
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

---任务52（黄泉宗）---

function TASK_FUNCTION_11052(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("既然你已拜入我门下，门派自然会传授你修道之法。只是想成为我的真传弟子可没那么容易，毕竟真传弟子是本门的砥柱力量，没有降服得了幽芒蝰蛇的本事其他都免谈！");
		AddOpt("弟子愿去一搏。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("甚好，甚好，看来你比我想象中要强得多！");
		AddOpt("掌教过奖了。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_11052(nTaskId, nAction)
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

---任务53（黄泉宗）---

function TASK_FUNCTION_11053(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("我就授予你真传弟子的身份，以后由我传授本门神通于你。现在我要先磨练你的心性，看你能否抵挡得住魔帅心魂之法的历练。");
		AddOpt("是！", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("看来你心性纯正？可以给你开放精英任务了，这样能加快你的修炼速度。");
		AddOpt("多谢掌门。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_11053(nTaskId, nAction)
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

---任务54（黄泉宗）---

function TASK_FUNCTION_11054(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("你修炼神速，看来我门派之中又多了一个非凡之才啊。现在我就要考验你的意志如何了，接受历练吧。");
		AddOpt("谨遵掌门法旨。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("想不到通过这场历练，不仅你的意志得到了加强，连肉体根骨也隐约中显现出道骨的灵性了……");
		AddOpt("掌门过奖了。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_11054(nTaskId, nAction)
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


---任务55（黄泉宗）---

function TASK_FUNCTION_11055(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("你的肉身已经修炼到了极限，就要蜕变为道骨了。我现在授你道骨修炼秘法，你去找天神幻影历练吧！");
		AddOpt("多谢掌门指点，弟子这就去。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("嗯，你身上的灵气越来越明显了，看来我的想法是对的。");
		AddOpt("弟子谨遵教诲。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_11055(nTaskId, nAction)
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

---任务56（黄泉宗）---

function TASK_FUNCTION_11056(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("你的根骨灵气越来越浑厚，已经到了蜕变的顶峰！要是能一举蜕变为道骨，对修炼我门派神通就能有更深的参悟，法力定然倍增。你再出去历练下，应该就能把道骨蜕变出来了。");
		AddOpt("弟子谨遵掌门法旨。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("竟然还未蜕变，这倒出乎我的意料。看来只能走‘九阳圣水’这一步了……");
		AddOpt("弟子这就前往寻早圣水。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_11056(nTaskId, nAction)
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

---任务57（黄泉宗）---

function TASK_FUNCTION_11057(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("血夜之王炼制的九阳圣水有脱胎换骨的奇效，应该说对你蜕变道骨有大用处。只是那圣水药性极烈，不是一般人能忍受的，还有殒命的危险……");
		AddOpt("弟子不惧，愿意一试。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("那九阳圣水果然发挥奇效了，你现在已经蜕变出了道骨，实在是我门派之福啊！");
		AddOpt("弟子日后定当努力回报。", 3);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_11057(nTaskId, nAction)
	local ret = false;
	if 1 == nAction then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("好，勇气可嘉，我果然没有看错你。");
		AddOpt("那我这就去找血夜之王。", 2);
		return true;
	elseif 2 == nAction then
		--未接
		ret = TASK_FUNCTION_COMMON(nTaskId);	
	elseif 3 == nAction then
		--任务已被接受
		ret = TASK_FUNCTION_COMMON(nTaskId);
	end
	
	return ret;
end

---任务58（黄泉宗）---

function TASK_FUNCTION_11058(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("你现在速去蓝月城，土洪星君已经先行一步到达了那里，有要事吩咐你去做！");
		AddOpt("是，我马上启程！", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("你来啦！甚好甚好。");
		AddOpt("有何难事尽管道来。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_11058(nTaskId, nAction)
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

---任务59---

function TASK_FUNCTION_10059(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("你英彩师妹前段时间来到了蓝月城，至今没有消息，实在让人担心，你赶紧去找找吧！");
		AddOpt("是，我这就去。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("找着了么？");
		AddOpt("师妹往沙漠更深处去了……", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10059(nTaskId, nAction)
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

---任务60---

function TASK_FUNCTION_10060(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("什么？这丫头竟然往沙漠更深处去了？要是遇到灭星和刺月两个悍匪怎么办？你赶紧将找她回来。");
		AddOpt("我立马动身。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("竟然被抓走了？这下糟糕了……");
		AddOpt("星君莫急。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10060(nTaskId, nAction)
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

---任务61---

function TASK_FUNCTION_10061(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("怕出事怕出事，可这偏偏就出了事！这蓝月城危险无比，要是英彩有个闪失我怎么向掌门交代？你快将此事汇报给火宇星君师兄，请他定夺！");
		AddOpt("是。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("哎……这丫头啊，都是被我惯坏的。如今被那灭星刺月抓走，要是有个三长两短我怎么对得起掌门的嘱托啊？");
		AddOpt("星君不必太过担忧，英彩师妹吉人天相，定能逢凶化吉！", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10061(nTaskId, nAction)
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

---任务62---

function TASK_FUNCTION_10062(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("都是我没能看管好英彩，让她四处乱跑，这次被抓走怕是有危险啊！");
		AddOpt("星君不必担忧，我这就去将师妹找回来！", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("怎么样？哎，真是急死我了！");
		AddOpt("星君莫急。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10062(nTaskId, nAction)
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

---任务63---

function TASK_FUNCTION_10063(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("都这么多天了，英彩不知是凶是吉？不管如何，这次你一定要找到英彩。");
		AddOpt("星君放心，如果这次不能将师妹带回来，我愿以死谢罪！", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("终于是回来了，太谢谢你了！我总算可以跟掌门交代了！");
		AddOpt("星君客气了。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10063(nTaskId, nAction)
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

---任务64---

function TASK_FUNCTION_10064(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("这次你救回英彩立了大功，这是掌门赏赐你的水灵电母丹。他知道你修炼的五行大术就差水系功法了，这丹对你肯定会有帮助的，去炼化它吧！");
		AddOpt("多谢星君和掌门！", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("看来这丹对你真的很有效果！");
		AddOpt("还望星君多多栽培。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10064(nTaskId, nAction)
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

---任务65---

function TASK_FUNCTION_10065(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("你的五行大术已经到了大成境界，确实可喜可贺！你要趁热打铁，只有参悟其中的奥秘才能修得圆满！这蓝月城诡异无比，是个不错的参悟之地！");
		AddOpt("多谢星君指点！", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("很好，想不到你这么快就参悟了金系功法！");
		AddOpt("星君过奖了。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10065(nTaskId, nAction)
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

---任务66---

function TASK_FUNCTION_10066(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("你现在只将金系功法练得圆满，其余四门也要抓紧啊！");
		AddOpt("是！", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("看来金克木果然是你的阻碍……");
		AddOpt("定当努力修炼提升。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10066(nTaskId, nAction)
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

---任务67---

function TASK_FUNCTION_10067(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("原以为你有盘武仙根能够挡住金气的克制，看来也是不行，那不如你先练土系神功吧！你速去找土洪星君师弟，土系功法可是他的本命绝学！");
		AddOpt("我这就去！", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("哦？师兄让你来找我的？");
		AddOpt("正是，他让弟子前来向星君学习土系功法！", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10067(nTaskId, nAction)
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

---任务68---

function TASK_FUNCTION_10068(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("你有练过土黄功？这门神通倒是和我的‘遁土大法’有相通之处，好吧，我就将参悟心法传授于你，至于能不能成就看你自己的领悟能力了！");
		AddOpt("多谢星君指点！", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("还真是奇才啊，竟然这么快就修成了！");
		AddOpt("还需要多多修炼才行。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10068(nTaskId, nAction)
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

---任务69---

function TASK_FUNCTION_10069(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("当年我苦苦参悟数十载才将‘遁土大法’练得圆满，没想到你几个时辰就修成了，果然是门派中的奇才！");
		AddOpt("星君谬夸了，这多亏了星君秘法的传授！敢问星君，我的水系功法该如何修炼才可圆满？", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("可惜啊，如此宝物就这样毁了！");
		AddOpt("确实如此。", 3);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10069(nTaskId, nAction)
	local ret = false;
	if 1 == nAction then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("水系功法，海天炉的水灵之气盈盛，足够你参悟之用！");
		AddOpt("那好，我马上去寻找此物。", 2);
		return true;
	elseif 2 == nAction then
		--未接
		ret = TASK_FUNCTION_COMMON(nTaskId);
	elseif 3 == nAction then
		--任务已被接受
		ret = TASK_FUNCTION_COMMON(nTaskId);
	end
	
	return ret;
end


---任务70---

function TASK_FUNCTION_10070(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("虽然毁了海天炉，不过，我知道有个人是水凌圣母转世，她的水系灵气也是很足的，你不妨去看看！");
		AddOpt("太好了，我这就去。弟子告辞！", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("呵呵，终于是练成了，现在你的五行术已经圆满了三门神通，实在是可喜可贺！");
		AddOpt("多谢星君夸奖。现在我感觉自己体内云火翻滚，看来也到了顿悟的最佳时机，这门神通该如何参悟？", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10070(nTaskId, nAction)
	local ret = false;
	if 1 == nAction then
		--未接
		ret = TASK_FUNCTION_COMMON(nTaskId);
	elseif 2 == nAction then
		--任务已被接受
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("火系功法我就不精通了，你去向火宇星君请教吧，师兄是这方面的行家！");
		AddOpt("那弟子先行告退。", 3);	
		return true;
	elseif 3 == nAction then
		--任务已被接受
		ret = TASK_FUNCTION_COMMON(nTaskId);
	end
	
	return ret;
end

---任务71---

function TASK_FUNCTION_10071(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("你想把你云火神功练得圆满？这你就错了，你现在体内真气翻滚乃是水系功法逼迫火云造成的！");
		AddOpt("怎么会是这样？那我该如何是好？请星君明示！", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("现在你的云火之气平稳了！");
		AddOpt("如此甚好。", 3);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10071(nTaskId, nAction)
	local ret = false;
	if 1 == nAction then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("你要是懂得混凝大法的话，一切就迎刃而解了！");
		AddOpt("那我这就去习练此法！", 2);	
		return true;
	elseif 2 == nAction then
		--未接
		ret = TASK_FUNCTION_COMMON(nTaskId);
	elseif 3 == nAction then
		--任务已被接受
		ret = TASK_FUNCTION_COMMON(nTaskId);
	end
	
	return ret;
end

---任务72---

function TASK_FUNCTION_10072(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("你现在可以开始参悟火系功法了。那龙道人乃是火龙转世，对你参悟此功应该大有裨益！");
		AddOpt("那弟子这就前往。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("果然见成效了，甚好甚好！");
		AddOpt("小事一桩。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10072(nTaskId, nAction)
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

---任务73---

function TASK_FUNCTION_10073(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("你如今四门功法修得圆满，确实神速。不过也正是因为修炼得过快，各真气会不时地相生相克，稍有不慎，极易走火入魔。你且将最后一门功法放一放，先找到镇法元石，将体内真气融汇贯通才是！");
		AddOpt("是！", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("嗯，现在你不必担心走火入魔了！这最后一门木系功法恐怕你还得请教土洪师弟，他对土木相生相克之理都很精通！");
		AddOpt("那我这就去。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10073(nTaskId, nAction)
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

---任务74---

function TASK_FUNCTION_10074(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("接下来你参悟木系功法想必就容易多了，去找木道人吧，你会受益匪浅的！");
		AddOpt("多谢星君提示。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("你终于是将五行术中的五门神通都练就圆满了，门派之幸，门派之幸啊！好，终于可以委以你大任了！");
		AddOpt("星君过奖了。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10074(nTaskId, nAction)
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

---任务75---

function TASK_FUNCTION_10075(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("在众多真传弟子中，修为进步能有你这样迅猛的绝无仅有！过几日就是修道界比武大会了，我委任你代表本派参赛。这是赛会的青龙令牌！你现在就赶去万归仙岛，太虚长老一行已先行到达了！");
		AddOpt("好的，我这就动身！", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("你来啦！还将五行大术练到了圆满境界，真是太好了！看来你这次定能在比武大会上大放异彩，为我门派争光了！");
		AddOpt("弟子定当全力以赴。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10075(nTaskId, nAction)
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

---任务76---

function TASK_FUNCTION_10076(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("这比武大会是修道界十年一届的盛会，也是各门派展现实力、争夺排位的最佳时机！每届设立一块‘天下第一’的牌匾。这千百年来，有实力获得此牌匾的门派只有仙道羽化门与魔道黄泉宗，所以我们两派都号称自己是天下第一，其实谁也不服谁，这次本派能不能拿到此牌匾就看你的表现了！");
		AddOpt("弟子定当全力以赴！", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("一来便旗开得胜！不错不错！");
		AddOpt("长老过奖了。", 3);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10076(nTaskId, nAction)
	local ret = false;
	if 1 == nAction then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("我相信你的实力！赶紧参赛去吧！");
		AddOpt("是！", 2);
		return true;
	elseif 2 == nAction then
		--未接
		ret = TASK_FUNCTION_COMMON(nTaskId);
	elseif 3 == nAction then
		--任务已被接受
		ret = TASK_FUNCTION_COMMON(nTaskId);
	end
	
	return ret;
end

---任务77---

function TASK_FUNCTION_10077(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("现在我门派率先竖起了一块道牌，真是可喜可贺！你要乘胜追击，将我门派的优势扩大！");
		AddOpt("是！", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("太好了，你又为本派获得了一块道牌！");
		AddOpt("长老过奖了。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10077(nTaskId, nAction)
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

---任务78---

function TASK_FUNCTION_10078(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("能有你这样的得意弟子真是门派之福啊，我就在这等着你的第三块道牌了，哈哈!");
		AddOpt("弟子定将第三块道牌取得！", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("第三块道牌也拿到了，不错不错！");
		AddOpt("弟子定当再接再厉。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10078(nTaskId, nAction)
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

---任务79---

function TASK_FUNCTION_10079(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("你三战全胜，拿下三块道牌，为本派确立了领先优势。甚好甚好，继续再接再厉吧！!");
		AddOpt("是。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("这已经是第四块了，你会破纪录么？");
		AddOpt("弟子定全力以赴。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10079(nTaskId, nAction)
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

---任务80---

function TASK_FUNCTION_10080(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("你连夺四块道牌，已经轰动整个比武大会了，要是能将第五块也拿到手的话，那你就是第一阶段的大满贯了！!");
		AddOpt("这个大满贯我拿定了！", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("想不到你真的把第一阶段的五块道牌都拿到手了！");
		AddOpt("唯有以此报恩。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10080(nTaskId, nAction)
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

---任务81---

function TASK_FUNCTION_10081(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("到如今，本次比武大会第一阶段的试炼已经结束，你连夺五块道牌已经破了历届大会第一阶所获道牌数的记录了！现在你到轮回长老处领取第二阶段比赛的白虎令牌吧！!");
		AddOpt("弟子领命！", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("不错不错，你表现得很好，连掌门都对你赞赏有加，你要继续努力！这是参加大会第二阶段的白虎令牌，你可收好了。");
		AddOpt("是！", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10081(nTaskId, nAction)
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

---任务82---

function TASK_FUNCTION_10082(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("你这次包揽了第一阶段所有的五块道牌，为本门确立了很大的优势！不过，这还只是第一阶段，第二阶段的试炼更加残酷，真正的考验才开始，你要小心！!");
		AddOpt("谨遵长老教诲！", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("很好，看来第二阶段的试炼难度没有给你造成什么困难！");
		AddOpt("长老放心。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10082(nTaskId, nAction)
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

---任务83---

function TASK_FUNCTION_10083(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("你的风头实在太盛了，惹得各门派都竞相发力。接下来的试炼势必更加激烈，你要顶住啊！!");
		AddOpt("长老放心，弟子应付得了！", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("看来你确实是应付得了，我的担心是多余的。");
		AddOpt("弟子定当再接再厉。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10083(nTaskId, nAction)
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

---任务84---

function TASK_FUNCTION_10084(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("本门派获得的道牌数如今仍然领先于其他门派，这次获得‘天下第一’的牌匾希望很大！不过有一个门派很值得注意，就是万归宗！他们获得的道牌数突然猛增，竟然排到了第三的位置,这个你要注意下。!");
		AddOpt("弟子会注意的。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("竟然有人比你先获得道牌？会是谁呢？");
		AddOpt("待弟子去查个清楚。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10084(nTaskId, nAction)
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

---任务85---

function TASK_FUNCTION_10085(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("我查清楚了，是万归宗的弟子先你一步夺走了道牌，想不到万归宗这样的小门派竟然也出了如此了得的弟子。现在他们的排名已经直追本门，我们的优势不多了！");
		AddOpt("长老放心，接下来的试炼我定当竭尽全力，必定助门派夺得‘天下第一’的牌匾。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("看得出你确实很努力……");
		AddOpt("此乃弟子本分。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10085(nTaskId, nAction)
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

---任务86---

function TASK_FUNCTION_10086(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("不过还是得告诉你，万归宗获得的道牌数已经超过本门派，位居第一了！");
		AddOpt("这万归宗几时变得如此强大了？", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("原来是这样，难怪万归宗能短短几日就超越本派！");
		AddOpt("看来必须要小心才是。", 3);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10086(nTaskId, nAction)
	local ret = false;
	if 1 == nAction then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("这就是奇怪的地方。这样吧，你不妨暗中查探一下。");
		AddOpt("是！", 2);
		return true;
	elseif 2 == nAction then
		--未接
		ret = TASK_FUNCTION_COMMON(nTaskId);
	elseif 3 == nAction then
		--任务已被接受
		ret = TASK_FUNCTION_COMMON(nTaskId);
	end
	
	return ret;
end

---任务87---

function TASK_FUNCTION_10087(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("万归宗的做法实在有违比武大会的规则，你赶紧将此事报告太虚师兄！");
		AddOpt("弟子这就去。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("万归宗的事情我已经知道了，各门派都在谴责万归宗弟子的行为，这实在不是修道之人应有的作为，掌门正与各派宗主商讨对策，我们静等消息就是！");
		AddOpt("弟子领命。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10087(nTaskId, nAction)
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

---任务88---

function TASK_FUNCTION_10088(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("经比武大会最高委员会的深入探讨，一致认为万归宗的做法有违本次大会公平、公正、公开的原则，更不是修道之人应有的心性！现研究决定，对万归宗发出调查令，你速去彻查此事！");
		AddOpt("是！", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("这万归宗的弟子真是这么说的？");
		AddOpt("的确如此。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10088(nTaskId, nAction)
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

---任务89---

function TASK_FUNCTION_10089(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("万归宗的事情存在着诸多疑点，单凭一个弟子的言语还不敢就此定下结论，还是调查清楚了为好！");
		AddOpt("那弟子再去调查此事！", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("看来确实是这样了，我马上报告掌门！");
		AddOpt("必须给他们点颜色瞧瞧。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10089(nTaskId, nAction)
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

---任务90---

function TASK_FUNCTION_10090(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("掌门有令，让你前去向万归宗主讨个说法！看他如何解释！");
		AddOpt("弟子正有此意！", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("原来如此！竟然是那个大长老在作祟！");
		AddOpt("此事已然明了。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10090(nTaskId, nAction)
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

---任务91---

function TASK_FUNCTION_10091(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("我也早就发觉那个大长老有些古怪，没想到果然是他在搞鬼！你速去捉拿此人！");
		AddOpt("是！", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("你说什么？和大长老在一起的还有一个神秘妖物？");
		AddOpt("是的。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10091(nTaskId, nAction)
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

---任务92---

function TASK_FUNCTION_10092(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("你说与那万归宗长老一起的妖孽叫什么？不可能，不可能，怎么可能是它，肯定是搞错了！");
		AddOpt("不知搞错何事，长老为何连呼‘不可能’？", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("真的是劫数啊，那群巨妖果然逃出来了！");
		AddOpt("现在该如何是好，请长老指示！", 4);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10092(nTaskId, nAction)
	local ret = false;
	if 1 == nAction then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("话说那妖孽数千年前已被各派掌门合力封印在了蛮荒神庙中，怎可能破印出来作祟呢？");
		AddOpt("那弟子再去调查此事！", 2);	
		return true;
	elseif 2 == nAction then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("嗯，这事一定要彻查到底！这是掌门的霹雳仙葫，若真是那巨妖作祟，你可以用此葫收服它！");
		AddOpt("是！", 3);	
		return true;
	elseif 3 == nAction then
		--未接
		ret = TASK_FUNCTION_COMMON(nTaskId);
	elseif 4 == nAction then
		--任务已被接受
		ret = TASK_FUNCTION_COMMON(nTaskId);
	end
	
	return ret;
end

---任务93---

function TASK_FUNCTION_10093(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("你现在火速前往蛮荒神庙，协助镇蛮元君降服这群妖孽，不然人间就有大难了！");
		AddOpt("是！我马上动身！", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("你来得正好，我正缺少人手呢！");
		AddOpt("请元君尽管吩咐。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_10093(nTaskId, nAction)
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