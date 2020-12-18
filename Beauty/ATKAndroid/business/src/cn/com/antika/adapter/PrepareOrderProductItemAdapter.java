package cn.com.antika.adapter;

import android.annotation.SuppressLint;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageButton;
import android.widget.TextView;

import java.util.List;

import cn.com.antika.bean.OrderProduct;
import cn.com.antika.business.R;
import cn.com.antika.util.NumberFormatUtil;

@SuppressLint("ResourceType")
public class PrepareOrderProductItemAdapter extends BaseAdapter {
	private LayoutInflater layoutInflater;
	private Context context;
	private List<OrderProduct> orderProductList;
	private int orderProductQuantity;
	public PrepareOrderProductItemAdapter(Context context,
			List<OrderProduct> orderProductList) {
		this.context = context;
		layoutInflater = (LayoutInflater) this.context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		this.orderProductList = orderProductList;
	}
	@Override
	public int getCount() {
		return orderProductList.size();
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
		PrepareOrderProductItem prepareOrderProductItem = null;
		if (convertView == null) {
			prepareOrderProductItem = new PrepareOrderProductItem();
			convertView = layoutInflater.inflate(
					R.xml.prepare_order_product_list_item, null);
			prepareOrderProductItem.prepareOrderProductNameText = (TextView) convertView
					.findViewById(R.id.prepare_order_product_name);
			prepareOrderProductItem.prepareOrderProductQuantityText = (TextView) convertView
					.findViewById(R.id.prepare_order_product_quantity);
			prepareOrderProductItem.prepareOrderProductTotalPriceText = (TextView) convertView
					.findViewById(R.id.prepare_order_product_total_price);
			prepareOrderProductItem.prepareOrderProductPromotionPriceText = (TextView) convertView
					.findViewById(R.id.prepare_order_product_total_sale_price);
			prepareOrderProductItem.prepareOrderPlusProductQuantityButton=(ImageButton)convertView.findViewById(R.id.prepare_order_plus_quantity_btn);
			prepareOrderProductItem.prepareOrderReduceProductQuantityButton=(ImageButton)convertView.findViewById(R.id.prepare_order_reduce_quantity_btn);
			final PrepareOrderProductItem pot=prepareOrderProductItem;
			prepareOrderProductItem.prepareOrderPlusProductQuantityButton.setOnClickListener(new OnClickListener() {
				@Override
				public void onClick(View view) {
					// TODO Auto-generated method stub
					orderProductQuantity+=1;
					pot.prepareOrderProductQuantityText.setText(String.valueOf(orderProductQuantity));
				}
			});
			prepareOrderProductItem.prepareOrderReduceProductQuantityButton.setOnClickListener(new OnClickListener() {
				@Override
				public void onClick(View view) {
					// TODO Auto-generated method stub
					if(orderProductQuantity>1)
						orderProductQuantity-=1;
					else 
						orderProductQuantity=1;
					pot.prepareOrderProductQuantityText.setText(String.valueOf(orderProductQuantity));
				}
			});
			convertView.setTag(prepareOrderProductItem);
		} else {
			prepareOrderProductItem = (PrepareOrderProductItem) convertView
					.getTag();
		}
		prepareOrderProductItem.prepareOrderProductNameText
				.setText(orderProductList.get(position).getProductName());
		prepareOrderProductItem.prepareOrderProductQuantityText.setText(String
				.valueOf(orderProductList.get(position).getQuantity()));
		prepareOrderProductItem.prepareOrderProductTotalPriceText.setText(NumberFormatUtil.currencyFormat(orderProductList.get(position).getUnitPrice()));
		if (Double.parseDouble(orderProductList.get(position).getPromotionPrice())!= 0)
			prepareOrderProductItem.prepareOrderProductPromotionPriceText.setText(NumberFormatUtil.currencyFormat(orderProductList.get(position).getPromotionPrice()));
		else
			prepareOrderProductItem.prepareOrderProductPromotionPriceText.setText(NumberFormatUtil.currencyFormat("0"));
		orderProductQuantity=Integer.parseInt(prepareOrderProductItem.prepareOrderProductQuantityText.getText().toString());
		return convertView;
	}

	public final class PrepareOrderProductItem {
		public TextView prepareOrderProductNameText;
		public TextView prepareOrderProductQuantityText;
		public TextView prepareOrderProductTotalPriceText;
		public TextView prepareOrderProductPromotionPriceText;
		public ImageButton prepareOrderPlusProductQuantityButton;
		public ImageButton prepareOrderReduceProductQuantityButton;
	}
}
