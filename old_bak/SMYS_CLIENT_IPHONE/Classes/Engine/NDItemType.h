/*
 *  NDItemType.h
 *  DragonDrive
 *
 *  Created by wq on 11-1-5.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef __ND_ITEM_TYPE_H__
#define __ND_ITEM_TYPE_H__

#include "NDLocalization.h"
#include <string>
using namespace std;

enum ITME_TYPE {
	IT_RECOVER = 28000004,		// 自动恢复药
};

namespace NDEngine
{
	class NDItemType
	{
	public:
		NDItemType()
		{
			::memset(&m_data, 0L, sizeof(m_data));
		}
	public:
		enum  
		{
			PROFESSION_LEN = 4,
			MONOPOLY_LEN = 2,
		};
		/** 0=不显示该项，1=限战士使用，2=限法师使用，3=限盗贼使用，显示格式为：“（限战士使用） */
		static std::string PROFESSION[PROFESSION_LEN];
		
		static std::string MONOPOLY[MONOPOLY_LEN];
		
		static int PINZHI_LEN()
		{
			return 10;
		}
		static std::string PINZHI(int i)
		{
			std::string res = "";
			switch (i) {
				case 0:
					res = NDCommonCString("chuchao");
					break;
				case 1:
					res = NDCommonCString("chuchao");
					break;
				case 2:
					res = NDCommonCString("chuchao");
					break;
				case 3:
					res = NDCommonCString("jiaocha");
					break;
				case 4:
					res = NDCommonCString("jiaocha");
					break;
				case 5:
					res = NDCommonCString("putong");
					break;
				case 6:
					res = NDCommonCString("jingzhi");
					break;
				case 7:
					res = NDCommonCString("xiyou");
					break;
				case 8:
					res = NDCommonCString("sishi");
					break;
				case 9:
					res = NDCommonCString("chuanshuo");
					break;
				default:
					break;
			}
			return res;
		}
		
		static int PETPINZHI_LEN()
		{
			return 10;
		}
		
		static std::string PETPINZHI(int i)
		{
			std::string res = "";
			switch (i) {
				case 0:
					res = NDCommonCString("chuchao");
					break;
				case 1:
					res = NDCommonCString("chuchao");
					break;
				case 2:
					res = NDCommonCString("chuchao");
					break;
				case 3:
					res = NDCommonCString("jiaocha");
					break;
				case 4:
					res = NDCommonCString("jiaocha");
					break;
				case 5:
					res = NDCommonCString("putong");
					break;
				case 6:
					res = NDCommonCString("youxiu");
					break;
				case 7:
					res = NDCommonCString("xiyou");
					break;
				case 8:
					res = NDCommonCString("wangmei");
					break;
				case 9:
					res = NDCommonCString("chuanshuo");
					break;
				default:
					break;
			}
			return res;
		}
		
		static std::string PETLEVEL(int i)
		{
			std::string res = "";
			switch (i) {
				case 0:
					res = NDCommonCString("putong");
					break;
				case 1:
					res = NDCommonCString("youxiu");
					break;
				case 2:
					res = NDCommonCString("xiyou");
					break;
				case 3:
					res = NDCommonCString("wangmei");
					break;
				case 4:
					res = NDCommonCString("chuanshuo");
					break;

			}
			return res;
		}
		
	static int getItemColor(int i);
	static std::string getItemStrColor(int i);
		
	public:
		struct {
			int m_id;
			Byte m_level;
			int m_req_profession;
			unsigned short m_req_level;
			unsigned short m_req_sex;
			unsigned short m_req_phy;
			unsigned short m_req_dex;
			unsigned short m_req_mag;
			unsigned short m_req_def;
			int m_price;
			int m_emoney;
			int m_save_time;
			unsigned short m_life;
			int m_mana;
			unsigned short m_amount_limit;
			unsigned short m_hard_hitrate;
			unsigned short m_mana_limit;
			unsigned short m_atk_point_add;	// 力量
			unsigned short m_def_point_add; // 体质
			unsigned short m_mag_point_add; // 智力
			unsigned short m_dex_point_add; // 敏捷
			unsigned short m_atk;
			unsigned short m_mag_atk;
			unsigned short m_def;
			unsigned short m_mag_def;
			unsigned short m_hitrate;
			unsigned short m_atk_speed;
			unsigned short m_dodge;
			unsigned short m_monopoly;
			int m_lookface;
			int m_iconIndex;
			Byte m_holeNum;
			unsigned int m_idUplev;
			int m_suitData;
			int m_enhancedId;
			int m_enhancedStatus;
			int m_recycle_time;
		} m_data;
		
		string m_name;
		string m_des;
	};
}

#endif