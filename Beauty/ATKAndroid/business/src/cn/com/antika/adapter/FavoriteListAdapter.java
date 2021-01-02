package cn.com.antika.adapter;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.content.DialogInterface;
import android.graphics.Paint;
import android.os.Handler;
import android.os.Message;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.TextView;

import org.json.JSONException;
import org.json.JSONObject;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;

import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.FavoriteInfo;
import cn.com.antika.bean.OrderInfo;
import cn.com.antika.bean.OrderProduct;
import cn.com.antika.business.R;
import cn.com.antika.util.DialogUtil;
import cn.com.antika.util.NumberFormatUtil;
import cn.com.antika.webservice.WebServiceUtil;

@SuppressLint("ResourceType")
public class FavoriteListAdapter extends BaseAdapter {
    private FavoriteListAdapterHandler adapterMhandler = new FavoriteListAdapterHandler(this);
    private Activity mContext;
    private LayoutInflater layoutInflater;
    private UserInfoApplication userInfoApplication;
    private List<FavoriteInfo> mFavoriteList;
    private int authMyOrderWrite;
    private List<OrderProduct> orderProductList;
    private Thread requestWebServiceThread;
    private int delFavoriteID;
    private int delPosition;
    // 待开产品
    private List<OrderProduct> selectedFavoriteList;
    // onClick 标志
    private boolean favoriteItemSelectCheckboxOnClickFlg;

    public FavoriteListAdapter(Activity context, List<FavoriteInfo> favoriteList) {
        this.favoriteItemSelectCheckboxOnClickFlg = false;
        mContext = context;
        mFavoriteList = favoriteList;
        layoutInflater = LayoutInflater.from(mContext);
        userInfoApplication = (UserInfoApplication) (mContext.getApplication());
        OrderInfo orderInfo = userInfoApplication.getOrderInfo();
        if (orderInfo == null)
            orderInfo = new OrderInfo();
        orderProductList = orderInfo.getOrderProductList();
        if (orderProductList == null)
            orderProductList = new ArrayList<OrderProduct>();
        userInfoApplication.setOrderInfo(orderInfo);
        userInfoApplication.getOrderInfo().setOrderProductList(orderProductList);
        authMyOrderWrite = userInfoApplication.getAccountInfo().getAuthMyOrderWrite();
        selectedFavoriteList = new ArrayList<OrderProduct>();
    }

    @Override
    public int getCount() {
        // TODO Auto-generated method stub
        return mFavoriteList.size();
    }

    @Override
    public Object getItem(int arg0) {
        // TODO Auto-generated method stub
        return null;
    }

    @Override
    public long getItemId(int arg0) {
        // TODO Auto-generated method stub
        return 0;
    }

    public void removeItem(int position) {
        mFavoriteList.remove(position);
        this.notifyDataSetChanged();
    }

    private static class FavoriteListAdapterHandler extends Handler {
        private final FavoriteListAdapter favoriteListAdapter;

        private FavoriteListAdapterHandler(FavoriteListAdapter activity) {
            WeakReference<FavoriteListAdapter> weakReference = new WeakReference<FavoriteListAdapter>(activity);
            favoriteListAdapter = weakReference.get();
        }

        @Override
        public void handleMessage(Message msg) {
            if (msg.what == 2)
                DialogUtil.createShortDialog(favoriteListAdapter.mContext, "您的网络貌似不给力，请检查网络设置");
            else if (msg.what == 3)
                DialogUtil.createShortDialog(favoriteListAdapter.mContext, msg.obj.toString());
            else if (msg.what == 4) {
                favoriteListAdapter.removeItem(favoriteListAdapter.delPosition);
                DialogUtil.createShortDialog(favoriteListAdapter.mContext, msg.obj.toString());
            }
            if (favoriteListAdapter.requestWebServiceThread != null) {
                favoriteListAdapter.requestWebServiceThread.interrupt();
                favoriteListAdapter.requestWebServiceThread = null;
            }
        }
    }

    @Override
    public View getView(int position, View convertView, ViewGroup viewGroup) {
        // TODO Auto-generated method stub
        FavoriteItem favoriteItem = null;
        if (convertView == null) {
            favoriteItem = new FavoriteItem();
            convertView = layoutInflater.inflate(R.xml.favorite_list_item, null);
            favoriteItem.productName = (TextView) convertView.findViewById(R.id.favorite_item_commodity_name);
            favoriteItem.promotionPrice = (TextView) convertView.findViewById(R.id.favorite_commodity_promotion_price);
            favoriteItem.unitPrice = (TextView) convertView.findViewById(R.id.favorite_commodity_unit_price);
            favoriteItem.discountIcon = (ImageView) convertView.findViewById(R.id.favorite_commodity_discount_icon);
            favoriteItem.selectCheckbox = (ImageButton) convertView.findViewById(R.id.favorite_product_select);
            favoriteItem.isLooseIcon = (ImageView) convertView.findViewById(R.id.favorite_lose_icon);
            convertView.setTag(favoriteItem);
        } else {
            favoriteItem = (FavoriteItem) convertView.getTag();
        }
        final int finalPosition = position;
        favoriteItem.productName.setText(mFavoriteList.get(position).getProductName() + "\t" + mFavoriteList.get(position).getSpecification());
        //收藏是否失效
        boolean isAvailable = mFavoriteList.get(position).isAvailable();
        if (!isAvailable)
            favoriteItem.isLooseIcon.setVisibility(View.VISIBLE);
        else
            favoriteItem.isLooseIcon.setVisibility(View.GONE);
        if (authMyOrderWrite == 0) {
            favoriteItem.selectCheckbox.setVisibility(View.GONE);
        } else {
            favoriteItem.selectCheckbox.setVisibility(View.VISIBLE);
            int hasSelected = 0;
            if (!favoriteItemSelectCheckboxOnClickFlg) {
                favoriteItem.selectCheckbox.setBackgroundResource(R.drawable.no_select_btn);
                mFavoriteList.get(position).setIsSelect(false);
                OrderProduct op = new OrderProduct();
                op.setProductID(Integer.parseInt(mFavoriteList.get(position).getProductID()));
                op.setProductType(mFavoriteList.get(position).getProductType());
                // 选中待开产品
                if (orderProductList.contains(op)) {
                    favoriteItem.selectCheckbox.setBackgroundResource(R.drawable.select_btn);
                    mFavoriteList.get(position).setIsSelect(true);
                    hasSelected = 1;
                }
            }
            /*if (mFavoriteList.get(position).getIsSelect()) {
                favoriteItem.selectCheckbox.setBackgroundResource(R.drawable.select_btn);
                hasSelected = 1;
            }*/
            final int hs = hasSelected;
            final String favoriteID = mFavoriteList.get(position).getFavoriteID();
            delFavoriteID = Integer.parseInt(favoriteID);
            favoriteItem.selectCheckbox.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View view) {
                    // TODO Auto-generated method stub
                    favoriteItemSelectCheckboxOnClickFlg = true;
                    if (mFavoriteList.get(finalPosition).isAvailable() == false) {
                        delPosition = finalPosition;
                        Dialog dialog = new AlertDialog.Builder(mContext,
                                R.style.CustomerAlertDialog)
                                .setTitle(mContext.getString(R.string.delete_dialog_title))
                                .setMessage(R.string.disable_service_or_commodity_delete_favorite_message)
                                .setPositiveButton(mContext.getString(R.string.delete_confirm),
                                        new DialogInterface.OnClickListener() {

                                            @Override
                                            public void onClick(DialogInterface dialog, int which) {
                                                dialog.dismiss();
                                                // TODO Auto-generated method stub
                                                requestWebServiceThread = new Thread() {
                                                    @Override
                                                    public void run() {

                                                        // TODO Auto-generated method stub
                                                        String methodName = "delFavorite";
                                                        String endPoint = "account";
                                                        JSONObject delFavoriteJsonParam = new JSONObject();
                                                        try {
                                                            delFavoriteJsonParam.put("FavoriteID", favoriteID);
                                                        } catch (JSONException e) {
                                                        }
                                                        String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, delFavoriteJsonParam.toString(), userInfoApplication);
                                                        if (serverRequestResult == null || serverRequestResult.equals(""))
                                                            adapterMhandler.sendEmptyMessage(2);
                                                        else {
                                                            int code = 0;
                                                            JSONObject delFavoriteJson = null;
                                                            try {
                                                                delFavoriteJson = new JSONObject(serverRequestResult);
                                                                code = delFavoriteJson.getInt("Code");
                                                            } catch (JSONException e) {
                                                            }
                                                            String returnMessage = "";
                                                            if (code == 1) {
                                                                try {
                                                                    returnMessage = delFavoriteJson.getString("Message");
                                                                } catch (JSONException e) {
                                                                    returnMessage = "";
                                                                }
                                                                adapterMhandler.obtainMessage(4, returnMessage).sendToTarget();
                                                            } else {
                                                                try {
                                                                    returnMessage = delFavoriteJson.getString("Message");
                                                                } catch (JSONException e) {
                                                                    returnMessage = "";
                                                                }
                                                                adapterMhandler.obtainMessage(3, returnMessage).sendToTarget();
                                                            }
                                                        }
                                                    }
                                                };
                                                requestWebServiceThread.start();
                                            }
                                        })
                                .setNegativeButton(mContext.getString(R.string.delete_cancel),
                                        new DialogInterface.OnClickListener() {
                                            @Override
                                            public void onClick(DialogInterface dialog, int which) {
                                                dialog.dismiss();
                                                dialog = null;
                                            }
                                        }).create();
                        dialog.show();
                        dialog.setCancelable(false);
                    } else {
                        if (mFavoriteList.get(finalPosition).getIsSelect() || hs == 1) {
                            view.setBackgroundResource(R.drawable.no_select_btn);
                            mFavoriteList.get(finalPosition).setIsSelect(false);
							/*Iterator<OrderProduct>  iterator=selectedFavoriteList.iterator();
							while(iterator.hasNext()){
								OrderProduct  op=iterator.next();
								int productID=op.getProductID();
								int productType=op.getProductType();
								if(productID==Integer.valueOf(mFavoriteList.get(finalPosition).getProductID()) && productType==mFavoriteList.get(finalPosition).getProductType())
									iterator.remove();
							}
							Iterator<OrderProduct>  orderProductIterator=orderProductList.iterator();
							while(orderProductIterator.hasNext()){
								OrderProduct  op=orderProductIterator.next();
								int productID=op.getProductID();
								int productType=op.getProductType();
								if(productID==Integer.valueOf(mFavoriteList.get(finalPosition).getProductID()) && productType==mFavoriteList.get(finalPosition).getProductType())
									orderProductIterator.remove();
							}*/
                        } else if (!mFavoriteList.get(finalPosition).getIsSelect() || hs == 0) {
                            view.setBackgroundResource(R.drawable.select_btn);
                            mFavoriteList.get(finalPosition).setIsSelect(true);
							/*OrderProduct orderProduct=new OrderProduct();
							orderProduct.setProductCode(Long.parseLong(mFavoriteList.get(finalPosition).getProductCode()));
							orderProduct.setProductID(Integer.valueOf(mFavoriteList.get(finalPosition).getProductID()));
							orderProduct.setProductName(mFavoriteList.get(finalPosition).getProductName());
							orderProduct.setProductType(Integer.valueOf(mFavoriteList.get(finalPosition).getProductType()));
							orderProduct.setQuantity(1);
							orderProduct.setUnitPrice(mFavoriteList.get(finalPosition).getUnitPrice());
							orderProduct.setTotalPrice(String.valueOf(Double.valueOf(orderProduct.getUnitPrice())*orderProduct.getQuantity()));
							orderProduct.setPromotionPrice(mFavoriteList.get(finalPosition).getPromotionPrice());
							orderProduct.setMarketingPolicy(Integer.valueOf(mFavoriteList.get(finalPosition).getMarketingPolicy()));
							orderProduct.setResponsiblePersonID(userInfoApplication.getAccountInfo().getAccountId());
							orderProduct.setResponsiblePersonName(userInfoApplication.getAccountInfo().getAccountName());
							orderProduct.setSalesID(0);
							orderProduct.setSalesName("");
							orderProduct.setPast(false);//是否老订单转入
							selectedFavoriteList.add(orderProduct);*/
                        }
                        FavoriteListAdapter.this.notifyDataSetChanged();
                    }
                }
            });
        }

        //设置价格
        int marketingPolicy = mFavoriteList.get(position).getMarketingPolicy();
        double promotionPrice = Double.parseDouble(mFavoriteList.get(position).getPromotionPrice());
        double unitPrice = Double.parseDouble(mFavoriteList.get(position).getUnitPrice());
        //1：按等级打折、
        if (marketingPolicy == 1) {
            if (userInfoApplication.getSelectedCustomerID() != 0 && promotionPrice != 0 && promotionPrice != unitPrice) {
                favoriteItem.discountIcon.setBackgroundResource(R.drawable.discount);
                favoriteItem.discountIcon.setVisibility(View.VISIBLE);
                favoriteItem.unitPrice.setVisibility(View.VISIBLE);
                favoriteItem.promotionPrice.setText(userInfoApplication.getAccountInfo().getCurrency() + NumberFormatUtil.currencyFormat(String.valueOf(promotionPrice)));
                favoriteItem.unitPrice.setText(NumberFormatUtil.currencyFormat(String.valueOf(unitPrice)));
                favoriteItem.unitPrice.getPaint().setFlags(Paint.STRIKE_THRU_TEXT_FLAG);
            } else {
                favoriteItem.discountIcon.setVisibility(View.GONE);
                favoriteItem.unitPrice.setVisibility(View.GONE);
                favoriteItem.promotionPrice.setText(userInfoApplication.getAccountInfo().getCurrency()
                        + NumberFormatUtil.currencyFormat(String
                        .valueOf(unitPrice)));
            }
        }
        //2：促销价
        else if (marketingPolicy == 2) {
            if (promotionPrice != unitPrice) {
                favoriteItem.promotionPrice.setText(userInfoApplication.getAccountInfo().getCurrency()
                        + NumberFormatUtil.currencyFormat(String
                        .valueOf(promotionPrice)));
                favoriteItem.unitPrice.setVisibility(View.VISIBLE);
                favoriteItem.unitPrice.setText(NumberFormatUtil.currencyFormat(String.valueOf(unitPrice)));
                favoriteItem.unitPrice.getPaint().setFlags(Paint.STRIKE_THRU_TEXT_FLAG);
                favoriteItem.discountIcon.setBackgroundResource(R.drawable.promotion);
                favoriteItem.discountIcon.setVisibility(View.VISIBLE);
            } else {
                favoriteItem.discountIcon.setVisibility(View.GONE);
                favoriteItem.unitPrice.setVisibility(View.GONE);
                favoriteItem.promotionPrice.setText(userInfoApplication.getAccountInfo().getCurrency() + NumberFormatUtil.currencyFormat(String.valueOf(unitPrice)));
            }
        }
        //无优惠政策
        else if (marketingPolicy == 0) {
            favoriteItem.discountIcon.setVisibility(View.GONE);
            favoriteItem.unitPrice.setVisibility(View.GONE);
            favoriteItem.promotionPrice.setText(userInfoApplication.getAccountInfo().getCurrency()
                    + NumberFormatUtil.currencyFormat(String
                    .valueOf(unitPrice)));
        }

        return convertView;
    }

    public interface IListItemClick {
        public void itemClick(int position, Boolean isSelect);
    }

    public List<OrderProduct> getSelectedFavoriteList() {
        if (selectedFavoriteList != null) {
            selectedFavoriteList.clear();
        } else {
            selectedFavoriteList = new ArrayList<OrderProduct>();
        }
        if (mFavoriteList != null) {
            for (FavoriteInfo favoriteInfo : mFavoriteList) {
                if (favoriteInfo.getIsSelect()) {
                    OrderProduct orderProduct = new OrderProduct();
                    orderProduct.setProductCode(Long.parseLong(favoriteInfo.getProductCode()));
                    orderProduct.setProductID(Integer.valueOf(favoriteInfo.getProductID()));
                    orderProduct.setProductName(favoriteInfo.getProductName());
                    orderProduct.setProductType(Integer.valueOf(favoriteInfo.getProductType()));
                    orderProduct.setQuantity(1);
                    orderProduct.setUnitPrice(favoriteInfo.getUnitPrice());
                    orderProduct.setTotalPrice(String.valueOf(Double.valueOf(orderProduct.getUnitPrice()) * orderProduct.getQuantity()));
                    orderProduct.setPromotionPrice(favoriteInfo.getPromotionPrice());
                    orderProduct.setMarketingPolicy(Integer.valueOf(favoriteInfo.getMarketingPolicy()));
                    orderProduct.setResponsiblePersonID(userInfoApplication.getAccountInfo().getAccountId());
                    orderProduct.setResponsiblePersonName(userInfoApplication.getAccountInfo().getAccountName());
                    orderProduct.setSalesID(0);
                    orderProduct.setSalesName("");
                    orderProduct.setPast(false);//是否老订单转入

                    selectedFavoriteList.add(orderProduct);
                }
            }
        }
        return selectedFavoriteList;
    }

    public final class FavoriteItem {
        public TextView productName;
        public TextView unitPrice;
        public TextView promotionPrice;
        public ImageView discountIcon;
        public ImageView favoriteIcon;
        public ImageButton selectCheckbox;
        public ImageView isLooseIcon;
    }


}
