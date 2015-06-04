package helpers;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import javax.servlet.http.HttpSession;

import org.json.*;

public class PurchaseHelper {

    public static JSONObject purchaseCart(ShoppingCart cart, Integer uid) {
        Connection conn = null;
        Statement stmt = null;
        JSONObject returnResultJ = new JSONObject();
        JSONArray logArray = new JSONArray();
        JSONObject log = new JSONObject();
        JSONObject returnMessage = new JSONObject();
        String returnMsg = "";
        try {
            try {
                conn = HelperUtils.connect();
            } catch (Exception e) {
            	JSONObject error = new JSONObject();
            	returnMsg = HelperUtils.printError("Internal Server Error. This shouldn't happen.");
            	try {
					error.put("error", returnMsg);
				} catch (JSONException e1) {
					e1.printStackTrace();
				}
                return error;
            }
            stmt = conn.createStatement();
            for (int i = 0; i < cart.getProducts().size(); i++) {
                ProductWithCategoryName p = cart.getProducts().get(i);
                int quantity = cart.getQuantities().get(i);
                conn.setAutoCommit(false);
		
                String SQL_3 = "INSERT INTO sales (uid, pid, quantity, price) VALUES(" + uid + ",'"
                        + p.getId() + "','" + quantity + "', " + p.getPrice() + ");";
                stmt.execute(SQL_3);
                conn.commit();
                conn.setAutoCommit(true);

		try {
					log.put("pid", p.getId()); //puts the pid into the log JSONObject attribute
				} catch (JSONException e) {
					e.printStackTrace();
				}
                try {
					log.put("cost", p.getPrice()*quantity); //puts the total cost into the log JSONObject attribute
				} catch (JSONException e) {
					e.printStackTrace();
				}
		//puts the log JSONObject into the log JSONArray
                logArray.put(log);
                try {
                	//put logArray into the larger JSON Object
					returnResultJ.put("log",logArray);
				} catch (JSONException e) {
					e.printStackTrace();
				}
            }
            cart.empty();
            //put return message into JSON object
            returnMsg = HelperUtils.printSuccess("Purchase successful!");
            try {
				returnResultJ.put("returnMessage", returnMsg);
			} catch (JSONException e) {
				e.printStackTrace();
			}
            return returnResultJ;
        } catch (SQLException e) {
        	returnMsg = HelperUtils.printError("Oops! Looks like the product you want to buy is no longer available...");
        	try {
				returnResultJ.put("returnMessage", returnMsg);
			} catch (JSONException e2) {
				e2.printStackTrace();
			}
        	return returnResultJ;
        } finally {
            try {
                stmt.close();
                conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    public static ShoppingCart obtainCartFromSession(HttpSession session) {
        ShoppingCart cart;
        try {
            cart = (ShoppingCart) session.getAttribute("cart");
            if (cart == null) {
                cart = new ShoppingCart();
            }
        } catch (Exception e) {
            cart = new ShoppingCart();
        }
        session.setAttribute("cart", cart);
        return cart;
    }

}
