//
//  GNViewController.m
//  GN_Entourage_Demo
//
//  
//  Copyright (c) 2013 Gracenote. All rights reserved.
//

#import "GNViewController.h"
#import <GracenoteACR/GnSdkManager.h>
#import <GracenoteACR/GnUser.h>
#import <GracenoteACR/GnAcrAudioConfig.h>
#import <GracenoteACR/GnAcrMatch.h>

/*** Enter your client id, client tag, and license info here ***/
#define CLIENT_ID  @""
#define CLIENT_TAG  @""
#define LICENSE_INFO  @""



@interface GNViewController ()

@property (nonatomic, retain) GnSdkManager          *sdkManager;
@property (nonatomic, retain) GnACR                 *acr;
@property (nonatomic, retain) GnAudioSourceiOSMic   *audioSource;
@property (nonatomic, retain) GnUser                *acrUser;
@property (nonatomic)         BOOL                  isListening;

@end

@implementation GNViewController

@synthesize matchResultView     = _matchResultView;
@synthesize statusView          = _statusView;
@synthesize sdkManager          = _sdkManager;
@synthesize acr                 = _acr;
@synthesize audioSource         = _audioSource;
@synthesize acrUser             = _acrUser;
@synthesize isListening         = _isListening;



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Initialize the Entourage SDK
    self.sdkManager = [[GnSdkManager alloc] initWithLicense:LICENSE_INFO error:nil];
    
    self.acrUser = [self getUserACR];
    if (!self.acrUser) {
        NSLog(@"Error: Invalid User");
    }
    
    // Create a GnAcr object for this user
    self.acr = [[GnACR alloc] initWithUser:self.acrUser error:nil];
    
    // Set up an audio configuration
    GnAcrAudioConfig *config =
    [[[GnAcrAudioConfig alloc] initWithAudioSourceType:GnAcrAudioSourceMic
                                            sampleRate:GnAcrAudioSampleRate44100
                                                format:GnAcrAudioSampleFormatPCM16
                                           numChannels:1] autorelease];
    
    // Initialize the GnAcr's audio configuration
    [self.acr audioInitWithAudioConfig:config];
    
    // Initialize the audio source (i.e. device microphone)
    self.audioSource = [[GnAudioSourceiOSMic alloc] initWithAudioConfig:config];
    
    // Assign the delegates
    self.audioSource.audioDelegate = self;
    self.acr.resultDelegate = self;
    self.acr.statusDelegate = self;
    
    self.isListening = NO;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(GnUser*)getUserACR {
    NSError *error = nil;
    GnUser *user = nil;
    NSString *savedUser = [[NSUserDefaults standardUserDefaults] objectForKey:@"StoredUserKey"];
    
    if (savedUser)
    {
        user = [[GnUser alloc] initWithSerializedUser:savedUser error:&error];
    }
    else
    {
        user  = [[GnUser alloc] initWithClientId:CLIENT_ID
                                     clientIdTag:CLIENT_TAG
                                      appVersion:@"any string you prefer, e.g. '1.0'"
                                registrationType:GnUserRegistrationType_NewUser error:&error];
        
        if (user) {
            [[NSUserDefaults standardUserDefaults] setObject:user.serializedUser
                                                      forKey:@"StoredUserKey"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    
    if (error) {
        NSLog(@"%@", [NSString stringWithFormat:@"getUserACR: ERROR: %@", error.localizedDescription]);
    }
    return user;
}



-(void)audioBytesReady:(void const * const)bytes length:(int)length
{
    // this callback is called from a background thread. It is important to not block this
    // callback for very long. It is advised to offload UI updates and expensive computations to the main thread.
    NSError *error = nil;
    
    error = [self.acr writeBytes:bytes length:length];
    if (error) {
        NSLog(@"audioBytesReady error: %@", error);
    }
}


-(void)acrResultReady:(GnResult*)result
{
    @autoreleasepool {
        // ACR query results will be returned in this callback
        // Below is an example of how to access the result metadata.
        
        // These callbacks may occur on threads other than the main thread.
        // Be careful not to block these callbacks for long periods of time.
        
        NSEnumerator *matches = result.acrMatches;
        
        // For this example we're only looking at the first match, but there could be multiple
        // matches in a result
        NSString *textToDisplay = @"";
        GnAcrMatch *match = [matches nextObject];
        if (!match)
        {
            textToDisplay = @"NO MATCH";
        } else {
            textToDisplay = match.title.display;
        }
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.matchResultView.text = textToDisplay;
        });
    }
}


-(void)acrStatusReady:(GnAcrStatus *)status
{
    @autoreleasepool {
        // This status callback will be called periodically with status from the ACR subsystem
        // You can use these statuses as you like.
        
        // These callbacks may occur on threads other than the main thread.
        // Be careful not to block these callbacks for long periods of time.
        
        // Not all statuses are enumerated here. SDK documentation contains all of the possible
        // GnAcrStatus values
        
        NSString *message = nil;
        
        switch (status.statusType) {
            case GnAcrStatusTypeSilent:
                message = [NSString stringWithFormat:@"Audio Silent %10.2f", status.value];
                break;
            case GnAcrStatusTypeSilentRatio:
                message = [NSString stringWithFormat:@"Silent Ratio %10.3f", status.value];
                break;
            case GnAcrStatusTypeError:
                message = [NSString stringWithFormat:@"ERROR %@ (0x%x)", [status.error localizedDescription], status.error.code];
                break;
            case GnAcrStatusTypeMusic:
                message = [NSString stringWithFormat:@"Audio Music"];
                break;
            case GnAcrStatusTypeNoise:
                message = [NSString stringWithFormat:@"Audio Noise"];
                break;
            case GnAcrStatusTypeSpeech:
                message = [NSString stringWithFormat:@"Audio Speech"];
                break;
            case GnAcrStatusTypeOnlineLookupComplete:
                message = [NSString stringWithFormat:@"Online Lookup Complete"];
                break;
            case GnAcrStatusTypeQueryBegin:
                message = [NSString stringWithFormat:@"Online Query Begin"];
                break;
            case GnAcrStatusTypeRecordingStarted:
                message = [NSString stringWithFormat:@"Recording Started"];
                break;
            case GnAcrStatusTypeTransition:
                message = [NSString stringWithFormat:@"Transition"];
                break;
            default:
                break;
        }
        
        if (message != nil) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.statusView.text = message;
            });
        }
    }
}



-(IBAction)toggleListening:(id)sender
{
    UIButton *toggleButton = (UIButton*)sender;
    if (!self.isListening) {
        [self.audioSource start];
        [toggleButton setTitle:@"Stop Listening" forState:UIControlStateNormal];
    } else {
        [self.audioSource stop];
        [toggleButton setTitle:@"Start Listening" forState:UIControlStateNormal];
        self.statusView.text = @"";
        self.matchResultView.text = @"";
    }

    self.isListening = !self.isListening;
}


@end
