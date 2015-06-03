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
					// TODO Auto-generated catch block
					e1.printStackTrace();
				}
                return error;
            }
            stmt = conn.createStatement();
            for (int i = 0; i < cart.getProducts().size(); i++) {
                ProductWithCategoryName p = cart.getProducts().get(i);
                int quantity = cart.getQuantities().get(i);
                conn.setAutoCommit(false);
                String SQL_1 = "INSERT INTO cart_history (uid) VALUES (" + uid + ");";
                stmt.execute(SQL_1);
                // Gets latest inserted id. See this stackoverflow for more information http://stackoverflow.com/questions/2944297/postgresql-function-for-last-inserted-id
                String SQL_2 = "SELECT lastval();";
                ResultSet rs = stmt.executeQuery(SQL_2);
                rs.next();
                int cart_id = rs.getInt(1);
                String SQL_3 = "INSERT INTO sales (uid, pid, cart_id, quantity, price) VALUES(" + uid + ",'"
                        + p.getId() + "','" + cart_id + "','" + quantity + "', " + p.getPrice() + ");";
                try {
					log.put("pid", p.getId());
				} catch (JSONException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
                try {
					log.put("cost", p.getPrice()*quantity);
				} catch (JSONException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
                logArray.put(log);
                try {
                	//put logArray into the larger JSON Object
					returnResultJ.put("log",logArray);
				} catch (JSONException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
                stmt.execute(SQL_3);
                conn.commit();
                conn.setAutoCommit(true);
            }
            cart.empty();
            //put return message into JSON object
            returnMsg = HelperUtils.printSuccess("Purchase successful!");
            try {
				returnResultJ.put("returnMessage", returnMsg);
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
            //return HelperUtils.printSuccess("Purchase successful!");
            return returnResultJ;
        } catch (SQLException e) {
        	returnMsg = HelperUtils.printError("Oops! Looks like the product you want to buy is no longer available...");
        	try {
				returnResultJ.put("returnMessage", returnMsg);
			} catch (JSONException e2) {
				// TODO Auto-generated catch block
				e2.printStackTrace();
			}
            //return HelperUtils.printError("Oops! Looks like the product you want to buy is no longer available...");
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
