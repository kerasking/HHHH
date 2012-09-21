// ConverToMK.cpp : 定义控制台应用程序的入口点。
//

#include "stdafx.h"
#include "ConverToMK.h"
#include <iostream>

using namespace std;

int main(int argc, char** argv)
{
	options_description kOptions("Tool Options");
	CConverToMK* pkMK = CConverToMK::initWithIniFile("ConvertToMKConfig.xml");

	kOptions.add_options()("help","This is help")("XX","XXXX");
	variables_map kVM;
	store(parse_command_line(argc,argv,kOptions),kVM);

	if (kVM.count("help"))
	{
		cout << kOptions << endl;
	}
	else if (kVM.size() == 0)
	{
		cout << "没有相关命令" << endl;
	}

	pkMK->WriteToMKFile();

	getchar();

	return 0;
}