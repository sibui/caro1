<!-- Put your Project 2 code here -->
<%-- Import the java.sql package --%>
<%@ page import="java.sql.*"%>
<%-- -------- Open Connection Code -------- --%>
	<%
	  Connection conn = null;
	  PreparedStatement pstmtProducts = null;
	  PreparedStatement pstmtCustomers = null;
	  PreparedStatement pstmtStates = null;
	  PreparedStatement pstmtMiddleTable = null;
	  ResultSet rsProducts = null;
	  ResultSet rsCustomers = null;
	  ResultSet rsStates = null;
	  ResultSet rsMiddle = null;
	 %>
	
	 <% 
	  try {
	      // Registering Postgresql JDBC driver with the DriverManager
	      Class.forName("org.postgresql.Driver");
	
	      // Open a connection to the database using DriverManager
	      conn = DriverManager.getConnection(
	          "jdbc:postgresql://localhost/cse135?" +
	          "user=postgres&password=postgres");
	 %>
      <% 
	  Statement categoryStatement1 = conn.createStatement();
	  int productOffset = 0;
	  int custStateOffset = 0;
	  if (request.getParameter("productOffset") == null) {
		  productOffset = 0;
	  } else {
		  productOffset = Integer.parseInt(request.getParameter("productOffset"));
	  }
	  
	  if (request.getParameter("custStateOffset") == null) {
		  custStateOffset = 0;
	  } else {
		  custStateOffset = Integer.parseInt(request.getParameter("custStateOffset"));
	  }
	  
	  String filter1 = request.getParameter("filter1");
	  String filter2 = request.getParameter("filter2");
	  
	  if (request.getParameter("category")==null) {
		  pstmtProducts = conn.prepareStatement("SELECT productName, sum(total) " +
				  "FROM (SELECT productName, total FROM FullProductHistory) as fph " +
				  "GROUP BY productName " +
				  "ORDER BY SUM(total) DESC LIMIT 10 OFFSET " + productOffset);
	  } else if (request.getParameter("category").equals("allCategories")) {
		  pstmtProducts = conn.prepareStatement("SELECT productName, sum(total) " +
				  "FROM (SELECT productName, total FROM FullProductHistory) as fph " +
				  "GROUP BY productName " +
				  "ORDER BY SUM(total) DESC LIMIT 10 OFFSET " + productOffset);
	  } else {
		  out.print("<h3> ENTERS THE FIRST CATEGORY CHEK else</h3>");
		  pstmtProducts = conn.prepareStatement("SELECT productName, sum(total) " +
				  "FROM (SELECT productName, total FROM FullProductHistory WHERE category = ?) as fph " +
				  "GROUP BY productName " +
				  "ORDER BY SUM(total) DESC LIMIT 10 OFFSET " + custStateOffset);
		  pstmtProducts.setInt(1, Integer.parseInt(request.getParameter("category")));
		  
	  }
	  rsProducts = pstmtProducts.executeQuery();
	%>     
	<table class="table table-border">
		<tr>
		<% while (rsProducts.next()) { 
			out.print("<th>"+rsProducts.getString("productName")+"</th>");
		} %>
		</tr>
	</table>
<%-- -------- Close Connection Code -------- --%>
<%
    // Close the ResultSets
    rsProducts.close();
	//rsCustomers.close();
	//rsStates.close();
	//rsMiddle.close();

    // Close the Statements
    pstmtProducts.close();
    //pstmtCustomers.close();
    //pstmtStates.close();
    //pstmtMiddleTable.close();

    // Close the Connection
    conn.close();
} catch (SQLException e) {
	
    // Wrap the SQL exception in a runtime exception to propagate
    // it upwards
    
    throw new RuntimeException(e);
}%>