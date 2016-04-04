//
//  ChatViewCell.h
//  EaseMobDemo
//
//  Created by linjohn on 3/29/16.
//  Copyright © 2016 linjohn. All rights reserved.
//

#import <UIKit/UIKit.h>
@class EMMessage;

@interface ChatViewCell : UITableViewCell

/** EMMessage模型 */
@property(nonatomic,strong)EMMessage *message;

+ (instancetype)initWithTableView:(UITableView *)tableView message:(EMMessage *)message indexPath:(NSIndexPath *)indexPath;

@end
