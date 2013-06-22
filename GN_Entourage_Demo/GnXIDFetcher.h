//
//  GnXIDFetcher.h
//  GN_ACR_SDK
//
//  Created by Gracenote on 1/4/13.
//
//

/**
     @brief This class simplifies the interface for retrieving external ID's associated with GN metadata objects. Note: The fetch methods perform a synchronous network operation and should be called from a background thread
 */
#import <Foundation/Foundation.h>

@class GnAcrMatch;
@class GnTvChannel;
@class GnTvProgram;
@class GnUser;

@interface GnXIDFetcher : NSObject
{
    GnUser*  mUser;
}

@property (nonatomic, retain) GnUser*  user;

/**
    @brief Initializer method
    @param user The global GnUser object that was initialized with your Entourage client id
 */
- (id)initWithUser:(GnUser*)user;

/**
    @brief Fetch external ID's attached to a TV Channel. This API performs a synchronous network operation and should be called from a background thread
    @param channel The channel you want to retrieve external ID's for
    @param source The preferred external ID source (e.g. "tmsid"). Results will only include external ID's from this source. Can be nil.
    @param error On failure an NSError object containing error information
 
    @return An NSArray containing GnExternalID's. May be nil in case of an error or when no external ID's are found
 */
- (NSArray*)fetchTvChannelXIDs:(GnTvChannel*)channel preferredSource:(NSString*)source error:(NSError**)error;

/**
 @brief Fetch external ID's attached to a GnTvProgram. This API performs a synchronous network operation and should be called from a background thread
 @param program The GnTvProgram you want to retrieve external ID's for
 @param source The preferred external ID source (e.g. "tmsid"). Results will only include external ID's from this source. Can be nil.
 @param error On failure an NSError object containing error information
 
 @return An NSArray containing GnExternalID's. May be nil in case of an error or when no external ID's are found
 */
- (NSArray*)fetchTvProgramXIDs:(GnTvProgram*)program preferredSource:(NSString*)source error:(NSError**)error;


/**
 @brief Fetch external ID's attached to a GnVideoWork. This API performs a synchronous network operation and should be called from a background thread
 @param GnAcrMatch The match containing the GnVideoWork you want to retrieve external ID's for
 @param source The preferred external ID source (e.g. "tmsid"). Results will only include external ID's from this source. Can be nil.
 @param error On failure an NSError object containing error information
 
 @return An NSArray containing GnExternalID's. May be nil in case of an error or when no external ID's are found
 */
- (NSArray*)fetchVideoWorkXIDs:(GnAcrMatch*)match preferredSource:(NSString*)source error:(NSError**)error;

@end




