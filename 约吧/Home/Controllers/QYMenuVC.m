//
//  QYMenuVC.m
//  约吧
//
//  Created by 云菲 on 4/6/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import "QYMenuVC.h"

@interface QYMenuVC () {
    NSInteger _presentedRow;
}
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;

@end

@implementation QYMenuVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _iconImageView.layer.cornerRadius = kRevealViewWidth / 4.f / 2;
    _iconImageView.layer.masksToBounds = YES;
}

- (IBAction)iconTapAction:(id)sender {
    UIStoryboard *profileStoryboard = [UIStoryboard storyboardWithName:@"QYProfile" bundle:nil];
    UINavigationController *nav = [profileStoryboard instantiateViewControllerWithIdentifier:@"profileNav"];
    [self.revealViewController pushFrontViewController:nav animated:YES];
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SWRevealViewController *revealVC = self.revealViewController;
    if (indexPath.row == _presentedRow) {
        [revealVC setFrontViewPosition:FrontViewPositionLeft animated:YES];
    }else{
        switch (indexPath.row) {
            case 0:{
                UINavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:kHomeNavIdentifier];
                [revealVC pushFrontViewController:navigationController animated:YES];
            }
                break;
            case 1:
                [revealVC rightRevealToggleAnimated:YES];
                break;
            case 2:{
                UIStoryboard *settingsStoryboard = [UIStoryboard storyboardWithName:@"Settings" bundle:nil];
                UINavigationController *navigationController = [settingsStoryboard instantiateViewControllerWithIdentifier:kSettingsNavIdentifier];
                [revealVC pushFrontViewController:navigationController animated:YES];
            }
                
                break;
                
            default:
                break;
        }
        _presentedRow = indexPath.row;
    }
}

@end
