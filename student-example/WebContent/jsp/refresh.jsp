<%@ page import="org.json.*"%> 
<% response.setContentType("text/JSON"); %>

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
			JSONObject returnMessage = new JSONObject();
			int logNumber = (Integer)application.getAttribute("logNumber");
			
			if(fphCurrent != logNumber)
			{	
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
				    	changes.putOnce("returnMessage", "successful");
				    } catch (JSONException e){}
			    	fphCurrent++;
				}
			}
			else
			{
				changes.put("returnMessage", "doNothing");
			}
			out.print(changes);
		}
	%>
