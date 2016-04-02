//
//  ViewController.m
//  UseExternalPlayer
//
//  Created by Catherine Zhao on 2016-03-04.
//  Copyright © 2016 Catherine. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

NSDictionary *playerVars;
NSDictionary *youtubeVideoDic;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self refresh];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refresh) name:@"YoutubeClear" object:nil];

    playerVars = @{@"playsinline" : @1,};
    self.mainTableView.delegate = self;
    self.mainTableView.dataSource = self;
    self.playerView.delegate = self;
}

-(void)refresh {
    youtubeVideoDic = [PlistSettingViewController getVideoPlaylist:FILE_YOUTUBE];
    [self.mainTableView reloadData];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    youtubeVideoDic = [PlistSettingViewController getVideoPlaylist:FILE_YOUTUBE];
    [self.mainTableView reloadData];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [youtubeVideoDic count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"videoCell"];
    cell.textLabel.text = [youtubeVideoDic.allKeys objectAtIndex:indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.playerView stopVideo];
    [self.playerView loadWithVideoId:[youtubeVideoDic.allValues objectAtIndex:indexPath.row] playerVars:playerVars];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
