package com.glamourpromise.beauty.customer.activity;
import java.util.ArrayList;
import java.util.List;
import org.json.JSONException;
import org.json.JSONObject;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ListView;
import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.adapter.RecordTemplateListAdapter;
import com.glamourpromise.beauty.customer.base.BaseActivity;
import com.glamourpromise.beauty.customer.bean.RecordInformation;
import com.glamourpromise.beauty.customer.bean.RecordTemplate;
import com.glamourpromise.beauty.customer.constant.Constant;
import com.glamourpromise.beauty.customer.net.IConnectTask;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.util.DialogUtil;
/*
 * 顾客咨询的模板列表
 * */
public class RecordTemplateListActivity extends BaseActivity implements OnItemClickListener,IConnectTask {
	private static final String CATEGORY_NAME = "Paper";
	private static final String GET_RECORD_TEMPLATE_LIST ="GetAnswerPaperList";
	private List<RecordTemplate> recordTemplateList;
	private ListView             recordTemplateListView;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		super.baseSetContentView(R.layout.activity_record_template_list);
		super.setTitle(getString(R.string.title_record_template_list));
		if (savedInstanceState == null) {
			initView();
		}
	}

	@Override
	protected void onResume() {
		super.onResume();
	}

	@Override
	protected void onNewIntent(Intent intent) {
		// TODO Auto-generated method stub
		super.onNewIntent(intent);
	}

	protected void initView() {
		recordTemplateList=new ArrayList<RecordTemplate>();
		recordTemplateListView=(ListView) findViewById(R.id.record_template_listview);
		recordTemplateListView.setOnItemClickListener(this);
		super.showProgressDialog();
		super.asyncRefrshView(this);
	}
	@Override
	public WebApiRequest getRequest() {
		// TODO Auto-generated method stub
		JSONObject getRecordTemplateListParam= new JSONObject();
		try {
			getRecordTemplateListParam.put("CustomerID",mCustomerID);
			getRecordTemplateListParam.put("FilterByTimeFlag",0);
			getRecordTemplateListParam.put("PageIndex",1);
			getRecordTemplateListParam.put("PageSize",9999);
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead(CATEGORY_NAME,GET_RECORD_TEMPLATE_LIST,getRecordTemplateListParam.toString());
		WebApiRequest request = new WebApiRequest(CATEGORY_NAME,GET_RECORD_TEMPLATE_LIST,getRecordTemplateListParam.toString(),header);
		return request;
	}

	@Override
	public void onHandleResponse(WebApiResponse response) {
		// TODO Auto-generated method stub
		super.dismissProgressDialog();
		if(response.getHttpCode() == 200){
			switch (response.getCode()) {
			case WebApiResponse.GET_WEB_DATA_TRUE:
				JSONObject responseJson=null;
				String  paperJsonArray=null;
				recordTemplateList.clear();
				try {
					responseJson=new JSONObject(response.getStringData());
				} catch (JSONException e) {
				}
				if(responseJson!=null){
					try {
						paperJsonArray=responseJson.getString("PaperList");
					} catch (JSONException e) {
					}
					if(paperJsonArray!=null && !paperJsonArray.equals("")){
						ArrayList<RecordTemplate> tempRecordTemplateList=RecordTemplate.parseListByJson(paperJsonArray);
						recordTemplateList.addAll(tempRecordTemplateList);
					}
				}
				recordTemplateListView.setAdapter(new RecordTemplateListAdapter(this,recordTemplateList));
				break;
			case WebApiResponse.GET_WEB_DATA_EXCEPTION:
				break;
			case WebApiResponse.GET_WEB_DATA_FALSE:
				DialogUtil.createShortDialog(getApplicationContext(),response.getMessage());
				break;
			case WebApiResponse.GET_DATA_NULL:
				break;
			case WebApiResponse.PARSING_ERROR:
				DialogUtil.createShortDialog(getApplicationContext(), Constant.NET_ERR_PROMPT);
				break;
			default:
				break;
			}    
		}
		
	}

	@Override
	public void parseData(WebApiResponse response) {
		// TODO Auto-generated method stub
		ArrayList<RecordInformation> RecordInformationList = RecordInformation.parseListByJson(response.getStringData());
		response.mData = RecordInformationList;
	}

	@Override
	public void onItemClick(AdapterView<?> parent, View view, int position,long id) {
		// TODO Auto-generated method stub
		Intent destIntent=new Intent(this,RecordListActivity.class);
		destIntent.putExtra("paperID",recordTemplateList.get(position).getRecordTemplateID());
		destIntent.putExtra("groupID",recordTemplateList.get(position).getGroupID());
		destIntent.putExtra("paperName",recordTemplateList.get(position).getRecordTemplateTitle());
		startActivity(destIntent);
	}
}
