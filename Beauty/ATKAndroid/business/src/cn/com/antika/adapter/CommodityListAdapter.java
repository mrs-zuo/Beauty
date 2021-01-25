package cn.com.antika.adapter;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.graphics.Paint;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.TextView;

import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.CommodityInfo;
import cn.com.antika.bean.OrderInfo;
import cn.com.antika.bean.OrderProduct;
import cn.com.antika.business.R;
import cn.com.antika.constant.Constant;
import cn.com.antika.util.ImageLoaderUtil;
import cn.com.antika.util.NumberFormatUtil;
import cn.com.antika.view.menu.BusinessRightMenu;

@SuppressLint("ResourceType")
public class CommodityListAdapter extends BaseAdapter {
	private LayoutInflater layoutInflater;
	private List<CommodityInfo> commodityList;
	private ImageLoader imageLoader;
	private DisplayImageOptions displayImageOptions;
	private UserInfoApplication userInfoApplication;
	private Activity mActivity;
	private List<OrderProduct> orderProductList;
	private int authMyOrderWrite;
	private List<OrderProduct> selectedCommodityList;
	public CommodityListAdapter(Activity activity,
			List<CommodityInfo> commodityList) {
		this.mActivity = activity;
		this.commodityList = commodityList;
		layoutInflater = LayoutInflater.from(mActivity);
		imageLoader = ImageLoader.getInstance();
		displayImageOptions=ImageLoaderUtil.getDisplayImageOptions(R.drawable.goods_image_null);
		userInfoApplication = UserInfoApplication.getInstance();
		OrderInfo orderInfo = userInfoApplication.getOrderInfo();
		if (orderInfo == null)
			orderInfo = new OrderInfo();
		orderProductList = orderInfo.getOrderProductList();
		if (orderProductList == null)
			orderProductList = new ArrayList<OrderProduct>();
		userInfoApplication.setOrderInfo(orderInfo);
		userInfoApplication.getOrderInfo().setOrderProductList(orderProductList);
		if(selectedCommodityList==null){
			selectedCommodityList=new ArrayList<OrderProduct>();
			for(OrderProduct op:orderProductList){
				if(op.getProductType()==Constant.COMMODITY_TYPE)
					selectedCommodityList.add(op);
			}
		}
		authMyOrderWrite = userInfoApplication.getAccountInfo().getAuthMyOrderWrite();
	}

	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return commodityList.size();
	}

	@Override
	public Object getItem(int position) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public long getItemId(int position) {
		// TODO Auto-generated method stub
		return 0;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup viewGroup) {
		// TODO Auto-generated method stub
		CommodityItem commodityItem = null;
		final int pos = position;
		if (convertView == null) {
			commodityItem = new CommodityItem();
			convertView = layoutInflater.inflate(R.xml.commodity_list_item,
					null);
			commodityItem.commodityName = (TextView) convertView
					.findViewById(R.id.item_commodity_name);
			commodityItem.commodityPromotionPrice = (TextView) convertView
					.findViewById(R.id.commodity_promotion_price);
			commodityItem.commodityDiscountIcon = (ImageView) convertView
					.findViewById(R.id.commodity_discount_icon);
			commodityItem.commodityUnitPrice = (TextView) convertView
					.findViewById(R.id.commodity_unit_price);
			commodityItem.commodityThumbnail = (ImageView) convertView
					.findViewById(R.id.commodity_thumbnail);
			commodityItem.newCommodityIcon = (ImageView) convertView
					.findViewById(R.id.new_commodity_icon);
			commodityItem.recomendedIcon = (ImageView) convertView
					.findViewById(R.id.recommended_commodity_icon);
			commodityItem.commoditySelectCheckbox = (ImageButton) convertView
					.findViewById(R.id.product_select);
			commodityItem.favoriteIcon = (ImageView) convertView
					.findViewById(R.id.stored_icon);
			convertView.setTag(commodityItem);
		} else
			commodityItem = (CommodityItem) convertView.getTag();
		commodityItem.commodityName.setText((String) commodityList
				.get(position).getCommodityName()
				+ "\t"
				+ commodityList.get(position).getSpecification());
		// 设置收藏
		if (commodityList.get(position).getFavoriteID() > 0)
			commodityItem.favoriteIcon.setVisibility(View.VISIBLE);
		else
			commodityItem.favoriteIcon.setVisibility(View.GONE);
		double promotionPrice = Double.parseDouble(commodityList.get(position).getPromotionPrice());
		double unitPrice = Double.parseDouble(commodityList.get(position).getUnitPrice());
		commodityItem.commodityDiscountIcon.setVisibility(View.GONE);
		int marketingPolicy = commodityList.get(position).getMarketingPolicy();// 1：按等级打折、2：促销价
		// 按等级打折
		if (marketingPolicy == 1) {
			if (userInfoApplication.getSelectedCustomerID() != 0
					&& promotionPrice!= 0 && NumberFormatUtil.doubleCompare(unitPrice, promotionPrice)!=0) {
				commodityItem.commodityDiscountIcon.setBackgroundResource(R.drawable.discount);
				commodityItem.commodityDiscountIcon.setVisibility(View.VISIBLE);
				commodityItem.commodityPromotionPrice.setText(userInfoApplication.getAccountInfo().getCurrency()
								+ NumberFormatUtil.currencyFormat(String
										.valueOf(commodityList.get(position).getPromotionPrice())));
				commodityItem.commodityUnitPrice.setVisibility(View.VISIBLE);
				commodityItem.commodityUnitPrice.setText(NumberFormatUtil
						.currencyFormat(String.valueOf(unitPrice)));
				commodityItem.commodityUnitPrice.getPaint().setFlags(
						Paint.STRIKE_THRU_TEXT_FLAG);
			} else {
				commodityItem.commodityDiscountIcon.setVisibility(View.GONE);
				commodityItem.commodityUnitPrice.setVisibility(View.GONE);
				commodityItem.commodityPromotionPrice
						.setText(userInfoApplication.getAccountInfo()
								.getCurrency()
								+ NumberFormatUtil.currencyFormat(String
										.valueOf(unitPrice)));
			}
		}
		// 按促销价
		else if (marketingPolicy == 2) {
			if(NumberFormatUtil.doubleCompare(unitPrice, promotionPrice)!=0){
				commodityItem.commodityPromotionPrice.setText(userInfoApplication
						.getAccountInfo().getCurrency()
						+ NumberFormatUtil.currencyFormat(String
								.valueOf(promotionPrice)));
				commodityItem.commodityUnitPrice.setVisibility(View.VISIBLE);
				commodityItem.commodityUnitPrice.setText(NumberFormatUtil.currencyFormat(String.valueOf(unitPrice)));
				commodityItem.commodityUnitPrice.getPaint().setFlags(
						Paint.STRIKE_THRU_TEXT_FLAG);
				commodityItem.commodityDiscountIcon
						.setBackgroundResource(R.drawable.promotion);
				commodityItem.commodityDiscountIcon.setVisibility(View.VISIBLE);
			}
			else{
				commodityItem.commodityDiscountIcon.setVisibility(View.GONE);
				commodityItem.commodityUnitPrice.setVisibility(View.GONE);
				commodityItem.commodityPromotionPrice.setText(userInfoApplication.getAccountInfo().getCurrency()
								+ NumberFormatUtil.currencyFormat(String
										.valueOf(unitPrice)));
			}
			
		}
		// 无优惠政策
		else if (marketingPolicy == 0) {
			commodityItem.commodityDiscountIcon.setVisibility(View.GONE);
			commodityItem.commodityUnitPrice.setVisibility(View.GONE);
			commodityItem.commodityPromotionPrice
					.setText(userInfoApplication.getAccountInfo().getCurrency()
							+ NumberFormatUtil.currencyFormat(String
									.valueOf(unitPrice)));
		}
		String thumbnailUrl =commodityList.get(position).getThumbnailUrl();
		imageLoader.displayImage(thumbnailUrl,commodityItem.commodityThumbnail,displayImageOptions);
		if (!commodityList.get(position).getIsNew().equals("0"))
			commodityItem.newCommodityIcon.setVisibility(View.VISIBLE);
		else
			commodityItem.newCommodityIcon.setVisibility(View.GONE);
		if (!commodityList.get(position).getRecommended().equals("0"))
			commodityItem.recomendedIcon.setVisibility(View.VISIBLE);
		else
			commodityItem.recomendedIcon.setVisibility(View.GONE);
		if (userInfoApplication.getAccountInfo().getBranchId() == 0) {
			commodityItem.commoditySelectCheckbox.setVisibility(View.GONE);
		} else if (authMyOrderWrite== 0) {
			commodityItem.commoditySelectCheckbox.setVisibility(View.GONE);
		} else {
			commodityItem.commoditySelectCheckbox
					.setBackgroundResource(R.drawable.no_select_btn);
			int hasSelected = 0;
			for (OrderProduct op : orderProductList) {
				if (op.getProductID() == Integer.parseInt(commodityList.get(
						position).getCommodityID()) && op.getProductType() ==Constant.COMMODITY_TYPE) {
					commodityItem.commoditySelectCheckbox.setBackgroundResource(R.drawable.select_btn);
					hasSelected = 1;
				}
			}
			if(commodityList.get(position).getCommodityIsChecked()==1){
				commodityItem.commoditySelectCheckbox.setBackgroundResource(R.drawable.select_btn);
				hasSelected=1;
			}
			final int hs = hasSelected;
			commodityItem.commoditySelectCheckbox
					.setOnClickListener(new OnClickListener() {

						@Override
						public void onClick(View view) {
							// TODO Auto-generated method stub
							if (commodityList.get(pos).getCommodityIsChecked() == 1
									|| hs == 1) {
								view.setBackgroundResource(R.drawable.no_select_btn);
								commodityList.get(pos).setCommodityIsChecked(0);
								Iterator<OrderProduct> iterator = selectedCommodityList.iterator();
								while (iterator.hasNext()) {
									OrderProduct op = iterator.next();
									int productID = op.getProductID();
									int productType = op.getProductType();
									if (productID == Integer
											.parseInt(commodityList.get(pos)
													.getCommodityID())
											&& productType == Constant.COMMODITY_TYPE)
										iterator.remove();
								}
								Iterator<OrderProduct> orderProductIterator = orderProductList.iterator();
								while (orderProductIterator.hasNext()) {
									OrderProduct op = orderProductIterator.next();
									int productID = op.getProductID();
									int productType = op.getProductType();
									if (productID == Integer.parseInt(commodityList.get(pos).getCommodityID())&& productType == Constant.COMMODITY_TYPE)
										orderProductIterator.remove();
								}
							} else if (commodityList.get(pos)
									.getCommodityIsChecked() == 0 || hs == 0) {
								view.setBackgroundResource(R.drawable.select_btn);
								commodityList.get(pos).setCommodityIsChecked(1);
								OrderProduct orderProduct = new OrderProduct();
								orderProduct.setProductCode(commodityList.get(
										pos).getCommodityCode());
								orderProduct.setProductID(Integer
										.parseInt(commodityList.get(pos)
												.getCommodityID()));
								orderProduct.setProductName(commodityList.get(
										pos).getCommodityName());
								orderProduct.setQuantity(1);
								orderProduct.setProductType(1);
								orderProduct.setUnitPrice(commodityList
										.get(pos).getUnitPrice());
								orderProduct.setTotalPrice(String
										.valueOf(Double.valueOf(orderProduct
												.getUnitPrice())
												* orderProduct.getQuantity()));
								orderProduct.setMarketingPolicy(commodityList
										.get(pos).getMarketingPolicy());
								orderProduct.setPromotionPrice(commodityList
										.get(pos).getPromotionPrice());
								orderProduct.setResponsiblePersonID(userInfoApplication.getAccountInfo().getAccountId());
								orderProduct.setResponsiblePersonName(userInfoApplication.getAccountInfo().getAccountName());
								orderProduct.setSalesID(0);
								orderProduct.setSalesName("");
								orderProduct.setPast(false);//是否老订单转入
								selectedCommodityList.add(orderProduct);
							}
							CommodityListAdapter.this.notifyDataSetChanged();
							BusinessRightMenu.createMenuContent();
							BusinessRightMenu.rightMenuAdapter.notifyDataSetChanged();
						}
					});
		}
		return convertView;
	}
	public List<OrderProduct> getSelectedCommodityList(){
		return selectedCommodityList;
	}
	public final class CommodityItem {
		public ImageView commodityThumbnail;
		public TextView commodityName;
		public TextView commodityPromotionPrice;
		public TextView commodityUnitPrice;
		public ImageView newCommodityIcon;
		public ImageView recomendedIcon;
		public ImageView commodityPromotionIcon;
		public ImageView commodityDiscountIcon;
		public ImageView favoriteIcon;
		public ImageButton commoditySelectCheckbox;
	}

}
