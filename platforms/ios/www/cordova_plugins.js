cordova.define('cordova/plugin_list', function(require, exports, module) {
module.exports = [
    {
        "file": "plugins/com.vresorts.background-geofencing/www/BackgroundGeofencing.js",
        "id": "com.vresorts.background-geofencing.BackgroundGeofencing",
        "clobbers": [
            "plugins.backgroundGeofencing"
        ]
    },
    {
        "file": "plugins/org.apache.cordova.device/www/device.js",
        "id": "org.apache.cordova.device.device",
        "clobbers": [
            "device"
        ]
    },
    {
        "file": "plugins/org.apache.cordova.statusbar/www/statusbar.js",
        "id": "org.apache.cordova.statusbar.statusbar",
        "clobbers": [
            "window.StatusBar"
        ]
    },
    {
        "file": "plugins/org.apache.cordova.dialogs/www/notification.js",
        "id": "org.apache.cordova.dialogs.notification",
        "merges": [
            "navigator.notification"
        ]
    }
];
module.exports.metadata = 
// TOP OF METADATA
{
    "com.vresorts.background-geofencing": "0.3.6",
    "org.apache.cordova.device": "0.3.0",
    "org.apache.cordova.statusbar": "0.1.10",
    "org.apache.cordova.dialogs": "0.3.0"
}
// BOTTOM OF METADATA
});