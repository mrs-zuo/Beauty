package com.glamourpromise.beauty.customer.activity;
import org.json.JSONException;
import org.json.JSONObject;
import android.content.Intent;
import android.os.Bundle;
import android.text.SpannableString;
import android.text.Spanned;
import android.text.method.LinkMovementMethod;
import android.text.style.ClickableSpan;
import android.text.util.Linkify;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TableLayout;
import android.widget.TableRow.LayoutParams;
import android.widget.TextView;
import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.base.BaseActivity;
import com.glamourpromise.beauty.customer.bean.AccountInformation;
import com.glamourpromise.beauty.customer.constant.Constant;
import com.glamourpromise.beauty.customer.net.IConnectTask;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.util.DialogUtil;
import com.glamourpromise.beauty.customer.util.HSClickSpan;
import com.squareup.picasso.Picasso;
public class AccountDetailActivity extends BaseActivity implements OnClickListener, IConnectTask {
	private static final String CATEGORY_NAME = "account";
	private static final String GET_ACCOUNT_DETAIL = "getAccountDetail";
	private String accountID = "0";
	private String accountName = "";
	private String department = "";
	private String title = "";
	private String introduction = "";
	private String expert = "";
	private String mobile = "";
	private String headImageURL = "";
	private String branchName = "";
	private LayoutInflater mLayoutInflater;
	private TextView  accountNameTextView;
	private ImageView accountHeadImage;
	private ImageView sendMessageButton;
	private AccountInformation accountInfo;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		super.baseSetContentView(R.layout.activity_account_detail);
		super.setTitle(getString(R.string.title_account_detail));
		Intent intent = getIntent();
		accountID = intent.getStringExtra("AccountID");
		initView();
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

	private void initView() {
		accountInfo = new AccountInformation();
		accountNameTextView = (TextView) findViewById(R.id.account_name);
		accountHeadImage = (ImageView) findViewById(R.id.account_headimage);
		sendMessageButton = (ImageView) findViewById(R.id.send_message_button);
		sendMessageButton.setOnClickListener(this);
		mLayoutInflater = getLayoutInflater();
		super.showProgressDialog();
		super.asyncRefrshView(this);
	}

	private void setFlyMessageStatus(int flyMessageAuthority){
		//有发飞语的权限
		if(flyMessageAuthority == 1){
			sendMessageButton.setVisibility(View.VISIBLE);
		}else{
			sendMessageButton.setVisibility(View.GONE);
		}
	}

	private void createMobileTableRow() {
		TableLayout tableLayoutPhone = (TableLayout) findViewById(R.id.account_phone);
		if (!mobile.equals("")) {
			createTableLayout(tableLayoutPhone, 2, getString(R.string.phone),mobile,2);
		} else {
			tableLayoutPhone.setVisibility(View.GONE);
		}
	}

	private void createTitleAndDepartment() {
		TableLayout tableLayout = (TableLayout) findViewById(R.id.account_title_and_department);
		if (title.equals("") && department.equals("")) {
			tableLayout.setVisibility(View.GONE);
		}
		if (!title.equals("")) {
			createTableLayout(tableLayout, 2, getString(R.string.title),title,0);
		}
		if (!department.equals("")) {
			tableLayout.addView(mLayoutInflater.inflate(R.xml.shape_straight_line,null),new TableLayout.LayoutParams(LayoutParams.MATCH_PARENT, 1));
			createTableLayout(tableLayout, 2, getString(R.string.department),department,0);
		}
	}
	private void createBranchName() {
		TableLayout tableLayout = (TableLayout) findViewById(R.id.account_branch_name);
		if (!branchName.equals("")) {
			createTableLayout(tableLayout, 1, getString(R.string.branch),branchName,0);
		} else {
			tableLayout.setVisibility(View.GONE);
		}
	}

	private void createExpertTableRow() {
		TableLayout tableLayout = (TableLayout) findViewById(R.id.account_expert);
		if (!expert.equals("")) {
			createTableLayout(tableLayout, 1, getString(R.string.expert),expert,0);
		} else {
			tableLayout.setVisibility(View.GONE);
		}
	}

	private void createIntroductionTableRow() {
		TableLayout tableLayout = (TableLayout) findViewById(R.id.account_introduction);
		if (!introduction.equals("")) {
			createTableLayout(tableLayout, 1,getString(R.string.introduction),introduction,0);
		} else {
			tableLayout.setVisibility(View.GONE);
		}
	}

	private void createTableLayout(TableLayout tableLayout, int flag,String title, String content,int linkFlag) {
		// 一行显示一个textview
		TextView contentTextView = null;
		if (flag == 1) {
			RelativeLayout titleLayout = (RelativeLayout) mLayoutInflater.inflate(R.xml.relativelayout_has_one_child_view, null);
			RelativeLayout contentLayout = (RelativeLayout) mLayoutInflater.inflate(R.xml.relativelayout_has_one_child_content_view, null);
			TextView titleTextView = (TextView) titleLayout.findViewById(R.id.left_textview);
			titleTextView.setText(title);
			titleTextView.setTextColor(this.getResources().getColor(R.color.text_color));
			contentTextView = (TextView) contentLayout.findViewById(R.id.content_textview);
			SpannableString spannableString=new SpannableString(content);
			if(linkFlag==1){
				ClickableSpan clickSpan=new HSClickSpan(contentTextView,this,1);
				spannableString.setSpan(clickSpan,0,content.length(),Spanned.SPAN_INCLUSIVE_EXCLUSIVE);
				contentTextView.setAutoLinkMask(Linkify.WEB_URLS);
			}
			else if(linkFlag==2){
				ClickableSpan clickSpan=new HSClickSpan(contentTextView,this,2);
				spannableString.setSpan(clickSpan,0,content.length(),Spanned.SPAN_INCLUSIVE_EXCLUSIVE);
				contentTextView.setAutoLinkMask(Linkify.PHONE_NUMBERS);
			}
			if(linkFlag!=0){
				contentTextView.setMovementMethod(LinkMovementMethod.getInstance());
				contentTextView.setText(spannableString);
			}
			else{
				contentTextView.setText(content);
			}

			tableLayout.addView(titleLayout);
			tableLayout.addView(mLayoutInflater.inflate(R.xml.shape_straight_line, null),new TableLayout.LayoutParams(LayoutParams.MATCH_PARENT, 1));
			tableLayout.addView(contentLayout);
		} else if (flag == 2) {
			RelativeLayout Layout = (RelativeLayout) mLayoutInflater.inflate(R.xml.relativelayout_has_two_child_view, null);
			TextView titleTextView = (TextView) Layout.findViewById(R.id.left_textview);
			titleTextView.setText(title);
			titleTextView.setTextColor(this.getResources().getColor(R.color.text_color));
			contentTextView = (TextView) Layout.findViewById(R.id.right_textview);
			SpannableString spannableString=new SpannableString(content);
			if(linkFlag==1){
				ClickableSpan clickSpan=new HSClickSpan(contentTextView,this,1);
				spannableString.setSpan(clickSpan,0,content.length(),Spanned.SPAN_INCLUSIVE_EXCLUSIVE);
				contentTextView.setAutoLinkMask(Linkify.WEB_URLS);
			}
			else if(linkFlag==2){
				ClickableSpan clickSpan=new HSClickSpan(contentTextView,this,2);
				spannableString.setSpan(clickSpan,0,content.length(),Spanned.SPAN_INCLUSIVE_EXCLUSIVE);
				contentTextView.setAutoLinkMask(Linkify.PHONE_NUMBERS);
			}
			if(linkFlag!=0){
				contentTextView.setMovementMethod(LinkMovementMethod.getInstance());
				contentTextView.setText(spannableString);
			}
			else{
				contentTextView.setText(content);
			}
			tableLayout.addView(Layout);
		}
	}

	@Override
	public void onClick(View view) {
		super.onClick(view);
		switch (view.getId()) {
		case R.id.send_message_button:
			Intent destIntent = new Intent(this, ChatMessageListActivity.class);
			destIntent.putExtra("AccountID", accountID);
			destIntent.putExtra("thumbnailImageURL",headImageURL);
			destIntent.putExtra("AccountName",accountName);
			startActivity(destIntent);
			break;
		default:
			break;
		}
	}
	@Override
	public WebApiRequest getRequest() {
		JSONObject para = new JSONObject();
		try {
			para.put("AccountID", accountID);
			if (mApp.getScreenWidth() == 720) {
				para.put("ImageWidth", String.valueOf(150));
				para.put("ImageHeight", String.valueOf(150));
			} else if (mApp.getScreenWidth() == 480) {
				para.put("ImageWidth", String.valueOf(132));
				para.put("ImageHeight", String.valueOf(132));
			} else if (mApp.getScreenWidth() == 1080) {
				para.put("ImageWidth", String.valueOf(300));
				para.put("ImageHeight", String.valueOf(300));
			} else if (mApp.getScreenWidth() == 1536) {
				para.put("ImageWidth", String.valueOf(366));
				para.put("ImageHeight", String.valueOf(366));
			} else {
				para.put("ImageWidth", String.valueOf(150));
				para.put("ImageHeight", String.valueOf(150));
			}
		} catch (JSONException e) {
			e.printStackTrace();
		}
		WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead(CATEGORY_NAME, GET_ACCOUNT_DETAIL, para.toString());
		WebApiRequest request = new WebApiRequest(CATEGORY_NAME, GET_ACCOUNT_DETAIL, para.toString(), header);
		return request;
	}


	@Override
	public void onHandleResponse(WebApiResponse response) {
		super.dismissProgressDialog();
		if(response.getHttpCode() == 200){
			switch (response.getCode()) {
			case WebApiResponse.GET_WEB_DATA_TRUE:
				if(headImageURL.equals("") || headImageURL.equals("null")){
					Picasso.with(getApplicationContext()).load(R.drawable.head_image_null_big).into(accountHeadImage);
				}else{
					Picasso.with(getApplicationContext()).load(headImageURL).error(R.drawable.head_image_null_big).into(accountHeadImage);
				}
				if (accountName.equals("anyType{}") || accountName.equals("")) {
					accountNameTextView.setText("无");
				} else {
					accountNameTextView.setText(accountName);
				}
				setFlyMessageStatus(accountInfo.getFlyMessageAuthority());
				createMobileTableRow();
				createTitleAndDepartment();
				createExpertTableRow();
				createBranchName();
				createIntroductionTableRow();
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
		if(response.getHttpCode() == 200 && response.getCode() == WebApiResponse.GET_WEB_DATA_TRUE){
			try {
				JSONObject result = new JSONObject(response.getStringData());
				if (result.has("Name")) {
					accountName = result.getString("Name").toString();
				}
				if (result.has("Department")) {
					department = result.getString("Department").toString();
				}
				if (result.has("Title")) {
					title = result.getString("Title").toString();
				}
				if (result.has("Introduction")) {
					introduction = result.getString("Introduction").toString();
				}
				if (result.has("Expert")) {
					expert = result.getString("Expert").toString();
				}
				if (result.has("Mobile")) {
					mobile = result.getString("Mobile").toString();
				}
				if (result.has("HeadImageURL")) {
					headImageURL = result.getString("HeadImageURL");
				}
				if (result.has("BranchName")) {
					branchName = result.getString("BranchName");
				}
				if(result.has("Chat_Use")){
					accountInfo.setFlyMessageAuthority(result.getBoolean("Chat_Use"));
				}
			} catch (JSONException e) {
				e.printStackTrace();
			}
		}
	}
}
