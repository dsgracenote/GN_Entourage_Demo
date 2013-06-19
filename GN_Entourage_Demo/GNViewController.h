//
//  GNViewController.h
//  GN_Entourage_Demo
//
//  Copyright (c) 2013 Gracenote. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GracenoteACR/GnACR.h>
#import <GracenoteACR/GnAudioSourceiOSMic.h>
#import <GracenoteACR/GnResult.h>

@interface GNViewController : UIViewController <IGnAcrResultDelegate, IGnAcrStatusDelegate, GnAudioSourceDelegate>


@property (retain) IBOutlet UITextView *matchResultView;
@property (retain) IBOutlet UITextView *statusView;

-(IBAction)toggleListening:(id)sender;

@end

