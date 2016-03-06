//
//  ViewController.h
//  UseExternalPlayer
//
//  Created by Catherine Zhao on 2016-03-04.
//  Copyright © 2016 Catherine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTPlayerView.h"
#import <DropboxSDK/DropboxSDK.h>

@interface ViewController : UIViewController<YTPlayerViewDelegate,UITableViewDelegate,UITableViewDataSource,DBRestClientDelegate>
@property (weak, nonatomic) IBOutlet YTPlayerView *playerView;
@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property (nonatomic, strong) DBRestClient *restClient;

@end

