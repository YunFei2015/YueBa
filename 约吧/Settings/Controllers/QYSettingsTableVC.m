//
//  QYSettingsTableVC.m
//  约吧
//
//  Created by 云菲 on 4/6/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import "QYSettingsTableVC.h"
#import "QYAccount.h"
#import "AppDelegate.h"
#import "QYNetworkManager.h"

@interface QYSettingsTableVC ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *leftBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightBarButtonItem;
@property (weak, nonatomic) IBOutlet UIButton *logoutBtn;
@property (weak, nonatomic) IBOutlet UISwitch *manSw;
@property (weak, nonatomic) IBOutlet UISwitch *womanSw;

@end

@implementation QYSettingsTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    SWRevealViewController *revealViewController = self.revealViewController;
    [revealViewController panGestureRecognizer];
    [revealViewController tapGestureRecognizer];
    if ( revealViewController )
    {
        [self.leftBarButtonItem setTarget: revealViewController];
        [self.leftBarButtonItem setAction: @selector(revealToggle:)];
        
        [self.rightBarButtonItem setTarget: revealViewController];
        [self.rightBarButtonItem setAction: @selector(rightRevealToggle:)];
    }
    
    _logoutBtn.layer.cornerRadius = 5;
    _logoutBtn.layer.borderColor = [UIColor redColor].CGColor;
    _logoutBtn.layer.borderWidth = .5f;
}

- (IBAction)logout:(UIButton *)sender {
    [[QYAccount currentAccount] logout];
    
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    [app setRootViewControllerToEntrance];
}

- (IBAction)selectSexAction:(UISwitch *)sender {
    if (sender == _manSw) {
        [_womanSw setOn:!sender.isOn animated:YES];
    }else{
        [_manSw setOn:!sender.isOn animated:YES];
    }
}

#pragma mark - Table view data source



/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
