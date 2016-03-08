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
//NSMutableDictionary *videoIds;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self refresh];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refresh) name:@"YoutubeClear" object:nil];

    playerVars = @{@"playsinline" : @1,};
    //videoIds = [[NSMutableDictionary alloc] initWithDictionary:@{@"一次就好":@"7dgyfnX-nmE",@"空白格":@"GrzzfZ1qaI0",@"最爱":@"OT0wn1mHbOY",@"流浪记":@"miTB7LO2OF8",@"匆匆那年":@"jAoNQ5g3PBI",@"大海":@"UBjLqzy0yI8"}];
    self.mainTableView.delegate = self;
    self.mainTableView.dataSource = self;
    self.playerView.delegate = self;
//    [self.playerView loadWithVideoId:@"GrzzfZ1qaI0" playerVars:playerVars];
    //[self.playerView loadWithVideoId:@"7dgyfnX-nmE"];
    //[self.playerView loadVideoById:@"M7lc1UVf-VE" startSeconds:0.0f endSeconds:60.0f suggestedQuality:kYTPlaybackQualityAuto];
    // Do any additional setup after loading the view, typically from a nib.
}



//- (IBAction)dropBoxLinking:(id)sender {
//    if (![[DBSession sharedSession] isLinked]) {
//        [[DBSession sharedSession] linkFromController:self];
//    }
//}

//- (IBAction)checkFile:(id)sender {
//    [self.restClient loadMetadata:@"/"];
//}

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
