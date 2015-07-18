
var MAPS = {
	"MillionMapsSM":"http://www.arcgis.com/apps/Embed/index.html?webmap=e723a5b6e2c54e29989c1c49fb563e02&amp;extent=-118.5103,34.0079,-118.4864,34.0266&amp;zoom=true&amp;scale=true&amp;theme=light",
	"MainStreetSM":"http://www.arcgis.com/apps/Embed/index.html?webmap=d0c530cddee643269bde86b000d9c489&amp;extent=-118.4819,33.9979,-118.4793,34&amp;zoom=true&amp;scale=true&amp;theme=light",
    "UCLA":"http://www.arcgis.com/apps/Embed/index.html?webmap=ee80b7ce24cc466c841e639ca1e3dccc&amp;extent=-118.4621,34.0444,-118.4206,34.0784&amp;zoom=true&amp;scale=true&amp;basemap_gallery=true&amp;theme=light",
    "London":"http://www.arcgis.com/apps/Embed/index.html?webmap=55d39fc56a624fe0bb1a94f8a418280c&amp;gcsextent=-0.1558,51.4833,-0.0628,51.5332&amp;zoom=true&amp;scale=true&amp;basemap_gallery=true&amp;theme=light",
	"Amsterdam":"http://www.arcgis.com/apps/Embed/index.html?webmap=fe824a4302bb4f27a55d7e2a7989847b&amp;gcsextent=4.8462,52.344,4.9283,52.3907&amp;zoom=true&amp;scale=true&amp;basemap_gallery=true&amp;theme=light",
	"Rome":"http://www.arcgis.com/apps/Embed/index.html?webmap=052090a1958e4bc18aed19ce9f111669&amp;gcsextent=12.4386,41.8747,12.5178,41.921&amp;zoom=true&amp;scale=true&amp;basemap_gallery=true&amp;theme=light",
	"Anaheim":"http://www.arcgis.com/apps/Embed/index.html?webmap=c36c9f2193f34826bfe06b6c86710597&amp;gcsextent=-118.1005,33.5779,-117.6765,33.8926&amp;zoom=true&amp;scale=true&amp;basemap_gallery=true&amp;theme=light",
	"Santa Monica":"http://www.arcgis.com/apps/Embed/index.html?webmap=83971f9b818e4eec83df051c670fb8b0&amp;gcsextent=-118.6621,33.9315,-118.3572,34.0792&amp;zoom=true&amp;scale=true&amp;basemap_gallery=true&amp;theme=light",
	"San Diego":"http://www.arcgis.com/apps/Embed/index.html?webmap=5661b683f2cc4412a0bdc5c311c2fce8&amp;gcsextent=-117.3381,32.6532,-117.0333,32.8031&amp;zoom=true&amp;scale=true&amp;basemap_gallery=true&amp;theme=light",
    "Big Island":"http://www.arcgis.com/apps/Embed/index.html?webmap=da209fcf6173471ab9f2233f0d645232&amp;gcsextent=-157.0939,18.9021,-154.1194,20.7879&amp;zoom=true&amp;scale=true&amp;basemap_gallery=true&amp;theme=light",
		"SantaMonica":"http://www.arcgis.com/apps/Embed/index.html?webmap=83971f9b818e4eec83df051c670fb8b0&amp;gcsextent=-118.6621,33.9315,-118.3572,34.0792&amp;zoom=true&amp;scale=true&amp;basemap_gallery=true&amp;theme=light",
		"USC":"http://www.arcgis.com/apps/Embed/index.html?webmap=0e510382894b4d97ae444b87eb70b617&amp;gcsextent=-118.2963,34.0133,-118.2758,34.027&amp;zoom=true&amp;scale=true&amp;basemap_gallery=true&amp;theme=light",
	"SanDiego":"http://www.arcgis.com/apps/Embed/index.html?webmap=5661b683f2cc4412a0bdc5c311c2fce8&amp;gcsextent=-117.3381,32.6532,-117.0333,32.8031&amp;zoom=true&amp;scale=true&amp;basemap_gallery=true&amp;theme=light",
	"Toronto":"http://www.arcgis.com/apps/Embed/index.html?webmap=2404c447d5424392874004ee8f6a74cd&amp;gcsextent=-79.4611,43.6135,-79.2943,43.6968&amp;zoom=true&amp;scale=true&amp;basemap_gallery=true&amp;theme=light",
	"Palm Springs":"http://www.arcgis.com/apps/Embed/index.html?webmap=adf1ae6912c74fe9a323a5292e9d46ac&amp;gcsextent=-116.6443,33.6621,-116.3106,33.9121&amp;zoom=true&amp;scale=true&amp;basemap_gallery=true&amp;theme=light",
	"PalmSprings":"http://www.arcgis.com/apps/Embed/index.html?webmap=adf1ae6912c74fe9a323a5292e9d46ac&amp;gcsextent=-116.6443,33.6621,-116.3106,33.9121&amp;zoom=true&amp;scale=true&amp;basemap_gallery=true&amp;theme=light",
    "BigIsland":"http://www.arcgis.com/apps/Embed/index.html?webmap=da209fcf6173471ab9f2233f0d645232&amp;gcsextent=-157.0939,18.9021,-154.1194,20.7879&amp;zoom=true&amp;scale=true&amp;basemap_gallery=true&amp;theme=light",
}


$(document).ready(function() {
    $("#page_display_trip_plan").bind("pagebeforeshow", function(event) {
        loadMap();
        loadTripPlansToSelect();        
        //loadPlaces(ACTIVE_TRIP_PLAN_UUID);
        loadPlaces(window.globalID.tripPlanuuid);
    });
});

$(document).ready(function() {
    $("#page_display_map").bind("pagebeforeshow", function(event) {
        loadMapNotLoggedIn();
    });
});

function loadMap() {
    $("#div_add_map_container").empty();
    $("#div_add_map_container_not_logged_in").empty();
    $("#div_add_map_container").append(
        "<iframe class='map-frame' frameborder='0' scrolling='no' marginheight='0' marginwidth='0' "
        + "src='"
        + MAPS[ACTIVE_MAP]
        + "'></iframe>"
    );
}

function loadMapNotLoggedIn() {
    $("#div_add_map_container_not_logged_in").empty();
    $("#div_add_map_container").empty();
    $("#div_add_map_container_not_logged_in").append(
        "<iframe class='map-frame' frameborder='0' scrolling='no' marginheight='0' marginwidth='0' "
        + "src='"
        + MAPS[ACTIVE_MAP]
        + "'></iframe>"
    );
}
