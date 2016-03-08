//
//  WebViewController.m
//  UseExternalPlayer
//
//  Created by Catherine Zhao on 2016-03-07.
//  Copyright © 2016 Catherine. All rights reserved.
//

#import "WebViewController.h"
#import "PlistSettingViewController.h"

@interface WebViewController ()

@end

@implementation WebViewController
NSDictionary *webVideoDic;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self refresh];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refresh) name:@"WebClear" object:nil];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    webVideoDic = [PlistSettingViewController getVideoPlaylist:FILE_OTHER];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)refresh {
    webVideoDic = [PlistSettingViewController getVideoPlaylist:FILE_OTHER];
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [webVideoDic count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WebCell"];
    cell.textLabel.text = [webVideoDic.allKeys objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *fullURL = webVideoDic.allValues[indexPath.row];
    NSURL *url = [NSURL URLWithString:fullURL];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:requestObj];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
