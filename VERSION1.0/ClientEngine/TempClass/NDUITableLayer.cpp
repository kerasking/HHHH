#include "NDUITableLayer.h"

namespace NDEngine
{
	IMPLEMENT_CLASS(NDUITableLayer,NDUILayer);

	NDUITableLayer::NDUITableLayer(){}
	NDUITableLayer::~NDUITableLayer(){}
	void NDUITableLayer::SetDataSource( NDDataSource* dataSource ){}
	void NDUITableLayer::SetBackgroundColor( ccColor4B color ){}
	void NDUITableLayer::ReflashData(){}
	void NDUITableLayer::Initialization(){}
	void NDUITableLayer::draw(){}
	void NDUITableLayer::OnSectionTitleClick( NDUISectionTitle* sectionTitle ){}
	void NDUITableLayer::OnVerticalScrollBarUpClick( NDUIVerticalScrollBar* scrollBar ){}
	void NDUITableLayer::OnVerticalScrollBarDownClick( NDUIVerticalScrollBar* scrollBar ){}
	void NDUITableLayer::UITouchEnd( NDTouch* touch ){}
	void NDUITableLayer::SetVisible( bool visible ){}

	NDUISectionTitle* NDUITableLayer::GetActiveSectionTitle()
	{
		return 0;
	}

	bool NDUITableLayer::TouchMoved( NDTouch* touch )
	{
		return false;
	}

	bool NDUITableLayer::DispatchTouchEndEvent( CGPoint beginTouch, CGPoint endTouch )
	{
		return true;
	}

	bool NDUITableLayer::DispatchLongTouchEvent( CGPoint beginTouch, CGPoint endTouch )
	{
		return true;
	}

	bool NDUITableLayer::DispatchLayerMoveEvent( CGPoint beginPoint, NDTouch *moveTouch )
	{
		return true;
	}
}