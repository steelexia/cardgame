//
//  SceneObjCViewController.m
//  cardgame
//
//  Created by Brian Allen on 6/22/16.
//  Copyright © 2016 Content Games. All rights reserved.
//

#import "SceneObjCViewController.h"
#import "GameViewController.h"
#import "Campaign.h"
@import SceneKit;
@import SpriteKit;
@interface SceneObjCViewController ()
@property (nonatomic) SCNNode *cameraNode;
@property (nonatomic) SCNCamera *firstCam;
@property (nonatomic) SCNNode *secondaryCamera;
@property (nonatomic) SCNCamera *secondCam;
@property (nonatomic) SCNView *myView;
@property (nonatomic) BOOL isZoomed;

@end

@implementation SceneObjCViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.myView = [[SCNView alloc] init];
    self.myView.frame = self.view.frame;
   
    self.myView.scene = [SCNScene sceneNamed:@"battle_bg.dae"];
    
    self.isZoomed = FALSE;
    
    self.secondaryCamera = [SCNNode node];
    self.secondaryCamera.position = SCNVector3Make(0, 0, 440);
    self.secondaryCamera.rotation = SCNVector4Zero;
    self.secondCam = [SCNCamera camera];
    self.secondCam.zNear = 109;
    self.secondCam.zFar = 27350;
    self.secondCam.yFov = 70;
    self.secondaryCamera.camera = self.secondCam;
    //self.cameraNode.camera.zNear = 109;
    //self.cameraNode.camera.zFar = 27350;
    [self.myView.scene.rootNode addChildNode:self.secondaryCamera];

    self.cameraNode = [SCNNode node];
    self.cameraNode.position = SCNVector3Make(0,0,840);
    self.cameraNode.rotation = SCNVector4Zero;
    self.cameraNode.camera = self.secondCam;
    //self.cameraNode = self.myView.pointOfView;
    [self.myView.scene.rootNode addChildNode:self.cameraNode];
    
    SCNNode *povNode = self.myView.pointOfView;
    povNode.position = SCNVector3Make(0,0,840);
    SCNCamera *checkCamDetails = povNode.camera;
    
    self.myView.pointOfView = povNode;
    
    SCNScene *cfButtonScene = [SCNScene sceneNamed:@"battle_button.dae"];
    SCNVector3 cfButtonVector = cfButtonScene.rootNode.position;
    cfButtonVector.z +=00;
    [cfButtonScene.rootNode setPosition:cfButtonVector];
    
    
    for (SCNNode* objectNode in cfButtonScene.rootNode.childNodes)
    {
        [self.myView.scene.rootNode addChildNode:objectNode];
    }
    
    
    SCNScene *enemy_life = [SCNScene sceneNamed:@"battle_enemy_life.dae"];
    [self.myView.scene.rootNode addChildNode:enemy_life.rootNode];
    
    SCNScene *playerLife = [SCNScene sceneNamed:@"battle_player_life.dae"];
    [self.myView.scene.rootNode addChildNode:playerLife.rootNode];
    
    SCNScene *enemyCardArea = [SCNScene sceneNamed:@"enemy_played_card.dae"];
    [self.myView.scene.rootNode addChildNode:enemyCardArea.rootNode];
    
    SCNScene *enemyMana = [SCNScene sceneNamed:@"battle_enemy_mana.dae"];
    [self.myView.scene.rootNode addChildNode:enemyMana.rootNode];
    
    SCNScene *playerMana = [SCNScene sceneNamed:@"battle_player_mana.dae"];
    [self.myView.scene.rootNode addChildNode:playerMana.rootNode];
    
    SCNScene *playerPortrait = [SCNScene sceneNamed:@"battle_player_portrait.dae"];
    [self.myView.scene.rootNode addChildNode:playerPortrait.rootNode];
    
    SCNScene *enemyPortrait = [SCNScene sceneNamed:@"battle_enemy_portrait.dae"];
    [self.myView.scene.rootNode addChildNode:enemyPortrait.rootNode];
    
   //povCamera.xFov = 20;
   //povCamera.yFov = 95;
    
    SCNCamera *povCamera = self.myView.pointOfView.camera;

    povCamera.xFov = 00;
    povCamera.yFov = 70;

    //15,120,1400
    //7, 45, 8, 115, 1300
    //7,45,8, 85, 1300
    //7,45,8,175,13
    
    //meeting with kyoung: 20 xFov, y95Fov
    
    //aug 28 values
    //pov x 10, y 70
    //SCNVector3 myCamPosition = SCNVector3Make(10,100,840);
    
    [self.myView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(screenTapped:)]];
    
    self.myView.allowsCameraControl = YES;
    self.myView.autoenablesDefaultLighting = YES;
    self.myView.backgroundColor = [UIColor lightGrayColor];

    [self.view addSubview:self.myView];
    
    Level*level = [Campaign getLevelWithDifficulty:1 withChapter:4 withLevel:1];
    
    GameViewController *gvc = [[GameViewController alloc] initWithGameMode:GameModeSingleplayer withLevel:level];
    gvc.noPreviousView = YES;
    
    //[self.myView addSubview:gvc.view];
    
}

-(void)screenTapped:(UITapGestureRecognizer *)tap
{
    //do stuff
    
    if(self.isZoomed == FALSE)
    {
        [SCNTransaction begin];
        [SCNTransaction setAnimationDuration:2.5];
        SCNNode *oldNode = self.myView.pointOfView;
        SCNCamera *oldNodeCamera = oldNode.camera;
        
        self.myView.pointOfView = self.secondaryCamera;
        SCNCamera *newCamera = self.secondaryCamera.camera;
          self.isZoomed = TRUE;
        [SCNTransaction commit];
      
    }
    else
    {
        [SCNTransaction begin];
        [SCNTransaction setAnimationDuration:2.5];
        SCNNode *oldNode = self.myView.pointOfView;
        SCNCamera *oldNodeCamera = oldNode.camera;
        self.myView.pointOfView = self.cameraNode;
        SCNCamera *newCamera = self.cameraNode.camera;
        self.isZoomed = FALSE;
        [SCNTransaction commit];
        
    }
    
}
-(void)viewDidAppear:(BOOL)animated
{
    /*
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:12.0];
    SCNNode *povNode = myView.pointOfView;
    SCNVector3 myCamPosition = SCNVector3Make(10,100,840);
    povNode.position = myCamPosition;
    
    [SCNTransaction commit];
     */
    [super viewDidAppear:animated];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
   // SCNVector3 myCamPosition = SCNVector3Make(10,100,840);
    
   
    
    CGPoint location = [[touches anyObject] locationInView:self.view];
    CGRect fingerRect = CGRectMake(location.x-5, location.y-5, 10, 10);
    
    for(UIView *view in self.view.subviews){
        CGRect subviewFrame = view.frame;
        
        if(CGRectIntersectsRect(fingerRect, subviewFrame)){
            //we found the finally touched view
            NSLog(@"Yeah !, i found it %@",view);
        }
        
    }

    SCNQuaternion myQuat =  self.myView.pointOfView.orientation;
    SCNVector3 myPos = self.myView.pointOfView.position;
    NSString *strX = [NSString stringWithFormat:@"%f", myPos.x];
 NSString *strY = [NSString stringWithFormat:@"%f", myPos.y];
     NSString *strZ = [NSString stringWithFormat:@"%f", myPos.z];
  
    NSLog([@"positionx" stringByAppendingString:strX]);
      NSLog([@"positiony" stringByAppendingString:strY]);
    NSLog([@"positionZ" stringByAppendingString:strZ]);
    
   double xFov=  self.myView.pointOfView.camera.xFov;
    double yFov = self.myView.pointOfView.camera.yFov;
    
    NSString *strfovY = [NSString stringWithFormat:@"%f", xFov];
    NSString *strfovZ = [NSString stringWithFormat:@"%f", yFov];
    
    NSLog([@"positiony" stringByAppendingString:strfovY]);
    NSLog([@"positionZ" stringByAppendingString:strfovZ]);
    
    //[povNode setPosition:myCamPosition];
    //[myView.pointOfView setPosition:myCamPosition];
    
}

/*
override func touchesEnded(touches: NSSet!, withEvent event: UIEvent!) {
    //
    // In this delegate, you can get the positions and orientations of camera
    // when setting allowsCameraControl to true.
    //
    let quaternion = myView?.pointOfView.orientation
    let position = myView?.pointOfView.position
    println("Orientation: (\(quaternion?.x),\(quaternion?.y),\(quaternion?.z),\(quaternion?.w)) Position: (\(position?.x),\(position?.y),\(position?.z)")
}
*/
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
