/*
 *  SyndicateCommon.mm
 *  DragonDrive
 *
 *  Created by wq on 11-4-1.
 *  Copyright 2011 (网龙)DeNA. All rights reserved.
 *
 */

#include "SyndicateCommon.h"
#include "NDUISynLayer.h"
#include "NDTransData.h"
#include "NDMsgDefine.h"
#include "EnumDef.h"
#include "NDConstant.h"
#include "NDLocalization.h"

using namespace NDEngine;

void queryCreatedInSynList(Byte queryPage) { // 查询创建中的帮派列表，应征
	ShowProgressBar;
	NDTransData bao(_MSG_SYNDICATE);
	bao << Byte(ACT_QUERY_REG_SYN_LIST) << (queryPage);
	// SEND_DATA(bao);
}

void sendQueryTaxis(Byte queryPage) { // 查询帮派排行榜
	ShowProgressBar;
	NDTransData bao(_MSG_SYN_QUERY);
	bao << Byte(QUERY_SYN_TAXIS) << queryPage;
	// SEND_DATA(bao);
}

void sendQueryAllSynList(Byte queryPage) { // 查询帮派排行榜
	ShowProgressBar;
	NDTransData bao(_MSG_SYN_QUERY);
	bao << Byte(QUERY_SYN_LIST_EX) << queryPage;
	// SEND_DATA(bao);
}

void sendApply(int synId) { // 申请加入某帮派
	ShowProgressBar;
	NDTransData bao(_MSG_SYNDICATE);
	bao << Byte(APPLY_SYN) << synId;
	// SEND_DATA(bao);
}

void sendQueryTaxisDetail(int synId) {// 查询帮派排行榜中的帮派信息 (特殊)
	ShowProgressBar;
	NDTransData bao(_MSG_SYN_QUERY);
	bao << Byte(QUERY_SYN_TAXIS_DETAIL) << synId;
	// SEND_DATA(bao);
}

void sendQueryInviteList() { // 查询受邀请列表
	ShowProgressBar;
	NDTransData bao(_MSG_SYN_QUERY);
	bao << Byte(QUERY_SYN_INVITE);
	// SEND_DATA(bao);
}

void sendInviteResult(Byte state, int synId) { // 发送接受邀请或者拒绝邀请结果
	//ShowProgressBar;
	NDTransData bao(_MSG_SYN_INVITE);
	bao << Byte(state) << synId;
	// SEND_DATA(bao);
}

void sendSynElection(Byte msgAction,Byte btNewRank) { // 竞选职位
	ShowProgressBar;
	NDTransData bao(_MSG_SYNDICATE);
	bao << msgAction << btNewRank;
	// SEND_DATA(bao);
}

void sendQuerySynNormalInfo(Byte msgAction) { // 军团通用消息，用于不需要带其他参数的消息
	ShowProgressBar;
	NDTransData bao(_MSG_SYNDICATE);
	bao << msgAction;
	// SEND_DATA(bao);
}

void sendSynVoteComm(Byte msgAction,int idVote) { // 投票相关操作
	if(msgAction == ACT_QUERY_VOTE_INFO){
		ShowProgressBar;
	}
	
	NDTransData bao(_MSG_SYNDICATE);
	bao << msgAction << idVote;
	// SEND_DATA(bao);
}

void sendQueryAnnounce() {// 查询军团公告
	ShowProgressBar;
	NDTransData bao(_MSG_SYN_QUERY);
	bao << Byte(QUERY_SYN_ANNOUNCE);
	// SEND_DATA(bao);
}

void sendModifyNote(const string& str) { // 副帮主以上级别修改公告
	ShowProgressBar;
	NDTransData bao(_MSG_SYNDICATE);
	bao << Byte(MODIFY_SYN_ANNOUNCE);
	bao.WriteUnicodeString(str);
	// SEND_DATA(bao);
}

void sendQueryPanelInfo() { // 查询帮派面板信息
	ShowProgressBar;
	NDTransData bao(_MSG_SYN_QUERY);
	bao << Byte(QUERY_SYN_PANEL_INFO);
	// SEND_DATA(bao);
}

void sendContributeSyn(Byte msgAction,int value) { //帮派捐献
	ShowProgressBar;
	NDTransData bao(_MSG_SYNDICATE);
	bao << msgAction << value;
	// SEND_DATA(bao);
}

void sendSynDonate(int uMoney, int uEmoney, int uWood, int uStone, int uCoal, int uPaint) {
	ShowProgressBar;
	NDTransData bao(_MSG_SYN_DONATE);
	bao << uMoney << uEmoney << uWood << uStone << uCoal << uPaint;
	// SEND_DATA(bao);
}

void sendUpGradeSyn() { // 军团升级
	ShowProgressBar;
	NDTransData bao(_MSG_SYNDICATE);
	bao << Byte(ACT_UPGRADE_SYN);
	// SEND_DATA(bao);
}

void sendInviteOther(const string& name) { // 邀请其他玩家加入帮派
	ShowProgressBar;
	NDTransData bao(_MSG_SYN_INVITE);
	bao << Byte(INVITE_USER);
	bao.WriteUnicodeString(name);
	// SEND_DATA(bao);
}

void sendQueryApprove(int queryPage) {// 查询待审批列表
	ShowProgressBar;
	NDTransData bao(_MSG_SYNDICATE);
	bao << Byte(QUERY_APPLY_LIST) << Byte(queryPage);
	// SEND_DATA(bao);
}

void sendApproveAccept(int roleId, const string& name) { // 审批通过
	ShowProgressBar;
	NDTransData bao(_MSG_SYNDICATE);
	bao << Byte(APPROVE_ACCEPT) << roleId;
	bao.WriteUnicodeString(name);
	// SEND_DATA(bao);
}

void sendApproveRefuse(int roleId) { // 审批拒绝
	ShowProgressBar;
	NDTransData bao(_MSG_SYNDICATE);
	bao << Byte(APPROVE_REFUSE) << roleId;
	// SEND_DATA(bao);
}

void sendQueryMembers(int queryPage) { // 查询帮派成员列表
	ShowProgressBar;
	NDTransData bao(_MSG_SYN_QUERY);
	bao << Byte(QUERY_SYN_MBR_LIST_EX) << Byte(queryPage);
	// SEND_DATA(bao);
}

void sendAssignMbrRank(int roleId,int btNewRank,int curPage) { // 军团成员任职
	ShowProgressBar;
	NDTransData bao(_MSG_SYNDICATE);
	bao << Byte(ACT_ASSIGN_MBR_RANK) << roleId
	<< Byte(btNewRank) << Byte(curPage);
	// SEND_DATA(bao);
}

void sendKickOut(int roleId,int curPage) { // 开除帮派成员
	ShowProgressBar;
	NDTransData bao(_MSG_SYNDICATE);
	bao << Byte(KICK_OUT_MBR) << roleId << Byte(curPage);
	// SEND_DATA(bao);
}

void sendLeaveDemise(int roleId,int curPage) { // 帮主禅让,尾随id
	ShowProgressBar;
	NDTransData bao(_MSG_SYNDICATE);
	bao << Byte(DEMISE_SYN) << roleId << Byte(curPage);
	// SEND_DATA(bao);
}

string getCampName(int type)
{
	switch (type) {
		case CAMP_TYPE_TANG:
			return CAMP_NAME_TANG;
		case CAMP_TYPE_SUI:
			return CAMP_NAME_SUI;
		case CAMP_TYPE_TU:
			return CAMP_NAME_TU;
		default:
			return CAMP_NAME_WU;
	}
}

string getRankStr(int rank) {
	switch (rank) {
		case SYNRANK_MEMBER: {
			return NDCommonCString("JunTuanMember");
		}
		case SYNRANK_MENZHU_SHENG: {
			return NDCommonCString("ShenMengMengZhu");
		}
		case SYNRANK_MENZHU_SHANG: {
			return NDCommonCString("ShangMengMengZhu");
		}
		case SYNRANK_MENZHU_XIU: {
			return NDCommonCString("XiuMengMengZhu");
		}
		case SYNRANK_MENZHU_DU: {
			return NDCommonCString("DuMengMengZhu");
		}
		case SYNRANK_MENZHU_JING: {
			return NDCommonCString("JingMengMengZhu");
		}
		case SYNRANK_MENZHU_SI: {
			return NDCommonCString("ShiMengMengZhu");
		}
		case SYNRANK_MENZHU_JING1: {
			return NDCommonCString("jinMengMengZhu");
		}
		case SYNRANK_MENZHU_KAI: {
			return NDCommonCString("KaiMengMengZhu");
		}
		case SYNRANK_TANGZHU_TIANLONG: {
			return NDCommonCString("TianLongTangZhu");
		}
		case SYNRANK_TANGZHU_QINGMU: {
			return NDCommonCString("QingMuTangZhu");
		}
		case SYNRANK_TANGZHU_CHIHUO: {
			return NDCommonCString("ChiHuoTangZhu");
		}
		case SYNRANK_TANGZHU_XIJIN: {
			return NDCommonCString("XiJingTangZhu");
		}
		case SYNRANK_TANGZHU_XUANSHUI: {
			return NDCommonCString("XuanShuiTangZhu");
		}
		case SYNRANK_TANGZHU_HUANGTU: {
			return NDCommonCString("HuanTuTangZhu");
		}
		case SYNRANK_YUANLAO_XUANWU: {
			return NDCommonCString("XuangWuYuanLao");
		}
		case SYNRANK_YUANLAO_QINGLONG: {
			return NDCommonCString("QingLongYuanLao");
		}
		case SYNRANK_YUANLAO_BAIHU: {
			return NDCommonCString("BaiHuYuanLao");
		}
		case SYNRANK_YUANLAO_ZHUQUE: {
			return NDCommonCString("ZhuQueYuanLao");
		}
		case SYNRANK_VICE_LEADER: {
			return NDCommonCString("FuTuanZhang");
		}
		case SYNRANK_LEADER: {
			return NDCommonCString("JunTuanZhang");
		}
		default: {
			return "";
		}
	}	
}