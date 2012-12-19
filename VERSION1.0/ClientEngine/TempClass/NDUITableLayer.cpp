#include "NDUITableLayer.h"
#include "ObjectTracker.h"

namespace NDEngine
{
	IMPLEMENT_CLASS(NDUITableLayer,NDUILayer);

	NDUITableLayer::NDUITableLayer(){ INC_NDOBJ_RTCLS }
	NDUITableLayer::~NDUITableLayer(){ DEC_NDOBJ_RTCLS }
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

	bool NDUITableLayer::DispatchTouchEndEvent( CCPoint beginTouch, CCPoint endTouch )
	{
		return true;
	}

	bool NDUITableLayer::DispatchLongTouchEvent( CCPoint beginTouch, CCPoint endTouch )
	{
		return true;
	}

	bool NDUITableLayer::DispatchLayerMoveEvent( CCPoint beginPoint, NDTouch *moveTouch )
	{
		return true;
	}
}