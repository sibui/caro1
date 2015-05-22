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
	  int productCount = 0;
	  String filter1 = "";
	  String filter2 = "";
	  String category = "";
	  
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
	  
	  if(request.getParameter("productCount") == null)
	  {
		  if(application.getAttribute("productCount") != null)
		  {
			productCount = (Integer)application.getAttribute("productCount");
		  }
		  else
		  {
			  productCount = 0;
			  out.print("productCount is null");
		  }
	  }
	  else if(request.getParameter("productCount").equals(""))
	  {
		  productCount = 0;
	  }
	  else
	  {
		  productCount = Integer.parseInt(request.getParameter("productCount"));
	  }
	  
	  if (request.getParameter("filter1") != null) 
	  {
		  filter1 = request.getParameter("filter1");
	  }
	  
	  if(request.getParameter("filter2") != null)
	  {
		  
	 	filter2 = request.getParameter("filter2");
	  }
	  
	  if(request.getParameter("category") != null)
	  {
		  
	 	category = request.getParameter("category");
	  }
	  
	  if (category.equals("")) {
		  pstmtProducts = conn.prepareStatement("SELECT productName, sum(total) " +
				  "FROM (SELECT productName, total FROM FullProductHistory) as fph " +
				  "GROUP BY productName " +
				  "ORDER BY SUM(total) DESC LIMIT 10 OFFSET " + productOffset);
	  } else if (category.equals("allCategories")) {
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
		<%
		int productCounter = 0;
		while (rsProducts.next()) { 
			out.print("<th>"+rsProducts.getString("productName")+"</th>");
			productCounter++;
		} %>
		</tr>
	</table>
				<%if(productCounter >= 10 && (productOffset+10) != productCount) 
					{ %>
				<form action="analytics" method="GET">
				<input type="hidden" value="<%=productOffset+10%>" name="productOffset"></input>
		        <input type="hidden" value="<%=custStateOffset%>" name="custStateOffset"></input>
		        <input type="hidden" value="<%=filter1%>" name="filter1"></input>
		        <input type="hidden" value="<%=filter2%>" name="filter2"></input>
		        <input type="hidden" value="<%=category%>" name="category"></input>
		        <input type="hidden" value="<%=productCount%>" name="productCount"></input>
		        <input type="submit" value="Next 10 Products">
				</form>
				<% } %>
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