/*
 *  SyndicateCommon.h
 *  DragonDrive
 *
 *  Created by wq on 11-4-1.
 *  Copyright 2011 (网龙)DeNA. All rights reserved.
 *
 */

#ifndef __SYNDICATE_COMMON_H__
#define __SYNDICATE_COMMON_H__

#include "define.h"
#include "basedefine.h"
#include <string>

using namespace std;

enum SYNDICATE_ACTION {
	APPLY_SYN = 0, // 申请加入帮派,需要尾随帮派id
	QUERY_APPLY_LIST = 1, // 查询审批列表,需要尾随页数
	APPROVE_ACCEPT = 2, // 审批通过, 尾随idUser+ TQMBStrUserName
	APPROVE_REFUSE = 3, // 审批拒绝, 尾随 idUser
	DONATE_MONEY = 4, // 捐钱,尾随 money(UINT)
	DEMISE_SYN = 5, // 禅让, 尾随新帮主id
	QUIT_SYN = 6, // 退出帮派
	MODIFY_SYN_ANNOUNCE = 7, // 修改帮派公告,尾随新公告,(副帮主以上操作)
	ELEVATE_MBR = 8, // 提拔成员,尾随被提拔人的id
	DEBASE_MBR = 9, // 贬低成员, 尾随被贬低人的id
	KICK_OUT_MBR = 10, // 开除帮众,(副帮主以上操作)
	DONATE_WOOD					= 11,		// 捐献木材, nVal
	DONATE_STONE				= 12,		// 捐献石料, nVal
	DONATE_PAINT				= 13,		// 捐献油漆, nVal
	DONATE_COAL					= 14,		// 捐献乌金, nVal
	DONATE_EMONEY				= 15,		// 捐献元宝, nVal
	
	ACT_APPLY_REG_SYN		= 16,		// 应征军团, idSyn
	ACT_QUERY_REG_SYN_LIST		= 17,		// 查询应征军团列表, btPage(从0开始)
	ACT_QUERY_REG_SYN_INFO		= 18,		// 查询应征军团信息, idSyn
	ACT_UPGRADE_SYN			= 19,		// 军团升级
	ACT_QUERY_SYN_UPGRADE_INFO	= 20,		// 查询军团升级信息
	ACT_QUERY_SYN_STORAGE		= 21,		// 查询军团仓库
	ACT_ASSIGN_MBR_RANK		= 22,		// 军团任职, idElevated, btNewRank
	ACT_RESIGN			= 23,		// 辞职
	ACT_DISMISS_SYN				= 24,		// 解散军团
	ACT_QUERY_OFFICER			= 25,		// 查询在职官员, btRank (除10)
	ACT_ELECTION				= 26,		// 竞选职位, btRank (具体值)
	ACT_QUERY_VOTE_LIST			= 27,		// 查询投票列表
	ACT_QUERY_VOTE_INFO			= 28,		// 查看投票详细信息, idVote
	ACT_CANCEL_VOTE				= 29,		// 取消投票, idVote
	ACT_VOTE_YES				= 30,		// 投赞成票, idVote
	ACT_VOTE_NO					= 31,		// 投反对票, idVote
};

enum SYNDICATE_ANSWER {
	APPROVE_ACCEPT_OK = 7, // 审批通过ok
	APPROVE_ACCEPT_FAIL = 8, // 审批通过失败
	APPROVE_REFUSE_OK = 10, // 审批拒绝ok
	QUIT_SYN_OK = 17, // 退出ok
	KICK_OUT_MBR_OK = 29, // 踢人成功
	ANS_REG_SYN_INFO		= 51,		// 应征军团信息, strTitle, strInfo
	ANS_SYN_UPGRADE_INFO	= 52,		// 军团升级信息, SYN_UP_INFO
	ANS_QUERY_SYN_STORAGE	= 53,		// 军团仓库, STORAGE_INFO
	ANS_SYN_PANEL_INFO		= 54,		// 查看本人军团信息, strInfo
	ANS_SYN_LIST_INFO		= 55,		// 军团排行中的军团信息, strTitle, strInfo
	ANS_QUERY_OFFICER		= 56,		// 下发在职官员列表, OFFICER_LIST
	ANS_QUERY_VOTE_LIST		= 57,		// 下发投票列表, VOTE_LIST
	ANS_QUERY_VOTE_INFO		= 58,		// 下发投票详细信息, VOTE_INFO
	ANS_UPDATE_SYN_MBR_RANK	= 59,		// 更新职位, btNewRank
};

enum SYN_QUERY {
	QUERY_SYN_PANEL_INFO = 0, // 查询帮派面板信息
	QUERY_SYN_TAXIS = 1, // 查询帮派排行榜
	QUERY_SYN_TAXIS_DETAIL = 2, // 查询帮派排行中的帮派信息
	QUERY_SYN_MBR = 3, // 查询帮派成员列表 (需要页数,类型BYTE)
	QUERY_SYN_ANNOUNCE = 4, // 查询帮派公告
	QUERY_SYN_INVITE = 5, // 查询邀请列表
	QUERY_SYN_LIST_EX = 6,
	QUERY_SYN_MBR_LIST_EX = 7, // 新的查询帮派某一页成员信息
};

enum SYN_INVITE {
	INVITE_ACCEPT_OK = 8, // 接受邀请,成功加入帮派,删除所有邀请记录
	INVITE_REFUSE_OK = 9, // 拒绝邀请成功,删除该邀请记录
	
	INVITE_USER = 100, // 邀请某个玩家
	INVITE_ACCEPT = 101, // 接受帮派邀请
	INVITE_REFUSE = 102, // 拒绝帮派邀请
};

enum SYNMBR_RANK {
	SYNRANK_NONE = -1,
	SYNRANK_MEMBER = 0,//普通军团成员
	//门主
	SYNRANK_MENZHU_SHENG = 11,//生门
	SYNRANK_MENZHU_SHANG = 12,//伤门
	SYNRANK_MENZHU_XIU = 13,//休门
	SYNRANK_MENZHU_DU = 14,//杜门
	SYNRANK_MENZHU_JING = 15,//景门
	SYNRANK_MENZHU_SI = 16,//死门
	SYNRANK_MENZHU_JING1 = 17,//惊门
	SYNRANK_MENZHU_KAI = 18,//开门
	//堂主
	SYNRANK_TANGZHU_TIANLONG = 51,//天龙
	SYNRANK_TANGZHU_QINGMU = 52,//青木
	SYNRANK_TANGZHU_CHIHUO = 53,//赤火
	SYNRANK_TANGZHU_XIJIN = 54,//西金
	SYNRANK_TANGZHU_XUANSHUI = 55,//玄水
	SYNRANK_TANGZHU_HUANGTU = 56,//黄土
	//元老
	SYNRANK_YUANLAO_XUANWU = 101,//玄武
	SYNRANK_YUANLAO_QINGLONG = 102,//青龙
	SYNRANK_YUANLAO_BAIHU = 103,//白虎
	SYNRANK_YUANLAO_ZHUQUE = 104,//朱雀
	//团长
	SYNRANK_VICE_LEADER = 111,//副团长
	SYNRANK_LEADER = 121,//团长
};

enum {
	ONE_PAGE_COUNT = 10,
};

void queryCreatedInSynList(Byte queryPage);

void sendQueryTaxis(Byte queryPage);

void sendQueryAllSynList(Byte queryPage);

void sendApply(int synId);

void sendQueryTaxisDetail(int synId);

void sendQueryInviteList();

void sendInviteResult(Byte state, int synId);

void sendSynElection(Byte msgAction, Byte btNewRank);

void sendQuerySynNormalInfo(Byte msgAction);

void sendSynVoteComm(Byte msgAction,int idVote);

void sendQueryAnnounce();

void sendModifyNote(const std::string& str);

void sendQueryPanelInfo();

void sendContributeSyn(Byte msgAction,int value);

void sendUpGradeSyn();

void sendInviteOther(const std::string& name);

void sendQueryApprove(int queryPage);

void sendApproveAccept(int roleId, const std::string& name);

void sendApproveRefuse(int roleId);

void sendQueryMembers(int queryPage);

void sendAssignMbrRank(int roleId, int btNewRank, int curPage);

void sendKickOut(int roleId,int curPage);

void sendLeaveDemise(int roleId,int curPage);

void sendSynDonate(int uMoney, int uEmoney, int uWood, int uStone, int uCoal, int uPaint);

std::string getCampName(int type);

std::string getRankStr(int rank);

#endif