//
//  RecordCollectionViewController.h
//  record album
//
//  Created by Krishan on 8/12/15.
//  Copyright (c) 2015 Romp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecordCollectionViewController : UICollectionViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate ,UITextFieldDelegate>

-(UIImage*)snapshotImage;
- (IBAction)btnAddAlbum:(id)sender;
@property (strong, nonatomic) UIImage *chosenImage;
@property (strong, nonatomic) UIImagePickerController *imagePicker;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectedModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSMutableArray *recordCollectionView;


@end
