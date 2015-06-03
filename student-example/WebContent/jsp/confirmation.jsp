<%@ page contentType="text/html; charset=utf-8" language="java" import="helpers.*"%>
<%@page import="org.json.*"%> 
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<jsp:include page="/html/head.html" />
</head>
<%@ page import="java.sql.*" %>
<%
	Connection conn = null;
	PreparedStatement pstmt = null;
	ResultSet resultset = null;

	boolean nameNotNull = session.getAttribute("name") != null;
	String role = (String) session.getAttribute("role");
	boolean roleIsCustomer = (role != null) ? role
			.equalsIgnoreCase("customer") : false;
			
	
	
	try {
		
		// Registering Postgresql JDBC driver with the DriverManager
		Class.forName("org.postgresql.Driver");
		
		// Open a connection to the database using DriverManager
		conn = DriverManager.getConnection(
			"jdbc:postgresql://localhost/cse135_small?" +
		    "user=postgres&password=postgres");
		
		//log, state, user rentry from shopping guy needed for analytics 
		String state=""; 
		if(nameNotNull){ //if its equal to true 
			pstmt = conn.prepareStatement("select state from users where name =?");
			pstmt.setString(1, (String)session.getAttribute("name"));
			resultset = pstmt.executeQuery();
			resultset.next();
			state = resultset.getString("state");
		}
		
	
	
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
                                	if (roleIsCustomer) {
                                %>
                                <jsp:include page="/jsp/customer-menu.jsp" />
                                <%
                                	} else {
                                %>
                                <jsp:include page="/jsp/owner-menu.jsp" />
                                <%
                                	}
                                %>
                                <%
                                	}
                                %>
                            </div>
                            <div class="col-md-9">
                                <div class="page-header">
                                    <h3>Confirmation</h3>
                                </div>
                                <%
                                	if (nameNotNull) {
                                		ShoppingCart cart = PurchaseHelper.obtainCartFromSession(session);
                                        Integer uid = LoginHelper.obtainUserFromSession(session);
                                        
                                	    JSONObject result = PurchaseHelper.purchaseCart(cart, uid); //function call 
                                	    JSONArray array = result.getJSONArray("log"); // reading the function call 
                                	    
                                	    
                                	    if (application.getAttribute("log") != null) {
                                	    	JSONObject log = (JSONObject) (application.getAttribute("log"));
                                	    
                                	    
	                                	    JSONArray logArray = new JSONArray();

	                                	    for(int i=0; i < array.length();i++){
	                                    	    JSONObject obj = new JSONObject();
												
	                                	    	int pid = array.getJSONObject(i).getInt("pid");
	                                	    	int cost = array.getJSONObject(i).getInt("cost");
	                                	    
	                                	    
	                                	    	obj.put("pid",pid);
	                                	    	obj.put("cost",cost);
	                                	    	obj.put("state",state);
	                                	    	
	                                	    	logArray.put(obj);	
                                	    	}
		                           	   		log.put("log",logArray);
                                	    	out.print(log);
                                	    }
                                        
                                                                       	   
                                	} else {
                                %>
                                <div class="alert alert-info">
                                    You need to be logged as an owner to see this page. Want to <a href="login">login</a>?
                                </div>
                                <%
                                	}
                                %>
                            </div>
                        </div>
                        <jsp:include page="/html/footer.html" />
                    </div>
                </div>
            </div>
        </div>
    </div>
    <%
	 		
	    // Close the ResultSets
	    if(resultset != null) resultset.close();
	
	    // Close the Statements
	    if(pstmt != null) pstmt.close();
	
	    // Close the Connection
	    if (conn != null) conn.close();
	    } catch (SQLException e) {
		
	    // Wrap the SQL exception in a runtime exception to propagate
	    // it upwards
	    throw new RuntimeException(e);
	    } 
	%>
</body>
</html>
