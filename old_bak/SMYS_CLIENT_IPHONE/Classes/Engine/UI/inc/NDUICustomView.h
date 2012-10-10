//
//  NDUICustomView.h
//  DragonDrive
//
//  Created by xiezhenghai on 11-2-22.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#ifndef __NDUICustomView_H
#define __NDUICustomView_H

#include "NDUINode.h"
#include <vector>
#include <string>

@class NDIphoneCustomView;

namespace NDEngine
{
	class NDUICustomView;
	//delegates begin
	class NDUICustomViewDelegate
	{
	public:
//		
//		函数：OnCustomViewConfirm
//		作用：当自定义视图按确认键返回时被框架内部调用
//		参数：customView自定义视图
//		返回值：true 关闭视图, false 不关闭
		virtual bool OnCustomViewConfirm(NDUICustomView* customView);
//		
//		函数：OnCustomViewCancle
//		作用：当自定义视图取消按返回键返回时被框架内部调用
//		参数：customView自定义视图
//		返回值：无
		virtual void OnCustomViewCancle(NDUICustomView* customView);
//		
//		函数：OnCustomViewOrtherButtonClick
//		作用：当自定义视图其他按钮被按下时被框架内部调用
//		参数：customView自定义视图，ortherButtonIndex按钮索引，ortherButtonTag按钮标识
//		返回值：无
		virtual void OnCustomViewOrtherButtonClick(NDUICustomView* customView, unsigned int ortherButtonIndex, int ortherButtonTag);
//		
//		函数：OnCustomViewRadioButtonSelected
//		作用：当自定义视图单选组建选择时被框架内部调用
//		参数：customView自定义视图，radioButtonIndex按钮索引，ortherButtonTag按钮标识
//		返回值：无
		virtual void OnCustomViewRadioButtonSelected(NDUICustomView* customView, unsigned int radioButtonIndex, int ortherButtonTag);
	};
	//delegates end
	
	class NDUICustomView : public NDUINode
	{
		DECLARE_CLASS(NDUICustomView)
		NDUICustomView();
		~NDUICustomView();
		
	public:	
//		
//		函数：SetEdit
//		作用：设置编辑框
//		参数：numbers编辑框数量，tags编辑框标识，titles编辑框标题；后两个容器的数量必须等于第一个参数的值
//		返回值：无
		void SetEdit(unsigned int numbers, const std::vector<int>& tags, const std::vector<std::string>& titles);
//		
//		函数：SetEditText
//		作用：设置编辑框文本内容
//		参数：text文本内容，editIndex编辑框索引
//		返回值：无
		void SetEditText(const char* text, unsigned int editIndex);
//		
//		函数：GetEditText
//		作用：获取编辑框文本内容
//		参数：editIndex编辑框索引
//		返回值：文本内容
		std::string GetEditText(unsigned int editIndex);
//		
//		函数：SetEditPassword
//		作用：设置编辑框是否密码方式显示
//		参数：password密码方式显示，editIndex编辑框索引
//		返回值：无
		void SetEditPassword(bool password, unsigned int editIndex);
//		
//		函数：EditIsPassword
//		作用：判断编辑框是否密码方式显示
//		参数：editIndex编辑框索引
//		返回值：true密码方式显示，否则不是
		bool EditIsPassword(unsigned int editIndex);
//		
//		函数：SetEditMaxLength
//		作用：设置编辑框最大输入字符数
//		参数：maxLength最大字符数，editIndex编辑框索引
//		返回值：无
		void SetEditMaxLength(unsigned int maxLength, unsigned int editIndex);
//		
//		函数：GetEditMaxLength
//		作用：获取编辑框最大输入字符数
//		参数：editIndex编辑框索引
//		返回值：允许最大输入的字符数
		unsigned int GetEditMaxLength(unsigned int editIndex);
//		
//		函数：SetEditMinLength
//		作用：设置编辑框最小输入字符数
//		参数：minLength最小输入字符数，editIndex编辑框索引
//		返回值：无
		void SetEditMinLength(unsigned int minLength, unsigned int editIndex);
//		
//		函数：GetEditMinLength
//		作用：获取编辑框的最小输入字符数
//		参数：editIndex编辑框索引
//		返回值：允许最小输入的字符数
		unsigned int GetEditMinLength(unsigned int editIndex);
//		
//		函数：SetRadioButton
//		作用：设置单选组件
//		参数：numbers编辑框数量，tags编辑框标识，titles编辑框标题；后两个容器的数量必须等于第一个参数的值
//		返回值：无	
		void SetRadioButton(unsigned int numbers, const std::vector<int>& tags, const std::vector<std::string>& titles);
		
		int GetActiveRadioButtonIndex();
		int GetActiveRadioButtonTag();
		void SetActiveRadioButtonWithIndex(unsigned int index);
		
//		
//		函数：SetButton
//		作用：设置按钮
//		参数：numbers编辑框数量，tags编辑框标识，titles编辑框标题；后两个容器的数量必须等于第一个参数的值
//		返回值：无
		void SetButton(unsigned int numbers, const std::vector<int>& tags, const std::vector<std::string>& titles);
//		
//		函数：Show
//		作用：显示自定义视图，调用该方法显示仍然需要显示调用Initialization()方法
//		参数：无
//		返回值：无
		void Show();
//		
//		函数：Hide
//		作用：隐藏自定义视图
//		参数：无
//		返回值：无
		void Hide();
		
		// 显示提示信息
		void ShowAlert(const char* pszAlert);
		
		void SetOkCancleButtonPosY(unsigned int y);
		
		void SetOkTitle(const char* text);
		
		void SetCancelTitle(const char* text);
	private:
		NDIphoneCustomView *m_iphoneCustomView;
		
		bool m_showed;

	};
}

#endif

