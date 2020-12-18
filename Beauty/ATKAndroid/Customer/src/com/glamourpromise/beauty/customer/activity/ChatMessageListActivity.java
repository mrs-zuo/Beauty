package com.glamourpromise.beauty.customer.activity;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.os.Handler;
import android.support.v4.view.ViewPager;
import android.support.v4.view.ViewPager.OnPageChangeListener;
import android.text.SpannableString;
import android.text.TextUtils;
import android.util.SparseArray;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.view.View.OnClickListener;
import android.view.ViewGroup.LayoutParams;
import android.view.inputmethod.InputMethodManager;
import android.view.Window;
import android.widget.AdapterView;
import android.widget.Button;
import android.widget.EditText;
import android.widget.GridView;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.AdapterView.OnItemClickListener;

import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.adapter.ChatListAdapter;
import com.glamourpromise.beauty.customer.adapter.FaceAdapter;
import com.glamourpromise.beauty.customer.adapter.ViewPagerAdapter;
import com.glamourpromise.beauty.customer.base.BaseActivity;
import com.glamourpromise.beauty.customer.bean.ChatEmoji;
import com.glamourpromise.beauty.customer.bean.ChatMessageInformation;
import com.glamourpromise.beauty.customer.bean.NewMessageInformation;
import com.glamourpromise.beauty.customer.broadcastreceiver.NewMessageRecevice;
import com.glamourpromise.beauty.customer.custom.view.NewRefreshListView;
import com.glamourpromise.beauty.customer.custom.view.NewRefreshListView.OnRefreshListener;
import com.glamourpromise.beauty.customer.task.GetHistoryMessageTask;
import com.glamourpromise.beauty.customer.task.GetHistoryMessageTask.HistoryMessageCallback;
import com.glamourpromise.beauty.customer.task.GetNewMessageTask;
import com.glamourpromise.beauty.customer.util.DialogUtil;
import com.glamourpromise.beauty.customer.util.FaceConversionUtil;
import com.glamourpromise.beauty.customer.util.SendMessageTread;

public class ChatMessageListActivity extends BaseActivity implements OnClickListener,OnItemClickListener {
	public static final String NEW_MESSAGE_BROADCAST_ACTION = "newChatMesage";
	public static final String NOT_FLY_MESSAGE_AUTHORITY = "该用户没有飞语权限！";
	//JPush
	public static boolean isForeground = false;

	private List<ChatMessageInformation> chatMessageList;
	private SparseArray<ChatMessageInformation> newChatMessageList;
	private NewRefreshListView messageListView;
	private Button sendButton;
	private EditText messageEditText;
	private ChatListAdapter chatListAdapter;
	private int flyMessageAuthority;
	private String thereUserID;
	private String thumbnailImageURL;
	private String hereUserThumbnailImageURL;
	private NewMessageRecevice messageRecevice;
	private IntentFilter filter;
	private SendMessageTread<Integer> mSendMessageTread;
	private RelativeLayout    expressionRelativelayout;
	private ViewPager         expressionViewPager;
	//表情数据结合
	private List<List<ChatEmoji>> emojis;
	//每一页的表情数据填充器
	private List<FaceAdapter> faceAdapters;
	//表情页界面集合
	private ArrayList<View>   pageViews;
	//当前表情页
	private int current = 0;
	/** 游标显示布局 */
	private LinearLayout layoutPoint;

	/** 游标点集合 */
	private ArrayList<ImageView> pointViews;
	private OnCorpusSelectedListener mListener;
	private ImageButton  flyMessageExpressionIcon;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		super.baseSetContentView(R.layout.activity_chat_list);
		super.setTitle("飞语");
		// 获取参数
		Intent intent = getIntent();
		thereUserID = intent.getStringExtra("AccountID");// 聊天对象的ID
		thumbnailImageURL = intent.getStringExtra("thumbnailImageURL");// 聊天对象的头像
		flyMessageAuthority = intent.getIntExtra("flyMessageAuthority",1);	
		hereUserThumbnailImageURL = mLogInInfo.getHeadImageURL();
		chatMessageList = new ArrayList<ChatMessageInformation>();
		newChatMessageList = new SparseArray<ChatMessageInformation>(5);
		messageListView = (NewRefreshListView) findViewById(R.id.chat_listview);
		sendButton = (Button)findViewById(R.id.chat_message_send_button);
		sendButton.setOnClickListener(this);
		messageEditText = (EditText) findViewById(R.id.sendmessage_edit);
		messageEditText.setOnClickListener(this);
		flyMessageExpressionIcon=(ImageButton)findViewById(R.id.fly_message_expression_icon);
		flyMessageExpressionIcon.setOnClickListener(this);
		expressionViewPager=(ViewPager)findViewById(R.id.fly_message_expression_viewpager);
		expressionRelativelayout=(RelativeLayout)findViewById(R.id.fly_message_expression_relativelayout);
		TextView thereName = (TextView) findViewById(R.id.there_name);
		thereName.setText(intent.getStringExtra("AccountName"));
		// 设置下拉刷新取历史消息时的回掉函数
		messageListView.setonRefreshListener(new OnRefreshListener() {
			@Override
			public void onRefresh() {
				if (chatMessageList.size() == 0) {
					DialogUtil.createShortDialog(ChatMessageListActivity.this,"没有更早的消息了");
					messageListView.onRefreshComplete();
				} else{
					String oldestMessageID = chatMessageList.get(0).getMessageID();
					getHistoryMessage(oldestMessageID);
				}
			}
		});
		FaceConversionUtil.getInstace().getFileText(getApplication());
		emojis = FaceConversionUtil.getInstace().emojiLists;
		layoutPoint=(LinearLayout)findViewById(R.id.fly_message_expression_point);
		initExpressionViewPager();
		initPoint();
		initExpressionData();
		// 发送消息的线程
		createSendThread();
		loadHistoryMessage();
	}
	
	@Override
	protected void onResume() {
		super.onResume();
		isForeground = true;
		// 注册监听新消息的广播
		if(messageRecevice == null){
			messageRecevice = new NewMessageRecevice(new NewMessageRecevice.ReceiveCallback() {
				
				@Override
				public void onReceive() {
					GetNewMessageTask getHistoryMsg = createLoadNewMessageTask();
					ChatMessageListActivity.super.asyncRefrshView(getHistoryMsg);
				}
			});
		}
		if(filter == null){
			filter = new IntentFilter();
			filter.addAction(NEW_MESSAGE_BROADCAST_ACTION);
		}
		this.registerReceiver(messageRecevice, filter);
	}
	private void initExpressionViewPager() {
		pageViews = new ArrayList<View>();
		// 中间添加表情页
		faceAdapters = new ArrayList<FaceAdapter>();
		for (int i = 0; i < emojis.size(); i++) {
			GridView view = new GridView(this);
			FaceAdapter adapter = new FaceAdapter(this,emojis.get(i));
			view.setAdapter(adapter);
			faceAdapters.add(adapter);
			view.setOnItemClickListener(this);
			view.setNumColumns(7);
			view.setBackgroundColor(Color.TRANSPARENT);
			view.setHorizontalSpacing(1);
			view.setVerticalSpacing(1);
			view.setStretchMode(GridView.STRETCH_COLUMN_WIDTH);
			view.setCacheColorHint(0);
			view.setPadding(5, 0, 5, 0);
			view.setSelector(new ColorDrawable(Color.TRANSPARENT));
			view.setLayoutParams(new LayoutParams(LayoutParams.MATCH_PARENT,LayoutParams.WRAP_CONTENT));
			view.setGravity(Gravity.CENTER);
			pageViews.add(view);
		}
	}
	//表情滑动视图添加数据
	private void initExpressionData() {
		expressionViewPager.setAdapter(new ViewPagerAdapter(pageViews));
		expressionViewPager.setCurrentItem(0);
		current = 0;
		expressionViewPager.setOnPageChangeListener(new OnPageChangeListener() {
			
			@Override
			public void onPageSelected(int viewPagerPosition) {
				drawPoint(viewPagerPosition);
				current = viewPagerPosition;
			}

			@Override
			public void onPageScrolled(int arg0, float arg1, int arg2) {

			}

			@Override
			public void onPageScrollStateChanged(int arg0) {

			}
		});

	}
	/**
	 * 初始化游标
	 */
	private void initPoint() {
		pointViews = new ArrayList<ImageView>();
		ImageView imageView;
		for (int i = 0; i < emojis.size(); i++) {
			imageView = new ImageView(this);
			imageView.setBackgroundResource(R.drawable.d1);
			LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams(new ViewGroup.LayoutParams(LayoutParams.WRAP_CONTENT,LayoutParams.WRAP_CONTENT));
			layoutParams.leftMargin = 10;
			layoutParams.rightMargin = 10;
			layoutParams.width = 8;
			layoutParams.height = 8;
			layoutPoint.addView(imageView, layoutParams);
			pointViews.add(imageView);
		}
	}
	/*
	 * 绘制当前是处于第几页
	 * */
	public void drawPoint(int index) {
		for (int i = 0; i < pointViews.size(); i++) {
			if (index == i) {
				pointViews.get(i).setBackgroundResource(R.drawable.d2);
			} else {
				pointViews.get(i).setBackgroundResource(R.drawable.d1);
			}
		}
	}
	public void setOnCorpusSelectedListener(OnCorpusSelectedListener listener) {
		mListener = listener;
	}
	/**
	 * 表情选择监听
	 */
	public interface OnCorpusSelectedListener {
		void onCorpusSelected(ChatEmoji emoji);
		void onCorpusDeleted();
	}
	@Override
	protected void onPause() {
		super.onPause();
		unregisterReceiver(messageRecevice);
		//取消发送线程
		if(mSendMessageTread != null){
			mSendMessageTread.setListener(null);
			mSendMessageTread.quit();
		}
		mSendMessageTread = null;
		isForeground = false;
	}

	/**
	 * 创建发送消息的线程
	 */
	private void createSendThread() {
		mSendMessageTread = new SendMessageTread<Integer>(new Handler(), mApp, getApplicationContext(), mApp.getHttpClient());
		mSendMessageTread.setListener(new SendMessageTread.Listener<Integer>() {

			public void onMessageSended(Integer position, int sendReturnFlag, int messageID) {
				ChatMessageInformation newChatMessage = newChatMessageList.get(position);
				// 发送成功
				if (sendReturnFlag == 1) {					
					newChatMessage.setIsSendSuccess("1");
					newChatMessage.setIsNewMessage("0");
					newChatMessage.setMessageID(String.valueOf(messageID));
				}
				// 发送失败
				else {
					newChatMessage.setIsSendSuccess("0");
					newChatMessage.setIsNewMessage("0");
				}
				chatListAdapter.notifyDataSetChanged();
				messageListView.setSelection(messageListView.getAdapter().getCount() - 1);
			}

			@Override
			public void onHttpError(int httpCode, int message) {
				ChatMessageListActivity.super.handleHttpError(httpCode, message);
			}
		});
		mSendMessageTread.start();
		mSendMessageTread.getLooper();
	}
	
	/**
	 * 创建获取新消息的任务
	 * @return
	 */
	private GetNewMessageTask createLoadNewMessageTask() {
		String newestMessageID = "0";
		//获取最新消息的ID
		if (chatMessageList.size() != 0) {
			int i = 0;
			for (i = chatMessageList.size() - 1; i >= 0; i--) {
				if (chatMessageList.get(i).getIsSendSuccess().equals("1")) {
					newestMessageID = chatMessageList.get(i).getMessageID();
					break;
				}
			}
			if (i < 0) {
				newestMessageID = "0";
			}

		} else
			newestMessageID = "0";
		GetNewMessageTask getHistoryMsg = new GetNewMessageTask(mCustomerID, thereUserID, newestMessageID, mApp, new GetNewMessageTask.NewMessageCallback() {
			
			@Override
			public void onLoaded(ArrayList<ChatMessageInformation> newMessages) {
				chatMessageList.addAll(chatMessageList.size(), newMessages);
				chatListAdapter.notifyDataSetChanged();
				messageListView.setSelection(messageListView.getAdapter().getCount() - 1);
			}
			
			@Override
			public void onError(int errorCode, String message) {
				DialogUtil.createShortDialog(getApplicationContext(), message);
			}
		});
		return getHistoryMsg;
	};

	@SuppressLint("SimpleDateFormat")
	@Override
	public void onClick(View v) {
		super.onClick(v);
		switch (v.getId()) {
		case R.id.sendmessage_edit:
			messageListView.setSelection(messageListView.getAdapter().getCount() - 1);
			break;
		case R.id.chat_message_send_button:
			if(flyMessageAuthority == 0){
				DialogUtil.createShortDialog(this, NOT_FLY_MESSAGE_AUTHORITY);
				return;
			}
			
			String inputMessage = String.valueOf(messageEditText.getText());
			if(!inputMessage.equals("")) {
				// 给ListView中添加一条新信息
				ChatMessageInformation newMessageInformation = new ChatMessageInformation();
				newMessageInformation.setMessageContent(inputMessage);
				newMessageInformation.setSendOrReceiveFlag("1");
				newMessageInformation.setIsNewMessage("1");
				newMessageInformation.setIsSendSuccess("1");
				SimpleDateFormat sDateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm", Locale.getDefault());
				newMessageInformation.setSendTime(sDateFormat.format(new java.util.Date()));
				newMessageInformation.setNewMessageID(messageListView.getAdapter().getCount());
				
				chatMessageList.add(newMessageInformation);
				newChatMessageList.put(messageListView.getAdapter().getCount()-1, newMessageInformation);;
				chatListAdapter.notifyDataSetChanged();

				messageListView.setSelection(messageListView.getAdapter().getCount() - 1);
				messageEditText.setText("");// 编辑框清空

				// 创建一个新消息到发送消息线程的队列
				NewMessageInformation newMessage = new NewMessageInformation();
				newMessage.setmBranchID(mApp.getLoginInformation().getBranchID());
				newMessage.setmCompanyID(mApp.getLoginInformation().getCompanyID());
				newMessage.setmGroupFlag("0");
				newMessage.setmMessageContent(inputMessage);
				newMessage.setmMessageType("0");
				newMessage.setmReceiverIDs(thereUserID + ",");
				newMessage.setmSenderID(mApp.getLoginInformation().getCustomerID());

				// 放到发送线程的消息队列中
				mSendMessageTread.queueMessage(messageListView.getAdapter().getCount() - 1, newMessage);
			}
			break;
		case R.id.fly_message_expression_icon:
			if(expressionRelativelayout.getVisibility()==View.GONE)
				expressionRelativelayout.setVisibility(View.VISIBLE);
			else if(expressionRelativelayout.getVisibility()==View.VISIBLE)
				expressionRelativelayout.setVisibility(View.GONE);
			InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);  
            if (imm != null) {  
                imm.hideSoftInputFromWindow(v.getWindowToken(), 0);  
            } 
			break;
		default:
			break;
		}
	}

	/**
	 * 第一次加载历史数据
	 */
	protected void loadHistoryMessage() {
		super.dismissProgressDialog();
		GetHistoryMessageTask getHistoryMsg = new GetHistoryMessageTask(mCustomerID, thereUserID, "0", mApp);
		getHistoryMsg.setCallback(new HistoryMessageCallback() {
			
			@Override
			public void onLoaded(ArrayList<ChatMessageInformation> newMessages) {
				chatMessageList = newMessages;
				if (chatMessageList.size() != 0) {
					chatMessageList.get(chatMessageList.size() - 1).getMessageID();
					
					chatListAdapter = new ChatListAdapter(ChatMessageListActivity.this, chatMessageList, thumbnailImageURL, hereUserThumbnailImageURL);
					messageListView.setAdapter(chatListAdapter);
					messageListView.setSelection(messageListView.getAdapter().getCount() - 1);
				} else {
					chatListAdapter = new ChatListAdapter(ChatMessageListActivity.this, chatMessageList, thumbnailImageURL, hereUserThumbnailImageURL);
					messageListView.setAdapter(chatListAdapter);
				}
			}
			
			@Override
			public void onHttpCode(int httpCode, int errorMessage) {
				ChatMessageListActivity.super.handleHttpError(httpCode, errorMessage);
			}
			
			@Override
			public void onError(int errorCode, String message) {
				DialogUtil.createShortDialog(getApplicationContext(), message);
			}
		});
		super.asyncRefrshView(getHistoryMsg);
	}

	// 取得ID小于oldThanMessageID的message信息
	protected void getHistoryMessage(String oldThanMessageID) {
		GetHistoryMessageTask getHistoryMsg = new GetHistoryMessageTask(mCustomerID, thereUserID, oldThanMessageID, mApp);
		getHistoryMsg.setCallback(new GetHistoryMessageTask.HistoryMessageCallback() {
			
			@Override
			public void onLoaded(ArrayList<ChatMessageInformation> messages) {
				chatMessageList.addAll(0, messages);
				if (messages == null || messages.size() == 0) {
					DialogUtil.createShortDialog(ChatMessageListActivity.this, "没有更早的消息了");
				} else {
					chatListAdapter.notifyDataSetChanged();
				}
				messageListView.onRefreshComplete(); 
			}
			
			@Override
			public void onHttpCode(int httpCode, int errorMessage) {
				ChatMessageListActivity.super.handleHttpError(httpCode, errorMessage);
			}
			
			@Override
			public void onError(int errorCode, String message) {
				DialogUtil.createShortDialog(getApplicationContext(), message);
			}
		});
		super.asyncRefrshView(getHistoryMsg);
	}

	@Override
	public void onItemClick(AdapterView<?> arg0, View arg1, int position, long id) {
		// TODO Auto-generated method stub
		ChatEmoji emoji = (ChatEmoji) faceAdapters.get(current).getItem(position);
				if (emoji.getId() == R.drawable.face_del_icon) {
					int selection =messageEditText.getSelectionStart();
					String text =messageEditText.getText().toString();
					if (selection > 0) {
						String text2 = text.substring(selection - 1);
						if ("]".equals(text2)) {
							int start = text.lastIndexOf("[");
							int end = selection;
							messageEditText.getText().delete(start, end);
							return;
						}
						messageEditText.getText().delete(selection - 1,selection);
					}
				}
				if (!TextUtils.isEmpty(emoji.getCharacter())) {
					int selection = messageEditText.getSelectionStart();
					if (mListener != null)
						mListener.onCorpusSelected(emoji);
					SpannableString spannableString = FaceConversionUtil.getInstace().addFace(this,emoji.getId(), emoji.getCharacter());
					messageEditText.getEditableText().insert(selection,spannableString);
				}
	}
}
