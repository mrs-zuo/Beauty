package com.glamourpromise.beauty.customer.bean;
import java.io.Serializable;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.glamourpromise.beauty.customer.util.NumberFormatUtil;

public class CartInformation implements Serializable {

	private static final long serialVersionUID = 11L;
	private int branchID = 0;
	private String branchName = "";
	private String cartID;
	private String productCode;
	private String productID;
	private int    productType;//服务/商品类型
	private String productName;
	private int   quantity = 0;
	private double unitPrice = 0;
	private double promotionPrice = 0;
	private String commodityThumbnail = "";
	private String marketingPolicy;
	private Boolean availableFlag; // 可用标志
	private BigDecimal totalSalePrice;
	private BigDecimal totalPrice;
	// 作为CartListActivity, 每个section的add, delBtn
	private boolean addHandlerFlag = false;
	private boolean delHandlerFlag = false;
	private int     cardID;//购买时的该顾客的默认卡ID
	private String  cardName;//购买时的该顾客的默认卡名称
	private List<ECardInformation> ecardList;
	public CartInformation() {
		promotionPrice = 0;
		marketingPolicy = "0";
		availableFlag = false;
		totalSalePrice = new BigDecimal(0f);
	}

	public static ArrayList<CartInformation> parseListByJson(String src) {
		ArrayList<CartInformation> list = new ArrayList<CartInformation>();
		try {
			JSONArray jarrList = new JSONArray(src);
			int count = jarrList.length();
			CartInformation item;
			for (int i = 0; i < count; i++) {
				JSONObject branchJson=jarrList.getJSONObject(i);
				String branchName=branchJson.getString("BranchName");
				JSONArray cartJsonArray=branchJson.getJSONArray("CartDetailList");
				for(int j=0;j<cartJsonArray.length();j++){
					item = new CartInformation();
					item.parseByJson(cartJsonArray.getJSONObject(j),branchName);
					list.add(item);
				}
			}
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return list;
	}
	public boolean parseByJson(JSONObject src,String branchName) {
		try {
			JSONObject jsSrc = src;
			if (jsSrc.has("CartID")) {
				setCartID(jsSrc.getString("CartID"));
			}
			if (jsSrc.has("BranchID")) {
				setBranchID(jsSrc.getInt("BranchID"));
			}
			if (jsSrc.has("ProductCode")) {
				setProductCode(jsSrc.getString("ProductCode"));
			}
			if (jsSrc.has("ProductName")) {
				setProductName(jsSrc.getString("ProductName"));
			}
			if (jsSrc.has("Quantity")) {
				setQuantity(jsSrc.getInt("Quantity"));
			}
			if (jsSrc.has("UnitPrice")) {
				setUnity(Double.valueOf(jsSrc.getString("UnitPrice")));
			}
			if (jsSrc.has("ImageURL")) {
				setCommodityThumbnail(jsSrc.getString("ImageURL"));
			}
			if (jsSrc.has("Available")) {
				setAvailableFlag(jsSrc.getBoolean("Available"));
			}
			setBranchName(branchName);
			setTotalSalePrice();
			setTotalPrice();
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return false;
		}
		return true;
	}
	public static void refershCartList(List<CartInformation> oldCartList,JSONArray newCartJsonArray){
		for(int i=0;i<newCartJsonArray.length();i++){
			try {
				JSONObject cartJson=newCartJsonArray.getJSONObject(i);
				CartInformation cartInfo=oldCartList.get(i);
				if(cartJson.has("ID"))
					cartInfo.setProductID(cartJson.getString("ID"));
				if(cartJson.has("CartID"))
					cartInfo.setCartID(cartJson.getString("CartID"));
				if(cartJson.has("BranchID"))
					cartInfo.setBranchID(cartJson.getInt("BranchID"));
				if(cartJson.has("BranchName"))
					cartInfo.setBranchName(cartJson.getString("BranchName"));
				if(cartJson.has("Code"))
					cartInfo.setProductCode(cartJson.getString("Code"));
				if(cartJson.has("ProductType"))
					cartInfo.setProductType(cartJson.getInt("ProductType"));
				if(cartJson.has("Name"))
					cartInfo.setProductName(cartJson.getString("Name"));
				if (cartJson.has("UnitPrice")) {
					cartInfo.setUnity(Double.valueOf(cartJson.getString("UnitPrice")));
				}
				if (cartJson.has("MarketingPolicy")) {
					cartInfo.setMarketingPolicy(cartJson.getString("MarketingPolicy"));
				}
				if (cartJson.has("PromotionPrice")) {
					cartInfo.setPromotionPrice(Double.valueOf(cartJson.getString("PromotionPrice")));
				}
				if (cartJson.has("CardID")) {
					cartInfo.setCardID(cartJson.getInt("CardID"));
				}
				if (cartJson.has("CardName")) {
					cartInfo.setCardName(cartJson.getString("CardName"));
				}
				if (cartJson.has("Quantity")) {
					cartInfo.setQuantity(cartJson.getInt("Quantity"));
				}
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
	}
	public int getBranchID() {
		return branchID;
	}

	public void setBranchID(int branchID) {
		this.branchID = branchID;
	}

	public String getBranchName() {
		return branchName;
	}

	public void setBranchName(String branchName) {
		this.branchName = branchName;
	}


	public String getProductCode() {
		return productCode;
	}

	public void setProductCode(String productCode) {
		this.productCode = productCode;
	}


	public String getProductID() {
		return productID;
	}

	public void setProductID(String productID) {
		this.productID = productID;
	}

	public String getProductName() {
		return productName;
	}

	public void setProductName(String productName) {
		this.productName = productName;
	}

	public int getQuantity() {
		return quantity;
	}

	public void setQuantity(int quantity) {
		this.quantity = quantity;
		setTotalSalePrice();
		setTotalPrice();
	}

	public double getUnity() {
		return unitPrice;
	}

	public void setUnity(double unitPrice) {
		this.unitPrice = Double.valueOf(NumberFormatUtil.StringFormatToStringWithoutSingle(String.valueOf(unitPrice)));
	}

	public double getPromotionPrice() {
		return promotionPrice;
	}

	public void setPromotionPrice(double promotionPrice) {
		this.promotionPrice = Double.valueOf(NumberFormatUtil
				.StringFormatToStringWithoutSingle(String
						.valueOf(promotionPrice)));
	}

	public String getCommodityThumbnail() {
		return commodityThumbnail;
	}

	public void setCommodityThumbnail(String commodityThumbnail) {
		if (!commodityThumbnail.equals("null"))
			this.commodityThumbnail = commodityThumbnail;
	}

	public String getMarketingPolicy() {
		return marketingPolicy;
	}

	public void setMarketingPolicy(String marketingPolicy) {
		this.marketingPolicy = marketingPolicy;
	}

	public Boolean getAvailableFlag() {
		return availableFlag;
	}

	public void setAvailableFlag(boolean availableFlag) {
		this.availableFlag=availableFlag;
	}

	private void setTotalSalePrice() {
		totalSalePrice = new BigDecimal(1f);
		BigDecimal bdPrice;
		BigDecimal bdQuantity = new BigDecimal((float) quantity);
		if (marketingPolicy.equals("0")) {
			bdPrice = new BigDecimal(unitPrice);
		} else {
			bdPrice = new BigDecimal(promotionPrice);
		}
		totalSalePrice = totalSalePrice.multiply(bdPrice).multiply(bdQuantity);
	}

	public BigDecimal getTotalSalePrice() {
		return totalSalePrice;
	}

	public BigDecimal getTotalPrice() {
		return totalPrice;
	}

	public String getTotalPriceString() {
		return totalPrice.toString();
	}

	public void setTotalPrice() {
		totalPrice = new BigDecimal(1f);
		BigDecimal bdPrice = new BigDecimal(unitPrice);
		BigDecimal bdQuantity = new BigDecimal((float) quantity);
		totalPrice = totalPrice.multiply(bdPrice).multiply(bdQuantity);
	}

	public double getCommoditySectionPrice() {
		return unitPrice * quantity;
	}

	public double getCommoditySectionPromotionPrice() {
		return promotionPrice * quantity;
	}

	public void setAddBtnFlag(boolean addHandlerFlag) {
		this.addHandlerFlag = addHandlerFlag;
	}

	public void setDelBtnFlag(boolean delHandlerFlag) {
		this.delHandlerFlag = delHandlerFlag;
	}

	public boolean getAddBtnFlag() {
		return addHandlerFlag;
	}

	public boolean getDelBtnFlag() {
		return delHandlerFlag;
	}

	public int getProductType() {
		return productType;
	}

	public void setProductType(int productType) {
		this.productType = productType;
	}

	public String getCardName() {
		return cardName;
	}

	public void setCardName(String cardName) {
		this.cardName = cardName;
	}

	public String getCartID() {
		return cartID;
	}

	public void setCartID(String cartID) {
		this.cartID = cartID;
	}

	public int getCardID() {
		return cardID;
	}

	public void setCardID(int cardID) {
		this.cardID = cardID;
	}

	public List<ECardInformation> getEcardList() {
		return ecardList;
	}

	public void setEcardList(List<ECardInformation> ecardList) {
		this.ecardList = ecardList;
	}
}
