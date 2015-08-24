//
//  RecordCollectionViewController.m
//  record album
//
//  Created by Krishan on 8/12/15.
//  Copyright (c) 2015 Romp. All rights reserved.
//

#import "RecordCollectionViewController.h"
#import "AppDelegate.h"
#import "RecordCollection.h"

@interface RecordCollectionViewController ()
{
    NSIndexPath *getIndexPath;
    
    //Editing part
    UIImageView *coverImgView;
    UITextField* editArtistName;
    UITextField* editAlbumName;
    UITextField* editYearReleased;
    UITextField* editRecordLabel;
    NSString *oldCoverImage;
    
    BOOL albumCoverChanged;
}
@end

@implementation RecordCollectionViewController
{
    
}
@synthesize chosenImage;
@synthesize imagePicker;

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectedModel = _managedObjectedModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize recordCollectionView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    _managedObjectContext = [appDelegate managedObjectContext];
    
    //Get the Record Collection data
    
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    NSEntityDescription *recordCollectionShow = [NSEntityDescription entityForName:@"RecordCollection" inManagedObjectContext:_managedObjectContext];
    
    [request setEntity:recordCollectionShow];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"artistName" ascending:YES];
    
    NSArray *sortDescriptors = [[NSArray alloc]initWithObjects:sortDescriptor, nil];
    
    [request setSortDescriptors:sortDescriptors];
    
    NSError *error = nil;
    
    //The ultimate result from the Core Data
    NSMutableArray *mutableFetchResults = [[_managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
    
    if(mutableFetchResults == nil){
        NSLog(@"Results empty!");
    }

    [self setRecordCollectionView:mutableFetchResults];
    
    self.collectionView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"music_background.JPG"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{

    return [recordCollectionView count];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifier = @"Cell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    RecordCollection *recordCollectionViewCell = (RecordCollection*)[recordCollectionView objectAtIndex:indexPath.row];
    
    UIImageView *cellCoverImage = (UIImageView*)[cell viewWithTag:100];
    cellCoverImage.image = [self loadImage:[recordCollectionViewCell coverImage]];
    
    UILabel *cellAlbumName = (UILabel *)[cell viewWithTag:101];
    cellAlbumName.text = [recordCollectionViewCell albumName];
    
    UILabel *cellArtistName = (UILabel *)[cell viewWithTag:102];
    cellArtistName.text = [recordCollectionViewCell artistName];
    
    return cell;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (UIImage*)snapshotImage
{
    // Make an image from the input view.
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, 0);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UIView *backingView = [[UIView alloc] initWithFrame:self.view.bounds];
    backingView.tag = 4455;
    backingView.backgroundColor = [UIColor clearColor];
    
    UIView *alphaEffect = [[UIView alloc] initWithFrame:self.view.bounds];
    alphaEffect.backgroundColor = [UIColor blackColor];
    alphaEffect.alpha = 0.45F;
    
    [backingView addSubview:alphaEffect];

    
    UIView *infoView =[[UIView alloc] initWithFrame:self.view.bounds];
    CGRect newFrame = infoView.frame;
    newFrame.size.width = backingView.frame.size.width;
    newFrame.size.height = 300;

    [infoView setFrame:newFrame];
    
    UIGraphicsBeginImageContext(infoView.frame.size);
    [[UIImage imageNamed:@"bg_view.JPG"] drawInRect:infoView.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    infoView.backgroundColor = [UIColor colorWithPatternImage:image];
    
    infoView.center = CGPointMake(backingView.frame.size.width / 2, backingView.frame.size.height / 2);
    
    //Add album information to the infoView sub view
    
    
    RecordCollection *recordCollectionViewItem = (RecordCollection*)[recordCollectionView objectAtIndex:indexPath.item];
    
    NSString *artistName = [recordCollectionViewItem artistName];
    NSString *albumName = [recordCollectionViewItem albumName];
    NSString *yearReleased = [recordCollectionViewItem yearReleased];
    NSString *recordLabel = [recordCollectionViewItem recordLabel];
    NSString *coverImage = [recordCollectionViewItem coverImage];
    
    UIImageView *coverImgCellView = [[UIImageView alloc] initWithFrame:CGRectMake(110, 10, 90, 90)];
    coverImgCellView.image = [self loadImage:coverImage];
    [infoView addSubview:coverImgCellView];
    
    
    UILabel *artistName_lbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 120, 300, 20)];
    [artistName_lbl setTextColor:[UIColor whiteColor]];
    [artistName_lbl setFont:[UIFont fontWithName:NULL size:15]];
    NSString *artist_lbl_string = @"Artist Name: ";
    artistName_lbl.text = artist_lbl_string;
    [infoView addSubview:artistName_lbl];
    
    UILabel *artistName_show = [[UILabel alloc] initWithFrame:CGRectMake(100, 120, 300, 20)];
    [artistName_show setTextColor:[UIColor whiteColor]];
    [artistName_show setFont:[UIFont fontWithName:NULL size:15]];
    NSString *artistName_text = artistName;
    artistName_show.text = artistName_text;
    [infoView addSubview:artistName_show];
    
    
    UILabel *albumName_lbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 155, 300, 20)];
    [albumName_lbl setTextColor:[UIColor whiteColor]];
    [albumName_lbl setFont:[UIFont fontWithName:NULL size:15]];
    NSString *albumName_lbl_string = @"Album Name: ";
    albumName_lbl.text = albumName_lbl_string;
    [infoView addSubview:albumName_lbl];
    
    UILabel *albumName_show = [[UILabel alloc] initWithFrame:CGRectMake(107, 155, 300, 20)];
    [albumName_show setTextColor:[UIColor whiteColor]];
    [albumName_show setFont:[UIFont fontWithName:NULL size:15]];
    NSString *albumName_text = albumName;
    albumName_show.text = albumName_text;
    [infoView addSubview:albumName_show];
    
    UILabel *yearReleased_lbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 190, 300, 20)];
    [yearReleased_lbl setTextColor:[UIColor whiteColor]];
    [yearReleased_lbl setFont:[UIFont fontWithName:NULL size:15]];
    NSString *yearReleased_lbl_string = @"Year Released: ";
    yearReleased_lbl.text = yearReleased_lbl_string;
    [infoView addSubview:yearReleased_lbl];
    
    UILabel *yearReleased_show = [[UILabel alloc] initWithFrame:CGRectMake(112, 190, 300, 20)];
    [yearReleased_show setTextColor:[UIColor whiteColor]];
    [yearReleased_show setFont:[UIFont fontWithName:NULL size:15]];
    NSString *yearReleased_text = yearReleased;
    yearReleased_show.text = yearReleased_text;
    [infoView addSubview:yearReleased_show];
    
    UILabel *recordLabel_lbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 225, 300, 20)];
    [recordLabel_lbl setTextColor:[UIColor whiteColor]];
    [recordLabel_lbl setFont:[UIFont fontWithName:NULL size:15]];
    NSString *recordLabel_lbl_string = @"Record Label: ";
   recordLabel_lbl.text = recordLabel_lbl_string;
    [infoView addSubview:recordLabel_lbl];
    
    UILabel *recordLabel_show = [[UILabel alloc] initWithFrame:CGRectMake(107, 225, 300, 20)];
    [recordLabel_show setTextColor:[UIColor whiteColor]];
    [recordLabel_show setFont:[UIFont fontWithName:NULL size:15]];
    NSString *recordLabel_text = recordLabel;
    recordLabel_show.text = recordLabel_text;
    [infoView addSubview:recordLabel_show];
   
    
    
    UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    getIndexPath = indexPath;
    [editButton addTarget:self action:@selector(editAlbumItem) forControlEvents:UIControlEventTouchUpInside];
    [editButton setTitle:@"Edit Album" forState:UIControlStateNormal];
    editButton.frame = CGRectMake(80.0, 460.0, 160.0, 40.0);
    [backingView addSubview:editButton];
    
    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [deleteButton setTag:indexPath.item];
    [deleteButton addTarget:self action:@selector(deleteAlbumItem:) forControlEvents:UIControlEventTouchUpInside];
    [deleteButton setTitle:@"Delete Album" forState:UIControlStateNormal];
    deleteButton.frame = CGRectMake(80.0, 490.0, 160.0, 40.0);
    [backingView addSubview:deleteButton];
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton addTarget:self action:@selector(closeView) forControlEvents:UIControlEventTouchUpInside];
    [closeButton setTitle:@"Close" forState:UIControlStateNormal];
    closeButton.frame = CGRectMake(80.0, 430, 160.0, 40.0);
    [backingView addSubview:closeButton];
    
    [backingView addSubview:infoView];
    
    [self.view addSubview:backingView];
    
}


- (void)closeView
{
    [[self.view viewWithTag:4455] removeFromSuperview];
}


- (void)editAlbumItem
{
    NSLog(@"%ld",(long)getIndexPath.item);
    
    //Create Edit View
    
    UIView *editBackingView = [[UIView alloc] initWithFrame:self.view.bounds];
    editBackingView.tag = 2266;
    editBackingView.backgroundColor = [UIColor clearColor];
    
    UIView *editView= [[UIView alloc] initWithFrame:self.view.bounds];
    
    UIGraphicsBeginImageContext(editView.frame.size);
    [[UIImage imageNamed:@"edit_bg.jpg"] drawInRect:editView.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    editView.backgroundColor = [UIColor colorWithPatternImage:image];
    
    CGRect newFrameEdit = editView.frame;
    newFrameEdit.size.width = editBackingView.frame.size.width;
    newFrameEdit.size.height = 400;
    [editView setFrame:newFrameEdit];
    editView.center = CGPointMake(editBackingView.frame.size.width / 2, editBackingView.frame.size.height / 2);
    
    
    UIView *editAlphaEffect = [[UIView alloc] initWithFrame:self.view.bounds];
    editAlphaEffect.backgroundColor = [UIColor blackColor];
    editAlphaEffect.alpha = 0.45F;
    
    UIButton* closeEditView = [[UIButton alloc] initWithFrame:CGRectMake(85, 345, 150, 70)];
    [closeEditView setTitle:@"Close" forState:UIControlStateNormal];
    [closeEditView setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [closeEditView addTarget:self action:@selector(closeEditView) forControlEvents:UIControlEventTouchUpInside];
    [editView addSubview:closeEditView];
    
    //Add all the item to the edit view

    RecordCollection *recordCollectionViewItem = (RecordCollection*)[recordCollectionView objectAtIndex:getIndexPath.item];

    NSString *artistName = [recordCollectionViewItem artistName];
    NSString *albumName = [recordCollectionViewItem albumName];
    NSString *yearReleased = [recordCollectionViewItem yearReleased];
    NSString *recordLabel = [recordCollectionViewItem recordLabel];
    NSString *coverImage = [recordCollectionViewItem coverImage];
    
    oldCoverImage = coverImage;
    
    coverImgView = [[UIImageView alloc] initWithFrame:CGRectMake(115, 10, 90, 90)];
    coverImgView.image = [self loadImage:coverImage];
    [editView addSubview:coverImgView];
    
    UIButton* changeCoverImg = [[UIButton alloc] initWithFrame:CGRectMake(85, 65, 150, 90)];
    [changeCoverImg setTitle:@"Change Cover" forState:UIControlStateNormal];
    changeCoverImg.titleLabel.font = [UIFont fontWithName:NULL size:11];
    [changeCoverImg setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [changeCoverImg addTarget:self action:@selector(changeAlbumCoverImage) forControlEvents:UIControlEventTouchUpInside];
    [editView addSubview:changeCoverImg];
    
    UIButton* updateRecord = [[UIButton alloc] initWithFrame:CGRectMake(80, 300, 150, 70)];
    [updateRecord setTitle:@"Update Records" forState:UIControlStateNormal];
    [updateRecord setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [updateRecord setTag:getIndexPath.item];
    [updateRecord addTarget:self action:@selector(updateRecords:) forControlEvents:UIControlEventTouchUpInside];
    [editView addSubview:updateRecord];
    
    
    UILabel *artistName_lbl = [[UILabel alloc] initWithFrame:CGRectMake(80, 125, 300, 20)];
    [artistName_lbl setTextColor:[UIColor darkGrayColor]];
    [artistName_lbl setFont:[UIFont fontWithName:NULL size:15]];
    NSString *artist_lbl_string = @"Artist Name: ";
    artistName_lbl.text = artist_lbl_string;
    [editView addSubview:artistName_lbl];
    
    editArtistName = [[UITextField alloc] initWithFrame:CGRectMake(170, 125, 300, 20)];
    editArtistName.text = artistName;
    editArtistName.borderStyle = UITextBorderStyleLine;
    [editView addSubview:editArtistName];
    
    
    UILabel *albumName_lbl = [[UILabel alloc] initWithFrame:CGRectMake(80, 170, 300, 20)];
    [albumName_lbl setTextColor:[UIColor darkGrayColor]];
    [albumName_lbl setFont:[UIFont fontWithName:NULL size:15]];
    NSString *albumName_lbl_string = @"Album Name: ";
    albumName_lbl.text = albumName_lbl_string;
    [editView addSubview:albumName_lbl];
    
    editAlbumName = [[UITextField alloc] initWithFrame:CGRectMake(175, 170, 300, 20)];
    editAlbumName.text = albumName;
    editAlbumName.borderStyle = UITextBorderStyleLine;
    [editView addSubview:editAlbumName];
    
    
    UILabel *yearRelased_lbl = [[UILabel alloc] initWithFrame:CGRectMake(80, 205, 300, 20)];
    [yearRelased_lbl setTextColor:[UIColor darkGrayColor]];
    [yearRelased_lbl setFont:[UIFont fontWithName:NULL size:15]];
    NSString *yearRelased_lbl_string = @"Year Released: ";
    yearRelased_lbl.text = yearRelased_lbl_string;
    [editView addSubview:yearRelased_lbl];
    
    editYearReleased = [[UITextField alloc] initWithFrame:CGRectMake(185, 205, 300, 20)];
    editYearReleased.text = yearReleased;
    editYearReleased.borderStyle = UITextBorderStyleLine;
    [editView addSubview:editYearReleased];
    
    
    UILabel *recordLabel_lbl = [[UILabel alloc] initWithFrame:CGRectMake(80, 240, 300, 20)];
    [recordLabel_lbl setTextColor:[UIColor darkGrayColor]];
    [recordLabel_lbl setFont:[UIFont fontWithName:NULL size:15]];
    NSString *recordLabel_lbl_string = @"Record Label: ";
    recordLabel_lbl.text = recordLabel_lbl_string;
    [editView addSubview:recordLabel_lbl];
    
    editRecordLabel = [[UITextField alloc] initWithFrame:CGRectMake(180, 240, 300, 20)];
    editRecordLabel.text = recordLabel;
    editRecordLabel.borderStyle = UITextBorderStyleLine;
    [editView addSubview:editRecordLabel];
    
    
    
    [editBackingView addSubview:editAlphaEffect];
    [editBackingView addSubview:editView];
    
    
    //Perform animation and show the edit UIView
    
    [UIView transitionFromView:[self.view viewWithTag:4455] toView: editBackingView duration:0.4 options:UIViewAnimationOptionTransitionFlipFromLeft completion:NULL];
    
    
}


- (void)deleteAlbumItem: (UIButton*)sender
{
   
    //Delete the album from the Core Data
    
    RecordCollection *recordCollectionViewItem = (RecordCollection*)[recordCollectionView objectAtIndex:sender.tag];
    
    NSString *fileName = [recordCollectionViewItem coverImage];

    
    NSManagedObject *deleteAlbumRecords = (NSManagedObject*)[recordCollectionView objectAtIndex:sender.tag];
    
    [self.managedObjectContext deleteObject:deleteAlbumRecords];
    
    NSError *deleteError = nil;
    
    if (![deleteAlbumRecords.managedObjectContext save:&deleteError]) {
        NSLog(@"Unable to delete record album.");
        NSLog(@"%@, %@", deleteError, deleteError.localizedDescription);
    }else{
        
    }
    
    
    //Delete the file from the document
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filePath = [documentsPath stringByAppendingPathComponent:fileName];
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:filePath error:&error];
    if (success) {
        [recordCollectionView removeObjectAtIndex:sender.tag];
        
        NSArray *selectedItemIndexPaths = [self.collectionView indexPathsForSelectedItems];
        
        [self.collectionView deleteItemsAtIndexPaths: selectedItemIndexPaths];
    }
    else
    {
        NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
    }
    
     NSLog(@"Item removed");
     
     [self.collectionView reloadData];
    
    [[self.view viewWithTag:4455] removeFromSuperview];
    
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    [self.view endEditing:YES];
}

- (IBAction)btnAddAlbum:(id)sender
{
        
}

- (UIImage*)loadImage: (NSString*)imageName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:
                      [NSString stringWithString:imageName] ];
    UIImage* image = [UIImage imageWithContentsOfFile:path];
    return image;
}

-(void)changeAlbumCoverImage
{
    albumCoverChanged = true;
    self.imagePicker = [[UIImagePickerController alloc]init];
    self.imagePicker.delegate = self;
    self.imagePicker.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)editInfo {
    
    NSLog(@"picked");
    
    self.chosenImage = editInfo[UIImagePickerControllerOriginalImage];
    [coverImgView setImage:self.chosenImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
}


-(void)updateRecords: (UIButton*)sender
{
    NSString *imgCoverName = oldCoverImage;
    
    
    if(albumCoverChanged)
    {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat: @"yyyy-MM-dd_HH:mm:ss"];
        
        NSDate *date = [[NSDate alloc] init];
        NSString *stringFromDate = [formatter stringFromDate:date];
        
        imgCoverName  = [[NSString alloc] initWithFormat:@"%@%@%@%@%@%@", editAlbumName.text, @"_", editArtistName.text, @"_", stringFromDate,@".jpg"];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *savedImagePath = [documentsDirectory stringByAppendingPathComponent:imgCoverName];
        UIImage *image = coverImgView.image;
        NSData *imageData = UIImageJPEGRepresentation(image, 0.6);
        [imageData writeToFile:savedImagePath atomically:NO];
        
        
        //Delete old cover image
        
        NSString *fileName = oldCoverImage;
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        NSString *filePath = [documentsPath stringByAppendingPathComponent:fileName];
        NSError *error;
        BOOL success = [fileManager removeItemAtPath:filePath error:&error];
        if (success) {
            NSLog(@"Item removed");
        }
        else
        {
            NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
        }
    }
    
    //Update the records in the Core Data
    
    NSManagedObject *updateAlbumRecords = (NSManagedObject*)[recordCollectionView objectAtIndex:sender.tag];
    
    [updateAlbumRecords setValue:editArtistName.text forKeyPath:@"artistName"];
    [updateAlbumRecords setValue:editAlbumName.text forKeyPath:@"albumName"];
    [updateAlbumRecords setValue:editYearReleased.text forKeyPath:@"yearReleased"];
    [updateAlbumRecords setValue:editRecordLabel.text forKeyPath:@"recordLabel"];
    [updateAlbumRecords setValue:imgCoverName forKeyPath:@"coverImage"];
    
    NSError *editError = nil;
    
    if(![updateAlbumRecords.managedObjectContext save:&editError]){
        
        NSLog(@"Error on updating");
        NSLog(@"%@, %@", editError, editError.localizedDescription);
    }

    
    [self.collectionView reloadData];
    
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Update Complete!"
                                                      message:@"The album information stored sucessfully"
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    
    [message show];
    
    [[self.view viewWithTag:2266] removeFromSuperview];
    

 
}


-(void)closeEditView
{
    [self.collectionView reloadData];
    [[self.view viewWithTag:2266] removeFromSuperview];
}


@end
