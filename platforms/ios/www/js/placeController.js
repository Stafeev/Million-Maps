//
//   This file contains logic related to displaying places in a trip plan
//
if(typeof(Storage)!=="undefined") {
    localStorage.placeUpdated = "false";
}
$(document).ready(function() {
    $("#popup_delete_place").popup();
});

function requestTripPlan(url, callback){
	var xmlhttp = new XMLHttpRequest();

	xmlhttp.onreadystatechange = function() {
	if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
		var myArr = JSON.parse(xmlhttp.responseText);
	    callback(myArr);
	    }
	}

	xmlhttp.open("GET", url, true);
	xmlhttp.send();
}

function loadPlaces(tripPlanUUID) {
    if(tripPlanUUID !== "undefined") {
    }
    else {
        $("#list_view_places").empty();
        $("#list_view_places").append("<li>No active trip plan selected. Select a trip plan from the box above.</li>");
        $("#list_view_places").listview("refresh"); 
        return;
    }
	
    window.globalID.tripPlanuuid = tripPlanUUID;
    // Nested function definition for the success callback that goes to readMultiplePlaces().
    
    function loadPlacesSuccessCB(placesList) {
    	this.curPlaceList = placesList;
//    	if(window.mobilePlugin) {
//    		mobilePlugin.onTripplanSwitched(tripPlanUUID);
//    	}
    
        $("#list_view_places").empty();

        placesList.forEach(function(place) {
                           if(place.offer_uuid != "0") {
                           var offerDetail =
                           "<a href='#' data-role='button' data-mini='true' style='width:4em; float:left;' "
                           + "onclick=\x22offerDetailsClicked(\x27"
                           + place.offer_uuid
                           + "\x27);\x22>Details</a>";
                           var switchHTML =
                           "<div class='containing-element' style='vertical-align:middle;margin-top:-0.2em; height:100%;    width: auto; text-align:right; float:left;'> <select onchange=\x22togglePlaceSubscription(\x27"
                           + place.uuid
                           + "\x27);\x22"
                           + "name='switch-" + place.uuid + "' "
                           + "id='switch-" + place.uuid + "' data-role='slider' data-mini='true' >"
                           + "<option value='off'>No Thanks</option>"
                           + "<option value='on'>Get Discount</option></select></div>";
                           
            //***Button for coupon and barcode testing
                var testButton =
                    "<a href='#' data-role='button' data-mini='true' style='width:40px;' "
                    + "onclick=\x22passwordClicked(\x27"
                    + place.offer_uuid
                    + "\x27,\x27"
                    + place.place_name
                    + "\x27);\x22>Test</a>";
//                var subscribedCheckboxHTML =
//                    "<input onchange=\x22togglePlaceSubscription(\x27"
//                    + place.uuid
//                    + "\x27);\x22 type=\x22checkbox\x22 data-type='vertical'"
//                    + "data-mini='true' data-iconpos='left' name='checkbox-" + place.uuid + "' "
//                    + "id='checkbox-" + place.uuid + "'/>"
//                    + "<label data-inline='true' style='width:86px;heigth:36px;padding:8px;' for='checkbox-" 
//                    + place.uuid
//                    +"'><div class='ui-icon-heart ui-btn-icon-notext'></div></label>";
                           
                           var activeRedeem = false;
                           
                           //Artem Code
                           var redeemButton;
                           
                           //if item is in the storage then enable redeem button
                           if (localStorage.getItem(place.offer_uuid) != null) {
                           redeemButton =
                           "<a href='#' name='redeem-" + place.offer_uuid + "' "
                           + "id='redeem-" + place.offer_uuid + "' data-role='button' data-inline='true'"
                           + "data-mini='true' style='width:50px; float: left; background: #2EFE64;' "
                           + "onclick=\x22passwordClicked(\x27"
                           + place.offer_uuid
                           + "\x27,\x27"
                           + place.place_name
                           + "\x27);\x22>Redeem</a>";
                           activeRedeem = true;
                           }
                           else
                           {
                           redeemButton =
                           "<a href='#' name='redeem-" + place.offer_uuid + "' "
                           + "id='redeem-" + place.offer_uuid + "' data-role='button' data-inline='true'"
//                           + "data-mini='true' class='ui-disabled' style='width:50px; background: #2EFE64;' "
                           + "data-mini='true' style='width:50px; float:left; background: #2EFE64;' "
                           + "onclick=\x22passwordClicked(\x27"
                           + place.offer_uuid
                           + "\x27,\x27"
                           + place.place_name
                           + "\x27);\x22>Redeem</a>";
                           activeRedeem = false;
                           
                           
                           }
                           
                           //end Artem Code

            }
            else {

                var offerDetail = "";
                var switchHTML = "";
                var testButton = "";
//                var subscribedCheckboxHTML = "";
            }

            $("#list_view_places").append(
                "<li><div>"
                + "<b>" + place.place_name + "</b>" + "<br>"
                + "<div class='word-break'><i>"
                + place.address + "</i></div>"
                + "<div class='word-break'>"
                + place.short_desc + "</div>"
                
                + "<div data-role='controlgroup' data-disabled='true' data-type='horizontal' class='ui-grid-a' style='width:100%; float:left;'>"
               // + "<a href='" + place.info_url + "'target='_blank' data-role='button' data-mini='true'  style='width:40px;'>Info</a>"
                + offerDetail
                 +redeemButton //Artem Code
                //+ "&nbsp;&nbsp;"
//                + subscribedCheckboxHTML
                + switchHTML
                                          
                + "</div>"
               
                //+ testButton


		        + "</li>"
		    );
            
                           if (activeRedeem == false)
                           {
            $("#redeem-" + place.offer_uuid).hide();
                           }
                           
            $("#list_view_places").listview("refresh");
            $("#list_view_places").trigger("create");
            if(place.is_subscribed == "true") {
                $("#switch-"+ place.uuid).val("on").slider("refresh");
//                $("#checkbox-"+ place.uuid).attr("checked", true).checkboxradio("refresh");
            }
        });
    }

//    readMultiplePlaces("trip_plan_uuid", tripPlanUUID, loadPlacesSuccessCB, loadPlacesErrorCB);
// 		read data from api.
    // for test
    //tripPlanUUID = 'a137a68a-be1f-11e4-a532-9192b501077c';
    requestTripPlan(window.globalURL + '/getPlaces?trip_plan_uuid='+tripPlanUUID + '&' + window.apikey, function(tripplan){
    	loadPlacesSuccessCB(tripplan.places);
        // Nested function definition for the error callback that goes to readMultiplePlaces()
        function loadPlacesErrorCB() {
            // TODO: Deal with this error.
        }    
        function configureSuccessCB() {
            // 
        }        
        function configureErrorCB() {
            // 
        }     
        function startSuccessCB() {
            // 
        }        
        function startErrorCB() {
            // 
        } 
        
        loaded = true;
    	var bgGeo = window.plugins.backgroundGeofencing;
		//getCurrentPosition();
        //getStoreLocation();
        //Trajon Track plugin updating head
    	//var anonymousTripplan = {"uuid":"none", "trip_plan_name":"none", "user_uuid":"none", "places":placesList};
        bgGeo.configure(configureSuccessCB,configureErrorCB,tripplan);
        bgGeo.start(startSuccessCB,startErrorCB);
        //Trajon Track plugin updating tail
        
        
});
    
}

function deletePlaceClicked(placeUUID, tripPlanUUID) {
    // Nested function definition for the success callback that goes to deletePlace().
    function deletePlaceClickedSuccessCB() {
        loadPlaces(tripPlanUUID);
    }

    // Nested function definition for the error callback that goes to deletePlace().
    function deletePlaceClickedErrorCB() {
        loadPlaces(tripPlanUUID);
    }

    deletePlace(placeUUID, deletePlaceClickedSuccessCB, deletePlaceClickedErrorCB);

    $("#popup_delete_place").popup("close");
}

function deletePlaceClickedUnconfirmed(placeUUID, tripPlanUUID) {
    $("#div_delete_place_confirm").empty();

    $("#div_delete_place_confirm").append(
        "<p>Are you sure you want to delete this place?</p>"
        + "<button type='button' style='background-color:#EEEEEE; border-style:solid; border-color:#CCCCCC;' "
        + "onclick=\x22deletePlaceClicked(\x27" + placeUUID + "\x27, " + "\x27 " + tripPlanUUID + "\x27);\x22>Yes, delete the place.</button>"
        + "<button type='button' style='background-color:#EEEEEE; border-style:solid; border-color:#CCCCCC;' "
        + "onclick=\x22$('#popup_delete_place').popup('close');\x22>No, do not delete.</button>"
    );

    $("#div_delete_place_confirm").trigger("create");

    $("#popup_delete_place").popup("open");
}

function addPlace(placeData) {
    function addPlaceSuccessCB() {
        $("#div_added_message").empty();
        $("#div_added_message").append(
            placeData.place_name + " has been successfully added to your trip plan."
        );
        $.mobile.changePage("#page_add_place_success");
        PARAMS = {};
        IS_PARAMS = false;
        if(typeof(Storage)!=="undefined") {
            localStorage.placeUpdated = "true";
        }
    }

    function addPlaceErrorCB() {
        $.mobile.changePage("#page_add_place_error");
    }

    if(!IS_LOGGED_IN) {
        $.mobile.changePage("#page_add_place_not_logged_in");
    }
    else if(window.globalID.tripPlanuuid != "undefined") {
        placeData.trip_plan_uuid = window.globalID.tripPlanuuid;

        var matchName = placeData.place_name.replace(/\W/g, '')

        readMultipleOffers("match_name", matchName, function(offerList) {
            if(offerList.length > 0) {
                placeData.short_desc = offerList[0].short_desc;
                placeData.offer_uuid = offerList[0].uuid;
                createPlace(placeData, addPlaceSuccessCB, addPlaceErrorCB);
            }
            else {
                placeData.short_desc = "No offers available.";
                placeData.offer_uuid = "0";
                createPlace(placeData, addPlaceSuccessCB, addPlaceErrorCB);
            }
        },
        function() {
            $.mobile.changePage("#page_problem_with_place");
        });        
    }
    else {
        $.mobile.changePage("#page_no_active_trip_plan");
    }
}

function refreshListview(offerid, storename) {
    //alert(offerid);
//    $("#redeem-" + offerid).prop('disabled', true).removeClass('ui-disabled');
    if (localStorage.getItem(offerid) != null)
    {
        $("#redeem-" + offerid).show();
        $("#redeem-" + offerid).prop('disabled', false).removeClass('ui-disabled');
    }
    else
    {
        $("#redeem-" + offerid).hide();
        $("#redeem-" + offerid).prop('disabled', true).addClass('ui-disabled');
    }
    $("#list_view_places").listview("refresh");
    $("#list_view_places").trigger("create");
    
}

