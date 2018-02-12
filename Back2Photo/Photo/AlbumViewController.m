/*
    File: AlbumViewController.m
\*/

#import "AlbumContentsViewController.h"
#import "AssetsDataIsInaccessibleViewController.h"
#import "AlbumViewController.h"

@implementation AlbumViewController

@synthesize delegate;


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
   [super viewDidLoad];
   
   self.title = @"Albums";
   
   UIBarButtonItem *btnCancel = [[UIBarButtonItem alloc]
                                 initWithTitle: @"Cancel"
                                 style:         UIBarButtonItemStyleBordered
                                 target:        self
                                 action:        @selector(btnPressedBack)];
   self.navigationItem.rightBarButtonItem = btnCancel;
   
   if (!assetsLibrary)
   {
      assetsLibrary = [[ALAssetsLibrary alloc] init];
   }
   if (!groups)
   {
      groups = [[NSMutableArray alloc] init];
   }
   else
   {
      [groups removeAllObjects];
   }
   
   ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop)
   {
      if (group)
      {
         [groups addObject: group];
      }
      else
      {
         [self.tableView performSelectorOnMainThread: @selector(reloadData) withObject: nil waitUntilDone: NO];
      }
   };
   
   ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error)
   {
      AssetsDataIsInaccessibleViewController *assetsDataInaccessibleViewController = [[AssetsDataIsInaccessibleViewController alloc] initWithNibName: @"AssetsDataIsInaccessibleViewController" bundle: nil];
      
      NSString *errorMessage = nil;
      switch ([error code])
      {
         case ALAssetsLibraryAccessUserDeniedError:
         case ALAssetsLibraryAccessGloballyDeniedError:
            errorMessage = @"The user has declined access to it.";
            break;
         default:
            errorMessage = @"Reason unknown.";
            break;
      }
      
      assetsDataInaccessibleViewController.explanation = errorMessage;
      [self presentViewController: assetsDataInaccessibleViewController animated: NO completion: nil];
   };
   
   NSUInteger groupTypes = ALAssetsGroupSavedPhotos | ALAssetsGroupAlbum | ALAssetsGroupEvent | ALAssetsGroupFaces;
   [assetsLibrary enumerateGroupsWithTypes:groupTypes usingBlock:listGroupBlock failureBlock:failureBlock];
}


- (void) btnPressedBack
{
   [self dismissViewControllerAnimated: YES completion: nil];
}


#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
   return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   return groups.count;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   static NSString *CellIdentifier = @"Cell";
   
   UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
   if (cell == nil)
   {
      cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
   }
   
   ALAssetsGroup *groupForCell   = [groups objectAtIndex: indexPath.row];
   CGImageRef     posterImageRef = [groupForCell posterImage];
   UIImage       *posterImage    = [UIImage imageWithCGImage: posterImageRef];

   cell.imageView.image = posterImage;
   cell.textLabel.text  = [groupForCell valueForProperty:ALAssetsGroupPropertyName];
   cell.accessoryType   = UITableViewCellAccessoryDisclosureIndicator;
   
   return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   if (groups.count > indexPath.row)
   {
      AlbumContentsViewController *albumContentsViewController = [[AlbumContentsViewController alloc] initWithNibName: @"AlbumContentsViewController" bundle: nil];
      albumContentsViewController.assetsGroup = [groups objectAtIndex:indexPath.row];
      albumContentsViewController.delegate    = delegate;
      [self.navigationController pushViewController: albumContentsViewController animated: YES];
   }
}


- (void) animationCompleted
{
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning
{
   // Releases the view if it doesn't have a superview.
   [super didReceiveMemoryWarning];
   
   // Relinquish ownership any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload
{
   // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
   // For example: self.myOutlet = nil;
   
   assetsLibrary = nil;
   groups = nil;
   
   [super viewDidUnload];
}

@end
