/*
  This file contains all the logic to get current locations from phone, etc.
  It used a Object Oriented Concept
  */
/*
    Get password and load the dialog
*/
var redeemPassword = "0";
var partnerUUID = "0";
var couponIMAGE = "0";

$(document).ready(function() {
                  $("#popup_password").popup();
                  });

function saveCoupon(uuid, place_name) {
    $("#popup_password").popup('close');
    localStorage.setItem(uuid, place_name);
    navigator.notification.alert("Saved! Press the green button when you want to use the coupon", function(){}, "Coupon Saved");
    //alert("Saved! Press the green button when you want to use the coupon");
    refreshListview(uuid,"");
    
}

function passwordClicked(uuid, place_name) {
    $("#div_password_name").empty();
    $("#div_password_info").empty();
    $("#div_pass_buttons").empty();
    window.globalID.offeruuid = uuid;
    $("#div_password_name").append("<h2>"+place_name+"</h2>");
    $("#div_password_info").append("<input type='tel' pattern='[0-9]*' inputmode='numeric' style='-webkit-text-security: disc' name='password' id='offer_password' value='' placeholder='PASSWORD'>");
    $("#div_pass_buttons").append("<button  href='#' onclick='passwordCheck();' data-role='button'>Get Coupon</button>"
                                  +"<button data-role='button'"
                                  + " onclick=\x22saveCoupon(\x27"
                                  + uuid
                                  + "\x27,\x27"
                                  + place_name
                                  + "\x27);\x22>Redeem Later</button>");
//    $("#popup_password").popup();
    $("#popup_password").popup( "option", "transition", "pop" );
    $("#popup_password").popup({
                           positionTo: "window"
                           });
    $("#popup_password").popup("open");
    //Performance note: call on local data will be faster --> wating for improvement
    $.getJSON(window.globalURL + "/getPlaces?trip_plan_uuid=" + window.globalID.tripPlanuuid + "&" + window.apikey, function(tripplan){
              $.each(tripplan.places, function(i, item){
                     var tmpID = item.uuid;
                     var tmpIsSub = item.is_subscribed;
                     if(item.offer_uuid == window.globalID.offeruuid && tmpIsSub == "true"){
                        togglePlaceSubscription(tmpID);
                }
                     
            })
    });
    
    $.getJSON(window.globalURL + "/getOffer?offer_uuid="+ window.globalID.offeruuid + "&" + window.apikey, function(offer){
              redeemPassword = offer.redeem_password;
              partnerUUID = offer.partner_uuid;
              couponIMAGE = offer.coupon.image_data;
              });
    
}


function passwordCheck(){
    var inputPassword = document.getElementById("offer_password").value;
    if( inputPassword == redeemPassword){
        getCouponClicked(window.globalID.offeruuid, partnerUUID, couponIMAGE);
    }
    else{
        navigator.notification.alert("Wrong password, please try again", function(){}, "Wrong Password");
        //alert("Wrong password, please try again");
    }
}