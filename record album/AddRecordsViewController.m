//
//  AddRecordsViewController.m
//  record album
//
//  Created by Krishan on 8/16/15.
//  Copyright (c) 2015 Romp. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "AddRecordsViewController.h"
#import "RecordCollectionViewController.h"
#import "AppDelegate.h"
#import "RecordCollection.h"

@interface AddRecordsViewController ()

@end

@implementation AddRecordsViewController
{
    CGFloat animatedDistance;
}
@synthesize imgCoverImage;
@synthesize txtArtistName;
@synthesize txtAlbumName;
@synthesize txtRecordLabel;
@synthesize txtYearReleased;

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectedModel = _managedObjectedModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;




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
    // Do any additional setup after loading the view.
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    _managedObjectContext = [appDelegate managedObjectContext];
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"add_bg.JPG"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
    
    self.txtAlbumName.delegate = self;
    self.txtRecordLabel.delegate = self;
    self.txtYearReleased.delegate = self;
    
    imgCoverImage.image = [UIImage imageNamed:@"empty_album.jpg"];
    
    
    
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect textFieldRect =
    [self.view.window convertRect:textField.bounds fromView:textField];
    CGRect viewRect =
    [self.view.window convertRect:self.view.bounds fromView:self.view];
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator =
    midline - viewRect.origin.y
    - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator =
    (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION)
    * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
    
    if (heightFraction < 0.0)
    {
        heightFraction = 0.0;
    }
    else if (heightFraction > 1.0)
    {
        heightFraction = 1.0;
    }
    
    UIInterfaceOrientation orientation =
    [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    }
    else
    {
        animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
    
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


- (IBAction)btnAddCoverImage:(id)sender
{
    self.imagePicker = [[UIImagePickerController alloc]init];
    self.imagePicker.delegate = self;
    self.imagePicker.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)editInfo {
    
    NSLog(@"picked");
    
    self.chosenImage = editInfo[UIImagePickerControllerOriginalImage];
    [self.imgCoverImage setImage:self.chosenImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    [self.view endEditing:YES];
}

- (IBAction)btnSaveRecords:(id)sender
{
    
    //Save the records
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *date = [[NSDate alloc] init];
    NSString *stringFromDate = [formatter stringFromDate:date];
    
    NSString *imgCoverName = [[NSString alloc] initWithFormat:@"%@%@%@%@%@%@", txtAlbumName.text, @"_", txtArtistName.text, @"_", stringFromDate,@".jpg"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *savedImagePath = [documentsDirectory stringByAppendingPathComponent:imgCoverName];
    UIImage *image = imgCoverImage.image;
    NSData *imageData = UIImageJPEGRepresentation(image, 0.6);
    [imageData writeToFile:savedImagePath atomically:NO];
    
    
    
    RecordCollection *recordCollection = [NSEntityDescription insertNewObjectForEntityForName:@"RecordCollection" inManagedObjectContext:_managedObjectContext];
    
    [recordCollection setArtistName:txtArtistName.text];
    [recordCollection setAlbumName:txtAlbumName.text];
    [recordCollection setRecordLabel:txtRecordLabel.text];
    [recordCollection setYearReleased:txtYearReleased.text];
    [recordCollection setCoverImage:imgCoverName];
    
    NSError *error = nil;
    if(![_managedObjectContext save:&error]){
        NSLog(@"Error on Core Date");
    }
}


@end
