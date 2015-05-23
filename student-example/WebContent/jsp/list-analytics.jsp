<!-- Put your Project 2 code here -->
<%-- Import the java.sql package --%>
<%@ page import="java.sql.*"%>
<%-- -------- Open Connection Code -------- --%>
	<%
	  Connection conn = null;
	  PreparedStatement pstmtProducts = null;
	  PreparedStatement pstmtCustStates = null;
	  PreparedStatement pstmtMiddleTable = null;
	  ResultSet rsProducts = null;
	  ResultSet rsCustStates = null;
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
	  int custStateCount = 0;
	  String filter1 = "";
	  String filter2 = "";
	  String category = "";
	  
  	  Statement dropTempStatement = conn.createStatement();
      dropTempStatement.executeUpdate("drop table if exists stateSort");
	  
	  Statement dropTempStatement1 = conn.createStatement();
	  dropTempStatement1.executeUpdate("drop table if exists customerSort");
	  
	  Statement dropTempStatement2 = conn.createStatement();
 	  dropTempStatement2.executeUpdate("drop table if exists productSort");
	  
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
	  
	  if(request.getParameter("custStateCount") == null)
	  {
		  if(application.getAttribute("custStateCount") != null)
		  {
			custStateCount = (Integer)application.getAttribute("custStateCount");
		  }
		  else
		  {
			  custStateCount = 0;
		  }
	  }
	  else if(request.getParameter("custStateCount").equals(""))
	  {
		  custStateCount = 0;
	  }
	  else
	  {
		  custStateCount = Integer.parseInt(request.getParameter("custStateCount"));
	  }
	  
	  if (request.getParameter("filter1") == null) 
	  {
		  filter1 = "";
	  }
	  else
	  {
		  filter1 = request.getParameter("filter1");
	  }
	  
	  if(request.getParameter("filter2") == null)
	  {
		  
	 	filter2 = "";
	  }
	  else
	  {
		  filter2 = request.getParameter("filter2");
	  }
	  
	  if(request.getParameter("category") != null)
	  {
		  
	 	category = request.getParameter("category");
	  }
	  
	  if (category.equals("")) {
		  pstmtProducts = conn.prepareStatement("create temporary table productSort as (SELECT productName, sum(total) " +
				  "FROM (SELECT productName, total FROM FullProductHistory) as fph " +
				  "GROUP BY productName " +
				  "ORDER BY SUM(total) DESC LIMIT 10 OFFSET " + productOffset+")");
	  } else if (category.equals("allCategories")) {
		  pstmtProducts = conn.prepareStatement("create temporary table productSort as (SELECT productName, sum(total) " +
				  "FROM (SELECT productName, total FROM FullProductHistory) as fph " +
				  "GROUP BY productName " +
				  "ORDER BY SUM(total) DESC LIMIT 10 OFFSET " + productOffset+")");
	  } else {
		  pstmtProducts = conn.prepareStatement("create temporary table productSort as (SELECT productName, sum(total) " +
				  "FROM (SELECT productName, total FROM FullProductHistory WHERE category = ?) as fph " +
				  "GROUP BY productName " +
				  "ORDER BY SUM(total) DESC LIMIT 10 OFFSET " + productOffset+")");
		  pstmtProducts.setInt(1, Integer.parseInt(request.getParameter("category")));
		  
	  }
	  String nameOrTopK = "name";
	  // (default state)no filters have been chosen
	  if(filter1.equals("") && filter2.equals(""))
	  {
		  out.print("1");
		  filter1 ="Customers";
		  filter2 ="Top-K";
		  pstmtCustStates = conn.prepareStatement("create temporary table customerSort as (SELECT name, sum(total) " +
				  "FROM (SELECT name, total FROM FullProductHistory) as fph "+
				  "GROUP BY name "+
				  "ORDER BY SUM(total) DESC LIMIT 10 OFFSET " + custStateOffset +")");
	  } //(customer or state) has been chosen
	  else if(filter1.equals("Customers") && filter2.equals("Alphabetical"))
	  {
		  out.print("2");
		  pstmtCustStates = conn.prepareStatement("create temporary table customerSort as (SELECT name, sum(total) " +
				  "FROM (SELECT name, total FROM FullProductHistory) as fph "+
				  "GROUP BY name "+
				  "ORDER BY name ASC LIMIT 10 OFFSET " + custStateOffset +")");	  
	  }// (customer or state) and (alphabetical or top-k) has been chosen
	  else if(filter1.equals("Customers") && filter2.equals("Top-K"))
	  {
		  out.print("3");
		  nameOrTopK = "sum";
		  pstmtCustStates = conn.prepareStatement("create temporary table customerSort as (SELECT name, sum(total) " +
				  "FROM (SELECT name, total FROM FullProductHistory) as fph "+
				  "GROUP BY name "+
				  "ORDER BY SUM(total) DESC LIMIT 10 OFFSET " + custStateOffset+")");
	  } //(alphabetical or top-k) has been chosen
	  else if(filter1.equals("States") && filter2.equals("Alphabetical"))
	  {
		  out.print("4");
		  pstmtCustStates = conn.prepareStatement("create temporary table stateSort as (SELECT state as name, sum(total) " +
				  "FROM (SELECT state, total FROM FullProductHistory) as fph "+
				  "GROUP BY state "+
				  "ORDER BY state ASC LIMIT 10 OFFSET " + custStateOffset+")");
	  }
	  else if(filter1.equals("States") && filter2.equals("Top-K"))
	  {
		  out.print("5");
		  nameOrTopK = "sum";
		  pstmtCustStates = conn.prepareStatement("create temporary table stateSort as (SELECT state as name, sum(total) " +
				  "FROM (SELECT state, total FROM FullProductHistory) as fph "+
				  "GROUP BY state "+
				  "ORDER BY SUM(total) DESC LIMIT 10 OFFSET " + custStateOffset+")");
	  }
	  
	  pstmtCustStates.executeUpdate();
	  pstmtProducts.executeUpdate();
	  
	  Statement custStateStatement =  conn.createStatement();
	  Statement productStatement = conn.createStatement();
	  
	  String StateOrCustomer = "States";
	  if(filter1.equals("Customers") || filter1.equals(""))
	  {
		 StateOrCustomer = "Customers";
	 	 rsCustStates = custStateStatement.executeQuery("select * from customerSort");
	  }
	  else if(filter1.equals("States"))
	  {
		  rsCustStates = custStateStatement.executeQuery("select * from stateSort");
	  }
	  rsProducts =  productStatement.executeQuery("select * from productSort");
	  
	  String[] productNameSort = new String[10];
	  String[] custStateNameSort = new String[10];
	  int[] productTotalCostSort = new int[10];
	  int[] custStateTotalCostSort = new int[10];
	  
	  int productCounter = 0;
	  while(rsProducts.next())
	  {
		  productNameSort[productCounter] = rsProducts.getString("productName");
		  productTotalCostSort[productCounter] = rsProducts.getInt("sum");
		  productCounter++;
	  }
		int customerCounter = 0;
		while(rsCustStates.next())
		{
			custStateNameSort[customerCounter] = rsCustStates.getString("name");
			custStateTotalCostSort[customerCounter] = rsCustStates.getInt("sum");
			customerCounter++;
		}
	  
	%>     
	<table class="table table-border">
		<tr>
		<th></th>
		<%
		int i = 0;
		while (i < productCounter) { 
			out.print("<td>"+productNameSort[i]+"<br>$"+productTotalCostSort[i]+"</td>");
			i++;
		} %>
		
		<%
		//productCounter >= 10 means you loaded 10 products and if productOFfset+10 != productCount then there are more products to display
		if(productCounter >= 10 && (productOffset+10) != productCount) 
					{ %>
				<td>
					<form action="analytics" method="GET">
					<input type="hidden" value="<%=productOffset+10%>" name="productOffset"></input>
			        <input type="hidden" value="<%=custStateOffset%>" name="custStateOffset"></input>
			        <input type="hidden" value="<%=filter1%>" name="filter1"></input>
			        <input type="hidden" value="<%=filter2%>" name="filter2"></input>
			        <input type="hidden" value="<%=category%>" name="category"></input>
			        <input type="hidden" value="<%=productCount%>" name="productCount"></input>
			        <input type="hidden" value="<%=custStateCount%>" name="custStateCount"></input>
			        <input type="submit" value="Next 10 Products">
					</form>
				</td>
		<% } %>
		</tr>
		<% 
			int j = 0;
			while(j < customerCounter)
			{
				out.print("<tr><td>"+custStateNameSort[j]+"<br>$"+custStateTotalCostSort[j]+"</td></tr>");
				j++;
			}		
		%>
		
		<%if(customerCounter >= 10 && (custStateOffset+10) != custStateCount ) 
					{ %>
				<tr>
					<td>
						<form action="analytics" method="GET">
						<input type="hidden" value="<%=productOffset%>" name="productOffset"></input>
				        <input type="hidden" value="<%=custStateOffset+10%>" name="custStateOffset"></input>
				        <input type="hidden" value="<%=filter1%>" name="filter1"></input>
				        <input type="hidden" value="<%=filter2%>" name="filter2"></input>
				        <input type="hidden" value="<%=category%>" name="category"></input>
				        <input type="hidden" value="<%=productCount%>" name="productCount"></input>
				         <input type="hidden" value="<%=custStateCount%>" name="custStateCount"></input>
				        <input type="submit" value="Next 10 <%=StateOrCustomer%>">
						</form>
					</td>
				</tr>
		<% } %>
	</table>
				
<%-- -------- Close Connection Code -------- --%>
<%
    // Close the ResultSets
    rsProducts.close();
	rsCustStates.close();
	//rsMiddle.close();

    // Close the Statements
    pstmtProducts.close();
    pstmtCustStates.close();
    //pstmtMiddleTable.close();

    // Close the Connection
    conn.close();
} catch (SQLException e) {
	
    // Wrap the SQL exception in a runtime exception to propagate
    // it upwards
    
    throw new RuntimeException(e);
}%>