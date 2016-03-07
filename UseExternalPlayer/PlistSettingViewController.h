//
//  PlistSettingViewController.h
//  
//
//  Created by Catherine Zhao on 2016-03-06.
//
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>

typedef enum fileTypes
{
    FILE_YOUTUBE,
    FILE_OTHER
} FileType;

@interface PlistSettingViewController : UIViewController<DBRestClientDelegate>
@property (nonatomic, strong) DBRestClient *restClient;
@property (weak, nonatomic) IBOutlet UITextField *groupNameField;
@property (weak, nonatomic) IBOutlet UITextField *fileNameField;
@property (weak, nonatomic) IBOutlet UITextField *fileURLField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *fileTypeSelector;

+(NSDictionary *)getVideoPlaylist:(FileType)fileType;
+(void)populateLocalDictionary;
+(void)setPlistName:(NSString*)name;
+(NSString*) getPlistName;
@end
