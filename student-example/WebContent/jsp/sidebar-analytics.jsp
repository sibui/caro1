<div class="panel panel-default">
	<div class="panel-body">
		<div class="bottom-nav">
            
            <!-- Put your part 2 code here -->
            <%@ page import="java.sql.*"%>
                                <%-- -------- Open Connection Code -------- --%>
           						<%
	                                Connection conn = null;
	                                ResultSet rsCategory1 = null;
	                                ResultSet rsProductCount = null;
	                                ResultSet rsCustState = null;
	                                PreparedStatement pstmtProductsCount = null;
	                                Statement statementProductCount = null;
	                                Statement statementCustStateCount = null;
	                                int productCount = -1;
	                                int custStateCount = -1;
	                                
	                                
	 		                    	try {					                
	 		                           // Registering Postgresql JDBC driver with the DriverManager
	 		                           Class.forName("org.postgresql.Driver");

	 		                           // Open a connection to the database using DriverManager
	 		                           conn = DriverManager.getConnection(
	 		                               "jdbc:postgresql://localhost/cse135_small?" +
	 		                               "user=postgres&password=postgres");
	 		                           
	 		                          Statement statement = conn.createStatement();
	 		                    %>
	 		                    
	 		                    <%
	 		                   		if(request.getParameter("custStateCount") == null ||request.getParameter("productCount") == null || request.getParameter("action") != null)
	 		                   		{
		 		                   		statementProductCount = conn.createStatement();
		 		                    
		 		           				String categoryProductCount;
		 		                    	if(request.getParameter("category") == null)
		 		                    	{
		 		                    		categoryProductCount = "";
		 		                    	}
		 		                    	else
		 		                    	{
		 		                    		categoryProductCount = request.getParameter("category");
		 		                    	}
		 		                    	
		 		                    	if(categoryProductCount.equals("allCategories") || categoryProductCount.equals(""))
		 		                    	{
		 		                  			pstmtProductsCount = conn.prepareStatement("select count(id) from products");
		 		                    	}
		 		                    	else
		 		                    	{
		 		                    		pstmtProductsCount = conn.prepareStatement("select count(id) from products where cid = ?");
		 		                    		pstmtProductsCount.setInt(1, Integer.parseInt(categoryProductCount));
		 		                    	}
		 		                    	rsProductCount = pstmtProductsCount.executeQuery();
			                    		rsProductCount.next();
			                    		productCount = rsProductCount.getInt("count");
			                    		application.setAttribute("productCount", productCount);
			                    		
			                    		statementCustStateCount = conn.createStatement();
			                    		
			                    		if(request.getParameter("action") != null)
			                    		{
			                    			if(((String)request.getParameter("filter1")).equals("States"))
			                    			{
			                    				custStateCount = 50;    				
			                    			}
			                    			else
			                    			{
					                    		rsCustState = statementCustStateCount.executeQuery("select count(id) from users");
					                    		rsCustState.next();
					                    		custStateCount = rsCustState.getInt("count");
			                    			}
			                    		}
			                    		else
			                    		{
			                    			rsCustState = statementCustStateCount.executeQuery("select count(id) from users");
				                    		rsCustState.next();
				                    		custStateCount = rsCustState.getInt("count");
			                    		}
			                    		application.setAttribute("custStateCount", custStateCount);		                
	 		                   		}
	 		                    %>
                                <table style="font-size: 12px;">
									<%
									if(request.getParameter("next10") ==null)
									{
									%>
									<h4> Options </h4>
            						<form action="analytics" method="GET">
            						<input type="hidden" value="0" name="productOffset"></input>
            						<input type="hidden" value="0" name="custStateOffset"></input>
            						<input type="hidden" value="search" name="action"></input>
		                            <tr>
						                <td>Customers or State:</td>
						                <td><select id="filter1" name="filter1">
						                		<option 
						                		<%
						                		if(request.getParameter("filter1") != null && request.getParameter("filter1").equals("Customers"))
						                		{
						                		%>
						                			selected="selected"
						                		<%
						                		}
						                		%>
						                		>Customers</option>
						                        <option
						                        <%
						                		if(request.getParameter("filter1") != null && request.getParameter("filter1").equals("States"))
						                		{
						                		%>
						                			selected="selected"
						                		<%
						                		}
						                		%>
						                        >States</option>
						                	</select>
						                </td>
		            				</tr>
		            				<tr>
		            					<td>Alphabetical or Top-K:</td>
		            					<td>
		            						<select id="filter2" name="filter2">
		            							<option
		            							<%
						                		if(request.getParameter("filter2") != null && request.getParameter("filter2").equals("Alphabetical"))
						                		{
						                		%>
						                			selected="selected"
						                		<%
						                		}
						                		%>>Alphabetical</option>
		            							<option
		            							<%
						                		if(request.getParameter("filter2") != null && request.getParameter("filter2").equals("Top-K"))
						                		{
						                		%>
						                			selected="selected"
						                		<%
						                		}
						                		%>
		            							>Top-K</option>
		            						</select>
		            					</td>
		            				</tr>
		            				<!-- Start of dropdown for categories -->
		            				<tr>
			            				<td>Category</td>
			            				<td>
			 					        	<select name="category">
			 					        		<% 
			 					                	statement = conn.createStatement();
		
				 		                    		rsCategory1 = statement.executeQuery("select categories.name, categories.id from categories");
												
												boolean isAllCategories = false;
														if(request.getParameter("category") != null && (request.getParameter("category").equals("allCategories")||request.getParameter("category").equals("")))
								                		{
															isAllCategories = true;
								                		}
												%>
												
												<option value="allCategories"
												<%
												if(isAllCategories)
												{
												%>
													selected="selected"
												<%
												}
												%>
												>All categories</option>
												<%
													while(rsCategory1.next()) {
												%>     	
				 					        		<option value="<%=rsCategory1.getInt("id")%>"
    								            <%
						                		if(!isAllCategories && request.getParameter("category") != null && Integer.parseInt(request.getParameter("category"))==(rsCategory1.getInt("id")))
						                		{
						                		%>
						                			selected="selected"
						                		<%
						                		}
						                		%>
				 					        		><%=rsCategory1.getString("name")%></option>
				 					        	<%
				 					        		} 
				 					        	%>
			 				        		</select>
		 				        		</td>
	            					<!-- End of dropdown -->
            					</tr>
            					<tr>
	        						<td><input type="submit" value="Run Query"></td>
            					</tr>
	        						</form>
	        					 <!-- closing bracket for if statement that checks if you clicked next 10 -->
	        					<%
									}
	        					%>
            					<%-- -------- Close Connection Code -------- --%>
					            <%
					                // Close the ResultSet
					                if(rsCategory1 != null) rsCategory1.close();
					            	if(rsProductCount != null) rsProductCount.close();
					
					                // Close the Statement
					                if(statement != null) statement.close();
					                if(statementProductCount != null) statementProductCount.close();
					
					                // Close the Connection
					                conn.close();
					            } catch (SQLException e) {
					            	
					                // Wrap the SQL exception in a runtime exception to propagate
					                // it upwards
					                
					                throw new RuntimeException(e);
					             
					            }%>
		            			</table>
		            			
		</div>
	</div>
</div>
