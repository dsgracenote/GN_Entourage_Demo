//
//  GnMetadataImage.h
//  GN_ACR_SDK
//
//  Created by Gracenote on 12/27/12.
//
//


/**
    @brief This class is intended to provide a simple interface for accessing GnMetadataObject images.
 
    @description This class fetches and stores image for a GnMetadata object.  The initWithObject method fetches the image.  Because the image fetch is synchronous you should create and initialize these objects on a background thread
 
    @see GnMetadataObject, GnLink
 */


#import <Foundation/Foundation.h>

@class GnMetadataObject;
@class GnUser;

@interface GnMetadataImage : NSObject
{
    NSData *mImage;
}

@property (nonatomic, readonly) NSData *imageData;

/**
    @brief          Init method for retrieving an image
    @description    The initWithObject method will fetch and store the metadata image.  The image fetched will be the first image available of the sizes given in the imageSizes array.  Because the image fetch is a synchronous network operation these objects should be initialized on a background thread.
 
    @param object The GnMetadataObject you want to retrieve an image for.  Supported objects are GnVideoWork, GnTvProgram, GnContributor, and GnTvChannel
 
    @param user The global GnUser object for the application instance
 
    @param imageSizes An array of preferred image sizes as defined in GnLink.h.  The image retrieved will be the first occurence of an image matching the size in the imageSizes array.  You can prioritize size(s) by sorting them to the top of the array.
  
 */
- (id)initWithMetadataObject:(GnMetadataObject*)object user:(GnUser*)user preferredSizes:(NSArray*)imageSizes;

@end
