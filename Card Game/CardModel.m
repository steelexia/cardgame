//
//  CardModel.m
//  Card Game
//
//  Created by Steele Xia
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "CardModel.h"
#import "MonsterCardModel.h"
#import "SpellCardModel.h"
#import "AbilityWrapper.h"
#import "CardView.h"

@implementation CardModel

@synthesize idNumber = _idNumber;
@synthesize name = _name;
@synthesize cost = _cost;
@synthesize rarity = _rarity;
@synthesize abilities = _abilities;
@synthesize type = _type;
@synthesize creator = _creator;
@synthesize creatorName = _creatorName;
@synthesize element = _element;

const int MONSTER_CARD = 0, SPELL_CARD = 1;

/** constructor with id number, all other fields will be defaut values */
-(instancetype)initWithIdNumber: (int)idNumber
{
    self = [super init];
    
    if (self)
    {
        _idNumber = idNumber;
        
        //default values
        self.name = [NSString stringWithFormat:@"Card %d", idNumber]; //TODO temp
        self.cost = 0;
        
        self.abilities = [NSMutableArray array]; //default no ability
        self.type = cardTypeStandard;
        self.creator = @"Unknown";
        self.element = elementNeutral;
    }
    
    return self;
}

-(instancetype)initWithIdNumber:(int)idNumber type:(enum CardType) type
{
    self = [self initWithIdNumber:idNumber];
    
    if (self)
    {
        self.type = type;
    }
    
    return self;
}

-(instancetype)initWithCardModel:(CardModel*)card
{
    self = [self initWithIdNumber:card.idNumber];
    
    if (self)
    {
        if ([card isKindOfClass:[MonsterCardModel class]])
        {
            MonsterCardModel *selfMonster = [[MonsterCardModel alloc] initWithIdNumber:card.idNumber];
            MonsterCardModel *otherMonster = (MonsterCardModel*)card;
            
            selfMonster.damage = otherMonster.baseDamage;
            selfMonster.life = otherMonster.life;
            selfMonster.maximumLife = otherMonster.baseMaxLife;
            selfMonster.cooldown = otherMonster.cooldown;
            selfMonster.maximumCooldown = otherMonster.baseMaxCooldown;
            
            selfMonster.deployed = otherMonster.deployed;
            selfMonster.side = otherMonster.side;
            selfMonster.dead = otherMonster.dead;
            selfMonster.turnEnded = otherMonster.turnEnded;
            self = selfMonster;
        }
        else if ([card isKindOfClass:[SpellCardModel class]])
        {
            SpellCardModel *spell = [[SpellCardModel alloc] initWithIdNumber:card.idNumber];
            self = spell;
        }
        
        //deep copy of all attributes
        self.type = card.type;
        self.element = card.element;
        
        for (Ability*ability in card.abilities)
            [self.abilities addObject: [[Ability alloc] initWithAbility:ability]];
        self.cost = card.cost;
        self.rarity = card.rarity;
        if (card.name != nil)
            self.name = [[NSString alloc]initWithString:card.name];
        if (card.creator != nil)
            self.creator = [[NSString alloc]initWithString:card.creator];
        if (card.creatorName != nil)
            self.creatorName = [[NSString alloc]initWithString:card.creatorName];
    }
    
    return self;
}

-(void)setIdNumber:(int)idNumber
{
    if (_idNumber == -1)
        _idNumber = idNumber;
}

/* must be 0 or higher */
-(void)setCost:(int)cost{
    _cost = cost < 0 ? 0 : cost;
}

-(int)cost{
    //TODO abilities can affect cost
    return _cost;
}

-(int)baseCost
{
    return _cost;
}

-(void)addBaseAbility: (Ability*)ability
{
    ability.isBaseAbility = YES;
    [self.abilities addObject:ability];
}

-(BOOL)isCompatible:(Ability*)ability
{
    if ([self isKindOfClass:[SpellCardModel class]])
    {
        if (ability.castType != castOnSummon)
            return NO;
    }
    
    for (Ability*ownAbility in self.abilities)
    {
        if (![ownAbility isCompatibleTo:ability])
            return NO;
    }
    
    return YES;
}

- (NSComparisonResult)compare:(CardModel *)otherObject
{
    NSComparisonResult costResult = [[NSNumber numberWithInt:self.cost] compare:[NSNumber numberWithInt:otherObject.cost]];
    
    if (costResult != NSOrderedSame)
        return costResult;
    else
        return [self.name caseInsensitiveCompare:otherObject.name];
}

+(NSString*) elementToString:(enum CardElement) element
{
    if (element == elementFire)
        return @"Fire";
    else if (element == elementIce)
        return @"Ice";
    else if (element == elementLightning)
        return @"Lightning";
    else if (element == elementEarth)
        return @"Earth";
    else if (element == elementLight)
        return @"Light";
    else if (element == elementDark)
        return @"Dark";
    else
        return @"Neutral";
}

//TODO this function is not working atm
+(void)loadCardWithParseID:(CardModel*)card withID:(NSString*)parseID
{
    PFQuery *query = [PFQuery queryWithClassName:@"Card"];
    [query getObjectInBackgroundWithId:parseID block:^(PFObject *cardPF, NSError *error) {
        if (!error)
        {
            //card = [self createCardFromPFObject:cardPF];
        }
        else
        {
            NSLog(@"ERROR: Failed to load %@.", parseID);
        }
    }];
}

+(CardModel*) createCardFromPFObject: (PFObject*)cardPF
{
    CardModel*card;
    
    NSNumber *cardType = cardPF[@"cardType"];
    NSNumber *idNumber = cardPF[@"idNumber"];
    
    if ([cardType intValue] == MONSTER_CARD)
    {
        card = [[MonsterCardModel alloc] initWithIdNumber:[idNumber intValue]];
        MonsterCardModel* monsterCard = (MonsterCardModel*)card;
        
        NSNumber *damage = cardPF[@"damage"];
        NSNumber *life = cardPF[@"life"];
        NSNumber *cooldown = cardPF[@"cooldown"];
        
        monsterCard.damage = [damage intValue];
        monsterCard.life = monsterCard.maximumLife = [life intValue];
        monsterCard.cooldown = monsterCard.maximumCooldown = [cooldown intValue];
    }
    else if ([cardType intValue] == SPELL_CARD)
    {
        card = [[SpellCardModel alloc] initWithIdNumber:[idNumber intValue]];
    }
    
    NSString *name = cardPF[@"name"];
    NSNumber *cost = cardPF[@"cost"];
    NSNumber *rarity = cardPF[@"rarity"];
    NSArray *abilities = cardPF[@"abilities"];
    NSString *creator = cardPF[@"creator"];
    
    //TODO in future this should [probably] never be nil
    if (creator != nil)
    {
        card.creator = creator;
        card.creatorName = @"Loading..."; //TODO
        
        //grabs the user's name to cache it
        PFQuery *query = [PFQuery queryWithClassName:@"User"];
        [query getObjectInBackgroundWithId:creator block:^(PFObject *user, NSError *error) {
            if (!error)
                card.creatorName = user[@"username"];
            else
                card.creatorName = @"Unknown";
        }];
    }
    
    //NOTE: make sure abilities are always loaded after stats otherwise maxLife etc may be modified by ability
    for (PFObject *abilityPF in abilities)
    {
        [abilityPF fetch];
        if (abilityPF != nil)
            [card addBaseAbility:[AbilityWrapper getAbilityWithPFObject:abilityPF]];
    }
    
    card.name = name;
    card.cost = [cost intValue];
    card.rarity = [rarity intValue];
    
    return card;
}

+(void) addCardToParse:(CardModel*) card
{
    //common to all cards
    PFObject *cardPF = [PFObject objectWithClassName:@"Card"];
    
    cardPF[@"idNumber"] = [NSNumber numberWithLong:card.idNumber];
    cardPF[@"name"] = card.name;
    cardPF[@"cost"] = [NSNumber numberWithInt:card.cost];
    cardPF[@"rarity"] = [NSNumber numberWithInt:card.rarity];
    cardPF[@"creator"] = card.creator;
   
    if ([card isKindOfClass:[MonsterCardModel class]])
    {
        MonsterCardModel *monsterCard = (MonsterCardModel*)card;
        
        cardPF[@"cardType"] = [NSNumber numberWithInt:MONSTER_CARD];
        cardPF[@"damage"] = [NSNumber numberWithInt:monsterCard.baseDamage];
        cardPF[@"life"] = [NSNumber numberWithInt:monsterCard.baseMaxLife];
        cardPF[@"cooldown"] = [NSNumber numberWithInt:monsterCard.baseMaxCooldown];
    }
    else if ([card isKindOfClass:[SpellCardModel class]])
    {
        SpellCardModel *spellCard = (SpellCardModel*)card;
        cardPF[@"cardType"] = [NSNumber numberWithInt:SPELL_CARD];
    }
    
    //loaded after stats
    NSMutableArray *pfAbilities = [[NSMutableArray alloc] init];
    //TODO image
    for (int i = 0 ; i < [card.abilities count]; i++){
        if ([card.abilities[i] isKindOfClass:[PFObject class]]){
            [pfAbilities addObject:card.abilities[i]];
        }
        //convert the ability to PFObject
        else if ([card.abilities[i] isKindOfClass:[Ability class]])
        {
            Ability*ability = card.abilities[i];
            int abilityID = [AbilityWrapper getIdWithAbility:ability];
            
            if (abilityID != -1)
            {
                PFObject*pfAbility = [PFObject objectWithClassName:@"Ability"];
                pfAbility[@"idNumber"] = [[NSNumber alloc] initWithInt:abilityID];
                if (ability.value == nil)
                   pfAbility[@"value"] = @0;
                else
                    pfAbility[@"value"] = ability.value;
                pfAbility[@"otherValues"] = ability.otherValues;
                
                [pfAbilities addObject:pfAbility];
            }
            else{
                
                NSLog(@"WARNING: Could not find the id of an ability of card. Ability: %@", [Ability getDescription:ability fromCard:card]);
            }
        }
    }
    
    cardPF[@"abilities"] = pfAbilities;
    
    [cardPF saveInBackground];
}



@end

