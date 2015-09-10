/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.classes;

import java.io.IOException;
import org.netbeans.saas.RestConnection;
import org.netbeans.saas.RestResponse;

/**
 *
 * @author Rizky
 */
public class Google {
    
    public String search(String query) throws IOException{
        String API_key = "AIzaSyDekw1kPIfIUat-B8VvHJPYrNOMzEpfLgs";
        String SEARCH_ID_cx = "001852067511937045191:0p4ldaivgno";
        
        query = query.replaceAll(" ", "%20");
        
        String[][] pathParams = new String[][]{};
        String[][] queryParams = new String[][]{};

        RestConnection conn = new
        RestConnection("https://www.googleapis.com/customsearch/v1?key="+API_key+"&cx="+ SEARCH_ID_cx + "&q="+ query + "&num=1", pathParams, queryParams);
        RestResponse response = conn.get();
        return response.getDataAsString(); 
    }
}
