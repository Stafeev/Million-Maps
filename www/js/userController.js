
var USERNAME_EXISTS = false;

$(document).ready(function() {
    // Initializes the validator.
    jQuery.validator.setDefaults({
        debug:true,
        success:"valid",
        errorElement:"label",
        errorClass: "errorLabel"
    });

    // Binds a function to the username field of form_create_user.
    // When focus leaves the username field, this checks the database to see
    // if the username is already in use.
    $("form[id='form_create_user'] input[name='username']").bind ("blur", function (event) {
        checkUsername($("form[id='form_create_user'] input[name='username']").val(), function(exists) {
            if (exists) {
                USERNAME_EXISTS = true;
                $("form[id='form_create_user'] input[name='username']").valid();
            }
            else {
                USERNAME_EXISTS = false;
                $("form[id='form_create_user'] input[name='username']").valid();
            }
        });
    });

    // Resets the global variable that keeps track of if the username is in use
    // (when the username field gets focus) so that when a new username is typed
    // the error message dissapears.
    $("form[id='form_create_user'] input[name='username']").bind ("focus", function (event) {
        USERNAME_EXISTS = false;
    });

    // Adds a custom validator to check if the username exists in the database.
    jQuery.validator.addMethod("checkUsername", function(value, element) {
        return !USERNAME_EXISTS;
    }, "This username is already in use. Please choose another.");

    // Adds a custom validator to reject entries with spaces.
    jQuery.validator.addMethod("noSpace", function(value, element) { 
        return value.indexOf(" ") < 0 && value != ""; 
    }, "Spaces are not allowed in this field.");    

    // Defines and starts the validator for form_create_user.
    $("#form_create_user").validate({
        rules: {
            username: {
                required:true,
                rangelength:[6, 30],
                noSpace:true,
                checkUsername:true
            },
            password: {
                required:true,
                rangelength:[6, 30],
                noSpace:true
            },
            email: {
                required:true,
                email:true
            }
        },
        messages: {
            email: {
                email:"Email must be in the form of name@domain.com"
            }
        },
        errorPlacement: function (error, element) {
            error.appendTo(element.parent().prev());
        }
    });
});

// userLoginClicked - when the login button is clicked, gets the info
// from the form and uses it to log in.
function userLoginClicked() {
    var loginData = $("#form_user_login").serializeObject();
    userLogin(loginData, userLoginSuccessCB, userLoginErrorCB);
}
function anonymousLoginClicked() {
    $.getJSON(window.globalURL + "/anonymousLogin?device_id=" + device.uuid, function(anonymousUser){
        anonymousLogin(anonymousUser,userLoginSuccessCB, userLoginErrorCB);
    });
}
// createUserClicked - when the create user button is clicked, gets the
// info from the form and performs one last validation, then creates the user if
// the form is valid.
function createUserClicked() {
    var validator = $("#form_create_user").validate();

    if(validator.form()) {
        var createUserData = $("#form_create_user").serializeObject();
        postNewUser(createUserData, createUserSuccessCB, createUserErrorCB);
    }
}

// userLogout - logs the user out.
function userLogout() {
//    if(window.mobilePlugin){
//    	window.mobilePlugin.onUserLogout();
//    }
    
    doLogout();
    $.mobile.changePage("#page_user_start");
}

//this code has been introduced by Abdullah AlAskari to fix the plugin to work on the map view.
//based on user requirements, map view should be the first view that user see after login.
//without the code below, the plugin does not work in the map view after login.

function loadPlans()
{
    function loadPlansSuccess(tripPlanList)
    {
        if(window.globalID.tripPlanuuid !== "undefined")
        {
            //return;

        }
        else
        {
            if (tripPlanList.length > 0)
            {
                window.globalID.tripPlanuuid = tripPlanList[0].uuid;
            }
            
            
        }
        
        if (!loaded)
        	{
        	
        	loaded = true;
        myPlan = window.globalID.tripPlanuuid;
        requestTripPlan(window.globalURL + '/getPlaces?trip_plan_uuid='+myPlan, function(tripplan){
                        loadPlaces(myPlan);
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
                        
                        //alert("null");
                        var bgGeo = window.plugins.backgroundGeofencing;
                        
                        bgGeo.configure(configureSuccessCB,configureErrorCB,tripplan);
                        bgGeo.start(startSuccessCB,startErrorCB);
                        
        
                        
                        });
        
        	}

    }
    
    function loadPlansError(tripPlanList)
    {
        // Do nothing.
    }
    
    readMultipleTripPlans("user_uuid", USER_UUID, loadPlansSuccess, loadPlansError);
}

// userLoginSuccessCB - a callback for use with userLogin.
function userLoginSuccessCB() {
    $("#form_user_login").trigger("reset");
    //here is the call to make sure plugin is started in the map view after login.
    //loadPlans();
    
    //$.mobile.changePage("#page_display_trip_plan"); //AMA
    $.mobile.changePage("#page_display_map");
//    if(window.mobilePlugin){
//    	window.mobilePlugin.onUserAccountInfoChanged();
//    }
}

// userLoginErrorCB - a callback for use with userLogin.
function userLoginErrorCB() {
    $.mobile.changePage("#page_user_login_error");
    $("#form_user_login").trigger("reset");
}

// createUserSuccessCB - a callback for use with postNewUser.
function createUserSuccessCB() {
    $.mobile.changePage("#page_create_user_success");
    $("#form_create_user").trigger("reset");
}

// createUserErrorCB - a callback for use with postNewUser.
function createUserErrorCB() {
    $.mobile.changePage("#page_create_user_error");
}



