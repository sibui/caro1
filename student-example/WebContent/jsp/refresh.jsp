<%@ page contentType="text/html; charset=utf-8" language="java" import="helpers.*"%>
<%@page import="org.json.*"%> 
<% response.setContentType("text/JSON"); %>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<jsp:include page="/html/head.html" />
</head>
<body>
	<%
		if (request.getParameter("fphCurrent") != null) {
			int fphCurrent = Integer.parseInt(request.getParameter("fphCurrent"));
			int fphTime = (Integer) application.getAttribute("fphTime");
			JSONObject log = (JSONObject) application.getAttribute("log");
			JSONObject changes = new JSONObject();
		    JSONArray logArray = log.getJSONArray("log");
			JSONObject stateElementObject = new JSONObject();
			JSONObject pidElementObject = new JSONObject();
			JSONObject statePidElementObject = new JSONObject();
			int logNumber = (Integer)application.getAttribute("logNumber");

			while (fphCurrent < logNumber) {
				JSONObject logObject = logArray.getJSONObject(fphCurrent+1);
		    	String state = logObject.get("state").toString();
		    	String pid = logObject.get("pid").toString();
		    	int cost = (Integer) logObject.get("cost");
				
		    	JSONObject element = new JSONObject();
		    	element.put("cost", cost);
		    	stateElementObject.append(state, element);
		    	pidElementObject.append(pid,element);
		    	statePidElementObject.append(state+"|"+pid, element);
		    	try {
			    	changes.putOnce("state", stateElementObject);
			    	changes.putOnce("pid", pidElementObject);
			    	changes.putOnce("statepid", statePidElementObject);
			    } catch (JSONException e){}
		    	
		    	fphCurrent++;
			}
			out.print(changes);
		}
	%>
</body>