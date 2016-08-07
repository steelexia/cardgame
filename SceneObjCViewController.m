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
@interface SceneObjCViewController ()

@end

@implementation SceneObjCViewController
SCNView *myView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    myView = [[SCNView alloc] init];
    myView.frame = self.view.frame;
   
    
    myView.scene = [SCNScene sceneNamed:@"battle_bg.dae"];
    
    SCNMaterial *material = [SCNMaterial material];
    material.diffuse.contents = [UIImage imageNamed:@"battle_page_01.png"];
    myView.scene.rootNode.geometry.materials = material.diffuse.contents;
    
    SCNScene *cfButtonScene = [SCNScene sceneNamed:@"battle_button.dae"];
    SCNVector3 cfButtonVector = cfButtonScene.rootNode.position;
    cfButtonVector.z +=00;
    [cfButtonScene.rootNode setPosition:cfButtonVector];
    
    [myView.scene.rootNode addChildNode:cfButtonScene.rootNode];
    
    SCNScene *enemy_life = [SCNScene sceneNamed:@"battle_enemy_life.dae"];
    [myView.scene.rootNode addChildNode:enemy_life.rootNode];
    
   
    SCNNode *cameraNode = [[SCNNode alloc] init];
    SCNCamera *myNodeCamera = [[SCNCamera alloc] init];
 
    [myNodeCamera setXFov:90];
    [myNodeCamera setYFov:90];
    
    cameraNode.camera = myNodeCamera;
    //cameraNode.position = SCNVector3Make(20, 2, 110);
    
    //[myView.scene.rootNode addChildNode:cameraNode];
    
    SCNNode *checkNode = myView.scene.rootNode;
    
    
    NSArray *childNodes = myView.scene.rootNode.childNodes;
    //myView.pointOfView = childNodes[1];
    SCNCamera *povCamera = myView.pointOfView.camera;
   povCamera.xFov = 0;
   povCamera.yFov = 55;
    SCNNode *povNode = myView.pointOfView;
    //15,120,1400
    //7, 45, 8, 115, 1300
    //7,45,8, 85, 1300
    //7,45,8,175,13
    SCNVector3 myCamPosition = SCNVector3Make(0,160,1340);
    
    [povNode setPosition:myCamPosition];
    
    
    myView.allowsCameraControl = YES;
    myView.autoenablesDefaultLighting = YES;
    myView.backgroundColor = [UIColor lightGrayColor];

     [self.view addSubview:myView];
    
    //test adding cards over top
    Level*level = [Campaign getLevelWithDifficulty:1 withChapter:4 withLevel:1];
    
    GameViewController *gvc = [[GameViewController alloc] initWithGameMode:GameModeSingleplayer withLevel:level];
    gvc.noPreviousView = YES;
    
    //[myView addSubview:gvc.view];
    
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
   
    CGPoint location = [[touches anyObject] locationInView:self.view];
    CGRect fingerRect = CGRectMake(location.x-5, location.y-5, 10, 10);
    
    for(UIView *view in self.view.subviews){
        CGRect subviewFrame = view.frame;
        
        if(CGRectIntersectsRect(fingerRect, subviewFrame)){
            //we found the finally touched view
            NSLog(@"Yeah !, i found it %@",view);
        }
        
    }

    
    SCNQuaternion myQuat =  myView.pointOfView.orientation;
    SCNVector3 myPos = myView.pointOfView.position;
    NSString *strX = [NSString stringWithFormat:@"%f", myPos.x];
 NSString *strY = [NSString stringWithFormat:@"%f", myPos.y];
     NSString *strZ = [NSString stringWithFormat:@"%f", myPos.z];
  
    NSLog([@"positionx" stringByAppendingString:strX]);
      NSLog([@"positiony" stringByAppendingString:strY]);
    NSLog([@"positionZ" stringByAppendingString:strZ]);
    
   double xFov=  myView.pointOfView.camera.xFov;
    double yFov = myView.pointOfView.camera.yFov;
    
    NSString *strfovY = [NSString stringWithFormat:@"%f", xFov];
    NSString *strfovZ = [NSString stringWithFormat:@"%f", yFov];
    
    NSLog([@"positiony" stringByAppendingString:strfovY]);
    NSLog([@"positionZ" stringByAppendingString:strfovZ]);
    
    SCNCamera *povCamera = myView.pointOfView.camera;
   // povCamera.xFov = 7;
    //povCamera.yFov = 45;
    SCNNode *povNode = myView.pointOfView;
    //15,120,1400
    //7, 45, 8, 115, 1300
    //7,45,8, 85, 1300
    //7,45,8,175,1300
    SCNVector3 myCamPosition = SCNVector3Make(15,120,1400);
    
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
