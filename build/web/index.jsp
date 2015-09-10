
<%@page import="java.util.Arrays"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Date"%>
<%@page import="org.codehaus.jettison.json.JSONArray"%>
<%@page import="org.codehaus.jettison.json.JSONObject"%>
<%@page import="com.classes.*"%>
<%@page import="javax.ws.rs.ClientErrorException"%>
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->
    <meta name="description" content="">
    <meta name="author" content="">

    <title>Family Movie Recommender</title>

    <!-- Bootstrap core CSS -->
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.4/css/bootstrap.min.css">
    
    <link href="bootstrap-star-rating/star-rating.min.css" media="all" rel="stylesheet" type="text/css" />
    <script src="//ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"></script>
    <script src="bootstrap-star-rating/star-rating.min.js" type="text/javascript"></script>

    <!-- Custom styles for this template -->
    <link href="css/jumbotron-narrow.css" rel="stylesheet">

    <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
    <!--[if lt IE 9]>
      <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
      <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->
  </head>

  <body>

    <div class="container">
      <div class="header clearfix">
        <nav>
          <ul class="nav nav-pills pull-right">
            <li role="presentation" class="active"><a href="#">Home</a></li>
            <li role="presentation"><a href="http://eamca.com" target="_blank">Contact</a></li>
          </ul>
        </nav>
        <h3 class="text-muted">Family Movie Recommender</h3>
      </div>

      <div class="jumbotron">
        <div class="row">
          <div class="col-lg-12">
            <form action="" method="get">
              <div class="input-group input-group-lg">
                <input type="text" name="query" class="form-control" placeholder="Input movie title" value="<%=(request.getParameter("query")!=null?request.getParameter("query"):"") %>">
                <span class="input-group-btn">
                  <button class="btn btn-info" type="submit">Search</button>
                </span>  
              </div><!-- /input-group -->
            </form>
          </div><!-- /.col-lg-6 -->
        </div><!-- /.row -->
      </div>
      <%
      if(request.getParameter("query") != null){
        String query = request.getParameter("query");
        Google google = new Google();
        String json = google.search(query);
        JSONObject result = new JSONObject(json);
        JSONArray items = result.getJSONArray("items");
        JSONObject item = items.getJSONObject(0);
        String link = item.getString("link");
        
        JSONObject pagemap = item.getJSONObject("pagemap");
        
        JSONArray movie = pagemap.getJSONArray("movie");
        item = movie.getJSONObject(0);
        String thumbnail = item.getString("image");
        String genre = item.getString("genre");
        String title = item.getString("name");
        String contentrating = item.getString("contentrating");
        String keywords = item.getString("keywords");
        String[] plots = keywords.split(" \\| ");
        plots[0] = plots[0].split(": ")[1];
        keywords = "";
        for(int i=0;i<plots.length-1;i++){
            keywords += plots[i];
            if(i<plots.length-2){
                keywords += " | ";
            }
        }
        
        JSONArray metatags = pagemap.getJSONArray("metatags");
        item = metatags.getJSONObject(0);
        String description = item.getString("og:description");
        
        JSONArray moviereview = pagemap.getJSONArray("moviereview");
        item = moviereview.getJSONObject(0);
        String director = item.getString("directed_by");
        String stars = item.getString("starring");
        String release_date = item.getString("release_date");
        
        // query title to movieDB
        boolean reviewAvailable = true;
        JSONObject movieJson = null;
        String movieId = null;
        try{
            MovieAPI movieAPI = new MovieAPI();
            movieJson = new JSONObject(movieAPI.getMovieByTitle(title));
            movieId = movieJson.getString("id");
            contentrating = movieJson.getString("rating");
        }catch(Exception e){
            reviewAvailable = false;
        }
        String[] allowedRating = new String[] {"G","PG","M"};
        if(
            (reviewAvailable && Arrays.asList(allowedRating).contains(movieJson.getString("rating"))) ||
            (!reviewAvailable && Arrays.asList(allowedRating).contains(contentrating))
                ){
      %>
        <div class="panel panel-default">
          <div class="panel-heading">
            <h3 class="panel-title"><%=title%></h3>
          </div>
          <div class="panel-body">
            <div class="row">
                <div class="media">
                  <div class="media-left">
                    <a href="#">
                      <img class="media-object" src="<%=thumbnail%>">
                    </a>
                  </div>
                  <div class="media-body">
                    <h4 class="media-heading">Description</h4>
                    <p><%=description%></p>
                    <dl class="dl-horizontal">
                      <dt>Director</dt>
                      <dd><%=director%></dd>
                      <dt>Stars</dt>
                      <dd><%=stars%></dd>
                      <dt>Release date</dt>
                      <dd><%
                      Date date = new SimpleDateFormat("yyyy-MM-dd").parse(release_date);
                      out.print(new SimpleDateFormat("dd MMMM yyyy").format(date));
                      %></dd>
                      <dt>Genre</dt>
                      <dd><%=genre%></dd>
                      <dt>Rating</dt>
                      <dd><%=contentrating%></dd>
                      <dt>Plot keywords</dt>
                      <dd><%=keywords%></dd>
                      <dt>External resource</dt>
                      <dd><a href="<%=link%>" target="_blank">IMDb</a></dd>
                    </dl>
                  </div>
                </div>
            </div>
          </div>
        </div>
                    
        <div class="container">     
            <div class=".col-lg-12"> 
                <%
                    YouTubeAPI youtube = new YouTubeAPI();
                    out.println(youtube.search(title) + "</iframe>");
                %>  
            </div>
        </div>
            
        <%
            if(reviewAvailable){

                ReviewAPI reviewAPI = new ReviewAPI();

                result = new JSONObject(reviewAPI.getReview(movieId));
                String numOfUser = result.getString("numOfUser");
                String averageScore = result.getString("averageScore");

                out.println("<ul class=\"list-group\">");
                out.println("<li class=\"list-group-item active\">");   
                out.print("<input id=\"input-id\" class=\"rating\" data-min=\"0\" value=\""+averageScore+"\" data-readonly=\"true\" data-symbol=\"&#xe006;\" data-show-clear=\"false\" data-show-caption=\"false\" data-size=\"xs\">");
                out.println("Ratings: " + averageScore + "/5 from " + numOfUser + " users");
                out.println("</li>");
                items = result.getJSONArray("reviews");
                for(int i=0;i<items.length();i++){
                    item = items.getJSONObject(i);
                    out.println("<li class=\"list-group-item\">");                            
                    out.println("<h4 class=\"list-group-item-heading\">" + item.getString("date") + " | by " + item.getString("name") + " (" + item.getString("country") + ")</h4>");
                    out.println("<p class=\"list-group-item-text\">" + item.getString("comment") + "</p>");
                    out.println("</li>");
                }
                out.println("</ul>");
            }else{
                out.println("<div class=\"alert alert-info\" role=\"alert\">Review is not available.</div>");
            }
        %>      
            
        <ul class="list-group">
        <%
            try{
                Twitter twitter = new Twitter();
                json = twitter.searchTwitter(title);
                result = new JSONObject(json);
                JSONArray statuses = result.getJSONArray("statuses");

                if(statuses.length() == 0){
                    out.println("<li class='list-group-item'>No tweets found</li>");
                }else{
                    out.println("<li class='list-group-item active'>Recent and popular tweets</li>");
                    for (int i = 0; i < statuses.length(); i++) {
                        JSONObject rec = statuses.getJSONObject(i);
                        out.println("<li class='list-group-item'>");
                        out.println("<td>" + rec.getString("text") + "</td>");
                        out.println("</li>");
                    }
                }
            }catch(Exception e){
                out.println("<li class='list-group-item'>" + e.getMessage() + "</li>");
            }
        %>
        </ul>

      <% }else{ %>
      <div class="alert alert-warning" role="alert">
          <strong>Oops!</strong> Our search found that the movie is non-family movie according to its rating. Try another movie.
      </div>
      <% } } %>

      <footer class="footer">
        <p>&copy; Rizky Noor Ichwan 2015</p>
      </footer>

    </div> <!-- /container -->
  </body>
</html>
