<%@ page import="org.json.*"%> 
<% response.setContentType("text/JSON"); %>

	<%
		//check if fphCurrent is not null
		if (request.getParameter("fphCurrent") != null) {
			//grab the current timestamps of application's precomputed table and YOUR precomputed table
			int fphCurrent =  Integer.parseInt(request.getParameter("fphCurrent"));
			int fphTime = (Integer) application.getAttribute("fphTime");
			
			//get the log
			JSONObject log = (JSONObject) application.getAttribute("log");
			
			//setting up the json objects 
			JSONObject changes = new JSONObject();
		    JSONArray logArray = log.getJSONArray("log");
			JSONObject stateElementObject = new JSONObject();
			JSONObject pidElementObject = new JSONObject();
			JSONObject statePidElementObject = new JSONObject();
			JSONObject returnMessage = new JSONObject();
			//grab timestamp of log
			int logNumber = (Integer)application.getAttribute("logNumber");
			
			//check if our table is outdated
			if(fphCurrent < logNumber)
			{
				//continue to add on to the json object if we are out of sync
				while (fphCurrent < logNumber) {
					//access the elements of one of our log entries
					JSONObject logObject = logArray.getJSONObject(fphCurrent+1);
			    	String state = logObject.get("state").toString();
			    	String pid = logObject.get("pid").toString();
			    	int cost = (Integer) logObject.get("cost");
					
			    	//take the elements of the log entry and place them into our json object
			    	//that will be sent back to list-analytics
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
				//update the timestamp of our table. at this point, we should be up-to-date
				session.setAttribute("fphCurrent",fphCurrent);
			}
			//jump here if our table is up-to-date
			else
			{
				changes.put("returnMessage", "doNothing");
			}
			changes.put("fphCurrent", fphCurrent);
			changes.put("fphTime",fphTime);
			//output the json object we created. it tells us which states, products, AND states+products
			//that need to be updated
			out.print(changes);
		}
	%>
