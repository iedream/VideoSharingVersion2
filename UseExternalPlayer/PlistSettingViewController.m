//
//  PlistSettingViewController.m
//  
//
//  Created by Catherine Zhao on 2016-03-06.
//
//

#import "PlistSettingViewController.h"

@interface PlistSettingViewController ()

@end

@implementation PlistSettingViewController

NSURL *fileURL;
NSString *plistName;
NSMutableDictionary *videoIds;
UIAlertController *emptyGroupName;
UIAlertController *downloadError;
UIAlertController *missingFileName;
UIAlertController *missingFileURL;
UIAlertAction *okAction;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self updateFileURL];
    emptyGroupName = [UIAlertController alertControllerWithTitle: @"GroupName cannot be Empty" message:@"Please enter in a GroupName" preferredStyle:UIAlertControllerStyleAlert];
    downloadError = [UIAlertController alertControllerWithTitle:@"Download Error" message:@"Download Playlist encounters an error. Please make sure you have entered the correct GroupName" preferredStyle:UIAlertControllerStyleAlert];
    missingFileName = [UIAlertController alertControllerWithTitle:@"File Name cannot be Empty" message:@"Please enter in a File Name" preferredStyle:UIAlertControllerStyleAlert];
    missingFileURL = [UIAlertController alertControllerWithTitle:@"File URL cannot be Empty" message:@"Please enter in a File URL" preferredStyle:UIAlertControllerStyleAlert];
    okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    [emptyGroupName addAction:okAction];
    [downloadError addAction:okAction];
    [missingFileName addAction:okAction];
    [missingFileURL addAction:okAction];
    self.restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    self.restClient.delegate = self;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateFileURL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Upload Plist Methods
- (IBAction)uploadPlist:(id)sender {
    [self updateFileURL];
    if ([plistName length] == 0) {
        [self presentAlertView:emptyGroupName];
        return;
    }
    NSFileManager *fileManage = [NSFileManager defaultManager];
    if(![fileManage fileExistsAtPath:fileURL.path]){
        [self writeToFile];
    }
    [self writeToFile];
    [self.restClient loadMetadata:@"/"];
}

-(void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
    if (metadata.isDirectory) {
        NSLog(@"Folder '%@' contains:", metadata.path);
        for (DBMetadata *file in metadata.contents) {
            NSLog(@"	%@", file.filename);
            if([file.filename isEqualToString:plistName]){
                [self.restClient uploadFile:plistName toPath:@"/" withParentRev:file.rev fromPath:fileURL.path];
                return;
            }
        }
        [self.restClient uploadFile:plistName toPath:@"/" withParentRev:nil fromPath:fileURL.path];
    }
}

- (void)restClient:(DBRestClient *)client
loadMetadataFailedWithError:(NSError *)error {
    NSLog(@"Error loading metadata: %@", error);
}

-(void)restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath from:(NSString *)srcPath metadata:(DBMetadata *)metadata {
    NSLog(@"File uploaded successfully to path: %@", metadata.path);
}

-(void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error {
    NSLog(@"Failure");
}

#pragma mark - Download Plist Methods

- (IBAction)downloadPlist:(id)sender {
    [self updateFileURL];
    if ([plistName length] == 0) {
        [self presentAlertView:emptyGroupName];
        return;
    }
    [self.restClient loadFile: [NSString stringWithFormat:@"/%@",plistName] intoPath:fileURL.path];
}

-(void)restClient:(DBRestClient *)client loadedFile:(NSString *)destPath contentType:(NSString *)contentType metadata:(DBMetadata *)metadata {
    NSLog(@"File loaded into path: %@", destPath);
    [PlistSettingViewController populateLocalDictionary];
}

-(void)restClient:(DBRestClient *)client loadFileFailedWithError:(NSError *)error {
    [self presentAlertView:downloadError];
}

#pragma mark - WriteTo Plist Methods
-(void)writeToFile {
    [videoIds writeToFile:fileURL.path atomically:false];
}


- (IBAction)addVideo:(id)sender {
    [self updateFileURL];
    if ([plistName length] == 0) {
        [self presentAlertView:emptyGroupName];
        return;
    }
    if ([self.fileNameField.text length] == 0) {
        [self presentAlertView:missingFileName];
        return;
        
    }
    if ([self.fileURLField.text length] == 0) {
        [self presentAlertView:missingFileURL];
        return;
    }
    
    NSString *fileName = [self.fileNameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSNumber *fileType;
    NSString *fileURL;
    if(self.fileTypeSelector.selectedSegmentIndex == 0){
        fileType = [NSNumber numberWithInt:FILE_YOUTUBE];
        NSArray *urlArray = [self.fileURLField.text componentsSeparatedByString:@"?v="];
        NSArray *videoIdArray = [urlArray[1] componentsSeparatedByString:@"&"];
        fileURL = videoIdArray[0];
    }else{
        fileType = [NSNumber numberWithInt:FILE_OTHER];
        fileURL = self.fileURLField.text;
    }
    videoIds[fileName] = @[fileType,fileURL];
    [self writeToFile];
}

-(void)presentAlertView:(UIAlertController*)alertView {
    if(self.presentedViewController != nil){
         [self.presentedViewController.view removeFromSuperview];
    }
    [self presentViewController:alertView animated:true completion:nil];
}

-(void)updateFileURL {
    if([self.groupNameField.text length] == 0){
        self.groupNameField.text = plistName;
    }else{
        plistName = self.groupNameField.text;
    }
    if([plistName length] != 0){
         NSURL *documentsURL = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0];
        fileURL = [documentsURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",plistName]];
    }
}

+(NSDictionary *)getVideoPlaylist:(FileType)fileType {
    NSMutableDictionary *returnDic = [[NSMutableDictionary alloc]init];
    for (NSString *key in videoIds) {
        NSLog(@"%i", FILE_YOUTUBE);
        if([videoIds[key][0] intValue] == fileType){
            returnDic[key] = videoIds[key][1];
        }
    }
    return [returnDic copy];
}

+(void)populateLocalDictionary {
    NSURL *documentsURL = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0];
    fileURL = [documentsURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",plistName]];
    NSFileManager *fileManage = [NSFileManager defaultManager];
    if(![fileManage fileExistsAtPath:fileURL.path]){
        videoIds = [[NSMutableDictionary alloc]init];
        return;
    }
    videoIds= [[NSMutableDictionary alloc] initWithContentsOfFile:fileURL.path];
}

+(void)setPlistName:(NSString*)name {
    plistName = name;
}

+(NSString*) getPlistName {
    return plistName;
}

-(void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:true];
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
