/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.classes;

import java.net.URLEncoder;
import java.util.logging.Level;
import java.util.logging.Logger;
import oauth.signpost.OAuthConsumer;
import oauth.signpost.basic.DefaultOAuthConsumer;
import org.netbeans.saas.RestConnection;
import org.netbeans.saas.RestResponse;

/**
 *
 * @author Rizky
 */
public class Twitter {
    
    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) throws Exception {
        Twitter t = new Twitter();
        String result = t.searchTwitter("cinderella");
        System.out.println(result);
    }
    
    public String searchTwitter(String query) throws Exception{
        OAuthConsumer consumer = new DefaultOAuthConsumer("T5y2Pu0tfsYv7pRiT7I0uoDLo", "tigmrtlN4iDPGYHspCFXJikJySR8f3UGHIyzK8o0ym6ZocJGso");
        consumer.setTokenWithSecret("2773134834-AgDtjzVt2KdFkXEUpCG5vELKNhh6KqQXacVleiA", "oUsTgyqrCRDzAX2uOlUzsR4krvO5CDjFHaykBy5QMMBcb");
        
        query = "#" + query.replaceAll(" ", "");
        
        String url="https://api.twitter.com/1.1/search/tweets.json?q=" + URLEncoder.encode(query, "UTF-8") + "&result_type=mixed&lang=en";
        String[][] pathParams = new String[][]{};
        String[][] queryParams = new String[][]{};
        
        RestConnection conn = new RestConnection(consumer.sign(url), pathParams, queryParams);
        RestResponse response = conn.get();
        
        return response.getDataAsString(); 
        
    }
    
}
