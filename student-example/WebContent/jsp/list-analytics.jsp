<!-- Put your Project 2 code here -->
<%-- Import the java.sql package --%>
<%@ page import="java.sql.*"%>
<%-- -------- Open Connection Code -------- --%>
	<%

	  Connection conn = null;
	  PreparedStatement pstmtProducts = null;
	  PreparedStatement pstmtCustStates = null;
	  PreparedStatement pstmtMiddleTable = null;
	  PreparedStatement pstmtFullProductHistory = null;
	  ResultSet rsProducts = null;
	  ResultSet rsCustStates = null;
	  ResultSet rsMiddle = null;
	  ResultSet rsFullProductHistory = null;
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
 	  
 	  Statement dropTempStatement3 = conn.createStatement();
 	  dropTempStatement3.executeUpdate("drop table if exists middleTable");
 	  
 	 Statement dropTempStatement4 = conn.createStatement();
	  dropTempStatement4.executeUpdate("drop table if exists FullProductHistory");
 	 
	  
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
	  
	  String productNameOrTopK = "";
	  if(filter2.equals("Alphabetical"))
	  {
		  productNameOrTopK = "productname ASC";
	  }
	  else
	  {
		  productNameOrTopK = "SUM(total) DESC";
	  }
	  
	  boolean categorySearch = false;
	  
	  if (category.equals("")) {
		  pstmtProducts = conn.prepareStatement("create temporary table productSort as (SELECT productName, sum(total) " +
				  "FROM (SELECT productName, total FROM FullProductHistory) as fph " +
				  "GROUP BY productName " +
				  "ORDER BY productName ASC LIMIT 10 OFFSET ? )");
		  pstmtProducts.setInt(1,productOffset);
	  } else if (category.equals("allCategories")) {  
		  pstmtProducts = conn.prepareStatement("create temporary table productSort as (SELECT productName, sum(total) " +
				  "FROM (SELECT productName, total FROM FullProductHistory) as fph " +
				  "GROUP BY productName " +
				  "ORDER BY "+ productNameOrTopK+ " LIMIT 10 OFFSET ? )");
		  pstmtProducts.setInt(1,productOffset);
	  } else {
		  
		  pstmtProducts = conn.prepareStatement("create temporary table productSort as (SELECT productName, sum(total) " +
				  "FROM (SELECT productName, total FROM FullProductHistory WHERE category = ? ) as fph " +
				  "GROUP BY productName " +
				  "ORDER BY "+ productNameOrTopK+ " LIMIT 10 OFFSET ? )");
		  categorySearch = true;
		  pstmtProducts.setInt(1, Integer.parseInt(request.getParameter("category")));	
		  pstmtProducts.setInt(2,productOffset);
	  }	  
	  
	  
	  
	  String custOrStateFPH = "users.name";
	  // (default state)no filters have been chosen
	  if(filter1.equals("") && filter2.equals(""))
	  {
		  filter1 ="Customers";
		  filter2 ="Alphabetical";
		  pstmtCustStates = conn.prepareStatement("create temporary table customerSort as (SELECT name, sum(total) " +
				  "FROM (SELECT name, total FROM FullProductHistory) as fph "+
				  "GROUP BY name "+
				  "ORDER BY name ASC LIMIT 20 OFFSET ? )");
		  pstmtCustStates.setInt(1,custStateOffset);
	  } //(customer or state) has been chosen
	  else if(filter1.equals("Customers") && filter2.equals("Alphabetical"))
	  {
		  pstmtCustStates = conn.prepareStatement("create temporary table customerSort as (SELECT name, sum(total) " +
				  "FROM (SELECT name, total FROM FullProductHistory) as fph "+
				  "GROUP BY name "+
				  "ORDER BY name ASC LIMIT 20 OFFSET ?)");	  
		  pstmtCustStates.setInt(1,custStateOffset);
	  }// (customer or state) and (alphabetical or top-k) has been chosen
	  else if(filter1.equals("Customers") && filter2.equals("Top-K"))
	  {
		  
		  pstmtCustStates = conn.prepareStatement("create temporary table customerSort as (SELECT name, sum(total) " +
				  "FROM (SELECT name, total FROM FullProductHistory) as fph "+
				  "GROUP BY name "+
				  "ORDER BY SUM(total) DESC LIMIT 20 OFFSET ?)");
		  pstmtCustStates.setInt(1,custStateOffset);
	  } //(alphabetical or top-k) has been chosen
	  else if(filter1.equals("States") && filter2.equals("Alphabetical"))
	  {
		  custOrStateFPH = "states.name";
		  pstmtCustStates = conn.prepareStatement("create temporary table stateSort as (SELECT name as name, sum(total) " +
				  "FROM (SELECT name, total FROM FullProductHistory) as fph "+
				  "GROUP BY name "+
				  "ORDER BY name ASC LIMIT 20 OFFSET ?)");
		  pstmtCustStates.setInt(1,custStateOffset);
	  }
	  else if(filter1.equals("States") && filter2.equals("Top-K"))
	  {
		  custOrStateFPH = "states.name";
		  pstmtCustStates = conn.prepareStatement("create temporary table stateSort as (SELECT name as name, sum(total) " +
				  "FROM (SELECT name, total FROM FullProductHistory) as fph "+
				  "GROUP BY name "+
				  "ORDER BY SUM(total) DESC LIMIT 20 OFFSET ?)");
		  pstmtCustStates.setInt(1,custStateOffset);
	  }
	  
	  
	  //check if user wants specific category or not	  
	  if(categorySearch)
	  {
		  int categoryFilterFPH = Integer.parseInt(request.getParameter("category"));
		  pstmtFullProductHistory = conn.prepareStatement("create temporary table FullProductHistory as(SELECT sales.uid, "+custOrStateFPH+", SUM(sales.price*sales.quantity) AS total, products.name as productname, categories.id as category "+
				  "FROM users, products, sales, categories, states "+
				  "WHERE sales.uid = users.id AND sales.pid = products.id AND categories.id = ? AND users.state = states.id "+
				  "GROUP BY "+custOrStateFPH+", sales.uid, products.name, categories.id "+
				  "ORDER BY SUM(sales.price*sales.quantity) DESC)");
		  pstmtFullProductHistory.setInt(1, categoryFilterFPH);
	  }
	  else
	  {
		  pstmtFullProductHistory = conn.prepareStatement("create temporary table FullProductHistory as(SELECT sales.uid, "+custOrStateFPH+", SUM(sales.price*sales.quantity) AS total, products.name as productname, categories.id as category "+
				  "FROM users, products, sales, categories, states "+
				  "WHERE sales.uid = users.id AND sales.pid = products.id AND categories.id = products.cid AND users.state = states.id "+
				  "GROUP BY "+custOrStateFPH+", sales.uid, products.name, categories.id "+
				  "ORDER BY SUM(sales.price*sales.quantity) DESC)");
	  }
	 
	  
	  //create FullProductHistory and its indices
	  //long startTime = System.nanoTime(); 
                                
	  pstmtFullProductHistory.executeUpdate();
	  //long endTime = System.nanoTime(); 
      //long duration = (endTime - startTime);
      //out.print("time of fullProductHistory:"+ duration);
	 /*
	 Statement createIndexStatement = conn.createStatement();
	  dropTempStatement4.executeUpdate("CREATE INDEX nameOrStateIndex ON fullProductHistory(name)");	  
	  Statement createIndexStatement1 = conn.createStatement();
	  dropTempStatement4.executeUpdate("CREATE INDEX productNameIndex ON fullProductHistory(productName)");
	 */
	  //create the left and top tables
	 // startTime = System.nanoTime();
	  pstmtCustStates.executeUpdate();
	//  endTime = System.nanoTime();
	//  duration = (endTime-startTime);
	//  out.print("time of left Table:"+ duration);
	  
	//  startTime = System.nanoTime();
	  pstmtProducts.executeUpdate();
	//  endTime = System.nanoTime();
	//  duration = (endTime-startTime);
	//  out.print("time of top Table:"+ duration);
	  
	  
	  //is it state or customer?
	  String custOrState = "state";
	  String custOrStateTable = "stateSort";
	  pstmtMiddleTable = conn.prepareStatement("create table middleTable as( "+
			  "select ? as name, productname, total from FullProductHistory "+
			  "WHERE ? in (SELECT ? from stateSort) "+
			  "AND productname in (SELECT productname from productSort) "+
			  "order by productname)");
	  
	  if(filter1.equals("Customers") || filter1.equals(""))
	  {
		  custOrState = "name";
		  custOrStateTable = "customerSort";
		  pstmtMiddleTable = conn.prepareStatement("create table middleTable as( "+
				  "select ? as name, productname, total from FullProductHistory "+
				  "WHERE ? in (SELECT ? from customerSort) "+
				  "AND productname in (SELECT productname from productSort) "+
				  "order by productname)");
	  }

	  //create middleTable

	  
	  pstmtMiddleTable.setString(1,custOrState);
	  pstmtMiddleTable.setString(2,custOrState);
	  pstmtMiddleTable.setString(3,custOrState);
	  //startTime = System.nanoTime();
	  pstmtMiddleTable.executeUpdate();
	  //endTime = System.nanoTime();
	 // duration = (endTime-startTime);
	  //out.print("time of middle Table:"+ duration);
	  
	  
	  
	  Statement custStateStatement =  conn.createStatement();
	  Statement productStatement = conn.createStatement();
	  Statement middleStatement = conn.createStatement();
	  
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
	  String[] custStateNameSort = new String[20];
	  int[] productTotalCostSort = new int[10];
	  int[] custStateTotalCostSort = new int[20];
	  int[][] middleTable = new int[10][20];
	  for(int i = 0; i < 10; i++)
	  {
		  for(int j = 0; j < 20; j++)
		  {
			  middleTable[i][j] = 0;
		  }
	  }
	  
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
		
		
		for(int k = 0; k < customerCounter; k++ )
		{
			rsMiddle = middleStatement.executeQuery("select name, productname, sum(total) as total from middleTable where name = '" + custStateNameSort[k]+"'"+" group by name, productname");
			int middleProductCounter = 0;
			while (rsMiddle.next()) 
			{ 
				String name = rsMiddle.getString("name");
				String productName =rsMiddle.getString("productname");
				int total =rsMiddle.getInt("total");
				//out.print("name: "+name+" , productName:"+ productName+", total:"+total+"<br>");

				while(middleProductCounter < productCounter)
				{
					if(productNameSort[middleProductCounter].equals(productName))
					{
						middleTable[middleProductCounter][k] = total;
						//out.print("productNameSort["+middleProductCounter+"]="+productNameSort[middleProductCounter]+" !middleTable["+middleProductCounter+"]["+k+"] = "+total+"<br>");
					}
					else
					{
						//out.print("productNameSort["+middleProductCounter+"]="+productNameSort[middleProductCounter]+"@middleTable["+middleProductCounter+"]["+k+"] = "+0+"<br>");
						middleTable[middleProductCounter][k] = 0;
						
					}
					middleProductCounter++;
				}	
					
				
			} 
		}
		
	  
	%>     
	<table class="table table-border">
		<tr>
		<th></th>
		<%
		int i = 0;
		while (i < productCounter) { 
			int length = productNameSort[i].length();
			if(length > 10)
			{
				length = 10;
			}
			out.print("<th>"+productNameSort[i].substring(0,length)+"<br>($"+productTotalCostSort[i]+")</th>");
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
			        <input type="hidden" value="clicked" name="next10"></input>
			        <input type="submit" value="Next 10 Products">
					</form>
				</td>
		<% } %>
		</tr>
		<% 
			int j = 0;
			while(j < customerCounter)
			{
				out.print("<tr>");
				out.print("<th>"+custStateNameSort[j]+"<br>($"+custStateTotalCostSort[j]+")</th>");
				for(int a = 0; a < productCounter; a++)
				{
					out.print("<td>$"+middleTable[a][j]+"</td>");	
				}
				out.print("</tr>");
				j++;
			}		
		%>
		
		
		<%if(customerCounter >= 20 && (custStateOffset+20) != custStateCount ) 
					{ %>
				<tr>
					<td>
						<form action="analytics" method="GET">
						<input type="hidden" value="<%=productOffset%>" name="productOffset"></input>
				        <input type="hidden" value="<%=custStateOffset+20%>" name="custStateOffset"></input>
				        <input type="hidden" value="<%=filter1%>" name="filter1"></input>
				        <input type="hidden" value="<%=filter2%>" name="filter2"></input>
				        <input type="hidden" value="<%=category%>" name="category"></input>
				        <input type="hidden" value="<%=productCount%>" name="productCount"></input>
				         <input type="hidden" value="<%=custStateCount%>" name="custStateCount"></input>
				         <input type="hidden" value="clicked" name="next10"></input>
				        <input type="submit" value="Next 20 <%=StateOrCustomer%>">
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