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
	  
	  
	  if(request.getParameter("category") != null)
	  {
		  
	 	category = request.getParameter("category");
	  }
	  
	  String productNameOrTopK = "SUM(total) DESC";
	  
	  boolean categorySearch = false;
	  
	  //changed queries so that it ALWAYS refers to state AND TOPK
	  //queries change depending on whether or not a category is specified
	  // this is hwere topProducts and topStates are created
	  if (category.equals("") || category.equals("allCategories")) {
		  pstmtProducts = conn.prepareStatement("create temporary table productSort as (SELECT productName, sum(total) " +
				  "FROM (SELECT productName, total FROM FullProductHistory) as fph " +
				  "GROUP BY productName " +
				  "ORDER BY SUM(total) DESC LIMIT 50 OFFSET ? )");
		  pstmtProducts.setInt(1,productOffset);
		  // (default state)no filters have been chosen
		  pstmtCustStates = conn.prepareStatement("create temporary table stateSort as (SELECT name as name, sum(total) " +
					  "FROM (SELECT name, total FROM FullProductHistory) as fph "+
					  "GROUP BY name "+
					  "ORDER BY SUM(total) DESC LIMIT 50 OFFSET ?)");
			  pstmtCustStates.setInt(1,custStateOffset);

	  }
	  else {	  
		  pstmtProducts = conn.prepareStatement("create temporary table productSort as (SELECT productName, sum(total) " +
				  "FROM (SELECT productName, total FROM FullProductHistory WHERE category = ? ) as fph " +
				  "GROUP BY productName " +
				  "ORDER BY SUM(total) DESC LIMIT 50 OFFSET ? )");
		  categorySearch = true;
		  pstmtProducts.setInt(1, Integer.parseInt(request.getParameter("category")));	
		  pstmtProducts.setInt(2,productOffset);
		  // (default state)no filters have been chosen
		  pstmtCustStates = conn.prepareStatement("create temporary table stateSort as (SELECT name as name, sum(total) " +
					  "FROM (SELECT name, total FROM FullProductHistory WHERE category = ?) as fph "+
					  "GROUP BY name "+
					  "ORDER BY SUM(total) DESC LIMIT 50 OFFSET ?)");
		  	  pstmtCustStates.setInt(1, Integer.parseInt(request.getParameter("category")));
			  pstmtCustStates.setInt(2,custStateOffset);

	  }	  
	  
	  
	  
	  
	  

	 


	  pstmtCustStates.executeUpdate();
	  pstmtProducts.executeUpdate();
	  
	  
	  //is it state or customer?
	  pstmtMiddleTable = conn.prepareStatement("create table middleTable as( "+
			  "select name as name, productname, total from FullProductHistory "+
			  "WHERE name in (SELECT name from stateSort) "+
			  "AND productname in (SELECT productname from productSort) "+
			  "order by productname)");

	  //create middleTable

	  pstmtMiddleTable.executeUpdate();
	  
	  
	  
	  Statement custStateStatement =  conn.createStatement();
	  Statement productStatement = conn.createStatement();
	  Statement middleStatement = conn.createStatement();
	  

	  rsCustStates = custStateStatement.executeQuery("select * from stateSort");
	  rsProducts =  productStatement.executeQuery("select * from productSort");
	  
	  String[] productNameSort = new String[50];
	  String[] custStateNameSort = new String[50];
	  int[] productTotalCostSort = new int[50];
	  int[] custStateTotalCostSort = new int[50];
	  int[][] middleTable = new int[50][50];
	  
	  for(int i = 0; i < 50; i++)
	  {
		  for(int j = 0; j < 50; j++)
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
			
			while (rsMiddle.next()) 
			{ 
				int middleProductCounter = 0;
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
					//took out an else statement that was doing something we didn't expect
					middleProductCounter++;
				}	
					
				
			} 
		}
		
	  
	%>     
	<!-- we get the "timestamp" of the precomputed tables AND the "timestamp" of your precomputed table -->
	<input type="hidden" id="hiddenFphCurrentTime" value="<%=session.getAttribute("fphCurrentTime")%>" method="GET"></>
	<input type="hidden" id="hiddenFphTime" value="<%=application.getAttribute("fphTime")%>" method="GET"></>
	<button id="refreshButton" name="refresh" value="refresh" onclick="refresh()">Refresh</button>
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
			//added same name for all cells so that we can make it all black very easily
			//added id that makes it easy to identify the cell based on productName
			out.print("<th>"+productNameSort[i].substring(0,length)+"<br>($<i name=\"namecell\" id=\""+productNameSort[i].substring(0,length)+"\">"+productTotalCostSort[i]+"</i>)</th>");
			i++;
		} %>
		

		<%
		//productCounter >= 10 means you loaded 10 products and if productOFfset+10 != productCount then there are more products to display
		if(productCounter >= 50 && (productOffset+50) != productCount) 
					{ %>
				<td>
					<form action="analytics" method="GET">
					<input type="hidden" value="<%=productOffset+50%>" name="productOffset"></input>
			        <input type="hidden" value="<%=custStateOffset%>" name="custStateOffset"></input>
			        <input type="hidden" value="<%=category%>" name="category"></input>
			        <input type="hidden" value="<%=productCount%>" name="productCount"></input>
			        <input type="hidden" value="<%=custStateCount%>" name="custStateCount"></input>
			        <input type="hidden" value="clicked" name="next10"></input>
			        <input type="submit" value="Next 50 Products">
					</form>
				</td>
				
				
		<% } %>
		</tr>
		<% 
			int j = 0;
			while(j < customerCounter)
			{
				out.print("<tr>");
				//added same name for all cells so that we can make it all black very easily
				//added id that makes it easy to identify based on statename
				out.print("<th>"+custStateNameSort[j]+"<br>($<i name=\"namecell\" id=\""+custStateNameSort[j]+"\">"+custStateTotalCostSort[j]+"</i>)</th>");
				for(int a = 0; a < productCounter; a++)
				{
					//added same name for all cells so that we can make it all black very easily
					//added id that makes it easy to identify based on statename AND productname
					out.print("<td>$<i name=\"namecell\" id=\""+custStateNameSort[j]+"|"+productNameSort[a]+"\">"+middleTable[a][j]+"</i></td>");	
				}
				out.print("</tr>");
				j++;
			}		
		%>
		

	</table>
				
	<script type="text/javascript">
		//ajax call function
		function refresh() {
			
			var xmlHttp;
			//make all the cells on our analytics table black by default
			for(a=0; a < document.getElementsByName("namecell").length;a++){
				document.getElementsByName("namecell")[a].style.color = "black";
			}
			xmlHttp = new XMLHttpRequest();
			//grab the timestamps that we set up earlier
			var fphCurrentDom = document.getElementById("hiddenFphCurrentTime").value;
			var fphTimeDom = document.getElementById("hiddenFphTime").value;
			
			var responseHandler = function() {
				//when it's ready
				if (xmlHttp.readyState == 4) {
					//read the json file that refresh.jsp gives us
					var arr = JSON.parse(xmlHttp.responseText);
					//grab the new timestamps of the states of the relevant tables
					document.getElementById("hiddenFphCurrentTime").value = arr.fphCurrent;
					document.getElementById("hiddenFphTime").value = arr.fphTime;
					
					//do stuff if our json object doesn't return with "doNothing"
					//it returns doNothing if our table is uptodate
					if(!arr.returnMessage.contains("doNothing")){
						//get the state object
						var stateArray = arr.state;
						//access each element in our state object
						for (i = 0; i < Object.keys(stateArray).length; i++) {
							//grab the key name, which is the state name
							var stateKey = Object.keys(stateArray)[i];
							//iterate through each key to get its value
							for(j=0; j < stateArray[stateKey].length;j++){
								//get how much that state cost should increase by
								var costKey = stateArray[stateKey][j].cost;
								//increase the state cost by itself + new number
								document.getElementById(stateKey).innerHTML = parseInt(costKey) + parseInt(document.getElementById(stateKey).innerHTML);
								//make the recently changed value red
								document.getElementById(stateKey).style.color = "red";
								
							}
						}
						
						//grab the product object
						var productArray = arr.pid;
						//access each product element
						for(i = 0; i< Object.keys(productArray).length; i++)
						{
							//grab a productKey
							var productKey = Object.keys(productArray)[i];
							//iterate through each key to get its value
							for(j=0; j< productArray[productKey].length;j++)
							{
								//get the number that product should be increased by
								costKey = productArray[productKey][j].cost;
								//increase the product total by itself + new number
								document.getElementById(productKey).innerHTML = parseInt(costKey) + parseInt(document.getElementById(productKey).innerHTML);
								//make the new number red
								document.getElementById(productKey).style.color= "red";
							}
						}
						
						//grab the statepid object
						var middleArray = arr.statepid;
						//access each statepid element
						for(i = 0; i< Object.keys(middleArray).length; i++)
						{
							//grab the statepid key
							var middleKey = Object.keys(middleArray)[i];
							//iterate through each of the key's values
							for(j=0; j< middleArray[middleKey].length;j++)
							{
								//get the cost that the statepid cell should be increased by
								costKey = middleArray[middleKey][j].cost;
								//increase the cell by its old total + new number
								document.getElementById(middleKey).innerHTML = parseInt(costKey) + parseInt(document.getElementById(middleKey).innerHTML);
								//make changed number red
								document.getElementById(middleKey).style.color= "red";
							}
						}
						
						

					}
					
				} 
			}
		
			//ajax requests
			xmlHttp.onreadystatechange = responseHandler;
			xmlHttp.open("GET", "/student-example/jsp/refresh.jsp?fphCurrent="+fphCurrentDom,true);
			xmlHttp.send(null);
			

		}
		
	</script>		
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