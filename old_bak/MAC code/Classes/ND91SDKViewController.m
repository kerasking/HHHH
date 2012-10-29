//
//  ND91SDKViewController.m
//  DHLJ
//
//  Created by liujh on 12/07/24.
//  Copyright (c) 2012  DeNA co., Ltd. All rights reserved.
//

#import "ND91SDKViewController.h"
#import "CCDirector.h"

#ifdef USE_MGSDK
#import "MBGSocialService.h"
#endif

@implementation ND91SDKViewController

#ifdef USE_MGSDK
MBGBalanceButton* balanceButton;
#endif
static ND91SDKViewController *_sharedViewController = nil;

+ (ND91SDKViewController *)sharedViewController
{
	if (!_sharedViewController) {
			_sharedViewController = [[self alloc] init];
	}
    
	return _sharedViewController;
}

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void) dealloc
{
	_sharedViewController = nil;
	
	[super dealloc];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *path = [NSString stringWithFormat:@"%@/NdComPlatform_SNS_Resources/icon_SNS.png", [[NSBundle mainBundle] resourcePath]];
    UIImage* pImage = [UIImage imageWithContentsOfFile:path];
    UIImageView *lefttop = [[UIImageView alloc] initWithImage:pImage];  //用图片来初始一个视图
    lefttop.userInteractionEnabled = YES;   //设置改视图的属性
    [self.view addSubview:lefttop];//将该图像视图添加到主视图中
    [lefttop release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIDeviceOrientationLandscapeLeft || interfaceOrientation == UIDeviceOrientationLandscapeRight);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[[CCDirector sharedDirector] openGLView] touchesBegan2:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[[CCDirector sharedDirector] openGLView] touchesMoved2:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[[CCDirector sharedDirector] openGLView] touchesEnded2:touches withEvent:event];
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[[CCDirector sharedDirector] openGLView] touchesCancelled2:touches withEvent:event];
}
- (void) showBalanceButton:(CGRect)rect {
#ifdef USE_MGSDK
    if(balanceButton == nil){
        balanceButton = [MBGSocialService getBalanceButton:rect];
        [self.view addSubview:balanceButton];
    }else{
        [balanceButton setFrame:rect];
        [balanceButton update];
        balanceButton.hidden = NO;
    }
#endif
}

- (void) hideBalanceButton {
#ifdef USE_MGSDK
    if(balanceButton != nil){
        balanceButton.hidden = YES;
    }
#endif
}
@end
