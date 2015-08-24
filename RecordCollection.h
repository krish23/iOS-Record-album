//
//  RecordCollection.h
//  record album
//
//  Created by Krishan on 8/20/15.
//  Copyright (c) 2015 Romp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface RecordCollection : NSManagedObject

@property (nonatomic, retain) NSNumber * albumID;
@property (nonatomic, retain) NSString * artistName;
@property (nonatomic, retain) NSString * albumName;
@property (nonatomic, retain) NSString * yearReleased;
@property (nonatomic, retain) NSString * recordLabel;
@property (nonatomic, retain) NSString * coverImage;

@end
