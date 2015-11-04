/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package com.waspmote.web;


import com.waspmote.model.Waspmote;
import com.waspmote.model.WaspmoteExpert;
import java.io.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.StringTokenizer;
import java.util.Vector;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.json.JSONArray;
import org.json.JSONObject;

public class WaspmoteMap extends HttpServlet{

    @Override
    public void doGet(HttpServletRequest request,
                       HttpServletResponse response) throws IOException, ServletException
    {
       
        
        //String tipo = request.getAttribute(tipo)
       // 

        //Verificamos que boton fue aplastado...
        int tipoMapa;
        //request.geta
        
        //HashMap<String, String[]> test = (HashMap<String, String[]>) request.getParameterMap(); 
        //
        String tipo_med = null;
        tipo_med = request.getParameter("tipo_med");
        String sensor = null;
        String esActualizacion = request.getParameter("actualizacion");
        
        
        if(esActualizacion == null){
            esActualizacion = "no";
        }

        if(tipo_med != null){
            if(tipo_med.contains("bosque")){
                tipoMapa = WaspmoteExpert.WASPMOTE_BOSQUES;

            }
            else if(tipo_med.contains("ciudad")){
                tipoMapa = WaspmoteExpert.WASPMOTE_CIUDAD;
            }
            else if(tipo_med.contains("inundaciones")){
                tipoMapa = WaspmoteExpert.WASPMOTE_INUNDACIONES;
            }
            else if(tipo_med.contains("camaronera")){
                tipoMapa = WaspmoteExpert.WASPMOTE_CAMARONERA;
            }
            else{
                 tipoMapa = WaspmoteExpert.WASPMOTE_CIUDAD;
            }
            
            if(esActualizacion.contains("no")){
                sensor = tipo_med.substring(tipo_med.lastIndexOf('_') + 1).trim();
            }
            else{
                sensor = request.getParameter("sensor");
            }
        }
        else{
            tipoMapa = WaspmoteExpert.WASPMOTE_CIUDAD;
            sensor = "TCA";
            tipo_med = "ciudad";        //por defecto...
        }
        
        ServletConfig config = getServletConfig();
        
        //String puerto = config.getInitParameter("usuario");
        WaspmoteExpert we = new WaspmoteExpert(tipoMapa, config.getInitParameter("IP"), config.getInitParameter("usuario"), config.getInitParameter("clave"), 
                                                config.getInitParameter("BD"), Integer.parseInt(config.getInitParameter("puerto")) );

        HashMap<String, Waspmote> motas = we.obtenerUltimasMediciones();

         //mandamos los datos de las motas al JSP, para visualización
        String maximoStr = "Max" + sensor;
        
        String maximo = config.getInitParameter(maximoStr);
                
        if(esActualizacion.contains("no")){
            request.setAttribute("motas", motas);  
        }
        request.setAttribute("sensor", sensor);
        request.setAttribute("maximo", maximo);             //mandamos el valor máximo.
        request.setAttribute("tipo_medicion", tipo_med);             //mandamos el valor máximo.
        request.setAttribute("profundidad_seco",  config.getInitParameter("profundidad_seco")); 
       
        
        
        String unidades = config.getInitParameter("unidades" + sensor);
        
        if(unidades.contains("dB") || unidades.contains("mg") || unidades.contains("ppm") || unidades.contains("cm")){
            unidades = " " + unidades;
        }
        
        request.setAttribute("unidades",unidades);
   
        if(esActualizacion.equals("no")){
            RequestDispatcher vista = request.getRequestDispatcher("result.jsp");
            vista.forward(request, response);
        }
        else{
            //Mandamos... solo la info...
           JSONArray datos = new JSONArray();
           
           ArrayList<Waspmote> listaMotas = new ArrayList<Waspmote>(motas.values());
           
           //Creamos el objeto JSON, y ponemos los datos de la mota.
           JSONObject objeto;
           for(int i = 0; i < listaMotas.size(); i++){
               objeto = new JSONObject();
               Waspmote miMota = listaMotas.get(i);
          
               objeto.put("id_wasp", miMota.obtenerIdWasp());
               objeto.put("latitud", miMota.obtenerLatitud());
               objeto.put("longitud", miMota.obtenerLongitud());
               objeto.put("medicion", miMota.obtenerMedicion(sensor));
                   objeto.put("timestamp", miMota.obtenerTimestamp());
               
               datos.put(objeto);
           }
           
           
           

                   
            
            //Serializamos el arreglo de datos
            final String salida = datos.toString();
            response.setContentLength(salida.length());
            //And write the string to output.
            response.getOutputStream().write(salida.getBytes());
            response.getOutputStream().flush();
            response.getOutputStream().close();
        }
    }
}