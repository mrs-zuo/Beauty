package com.glamourpromise.beauty.customer.adapter;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Set;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.bean.BranchCartInfo;
import com.glamourpromise.beauty.customer.bean.CartInformation;
import com.glamourpromise.beauty.customer.util.NumberFormatUtil;
import com.squareup.picasso.Picasso;

public class CartListAdapter extends BaseAdapter {

	private LayoutInflater layoutInflater;
	private Activity mContext;
	private List<CartInformation> cartList;
	//每个商品选择状态列表
	private List<Boolean> isSelected;
	private ListItemClick callback;
	//当前已经选择的数量
	private int currentSelectCount;
	//所有可用商品的数量
	private int availableCartListCount;
	private String tmpDiscountPrice;
	private String tmpUnitPrice;
	private int currentBranchID;
	private String branchName;
	private HashMap<Integer, BranchCartInfo> branchCartInfoList;
	
	@SuppressLint("UseSparseArrays")
	public CartListAdapter(Activity context, List<CartInformation> cartList, ListItemClick callback, HashMap<Integer, BranchCartInfo> branchCartInfoList) {
		this.mContext = context;
		this.cartList = cartList;
		this.callback = callback;
		if(branchCartInfoList == null)
			this.branchCartInfoList = new HashMap<Integer, BranchCartInfo>();
		else
			this.branchCartInfoList = branchCartInfoList;
		currentSelectCount = 0;
		availableCartListCount = 0;
		layoutInflater = LayoutInflater.from(mContext);
		isSelected = new ArrayList<Boolean>();		
		//循环设置选择状态和可用数量
		for (int i = 0; i < cartList.size(); i++){
			isSelected.add(i, false);
			if(cartList.get(i).getAvailableFlag())
				availableCartListCount++;
		}
	}

	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return cartList.size();
	}

	@Override
	public Object getItem(int position) {
		// TODO Auto-generated method stub
		return cartList.get(position);
	}

	@Override
	public long getItemId(int position) {
		// TODO Auto-generated method stub
		return position;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup viewGroup) {
		// TODO Auto-generated method stub
		CartItem cartItem = null;
		if (convertView == null) {
			cartItem = new CartItem();
			convertView = layoutInflater.inflate(R.xml.cart_list_item, null);
			cartItem.commodityName = (TextView) convertView.findViewById(R.id.commodity_name);
			cartItem.commodityCount = (EditText) convertView.findViewById(R.id.edit_commodity_count);
			cartItem.commodityTotalSalePrice = (TextView) convertView.findViewById(R.id.commodity_total_sale_price);
			cartItem.commodityTotalPrice = (TextView) convertView.findViewById(R.id.commodity_total_price);
			cartItem.commodityThumbnail = (ImageView) convertView.findViewById(R.id.commodity_thumbnail);
			cartItem.offShelfFlagView = (ImageView) convertView.findViewById(R.id.offShelf_flag);
			cartItem.selectView = (ImageButton) convertView.findViewById(R.id.commodity_item_select);
			
			//表头，每一个分店第一个商品显示，其余不显示
			cartItem.headerLayout = (RelativeLayout) convertView.findViewById(R.id.header_layout);
			cartItem.headerView = (TextView) convertView.findViewById(R.id.header_textview);
			cartItem.branchCartSelectButton = (ImageButton) convertView.findViewById(R.id.branch_commodity_item_select_all);
			convertView.setTag(cartItem);
		} else {
			cartItem = (CartItem) convertView.getTag();
		}
		
		final int finalPos = position;
		//表头，每一个分店第一个商品显示，其余不显示
		currentBranchID = ((CartInformation)getItem(position)).getBranchID();
		branchName = ((CartInformation)getItem(position)).getBranchName();
		
		if(position == 0 || ((CartInformation)getItem(position-1)).getBranchID() != currentBranchID){
			cartItem.headerLayout.setVisibility(View.VISIBLE);
			cartItem.headerView.setText(branchName);
			BranchCartInfo currentBranchInfo = branchCartInfoList.get(currentBranchID);
			if(currentBranchInfo.getIsSelect()){
				cartItem.branchCartSelectButton.setBackgroundResource(R.drawable.one_select_icon);
			}else{
				cartItem.branchCartSelectButton.setBackgroundResource(R.drawable.one_unselect_icon);
			}
			cartItem.branchCartSelectButton.setOnClickListener(new OnClickListener() {
				
				@Override
				public void onClick(View v) {
					// TODO Auto-generated method stub
					selectAllBranchCartItem(finalPos, v);
				}
			});
			//当仅剩失效商品时，隐藏全选按钮
			if(currentBranchInfo.getAvailableSize() == 0){
				cartItem.branchCartSelectButton.setVisibility(View.INVISIBLE);
			}else{
				cartItem.branchCartSelectButton.setVisibility(View.VISIBLE);
			}
		}else{
			cartItem.headerLayout.setVisibility(View.GONE);
		}
		cartItem.commodityName.setText((String) cartList.get(position).getProductName());
		cartItem.commodityCount.setText(String.valueOf(cartList.get(position).getQuantity()));
		//设置每个Item选中状态
		if(isSelected.get(position) && cartList.get(position).getAvailableFlag())
			cartItem.selectView.setBackgroundResource(R.drawable.one_select_icon);
		else
			cartItem.selectView.setBackgroundResource(R.drawable.one_unselect_icon);
		
		//设置点击事件:选择事件、修改商品数量事件
		/*选择事件
		 * 购物车没有失效才可以点击
		*/
		if(cartList.get(position).getAvailableFlag()){
			cartItem.selectView.setOnClickListener(new OnClickListener() {
				
				@Override
				public void onClick(View view) {
					// TODO Auto-generated method stub
					BranchCartInfo branchCart = branchCartInfoList.get(cartList.get(finalPos).getBranchID());
					if(isSelected.get(finalPos)){
						currentSelectCount--;
						branchCart.subCurrentSelectSize();;
						isSelected.set(finalPos, false);
						view.setBackgroundResource(R.drawable.one_unselect_icon);
					}
					else{
						currentSelectCount++;
						branchCart.addCurrentSelectSize();
						isSelected.set(finalPos, true);
						view.setBackgroundResource(R.drawable.one_select_icon);
					}
					if(branchCart.getCurrentSelectSize() == branchCart.getAvailableSize()){
						branchCart.setIsSelect(true);
					}else{
						branchCart.setIsSelect(false);
					}
					CartListAdapter.this.notifyDataSetChanged();
					
					callback.allCommoditySelectProcess(currentSelectCount);
					//修改价格
					callback.onClick(view, finalPos);
				}
			});
		}
		
		//修改数量时间
		cartItem.commodityCount.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View view) {
				callback.onClick(view, finalPos);
			}
		});
		

		tmpDiscountPrice = NumberFormatUtil.FloatFormatToStringWithoutSingle(cartList.get(position).getTotalSalePrice().doubleValue());
		tmpUnitPrice = NumberFormatUtil.FloatFormatToStringWithoutSingle(cartList.get(position).getTotalPrice().doubleValue());
		if(tmpDiscountPrice.equals("0.00") || (tmpDiscountPrice.equals(tmpUnitPrice))){
			//没有折扣
			cartItem.commodityTotalPrice.setVisibility(View.GONE);
			cartItem.commodityTotalSalePrice.setText(NumberFormatUtil.StringFormatToString(mContext, tmpUnitPrice));
		}else{
			//有折扣
			cartItem.commodityTotalPrice.setVisibility(View.VISIBLE);
			cartItem.commodityTotalPrice.setText(tmpUnitPrice);
			cartItem.commodityTotalSalePrice.setText(NumberFormatUtil.StringFormatToString(mContext, tmpDiscountPrice));
		}

		//购物车可用
		if(cartList.get(position).getAvailableFlag()){
			cartItem.offShelfFlagView.setVisibility(View.GONE);
			cartItem.selectView.setVisibility(View.VISIBLE);
		}else{
			cartItem.offShelfFlagView.setVisibility(View.VISIBLE);
			cartItem.selectView.setVisibility(View.GONE);
		}

		if (!cartList.get(position).getCommodityThumbnail().equals(""))
			Picasso.with(mContext).load(cartList.get(position).getCommodityThumbnail()).error(R.drawable.commodity_image_null).into(cartItem.commodityThumbnail);
		else
			cartItem.commodityThumbnail.setImageResource(R.drawable.commodity_image_null);

		return convertView;
	}
	
	/**
	 * 
	 */
	private void selectAllBranchCartItem(int position, View branchSelectView){
		int branchID = cartList.get(position).getBranchID();
		BranchCartInfo branchCartInfo = branchCartInfoList.get(branchID);
		
		CartInformation cartInfo;
		BigDecimal price = new BigDecimal(0);
		Boolean isSelect = branchCartInfo.getIsSelect();
		int size = branchCartInfo.getSize();
		int pos = position;
		int maxPos = position+size;
		Boolean available;
		for(int i = position; i < maxPos; i++){
			cartInfo = cartList.get(pos);
			pos += 1;
			available = cartList.get(i).getAvailableFlag();
			if(!available){
				continue;
			}
			//该分店的购物车已选择
			if(isSelect){
				if(isSelected.get(i) && available){
					currentSelectCount--;
					branchCartInfo.subCurrentSelectSize();
					isSelected.set(i, false);
					price = price.subtract(cartInfo.getTotalSalePrice());
					branchCartInfo.setIsSelect(false);
				}
				
				branchSelectView.setBackgroundResource(R.drawable.all_unselect_icon);
			}
			else{
				if(!isSelected.get(i) && available){
					currentSelectCount++;
					branchCartInfo.addCurrentSelectSize();
					isSelected.set(i, true);
					price = price.add(cartInfo.getTotalSalePrice());
					branchCartInfo.setIsSelect(true);
				}
				
				branchSelectView.setBackgroundResource(R.drawable.all_select_icon);
			}
			
		}
		CartListAdapter.this.notifyDataSetChanged();
		callback.branchCartSelect(price.doubleValue());
		callback.allCommoditySelectProcess(currentSelectCount);
	}
	
	public void setBranchCartInfoList(
			HashMap<Integer, BranchCartInfo> branchCartInfoList) {
		this.branchCartInfoList = branchCartInfoList;
	}

	public List<Boolean> getIsSelected() {
		return isSelected;
	}

	public void setIsSelected(List<Boolean> isSelected) {
		this.isSelected = isSelected;
	}

	public void changeCommodityCount(int position, int count) {
		cartList.get(position).setQuantity(count);
	}
	
	public void setCurrentSelectCount(){
		this.currentSelectCount = 0;
		//循环设置选择状态和可用数量
		availableCartListCount = 0;
		for (int i = 0; i < cartList.size(); i++) {
			if (cartList.get(i).getAvailableFlag())
				availableCartListCount++;
		}
	}
	
	public int getCurrentSelectCount(){
		return currentSelectCount;
	}
	
	public void setAllItemSelectStatus(Boolean status){
		if(isSelected != null && isSelected.size() > 0)
		{
			for(int i =0; i < isSelected.size(); i++){
				if(cartList.get(i).getAvailableFlag())
					isSelected.set(i, status);
			}	
		}
		Set<Integer> branchIDSet = branchCartInfoList.keySet();
		BranchCartInfo tmp;
		for(int branchID:branchIDSet){
			tmp = branchCartInfoList.get(branchID);
			tmp.setIsSelect(status);
			if(status){
				tmp.setCurrentSelectSize(tmp.getSize());
			}else{
				tmp.setCurrentSelectSize(0);
			}
		}
		
		if(status){
//			currentSelectCount = isSelected.size();
			currentSelectCount = availableCartListCount;
		}
		else
			currentSelectCount = 0;
	}
	
	public int getAvailableCartListCount(){
		return availableCartListCount;
	}
	
	public interface ListItemClick {
		void onClick(View clickView, int position);
		void allCommoditySelectProcess(int currentSelectCount);
		void branchCartSelect(double branchCartTotalPrice);
	}

	public final class CartItem {
		public ImageView commodityThumbnail;
		public ImageView offShelfFlagView;
		public TextView commodityName;
		public EditText commodityCount;
		public TextView commodityTotalSalePrice;
		public TextView commodityTotalPrice;
		public ImageButton selectView;
		public TextView headerView;
		public RelativeLayout headerLayout;
		public ImageButton branchCartSelectButton;
	}

}