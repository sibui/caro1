<%@ page contentType="text/html; charset=utf-8" language="java"%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<jsp:include page="/html/signup-form.html" />
</head>
<body>
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
	 	result = pstmt.executeQuery();
	 	result.next();
	 	String returnResult = "";
	 	if(result != null)
	 	{
	 		//username already in database, return error
	 		returnResult = "this user name is already taken";
	 		
	 	}
	 	//return the result
	 	out.write(returnResult);
	 %>
	 <%-- -------- Close Connection Code -------- --%>
	 <%
	    // Close the ResultSets
	    result.close();
		//rsMiddle.close();
	
	    // Close the Statements
	    pstmt.close();
	
	    // Close the Connection
	    conn.close();
	    } catch (SQLException e) {
		
	    // Wrap the SQL exception in a runtime exception to propagate
	    // it upwards
	    throw new RuntimeException(e);
	    } 
	%>
</body>
</html>