/***************************************************************************************
*    Title:  youtube-api-samples
*    Author: YouTube API Group
*    Date: 2013
*    Availability: https://code.google.com/p/youtube-api-samples/source/browse/#git%2Fsamples%2Fjava
*
***************************************************************************************/
package com.classes;

import java.io.InputStreamReader;
import java.util.Iterator;
import java.util.List;

import com.google.api.client.googleapis.json.GoogleJsonResponseException;
import com.google.api.client.http.HttpRequest;
import com.google.api.client.http.HttpRequestInitializer;
import com.google.api.client.http.HttpTransport;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.JsonFactory;
import com.google.api.client.json.jackson2.JacksonFactory;
import com.google.api.services.youtube.YouTube;
import com.google.api.services.youtube.model.ResourceId;
import com.google.api.services.youtube.model.SearchListResponse;
import com.google.api.services.youtube.model.SearchResult;
import com.google.api.services.youtube.model.Thumbnail;
import com.google.api.services.youtube.model.Video;
import com.google.api.services.youtube.model.VideoListResponse;
import java.io.BufferedReader;
import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author WUT
 */
public class YouTubeAPI {

    /** Global instance Developer Key.  */
    /*
    * TODO: Replace key AJzbXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX with your key.  If you don't, you
    * will get a 400 service error (bad request).
    */
    //Google Maps Key: AIzaSyCiFrRjwG29nwVfYTDIdW6dCUwIVOMr_vs
    //YouTube Key: AIzaSyB2TeuT4cdjsc4yFoRN3K1uxq9a91WDjXo
    private static final String DEV_KEY = "AIzaSyDekw1kPIfIUat-B8VvHJPYrNOMzEpfLgs";

    /** Global instance of the HTTP transport. */
    private static final HttpTransport HTTP_TRANSPORT = new NetHttpTransport();

    /** Global instance of the JSON factory. */
    private static final JsonFactory JSON_FACTORY = new JacksonFactory();

    /** Global instance of the max number of videos we want returned (50 = upper limit per page). */
    private static final long NUMBER_OF_VIDEOS_RETURNED = 25;

    /** Global instance of Youtube object to make all API requests. */ 
    private static YouTube youtube;

    public static String search(String query) {
        try {
          youtube = new YouTube.Builder(HTTP_TRANSPORT, JSON_FACTORY, new HttpRequestInitializer() {
            public void initialize(HttpRequest request) throws IOException {}})
          .setApplicationName("youtube-cmdline-search-sample")
          .build();
          
          YouTube.Search.List search = youtube.search().list("id,snippet");
          search.setKey(DEV_KEY);
          search.setQ(query + " trailer");
          search.setType("video");
          search.setFields("items(id/kind,id/videoId,snippet/title,snippet/thumbnails/default/url)");
          search.setMaxResults(NUMBER_OF_VIDEOS_RETURNED);
          SearchListResponse searchResponse = search.execute();

          List<SearchResult> searchResultList = searchResponse.getItems();

          if(searchResultList != null) {
            return printSearchResult(searchResultList.iterator(), query);
          }
        } catch (GoogleJsonResponseException e) {
          System.err.println("There was a service error: " + e.getDetails().getCode() +
              " : " + e.getDetails().getMessage());
        } catch (IOException e) {
          System.err.println("There was an IO error: " + e.getCause() + " : " + e.getMessage());
        } catch (Throwable t) {
          t.printStackTrace();
        }
        return "";
    }
    
    private static String printSearchResult(Iterator<SearchResult> iteratorSearchResults, String query){
        String embedHtml = "";

        SearchResult singleVideo = iteratorSearchResults.next();
        ResourceId rId = singleVideo.getId();

        // Double checks the kind is video.
        if(rId.getKind().equals("youtube#video")) {
            try {   
                YouTube.Videos.List video = youtube.videos().list("snippet,contentDetails,player").setId(rId.getVideoId());
                video.setKey(DEV_KEY);
                VideoListResponse videoSearch = video.execute();
                List<Video> videoList = videoSearch.getItems();
                Video aVideo = videoList.get(0);
                embedHtml = aVideo.getPlayer().getEmbedHtml();
            } catch (IOException ex) {
                Logger.getLogger(YouTubeAPI.class.getName()).log(Level.SEVERE, null, ex);
            }
            return embedHtml;
        }
        return "";
    }
}
