
local _G = _G;
setfenv(1, TASK);

---支线任务1---

function TASK_FUNCTION_20001(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("阁下就是白海禅大师新收的得意弟子么，这下好了……前日我从城外回来时青锋剑被枯木树妖抢走了，那都是价值连城的宝物啊，可否替我夺回来？");
		AddOpt("好的，我这就去夺回青锋剑。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("我的青锋剑终于回来了！你真是武艺超群，多谢了。 ");
		AddOpt("小事一桩。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_20001(nTaskId, nAction)
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

---支线任务2---

function TASK_FUNCTION_20002(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("素闻白海禅收了一个高徒，想必就是你吧。既然你身手如此不凡，可否前去击杀铁枝树妖？那妖物不知是怎么修炼的，全身竟然坚硬如铁，十分厉害！");
		AddOpt("有这等事？我马上去看看。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("你当真把那妖孽灭了？真不愧为白师傅的高徒啊！ ");
		AddOpt("过奖了。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_20002(nTaskId, nAction)
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

---支线任务3---

function TASK_FUNCTION_20003(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("你就是白大师的高徒吧？呵呵，近闻你接连斩杀了多只妖孽，勇猛无敌，所以特此请你去铲除小蜂妖，你应该不会拒绝吧？");
		AddOpt("这个当然不会。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("你果然名不虚传啊！ ");
		AddOpt("过奖了。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_20003(nTaskId, nAction)
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

---支线任务4---

function TASK_FUNCTION_20004(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("最近有一群蜂妖首领四处作恶，不知你可否前去将它剿杀？");
		AddOpt("这个义不容辞。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("真是好功夫！佩服，佩服！ ");
		AddOpt("小事一桩。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_20004(nTaskId, nAction)
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

---支线任务5---

function TASK_FUNCTION_20005(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("我日前押送一批货物过龙渊河时，被一股黑风袭击，所押货物全被席卷一空。这可急坏了我，还望你能为我夺回来。");
		AddOpt("想必又是妖孽作祟，你放心，我这就去为你夺回货物。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("没错没错，这正是我的货物，真是万分感谢。 ");
		AddOpt("不必多礼。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_20005(nTaskId, nAction)
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

---支线任务6---

function TASK_FUNCTION_20006(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("在我运送货物的途中出现了一批可怕的狼群，过往旅人多为所害，路旁堆满了累累白骨，甚是恐怖！");
		AddOpt("哦，竟有这等事，我必定铲除它们。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("你真是越来越神勇了，佩服佩服，这下过往旅人安全多了！ ");
		AddOpt("过奖了。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_20006(nTaskId, nAction)
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

---支线任务7---

function TASK_FUNCTION_20007(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("水天如玉原本是城中百姓用来求雨祭祀、召唤四海龙王的圣物，不知怎么落到了暴戾狼妖的手中……");
		AddOpt("肯定是它偷去的，我这就将它夺回来。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("夺回来了就好，夺回来了就好！ ");
		AddOpt("请您收好。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_20007(nTaskId, nAction)
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

---支线任务8---

function TASK_FUNCTION_20008(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("我既然都把‘万古书’的消息告诉你了，你是否也该为我办件事情呢？");
		AddOpt("这个当然，不知姑娘要我所办何事？", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("这火离珠果然是珍宝啊，多谢了。 ");
		AddOpt("姑娘何必多礼。", 3);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_20008(nTaskId, nAction)
	local ret = false;
	if 1 == nAction then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("我素爱珠宝，尤其是离火护卫的离火精元，不知你可否夺来？");
		AddOpt("好吧，我这就去夺来，就当对姑娘的报答了。", 2);
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

---支线任务9---

function TASK_FUNCTION_20009(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("近日离火统领带人四处横行霸道，说是为了捉拿妖孽，其实是在到处搜刮民脂民膏，百姓叫苦连天啊！");
		AddOpt("这些狗官，看我怎么教训他们。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("你可为百姓出了一口恶气啊。 ");
		AddOpt("此乃在下分内之事。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_20009(nTaskId, nAction)
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

---支线任务10---

function TASK_FUNCTION_20010(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("这几日我要静心闭关修炼，只是那精锐燎天卫整日带着人马巡逻，嘈杂至极，这让我怎么修炼？");
		AddOpt("这事交给我好了。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("这下清静多了，多谢你了。 ");
		AddOpt("不必客气。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_20010(nTaskId, nAction)
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

---支线任务11---

function TASK_FUNCTION_20011(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("听说燎天统领专门捉拿年轻少女做妻妾，我一个弱女子实在害怕，你如此神勇可要保护我们啊！");
		AddOpt("有我在，你们放心好了。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("太好了，我们这些少女安全了，多谢你了。 ");
		AddOpt("姑娘多礼了。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_20011(nTaskId, nAction)
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

---支线任务12---

function TASK_FUNCTION_20012(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("自从烈焰傀儡出现后，大离皇宫就越来越不太平了。只是它们行踪诡异，实在难以捉拿！");
		AddOpt("那就看我的好了。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("你果然厉害，佩服，佩服！ ");
		AddOpt("老板过奖了。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_20012(nTaskId, nAction)
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

---支线任务13---

function TASK_FUNCTION_20013(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("燎火殿最近妖气极重，怕是又有妖魔作祟了，你可否去清除这股妖气？");
		AddOpt("我正有此意。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("妖气一除，真是拨开云雾见天日啊！ ");
		AddOpt("在下告辞。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_20013(nTaskId, nAction)
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

---支线任务14（羽化门）---

function TASK_FUNCTION_20014(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("你刚来门派，想必对门派的规矩还不是很懂咯？跟你说吧，要想在门派扎稳脚跟，就得先打出自己的威望来，这样门派才会关注你啊！");
		AddOpt("原来如此，那我这就去打出自己的威望。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("看来身手不错嘛，门派肯定会关注你的。 ");
		AddOpt("如此甚好。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_20014(nTaskId, nAction)
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

---支线任务15（羽化门）---

function TASK_FUNCTION_20015(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("想不想得到门派众多长老的关注？想是吧？那可就要干出一番事迹才行。所以，年轻人，你就去做些能引起轰动的事情吧！");
		AddOpt("瞧我的好了。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("你真是一鸣惊人啊，很多长老都知道你了！ ");
		AddOpt("过奖了。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_20015(nTaskId, nAction)
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

---支线任务16（羽化门）---

function TASK_FUNCTION_20016(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("那地魔把我的一批晶玉残骸偷走了，那可是我用来炼制绝密武器的必备材料啊，麻烦你速速帮我追讨回来。");
		AddOpt("我立马动身。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("这可都是我的宝贝啊！谢谢你了！ ");
		AddOpt("太客气了。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_20016(nTaskId, nAction)
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

---支线任务17（羽化门）---

function TASK_FUNCTION_20017(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("跟你说个秘密吧，掌门和妖皇是老冤家，你要是能破了妖皇的分身，掌门肯定会对你刮目相看的！");
		AddOpt("哦？还有这种事，那我去试试。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("哈哈，我没骗你吧！ ");
		AddOpt("姑娘帮大忙了。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_20017(nTaskId, nAction)
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

---支线任务18（羽化门）---

function TASK_FUNCTION_20018(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("你最近声名鹊起，却也惹来不少同门的羡慕嫉妒恨。貌似还有些人不服气啊，你说该如何呢？");
		AddOpt("我会让他们服气的……", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("呵呵，这下很多人都对你服气了。 ");
		AddOpt("定叫他们不得小瞧于我。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_20018(nTaskId, nAction)
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

---支线任务19（羽化门）---

function TASK_FUNCTION_20019(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("昨日有弟子看见天魔战场上出现了成群的幽芒蝰蛇，这蛇群要是发起攻击来可是不得了啊！");
		AddOpt("不必担心，我去把它们剿杀了就是。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("竟然有这么多，还好你及时将它们斩杀了。 ");
		AddOpt("此乃在下本分。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_20019(nTaskId, nAction)
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

---支线任务20（羽化门）---

function TASK_FUNCTION_20020(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("近日，出去采集仙草的弟子多被赤头飞蛮击伤，实在是可恶啊！你去把那些赤头飞蛮都铲除了吧！");
		AddOpt("好的。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("这下采药弟子们安全多了。 ");
		AddOpt("还要小心才是。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_20020(nTaskId, nAction)
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

---支线任务21（羽化门）---

function TASK_FUNCTION_20021(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("我看见摄魄天魔了，它到处摄人心魄好可怕啊……");
		AddOpt("我不会让这些该死的妖孽继续作祟的。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("还好你把它们铲除了，真是吓死人了。 ");
		AddOpt("姑娘不必多礼。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_20021(nTaskId, nAction)
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

---支线任务22（羽化门）---

function TASK_FUNCTION_20022(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("我的麒麟坐骑被狰狞天魔吃了，真是气煞我也，我要将它碎尸万段……");
		AddOpt("你且息怒，我愿代为前往。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("总算是消了我的心头之恨…… ");
		AddOpt("日后请多加小心。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_20022(nTaskId, nAction)
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

---支线任务23（羽化门）---

function TASK_FUNCTION_20023(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("我感觉这段日子元气损耗严重，运功时内力不足，这必定是天神幻影暗中吸走了天地之间的元气。");
		AddOpt("我要它们把元气都吐回来。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("现在元气充沛了！ ");
		AddOpt("如此甚好。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_20023(nTaskId, nAction)
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

---支线任务24（羽化门）---

function TASK_FUNCTION_20024(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("我的金碧大丹就要炼成了，只是还差婆娑念珠作为引子，不知你能否为我弄些来？");
		AddOpt("我立马动身。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("哈哈，看来我的金碧大丹指日可成了。 ");
		AddOpt("如此甚好。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_20024(nTaskId, nAction)
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

---支线任务25（羽化门）---

function TASK_FUNCTION_20025(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("听说最近门派中经常有弟子被拳霸幻影所伤，长老们正为此事头疼呢。");
		AddOpt("我去杀了拳霸幻影，长老们就不必头疼了吧。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("做得很好，长老们都夸你呢！ ");
		AddOpt("长老们过奖了。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_20025(nTaskId, nAction)
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

---支线任务26（羽化门）---

function TASK_FUNCTION_20026(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("我炼制的天魔丹，可以使那些天魔改邪归正，不过需要加入天魔印记，再炼上七七四十九天才行，你为我收集些天魔印记来吧。");
		AddOpt("好的，我这就去。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("太好了，有了这些天魔印记，我的天魔丹成矣！ ");
		AddOpt("恭喜长老。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_20026(nTaskId, nAction)
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

---支线任务14（黄泉宗）---

function TASK_FUNCTION_21014(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("你刚来门派，想必对门派的规矩还不是很懂咯？跟你说吧，要想在门派扎稳脚跟，就得先打出自己的威望来，这样门派才会关注你啊！");
		AddOpt("原来如此，那我这就去打出自己的威望。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("看来身手不错嘛，门派肯定会关注你的。 ");
		AddOpt("如此甚好。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_21014(nTaskId, nAction)
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

---支线任务15（黄泉宗）---

function TASK_FUNCTION_21015(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("想不想得到门派众多长老的关注？想是吧？那可就要干出一番事迹才行。所以，年轻人，你就去做些能引起轰动的事情吧！");
		AddOpt("瞧我的好了。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("你真是一鸣惊人啊，很多长老都知道你了！ ");
		AddOpt("过奖了。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_21015(nTaskId, nAction)
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

---支线任务16（黄泉宗）---

function TASK_FUNCTION_21016(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("那地魔把我的一批晶玉残骸偷走了，那可是我用来炼制绝密武器的必备材料啊，麻烦你速速帮我追讨回来。");
		AddOpt("我立马动身。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("这可都是我的宝贝啊！谢谢你了！ ");
		AddOpt("太客气了。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_21016(nTaskId, nAction)
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

---支线任务17（黄泉宗）---

function TASK_FUNCTION_21017(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("跟你说个秘密吧，掌门和妖皇是老冤家，你要是能破了妖皇的分身，掌门肯定会对你刮目相看的！");
		AddOpt("哦？还有这种事，那我去试试。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("哈哈，我没骗你吧！ ");
		AddOpt("姑娘帮大忙了。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_21017(nTaskId, nAction)
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

---支线任务18（黄泉宗）---

function TASK_FUNCTION_21018(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("你最近声名鹊起，却也惹来不少同门的羡慕嫉妒恨。貌似还有些人不服气啊，你说该如何呢？");
		AddOpt("我会让他们服气的……", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("呵呵，这下很多人都对你服气了。 ");
		AddOpt("定叫他们不得小瞧于我。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_21018(nTaskId, nAction)
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

---支线任务19（黄泉宗）---

function TASK_FUNCTION_21019(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("昨日有弟子看见天魔战场上出现了成群的幽芒蝰蛇，这蛇群要是发起攻击来可是不得了啊！");
		AddOpt("不必担心，我去把它们剿杀了就是。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("竟然有这么多，还好你及时将它们斩杀了。 ");
		AddOpt("此乃在下本分。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_21019(nTaskId, nAction)
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

---支线任务20（黄泉宗）---

function TASK_FUNCTION_21020(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("近日，出去采集仙草的弟子多被赤头飞蛮击伤，实在是可恶啊！你去把那些赤头飞蛮都铲除了吧！");
		AddOpt("好的。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("这下采药弟子们安全多了。 ");
		AddOpt("还要小心才是。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_21020(nTaskId, nAction)
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

---支线任务21（黄泉宗）---

function TASK_FUNCTION_21021(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("我看见摄魄天魔了，它到处摄人心魄好可怕啊……");
		AddOpt("我不会让这些该死的妖孽继续作祟的。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("还好你把它们铲除了，真是吓死人了。 ");
		AddOpt("姑娘不必多礼。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_21021(nTaskId, nAction)
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

---支线任务22（黄泉宗）---

function TASK_FUNCTION_21022(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("我的麒麟坐骑被狰狞天魔吃了，真是气煞我也，我要将它碎尸万段……");
		AddOpt("你且息怒，我愿代为前往。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("总算是消了我的心头之恨…… ");
		AddOpt("日后请多加小心。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_21022(nTaskId, nAction)
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

---支线任务23（黄泉宗）---

function TASK_FUNCTION_21023(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("我感觉这段日子元气损耗严重，运功时内力不足，这必定是天神幻影暗中吸走了天地之间的元气。");
		AddOpt("我要它们把元气都吐回来。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("现在元气充沛了！ ");
		AddOpt("如此甚好。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_21023(nTaskId, nAction)
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

---支线任务24（黄泉宗）---

function TASK_FUNCTION_21024(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("我的金碧大丹就要炼成了，只是还差婆娑念珠作为引子，不知你能否为我弄些来？");
		AddOpt("我立马动身。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("哈哈，看来我的金碧大丹指日可成了。 ");
		AddOpt("如此甚好。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_21024(nTaskId, nAction)
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

---支线任务25（黄泉宗）---

function TASK_FUNCTION_21025(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("听说最近门派中经常有弟子被拳霸幻影所伤，长老们正为此事头疼呢。");
		AddOpt("我去杀了拳霸幻影，长老们就不必头疼了吧。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("做得很好，长老们都夸你呢！ ");
		AddOpt("长老们过奖了。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_21025(nTaskId, nAction)
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

---支线任务26（黄泉宗）---

function TASK_FUNCTION_21026(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("我炼制的天魔丹，可以使那些天魔改邪归正，不过需要加入天魔印记，再炼上七七四十九天才行，你为我收集些天魔印记来吧。");
		AddOpt("好的，我这就去。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("太好了，有了这些天魔印记，我的天魔丹成矣！ ");
		AddOpt("恭喜长老。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_21026(nTaskId, nAction)
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

---支线任务27---

function TASK_FUNCTION_20027(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("蓝月城盛产皇帝土皇珠，这可是价值连城的宝贝啊，快去收集些来吧！");
		AddOpt("好的！", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("哈哈，好多的皇帝土黄珠啊，发财了，发财了！ ");
		AddOpt("在下告辞。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_20027(nTaskId, nAction)
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

---支线任务28---

function TASK_FUNCTION_20028(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("这沙漠中有一群游荡沙匪专干杀人掠货的勾当，你看那路边的森森白骨，真让人毛骨悚然！");
		AddOpt("嗯！不能再让他们危害人间了……", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("都把他们解决了？这下好了，以后经过这里就安全多了！ ");
		AddOpt("如此甚好。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_20028(nTaskId, nAction)
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

---支线任务29---

function TASK_FUNCTION_20029(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("你虽然破了‘星月神话’，可是它们的余孽尚存，只怕春风吹又生啊！");
		AddOpt("那我这就去斩草除根！", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("这下不必担心它们卷土重来了！ ");
		AddOpt("本该如此。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_20029(nTaskId, nAction)
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

---支线任务30---

function TASK_FUNCTION_20030(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("那无底深渊里有深渊血蟒，好大好大，我这辈子最怕蛇了……");
		AddOpt("那我去把它除掉好了！", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("这下放心多了，但愿不要再有第二条！ ");
		AddOpt("姑娘放心。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_20030(nTaskId, nAction)
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

---支线任务31---

function TASK_FUNCTION_20031(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("那群可恶的冥煞狂熊，除了为非作歹还是为非作歹，可恶可恶！");
		AddOpt("我这就去教训它们！", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("哈哈，看它们以后怎么为非作歹了！ ");
		AddOpt("必须有一杀一。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_20031(nTaskId, nAction)
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

---支线任务32---

function TASK_FUNCTION_20032(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("这蓝月城地底下是不是有东西啊啊？总感觉地下有异动，不会是有妖怪吧？");
		AddOpt("我去看看好了！", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("原来是这些嗜杀蜂妖啊，太吓人了，还好你把它除了！ ");
		AddOpt("过奖了。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_20032(nTaskId, nAction)
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

---支线任务33---

function TASK_FUNCTION_20033(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("最近出了一个妖团，叫什么‘狂煞一族’，甚是嚣张。唉，以后日子难过了！");
		AddOpt("我倒要看看它们能嚣张到几时！", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("这么快就把它们剿灭啦？‘狂煞一族’的名字叫得那么响，原来那么不经打啊！ ");
		AddOpt("哈哈，确是如此。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_20033(nTaskId, nAction)
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

---支线任务34---

function TASK_FUNCTION_20034(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("我看见狂煞巫妖了，它来干什么？难道是来给‘狂煞一族’报仇的么？");
		AddOpt("来了又能怎样，我还怕它不成！", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("看来这狂煞巫妖不是来报仇的，而是来送死的…… ");
		AddOpt("哈哈，确是如此。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_20034(nTaskId, nAction)
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

---支线任务35---

function TASK_FUNCTION_20035(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("这段时日，守护祭坛的修罗们不知为何常冒出地面来，弄得大家都很恐慌！");
		AddOpt("大家无需恐慌，我去消灭它们就是。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("消灭了这群修罗，大家现在安心多了！ ");
		AddOpt("此事已了，在下告辞。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_20035(nTaskId, nAction)
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

---支线任务36---

function TASK_FUNCTION_20036(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("我看见好多修罗，成群结队的，难道修罗界发生了什么大事不成？");
		AddOpt("我也不甚清楚，探探便知了！", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("什么也没探听到吗？这就奇怪了！ ");
		AddOpt("还要多加小心。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_20036(nTaskId, nAction)
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

---支线任务37---

function TASK_FUNCTION_20037(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("深渊祭坛乃是血云地脉的所在，你快去收集血珊瑚吧，多多益善啊！");
		AddOpt("好的。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("这么多血珊瑚啊，不错不错！ ");
		AddOpt("过奖了。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_20037(nTaskId, nAction)
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

---支线任务38---

function TASK_FUNCTION_20038(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("这蓝月城怎么会这么凶险？连深渊屠戮者都有，你快去把它们消灭了吧！");
		AddOpt("我去去就回！", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("你真是好生了得，一下就消灭了这么多啊！ ");
		AddOpt("此乃在下本分。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_20038(nTaskId, nAction)
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

---支线任务39---

function TASK_FUNCTION_20039(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("刚才遮云蔽日地来了一群深渊霸王，屠戮了不少生灵，实在是太残忍了！");
		AddOpt("可恶，看我如何收拾它们！", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("总算是为那些冤死的生灵报仇了！ ");
		AddOpt("此乃在下本分。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_20039(nTaskId, nAction)
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

---支线任务40---

function TASK_FUNCTION_20040(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("比武大会开始了，你只有多杀妖魔鬼怪才能展现你们的门派实力！");
		AddOpt("这个我知道，就看我的吧！", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("呵呵，大家都看到你的实力了！ ");
		AddOpt("必当再接再厉。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_20040(nTaskId, nAction)
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

---支线任务41---

function TASK_FUNCTION_20041(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("这里的海蚺汲取了万归仙岛的仙灵之气，用来淬炼元气的纯度再好不过了！");
		AddOpt("那我这就去淬炼！", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("你的元气更加纯粹了！ ");
		AddOpt("如此甚好。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_20041(nTaskId, nAction)
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

---支线任务42---

function TASK_FUNCTION_20042(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("这万归仙岛的乃是黑水蛇族的老巢，想必各类黑水蛇妖都有，你速速去清除它们！");
		AddOpt("好的！", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("竟然有这么多，多得出乎我的意料了！ ");
		AddOpt("定当早日清楚它们。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_20042(nTaskId, nAction)
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

---支线任务43---

function TASK_FUNCTION_20043(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("那黑水蛇族也不是好惹的，你杀了那么多它们的族类，可要提防它们的报复！");
		AddOpt("我倒要看看它们能奈我何！", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("看来以你的修为确实可以不用怕它们！ ");
		AddOpt("必叫它们有来无回。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_20043(nTaskId, nAction)
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

---支线任务44---

function TASK_FUNCTION_20044(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("这万归仙岛根本就是个蛇岛，竟然连神蛇都出现了！这怎么了得，怎么了得啊！");
		AddOpt("莫慌，我去铲除它们便是了！", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("还好有你在！ ");
		AddOpt("此乃在下本分。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_20044(nTaskId, nAction)
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

---支线任务45---

function TASK_FUNCTION_20045(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("这里的蛇妖都修炼到神蛇的境界，再修炼下去就是条条蛟龙，只怕又是一个邪恶异族的崛起啊，人间怕是要生灵涂炭了！");
		AddOpt("我不会让这种事情发生的！", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("你一举铲除了这么多妖孽，相当于挽救了多少生灵啊？ ");
		AddOpt("此乃在下本分。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_20045(nTaskId, nAction)
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

---支线任务46---

function TASK_FUNCTION_20046(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("这里的海妖巡守实在凶残，多少出海之人死于它们的妖法之下，你去铲除它们吧！");
		AddOpt("这个当然，我这就去！", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("以后出海就安全多了！ ");
		AddOpt("还需多加小心。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_20046(nTaskId, nAction)
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

---支线任务47---

function TASK_FUNCTION_20047(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("原来有海妖守卫在这里，难怪那群小海妖敢如此肆无忌惮，到处为非作歹！");
		AddOpt("看我不收拾光它们。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("天哪，实在是太多了！ ");
		AddOpt("在下必定将其斩尽杀绝。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_20047(nTaskId, nAction)
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

---支线任务48---

function TASK_FUNCTION_20048(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("当年我叔叔出海一去不归，就是被那海妖猛士所害，我与它们不共戴天……");
		AddOpt("你放心好了，这个仇我会替你报的！", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("谢谢你为我报了仇！ ");
		AddOpt("是可忍孰不可忍？", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_20048(nTaskId, nAction)
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

---支线任务49---

function TASK_FUNCTION_20049(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("我看见成群的海妖巫师，它们可是海妖里的护法啊，难道有大人物要来临了吗？");
		AddOpt("来得正好，我正要去找它们呢！", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("你杀了这么多海妖护法巫师，恐怕会触怒海妖大族啊！ ");
		AddOpt("不必担心。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_20049(nTaskId, nAction)
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

---支线任务50---

function TASK_FUNCTION_20050(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("大事不妙了，海妖族中的海妖侍卫都出现了，想必一场屠杀在所难免，我看你还是先走好了！");
		AddOpt("不必惊慌，它们不是我的对手！", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("难怪你不怕，原来你已经强大到这个地步了！ ");
		AddOpt("老板过奖了。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_20050(nTaskId, nAction)
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

---支线任务51---

function TASK_FUNCTION_20051(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("这海妖精英确实厉害，连伤几大门派的弟子，实在是有辱我修道门派的威严啊！");
		AddOpt("我这就去讨回这份威严！", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("多亏有你，总算是为修道门派挽回了面子！ ");
		AddOpt("怎可让其小瞧我们？", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_20051(nTaskId, nAction)
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

---支线任务52---

function TASK_FUNCTION_20052(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("万归宗弟子的行径实在是有辱修道准则，你速去教训教训他们！");
		AddOpt("我正有此意！", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("但愿它们能改邪归正！ ");
		AddOpt("如此甚好。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_20052(nTaskId, nAction)
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

---支线任务53---

function TASK_FUNCTION_20053(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("那万归剑使实在可恶，竟敢打伤其他门派弟子，实在有违修道门规，你去让他收敛点！");
		AddOpt("是！", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("希望他能记住这次教训！ ");
		AddOpt("但来无妨。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_20053(nTaskId, nAction)
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

---支线任务54---

function TASK_FUNCTION_20054(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("这万归道长是疯了么？各门派弟子的受伤事件都系于他们所为，这次一定要讨个说法！");
		AddOpt("是应该讨回公道！", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("看他们还有什么话说！ ");
		AddOpt("总算是出了一口恶气。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_20054(nTaskId, nAction)
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

---支线任务55---

function TASK_FUNCTION_20055(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("万归长老竟然与妖孽同伙，难怪会坏了心性，你速去除了这修道界的大害！");
		AddOpt("是！", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("这个修道界的败类，真是死有余辜！ ");
		AddOpt("确是如此。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_20055(nTaskId, nAction)
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

---支线任务56---

function TASK_FUNCTION_20056(nTaskId)
	local taskState		= GetTaskState(nTaskId);
	_G.LogInfo("[%d]", taskState);
	if SM_TASK_STATE.STATE_AVAILABLE == taskState or 
	   SM_TASK_STATE.STATE_NONE == taskState then
		--未接
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("这万归仙岛道妖不分，已经乱了正统，有必要重整秩序。如今各门派都在出力，你也该去帮忙啊！");
		AddOpt("我立刻就去。", 1);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == taskState then
		--任务已接未完成
	elseif SM_TASK_STATE.STATE_COMPLETE == taskState then
		--任务已接已完成
		OpenTaskDlg(nTaskId);
		--SetTitle("");
		SetContent("道就是道，妖终究是妖…… ");
		AddOpt("对妖不可手软。", 2);	
		return true;
	end
	
	local ret = TASK_FUNCTION_COMMON(nTaskId);
	return true;
end 

function TASK_OPTION_20056(nTaskId, nAction)
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
