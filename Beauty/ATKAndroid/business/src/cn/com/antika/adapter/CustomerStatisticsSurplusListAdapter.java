package cn.com.antika.adapter;

import android.annotation.SuppressLint;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.TextView;

import java.text.DecimalFormat;
import java.util.List;

import cn.com.antika.bean.CustomerStatisticsSurplus;
import cn.com.antika.business.CustomerStatisticsSurplusListActivity;
import cn.com.antika.business.R;

@SuppressLint("ResourceType")
public class CustomerStatisticsSurplusListAdapter extends BaseAdapter {
    private LayoutInflater layoutInflater;
    private Context mContext;
    private List<CustomerStatisticsSurplus> customerStatisticsSurplusList;
    private CustomerStatisticsSurplusListActivity.CustomerStatisticsListActivityHandler mHandler;
    private Integer mObjectType;
    DecimalFormat df = new DecimalFormat("0.00");

    public CustomerStatisticsSurplusListAdapter(Context context, List<CustomerStatisticsSurplus> customerStatisticsSurplusList, Integer objectType, CustomerStatisticsSurplusListActivity.CustomerStatisticsListActivityHandler mHandler) {
        this.mContext = context;
        this.customerStatisticsSurplusList = customerStatisticsSurplusList;
        this.layoutInflater = LayoutInflater.from(mContext);
        this.mObjectType = objectType;
        this.mHandler = mHandler;
    }

    @Override
    public int getCount() {
        // TODO Auto-generated method stub
        return customerStatisticsSurplusList.size();
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
    public View getView(final int position, View convertView, ViewGroup viewGroup) {
        // TODO Auto-generated method stub
        final CustomerStatisticsSurplus customerStatisticsSurplus = customerStatisticsSurplusList.get(position);
        CustomerStatisticsListItem csItem = null;
        if (convertView == null) {
            csItem = new CustomerStatisticsListItem();
            convertView = layoutInflater.inflate(R.xml.report_detail_surplus_list_item, null);
            csItem.productNo = convertView.findViewById(R.id.product_no);
            csItem.productName = convertView.findViewById(R.id.product_name);
            csItem.productSurplusNum = convertView.findViewById(R.id.product_surplus_num);
            csItem.productSurplusPrice = convertView.findViewById(R.id.product_surplus_price);
            convertView.setTag(csItem);
        } else {
            csItem = (CustomerStatisticsListItem) convertView.getTag();
        }
        // 序号
        csItem.productNo.setText(String.valueOf(position + 1));
        // 名称
        csItem.productName.setText(customerStatisticsSurplus.getProductName());
        // 未完成数|剩余数量
        switch (mObjectType) {
            case 0:
                // 服务
                switch (customerStatisticsSurplus.getProductServiceType()) {
                    case 1:
                        //时间卡
                        csItem.productSurplusNum.setText(customerStatisticsSurplus.getProductSurPlusNum() + "天");
                        break;
                    case 2:
                        //服务次数
                        csItem.productSurplusNum.setText(customerStatisticsSurplus.getProductSurPlusNum() + "次");
                        break;
                }
                break;
            case 1:
                // 商品
                csItem.productSurplusNum.setText(customerStatisticsSurplus.getProductSurPlusNum() + "件");
                break;
        }
        // 剩余金额
        csItem.productSurplusPrice.setText(df.format(customerStatisticsSurplus.getProductSurplusPrice()));
        csItem.productSurplusPrice.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mHandler.obtainMessage(101, customerStatisticsSurplus).sendToTarget();
            }
        });
        return convertView;
    }

    private final class CustomerStatisticsListItem {
        public TextView productNo;
        public TextView productName;
        public TextView productSurplusNum;
        public Button productSurplusPrice;
    }

    public void setmObjectType(Integer mObjectType) {
        this.mObjectType = mObjectType;
    }

}
