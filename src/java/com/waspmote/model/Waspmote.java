/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package com.waspmote.model;

import java.util.HashMap;

/**
 *
 * @author Eduardo
 */
public class Waspmote {
    
    private int tipo;
    private String id_wasp;
    private String timestamp;
    private HashMap<String, Float> mediciones;
    private String latitud, longitud;
    
    public Waspmote(int tipo, String id){
        this.tipo = tipo;
        this.id_wasp = id;
        this.timestamp = null;
        this.mediciones = new HashMap<String, Float>();
        this.latitud = "";
        this.longitud = "";
    }
    
    public void agregarMedicion(String nombre, Float valor){
        mediciones.put(nombre, valor);
    }
    
    public void agregarLatitud(String latitud){
        this.latitud = latitud;
    }
    
    public void agregarLongitud(String longitud){
        this.longitud = longitud;
    }
    
    public void agregarTimestamp(String timestamp){
        this.timestamp = timestamp;
    }
    
    public float obtenerMedicion(String nombre){
        return ((Float)mediciones.get(nombre)).floatValue();
    }
    
    public String obtenerLatitud(){
        return latitud;
    }
    
    public String obtenerLongitud(){
        return longitud;
    }
    
    public String obtenerIdWasp(){
        return this.id_wasp;
    }
    
    public String obtenerTimestamp(){
        return this.timestamp;
    }
    
    
}
