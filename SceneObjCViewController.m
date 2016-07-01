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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    SCNView *myView = [[SCNView alloc] init];
    myView.frame = self.view.frame;
   
    
    myView.scene = [SCNScene sceneNamed:@"battle_screen_01.scn"];
    
    SCNMaterial *material = [SCNMaterial material];
    material.diffuse.contents = [UIImage imageNamed:@"battle_page_01.png"];
    myView.scene.rootNode.geometry.materials = material.diffuse.contents;
    
    
    
    myView.allowsCameraControl = YES;
    myView.autoenablesDefaultLighting = YES;
    myView.backgroundColor = [UIColor lightGrayColor];

     [self.view addSubview:myView];
    
    //test adding cards over top
    Level*level = [Campaign getLevelWithDifficulty:1 withChapter:4 withLevel:1];
    
    GameViewController *gvc = [[GameViewController alloc] initWithGameMode:GameModeSingleplayer withLevel:level];
    gvc.noPreviousView = YES;
    
    [myView addSubview:gvc.view];
    
}

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
