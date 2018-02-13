/*
    File: AlbumContentsViewController.m
*/

#import "AlbumContentsViewController.h"

#import "AlbumContentsTableViewCell.h"

@implementation AlbumContentsViewController

@synthesize assetsGroup;
@synthesize tmpCell;
@synthesize delegate;


- (void)awakeFromNib
{
   [super awakeFromNib];
   lastSelectedRow = NSNotFound;
}


#pragma mark View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
   [super viewWillAppear:animated];
   
   self.title = [assetsGroup valueForProperty:ALAssetsGroupPropertyName];
   
   if (!assets)
   {
      assets = [[NSMutableArray alloc] init];
   }
   else
   {
      [assets removeAllObjects];
   }
   
   ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop)
   {
      if (result)
      {
         [assets addObject:result];
      }
   };
   
   ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
   [assetsGroup setAssetsFilter:onlyPhotosFilter];
   [assetsGroup enumerateAssetsUsingBlock:assetsEnumerationBlock];
}

- (void)viewDidAppear:(BOOL)animated
{
   [super viewDidAppear:true];
   
   if (lastSelectedRow != NSNotFound)
   {
      NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForRow:lastSelectedRow inSection:0];
      AlbumContentsTableViewCell *selectedCell = (AlbumContentsTableViewCell *)[(UITableView *)self.view cellForRowAtIndexPath:selectedIndexPath];
      [selectedCell clearSelection];
      
      lastSelectedRow = NSNotFound;
   }
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
   // Return the number of sections.
   return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   // Return the number of rows in the section.
   return ceil((float)assets.count / 4); // there are four photos per row.
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   static NSString *CellIdentifier = @"Cell";
   
   AlbumContentsTableViewCell *cell = (AlbumContentsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
   if (cell == nil)
   {
      [[NSBundle mainBundle] loadNibNamed:@"AlbumContentsTableViewCell" owner:self options:nil];
      cell = tmpCell;
      tmpCell = nil;
   }
   
   cell.rowNumber = indexPath.row;
   cell.selectionDelegate = self;
   
   // Configure the cell...
   NSUInteger firstPhotoInCell = indexPath.row * 4;
   NSUInteger lastPhotoInCell  = firstPhotoInCell + 4;
   
   if (assets.count <= firstPhotoInCell)
   {
      NSLog(@"We are out of range, asking to start with photo %lu but we only have %lu", (unsigned long)firstPhotoInCell, (unsigned long)assets.count);
      return cell;
   }
   
   NSUInteger currentPhotoIndex = 0;
   NSUInteger lastPhotoIndex = MIN(lastPhotoInCell, assets.count);
   for ( ; firstPhotoInCell + currentPhotoIndex < lastPhotoIndex ; currentPhotoIndex++)
   {
      ALAsset *asset = [assets objectAtIndex:firstPhotoInCell + currentPhotoIndex];
      CGImageRef thumbnailImageRef = [asset thumbnail];
      UIImage *thumbnail = [UIImage imageWithCGImage:thumbnailImageRef];
      
      switch (currentPhotoIndex)
      {
         case 0:
            [cell photo1].image = thumbnail;
            break;
         case 1:
            [cell photo2].image = thumbnail;
            break;
         case 2:
            [cell photo3].image = thumbnail;
            break;
         case 3:
            [cell photo4].image = thumbnail;
            break;
         default:
            break;
      }
   }
   
   return cell;
}


#pragma mark -
#pragma mark AlbumContentsTableViewCellSelectionDelegate

- (void) albumContentsTableViewCell:(AlbumContentsTableViewCell *)cell selectedPhotoAtIndex:(NSUInteger)index
{
   lastSelectedRow = cell.rowNumber;
   
   ALAsset *asset = [assets objectAtIndex:(cell.rowNumber * 4) + index];
   [[NSNotificationCenter defaultCenter] postNotificationName: @"PhotoNotification" object: asset];
   
   [self dismissViewControllerAnimated: YES completion: nil];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning
{
   [super didReceiveMemoryWarning];
}

- (void)viewDidUnload 
{
   [super viewDidUnload];
}

@end

