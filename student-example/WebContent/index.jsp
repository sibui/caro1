<%@ page contentType="text/html; charset=utf-8" language="java"%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<jsp:include page="/html/head.html" />
</head>
<body class="page-index" data-spy="scroll" data-offset="60" data-target="#toc-scroll-target">
	<%@page import="org.json.*"%> 
	<%-- Makes a log file when logging in. This log file contains a JSON array containing
	state, pid, cost, logNumber, and cid(category id). We created a log file to keep track
	of newly purchased items, in order for the changes to occur in the analytics.jsp page --%>
	<%
		if (application.getAttribute("log") == null) {
			JSONObject log = new JSONObject();
			JSONObject objElem = new JSONObject();
			JSONArray arr = new JSONArray();
			objElem.put("state", -1);
			objElem.put("pid", -1);
			objElem.put("cost", -1);
			objElem.put("logNumber", -1);
			objElem.put("cid", -1);
			arr.put(objElem);		
			log.put("log",arr);
			
			application.setAttribute("log", log); //Making the JSON object an application attribute
			application.setAttribute("logNumber", 0); //Keeps track of how many purchases were made
			application.setAttribute("fphTime", 0); //Refers to when the last time you updated fullproducthistory since the table does not update itself
			
			
		}
	%>
    <%
    	String name = null;
    	try {
    		name = request.getParameter("name");
    	} catch (Exception e) {
    		name = null;
    	}
    	if (name != null)
    		out.println(helpers.IndexHelper.login(name, session));
    %>
    <jsp:include page="/jsp/header.jsp" />
    <div class="container">
        <div class="row">
            <div class="span12">
                <div class="body-content">
                    <div class="section">
                        <div class="page-header">
                            <h4>Home</h4>
                        </div>
                        <div class="row">
                            <%
                            	if (session.getAttribute("name") != null) {
                            %>
                            <%
                            	if (((String)session.getAttribute("role")).equalsIgnoreCase("owner")) {
                            %>
                            <div class="container">
                            <jsp:include page="/jsp/owner-menu.jsp" />
                            </div>
                            <%
                            	} else {
                            %>
                            <div class="container">
                            <jsp:include page="/jsp/customer-menu.jsp" />
                            </div>
                            <%
                            	}
                            %>
                            <%
                            	} else {
                            %>
                            <div class="alert alert-info">
                                You need to be logged into see this page. Want to <a href="login">login</a> or <a href="signup">signup</a>?
                            </div>
                            <%
                            	}
                            %>
                        </div>
                        <jsp:include page="/html/footer.html" />
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
