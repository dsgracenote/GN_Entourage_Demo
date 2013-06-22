//
//  GnMetadataImage.m
//  GN_ACR_SDK
//
//  Created by Gracenote on 12/27/12.
//
//

#import "GnMetadataImage.h"
#import <GracenoteACR/GnMetadataObject.h>
#import <GracenoteACR/GnUser.h>
#import <GracenoteACR/GnLink.h>

@implementation GnMetadataImage

@synthesize imageData = mImage;


- (id)initWithMetadataObject:(GnMetadataObject*)object user:(GnUser*)user preferredSizes:(NSArray*)imageSizes
{

    self = [super init];
    if (self) {
        
        mImage = nil;
        [[object retain] autorelease];
        [[imageSizes retain] autorelease];
        [[user retain] autorelease];
        
        NSError *err = nil;
        GnLink *link = [[GnLink alloc] initWithMetadataObject:object user:user error:&err];
        
        if (err) {
            NSLog(@"Error creating GnLink object %d, %@", [err code], [err localizedDescription]);
            return nil;
        }
        
        if (link.imageItemCount > 0) {
            NSUInteger sizesLength = imageSizes.count;
            for (int i = 0; i < sizesLength; ++i) {
                
                mImage = [link getImageOfSize:[imageSizes objectAtIndex:i] error:&err];
                if (err) {
                    NSLog(@"Error getting Image (%@), %d", [err localizedDescription],[err code]);
                }
                
                if (mImage) {
                    [mImage retain];
                    break;
                }
            }
        }
        else
            NSLog(@"No Images Available for GnMetadataObject");
        
        
    }
         
    return self;
}



- (void)dealloc
{
    [super dealloc];
    if (mImage)
    {
        [mImage release];
    }
    mImage = nil;
    
}



@end

