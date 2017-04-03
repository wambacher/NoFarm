package com.wno;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.PreparedStatement;
import java.sql.Statement;
import java.sql.ResultSet;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;

import com.fasterxml.jackson.core.JsonEncoding;
import com.fasterxml.jackson.core.JsonFactory;
import com.fasterxml.jackson.core.JsonGenerationException;
import com.fasterxml.jackson.core.JsonGenerator;
import com.fasterxml.jackson.core.JsonParser;

/* Version 1 Abgeleitet von Todo.java
*/

public class getOsmLanduseCount extends HttpServlet {

   private String myName = "getOsmLanduseCount";
   private String myLog;
   
   private static <T> T coalesce(T ...items) {
      for(T i : items) if(i != null) return i;
      return null;
   }  

   public void doGet(HttpServletRequest request,
                     HttpServletResponse response)
      throws ServletException, IOException {
        
        int debug = Integer.parseInt(coalesce(request.getParameter("debug"),"2"));

        String caller = request.getParameter("caller");
        myLog = coalesce(request.getParameter("base"),"boundaries");  /* ?*/

        //is client behind something?
        String remoteAddr = coalesce(request.getHeader("X-FORWARDED-FOR"), request.getRemoteAddr());

//      InetAddress inetAddress = InetAddress.getByName(remoteAddr);

        String spaces = "                                     ";
        String myHeader = remoteAddr+spaces.substring(0,16-remoteAddr.length()) 
                        + caller + " " 
                        + myName+spaces.substring(0,30-myName.length());

        String callerVersion = caller.split("-")[1];
        String database = request.getParameter("database");

        int    rc  = 0;

        if (debug > 1) SimpleLog.write(myLog, myHeader+"referer="+request.getHeader("referer")); 
        if (debug > 1) SimpleLog.write(myLog, myHeader+"started: request=\""+request.getQueryString()+"\"");

        if (debug > 2) SimpleLog.write(myLog, myHeader+"callerVersion="+callerVersion);

      try {
         Class.forName("org.postgresql.Driver");
      } 
      catch (ClassNotFoundException cnfe) {
         SimpleLog.write(myName+" Couldn't find the driver!");
         cnfe.printStackTrace();
         System.exit(1);
      }
        
      Connection conn = null;
                   
      JsonFactory jsonfactory = new JsonFactory();
      StringWriter writer = new StringWriter();
      JsonGenerator jsonGenerator = jsonfactory.createJsonGenerator(writer);           
//    jsonGenerator.useDefaultPrettyPrinter();

      try {
         conn = DriverManager.getConnection("jdbc:postgresql://localhost:5432/" + database,"osm", "");

         Statement statement = conn.createStatement();

         String query = 
              "select landuse,count(*) from planet_osm_polygon"
            + " where landuse in ('farm','farmland','farmyard')"
            + " group by landuse"
            + " order by landuse;"; 
         
         if (debug > 1) SimpleLog.write(myLog,myHeader+query);
         ResultSet rs = statement.executeQuery(query);
         
    	 jsonGenerator.writeStartObject();

         while (rs.next()) {

            String landuse = rs.getString("landuse");
            int count   = rs.getInt("count");
            
            jsonGenerator.writeNumberField(landuse,count);
         }
         jsonGenerator.writeEndObject();
      } 
      catch (SQLException se) {
         SimpleLog.write(myLog,myHeader+se.getMessage());
      }
      finally {
         try {
            if (conn != null) {
               conn.close();
               if (debug > 1) SimpleLog.write(myLog,myHeader+"closing SQL-Connection");
            }
         }
         catch (SQLException e) {
            SimpleLog.write(myLog,myHeader+e.toString());
         }
      }   
                
      jsonGenerator.flush();
      jsonGenerator.close();
      
      String jsonString = writer.toString();
      if (debug > 0) SimpleLog.write("returning "+jsonString);
      
      response.setContentType("application/json");
      response.getWriter().write(jsonString);            
      rc = HttpServletResponse.SC_OK;
      if (debug > 0) SimpleLog.write(myLog,myHeader+jsonString);	           
      response.setStatus(rc);  
   } 
   
   public void doPost(HttpServletRequest request,
                       HttpServletResponse response)
    throws IOException, ServletException
       {
           // Übergabe an doGet(), falls Anforderung mittels POST
           doGet(request, response);
       }
}
