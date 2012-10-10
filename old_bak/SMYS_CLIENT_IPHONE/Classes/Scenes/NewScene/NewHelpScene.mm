/*
 *  NewHelpScene.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-9-6.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "NewHelpScene.h"
#include "NDUtility.h"
#include "NDDirector.h"
#include "NDPath.h"
#include "NDTextNode.h"
#include "JavaMethod.h"

IMPLEMENT_CLASS(HelpCell, NDPropCell)

HelpCell::HelpCell()
{
	m_pic = NULL;
}

HelpCell::~HelpCell()
{
	SAFE_DELETE(m_pic);
}

void HelpCell::Initialization()
{
	NDPropCell::Initialization(false, CGSizeMake(115, 23));
	
	m_pic = NDPicturePool::DefaultPool()->AddPicture(GetImgPathNew("farmrheadtitle.png"));
	
	this->SetKeyLeftDistance(4+m_pic->GetSize().width+4);
	
	this->SetFocusTextColor(ccc4(187, 19, 19, 255));
}

void HelpCell::draw()
{
	if (!this->IsVisibled()) return;
	
	NDPropCell::draw();
	
	NDPicture * pic = NULL;
	
	CGRect scrRect = this->GetScreenRect();
	
	NDNode *parent = this->GetParent();
	
	if (parent && parent->IsKindOfClass(RUNTIME_CLASS(NDUILayer)) && ((NDUILayer*)parent)->GetFocus() == this)
	{
		pic = m_picFocus;
	}
	else
	{
		pic = m_picBg;
	}
	
	if (!pic) return;
	
	if (!m_pic) return;
	
	CGSize sizePic = m_pic->GetSize();
	m_pic->DrawInRect(CGRectMake(scrRect.origin.x+4, 
								 scrRect.origin.y+(pic->GetSize().height-sizePic.height)/2, 
								 sizePic.width, sizePic.height));
}


enum 
{
	eHelpBegin = 0,
	eHelpIntroduce = eHelpBegin,
	eHelpMenuIntroduce,
	eHelpOperate,
	eHelpGameSetting,
	eHelpEnd,
};

IMPLEMENT_CLASS(NewHelpLayer, NDUILayer)

NewHelpLayer::NewHelpLayer()
{
}

NewHelpLayer::~NewHelpLayer()
{
}

void NewHelpLayer::Initialization(bool delayShow/*=false*/)
{
	NDUILayer::Initialization();
	
	LoadText();
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	NDPicturePool& pool = *(NDPicturePool::DefaultPool());
	
	int /*startX = 17,*/ startY = 50-37;
	
	NDUILayer *layerBg = new NDUILayer;
	layerBg->Initialization();
	layerBg->SetFrameRect(CGRectMake(0, startY, 325, 262));
	layerBg->SetBackgroundImage(pool.AddPicture(GetImgPathNew("bag_left_bg.png"), 321, 262), true);
	this->AddChild(layerBg);
	
	m_contentScroll = new NDUIContainerScrollLayer;
	m_contentScroll->Initialization();
	m_contentScroll->SetFrameRect(CGRectMake(0, 10, 317, 242));
	m_contentScroll->SetDelegate(this);
	m_contentScroll->SetBackgroundImage(pool.AddPicture(GetImgPathNew("attr_role_bg.png"), 317, 242), true);
	layerBg->AddChild(m_contentScroll);
	
	int height = 23*m_mapIndex.size()+4*(m_mapIndex.size()-1)+10;
	
	if (height > 245) {
		height = 245;
	}
	
	m_tl = new NDUITableLayer;
	m_tl->Initialization();
	m_tl->SetBackgroundColor(ccc4(0, 0, 0, 0));
	m_tl->VisibleSectionTitles(false);
	m_tl->SetFrameRect(CGRectMake(327, startY+16, 120, height));
	m_tl->VisibleScrollBar(false);
	m_tl->SetCellsInterval(4);
	m_tl->SetCellsRightDistance(0);
	m_tl->SetCellsLeftDistance(0);
	m_tl->SetDelegate(this);
	
	NDDataSource *dataSource = new NDDataSource;
	NDSection *section = new NDSection;
	section->UseCellHeight(true);
	
	/*
	const char* text[eHelpEnd] = 
	{
		"游戏介绍",
		"菜单说明",
		"操作说明",
		"游戏设置",
	};
	*/
	
	
	
	for_vec(m_mapIndex, map_index_help_data_it)
	{
		HelpCell  *prop = new HelpCell;
		prop->Initialization();
		prop->SetTag(it->first);
		if (prop->GetKeyText())
			prop->GetKeyText()->SetText(it->second.c_str());
		
		section->AddCell(prop);
	}
	
	if (!delayShow) 
	{
		if (section->Count() >= 2) 
		{
			section->SetFocusOnCell(1);
			
			map_help_data_it it = m_mapData.find(section->Cell(1)->GetTag());
			
			if (it != m_mapData.end())
			{
				refresh(it->second);
			}
		}
	}
	else 
	{
		m_timer.SetTimer(this, 1, 1.5f);
	}


	dataSource->AddSection(section);
	m_tl->SetDataSource(dataSource);
	this->AddChild(m_tl);
}

bool NewHelpLayer::OnLayerMove(NDUILayer* uiLayer, UILayerMove move, float distance)
{
	if (uiLayer == m_contentScroll)
		m_contentScroll->OnLayerMove(uiLayer, move, distance);
	
	return false;
}

void NewHelpLayer::SetContent(const char *text, ccColor4B color/*=ccc4(255, 0, 0, 255)*/, unsigned int fontsize/*=12*/)
{
	if (!m_contentScroll) return;
	
	m_contentScroll->RemoveAllChildren(true);
	
	if (!text) return;
	
	CGSize size = getStringSizeMutiLine(text, 12, CGSizeMake(m_contentScroll->GetFrameRect().size.width-4, 320));
	
	NDUILabel *lbContent = new NDUILabel;
	lbContent->Initialization();
	lbContent->SetTextAlignment(LabelTextAlignmentLeft);
	lbContent->SetFontSize(12);
	lbContent->SetFrameRect(CGRectMake(2, 3, size.width, size.height));
	lbContent->SetFontColor(color);
	lbContent->SetText(text);
	
	if (lbContent->GetParent() == NULL)
		m_contentScroll->AddChild(lbContent);
	
	m_contentScroll->refreshContainer();
	
	return;
}

void NewHelpLayer::OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
{
	if (m_tl != table) 
	{
		return;
	}
	
	if (!m_tl || !m_tl->GetDataSource()
	    || m_tl->GetDataSource()->Count() != 1
		|| m_tl->GetDataSource()->Section(0)->Count() != m_mapIndex.size())
		return;
	
	/*
	switch (cellIndex) {
		case eHelpIntroduce:
			SetContent(m_strIntroduce.c_str());
			break;
		case eHelpMenuIntroduce:
			SetContent(m_strMenuIntroduce.c_str());
			break;
		case eHelpGameSetting:
			SetContent(m_strGameSetting.c_str());
			break;
		case eHelpOperate:
			break;

		default:
			break;
	}*/
	
	map_help_data_it it = m_mapData.find(cell->GetTag());
	
	if (it == m_mapData.end()) return;
	
	refresh(it->second);
}

void NewHelpLayer::OnTimer(OBJID tag)
{
	if (tag != 1) 
	{
		NDUILayer::OnTimer(tag);
		return;
	}
	
	m_timer.KillTimer(this, tag);
	
	if (!m_tl ||!m_tl->GetDataSource() || m_tl->GetDataSource()->Count() != 1) 
		return;
		
	NDSection *section = m_tl->GetDataSource()->Section(0);
	
	if (section && section->Count()) 
	{
		section->SetFocusOnCell(0);
		
		map_help_data_it it = m_mapData.find(section->Cell(0)->GetTag());
		
		if (it != m_mapData.end())
		{
			refresh(it->second);
		}
		
		m_tl->ReflashData();
	}
}

void NewHelpLayer::LoadText()
{
	/*
	m_strIntroduce	= LoadTextWithParam(1);
	m_strMenuIntroduce = LoadTextWithParam(2);
	m_strGameSetting = LoadTextWithParam(7);*/
	
	/*
	m_mapIndex.insert(std::pair<int, std::string>(0, "游戏介绍"));
	
	do
	{
		vec_help_data& helpdata = m_mapData[0];
		HelpData data;
		data.type = HelpDataString;
		data.text = "这里只是做个简单的游戏介绍";
		helpdata.push_back(data);
	}while (0);
	
	m_mapIndex.insert(std::pair<int, std::string>(1, "菜单操作"));
	
	do
	{
		vec_help_data& helpdata = m_mapData[1];
		HelpData data;
		data.type = HelpDataString;
		data.text = "这里只是做个简单的菜单操作";
		helpdata.push_back(data);
	}while (0);
	
	m_mapIndex.insert(std::pair<int, std::string>(2, "功能介绍"));
	
	do
	{
		vec_help_data& helpdata = m_mapData[2];
		HelpData data;
		data.type = HelpDataString;
		data.text = "功能介绍 (一)";
		helpdata.push_back(data);
		data.type = HelpDataImage;
		data.text = "功能介绍1.png";
		helpdata.push_back(data);
		
		data.type = HelpDataString;
		data.text = "功能介绍 (二)";
		helpdata.push_back(data);
		data.type = HelpDataImage;
		data.text = "功能介绍2.png";
		helpdata.push_back(data);
		
	}while (0);
	
	m_mapIndex.insert(std::pair<int, std::string>(3, "战斗操作"));
	
	do
	{
		vec_help_data& helpdata = m_mapData[3];
		HelpData data;
		data.type = HelpDataString;
		data.text = "战斗操作 (一)";
		helpdata.push_back(data);
		data.type = HelpDataImage;
		data.text = "战斗操作说明1.png";
		helpdata.push_back(data);
		
		data.type = HelpDataString;
		data.text = "战斗操作 (二)";
		helpdata.push_back(data);
		data.type = HelpDataImage;
		data.text = "战斗操作说明2.png";
		helpdata.push_back(data);
		
	}while (0);
	
	return;
	*/
	
	//NSString *resPath = [NSString stringWithUTF8String:NDPath::GetResourcePath().c_str()];
	NSString *helpiniTable = [NSString stringWithFormat:@"%s", GetResPath("helpview.ini")];
	NSInputStream *stream  = [NSInputStream inputStreamWithFileAtPath:helpiniTable];
	
	if (!stream) return;
	
	[stream open];		
	
	unsigned char byteBufL[1] = {0x00};
	int readLen = [stream read:byteBufL maxLength:1];
	if ( !readLen ) 
	{
		[stream close];
		
		return;
	}
	
	int amount = byteBufL[0];
	
	if (amount == 0)
	{
		[stream close];
		
		return;
	}
	
	for (int i = 0; i < amount; i++) 
	{
		std::string title = [[stream readUTF8String] UTF8String];
		
		int subAmount = [stream readByte];
		
		m_mapIndex.insert(std::pair<int, std::string>(i, title));
		
		vec_help_data& helpdata = m_mapData[i];
		
		helpdata.clear();
		
		for (int j = 0; j < subAmount; j++) 
		{
			HelpData data;
			
			int type = [stream readByte];
			
			if (type == 1) // 图片
			{
				data.type = HelpDataImage;
			}
			else if (type == 0) // 文本
			{
				data.type = HelpDataString;
			}
			
			data.text = [[stream readUTF8String] UTF8String];
			
			helpdata.push_back(data);
		}
	}
	
	[stream close];
}

std::string NewHelpLayer::LoadTextWithParam(int index)
{
	std::string result = "";
	//NSString *resPath = [NSString stringWithUTF8String:NDPath::GetResourcePath().c_str()];
	NSString *helpiniTable = [NSString stringWithFormat:@"%s", GetResPath("help.ini")];
	NSInputStream *stream  = [NSInputStream inputStreamWithFileAtPath:helpiniTable];
	
	if (stream)
	{
		[stream open];		
		result	= cutBytesToString(stream, index);		
		[stream close];
	}
	return result;
}

void NewHelpLayer::refresh(vec_help_data& data)
{
	if (!m_contentScroll) return;
	
	m_contentScroll->RemoveAllChildren(true);
	
	CGRect rect = m_contentScroll->GetFrameRect();
	
	int textStartX = 2, startY = 3;
	
	for_vec(data, vec_help_data_it)
	{
		HelpData& helpdata = *it;
		
		if (helpdata.type == HelpDataString)
		{
			CGSize textSize;
			textSize.width = rect.size.width-textStartX*2;
			textSize.height = NDUITextBuilder::DefaultBuilder()->StringHeightAfterFilter(helpdata.text.c_str(), textSize.width, 13);
			
			NDUIText* memo = NDUITextBuilder::DefaultBuilder()->Build(helpdata.text.c_str(), 
																	  13, 
																	  textSize, 
																	  ccc4(255, 0, 0, 255),
																	  true);
			memo->SetFrameRect(CGRectMake(textStartX, startY, textSize.width, textSize.height));
			
			m_contentScroll->AddChild(memo);
			
			startY += textSize.height + 8;
		}
		else if (helpdata.type == HelpDataImage)
		{
			NDPicture *pic = new NDPicture;
			pic->Initialization(GetImgPath((helpdata.text+".png").c_str()));
			
			CGSize size = pic->GetSize();
			if (size.width == 0.0f || size.height == 0.0f)
				continue;
			
			int x = rect.size.width > size.width ? (rect.size.width-size.width)/2 : 0;
			
			NDUIImage *img = new NDUIImage;
			img->Initialization();
			img->SetPicture(pic, true);
			img->SetFrameRect(CGRectMake(x, startY, size.width, size.height));
			m_contentScroll->AddChild(img);
			
			startY += size.height + 10;
		}
	}
	
	m_contentScroll->refreshContainer();
}

IMPLEMENT_CLASS(NewHelpScene, NDCommonSocialScene)

NewHelpScene::NewHelpScene()
{
}

NewHelpScene::~NewHelpScene()
{
}

NewHelpScene* NewHelpScene::Scene(bool delayShow/*=false*/)
{
	NewHelpScene *scene = new NewHelpScene;
	scene->Initialization(delayShow);
	return scene;
}

void NewHelpScene::Initialization(bool delayShow/*=false*/)
{
	NDCommonSocialScene::Initialization();
	
	m_bDelayShow = delayShow;
	
	NDPicturePool& pool = *(NDPicturePool::DefaultPool());
	
	InitTab(1);
	
	TabNode* tabnode = GetTabNode(0);
	
	NDPicture *pic = pool.AddPicture(GetImgPathNew("newui_text.png"));
	NDPicture *picFocus = pool.AddPicture(GetImgPathNew("newui_text.png"));
	
	int startX = 18*15;
	
	pic->Cut(CGRectMake(startX, 36, 18, 36));
	picFocus->Cut(CGRectMake(startX, 0, 18, 36));
	
	tabnode->SetTextPicture(pic, picFocus);
	
	SetClientLayerBackground(0, false, 480-325);
	
	
	NDUIClientLayer* client = this->GetClientLayer(0);
	
	Init(client);
}

void NewHelpScene::OnButtonClick(NDUIButton* button)
{
	if (OnBaseButtonClick(button)) return;
}

void NewHelpScene::Init(NDUIClientLayer* client)
{
	
	if (!client) return;
	
	CGSize sizeClient = client->GetFrameRect().size;
	NDHFuncTab *help = new NDHFuncTab;
	help->Initialization(1);
	help->SetDelegate(this);
	
	TabNode* tabnode = help->GetTabNode(0);
	tabnode->SetText(NDCommonCString("help"));

	client->AddChild(help);
	
	NDUIClientLayer *clientTab = help->GetClientLayer(0);
	// init..
	NewHelpLayer *helpLayer = new NewHelpLayer;
	helpLayer->Initialization(m_bDelayShow);
	helpLayer->SetFrameRect(CGRectMake(0, 0, sizeClient.width, sizeClient.height));
	clientTab->AddChild(helpLayer);
}