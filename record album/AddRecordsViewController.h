//
//  AddRecordsViewController.h
//  record album
//
//  Created by Krishan on 8/16/15.
//  Copyright (c) 2015 Romp. All rights reserved.
//

#import "ViewController.h"
#import <CoreData/CoreData.h>
#import "AppDelegate.h"


@interface AddRecordsViewController : ViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate>

- (IBAction)btnAddCoverImage:(id)sender;
@property (strong, nonatomic) UIImage *chosenImage;
@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (weak, nonatomic) IBOutlet UIImageView *imgCoverImage;
- (IBAction)btnSaveRecords:(id)sender;


@property (strong, nonatomic) IBOutlet UITextField *txtArtistName;
@property (strong, nonatomic) IBOutlet UITextField *txtAlbumName;
@property (strong, nonatomic) IBOutlet UITextField *txtYearReleased;
@property (strong, nonatomic) IBOutlet UITextField *txtRecordLabel;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectedModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;


@end
