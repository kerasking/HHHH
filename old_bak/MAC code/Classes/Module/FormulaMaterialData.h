/*
 *  FormulaMaterialData.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-3-25.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _FORMULA_MATERIAL_DATA_H_
#define _FORMULA_MATERIAL_DATA_H_

#include <string>

class FormulaMaterialData 
{
	enum
	{
		GRADE_NO_DEFINE = 0, 
		GRADE_LOW = 1, 
		GRADE_MIDDLE = 2, 
		GRADE_HIGH = 3,
	};
	
public:
	FormulaMaterialData(int iid, int grade,int matID_1,int count1,int matID_2,int count2,int matID_3,int count3,int prodItem ,int money,int emoney,std::string sName,int iconIdx);
	
	void init(int grades,int matID_1,int count1,int matID_2,int count2,int matID_3,int count3,int prodItem,int money,int emoney,int iconIdx);
	
	int getSkillID();
	
	static bool isFormula(int formulaId);
	
	std::string getProductItemsName();
	
	void showDetailDialog();
	
	std::string getDetailDescription();
	
	public:
		int idFormula;//万位和十万位表示对应的技能id
		int itemType1, itemType2, itemType3;
		int itemCount1, itemCount2, itemCount3;
		std::string	itemName1, itemName2, itemName3, productItemName;
		std::string formulaName;
		int productItemType;
		
		int	grade;
		int need_Money,need_EMoney;
		int iconIndex;
};

#endif // _FORMULA_MATERIAL_DATA_H_
