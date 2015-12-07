<%-- 
    Document   : index/result   
    Created on : Oct 26, 2015, 14:28:15 AM
    Author     : Eduardo Murillo
--%>
<%@page import="java.util.GregorianCalendar"%>
<%@page import="java.util.Calendar"%>
<%@page import="java.util.ArrayList"%>
<%@page import="com.waspmote.model.Waspmote"%>
<%@page import="java.util.HashMap"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Mapa Waspmote</title>      
        
        <style>
            html{
                height: 100%;

            }
            #map-canvas {
                width: 100%;
                height: 100%;
                background-color: #CCC;
                margin: 0px;              
            }
            
             body {
                background-color: #202020;
                margin: 0px;
                height: 84%;
            }
            
            #botones_div{
                background-color: #044681;
                margin: 0px;             
            }

            head {
                color: #202020;
            }
            
            #titulo{
                color: white;
                text-align: left;
                letter-spacing: 10px;
                font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;
                font-stretch: expanded;
                display: inline;      
                margin-left: 50px;
                -webkit-font-smoothing: antialiased;
                text-shadow: 1px 1px 1px rgba(0,0,0,0.004);
            }
            
            #somediv{
                margin-top: 25px;
                margin-bottom: 10px;
            }
            
            .botones_tipo{
                font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;
                height: 50px;
                font-size: 20px;
                background-color: #044681;
                color: white;
                alignment-baseline: central;
                width: 200px;
                border: none;
                cursor: pointer;
                 outline: 0;
                 margin: auto;
                 padding: 0px;      
                 border-top-left-radius: 10px;
                 border-top-right-radius: 10px;
            }
            
            .botones_med{
                font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;
                height: 30px;
                font-size: 10px;
                background-color: #5EBB00;
                
                color: white;
                alignment-baseline: central;
                width: 200px;
                cursor: pointer;
                font-weight: bold;
                 outline: 0;
                 border: none;
            }
            
            #camaronera_js{
                cursor: no-drop;
            }
            
            #actualizar{
                float: right;
            }
            
            #nombre_medicion{
                background-color: #5EBB00;
                border: none;
                margin: 0px;
            }
            
            #mensaje_actualizacion{

                color: white;
                text-align: right;
                margin: 0px;
                color: #9D9D9D;
                font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;
                margin-right: 10px;
                font-size: 13px;
                margin-bottom: 3px;
                font-style: italic;
            }
            
            #header_tipo {
                 color: #FF0B0B;
                 font-size: 20px;
                 display: inline-block;
                 text-align: right;
                 float: right;
                 margin: 10px;
                 padding-right: 10px;
                 overflow: hidden;
                 font-weight: bold;
                 font-style: oblique;
                 font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;
            }
        </style>
        
       
</style>
         <script src="https://maps.googleapis.com/maps/api/js?libraries=visualization&sensor=true"></script>
         
    </head>
    <body>
        
        
        <div id="somediv">
            <h1 id="titulo">Waspmotes</h1>
            <span id="header_tipo"></span>
        </div>
         <p id="mensaje_actualizacion">El mapa se actualiza cada minuto automáticamente. </p>
        <script src="http://code.jquery.com/jquery-latest.min.js"></script>
        
        
        <div id="botones_div" >
            <button class="botones_tipo" id="bosque_js" name="bosque_js" onclick='botones(this,"bosque")' onmouseover="cambiarBoton(this)" onmouseout="restaurarBoton(this)">Bosque</button><button class="botones_tipo" id="ciudad_js" name="ciudad_js" onclick='botones(this,"ciudad")' onmouseover="cambiarBoton(this)" onmouseout="restaurarBoton(this)">Ciudad</button><button class="botones_tipo" id="inundaciones_js" name="inundaciones_js" onclick='botones(this,"inundaciones")' onmouseover="cambiarBoton(this)" onmouseout="restaurarBoton(this)">Inundaciones</button><!--<button class="botones_tipo" id="camaronera_js" name="camaronera_js"  onmouseover="cambiarBoton(this)" onmouseout="restaurarBoton(this)">Camaronera</button>-->
            <button id="actualizar" class="botones_tipo" onmouseover="cambiarBoton(this)" onmouseout="restaurarBoton(this)">Actualizar</button>
        </div>
        <div id="nombre_medicion">
            <!--con javascript pondremos aquí los botones dinámicos...-->
        </div>
        <div id="map-canvas"></div>

        <script>
            
            //Variables... 
            var ventanaInformacion;
            var map;
            var markers = [];     //marcadores...
            var nivelZoom;

            //Objeto JS que contiene los datos de las motas.
            var Waspmotes = {timestamp: {}, medicion: {}, latitud: {}, longitud: {}, nombreMotas: []};
            
            var marker;     //el marcador actual
            var heatmap = null;    //el objeto actual.
            var testData = null;
            var parametrosActualizacion;
            
            //Estado actual
            var tipo_med;
            var sensor;
            var maximo;
            var minimo;
            var profundidad_seco;
            var unidades;
            var intervaloRefreshaPagina = 60000;    //60 segundos.
            
            //Sobre la pagina
            var botonAnteriorSeleccionado = null;
            
            function cambiarBoton(boton){
                if(boton.className == "botones_tipo"){
                    
                    if(botonAnteriorSeleccionado == null){
                        boton.style.backgroundColor = "#5EBB00";    
                    }
                    else if(botonAnteriorSeleccionado != boton.name){
                        //Una vez seleccionado algun boton, el highlight debe ser 
                        //más oscuro.
                        boton.style.backgroundColor = "#FFA200";  
                    }
                }
                else{
                    boton.style.backgroundColor = "#B80000"; 
                }
            }
            
            function restaurarBoton(boton){
                
               
                if(boton.className == "botones_tipo"){
                   //solo restauramos los botones no seleccionados.
                   if(botonAnteriorSeleccionado != boton.name){
                       boton.style.backgroundColor = "#044681";
                   }
                }
                else{
                    boton.style.backgroundColor = "#5EBB00"; 
                }
            }
            
            //Inicializar Mapa
            function initialize() {
                
              nivelZoom = 18;
              
              var mapCanvas = document.getElementById('map-canvas');
              var mapOptions = {
                center: new google.maps.LatLng(-2.153029, -79.953520),
                //center: new google.maps.LatLng(25.6586,-80.3568),
                zoom: nivelZoom,
                mapTypeId: google.maps.MapTypeId.ROADMAP,
                scaleControl: true
              }
              map = new google.maps.Map(mapCanvas, mapOptions)
              
              var styleArray = [
                {
                  featureType: "all",
                  stylers: [
                    { saturation: -80 }
                  ]
                },{
                  featureType: "road.arterial",
                  elementType: "geometry",
                  stylers: [
                    { hue: "#00ffee" },
                    { saturation: 50 }
                  ]
                },{
                  featureType: "poi.business",
                  elementType: "labels",
                  stylers: [
                    { visibility: "off" }
                  ]
                }
              ];             
              map.setOptions({styles: styleArray});
              
              <%  HashMap<String, Waspmote> motas = (HashMap<String, Waspmote>)request.getAttribute("motas"); 
                    
                    String nombreMedicion = (String)request.getAttribute("sensor");

                    ArrayList<Waspmote> motasAL = new ArrayList<Waspmote>(motas.values());
                    
                    String max = (String)request.getAttribute("maximo");
                    String min = (String)request.getAttribute("minimo");
                    
                    String tipo_med = (String)request.getAttribute("tipo_medicion");

                    for(int i = 0; i < motasAL.size(); i++){
                        Waspmote tmp = motasAL.get(i);
                 %>
                         
                //aqui guardamos la información de la medicion en JavaScript, para poder crear el tooltip
                <%= "Waspmotes.nombreMotas.push(\"" + tmp.obtenerIdWasp() + "\");" %>
                <%= "Waspmotes.timestamp[\"" + tmp.obtenerIdWasp() + "\"] = \"" + tmp.obtenerTimestamp() + "\";" %>            
                <%= "Waspmotes.medicion[\"" + tmp.obtenerIdWasp() + "\"] = parseFloat(\"" + tmp.obtenerMedicion(nombreMedicion) + "\");" %>
                <%= "Waspmotes.latitud[\"" + tmp.obtenerIdWasp() + "\"] = parseFloat(\"" + tmp.obtenerLatitud() + "\");" %>
                <%= "Waspmotes.longitud[\"" + tmp.obtenerIdWasp() + "\"] = parseFloat(\"" + tmp.obtenerLongitud() + "\");" %>
                    
                //Aqui cramos los markers...
                <%=  "var myLatLng = {lat: " + tmp.obtenerLatitud() + ", lng: " + tmp.obtenerLongitud() + " };" %>
                <%= "marker = new google.maps.Marker({ position: myLatLng, title:\"" + tmp.obtenerIdWasp() + "\"});"  %>
                <%= "marker.setAnimation(google.maps.Animation.DROP);" %>
               
                <%= "markers.push(marker);" %>
                   
                //Si no usamos with, tenemos el closure problem. Creamos nuevo scope.
                with({mark: marker}){
                    mark.addListener('click',  function(){

                           if(ventanaInformacion != null){
                               ventanaInformacion.close();  //cerramos la ventana abierta...
                           }
                          
                           var texto;
                           if(mark.getTitle() != "WM_CITY_1"){
                                texto = "<b>Nombre:</b> " + mark.getTitle() + "<br><b>Fecha/Hora</b>: " + Waspmotes.timestamp[mark.getTitle()] + 
                                        "<br><b>Medicion:</b> " + Waspmotes.medicion[mark.getTitle()]+ unidades;
                           }
                           else{
                               texto = "<b>Nombre:</b> " + mark.getTitle() + "<br><b>Fecha/Hora</b>: " + Waspmotes.timestamp[mark.getTitle()] + 
                                        "<br><b>Medicion:</b> " +Waspmotes.medicion[mark.getTitle()]+ unidades + "<br><b>NODO COORDINADOR DIGIMESH</b>";
                                        
                           }

                            //Creamos la ventana
                            ventanaInformacion = new google.maps.InfoWindow({
                                content: texto
                            });

                            //La mostramos...
                            ventanaInformacion.open(map, mark);
                       });
                }
                  
                  <%= "marker.setMap(map);" %>

                <% } %>
                    
                <%= "maximo = " + max + ";" %>
                <%= "minimo = " + min + ";" %>
                <%= "sensor = \"" + nombreMedicion + "\";" %>
                <%= "tipo_med = \"" + tipo_med + "\";" %>  
                <%= "unidades = \""  + (String)request.getAttribute("unidades") + "\";" %>
                <%= "profundidad_seco = "  + (String)request.getAttribute("profundidad_seco") + ";" %>
                    
                
                //Actualizamos el header para informar el tipo de medicion
                var tipo_wasmpote;
                if(tipo_med.indexOf("bosque") > -1){
                    //document.getElementById("header_tipo").innerHTML = "Bosque";
                    tipo_wasmpote = "Bosque";
                }
                else if(tipo_med.indexOf("ciudad") > -1){
                    //document.getElementById("header_tipo").innerHTML = "Ciudad";
                    tipo_wasmpote = "Ciudad";
                }
                else if(tipo_med.indexOf("camaronera") > -1){
                    //document.getElementById("header_tipo").innerHTML = "Camaronera";
                    tipo_wasmpote = "Camaronera";
                }
                else if(tipo_med.indexOf("inundaciones") > -1){
                    //document.getElementById("header_tipo").innerHTML = "Inundaciones";
                    tipo_wasmpote = "Inundaciones";
                }
                
                //ahora el tipo de medicion;
                var variable_medida;
                
                if(sensor == "TCA"){
                    variable_medida = ": Temperatura"
                }
                else if(sensor == "BAT"){
                    variable_medida = ": Batería";
                }
                 else if(sensor == "HUMA"){
                    variable_medida = ": Humedad";
                }
                 else if(sensor == "CO2"){
                    variable_medida = ": CO2";
                }
                 else if(sensor == "DUST"){
                    variable_medida = ": Partículas";
                }
                 else if(sensor == "US"){
                    variable_medida = ": Profundidad";
                }
                 else if(sensor == "LUM"){
                    variable_medida = ": Luminosidad";
                }
                 else if(sensor == "MCP"){
                    variable_medida = ": Ruido";
                }
                
                document.getElementById("header_tipo").innerHTML = tipo_wasmpote + variable_medida;
                
                    
                
                //Creamos el heatmap usando heatmap.js
                heatmap = new HeatmapOverlay(map, 
                {
                    // radius should be small ONLY if scaleRadius is true (or small radius is intended)
                    "radius": 0.0005,   //Medido en escala del mapa si scaleRadius = true, caso contrario se mide en pixeles.
                    "maxOpacity": 1, 
                    // scales the radius based on map zoom
                    "scaleRadius": true, 
                    // if set to false the heatmap uses the global maximum for colorization
                    // if activated: uses the data maximum within the current map boundaries 
                    //   (there will always be a red spot with useLocalExtremas true)
                    "useLocalExtremas": false,
                    // which field name in your data represents the latitude - default "lat"
                    latField: 'lat',
                    // which field name in your data represents the longitude - default "lng"
                    lngField: 'lng',
                    // which field name in your data represents the data value - default "value"
                    valueField: 'count'
                }
              );
              
              
              //Añadimos los datos.. Max es el maximo global de la medicon)
              testData={max: maximo, min: minimo, data:[]};
            
              //Llenamos los datos...
              //window.alert(testData.max);
              var i = 0; 
              for(i = 0; i < Waspmotes.nombreMotas.length; i++){
                  
                  var nombre = Waspmotes.nombreMotas[i];
                  if(tipo_med == "b_inundaciones_US"){
                      
                      var nivel_agua = profundidad_seco - Waspmotes.medicion[nombre];
                      
                      var obj = {lat: Waspmotes.latitud[nombre], lng: Waspmotes.longitud[nombre], count: nivel_agua};
                  }
                  else{
                      var obj = {lat: Waspmotes.latitud[nombre], lng: Waspmotes.longitud[nombre], count: Waspmotes.medicion[nombre]};
                  }
                  
                  if(Waspmotes.nombreMotas[i] !='WM_CITY_1'){
                    testData.data.push(obj);
                  }
              }
              
              heatmap.setData(testData);
              
              //con jQuery, hacemos que actualizar cree una solicitud GET para actualizar el mapa
              //Lo hacemo cada vez que cambiamos de tipo de medicion.
                   parametrosActualizacion = {
                    tipo_med: tipo_med,
                    actualizacion: "si",
                    sensor:sensor
                  };
                  
                //Creamos un listener onClick para el botón actualizar.  
                $(document).on("click", "#actualizar", function() { 
                    $.get("WaspmoteMap", parametrosActualizacion, function(responseText) {  
                        //$("#somediv").text(responseText);         // Locate HTML DOM element with ID "somediv" and set its text content with the response text.
                        var respuestaJSON = JSON.parse(responseText);             //Convertimos el string a un objeto JSON en

                        borrarMarkers();

                        //Borramos el mapa                    
                        //truco para borrar el mapa anterior... (creamos un punto con valor 0. si damos un 
                        //dato vacio, persiste el mapa en miniatura...
                        heatmap.setData({max: 0, data:[{lat: -2.993122, lng: -95.457636, count: 0}]});

                        //Vaciamos los arreglos 
                        Waspmotes.nombreMotas = [];
                        Waspmotes.timestamp = [];
                        Waspmotes.medicion = [];
                        Waspmotes.latitud = [];
                        Waspmotes.longitud = [];

                        //creamos nuevamente los markers y el mapa de calor...
                        crearMarkers(respuestaJSON);
                        crearMapaDeCalor();
                    });

                });
            }

            
            //Funcion que borrará los markers
            function borrarMarkers(){
                 //window.alert(markers.length);
               
                for (var i = 0; i < markers.length; i++) {
                    markers[i].setMap(null);
                }
                
                //TODO: borrar el heatmap
                markers = [];
            }
            

            //Funcion que crear los markers a partir de un objeto JSON.
            function crearMarkers(respuesta){
                var i = 0;
                for(i = 0; i < respuesta.length; i++){
                     var mota = respuesta[i];
                     
                     //Creamotes los markers...
                     Waspmotes.nombreMotas.push(mota.id_wasp);
                     
                     Waspmotes.timestamp[mota.id_wasp] = mota.timestamp;
                     Waspmotes.medicion[mota.id_wasp] = parseFloat(mota.medicion).toFixed(1);
                     Waspmotes.latitud[mota.id_wasp] = parseFloat(mota.latitud);
                     Waspmotes.longitud[mota.id_wasp] = parseFloat(mota.longitud);
                                    
                    //Aqui cramos los markers...
                    var myLatLng = {lat: Waspmotes.latitud[mota.id_wasp], lng: Waspmotes.longitud[mota.id_wasp] };
                    var mimarker = new google.maps.Marker({ position: myLatLng, title: mota.id_wasp});
                    mimarker.setAnimation(google.maps.Animation.DROP);
               
                    //Guardamos el maker en una lista, para poder borrarlo despues
                    markers.push(mimarker);

                    //Si no usamos with, tenemos el closure problem. Creamos nuevo scope.
                    with({mark: mimarker}){
                        mark.addListener('click',  function(){

                               if(ventanaInformacion != null){
                                   ventanaInformacion.close();  //cerramos la ventana abierta...
                               }
                               else{
                                  
                               }

                               var texto = "";
                               if(mark.getTitle() != "WM_CITY_1"){
                                   
                                    texto = "<b>Nombre:</b> " + mark.getTitle() + "<br><b>Fecha/Hora</b>: " + Waspmotes.timestamp[mark.getTitle()] + 
                                            "<br><b>Medicion:</b> " + Waspmotes.medicion[mark.getTitle()] + unidades ;
                               }
                               else{
                                   texto = "<b>Nombre:</b> " + mark.getTitle() + "<br><b>Fecha/Hora</b>: " + Waspmotes.timestamp[mark.getTitle()] + 
                                            "<br><b>Medicion:</b> " + Waspmotes.medicion[mark.getTitle()]+  unidades  + "<br><b>NODO COORDINADOR DIGIMESH</b>";

                               }

                                //Creamos la ventana
                                ventanaInformacion = new google.maps.InfoWindow({
                                    content: texto
                                });

                            //La mostramos...
                            ventanaInformacion.open(map, mark);
                       });
                    }
                  
                    mimarker.setMap(map);
                   
                }
            }
            
            //Funcion que crear el mapa de calor. Asume que tenemos una variable global heatmap 
            //Y la variable Waspmotes llena con los datos
            function crearMapaDeCalor(){
            
                //Creamos el heatmap usando heatmap.js si ses que no existe.
                if(heatmap == null){
                    heatmap = new HeatmapOverlay(map, 
                    {
                        // radius should be small ONLY if scaleRadius is true (or small radius is intended)
                        "radius": 0.0005,   //Medido en escala del mapa si scaleRadius = true, caso contrario se mide en pixeles.
                        "maxOpacity": 1, 
                        // scales the radius based on map zoom
                        "scaleRadius": true, 
                        // if set to false the heatmap uses the global maximum for colorization
                        // if activated: uses the data maximum within the current map boundaries 
                        //   (there will always be a red spot with useLocalExtremas true)
                        "useLocalExtremas": false,
                        // which field name in your data represents the latitude - default "lat"
                        latField: 'lat',
                        // which field name in your data represents the longitude - default "lng"
                        lngField: 'lng',
                        // which field name in your data represents the data value - default "value"
                        valueField: 'count'
                    }
                  );
                }

                //Añadimos los datos.. Max es el maximo global de la medicon)
                testData={max: maximo, min: minimo, data:[]};

                //Llenamos los datos...
                //window.alert(testData.max);
                var i = 0;
                for(i = 0; i < Waspmotes.nombreMotas.length; i++){

                    var nombre = Waspmotes.nombreMotas[i];
                    var obj = {lat: Waspmotes.latitud[nombre], lng: Waspmotes.longitud[nombre], count: Waspmotes.medicion[nombre]};
                    if(Waspmotes.nombreMotas[i] !='WM_CITY_1'){
                        testData.data.push(obj);
                    }
                }

                heatmap.setData(testData);   
            
            }
            
            function refrescarMapa(){
                //window.alert("refrescando mapa...");
                $.get("WaspmoteMap", parametrosActualizacion, function(responseText) {  
                        //$("#somediv").text(responseText);         // Locate HTML DOM element with ID "somediv" and set its text content with the response text.
                        var respuestaJSON = JSON.parse(responseText);             //Convertimos el string a un objeto JSON en

                        borrarMarkers();

                        //Borramos el mapa                    
                        //truco para borrar el mapa anterior... (creamos un punto con valor 0. si damos un 
                        //dato vacio, persiste el mapa en miniatura...
                        heatmap.setData({max: 0, min: 0, data:[{lat: -2.993122, lng: -95.457636, count: 0}]});

                        //Vaciamos los arreglos 
                        Waspmotes.nombreMotas = [];
                        Waspmotes.timestamp = [];
                        Waspmotes.medicion = [];
                        Waspmotes.latitud = [];
                        Waspmotes.longitud = [];

                        //creamos nuevamente los markers y el mapa de calor...
                        crearMarkers(respuestaJSON);
                        crearMapaDeCalor();
                    });
            }
            
            function startInterval() {
                setInterval("refrescarMapa();" ,intervaloRefreshaPagina);
            }

            function startTime() {
                var now = new Date();
                document.getElementById('titulo').innerHTML = now.getHours() + ":" + now.getMinutes() + ":" +now.getSeconds();
            }
            
            //Cargar Mapa
             google.maps.event.addDomListener(window, 'load', initialize);
             window.onload = startInterval;

            
         </script>
         
        
        <script type="text/javascript" src="heatmap.js-2.0/build/heatmap.js"></script>
        <script type="text/javascript" src="heatmap.js-2.0/plugins/gmaps-heatmap.js"></script>
        
        <script>
            //Seleccionamos  el tipo de equipo
            function botones(boton, tipo_waspmote) {
                
                document.getElementById(boton.name).style.backgroundColor = "#5EBB00"; //5EBB00 044681
                
                if(botonAnteriorSeleccionado != null){
                    document.getElementById(botonAnteriorSeleccionado).style.backgroundColor = "#044681";
                    //cambiarBoton(boton);
                }
              
                botonAnteriorSeleccionado = boton.name;
                 
                              
                //Removemos los botones viejos
                var nodo = document.getElementById("nombre_medicion");
                var botones = [];
                
                //Borramos los botones anteriores si existen...
                if(nodo.hasChildNodes()){
                    while (nodo.firstChild) {
                        nodo.removeChild(nodo.firstChild);
                    }
                }
                
                //Estilo
                var style = document.createElement('style');
                style.type = 'text/css';
                style.innerHTML = '.botones_med { color: #F00; }';
                
                if(tipo_waspmote == "ciudad"){
                    
                    //Agregamos los nuevos botones (bate, Temp, hum, ruido, luz, polvo)
                    var bat_btn = document.createElement("BUTTON");
                    var temp_btn = document.createElement("BUTTON");
                    var hum_btn = document.createElement("BUTTON");
                    var ruido_btn = document.createElement("BUTTON");
                    var luz_btn = document.createElement("BUTTON");
                    var polvo_btn = document.createElement("BUTTON");
                    
                    
                    
                    bat_btn.appendChild(document.createTextNode("Batería"));
                    bat_btn.setAttribute("value", "b_ciudad_BAT");
                    bat_btn.setAttribute("form", "form1");
                    bat_btn.setAttribute("method", "get");
                    bat_btn.setAttribute("name", "tipo_med");   
                    bat_btn.setAttribute("class", "boton_med");  
                    botones.push(bat_btn);
                    
                   
                    temp_btn.appendChild(document.createTextNode("Temperatura"));
                    temp_btn.setAttribute("value", "b_ciudad_TCA");
                    temp_btn.setAttribute("form", "form1");
                    temp_btn.setAttribute("method", "get");
                    temp_btn.setAttribute("name", "tipo_med");
                    temp_btn.setAttribute("class", "boton_med");  
                    botones.push(temp_btn);
                    
                    hum_btn.appendChild(document.createTextNode("Humedad"));
                    hum_btn.setAttribute("value", "b_ciudad_HUMA");
                    hum_btn.setAttribute("form", "form1");
                    hum_btn.setAttribute("method", "get");
                    hum_btn.setAttribute("name", "tipo_med");
                    hum_btn.setAttribute("class", "boton_med"); 
                    botones.push(hum_btn);
                    
                    ruido_btn.appendChild(document.createTextNode("Ruido"));
                    ruido_btn.setAttribute("value", "b_ciudad_MCP");
                    ruido_btn.setAttribute("form", "form1");
                    ruido_btn.setAttribute("method", "get");
                    ruido_btn.setAttribute("name", "tipo_med");
                    ruido_btn.setAttribute("class", "boton_med");  
                    botones.push(ruido_btn);
                    
                    luz_btn.appendChild(document.createTextNode("Luminosidad"));
                    luz_btn.setAttribute("value", "b_ciudad_LUM");
                    luz_btn.setAttribute("form", "form1");
                    luz_btn.setAttribute("method", "get");
                    luz_btn.setAttribute("name", "tipo_med");
                    luz_btn.setAttribute("class", "boton_med");
                     botones.push(luz_btn);
                    
                    polvo_btn.appendChild(document.createTextNode("Partículas"));
                    polvo_btn.setAttribute("value", "b_ciudad_DUST");
                    polvo_btn.setAttribute("form", "form1");
                    polvo_btn.setAttribute("method", "get");
                    polvo_btn.setAttribute("name", "tipo_med");
                    polvo_btn.setAttribute("class", "boton_med");   
                     botones.push(polvo_btn);
                    
                    var form1 = document.createElement("form");
                    form1.setAttribute("action", "WaspmoteMap");
                    form1.setAttribute("method", "get");
                    form1.setAttribute("id", "form1");

                    form1.appendChild(bat_btn);
                    form1.appendChild(temp_btn);
                    form1.appendChild(hum_btn);
                    form1.appendChild(ruido_btn);
                    form1.appendChild(luz_btn);
                    form1.appendChild(polvo_btn);
                    
                    var grupo_botones = document.getElementById("nombre_medicion");
                    
                    grupo_botones.appendChild(form1);
                    
                    
                    
                }
                else if(tipo_waspmote == "bosque"){
                    
                    var bat_btn = document.createElement("BUTTON");
                    var temp_btn = document.createElement("BUTTON");
                    var hum_btn = document.createElement("BUTTON");
                    var CO2_btn = document.createElement("BUTTON");
                    
                    //bat_btn.setAttribute("style", "display:inline-block");
                    
                    bat_btn.appendChild(document.createTextNode("Batería"));
                    bat_btn.setAttribute("value", "b_bosque_BAT");
                    bat_btn.setAttribute("form", "form1");
                    bat_btn.setAttribute("method", "get");
                    bat_btn.setAttribute("name", "tipo_med");
                    bat_btn.setAttribute("class", "boton_med");
                     botones.push(bat_btn);
                   
                    temp_btn.appendChild(document.createTextNode("Temperatura"));
                    temp_btn.setAttribute("value", "b_bosque_TCA");
                    temp_btn.setAttribute("form", "form1");
                    temp_btn.setAttribute("method", "get");
                    temp_btn.setAttribute("name", "tipo_med");
                    temp_btn.setAttribute("class", "boton_med"); 
                     botones.push(temp_btn);
                    
                    hum_btn.appendChild(document.createTextNode("Humedad"));
                    hum_btn.setAttribute("value", "b_bosque_HUMA");
                    hum_btn.setAttribute("form", "form1");
                    hum_btn.setAttribute("method", "get");
                    hum_btn.setAttribute("name", "tipo_med");
                    hum_btn.setAttribute("class", "boton_med"); 
                     botones.push(hum_btn);
                    
                    CO2_btn.appendChild(document.createTextNode("CO2"));
                    CO2_btn.setAttribute("value", "b_bosque_CO2");
                    CO2_btn.setAttribute("form", "form1");
                    CO2_btn.setAttribute("method", "get");
                    CO2_btn.setAttribute("name", "tipo_med");
                    CO2_btn.setAttribute("class", "boton_med");  
                     botones.push(CO2_btn);
                    
                    var form1 = document.createElement("form");
                    form1.setAttribute("action", "WaspmoteMap");
                    form1.setAttribute("method", "get");
                    form1.setAttribute("id", "form1");

                    form1.appendChild(bat_btn);
                    form1.appendChild(temp_btn);
                    form1.appendChild(hum_btn);
                    form1.appendChild(CO2_btn);
                    
                    var grupo_botones = document.getElementById("nombre_medicion");
                    
                    grupo_botones.appendChild(form1);
                    
                }
                else if(tipo_waspmote == "inundaciones"){
                    
                    var bat_btn = document.createElement("BUTTON");
                    var temp_prof = document.createElement("BUTTON");
                    
                    //bat_btn.setAttribute("style", "display:inline-block");
                    
                    bat_btn.appendChild(document.createTextNode("Batería"));
                    bat_btn.setAttribute("value", "b_inundaciones_BAT");
                    bat_btn.setAttribute("form", "form1");
                    bat_btn.setAttribute("method", "get");
                    bat_btn.setAttribute("name", "tipo_med");
                    bat_btn.setAttribute("class", "boton_med"); 
                     botones.push(bat_btn);
                   
                    temp_prof.appendChild(document.createTextNode("Profundidad"));
                    temp_prof.setAttribute("value", "b_inundaciones_US");
                    temp_prof.setAttribute("form", "form1");
                    temp_prof.setAttribute("method", "get");
                    temp_prof.setAttribute("name", "tipo_med");
                    temp_prof.setAttribute("class", "boton_med");
                    botones.push(temp_prof);
                    
                    var form1 = document.createElement("form");
                    form1.setAttribute("action", "WaspmoteMap");
                    form1.setAttribute("method", "get");
                    form1.setAttribute("id", "form1");
                        //Nivel agua
                    form1.appendChild(bat_btn);
                    form1.appendChild(temp_prof);
                    
                    var grupo_botones = document.getElementById("nombre_medicion");
                    
                    grupo_botones.appendChild(form1);
                    
                }
                else if(tipo_waspmote == "camaronera"){
                    
                    var bat_btn = document.createElement("BUTTON");
                    var temp_btn = document.createElement("BUTTON");
                    var ph_btn = document.createElement("BUTTON");
                    var oxi_btn = document.createElement("BUTTON");
                    
                    //bat_btn.setAttribute("style", "display:inline-block");
                    
                    bat_btn.appendChild(document.createTextNode("Batería"));
                    bat_btn.setAttribute("value", "b_camaronera_BAT");
                    bat_btn.setAttribute("form", "form1");
                    bat_btn.setAttribute("method", "get");
                    bat_btn.setAttribute("name", "tipo_med");
                    bat_btn.setAttribute("class", "boton_med");
                     botones.push(bat_btn);
                   
                    temp_btn.appendChild(document.createTextNode("Temperatura"));
                    temp_btn.setAttribute("value", "b_camaronera_TCA");
                    temp_btn.setAttribute("form", "form1");
                    temp_btn.setAttribute("method", "get");
                    temp_btn.setAttribute("name", "tipo_med");
                    temp_btn.setAttribute("class", "boton_med");
                     botones.push(temp_btn);
                    
                    ph_btn.appendChild(document.createTextNode("Acidez (pH)"));
                    ph_btn.setAttribute("value", "b_camaronera_PH");
                    ph_btn.setAttribute("form", "form1");
                    ph_btn.setAttribute("method", "get");
                    ph_btn.setAttribute("name", "tipo_med");
                    ph_btn.setAttribute("class", "boton_med"); 
                     botones.push(ph_btn);
                    
                    oxi_btn.appendChild(document.createTextNode("Oxígeno Disuelto"));
                    oxi_btn.setAttribute("value", "b_camaronera_DO");
                    oxi_btn.setAttribute("form", "form1");
                    oxi_btn.setAttribute("method", "get");
                    oxi_btn.setAttribute("name", "tipo_med");
                    oxi_btn.setAttribute("class", "boton_med"); 
                     botones.push(oxi_btn);
                    
                    var form1 = document.createElement("form");
                    form1.setAttribute("action", "WaspmoteMap");
                    form1.setAttribute("method", "get");
                    form1.setAttribute("id", "form1");

                    form1.appendChild(bat_btn);
                    form1.appendChild(temp_btn);
                    form1.appendChild(ph_btn);
                    form1.appendChild(oxi_btn);
                    
                    var grupo_botones = document.getElementById("nombre_medicion");
                    
                    grupo_botones.appendChild(form1);
                }
                
                var i = 0;
                
                for(i = 0; i < botones.length; i++){
                    var boton = botones[i];
                    boton.style.backgroundColor = "#5EBB00";
                    boton.style.height = "30px";
                    boton.style.fontFamily = "Helvetica Neue, Helvetica, Arial, sans-serif";
                    boton.style.color = "white";
                    boton.style.alignmentBaseline = "central";
                    boton.style.border = "none";
                    boton.style.width = "200px";
                    boton.style.cursor = "pointer";
                    boton.style.margin = "0px"; 
                    boton.style.outline = "0";
                    
                    //Evento para seleccionar el boton
                    $(document).on('mouseover', '.boton_med', function(evento) {
                        
                        //window.alert(evento.classname)
                        cambiarBoton(evento.target);
                    });
                    
                    //Evento cuando salimos del boton
                    $(document).on('mouseout', '.boton_med', function(evento) {
                        
                        //window.alert(evento.classname)
                        restaurarBoton(evento.target);
                    });
                }
                
                
                /*font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;
                height: 30px;
                font-size: 10px;
                background-color: #5EBB00;
                
                color: white;
                alignment-baseline: central;
                width: 200px;
                border: none;
                cursor: pointer;
                font-weight: bold;*/
            }
        </script>
    </body>
</html>
