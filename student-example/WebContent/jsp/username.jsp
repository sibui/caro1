<%@page import="org.json.*"%> 
<%-- Needed for only JSON to return back to signup-form.html --%>
<% response.setContentType("text/JSON"); %>
<%--  <% response.setContentType("text/xml"); %> --%>
<%-- <%@ page contentType="text/xml; charset=utf-8" language="java"%> --%>

<%-- We run a query on getting the name from the users table to check if the 
     username already exists. --%>
	<%
	
		String name = null;
		try {
			name = request.getParameter("name");
		} catch (Exception e) {
			name = null;
		}
	%>
	<%-- Import the java.sql package --%>
	<%@ page import="java.sql.*"%>
	<%-- -------- Open Connection Code -------- --%>
	<%
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet result = null;
	%>
	<% 
		try {
	
		// Registering Postgresql JDBC driver with the DriverManager
		Class.forName("org.postgresql.Driver");
		
		// Open a connection to the database using DriverManager
		conn = DriverManager.getConnection(
			"jdbc:postgresql://localhost/cse135_small?" +
		    "user=postgres&password=postgres");
	 %>
	 <%
	 	Statement userStatement = conn.createStatement();
	 	pstmt = conn.prepareStatement("select * from users where name=?");
	 	pstmt.setString(1, name);
	 	String returnResult = "";	 //what gets returned from the AJAX request
	 	if(!name.equals(""))
	 	{
		 	result = pstmt.executeQuery();
	
		 	if(result.next())
		 	{
		 		//username already in database, return error
		 		returnResult = "this user name is already taken";
		 	}
		 	else
		 	{
		 		returnResult = "name provided";
		 	}
	 	}
	 	else
	 	{
	 		returnResult = "blank";
	 	}
	 	
	 	//This is the JSONObject being returned with the appropriate message
	 	JSONObject username = new JSONObject();
	 	username.put("name", returnResult);
	 	out.print(username);
	 	
	 %>

	 <%-- -------- Close Connection Code -------- --%>
	 <%
	 		
	    // Close the ResultSets
	    if(result != null) result.close();
	
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
