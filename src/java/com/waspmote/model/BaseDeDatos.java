/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package com.waspmote.model;

import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.logging.FileHandler;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author Eduardo Murillo
 */
public class BaseDeDatos {
    
    public static final int MYSQL_DB = 1;
    public static final int ORACLE_DB = 2;
    public static final int POSTGRE_DB = 3;
    
    private String usuario;
    private String clave;
    private int puertoBD;
    private String IPServidor;
    private int tipoBD;
    private Connection conexion;
    private String sid;
    private String baseDeDatos;
    
    
    public BaseDeDatos(int tipoBD, String rutaErrores, String IP, String usuario, String clave, int puerto, String sid, String BD){
        this.tipoBD = tipoBD;
        this.usuario = usuario;
        this.clave = clave;
        this.IPServidor = IP;
        this.puertoBD = puerto;
        this.sid = sid;
        this.baseDeDatos = BD;
    }
    
    //conectar a la base de datos
    public synchronized int conectar(){
        try{
            StringBuilder url;
            
            switch(this.tipoBD){
                case BaseDeDatos.MYSQL_DB:
                    url = new StringBuilder("jdbc:mysql://");
                    Class.forName("com.mysql.jdbc.Driver").newInstance();
                    url.append(this.IPServidor);
                    url.append(":");
                    url.append(puertoBD);
                    url.append("/");
                    url.append(this.baseDeDatos);
                    break;
                case BaseDeDatos.ORACLE_DB:
                    url = new StringBuilder("jdbc:oracle:thin:@");
                    Class.forName("oracle.jdbc.driver.OracleDriver").newInstance();
                    url.append(IPServidor);
                    url.append(":");
                    url.append(puertoBD);
                    url.append(":");
                    url.append(this.sid);
                    break;
                case BaseDeDatos.POSTGRE_DB:
                    url = new StringBuilder("jdbc:postgresql://");
                    Class.forName("org.postgresql.Driver").newInstance();
                    url.append(this.IPServidor);
                    url.append("/");
                    url.append(baseDeDatos);
                    break;
                default:
                    //TODO escribir a log de errores.
                    return -1;
            }
                  
            //Añadimos el host y la base de datos
            

            //Creamos la conexion
            this.conexion = DriverManager.getConnection(url.toString(), usuario, clave);
            
            //
            if(this.conexion != null){
                return 0;
            }
            else return -1;

        }
        catch(SQLException e){
            try{
                String msg = e.getMessage();
                FileHandler handler = new FileHandler("log_db.log", true);
                Logger log = Logger.getLogger(Class.class.getName());
                log.addHandler(handler);
                log.log(Level.WARNING, e.getMessage(), e);
                return -1;
            }
            catch(Exception w){
                return -1;
            }
        }
        catch(Exception e){
            try{
                FileHandler handler = new FileHandler("log_db.log", true);
                Logger log = Logger.getLogger(Class.class.getName());
                log.addHandler(handler);
                log.log(Level.WARNING, e.getMessage(), e);
                return -1;
            }
            catch(Exception w){
                return -1;
            }
        }
    }
    
    //Cierra la conexion a la base de datos
    public synchronized void cerrar(){
        try{
            if(this.conexion != null){
                this.conexion.close();
            }
        }
        catch(Exception e){
            try{
                FileHandler handler = new FileHandler("log_db.log", true);
                Logger log = Logger.getLogger(Class.class.getName());
                log.addHandler(handler);
                log.log(Level.WARNING, e.getMessage(), e);
                return;
            }
            catch(Exception w){
                return;
            }
        }
    }
    
    
    /**
     * Verifica si exite la tabla dada por el nombre
     */
    public synchronized boolean  existeTabla(String nombreTabla){
        try{
            
            if(this.conexion == null){
               this.conectar(); 
            }
            DatabaseMetaData dbm = this.conexion.getMetaData();
            ResultSet tablas = dbm.getTables(null, null, nombreTabla, null);

            if(tablas.next()){
                
                if(tablas != null){   //--CHECK
                    tablas.close();
                }
                return true;
            }
            else{
                if(tablas != null){   //--CHECK
                    tablas.close();
                }
                return false;
            }
        }
        catch(Exception e){
            try{
                FileHandler handler = new FileHandler("log_db.log", true);
                Logger log = Logger.getLogger(Class.class.getName());
                log.addHandler(handler);
                log.log(Level.WARNING, e.getMessage(), e);
                return false;
            }
            catch(Exception w){
                return false;
            }
        }
    }
    
    
    public synchronized ResultSet LeerRegistros(String nombreTabla){
        
            try{
            
            String consultaInsercion = "SELECT * FROM " + nombreTabla + " A inner join info_waspmotes B on B.id_wasp = A.id_wasp";
            
            //TODO: Estructura de BD de bosques e inundaciones es distinta
            
           

            //Ejecutamos la consulta de almacenamiento
            if(this.conexion == null){
                this.conectar();
            }
            
            Statement consultaStatement = conexion.createStatement(); 
            ResultSet resultados = consultaStatement.executeQuery(consultaInsercion);

            //Usuario cierra statement y resultset

            return resultados;

        }
        catch(Exception e){
            try{
                String msg = e.getMessage();
                FileHandler handler = new FileHandler("log_db.log", true);
                Logger log = Logger.getLogger(Class.class.getName());
                log.addHandler(handler);
                log.log(Level.WARNING, e.getMessage(), e);
                return null;
            }
            catch(Exception w){
                return null;
            }
        }
    }
}
