//
//  MessagesViewController.m
//  cardgame
//
//  Created by Steele on 2014-08-31.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "MessagesViewController.h"
#import "CardView.h"

@interface MessagesViewController ()

@end

@implementation MessagesViewController

int SCREEN_WIDTH, SCREEN_HEIGHT;

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    SCREEN_WIDTH = self.view.bounds.size.width;
    SCREEN_HEIGHT = self.view.bounds.size.height;
    
    //background view
    UIImageView*backgroundImageTop = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"screen_background_top"]];
    backgroundImageTop.frame = CGRectMake(0, 0, SCREEN_WIDTH, 40);
    [self.view addSubview:backgroundImageTop];
    
    UIImageView*backgroundImageMiddle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"screen_background_center"]];
    backgroundImageMiddle.frame = CGRectMake(0, 40, SCREEN_WIDTH, SCREEN_HEIGHT - 40 - 40);
    [self.view addSubview:backgroundImageMiddle];
    
    UIImageView*backgroundImageBottom = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"screen_background_bottom"]];
    backgroundImageBottom.frame = CGRectMake(0, SCREEN_HEIGHT-40, SCREEN_WIDTH, 40);
    [self.view addSubview:backgroundImageBottom];
    
    CFLabel*menuLogoBackground = [[CFLabel alloc] initWithFrame:CGRectMake(0,0,250,60)];
    menuLogoBackground.center = CGPointMake(SCREEN_WIDTH/2, 70);
    menuLogoBackground.label.textAlignment = NSTextAlignmentCenter;
    [menuLogoBackground setTextSize:30];
    menuLogoBackground.label.text = @"Messages";
    [self.view addSubview:menuLogoBackground];
    
    CFLabel*messageTitlesBackground = [[CFLabel alloc] initWithFrame:CGRectMake(0, 0, 250, SCREEN_HEIGHT/2 - 110)];
    messageTitlesBackground.center = CGPointMake(SCREEN_WIDTH/2, 110+messageTitlesBackground.frame.size.height/2);
    [self.view addSubview:messageTitlesBackground];
    
    _messageTableView = [[MessageTableView alloc] initWithFrame:CGRectInset(messageTitlesBackground.frame, 6, 6)];
    /*
    MessageModel *dummy = [[MessageModel alloc] init];
    dummy.title = @"title 1";
    dummy.body = @"body asdfas dfa sdfa sdfsfg\n adfas dfasd fasd asdf asdf asdf asdf asf ";
    [_messageTableView.currentMessages addObject:dummy];
     */
    _messageTableView.currentMessages = [self.messagesRetrieved mutableCopy];
    
    [_messageTableView.tableView reloadData];
    [_messageTableView.tableView reloadInputViews];
    _messageTableView.parent = self;
    [self.view addSubview:_messageTableView];
    
    CFLabel*messageBodyBackground = [[CFLabel alloc] initWithFrame:CGRectMake(0, 0, 250, SCREEN_HEIGHT/2 - 60)];
    messageBodyBackground.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2+messageBodyBackground.frame.size.height/2 + 5);
    [self.view addSubview:messageBodyBackground];
    
    _messageBodyView = [[UITextView alloc] initWithFrame:CGRectInset(messageBodyBackground.frame, 6, 6)];
    [_messageBodyView setFont:[UIFont fontWithName:cardMainFont size:16]];
    [_messageBodyView setTextColor:[UIColor whiteColor]];
    _messageBodyView.backgroundColor = [UIColor clearColor];
    [_messageBodyView setDelegate:self];
    [self.view addSubview:_messageBodyView];
    
    UIButton* backButton = [[CFButton alloc] initWithFrame:CGRectMake(35, SCREEN_HEIGHT - 32 - 20, 46, 32)];
    [backButton setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
}

-(void)selectedMessage:(PFObject*)message
{
    NSString *bodyText = [message objectForKey:@"body"];
    
    [_messageBodyView setText:bodyText];
    
}

-(void)backButtonPressed
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

-(void)textViewDidBeginEditing:(UITextView *)textView{
    //not editable
    [textView resignFirstResponder];
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

@end
