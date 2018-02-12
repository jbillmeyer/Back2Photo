/*
    File: AlbumViewController.h
*/

#import <UIKit/UIKit.h>

#import <AssetsLibrary/AssetsLibrary.h>

@interface AlbumViewController : UITableViewController
{
   ALAssetsLibrary *assetsLibrary;
   NSMutableArray *groups;

   id delegate;
}

@property (strong, nonatomic) id delegate;

@end
