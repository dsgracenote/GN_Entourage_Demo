//
//  GnXIDFetcher.m
//  GN_ACR_SDK
//
//  Created by Gracenote on 1/4/13.
//
//

#import "GnXIDFetcher.h"
#import <GracenoteACR/GnAcr.h>
#import <GracenoteACR/GnAcrMatch.h>
#import <GracenoteACR/GnTvAiring.h>
#import <GracenoteACR/GnUser.h>
#import <GracenoteACR/GnTvProgram.h>
#import <GracenoteACR/GnVideoWork.h>
#import <GracenoteACR/GnTvChannel.h>
#import <GracenoteACR/GnExternalID.h>
#import <GracenoteACR/GnEpg.h>
#import <GracenoteACR/GnVideo.h>


@implementation GnXIDFetcher


@synthesize user = mUser;

- (id)initWithUser:(GnUser*)user{
    self = [super init];
    if (self) {
        
        self.user = user;
        
    }
    
    return self;
}



- (NSArray*)fetchTvChannelXIDs:(GnTvChannel*)channel preferredSource:(NSString*)source error:(NSError**)error
{
    NSMutableArray *channelIDs = [NSMutableArray array];
    
    GnEpg *epg = [[GnEpg alloc] initWithUser:self.user error:error];
    if (error && *error)
    {
        return nil;
    }
    
    epg.enableLinkData = YES;
    GnResult *result = [epg findChannelsWithChannel:channel error:error];
    if (error && *error)
    {
        return nil;
    }
    
    for (GnTvChannel *channel in result.tvChannels) {
        
        for (GnExternalID *xid in channel.externalIDs) {
            
            if (source == nil || [xid.source isEqualToString:source])
            {
                [channelIDs addObject:xid];
            }
        }
    }
    
    return (NSArray*)[[channelIDs copy] autorelease];
    
}



- (NSArray*)fetchTvProgramXIDs:(GnTvProgram*)program preferredSource:(NSString*)source error:(NSError**)error
{
    NSMutableArray *programIDs = [NSMutableArray array];
    
    GnEpg *epg = [[GnEpg alloc] initWithUser:self.user error:error];
    if (error && *error)
    {
        return nil;
    }
    
    epg.enableLinkData = YES;
    GnResult *result = [epg findProgramsWithProgram:program error:error];
    if (error && *error)
    {
        return nil;
    }
    
    for (GnTvProgram *program in result.tvPrograms) {
        
        for (GnExternalID *xid in program.externalIDs) {
            
            if (source == nil || [xid.source isEqualToString:source])
            {
                [programIDs addObject:xid];
            }
        }
    }

    return [(NSArray*)[programIDs copy] autorelease];
}



- (NSArray*)fetchVideoWorkXIDs:(GnAcrMatch*)match preferredSource:(NSString*)source error:(NSError**)error
{
    GnResult *result = nil;
    
    NSMutableArray *workIDs = [NSMutableArray array];
    GnVideo *video = [[GnVideo alloc] initWithUser:self.user error:error];
    if (error && *error)
    {
        return nil;
    }
    
    video.enableLinkData = YES;
    
    if (match.avWork != nil)
    {
        // Match came from VOD database
        result = [video findWorksWithWork:match.avWork error:error];
        if (error && *error)
        {
            return nil;
        }
    }
    else
    {
        // Match came from tv broadcast
        
        // First fetch full TVProgram
        GnEpg *epg = [[GnEpg alloc] initWithUser:self.user error:error];
        if (error && *error)
        {
            return nil;
        }
        
        GnResult *epgResult = [epg findProgramsWithProgram:match.tvAiring.tvProgram error:error];
        if (error && *error)
        {
            return nil;
        }
        
        GnTvProgram *program = (GnTvProgram*)epgResult.tvPrograms.nextObject;
        
        // Now retrieve VideoWork
        if (program.avWork != nil)
        {
            result = [video findWorksWithWork:program.avWork error:error];
            if (error && *error)
            {
                return nil;
            }
            
        }
        
    }
    
    for (GnVideoWork *work in result.videoWorks)
    {
        for (GnExternalID *xid in work.externalIDs) {
            
            if (source == nil || [xid.source isEqualToString:source])
            {
                [workIDs addObject:xid];
            }
        }
    }
    
    return [(NSArray*)[workIDs copy] autorelease];
}


@end
