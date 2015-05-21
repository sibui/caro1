<%@ page contentType="text/html; charset=utf-8" language="java"%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<jsp:include page="/html/head.html" />
</head>
<%
    boolean nameNotNull = session.getAttribute("name") != null;
    String role = (String) session.getAttribute("role");
    boolean roleIsOwner = (role != null) ? role
            .equalsIgnoreCase("owner") : false;
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
                                %>
                                <%@ page import="java.sql.*"%>
                                <%-- -------- Open Connection Code -------- --%>
           						<%
	                                Connection conn = null;
	                                ResultSet rsCategory1 = null;
	 		                    	
	 		                    	try {
	 		                           // Registering Postgresql JDBC driver with the DriverManager
	 		                           Class.forName("org.postgresql.Driver");

	 		                           // Open a connection to the database using DriverManager
	 		                           conn = DriverManager.getConnection(
	 		                               "jdbc:postgresql://localhost/cse135?" +
	 		                               "user=postgres&password=postgres");
	 		                           
	 		                        
	 		                    %>
                                <table>
		                            <tr>
						                <td>Customers or State:</td>
						                <td><select id="filter1" name="filter1">
						                		<option selected="selected">Customers</option>
						                        <option>Alabama</option>
						                        <option>Alaska</option>
						                        <option>Arizona</option>
						                        <option>Arkansas</option>
						                        <option>California</option>
						                        <option>Colorado</option>
						                        <option>Connecticut</option>
						                        <option>Delaware</option>
						                        <option>Florida</option>
						                        <option>Georgia</option>
						                        <option>Hawaii</option>
						                        <option>Idaho</option>
						                        <option>Illinois</option>
						                        <option>Indiana</option>
						                        <option>Iowa</option>
						                        <option>Kansas</option>
						                        <option>Kentucky</option>
						                        <option>Louisiana</option>
						                        <option>Maine</option>
						                        <option>Maryland</option>
						                        <option>Massachusetts</option>
						                        <option>Michigan</option>
						                        <option>Minnesota</option>
						                        <option>Mississippi</option>
						                        <option>Missouri</option>
						                        <option>Montana</option>
						                        <option>Nebraska</option>
						                        <option>Nevada</option>
						                        <option>New Hampshire</option>
						                        <option>New Jersey</option>
						                        <option>New Mexico</option>
						                        <option>New York</option>
						                        <option>North Carolina</option>
						                        <option>North Dakota</option>
						                        <option>Ohio</option>
						                        <option>Oklahoma</option>
						                        <option>Oregon</option>
						                        <option>Pennsylvania</option>
						                        <option>Rhode Island</option>
						                        <option>South Carolina</option>
						                        <option>South Dakota</option>
						                        <option>Tennessee</option>
						                        <option>Texas</option>
						                        <option>Utah</option>
						                        <option>Vermont</option>
						                        <option>Virginia</option>
						                        <option>Washington</option>
						                        <option>West Virginia</option>
						                        <option>Wisconsin</option>
						                        <option>Wyoming</option>
						                	</select>
						                </td>
		            				</tr>
		            				<tr>
		            					<td>Alphabetical or Top-K:</td>
		            					<td>
		            						<select id="filter2" name="filter2">
		            							<option>Alphabetical</option>
		            							<option>Top-K</option>
		            						</select>
		            					</td>
		            				</tr>
		            				<!-- Start of dropdown for categories -->
		            				<tr>
			            				<td>Category</td>
			            				<td>
			 					        	<select name="category">
			 					        		<% 
			 					                	Statement statement = conn.createStatement();
		
				 		                    		rsCategory1 = statement.executeQuery("select categories.name, categories.id from categories");
				 		                    		rsCategory1.next();
												
													while(rsCategory1.next()) {			   
												%>     	
				 					        		<option value="<%=rsCategory1.getInt("id")%>"><%=rsCategory1.getString("name")%></option>
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
            					<%-- -------- Close Connection Code -------- --%>
					            <%
					                // Close the ResultSet
					                rsCategory1.close();
					
					                // Close the Statement
					                statement.close();
					
					                // Close the Connection
					                conn.close();
					            } catch (SQLException e) {
					            	
					                // Wrap the SQL exception in a runtime exception to propagate
					                // it upwards
					                
					                //throw new RuntimeException(e);
					                
					            	String redirectURL = "unsuccessful.html";
					                response.sendRedirect(redirectURL);
					            }%>
		            			</table>
		            			
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
