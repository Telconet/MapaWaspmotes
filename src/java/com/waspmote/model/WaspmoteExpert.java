/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package com.waspmote.model;

import java.sql.ResultSet;
import java.sql.Statement;
import java.util.HashMap;

/**
 *
 * @author Eduardo
 */
public class WaspmoteExpert {
    
    private String usuario = null;
    private String clave = null;
    
    private String BD = null;
    private String tabla = null;
    private String IP = null;
    private int puerto = 3306;
    private int tipo;
   
    
    public static final int WASPMOTE_CIUDAD = 1;
    public static final int NUMERO_MEDICIONES_WM_CIUDAD = 6;            //BAT, TEMP, HUM, NOISE, DUST, LIGHT...
    public static final int WASPMOTE_CAMARONERA = 2;
    public static final int NUMERO_MEDICIONES_WM_CAMARONERA = 4;        // BAT, PH, T, O2
    public static final int WASPMOTE_INUNDACIONES = 3;
    public static final int NUMERO_MEDICIONES_WM_INUNDACIONES = 2;      // BAT, UTRASOUND
    public static final int WASPMOTE_BOSQUES = 4;
    public static final int NUMERO_MEDICIONES_WM_BOSQUES = 4;      // BAT, TEMP, HUM, CO2
    
    public WaspmoteExpert(int tipo, String IP, String usuario, String clave, String BD, int puerto){
    
        this.tipo = tipo;
        switch(tipo){
            case WASPMOTE_BOSQUES:
                tabla = "tabla_bosques_actual";
                break;
            case WASPMOTE_CAMARONERA:
                tabla = "tabla_camaronera_actual";
                break;
            case WASPMOTE_CIUDAD:
                tabla = "sensor_ciudadDM_actual";
                break;
            case WASPMOTE_INUNDACIONES:
                tabla = "tabla_inundaciones_actual";
                break;
                    
        }
        
        this.usuario = usuario;
        this.clave = clave;
        this.BD = BD;
        this.puerto = puerto;
        this.IP = IP;
    }
    
    public HashMap<String, Waspmote> obtenerUltimasMediciones(){
        try{
        
            BaseDeDatos bd = new BaseDeDatos(BaseDeDatos.MYSQL_DB, "log_errores", IP , usuario, clave, puerto, "", BD);
            bd.conectar();
            
                     
            ResultSet conjunto = bd.LeerRegistros(tabla);
            
            HashMap<String, Waspmote> motas = new HashMap<String, Waspmote>();
            
            while(conjunto.next()){
               Waspmote wm = motas.get(conjunto.getString("id_wasp"));
               
               if(wm == null){
                   wm = new Waspmote(this.tipo, conjunto.getString("id_wasp"));
                   wm.agregarLatitud(Float.toString(conjunto.getFloat("latitud")));
                   wm.agregarLongitud(Float.toString(conjunto.getFloat("longitud")));
                   
                   if(tipo == WASPMOTE_CIUDAD){
                       //Ya tenemos el timestamp
                       wm.agregarTimestamp(conjunto.getString("timestamp"));
                   }
                   else{
                       //construimos el timestamp
                       String timestamp = conjunto.getString("fecha") + " " + conjunto.getString("hora");
                       wm.agregarTimestamp(timestamp);
                   }
                   
                   motas.put(conjunto.getString("id_wasp"), wm);
               }
               
               //Empezamos a llenar las mediciones
               if(tipo == WASPMOTE_CIUDAD){
                    wm.agregarMedicion(conjunto.getString("sensor"), Float.parseFloat(conjunto.getString("value")));
               }
               else if(tipo == WASPMOTE_BOSQUES){
                   wm.agregarMedicion("BAT", Float.parseFloat(conjunto.getString("bateria")));
                   wm.agregarMedicion("CO2", Float.parseFloat(conjunto.getString("CO2ppm")));
                   wm.agregarMedicion("TCA", Float.parseFloat(conjunto.getString("temperatura")));
                   wm.agregarMedicion("HUMA", Float.parseFloat(conjunto.getString("humedad")));
               }
               else if(tipo == WASPMOTE_INUNDACIONES){
                   wm.agregarMedicion("BAT", Float.parseFloat(conjunto.getString("bateria")));
                   wm.agregarMedicion("US", Float.parseFloat(conjunto.getString("nivel_agua")));
               }
               
              
                
            }
            
            //TODO: procesar...
            Statement state = conjunto.getStatement();
            state.close();
            conjunto.close();
            bd.cerrar();
            
            return motas;
        }
        catch(Exception e){
            
            String what = e.getMessage();
            e.printStackTrace();
            return null;
        }
    }
    
}
