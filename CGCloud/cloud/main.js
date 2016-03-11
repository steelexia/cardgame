/* Generates a new ID for a card and update the counter. */
/*
Parse.Cloud.define("getNewCardID", function(request, response) {
var query = new Parse.Query("Database");

query.find({
success: function(results) {
results[0].increment("cardIdCounter");
results[0].save();
response.success(results[0].get("cardIdCounter"));
},
error: function() {
response.error(-1);
}
})
});*/


/**
* Finishes a multiplayer match, function sent by winner of match
* User1 - ParseUserID of Winner
* User2 - ParseUserID of Loser
* MatchType--Ladder or Casual
**/
Parse.Cloud.define("mpMatchComplete", function(request, response) {
  var matchWinner = request.params.User1;
  var matchLoser = request.params.User2;

  console.log(matchWinner);
  console.log(matchLoser);

  var matchWinnerEloRating = request.params.User1Rating;
  var matchLoserEloRating = request.params.User2Rating;

  console.log(matchWinnerEloRating);

  console.log(matchLoserEloRating);

  //calculate elo changes
  //elo depends upon a table illustrated as such
  //ELO difference  Expected score:
  //  0 0.50
  //  20  0.53
  //  40  0.58
  //  60  0.62
  //  80  0.66
  //  100 0.69
  //  120 0.73
  //  140 0.76
  //  160 0.79
  //  180 0.82
  //  200 0.84
  //  300 0.93
  //  400 0.97
  //
  //The formula to calculate a player's new rating based on his/her previous one is:
  //Rn = Ro + C * (S - Se)      (1)
  //where:
  //Rn = new rating
  //Ro = old rating
  //S  = score  --this is usually 1, representing the "weight" of the match
  //Se = expected score
  //C  = constant --this represents the speed/volatility at which ratings will change, we'll use a value of 30

  var C = 30;
  var eloDifference = Math.abs(matchWinnerEloRating-matchLoserEloRating);
  console.log("eloDiff");
  console.log(eloDifference);

  var playerOneNewRating;
  var playerTwoNewRating;
  var scoreRatio;
  if(eloDifference <=20 && eloDifference >=0)
  {
    playerOneNewRating = matchWinnerEloRating + C *(0.51);
  }
  else
  if(eloDifference <=40)
  {
    playerOneNewRating = matchWinnerEloRating + C *(1-0.53);
  }
  else
  if(eloDifference <=60)
  {
    playerOneNewRating = matchWinnerEloRating + C *(1-0.58);
  }
  else
  if(eloDifference <=80)
  {
    playerOneNewRating = matchWinnerEloRating + C *(1-0.62);
  }
  else
  if(eloDifference <=100)
  {
    playerOneNewRating = matchWinnerEloRating + C *(1-0.66);
  }
  else
  if(eloDifference <=120)
  {
    playerOneNewRating = matchWinnerEloRating + C *(1-0.69);
  }
  else
  if(eloDifference <=140)
  {
    playerOneNewRating = matchWinnerEloRating + C *(1-0.73);
  }
  else
  if(eloDifference <=160)
  {
    playerOneNewRating = matchWinnerEloRating + C *(1-0.76);
  }
  else
  if(eloDifference <=180)
  {
    playerOneNewRating = matchWinnerEloRating + C *(1-0.79);
  }
  else
  if(eloDifference <=200)
  {
    playerOneNewRating = matchWinnerEloRating + C *(1-0.82);
  }
  else
  if(eloDifference <=300)
  {
    playerOneNewRating = matchWinnerEloRating + C *(1-0.87);
  }
  else
  if(eloDifference <=400)
  {
    playerOneNewRating = matchWinnerEloRating + C *(1-0.93);
  }
  else
  if(eloDifference >=401)
  {
    playerOneNewRating = matchWinnerEloRating + C *(1-0.95);
  }

  //subtract the difference of playerOneNewRating to set playerTwoNewRating
  var player1EloChange = playerOneNewRating-matchWinnerEloRating;
  playerTwoNewRating = matchLoserEloRating-player1EloChange;

  playerOneNewRating = Math.ceil(playerOneNewRating);
  playerTwoNewRating = Math.ceil(playerTwoNewRating);

  console.log("player1NewRating");
  console.log(playerOneNewRating);
  console.log("player2NewRating");
  console.log(playerTwoNewRating);

  var parseUserPointers = new Array();
  var updatedUserObjects = new Array();
  parseUserPointers.push(matchWinner);
  parseUserPointers.push(matchLoser);

  console.log("players ids:");
  console.log(parseUserPointers);
  console.log("player1 ID: ");
  console.log(matchWinner);
  console.log("player2 ID: ");
  console.log(matchLoser);

  Parse.Cloud.useMasterKey();
  //query for the two PFUser Objects based on the parameters
  var userQuery = new Parse.Query(Parse.User);
  userQuery.containedIn("objectId",parseUserPointers);
  userQuery.find({
    success: function(results) {
      console.log(results.count);

      var userObject1 = results[0];
      var userObject2 = results[1];
      if(userObject1.objectId ==matchWinner)
      {
        userObject1.set("eloRating",playerOneNewRating);
        userObject2.set("eloRating",playerTwoNewRating);
      }
      else
      {
        userObject2.set("eloRating",playerOneNewRating);
        userObject1.set("eloRating",playerTwoNewRating);

      }
      updatedUserObjects.push(userObject1);
      updatedUserObjects.push(userObject2);

    },
    error: function() {
      response.error("Query Failed");
    }
  }).then(function(saveObjects)
  {
    Parse.Object.saveAll(updatedUserObjects, {

      success: function(list) {
      //assumes all are saved
        response.success("user EloRatings Saved Successfully");
      },
      error: function(error) {
        response.error("Couldn't save");
        console.error("Got an error " + error.code + " : " + error.message);
      }
    });
  });
});

/**
//afterSave function for notifying user about a like received on their cards
//client will open a notification and bring the user to the editing screen to increase the power level of their card
//notification will send out on first, 10th, and 50th likes
//notification will contain separate data indicating when the card
has reached a new tier in rarity and the player can modify its stats

//get cardID from cardLike
//query for card object
//check number of likes
//
**/

Parse.Cloud.afterSave("cardLike", function(request) {
  var cardID = request.params.cardID;

  cardQuery = new Parse.Query("Card");
  query.get(request.params.cardID, {
  success:function(card)
  {

      var originalLikes = card.get("likes");
      //add to card likes
      card.increment("likes");

      if(originalLikes==0)
      {
        //send a message for the first like notification
        console.log("first");
      }
      elseif(originalLikes==9)
      {
        console.log("10th");
        //send a message for the 10th like notification
      }
      elseif(originalLikes==49)
      {
        //send a message for the 50th like notification
      }

  },
    error: function(error) {
      console.error("Got an error " + error.code + " : " + error.message);
  }
  });
});

/**
function for sending a push notification to a particular userID
//parameter: ParseUser
*/

Parse.Cloud.define('pushNotificationForUser', function(request, response)
{
  var ParseUserPointer = request.params.userID;


  var query = new Parse.Query(Parse.User);
  query.equalTo('objectId', ParseUserPointer);
  // Find devices associated with these users
  var pushQuery = new Parse.Query(Parse.Installation);
  // need to have users linked to installations
  pushQuery.matchesQuery('user', query);

    console.log(ParseUserPointer);


    var promise = new Parse.Promise();
    var msgTxt = request.params.messageText;
    var msgType = request.params.messageType;

    console.log(msgTxt);
    console.log(msgType);

    // Send push notification to query
    Parse.Push.send({
                    where: pushQuery, // Set our installation query
                    data: {
                    "alert": msgTxt,
                    "sound": "default",
                    "messageType": msgType,
                    "text":msgTxt
                    }
                    }, {
                    success: function () {
                    // Push was successful
                    console.log("Message was sent successfully");
                    //response.success('true');
                    },
                    error: function (error) {
                    response.error(error);
                    }
                    }).then (function(result){
                             //Marks this promise as fulfilled,
                             //firing any callbacks waiting on it.
                             console.log("promise resolved");
                             response.success("sent the push notification");
                             promise.resolve(result);
                             }, function(error) {
                             //Marks this promise as fulfilled,
                             //firing any callbacks waiting on it.
                             promise.reject(error);
                             });
    return promise;

  });


  Parse.Cloud.define('createMessageForUser', function(request, response)
  {
      var ParseUserPointer = request.params.userID;
      var msgTxt = request.params.messageText;
      var msgType = request.params.messageType;
      var msgTitle = request.params.messageTitle;
      var rareCardID = request.params.rareCardID;

      console.log(ParseUserPointer);
      console.log(msgTxt);
      console.log(msgType);

      var userMsg = new Parse.Object("Message");
      userMsg.set("userPointer", ParseUserPointer);
      userMsg.set("body",msgTxt);
      userMsg.set("title",msgTitle);
      userMsg.set("msgType",msgType);
      if(rareCardID === null || rareCardID === "null")
      {

      }
      else
      {
        console.log("rare card ID for Message");
        console.log(rareCardID);
        userMsg.set("rareCardID",rareCardID);
      }
      userMsg.save({
      }, {
      success: function() {
      response.success();
      },
      error: function(error) {
      response.error("Failed to sell");
      }
      });
  });


/**
* Not actually any secure, but having function in cloud prevents errors in updating.
* In future can store level costs in cloud code
*
* levelID - string
* gold - integer
* blankCards - integer
*
*/



Parse.Cloud.define("levelComplete", function(request, response) {
var completedLevels = request.user.get("completedLevels");

if (completedLevels.indexOf(request.params.levelID) == -1)
{
request.user.increment("gold", request.params.gold);
request.user.increment("blankCards", request.params.goldReward);
completedLevels.push(request.params.levelID);

request.user.save({},{
success: function() {
response.success();
},
error: function(error) {
response.error("Couldn't save");
}
});
}
else{
response.error("Level already completed");
}
});

/**
* Publishes the card
* cardID - Card's objectID
*/
Parse.Cloud.define("publishCard", function(request, response) {
if (request.user.get("blankCards") <= 0)
{
response.error("No blank cards left");
return;
}

var cardQuery = new Parse.Query("Card");
cardQuery.get(request.params.cardID, {
success:function(card)
{
var databaseQuery = new Parse.Query("Database");
databaseQuery.first({
success: function(database) {
//give the card an ID
var idNumber = database.get("cardIdCounter");
database.increment("cardIdCounter");
card.set("idNumber", idNumber);

var sale = new Parse.Object("Sale");
sale.set("cardID", idNumber);
sale.set("likes", 0);
sale.set("seller", card.get("creator"));
sale.set("stock", 10);
sale.set("card", card);
sale.set("name", card.get("name"));
sale.set("tags", card.get("tags"));

//TODO go through each tag and increment tag counters

request.user.increment("blankCards", -1);
setOwnedCard(request.user, idNumber, true);

Parse.Object.saveAll([request.user, card, database, sale], {
success: function(list) {
//assumes all are saved
response.success();
},
error: function(error) {
response.error("Couldn't save");
}
});
},
error: function() {
response.error(-1);
}
});
},
error: function() {
response.error("Couldn't find card");
}
})
});

/**
* Set card as featured
* cardID - Card's objectID
*/
Parse.Cloud.define("setCardAsFeatured", function(request, response) {

  var cardQuery = new Parse.Query("Card");
  cardQuery.get(request.params.cardID,
  {
    success:function(card)
    {
      var featuredCard = new Parse.Object("FeaturedCard");
      featuredCard.set("card", card);

      featuredCard.save({
      }, {
        success: function() {
          response.success();
        },
        error: function(error) {
          response.error("Failed to Save");
        }
      });
    },
    error: function() {
      response.error("Couldn't find card");
    }
  })
});

/**
* Buys a boosterPack
* packType - numeric value representing one of three pack types (bronze, silver, gold)
* cost - positive integer
**/

Parse.Cloud.define("buyBoosterPack", function(request, response) {

  var Card = Parse.Object.extend("Card");

  var innerQuery = new Parse.Query(Card);
  var saleQuery = new Parse.Query("Sale");
  saleQuery.greaterThan("stock", 1);
  saleQuery.descending("createdAt");
  saleQuery.include("card");
  //saleQuery.include("card.rarity");
  //saleQuery.limit(5);
  saleQuery.find({
              success: function(results) {

               //loop through the results to create an array of things to return.
               var commonCards = new Array();
               var rareCards = new Array();

               var resultsLength = results.length;


                 for (var j = 0; j<5; j++)
               {

                  var value = Math.floor((Math.random() * resultsLength))

                  var resultCard = results[value];
                  //var cardName = resultCard.get("name");

                  var cardObj = resultCard.get("card");

                  console.log(cardObj.get("name"));
                  setOwnedCard(request.user, cardObj.get("idNumber"), true);
                  rareCards.push(cardObj);

                  Parse.Object.saveAll([request.user, cardObj], {
                    success: function(list) {
                      //console.log("saved");
                      //assumes all are saved

                    },
                    error: function(error) {
                      response.error("Couldn't save User");
                    }
                  });

                }
                response.success(rareCards);
              }
           });

});

/**
* Buys a card
* saleID - Sale's objectID
* cardID - Card's objectID
* cost - positive integer
**/
Parse.Cloud.define("buyCard", function(request, response) {
var cardQuery = new Parse.Query("Card");
cardQuery.get(request.params.cardID, {
success:function(card)
{
var saleQuery = new Parse.Query("Sale");
saleQuery.get(request.params.saleID, {
success:function(sale)
{
var stock = sale.get("stock");
if (stock <= 0)
response.error("Sale has no stock left");
else if (getOwnedCard(request.user, card.get("idNumber")))
response.error("User already owns card");
else
{
sale.increment("stock", -1);
request.user.increment("gold", -request.params.cost);

//TODO probably need push later, and add money to creator
//TODO defintely push to seller when sold out
var sellingUser = sale.get("seller");
console.log("the selling user");
console.log(sellingUser);

//give user 5% of the cost, notify them via push notification, notify them via message
var amountForSeller = Math.ceil(0.05*request.params.cost);
var buyingUserName = request.user.get("username");
var cardname = card.get("name");

var messageForSeller1 = buyingUserName + " has bought your card ";
var messageForSeller2 = messageForSeller1 + cardname;
var totalMessage = messageForSeller2 + ". You received ";
var totalMessageFinal = totalMessage + amountForSeller + " gold!";

Parse.Cloud.run('giveSellerGold', {sellerID: sellingUser, sellerGold:amountForSeller }, {
  success: function(userNotified) {

    console.log("seller gold given");
  },
  error: function(error) {
    console.log("error giving seller gold");
  }
});

Parse.Cloud.run('pushNotificationForUser', { userID: sellingUser, messageText:totalMessageFinal, messageType:"soldNotification" }, {
  success: function(userNotified) {
    // ratings should be 4.5
    console.log("user successfully notified");
  },
  error: function(error) {
    console.log("error notifying user");
  }
});

Parse.Cloud.run('createMessageForUser', { userID: sellingUser, messageTitle:"Card Sold!",messageText:totalMessageFinal, messageType:"soldNotification" }, {
  success: function(userNotified) {
    // ratings should be 4.5
    console.log("user message created");
  },
  error: function(error) {
    console.log("error creating user message");
  }
});

//saves user
setOwnedCard(request.user, card.get("idNumber"), true);

Parse.Object.saveAll([request.user, card, sale], {
success: function(list) {
//console.log("saved");
//assumes all are saved
response.success();
},
error: function(error) {
response.error("Couldn't save User");
}
});
}
},
error:function() {
response.error("Couldn't find Card");
}
});
},
error:function() {
response.error("Couldn't find Sale");
}
});
});

Parse.Cloud.define("giveSellerGold", function(request, response) {
  Parse.Cloud.useMasterKey();
    var user = new Parse.User();
    var query = new Parse.Query(Parse.User);
    query.equalTo("objectId", request.params.sellerID);
    query.first({
       success: function(object) {
          object.increment("gold", request.params.sellerGold);
          object.save();
          response.success("Successfully saved gold");
       },
       error: function(error) {
        response.error("update failed");
       }
    });
 });

/**
* Sells a card, only need card ID, since it only changes the user. However client will specify the cost of the card
* cardNumber- integer
* cost - positive integer
**/
Parse.Cloud.define("sellCard", function(request, response) {
request.user.increment("gold", request.params.cost);
setOwnedCard(request.user, request.params.cardNumber, false);

request.user.save({
}, {
success: function() {
response.success();
},
error: function(error) {
response.error("Failed to sell");
}
});
});

/**
* Like a card. Needs both Card and Sale objects for updating
*
* cardID - Card's objectID
* saleID - Sale's objectID
*
**/
Parse.Cloud.define("likeCard", function(request, response) {
//console.log("start");
  var cardQuery = new Parse.Query("Card");
  cardQuery.get(request.params.cardID, {
    success:function(card)
    {
      //console.log("card");
      var saleQuery = new Parse.Query("Sale");
      saleQuery.get(request.params.saleID, {
        success:function(sale)
        {
          //console.log("sale");
          var userLikes = request.user.get("likes");
          if (userLikes <= 0)
            response.error("User has no likes left");
          else if (getLikedCard(request.user, card.get("idNumber")))
            response.error("User already liked card");
          else
          {
            //console.log("enough likes");
            request.user.increment("likes", -1);
            var originalLikes = card.get("likes");

            card.increment("likes", 1);
            sale.increment("likes", 1);

            //TODO can do a push later
            request.user.increment("gold", 5);

            var cardname = card.get("name");
            var fullString;
            var doUpdate = "NO"
            if(originalLikes ==0)
            {
              fullString = "Your Card " +cardname + " received its first like!  Get more likes to increase the card's power & rarity."
              doUpdate = "YES";
            }
            if(originalLikes ==9)
            {
              fullString = "Your Card " +cardname + " received its tenth like!  Get more likes to increase the card's power & rarity."
              doUpdate = "YES";
            }
            if(originalLikes ==50)
            {
              fullString = "Your Card " +cardname + " received its 50 like!  Look at you, Mr/Ms popular!"
              doUpdate = "YES";
            }
            //get the userID of the card owner to notify them about the like

            if(doUpdate =="YES")
            {


              var parseUserID = sale.get("seller");
              //notify the parseUserID
              Parse.Cloud.run('pushNotificationForUser', { userID: parseUserID, messageText:fullString, messageType:"likeNotification" }, {
                success: function(userNotified) {
                  // ratings should be 4.5
                  console.log("user successfully notified");
                },
                error: function(error) {
                  console.log("error notifying user");
                }
              });

              Parse.Cloud.run('createMessageForUser', { userID: parseUserID, messageTitle:"Card Like!",messageText:fullString, messageType:"likeNotification" }, {
                success: function(userNotified) {
                  // ratings should be 4.5
                  console.log("user message created");
                },
                error: function(error) {
                  console.log("error creating user message");
                }
              });

            }

            //saves user
            setLikedCard(request.user, card.get("idNumber"), true);
            console.log("liked: " + getLikedCard(request.user, card.get("idNumber")));

            Parse.Object.saveAll([request.user, card, sale], {
              success: function(list) {
              //console.log("saved");
              //assumes all are saved
                response.success();
              },
              error: function(error) {
                response.error("Couldn't save");
              }
            });
          }
        },
        error:function() {
          response.error("Couldn't find sale");
        }
      });
    },
    error:function() {
     response.error("Couldn't find Card");
    }
  });
});

/**
* Appove card Image
**/
Parse.Cloud.define("approveCardImage", function(request, response) {
  //console.log("Report function started.");
  var cardQuery = new Parse.Query("Card");
  cardQuery.get(request.params.cardID, {
    success: function(card) {
      card.set("adminPhotoCheck", 1);
      card.save({
      }, {
        success: function() {

          var cardname = card.get("name");
          var creator = card.get("creator");
          var totalMessageFinal = "Your card " + cardname + " has been approved. Users can now view it on the store and buy it, giving you a percent of the gold!  If the community likes your card, you will also get a chance to increase its rarity";

          Parse.Cloud.run('pushNotificationForUser', { userID: creator, messageText:totalMessageFinal, messageType:"cardApprovedNotification" }, {
            success: function(userNotified) {
              // ratings should be 4.5
              console.log("user successfully notified");
            },
            error: function(error) {
              console.log("error notifying user");
            }
          });

          Parse.Cloud.run('createMessageForUser', { userID: creator, messageTitle:"Card Approved!",messageText:totalMessageFinal, messageType:"cardApprovedNotification" }, {
            success: function(userNotified) {
              // ratings should be 4.5
              console.log("user message created");
            },
            error: function(error) {
              console.log("error creating user message");
            }
          });

          response.success();
        },
        error: function(error) {
          response.error("Failed to Approve");
        }
      });
    },
    error: function(error) {
      response.error("Couldn't approve card image");
    }
  });

});

/**
* Decline card Image
**/
Parse.Cloud.define("declineCardImage", function(request, response) {
  //console.log("Report function started.");
  var cardQuery = new Parse.Query("Card");
  cardQuery.get(request.params.cardID, {
    success: function(card) {
      card.set("adminPhotoCheck", -1);
      card.save({
      }, {
        success: function() {
          var cardname = card.get("name");
          var creator = card.get("creator");
          var totalMessageFinal = "Your card " + cardname + " has been declined.  One of our moderators found an objection to its content under our terms and conditions.";

          Parse.Cloud.run('pushNotificationForUser', { userID: creator, messageText:totalMessageFinal, messageType:"cardApprovedNotification" }, {
            success: function(userNotified) {
              // ratings should be 4.5
              console.log("user successfully notified");
            },
            error: function(error) {
              console.log("error notifying user");
            }
          });

          Parse.Cloud.run('createMessageForUser', { userID: creator, messageTitle:"Card Approved!",messageText:totalMessageFinal, messageType:"cardApprovedNotification" }, {
            success: function(userNotified) {
              // ratings should be 4.5
              console.log("user message created");
            },
            error: function(error) {
              console.log("error creating user message");
            }
          });

          response.success();
        },
        error: function(error) {
          response.error("Failed to Decline");
        }
      });
    },
    error: function(error) {
      response.error("Couldn't decline card image");
    }
  });

});

/**
* Reports a card. Needs both Card and Sale objects for updating
*
* cardID - Card's objectID
* saleID - Sale's objectID
*
**/
Parse.Cloud.define("reportCard", function(request, response) {
  //console.log("Report function started.");
  var cardQuery = new Parse.Query("Card");
  cardQuery.get(request.params.cardID, {
    success: function(card) {
      //console.log("Card to report found.");
      var saleQuery = new Parse.Query("Sale");
      saleQuery.get(request.params.saleID, {
      success:function(sale)
      {
      if (getReportedCard(request.user, card.get("idNumber")))
        response.error("User already reported card");
      else{
        //console.log("Report increment");
        var originalReports = card.get("reports");
        card.increment("reports");
        sale.increment("reports");

        var cardName = card.get("name");
        var fullString;
        var doUpdate = false;
        if(originalReports == 4) {
          //console.log("Card reported 5 times");

          // Copies the card to the reported cards.
          var takenOutCard = new Parse.Object("ReportedCards");
          /**takenOutCard.set("name", cardName);
          takenOutCard.set("flavourText", card.get("flavourText"));
          takenOutCard.set("idNumber", card.get("idNumber"));
          takenOutCard.set("cardType", card.get("cardType"));
          takenOutCard.set("cost", card.get("cost"));
          takenOutCard.set("idNumber", card.get("idNumber"));
          takenOutCard.set("rarity", card.get("rarity"));
          takenOutCard.set("damage", card.get("damage"));
          takenOutCard.set("idNumber", card.get("idNumber"));
          takenOutCard.set("life", card.get("life"));
          takenOutCard.set("cooldown", card.get("cooldown"));
          takenOutCard.set("abilities", card.get("abilities"));
          takenOutCard.set("idNumber", card.get("idNumber"));
          takenOutCard.set("creator", card.get("creator"));
          takenOutCard.set("element", card.get("element"));
          takenOutCard.set("likes", card.get("likes"));
          takenOutCard.set("tags", card.get("tags"));
          takenOutCard.set("image", card.get("image"));
          takenOutCard.set("cardVote", card.get("cardVote"));
          takenOutCard.set("version", card.get("version"));
          takenOutCard.set("rarityUpdateAvailable", card.get("rarityUpdateAvailable"));
          takenOutCard.set("skipDelete", false);

          takenOutCard.save(null, {
            success: function(takenOutCard) {
              card.set("skipDelete", true);
              card.destroy({
              success: function(card) {
                fullString = "Your Card " +cardName + " was reported for inappropriate content, it has been taken out of the game until investigation";
                doUpdate = true;
                alert('Card: ' + takenOutCard.id + ' moved to reportedCards');
              },
              error: function(error) {
                response.error("Couldn't destroy card: " + error.message);
              }
            });
            },
            error: function(error) {
              // error is a Parse.Error with an error code and message.
                response.error("Couldn't copy card: " + error.message);
            }
          }); */



          // TODO: Perhaps notify staff that a card has been taken out.
        }

        if(doUpdate == true) {
          //get the userID of the card owner to notify them about the like
          var parseUserID = card.get("creator");
          //notify the parseUserID
          Parse.Cloud.run('pushNotificationForUser', { userID: parseUserID, messageText:fullString, messageType:"reportNotification" }, {
            success: function(userNotified) {
              console.log("user successfully notified");
            },
            error: function(error) {
              console.log("error notifying user");
            }
          });

          Parse.Cloud.run('createMessageForUser', { userID: parseUserID, messageTitle:"Card reported :(",messageText:fullString, messageType:"createNotification" }, {
            success: function(userNotified) {
              console.log("user message created");
            },
            error: function(error) {
              console.log("error creating user message");
            }
          });
        }

        //saves user
        setReportedCard(request.user, card.get("idNumber"), true);
        console.log("reported: " + getReportedCard(request.user, card.get("idNumber")));

        if (!takenOutCard) {
          Parse.Object.saveAll([request.user, card, sale], {
            success: function(list) {
              //console.log("saved");
              //assumes all are saved
              response.success("User and card saved");
            },
            error: function(error) {
              response.error("Couldn't save");
            }
          });
        }
        else {
          request.user.save(null, {
            success: function(card) {
              response.success("User saved and card taken out");
            },
            error: function(error) {
              response.error("Couldn't save user");
            }
          });
        }
      }

      },
      error:function() {
        response.error("Couldn't find sale");
      }
    });
    },
    error: function() {
      response.error("Couldn't find Card");
    }
  });
});


/***************************************************
Functions for getting user's interacted cards
***************************************************/

function getLikedCard(user, cardID)
{
return getCardInteraction(user, cardID, 0);
}

function getEditedCard(user, cardID)
{
return getCardInteraction(user, cardID, 1);
}

function getOwnedCard(user, cardID)
{
return getCardInteraction(user, cardID, 2);
}

function getReportedCard(user, cardID)
{
  return getCardInteraction(user, cardID, 3);
}

function getCardInteraction(user, cardID, atBit){
var interactionDic = user.get("interactedCards");

if (interactionDic == null)
return false;

var interaction = interactionDic[cardID+""];
if (interaction == null)
return false;
else
{
if ((interaction >> atBit) % 2 == 1)
return true;
}

return false;
}

/***************************************************
Functions for setting user's interacted cards
***************************************************/

function setLikedCard(user, cardID, state)
{
return setCardInteraction(user, cardID, 0, state);
}

function setEditedCard(user, cardID, state)
{
return setCardInteraction(user, cardID, 1, state);
}

function setOwnedCard(user, cardID, state)
{
return setCardInteraction(user, cardID, 2, state);
}

function setReportedCard(user, cardID, state)
{
  return setCardInteraction(user, cardID, 3, state);
}

/** NOTE that this does NOT save the user */
function setCardInteraction(user, cardID, atBit, state){
var interactionDic = user.get("interactedCards");

if (interactionDic == null)
interactionDic = [];

var interaction = interactionDic[cardID+""];
if (interaction == null)
{
if (state)
interaction = 1 << atBit;
else
interaction = 0;
}
else
{
if (state)
interaction = interaction | (1 << atBit);
else
interaction = interaction & ~(1 << atBit);
}

interactionDic[cardID+""] = interaction;
user.set("interactedCards", interactionDic);
}

/**********************************************************
*
*  Jobs
*
**********************************************************/

/**
* Runs once a ?week to evaluate the rarity of all cards
*/
Parse.Cloud.job("updateAllCardsRarity", function(request, status) {
var NOW_DATE = new Date();
console.log("start");
var databaseQuery = new Parse.Query("Database");
databaseQuery.first({
success: function(database) {
var daysSinceLastRarityUpdate = database.get("daysSinceLastRarityUpdate");
database.increment("daysSinceLastRarityUpdate", 1);

//only update if rarity update is 3
if (daysSinceLastRarityUpdate >= 0)
{
console.log("needs to update");
var cardsQuery = new Parse.Query("Card");
cardsQuery.greaterThan("createdAt", database.get("dateSinceLastRarityUpdate"));

//find total number of cards updated after last update
cardsQuery.count({
success: function(lastPeriodCards) {

//find total number of cards overall
var allCardsQuery = new Parse.Query("Card");
allCardsQuery.count({
success: function(totalCards) {
//update all cards
updateRarityAllPeriod(database.get("dateSinceLastRarityUpdate"), 0, lastPeriodCards, totalCards, status,
function(){
database.set("daysSinceLastRarityUpdate", 0);
console.log("ended");
database.set("dateSinceLastRarityUpdate", NOW_DATE);
database.save({},{
success: function() {
status.success();
},
error: function(error) {
status.error("Couldn't save");
}
});
});
},
error: function(error) {
status.error("ERROR: Couldn't find total card count");
}
});
},
error: function(error) {
status.error("ERROR: Couldn't find total card count");
}
});
}
else
{
console.log("Hasn't been enough dates since last update. Skipping.");
database.save({},{
success: function() {
status.success();
},
error: function(error) {
status.error("Couldn't save");
}
});
}
},
error: function() {
status.error("Couldn't find database");
}
});
});


/**
* Recursive function to ensure all cards from the current period has been updated
*/
/*
function updateRarityCurrentPeriod(lastUpdateDate, updatedCount, totalCards, status, onFinish)
{
//console.log("inside update rarity. updatedCount: " + updatedCount + " totalCards: " + totalCards);
var QUERY_COUNT = 10;
var cardsQuery = new Parse.Query("Card");
cardsQuery.skip(updatedCount);
cardsQuery.limit(QUERY_COUNT);
cardsQuery.greaterThan("createdAt", lastUpdateDate); //first search only looks at cards from last update
cardsQuery.descending("likes");

cardsQuery.find({
success: function(cards) {
//console.log("found cards: " + cards.length);

for (var i = 0; i < cards.length; i++)
{
var rarityPercent = (updatedCount+i)/totalCards;
var card = cards[i];

var likes = card.get("likes");
var originalRarity = card.get("rarity");
var rarity = getRarity(rarityPercent,likes);

if (rarity > originalRarity) //rarity can never decrease
{
console.log("updating " + card.get("idNumber") + " to rarity " + rarity);
card.set("rarity", rarity);
}
}

if (cards.length >= QUERY_COUNT)
{
//tries to save all the cards before continuing
Parse.Object.saveAll(cards, {
success: function() {
//keep searching for more
updateRarityCurrentPeriod(lastUpdateDate, updatedCount + QUERY_COUNT, totalCards, status, onFinish);
},
error: function(error) {
status.error("ERROR: Failed to save cards while updating.");
}
});
}
else
{
Parse.Object.saveAll(cards, {
success: function() {
//done
status.success();
onFinish();
},
error: function(error) {
status.error("ERROR: Failed to save cards while updating.");
}
});
}
},
error: function() {
status.error("ERROR: Failed to find cards to update");
}
})
}*/

/**
* Recursive function to ensure all cards from the all periods has been updated
*/
function updateRarityAllPeriod(lastUpdateDate, updatedCount, lastPeriodCards, totalCards, status, onFinish)
{
console.log("inside update rarity. updatedCount: " + updatedCount + " totalCards: " + totalCards);
var QUERY_COUNT = 10;
var cardsQuery = new Parse.Query("Card");
cardsQuery.skip(updatedCount);
cardsQuery.limit(QUERY_COUNT);
cardsQuery.descending("likes");

cardsQuery.find({
success: function(cards) {
console.log("found cards: " + cards.length);

for (var i = 0; i < cards.length; i++)
{
var card = cards[i];
var rarityPercent;
var creationDate = card.get("createdAt");

//cards from last period has "bonus" in getting a higher rarity, as it only compares to other cards in the same period
if (creationDate > lastUpdateDate)
{
rarityPercent = (updatedCount+i)/lastPeriodCards;
}
//cards outside their initial period compares to all cards, so their chance of improving is lower
else
{
rarityPercent = (updatedCount+i)/totalCards;
}

var likes = card.get("likes");
var originalRarity = card.get("rarity");
var rarity = getRarity(rarityPercent,likes);
var cardCreator = card.get("creator");

if (rarity > originalRarity) //rarity can never decrease
{
console.log("updating " + card.get("idNumber") + " to rarity " + rarity);
card.set("rarity", rarity);
card.set("rarityUpdateAvailable","YES");

var cardName = card.get("name");

var cardID = card.get("idNumber");

console.log("cardObjectID:" +cardID);

var rarityStatus;
if(rarity==1)
{
  rarityStatus = "Uncommon"
}
if(rarity==2)
{
  rarityStatus = "Rare"
}
if(rarity==3)
{
  rarityStatus = "Exceptional"
}
if(rarity==4)
{
  rarityStatus = "LEGENDARY"
}
var totalMessageFinal = "Your card " + cardName + " has achieved " +rarityStatus + " based on its high number of likes from the Cardforge Community. Upgrade its power now!";
//TODOBRIAN--Notify user here and add to messages
Parse.Cloud.run('pushNotificationForUser', { userID: cardCreator, messageText:totalMessageFinal, messageType:"rareNotification" }, {
  success: function(userNotified) {
    // ratings should be 4.5
    console.log("user successfully notified");
  },
  error: function(error) {
    console.log("error notifying user");
  }
});

Parse.Cloud.run('createMessageForUser', { userID: cardCreator, messageTitle:"Card Rarity Increase!",messageText:totalMessageFinal, messageType:"rareNotification",rareCardID:cardID }, {
  success: function(userNotified) {
    // ratings should be 4.5
    console.log("user message created");
  },
  error: function(error) {
    console.log("error creating user message");
  }
});

}
}

if (cards.length >= QUERY_COUNT)
{
//tries to save all the cards before continuing
Parse.Object.saveAll(cards, {
success: function() {
//keep searching for more
updateRarityAllPeriod(lastUpdateDate, updatedCount + QUERY_COUNT, lastPeriodCards, totalCards, status, onFinish);
},
error: function(error) {
status.error("ERROR: Failed to save cards while updating.");
}
});
}
else
{
Parse.Object.saveAll(cards, {
success: function() {
//done
status.success();
onFinish();
},
error: function(error) {
status.error("ERROR: Failed to save cards while updating.");
}
});
}
},
error: function() {
status.error("ERROR: Failed to find cards to update");
}
})
}

/**
* Returns a card's rarity based on the number of likes and its % standing
*
* Note:
* Common - 0
* Uncommon - 1
* Rare - 2
* Exceptional - 3
* Legendary - 4
*/

function getRarity(percent, likes)
{
var rarity = 0;
if (percent < 0.01) //1 in 100 cards are legendary
rarity = 4;
else if (percent < 0.04) //1 in ~33 cards (3/100) are exceptional
rarity = 3;
else if (percent < 0.15) //1 in 10 cards (10/100) are rare
rarity = 2;
else if (percent < 0.4) //1 in 4 cards (25/100) are uncommon
rarity = 1;
//3 in 5 cards (60/100) are common

//hard caps of likes required for reach rarities:
if (likes < 50 && rarity == 4) //legendary requires at least 50 likes
rarity = 3;
if (likes < 25 && rarity == 3) //exceptional requires at least 25 likes
rarity = 2;
if (likes < 10 && rarity == 2) //rare cards requires at least 10 likes
rarity = 1;
if (likes < 1 && rarity == 1) //uncommon cards require 1 like
rarity = 0;

return rarity;
}


/**
* Runs once a day to update all cards into their voted versions
*/
Parse.Cloud.job("updateAllVotedCards", function(request, status) {
status.message("starting job");
var query = new Parse.Query("Card");
query.include("abilities");
query.include("cardVote");
query.include("cardVote.currentVotedCard");
query.include("cardVote.currentVotedCard.abilities");
var totalUpdated = 0;
var unsavedCards = 0;
var reachedEnd = false;
query.find({
success: function(results) {
console.log("found " + results.length + "cards.");
for (var i = 0; i < results.length; i++)
{
card = results[i];
//console.log("card: " + card.get("idNumber"));
var cardVote = card.get("cardVote");

//console.log("cardVote: " + cardVote);
if (cardVote != undefined)
{
var votedCard = cardVote.get("currentVotedCard");
//console.log("votedCard: " + votedCard);

if (votedCard != undefined)
{
votedCard.fetch();

card.set("cost", votedCard.get("cost"));
card.set("damage", votedCard.get("damage"));
card.set("life", votedCard.get("life"));
card.set("cooldown", votedCard.get("cooldown"));

//remove all previous abilities
var oldAbilities = card.get("abilities");
//console.log("old abilities: " + oldAbilities + " count: " + oldAbilities.length);

for (var j = 0; j < oldAbilities.length; j++)
{
var ability = oldAbilities[j];

ability.destroy({
wait: true,
success: function(myObject)
{
//console.log("Successfully destroyed ability");
},
error: function(myObject, error)
{
//console.error("Failed to destroy result " + myObject.id + " : " + error.code + " / " + error.message);
}
});
}

var votedAbilities = votedCard.get("abilities");
var newAbilities = [];

//since votedCard's abilities get deleted every vote, need to create copies
for (var j = 0; j < votedAbilities.length; j++)
{
var ability = votedAbilities[j];
//console.log("ability objectID: " + ability.id);
//console.log("ability: " + ability.get("idNumber"));

var abilityCopy = new Parse.Object("Ability");
abilityCopy.set("idNumber", ability.get("idNumber"));
abilityCopy.set("value", ability.get("value"));
abilityCopy.set("otherValues", ability.get("otherValues"));

newAbilities.push(abilityCopy);
}

card.set("abilities", newAbilities);

unsavedCards++;
card.save({
}, {
success: function(gameTurnAgain) {
//console.log("save success");
unsavedCards--;
if (unsavedCards == 0 && reachedEnd)
status.success("Updated " + totalUpdated + " cards");

},
error: function(gameTurnAgain, error) {
// The save failed.  Error is an instance of Parse.Error.
console.log("save failed " + error);
}
});

totalUpdated++;
}
}
}
reachedEnd = true;
},
error: function() {
status.error("ERROR: Couldn't find cards to update.");
}
})
});

/**********************************************************
*
*  Maintenance
*
**********************************************************/

/** Deletes a card and its data */
Parse.Cloud.afterDelete("Card", function(request) {
if (request.object.get("skipDelete") == false || request.object.get("skipDelete") == null){
console.log("card after delete");

//delete all abilities
var abilities = request.object.get("abilities");
if (abilities != null)
Parse.Object.destroyAll(abilities, {
success: function() {},
error: function(error) {
console.error("Error deleting abilities. " + error.code + ": " + error.message);
}
});

//delete image
var image = request.object.get("image");
if (image != null)
image.destroy({
success: function() {},
error: function(error) {
console.error("Error deleting CardImage. " + error.code + ": " + error.message);
}
});

//delete cardvote
var cardVote = request.object.get("cardVote");
if (cardVote != null)
cardVote.destroy({
success: function() {},
error: function(error) {
console.error("Error deleting CardVote. " + error.code + ": " + error.message);
}
});

//delete sale. there is no pointer to sale, so must find it
var saleQuery = new Parse.Query("Sale");
saleQuery.equalTo("cardID", request.object.get("idNumber"));

saleQuery.first({
success: function(sale) {
sale.destroy({
success: function() {},
error: function(error) {
console.error("Error deleting Sale. " + error.code + ": " + error.message);
}
});
},
error: function(error) {
console.error("Error finding Sale for card. " + error.code + ": " + error.message);
}
});

//add message to creator and all owners (and push) TODO
}
});

/** Sames as for Card, TODO: make the inside a shared function. */
Parse.Cloud.afterDelete("ReportedCards", function(request) {
if (request.object.get("skipDelete") == false || request.object.get("skipDelete") = null){
console.log("card after delete");

//delete all abilities
var abilities = request.object.get("abilities");
if (abilities != null)
Parse.Object.destroyAll(abilities, {
success: function() {},
error: function(error) {
console.error("Error deleting abilities. " + error.code + ": " + error.message);
}
});

//delete image
var image = request.object.get("image");
if (image != null)
image.destroy({
success: function() {},
error: function(error) {
console.error("Error deleting CardImage. " + error.code + ": " + error.message);
}
});

//delete cardvote
var cardVote = request.object.get("cardVote");
if (cardVote != null)
cardVote.destroy({
success: function() {},
error: function(error) {
console.error("Error deleting CardVote. " + error.code + ": " + error.message);
}
});

//delete sale. there is no pointer to sale, so must find it
var saleQuery = new Parse.Query("Sale");
saleQuery.equalTo("cardID", request.object.get("idNumber"));

saleQuery.first({
success: function(sale) {
sale.destroy({
success: function() {},
error: function(error) {
console.error("Error deleting Sale. " + error.code + ": " + error.message);
}
});
},
error: function(error) {
console.error("Error finding Sale for card. " + error.code + ": " + error.message);
}
});

//add message to creator and all owners (and push) TODO
}
});

/** Deletes a card vote and its data */
Parse.Cloud.afterDelete("CardVote", function(request) {
console.log("card vote after delete");
var votedCard = request.object.get("currentVotedCard");

if (votedCard != null)
votedCard.destroy({
success: function() {},
error: function(error) {
console.error("Error deleting VotedCard. " + error.code + ": " + error.message);
}
});
});

/** Deletes a card vote and its data */
Parse.Cloud.afterDelete("VotedCard", function(request) {
console.log("voted card after delete");
var abilities = request.object.get("abilities");

if (abilities != null)
Parse.Object.destroyAll(abilities, {
success: function() {},
error: function(error) {
console.error("Error deleting VotedCard abilities. " + error.code + ": " + error.message);
}
});
});

/** Called before saving a card gives default values */
Parse.Cloud.beforeSave("Card", function(request, response) {
  console.log("saving card");
  if (!request.object.get("reports")) {
    request.object.set("reports", 0);
  }
    if (!request.object.get("skipDelete")) {
    request.object.set("skipDelete", false);
  }
  response.success();
});

/** Called before saving a sale gives default values */
Parse.Cloud.beforeSave("Sale", function(request, response) {
  console.log("saving sale");
  if (!request.object.get("reports")) {
    request.object.set("reports", request.object.get("card").get("reports"));
  }
  response.success();
});

/** Calculate + ELO Rating on WIN */
Parse.Cloud.define("getELORatingOnWin", function(request, response) {

  var matchWinnerEloRating = request.params.User1Rating;
  var matchLoserEloRating = request.params.User2Rating;

  console.log(matchWinnerEloRating);

  console.log(matchLoserEloRating);

  //calculate elo changes
  //elo depends upon a table illustrated as such
  //ELO difference  Expected score:
  //  0 0.50
  //  20  0.53
  //  40  0.58
  //  60  0.62
  //  80  0.66
  //  100 0.69
  //  120 0.73
  //  140 0.76
  //  160 0.79
  //  180 0.82
  //  200 0.84
  //  300 0.93
  //  400 0.97
  //
  //The formula to calculate a player's new rating based on his/her previous one is:
  //Rn = Ro + C * (S - Se)      (1)
  //where:
  //Rn = new rating
  //Ro = old rating
  //S  = score  --this is usually 1, representing the "weight" of the match
  //Se = expected score
  //C  = constant --this represents the speed/volatility at which ratings will change, we'll use a value of 30

  var C = 30;
  var eloDifference = Math.abs(matchWinnerEloRating-matchLoserEloRating);
  console.log("eloDiff");
  console.log(eloDifference);

  var playerOneNewRating;
  var scoreRatio;
  if(eloDifference <=20 && eloDifference >=0)
  {
    playerOneNewRating = matchWinnerEloRating + C *(0.51);
  }
  else
  if(eloDifference <=40)
  {
    playerOneNewRating = matchWinnerEloRating + C *(1-0.53);
  }
  else
  if(eloDifference <=60)
  {
    playerOneNewRating = matchWinnerEloRating + C *(1-0.58);
  }
  else
  if(eloDifference <=80)
  {
    playerOneNewRating = matchWinnerEloRating + C *(1-0.62);
  }
  else
  if(eloDifference <=100)
  {
    playerOneNewRating = matchWinnerEloRating + C *(1-0.66);
  }
  else
  if(eloDifference <=120)
  {
    playerOneNewRating = matchWinnerEloRating + C *(1-0.69);
  }
  else
  if(eloDifference <=140)
  {
    playerOneNewRating = matchWinnerEloRating + C *(1-0.73);
  }
  else
  if(eloDifference <=160)
  {
    playerOneNewRating = matchWinnerEloRating + C *(1-0.76);
  }
  else
  if(eloDifference <=180)
  {
    playerOneNewRating = matchWinnerEloRating + C *(1-0.79);
  }
  else
  if(eloDifference <=200)
  {
    playerOneNewRating = matchWinnerEloRating + C *(1-0.82);
  }
  else
  if(eloDifference <=300)
  {
    playerOneNewRating = matchWinnerEloRating + C *(1-0.87);
  }
  else
  if(eloDifference <=400)
  {
    playerOneNewRating = matchWinnerEloRating + C *(1-0.93);
  }
  else
  if(eloDifference >=401)
  {
    playerOneNewRating = matchWinnerEloRating + C *(1-0.95);
  }

  //subtract the difference of playerOneNewRating to set playerTwoNewRating
  var player1EloChange = playerOneNewRating-matchWinnerEloRating;

  player1EloChange = Math.ceil(player1EloChange);

  console.log("player1+ELORating");
  console.log(player1EloChange);

  response.success(player1EloChange);
});

/**
* increments player xp and level, client specifies small, medium, or large xp gain value and number of cards used from each element.  Request parameters as follows:
*userXPGain (small, medium, large)
*userXP
*userLevel
*earthCards
*fireCards
*iceCards
*lightCards
*darkCards
*lightningCards
Server calculates net gain in XP/Level for the following user variables:
*userXP
*userLevel
*userEarthXP
*userEarthLevel
*userFireXP
*userFireLevel
*userIceXP
*userIceLevel
*userLightXP
*userLightLevel
*userDarkXP
*userDarkLevel
*userLightningXP
*userLightningLevel
Server awards unlocked cards or coin awards to player inventory, client runs same logic to know what to display if call is successful
**/
Parse.Cloud.define("awardUserXP", function(request, response) {
var xpGain = request.params.userXPGain;
var userLevel = request.user.get("userLevel");
var userXP = request.user.get("userXP");
//variables for the # of cards used by player deck
var earthCards = request.params.earthCards;
var fireCards = request.params.fireCards;
var iceCards = request.params.iceCards;
var lightCards = request.params.lightCards;
var darkCards = request.params.darkCards;
var lightningCards = request.params.lightningCards;

console.log(userXP);
console.log(userLevel);
var xpIncrement = 0;
//smallXPGain
if (xpGain==1)
{
xpIncrement = 5;
}
if (xpGain==2)
{
xpIncrement = 10;
}
if (xpGain==3)
{
xpIncrement= 20;
}

  //calculate new level and xp.  xp follows straight linear increase (100 xp for level 1, 200xp level 2, 4000 xp level 40)
  //level 1>2 requires 100XP.
  //level 2>3 requires 200XP
  //level 10+ requires 1000XP

var newXPThreshold = userLevel *100;

//add xpGain to currentXP
var newXPTotal = userXP + xpIncrement;

if(newXPTotal>newXPThreshold)
{
request.user.increment("userLevel", 1);
request.user.increment("userXP",xpIncrement);
}
else
{
request.user.increment("userXP",xpIncrement);
}

  //calculate specific cards (fire, ice, lightning, etc.) xp.  xp follows straight linear increase by 1000 per level (1000 xp for level 1, 2000xp level 2, 40000 xp level 40)
  //level 1>2 requires 1000XP.
  //level 2>3 requires 2000XP
  //level 10+ requires 10000XP

//xp increment for each card type follows # of cards used
var EarthCardXPIncrement = xpIncrement *earthCards;
var IceCardXPIncrement = xpIncrement *iceCards;
var FireCardXPIncrement = xpIncrement * fireCards;
var LightningCardXPIncrement = xpIncrement * lightningCards;
var DarkCardXPIncrement = xpIncrement *darkCards;
var LightCardXPIncrement = xpIncrement *lightCards;

var userEarthLevel = request.user.get("userEarthLevel");
var userIceLevel = request.user.get("userIceLevel");
var userFireLevel = request.user.get("userFireLevel");
var userLightningLevel = request.user.get("userLightningLevel");
var userDarkLevel = request.user.get("userDarkLevel");
var userLightLevel = request.user.get("userLightLevel");

var userEarthXP = request.user.get("userEarthXP");
var userIceXP = request.user.get("userIceXP");
var userFireXP = request.user.get("userFireXP");
var userLightningXP = request.user.get("userLightningXP");
var userDarkXP = request.user.get("userDarkXP");
var userLightXP = request.user.get("userLightXP");

var EarthXPThreshold = userEarthLevel *1000;
var IceXPThreshold = userIceLevel *1000;
var FireXPThreshold = userFireLevel *1000;
var LightningXPThreshold = userLightningLevel*1000;
var DarkXPThreshold = userDarkLevel*1000;
var LightXPThreshold = userLightLevel*1000;

var newEarthXPTotal = userEarthXP+EarthCardXPIncrement;
if(newEarthXPTotal>EarthXPThreshold)
{
request.user.increment("userEarthLevel", 1);
request.user.increment("userEarthXP",EarthCardXPIncrement);
}
else
{
request.user.increment("userEarthXP",EarthCardXPIncrement);
}

var newIceXPTotal = userIceXP+IceCardXPIncrement;
if(newIceXPTotal>IceXPThreshold)
{
request.user.increment("userIceLevel", 1);
request.user.increment("userIceXP",IceCardXPIncrement);
}
else
{
request.user.increment("userIceXP",IceCardXPIncrement);
}

var newFireXPTotal = userFireXP+FireCardXPIncrement;
if(newFireXPTotal>FireXPThreshold)
{
request.user.increment("userFireLevel", 1);
request.user.increment("userFireXP",FireCardXPIncrement);
}
else
{
request.user.increment("userFireXP",FireCardXPIncrement);
}

var newLightningXPTotal = userLightningXP+LightningCardXPIncrement;
if(newLightningXPTotal>LightningXPThreshold)
{
request.user.increment("userLightningLevel", 1);
request.user.increment("userLightningXP",LightningCardXPIncrement);
}
else
{
request.user.increment("userLightningXP",LightningCardXPIncrement);
}

var newDarkXPTotal = userDarkXP+DarkCardXPIncrement;
if(newDarkXPTotal>DarkXPThreshold)
{
request.user.increment("userDarkLevel", 1);
request.user.increment("userDarkXP",DarkCardXPIncrement);
}
else
{
request.user.increment("userDarkXP",DarkCardXPIncrement);
}

var newLightXPTotal = userLightXP+LightCardXPIncrement;
if(newLightXPTotal>LightXPThreshold)
{
request.user.increment("userLightLevel", 1);
request.user.increment("userLightXP",LightCardXPIncrement);
}
else
{
request.user.increment("userLightXP",LightCardXPIncrement);
}

request.user.save({
}, {
success: function() {
response.success();
},
error: function(error) {
response.error("Failed to sell");
}
});
});
