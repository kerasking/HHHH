--ui事件类型定义
NUIEventType = 
{
	TE_NONE = 0,
	
	-- 按钮事件
	TE_TOUCH_BTN_CLICK = 1,
	
	TE_TOUCH_BTN_DRAG_OUT = 2,
	
	TE_TOUCH_BTN_DRAG_OUT_COMPLETE = 3,
	
	TE_TOUCH_BTN_DRAG_IN = 4,
	
	-- 滚动层某个视图跑到容器起始处(参数为视图索引)
	TE_TOUCH_SC_VIEW_IN_BEGIN = 5,
	
	-- checkbox状态发生改变
	TE_TOUCH_CHECK_CLICK = 6,
	
	-- RadioGroup选项发生改变
	TE_TOUCH_RADIO_GROUP = 7,
	
	-- edit事件
	-- 用户按下键盘的返回键
	TE_TOUCH_EDIT_RETURN = 8,
	-- edit中的文本变更
	TE_TOUCH_EDIT_TEXT_CHANGE = 9,
    TE_TOUCH_EDIT_INPUT_FINISH =10,
	
	--按钮双击
	TE_TOUCH_BTN_DOUBLE_CLICK = 11,
    TE_TOUCH_SC_VIEW_IN_END = 14,
};

UIScrollStyle =
{
	Horzontal = 0,
	Verical = 1,
};

--文本对齐方式
UITextAlignment =
{
	Left = 0,		--左对齐
	Center = 1,		--居中
	Right = 2,		--右对齐
    LeftRCenter = 3,
};
--z轴层级
UILayerZOrder = 
{
    NormalLayer = 10;
    ChatBtn = 9;
    ActivityLayer = 5;
}


-- 脚本创建的每一个场景都需要在这边定义一个tag,不允许重复
local NUISCENETAG_BEGIN = 1000;
NSCENETAG =
{
};

local NUITAG_BEGIN	= 2000;
local NDLGTAG_BEGIN = 5000;
local NDLGTAGNEW_BEGIN = 65536;
NMAINSCENECHILDTAG =
{
	BottomSpeedBar			= NUITAG_BEGIN + 1,					-- 底部快捷栏
	PlayerAttr				= NUITAG_BEGIN + 2,					-- 玩家属性界面
	PlayerTask				= NUITAG_BEGIN + 3,					-- 玩家任务界面
	PlayerBackBag			= NUITAG_BEGIN + 4,					-- 玩家背包界面
	RoleInvite				= NUITAG_BEGIN + 5,					-- 伙伴邀请界面
	RoleInherit				= NUITAG_BEGIN + 6,					-- 伙伴传承界面
	PlayerMagic				= NUITAG_BEGIN + 7,					-- 奇术
	PlayerMartial			= NUITAG_BEGIN + 8,					-- 布阵
	PlayerRealize			= NUITAG_BEGIN + 9,					-- 悟道购买界面

	AffixNormalBoss			= NUITAG_BEGIN + 10,					-- 普通副本
	AffixBossClearUp		= NUITAG_BEGIN + 11,					-- 清剿普通
	AffixBossClearUpElite	= NUITAG_BEGIN + 12,					-- 清剿精英

	bossUI					= NUITAG_BEGIN + 13,					-- BOSS战界面
	bossRankUI				= NUITAG_BEGIN + 14,					-- BOSS战排行界面
	Arena					= NUITAG_BEGIN + 15,					-- 排行榜界面
	RoleTrain				= NUITAG_BEGIN + 16,					-- 培养
	TopSpeedBar				= NUITAG_BEGIN + 17,					-- 右上部活动快捷栏
	ArenaRank				= NUITAG_BEGIN + 18,					--竞技场界面
	ActivityMix				= NUITAG_BEGIN + 19,					--活动界面
	WorldMapBtn				= NUITAG_BEGIN + 20,					--世界地图入口按钮
	WorldMap				= NUITAG_BEGIN + 21,					--世界地图	
	AffixEliteBoss			= NUITAG_BEGIN + 22,					-- 精英副本
	RealizeBag				= NUITAG_BEGIN + 23,					-- 悟道背包
	RealizeShop				= NUITAG_BEGIN + 24,					-- 悟道商店
	PlayerEquipUpStepUI			= NUITAG_BEGIN + 25,					-- 升阶
	UserStateList		    = NUITAG_BEGIN + 26,					-- 状态列表
	PlayerEquipGlidUI		= NUITAG_BEGIN + 27,					-- 神铸界面
	HeroStarUI              = NUITAG_BEGIN + 28,                    --将星图
	MonsterReward			= NUITAG_BEGIN + 33,					-- 怪物战奖励界面
	UserStateUI             = NUITAG_BEGIN + 34,                    --状态信息界面
	DynMapGuide				= NUITAG_BEGIN + 35,					--副本攻略界面
	BattleFail				= NUITAG_BEGIN + 36,					--战斗失败界面
	DynMapToolBar			= NUITAG_BEGIN + 37,					--副本工具栏
	

	TASKUISELCAMP			= NUITAG_BEGIN + 38,                    --选择阵营界面
	
	EmailList               = NUITAG_BEGIN + 39,                    --邮件列表
	PlayerUIPill            = NUITAG_BEGIN + 40,                    --丹药界面
	ArenaRewardUI			=NUITAG_BEGIN + 41,						--竞技场战斗奖励
	FighterInfo				=NUITAG_BEGIN + 42,						--战斗角色信息
	ChatMainUI				=NUITAG_BEGIN + 43,						--聊天窗口
	ChatMainBar				=NUITAG_BEGIN + 44,						--聊天频道栏
	MilOrdersBtn			=NUITAG_BEGIN + 45,						--购买军令按钮
	MilOrdersDisPTxt			=NUITAG_BEGIN + 46,					--军令显示
	PlayerVIPUI				= NUITAG_BEGIN + 47,					--vip界面
    
    TestDelPlayer           = NUITAG_BEGIN + 48,					--删除玩家测试按钮
    ChatSmallUI				= NUITAG_BEGIN + 49,					--迷你聊天窗口
    ChatFaceUI				= NUITAG_BEGIN + 50,					--
    ChatItemUI				= NUITAG_BEGIN + 51,					--
    ChatFriendUI			= NUITAG_BEGIN + 52,					--
    ChatPrivateUI			= NUITAG_BEGIN + 53,					--私聊
    ChatGameScene			= NUITAG_BEGIN + 54,					--主界面聊天框
    GMProblemUI				= NUITAG_BEGIN + 55,					--提交gm问题界面
    
    
    Login_ServerUI          = NUITAG_BEGIN + 68,                    --服务器选择界面
    Login_RegRoleUI         = NUITAG_BEGIN + 69,                    --角色创建
    Login_AccountUI         = NUITAG_BEGIN + 70,                    --帐号输入登陆界面
    Login_ServerAndAccountUI= NUITAG_BEGIN + 71,                    --帐号和服务器选择界面
    Login_LoadingUI         = NUITAG_BEGIN + 72,                    --加载进度界面
    Login_MainUI            = NUITAG_BEGIN + 73,                    --登陆主界面
	Login_Choose            = NUITAG_BEGIN + 74,                    --选择登陆模式
    
    EquipStr                = NUITAG_BEGIN + 90,                    --装备强化界面
	
	GiveFlowers             = NUITAG_BEGIN + 91,                    --赠送鲜花界面
	FlowersRank             = NUITAG_BEGIN + 92,                    --鲜花榜界面
	FriendAttr              = NUITAG_BEGIN + 93,                    --查看资料界面

	Friend                  = NUITAG_BEGIN + 94,                    --好友界面
	FriendContext           = NUITAG_BEGIN + 95,                    --好友菜单界面

	AffixBossBattleRaiseDlg	= NUITAG_BEGIN + 100,					-- 通关评价界面
	AffixBossBoxDlg			= NUITAG_BEGIN + 101,					-- 宝箱
	
	PlayerNimbusUI          = NUITAG_BEGIN + 102,                   --玩家器灵界面
   	PetUI                   = NUITAG_BEGIN + 103,                   --玩家宠物界面
    RankUI                  = NUITAG_BEGIN + 104,                   --军衔界面
	ShopScretUI             = NUITAG_BEGIN + 105,                   --神秘商人
   -- MainUI                  = NUITAG_BEGIN + 106,                   --主城UI
    MainUITop 				= NUITAG_BEGIN + 106,                   --主城UI
    EquipUI 				= NUITAG_BEGIN + 107,                   --装备养成
    PlayerGiftBagUI         = NUITAG_BEGIN + 108,                   --礼包
    GameAssistantUI         = NUITAG_BEGIN + 109,                   --助手
    ArenaFightReplayUI       = NUITAG_BEGIN + 110,                   --战斗查看以及副本攻略结果界面
    DragonTactic                   = NUITAG_BEGIN + 111,                   --龙将兵法界面
    BattleMapCtrl                   = NUITAG_BEGIN + 112,                   --战斗界面的控件处理层
    DailyCheckIn                    = NUITAG_BEGIN + 113,                   --每日签到处理层   
    RechargeReward              = NUITAG_BEGIN + 114,                   --充值奖励处理层       
    DailyActionUI                    = NUITAG_BEGIN + 115,                   --每日活动处理层         
    --TransportUI                           = NUITAG_BEGIN + 116,                   --运送粮草处理层   
    TransportUI                           = 2015,                   --运送粮草处理层         
    TransportPrepareUI              = NUITAG_BEGIN + 117,                   --运送粮草准备处理层
    TransportLootUI                   = NUITAG_BEGIN + 118,                   --运送粮草准备处理层       
    BattleBossUI                    = 2015,--NUITAG_BEGIN + 119,   
    TransPlayerListUI                    = NUITAG_BEGIN + 120,                  --运送粮草玩家列表     
    
    TopBar                  = NUITAG_BEGIN + 158,
    BottomMsgBtn               = NUITAG_BEGIN + 159,
    BottomFind              = NUITAG_BEGIN + 160,
    BottomMsg              = NUITAG_BEGIN + 161,
    RaidersLoad             = NUITAG_BEGIN + 162,                   --查看攻略结束后弹出框
    BottomControlBtn        = NUITAG_BEGIN + 163,
    EffectAniLayer			= NUITAG_BEGIN + 164,					-- 播放特效动画层--Z-Order=NDLGTAGNEW_BEGIN+1
    GameSetting				= NUITAG_BEGIN + 165,					-- 游戏设置
    Agiotage				= NUITAG_BEGIN + 166,					-- 兑换界面
    Update					= NUITAG_BEGIN + 167,					-- 更新界面
    Levy                    = NUITAG_BEGIN + 168,                   --征收
    Fete                    = NUITAG_BEGIN + 169,                   --祭祀
    Entry					= NUITAG_BEGIN + 170,					-- 入口界面
    GMProblemBtn            = NUITAG_BEGIN + 171,
    OLGiftBtn               = NUITAG_BEGIN + 172,                   --在线奖励活动
    RechargeGiftBtn               = NUITAG_BEGIN + 173,                   --充值奖励活动
    ArmyGroup				= NUITAG_BEGIN + 174,					-- 军团界面
    CreateOrJoinArmyGroup	= NUITAG_BEGIN + 175,					-- 创建或加入军团界面(含军团列表)
	ActivityNoticeUI		= NUITAG_BEGIN + 176,					-- 活动公告界面--
    LoginListUI          = NUITAG_BEGIN + 177,                    --登入等待界面
    MainPlayerListUI        = NUITAG_BEGIN + 178,                   --主城查看其它玩家
    Banquet					= NUITAG_BEGIN + 179,                    --宴会界面
    BattleUI_Title			= NUITAG_BEGIN + 180,                    --战斗TITLE界面
 	QuickSwapEquipUI        = NUITAG_BEGIN + 181,                   --快速换装备
    CampBattle              = 2015,                   --阵营战
     	
 	SyndicateBattleUI         =  2015,                   --军团战ui
 	SyndicateBattleSignUpUI           =  NUITAG_BEGIN + 180,                  --军团战报名ui
 	SyndicateBattleResultUI           =  NUITAG_BEGIN + 181,                   --军团战进程ui

	LuckyBox							= NUITAG_BEGIN + 185,		-- 幸运宝箱
	TreasureHunt						= 2015,--NUITAG_BEGIN + 183,		-- 古迹寻宝
 	

 	PVPADDUI           =  NUITAG_BEGIN + 184,                   --PVP属性界面

 	DestinyUI               = NUITAG_BEGIN + 182,                   --占星
    DestinyFeteUI           = NUITAG_BEGIN + 183,                   --占星祭祀

	RankListUI              = NUITAG_BEGIN + 189,                   --名人堂
	SlaveUI					= 2015,                   --斗地主

    Buff           = NUITAG_BEGIN + 186,                   --玩家状态

    CommonDlg				= NDLGTAG_BEGIN,						--通用对话框
	CommonDlgNew              = NDLGTAGNEW_BEGIN,                     --新通用对话框
	--后面都被对话框占用了,请不要使用
};

local winsize = GetWinSize(); 
--RectUILayer = CGRectMake(winsize.w * (1 - 0.908333) / 2, winsize.h * (1 - 0.84065) / 2, winsize.w * 0.908333, winsize.h * 0.84065);
RectUILayer = CGRectMake(winsize.w * (1 - 0.954167) / 2, winsize.h * (1 - 0.8875) / 2, winsize.w * 0.954167, winsize.h * 0.8875);

RectFullScreenUILayer = CGRectMake(0, 0, winsize.w, winsize.h);

--缩放系数（基于480*320）
ScaleFactor = DefaultDirector():GetScaleFactor();
CoordScaleX = DefaultDirector():GetCoordScaleX()*2;
CoordScaleY = DefaultDirector():GetCoordScaleY()*2;


--缩放系数（基于960*640）
ScaleFactor_960 = DefaultDirector():GetScaleFactor()*0.5;
CoordScaleX_960 = DefaultDirector():GetCoordScaleX();
CoordScaleY_960 = DefaultDirector():GetCoordScaleY();
