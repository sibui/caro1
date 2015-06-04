<%@ page contentType="text/html; charset=utf-8" language="java"%>
<%@page import="org.json.*"%> 
<%@ page import="java.sql.*" %>
<%@page import="java.util.Iterator" %>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<jsp:include page="/html/head.html" />
</head>
<%
    boolean nameNotNull = session.getAttribute("name") != null;
    String role = (String) session.getAttribute("role");
    boolean roleIsOwner = (role != null) ? role
            .equalsIgnoreCase("owner") : false;
    JSONObject result = (JSONObject)(application.getAttribute("log"));
    //String tester = result.toString();
    //out.print(result+"<br>");
    //out.print((Integer)application.getAttribute("logNumber"));
    JSONArray logArray = result.getJSONArray("log");
    //out.print(result.getJSONArray("log"));
    //out.print(logArray);
    for(int i = 0; i< logArray.length();i++ )
    {
    	JSONObject logObject = logArray.getJSONObject(i);
    	//out.print(JSONObject.getNames(logObject)+"<br>");
    	Iterator<?> keys = logObject.keys();
    	while( keys.hasNext() ) {
    	    String key = (String)keys.next();
    	    out.print(key+"<br>");
    	}
    	String test = logObject.get("state").toString();
    }
    int fphTime = (Integer)application.getAttribute("fphTime");
    int logNumber = (Integer) application.getAttribute("logNumber");
    //session.setAttribute("fphCurrentTime",fphTime );
    
    Connection conn = null;
	PreparedStatement pstmt = null;
	ResultSet resultset = null;
    
	Class.forName("org.postgresql.Driver");
	
	// Open a connection to the database using DriverManager
	conn = DriverManager.getConnection(
		"jdbc:postgresql://localhost/cse135_small?" +
	    "user=postgres&password=postgres");
	
    //while our precomputed table is behind our log, keep on inserting
    while(fphTime < logNumber)
    {
    	pstmt = conn.prepareStatement("INSERT into fullproducthistory VALUES (?,?,?,?);");
    	JSONObject logObjectElement = logArray.getJSONObject(fphTime+1);
    	
    	pstmt.setString(1,(String)logObjectElement.get("state"));
    	pstmt.setInt(2,(Integer)logObjectElement.get("cost"));
    	pstmt.setString(3,(String)logObjectElement.get("pid"));
    	pstmt.setInt(4,(Integer)logObjectElement.get("cid"));
    	pstmt.executeUpdate();
    	fphTime++;
    }
    application.setAttribute("fphTime", fphTime);
    session.setAttribute("fphCurrentTime",fphTime );
    
           // long startTime = System.nanoTime();  
           
%>
<body class="page-index" data-spy="scroll" data-offset="60" data-target="#toc-scroll-target">
    <jsp:include page="/jsp/header.jsp" />
    <div class="container">
        <div class="row">
            <div class="span12">
                <div class="body-content">
                    <div class="section">
                        <div class="row">
                            <div class="col-md-3">
                                <%
                                    if (nameNotNull) {
                                %>
                                <%
                                    if (roleIsOwner) {
                                %>
                                <jsp:include page="/jsp/owner-menu.jsp" />
                                <jsp:include page="/jsp/sidebar-analytics.jsp" />
                                <%
                                    } else {
                                %>
                                <jsp:include page="/jsp/customer-menu.jsp" />
                                <%
                                    }
                                %>
                                <%
                                    }
                                %>
                            </div>
                            <div class="col-md-9">
                                <div class="page-header">
                                    <h3>Analytics</h3>
                                </div>
                                <%
                                    if (nameNotNull && roleIsOwner) {
                                %>
                                
                                <jsp:include page="/jsp/list-analytics.jsp" />
                                <%
                                    } else {
                                %>
                                <div class="alert alert-info">
                                    You need to be logged as an owner to see this page. Want to <a href="login">login</a>?
                                </div>
                                <%
                                    }
                               // long endTime = System.nanoTime(); 
                                //long duration = (endTime - startTime);
                                //out.print(duration);
                                %>
                            </div>
                        </div>
                        <jsp:include page="/html/footer.html" />
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>