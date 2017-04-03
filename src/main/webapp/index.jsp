<!DOCTYPE html>
<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=utf-8'>
<!--meta http-equiv="Pragma" content="no-cache"--> 
<title>OSM NoFarm 1.2</title>
<!-- 
    V 1.0 abgeleitet aus emergency/19 
    V 1.1 css/js von common-server
    V 1.2 active zoom levels anzeigen

-->
<base target="_top" />

<link rel='stylesheet' href='https://wambachers-osm.website/common/css/leaflet/leaflet_0.7.5.css' />
<link rel='stylesheet' href='https://wambachers-osm.website/common/css/leaflet/L.Control.ZoomDisplay.css' />
<link rel='stylesheet' href='https://wambachers-osm.website/common/css/leaflet/L.Control.MousePosition.css' />
<link rel='stylesheet' href='https://wambachers-osm.website/common/css/leaflet/L.Control.Loading.css' />
<link rel='stylesheet' href='https://wambachers-osm.website/common/css/leaflet/Leaflet.EditInOSM.css' />
<link rel='StyleSheet' href='https://wambachers-osm.website/common/js/leaflet/plugins/leaflet-messagebox/leaflet-messagebox.css'/>
<link rel="StyleSheet" href='https://wambachers-osm.website/common/js/leaflet/plugins/Leaflet.Dialog/Leaflet.Dialog.css'/>

<link rel='StyleSheet' href='css/map001.css'/>

<!--[if IE 6]>
   <link href="https://wambachers-osm.website/common/css/ie6.css" rel="stylesheet" type="text/css" />
<![endif]-->

<script>
   var myBase       = "nofarm";
   var myVersion    = "1";
   var mySubversion = "2"; 
   var FEATURE_COUNT = 5;   
   var myName       = myBase+"-"+myVersion+"."+mySubversion;
   var database     = "planet3";
   var loading      = 0;
   var host         = window.location.hostname;
   var protocol     = window.location.protocol;
   
   if (typeof console === "undefined" || typeof console.log === "undefined") {
     console = {};
     console.log = function() {};
   }
</script>

<script src='https://wambachers-osm.website/common/js/leaflet/leaflet.js'></script>

<script src='https://wambachers-osm.website/common/js/leaflet/L.TileLayer.Grayscale.js'></script>
<script src='https://wambachers-osm.website/common/js/leaflet/L.Control.ZoomDisplay.js'></script>
<script src='https://wambachers-osm.website/common/js/leaflet/L.Control.MousePosition.js'></script>
<script src='https://wambachers-osm.website/common/js/leaflet/L.Control.ActiveLayers.js'></script>
<script src='https://wambachers-osm.website/common/js/leaflet/L.Control.SelectLayers.js'></script>
<script src='https://wambachers-osm.website/common/js/leaflet/L.Control.Loading.js'></script>
<script src='https://wambachers-osm.website/common/js/leaflet/Leaflet.EditInOSM2.js'></script>
<script src='https://wambachers-osm.website/common/js/leaflet/plugins/leaflet-messagebox/leaflet-messagebox.js'></script>
<script src='https://wambachers-osm.website/common/js/leaflet/plugins/Leaflet.Dialog/Leaflet.Dialog.js'></script>
<script src='https://code.jquery.com/jquery-2.1.0.min.js'></script>
<script src='https://wambachers-osm.website/common/js/leaflet/shamov/leaflet-plugins-master/control/Permalink.js'></script>
<script src='https://wambachers-osm.website/common/js/leaflet/shamov/leaflet-plugins-master/control/Permalink.Marker.js'></script>
<script src='https://wambachers-osm.website/common/js/leaflet/shamov/leaflet-plugins-master/control/Permalink.Layer.js'></script>
<script src='https://wambachers-osm.website/common/js/leaflet/shamov/leaflet-plugins-master/control/Permalink.Overlay.js'></script>

   <style>
      html, body, #map {
         height:100%;
         width:100%;
         padding:0px;
         margin:0px;
      } 

#     .leaflet-tile { border: solid blue 1px; }

   </style>

<script language="javascript">
   function init() {

      function merge_options(obj1,obj2){
        var obj3 = {};
        for (var attrname in obj1) { 
           obj3[attrname] = obj1[attrname];
        }
        for (var attrname in obj2) { 
           obj3[attrname] = obj2[attrname];
        }
        return obj3;
      }

      function DisplayActiveLayers(layers) {
         console.log("Active base layer is "+layers.getActiveBaseLayer().name);

         var activeOverlayLayers = layers.getActiveOverlayLayers()
         for (var overlayId in activeOverlayLayers) {
            console.log("Active overlay layer is "+activeOverlayLayers[overlayId].name)
         }
      }

      function getIdxByName(Overlays, layer) {
         console.log("searching for",layer, "in", Overlays.length, "Overlays");
         for (var i=0;i < Overlays.length;i++) {
            if (Overlays[i].display == layer) {
               console.log("Found",i,"=", Overlays[i].display);
               return i;
            }
         }
         console.log("not found");
         return -1;
      }

      function ActivateOverlays() {
         console.log("ActivateOverlays()");
         for (var i=0; i< Overlays.length;i++) {
            if (Overlays[i].active) {
               OVL[i].addTo(map);
            }
         }
      }

      $(window).on("unload", function(e){
        console.log("here is unload event handler:",e.type);
        saveLocalStorage();
      });
      
      console.log("### Starting Emergency Map. host="+host+" version="+myVersion+"."+mySubversion+" ###");
     
//    var mapbox_token = GetMapboxToken("emergency");
      var mapbox_token = "pk.eyJ1Ijoid2FtYmFjaGVyIiwiYSI6ImY3Njk2YjY0MDgyNDJhZjNlMTdmYmVjZWYxZWE3MDNlIn0.1GZqaAa_KtToKDI8SFIoRw";

      var osmAttr   = 'Map data &copy; <a href="https://openstreetmap.org">OpenStreetMap</a> contributors ' +
                       '<a href="https://opendatacommons.org/licenses/odbl/1.0/">ODbl</a>, ' +
                      'Imagery &copy; <a href="https://openstreetmap.org">OpenStreetMap</a>',   
          osmOrgUrl = 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
          osmDeUrl  = 'https://{s}.tile.openstreetmap.de/tiles/osmde/{z}/{x}/{y}.png';

      var mbAttr = 'Map data &copy; <a href="https://openstreetmap.org">OpenStreetMap</a> contributors ' +
                   '<a href="http://opendatacommons.org/licenses/odbl/1.0/">ODbl</a>, ' +
                   'Imagery &copy; <a href="https://mapbox.com">Mapbox</a>',
          mbUrl  = 'https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.png?access_token='+ mapbox_token;

      var osmOrg     = L.tileLayer(osmOrgUrl, {
                          attribution: osmAttr });
      var osmOrgGray = L.tileLayer.grayscale(osmOrgUrl, {
                         attribution: osmAttr });
      var osmDe      = L.tileLayer(osmDeUrl, {
                          attribution: osmAttr });
      var streets    = L.tileLayer(mbUrl, {id: "mapbox.streets",   attribution: mbAttr});
      var grayscale  = L.tileLayer(mbUrl, {id: "mapbox.light", attribution: mbAttr});
      var terrain_v2 = L.tileLayer(mbUrl, {id: "mapbox.terrain-v2", attribution: mbAttr});
      var satellite  = L.tileLayer(mbUrl, {id: "mapbox.satellite", attribution: mbAttr});

      var msUrl      = "http://localhost:8083/cgi-bin/mapserv?map=/osm/mapserver/myMapserver.map";
      var qgisUrl    = "http://localhost:8084/cgi-bin/emergency/qgis_mapserv.fcgi";
      var geosUrl    = "../geoserver/wms";
      var wmflabsUrl = "http://{s}.tiles.wmflabs.org/hillshading/{z}/{x}/{y}.png";

      var owsrootUrl = "../geoserver/ows";

      var global_options = {
         format: "image/png8",
         transparent: true,
         buffer: 20,
         timeout: 300,
         heigth: 256,
         width: 256,
         exceptions: "application/vnd.ogc.se_inimage",
         maxZoom: 19,
         minZoom: 11
      };

       var defaultParameters = {   // not used here!!!
          service : "WFS",
          version : "2.0",
          request : "GetFeature",
          typeName : "osm:exifs",
          outputFormat : "json",
          format_options : "callback:getJson",
          SrsName : "EPSG:4326"
      };

      var Overlays = [  {layer:"contours", display:"Contours", active:false, visible:true, popup:false,
                         order:1, url:geosUrl, gsLayer:"osm:Contours"},
            {layer:"hillshading", display:"Hillshading", active:false, visible:true, popup:false,
                         order:2, url:wmflabsUrl, gsLayer:""},
            {layer:"nofarm", display:"No more farm", active:false, visible:true, popup:true,
                         order:3, url:geosUrl, gsLayer:"osm:NoFarm"}
      ];

      var localStorageBase = "";

      var hash;

      getLocalStorage();

      var OVL = [];

      for (var i=0; i< Overlays.length;i++) {
         console.log("adding OVL["+i+"] layer="+Overlays[i].layer);
         if (i != 1) 
            OVL[i] = L.tileLayer.wms(Overlays[i].url, 
                     merge_options(global_options, merge_options({"layers":Overlays[i].gsLayer},
                                  Overlays[i].localOptions)));
         else
            OVL[i] = L.tileLayer(wmflabsUrl,
                     merge_options(global_options, merge_options({
                        attribution: "Hillshading by ??? from NASA SRTM data",
                        minZoom: 3,
                        maxZoom: 16
                     },
                      Overlays[i].localOptions)));
      }
    
      var baseLayers = {
         "OpenStreetMap.org":           osmOrg,
         "Openstreetmap.org Grayscale": osmOrgGray,
         "OpenStreetMap.de":            osmDe,
         "Mapbox Streets":              streets,
         "Mapbox Grayscale":            grayscale,
         "Mapbox Satellite":            satellite
      };

      var overlayLayers = {
         "Contours":                    OVL[ 0],
         "Hillshading":                 OVL[ 1],
         "No more farm":                OVL[ 2]
      };

      var initLayer;
      
      if (storageAvailable('localstore')) {
         console.log("vor initLayer","checking",localStorageBase+"Base");
         console.log("initLayer is",localStorage.getItem(localStorageBase+"Base"));
   
         initLayer = (localStorage && localStorage.getItem(localStorageBase+"Base")!=null)
                     ?baseLayers[localStorage.getItem(localStorageBase+"Base")]:osmOrg;
      }
      else
         initLayer = osmOrgGray;

      console.log("initLayer=",initLayer._url);

//    console.log("type:",typeof hash);
      if (typeof hash !== "string") hash = "15/50.1115/8.098"; // wambach
      var zoom = hash.split("/")[0];
      var center = [hash.split("/")[1],hash.split("/")[2]] ;
      console.log(hash,"->",zoom,center[0],center[1]);

      var map = L.map("map", {
         center:		center,    // wambach                  
         zoom:			zoom,
         minZoom:		6,
         maxZoom:		18,
         layers:		initLayer,
         loadingControl:	true,
         editInOSMControlOptions: {
            zoomThreshold:	14,
            editors: 		["id","potlatch","josm"]}	
      });
      
      map.on("baselayerchange", function(e){
         console.log("baselayerchange called");
         if (localStorage) {
            console.log("saving "+localStorageBase, e.name, e);
            localStorage.setItem(localStorageBase+"Base", e.name);
         }
      }); 

      map.on("overlayadd", function(e){
         console.log("overlayadd:", e.name);
         var idx = getIdxByName(Overlays, e.name);
         console.log("activating",Overlays[idx].layer);
         Overlays[idx].active = true;
      });   

      map.on("overlayremove", function(e){
         console.log("overlayremove:",e.name)
         var idx = getIdxByName(Overlays, e.name);
         console.log("removing",Overlays[idx].layer);
         Overlays[idx].active = false;
      }); 
      
      map.on('zoomend', function(e) {
         var zoom = map.getZoom();
         console.log("zoom changed to",zoom);
         if (zoom >= global_options.minZoom) {
            console.log("do nofarm");
            $(".leaflet-control-zoom-display").css("background-color", "#62ef2b"); 
         }
         else {
            console.log("don't nofarm");
            $(".leaflet-control-zoom-display").css("background-color", "#FFFFFF"); 
         }
      });

      var layerControl = L.control.selectLayers(baseLayers, overlayLayers);

      layerControl.addTo(map);

      ActivateOverlays();

      DisplayActiveLayers(layerControl);
            
      $("select.leaflet-control-layers-overlays").attr("size",Overlays.length);
      
      L.control.mousePosition({
         position: "bottomright",
         separator: ", ",
         emptyString: "",
         lngFirst: true,
         prefix: "lon,lat: "
      }).addTo(map);

      var popupContent = null;

      var popupOptions = {
         "minWidth":	"491",
         "maxWidth":	"691",
         "minHeight":	"300",
         "maxHeight":	"400",
         "closeButton":	true
      };
      
      var dialogOptions = {
         "size":    [320,80],
         "maxSize": [320,80],
         "anchor":  [2,40]
      };
      
      var dialog = L.control.dialog(dialogOptions)
                    .setContent("<p style='font-size:200%; margin:0; text-align:center;'>NoFarm"+myVersion+"."+mySubversion+"</p>"+
                                "<div id='lag'></div>" +
                                "<div id='count'></div>")
                    .addTo(map);
      
      map.addControl(new L.Control.Permalink({text: 'Permalink', layers: layerControl, position: 'bottomright'}));
      
      console.log("Firing zoomend");
      map.fireEvent("zoomend");
      
      map.addEventListener("click", onMapClick);
      
      setInterval(getAction,60*10*1000);  // 10 min 
      getAction(); 
      
      getOsmReplicationLag();
      setInterval(getOsmReplicationLag,60*1000); // 1 min  
      setInterval(LagAnzeigen,1000); 
      
      getOsmLanduseCount();
      setInterval(getOsmLanduseCount, 60*60*1000); // 1h

// ********************************************************************************************
// ************************** START Functions *************************************************
// ********************************************************************************************
 
      function formatHash(args) {
      var center, zoom, layers;

      if (args instanceof L.Map) {
        center = args.getCenter();
        zoom = args.getZoom();
      } else {
        center = args.center || L.latLng(args.lat, args.lon);
        zoom = args.zoom;
      }

      center = center.wrap();

      var precision = 5;
  
      var hash = zoom +
          "/" + center.lat.toFixed(precision) +
          "/" + center.lng.toFixed(precision);

      return hash;
  }
  
// ----------------------------------------------------------------------------------------

      function storageAvailable(type) {
         try {
             var storage = window[type],
                 x = '__storage_test__';
             storage.setItem(x, x);
             storage.removeItem(x);
             return true;
         }
         catch(e) {
             console.warn("Your browser blocks access to " + type);
             return false;
         }
      }
      
// ----------------------------------------------------------------------------------------

      function saveLocalStorage() {
         
         if (!storageAvailable('localStorage')) {
                console.log("exit ########################## base #############################");
                return;
         }   
         else {         
            localStorageBase = host+"/"+myBase+"/";
   
   //       Overlays
   
            localStorage.setItem(localStorageBase+"Version","2");
            for (var i=0; i<Overlays.length;i++) {
               console.log("saving overlay layer", i, Overlays[i].layer,"active =",Overlays[i].active);
               console.log("setting",localStorageBase+"Overlays/"+Overlays[i].layer,Overlays[i].active);
               localStorage.setItem(localStorageBase+"Overlays/"+Overlays[i].layer,Overlays[i].active);
            }
      
   //       bbox & zoom
      
            var hash = formatHash(map);
            console.log("saving hash: ",hash);
            localStorage.setItem(localStorageBase+"hash",hash);
          
            console.log("exit ########################## base #############################");
         }
      }

// ----------------------------------------------------------------------------------------

      function getLocalStorage() { 
         
         if (!storageAvailable('localStorage')) {
                return;
         }   
         else {
            localStorageBase     = host+"/"+myBase+"/";
   
            console.log("localStorage:",localStorageBase);
   
            localStorage.removeItem("osm.wno-edv-service.de/leaflet1/base"); // cleanup
            localStorage.removeItem("osm.wno-edv-service.de/lights/base"); // cleanup
            localStorage.removeItem(localStorageBase+"-base"); // cleanup
            localStorage.removeItem(localStorageBase+"-Overlays"); // cleanup
            localStorage.removeItem(localStorageBase+"Overlays/defillibrators"); // cleanup
   
            console.log("localStorage.length="+localStorage.length);
            for (var i=0;i<localStorage.length;i++) {
               console.log("localStorage.key("+i+")="+localStorage.key(i) + " -> " +
                            localStorage.getItem(localStorage.key(i)));
               var key= localStorage.key(i);
               if (key.length > 32) { 
                  if ((host == "wambachers-osm.website") & (key.substring(0,32) == "osm.wno-edv-service.de/emergency")) {
                     console.log("will be deleted");
                     localStorage.removeItem(key);
                  }
               }
            }
   
            var version = localStorage.getItem(localStorageBase+"Version");
            for (var i=0; i< Overlays.length;i++) {
               console.log("getting state of overlay layer",Overlays[i].layer);
               Overlays[i].active = localStorage.getItem(localStorageBase+"Overlays/"+Overlays[i].layer) == "true";
               console.log("active overlay layers:", i, Overlays[i].layer,"=",Overlays[i].active);
            }
   
            hash = localStorage.getItem(localStorageBase+"hash");
            console.log("got hash",hash);
         }
      }

// ----------------------------------------------------------------------------------------

      function onMapClick(e) {
         var query = createQueryFromLayers(Overlays);
         console.log("onMapClick(): query=",query);
         if (query == "")
            return;
         var BBOX = map.getBounds()._southWest.lng + "," + map.getBounds()._southWest.lat + "," +
                    map.getBounds()._northEast.lng + "," + map.getBounds()._northEast.lat;
         var WIDTH = map.getSize().x;
         var HEIGHT = map.getSize().y;
         var X = map.layerPointToContainerPoint(e.layerPoint).x;
         var Y = map.layerPointToContainerPoint(e.layerPoint).y;
         var URL =           "?SERVICE=WMS&VERSION=1.1.1&REQUEST=GetFeatureInfo"  // WFS ist recommended 
                           + query
                           + "&BBOX="+BBOX
                           + "&BUFFER=100"
                           + "&FEATURE_COUNT="+FEATURE_COUNT
                           + "&HEIGHT="+HEIGHT+"&WIDTH="+WIDTH
                           + "&INFO_FORMAT=application/json"
                           + "&SRS=EPSG:4326"
                           + "&X="+X+"&Y="+Y
                           + "&EXCEPTIONS=application/vnd.ogc.se_xml"
         ;
         console.log("URL="+geosUrl+encodeURI(URL));

         $.ajax({
            url:	geosUrl+encodeURI(URL),
            async:	false,
            success:	function (data, status, xhr) {
//                         console.log("data: "+data);
//                         console.log ("typeof data: "+ typeof data);
//                         console.log("status: "+status);
                           console.log("xhr: "+xhr.status+" "+xhr.statusText);
                           var features = data.features;
                           if (features.length > 0) {
                              popupContent = createContentFromFeature(data.features[0]);
                           }
                           else
                              popupContent = null;
                              console.log("in ajax popupContent="+popupContent);
/*                            var jfeatures = xhr.responseJSON.features;
                                 if (jfeatures.length > 0) {
                                    alert("JSON="+xhr.responseText);
//                                  popupContent = createContentFromFeature(xhr.features[0]);
                                 }
                                 else
                                    popupContent = null; */
                        },
             error:	function (xhr, status, error) {
                           console.log("in error xhr: "+xhr.status+" "+xhr.statusText);
                        }
         });

         console.log("nach ajax popupContent="+popupContent);
         if (popupContent != null) {
            var popup = L.popup(popupOptions)
              .setLatLng(e.latlng)
              .setContent(popupContent)
              .openOn(map);
         }
      }

// ----------------------------------------------------------------------------------------

      function createContentFromFeature(feature) {
         var tags = feature.properties.tags;
         console.log("tags=",tags);
         var tagsObj = JSON.parse(tags);
         var content = "<p>Object: "+feature.properties.osm_link+"</p>";
             content  += "<p>Query: "+feature.properties.query+"</p>";

         content += "<table id='popup' border='1'>";
         content += "   <td>Key</td><td>Value</td>";
         $.each( tagsObj, function( key, value ) {
            if (value != null)
               switch(key) {
                  case "z_order":
                  case "way_area":
                  case "pointonsurface":
                  case "bbox":
                  case "mway":
                  case "jd":
                  case "query":
                  case "osm_user":
                     break;
                  default:
                     content += "   <tr><td>"+key+"</td><td>"+value+"</td></tr>";
                     break;
               }
         });
	     content += "</table>";
	     var osm_id = feature.properties.osm_id;
	     if (protocol=="http:") {
	        josm = "<a href='http://127.0.0.1:8111";
	     }
	     else {
	        josm = "<a href='https://127.0.0.1:8112";
         }
	   
         josm += "/load_object?new_layer=false&objects="+osm_id
               + "' target='hiddenIframe'>"+osm_id+"</a>";
         console.log(josm);
         content += "<br>Edit with josm:&nbsp;"+josm;
         

         return content; 
      }
// ----------------------------------------------------------------------------------------

      function createQueryFromLayers() {
         console.log("createQueryFromLayers()");
         var query = "";
         for (var i=0;i<=Overlays.length-1;i++) {
//          console.log("Overlays["+i+"].active=", Overlays[i].active);
            if (Overlays[i].active) {
               console.log("active layer:",Overlays[i].gsLayer);
               query = query + Overlays[i].gsLayer +","; 
            }
         }
         query = "&LAYERS="+query.substring(0,query.length-1)
               + "&QUERY_LAYERS="+query.substring(0,query.length-1);    // warum auch immer
         console.log("query=",query);
         return query;
      }  
   
// ----------------------------------------------------------------------------------------

      function getAction() {
         $.ajax({
                 type:      "POST",
                 timeout:   5000,
                 url:       "getAction5", 
                 data: {
                      caller:   myName,
                      base:     myBase,
                      debug:    1,
                      database: database
                 },
                 async:     false,
                 dataType:  "text",
                 success: function(action, status) { 
                    console.log("getAction -->",action,status);
                    var ac = action.split(":"); 
                    switch(ac[0]) {
                       case "reload":
                          console.log("getAction: got order to reload page");
                          console.log("pathname = "+window.location.pathname); // Returns path only
                          console.log("url      = "+window.location.href);     // Returns full URL
                          ReloadPage();
                          break;
                       case "unread":
                          if (! ignoreMyMails) {
                             console.log("start noty");
                             var n = noty({text:        "You got "+ac[1]+" unread mails in your "
                                                      +     "<a href='http://openstreetmap.org/user/"+ac[2]
                                                      +     "/inbox' target='_blank'>OSM-Mailbox</a> "
                                                      +         "Click link to open mailbox.",
                                           buttons: [
//                             /*            {addClass: 'btn btn-primary', 
//                                             text:        '   Read Mail', 
//                                             onClick:     function($noty) {
//                                                 $noty.close();
//                                                                 ignoreMyMails = true;
//                                          }
//                                    }, */
                                      {addClass:    'btn btn-primary', 
                                               text:        'Ignore in current session', 
                                               onClick:     function($noty) {
                                                               $noty.close();
                                                               ignoreMyMails = true;
                                                            }
                                      },
                                      {addClass:    'btn btn-danger',
                                               text:     'Close', 
                                            onClick:     function($noty) {
                                                            $noty.close();
                                                         }
                                       }
                                       ],
                                           layout:      "center",         
                                           type:        "success",
                                           theme:       "defaultTheme",
                                           timeout:     30000,
                                           killer:      true,
                                           dismissQueue:    false
                                          }
                                         );
                          }
                          break;
                       case "msg":
                          if (!ignoreMsg) {
                             var n = noty({text:        ac[1],
                                           buttons: [
                              {addClass:    'btn btn-primary',
                           text:        'Ignore in current session', 
                                               onClick:     function($noty) {
                                           $noty.close();
                                                                   ignoreMsg = true;
                                }
                          },
                                      {addClass:    'btn btn-primary', 
                                               text:        '   Close', 
                                               onClick:     function($noty) {
                                   $noty.close();
                                            }
                                      }
                                       ],
                                           layout:      "center",         
                                           type:        "success",
                                           theme:       "defaultTheme",
                                           timeout:         30000,
                                           killer:      true,
                                           dismissQueue:    false
                                       }
                                    );
                          }
                          break;
                    }
                 },
                 error: function(XMLHttpRequest, textStatus, errorThrown) {
                     console.log("getAction: An error has occurred making the request: " + errorThrown);
                 }   
               });
      }
      
// ----------------------------------------------------------------------------------------

      function ReloadPage() {
         console.log("ReloadPage(): loading="+loading);
         window.location.reload(true); // ohne cache
      } 
      
// ----------------------------------------------------------------------------------------

      function getOsmLanduseCount() {
         $.ajax({
                 type:      "POST",
                 timeout:   30000,
                 url:       "getOsmLanduseCount", 
                 data: {
                      caller:   myName,
                      base:     myBase,
                      debug:    1,
                      database: database
                 },
                 async:     true,
                 dataType:  "json",
                 success: function(action, status) { 
                             console.log(action, status);
                             $("#count").html("<p style='margin:0; text-align:center'>"
                                +"farm:&nbsp;"+addCommas(action.farm)
                                +"&nbsp;farmland:&nbsp;"+addCommas(action.farmland)
                                +"&nbsp;farmyard:&nbsp;"+addCommas(action.farmyard)
                                +"</p>");
                          },
                 error: function(XMLHttpRequest, textStatus, errorThrown) {
                     console.log("getAction: An error has occurred making the request: " + errorThrown);
                 }   
               });
      } 
      
// ---------------------------------------------------------------------------

      function addCommas(nStr) {
	     nStr += '';
	     x = nStr.split('.');
	     x1 = x[0];
	     x2 = x.length > 1 ? '.' + x[1] : '';
	     var rgx = /(\d+)(\d{3})/;
	     while (rgx.test(x1)) {
		    x1 = x1.replace(rgx, '$1' + ',' + '$2');
	     }
	     return x1 + x2;
      }
// **************************** display lag **********************************

      var vlag;

      function LagAnzeigen() {
         var absSekunden = Math.round(vlag);
         var relSekunden = absSekunden % 60;
         var absMinuten = Math.abs(Math.round((absSekunden - 30) / 60));
         var absStunden = Math.abs(Math.round((absMinuten - 30) / 60));
             absMinuten = absMinuten - absStunden*60;
         var anzSekunden = "" + ((relSekunden > 9) ? relSekunden : "0" + relSekunden);
         var anzMinuten = "" + ((absMinuten > 9) ? absMinuten : "0" + absMinuten);
         var anzStunden = "" + ((absStunden > 9) ? absStunden : "0" + absStunden); 
         var lagText = "lag: "+ anzStunden + ":" + anzMinuten + ":" + anzSekunden;
//         innerHtml =  "<a href=\"ReplicationLag.png\">lag: "+ anzStunden + ":" + anzMinuten + ":" + anzSekunden+"</a>";
//         console.log("innerHtml=",innerHtml);
//         document.getElementById("lag_div").innerHTML = innerHtml;
//       box.show(lagText);
//       console.log("dialog lag:", $("#lag").html());
         $("#lag").html("<p style='margin:0; text-align:center'>"+lagText+"</p>");
         vlag = vlag + 1;
      }

// ----------------------------------------------------------------------------------------

      function getOsmReplicationLag() {
         vlag = -1;
//       console.log("getOsmReplicationLag: ",myName, database, "p3run", 2);
         $.ajax({
                 type:      "POST",
                 async:     false,
                 timeout:   5000,
                 url:       "getOsmReplicationLag3",
                 data: {
                      caller:   myName,
                      base:     myBase,
                      database: database,
                      diff:     "p3run",
                      debug:    0
                       },
                 dataType:  "text",
                 success:   function(text,status) {
//                             console.log(text,status);
                               vlag = parseInt(text);
                            },
                 error: function(XMLHttpRequest, textStatus, errorThrown) {
                     console.log("An error has occurred making the request: " + errorThrown);
                     oa = false;
                 }   
         });        
         LagAnzeigen();
      }

}
</script>

</head>

<body onLoad="javascript:init();">
   <div id="map"></div>
   <iframe style="display:none" id="hiddenIframe" name="hiddenIframe"></iframe>
</body>                                                                                                                          
</html>
