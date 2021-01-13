package cn.com.antika.business;

import android.app.ProgressDialog;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.support.v4.view.ViewPager;
import android.support.v4.view.ViewPager.OnPageChangeListener;
import android.text.SpannableString;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.view.ViewGroup.LayoutParams;
import android.view.Window;
import android.view.inputmethod.InputMethodManager;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.GridView;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import cn.com.antika.adapter.FaceAdapter;
import cn.com.antika.adapter.FlyMessageDetailListAdapter;
import cn.com.antika.adapter.ViewPagerAdapter;
import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.ChatEmoji;
import cn.com.antika.bean.DownloadInfo;
import cn.com.antika.bean.FlyMessage;
import cn.com.antika.bean.FlymessageDetail;
import cn.com.antika.bean.ServerPackageVersion;
import cn.com.antika.constant.Constant;
import cn.com.antika.minterface.RefreshListViewWithWebservice;
import cn.com.antika.util.DialogUtil;
import cn.com.antika.util.FaceConversionUtil;
import cn.com.antika.util.FileCache;
import cn.com.antika.util.GenerateMenu;
import cn.com.antika.util.PackageUpdateUtil;
import cn.com.antika.view.BusinessLeftImageButton;
import cn.com.antika.view.BusinessRightImageButton;
import cn.com.antika.view.RefreshListView;
import cn.com.antika.webservice.WebServiceUtil;

public class FlyMessageDetailActivity extends BaseActivity implements OnClickListener, OnItemClickListener {
    private FlyMessageDetailActivityHandler mHandler = new FlyMessageDetailActivityHandler(this);
    public static final String NEW_MESSAGE_BROADCAST_ACTION = "newChatMesage";
    //JPush
    public static boolean isForeground = false;
    private MessageRecevice messageRecevice;
    private IntentFilter filter;
    private TextView recevierText;
    private Button sendFlyMessageBtn;
    private ImageButton chooseFlyMessageTemplateBtn, flyMessageExpressionIcon;
    private String toUserIds = "";
    private String receiverTitleText = "收件人：";
    private EditText sendFlyMessageText;
    private RefreshListView flyMessageListView;
    private Thread requestWebServiceThread;
    private ProgressDialog progressDialog;
    private List<FlymessageDetail> flyMessageDetailList;
    private int olderThanMessageID = 0;
    private FlyMessageDetailListAdapter flyMessageDetailListAdapter;
    private int newestMessageID;
    private int oldestMessageID;
    private HashMap<Integer, String> sendOrReceviceFlag = new HashMap<Integer, String>();
    private String thereUserHeadImage;
    private String hereUserHeadImage;
    private String sendMessageResult;
    private UserInfoApplication userinfoApplication;
    private FlyMessage flyMessage;
    private String des;
    private String toUserNames;
    private RefreshListViewWithWebservice refreshListViewWithWebservice;
    private String source;
    private PackageUpdateUtil packageUpdateUtil;
    private RelativeLayout expressionRelativelayout;
    private ViewPager expressionViewPager;
    //表情数据结合
    private List<List<ChatEmoji>> emojis;
    //每一页的表情数据填充器
    private List<FaceAdapter> faceAdapters;
    //表情页界面集合
    private ArrayList<View> pageViews;
    //当前表情页
    private int current = 0;
    /**
     * 游标显示布局
     */
    private LinearLayout layoutPoint;

    /**
     * 游标点集合
     */
    private ArrayList<ImageView> pointViews;
    private OnCorpusSelectedListener mListener;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    private static class FlyMessageDetailActivityHandler extends Handler {
        private final FlyMessageDetailActivity flyMessageDetailActivity;

        private FlyMessageDetailActivityHandler(FlyMessageDetailActivity activity) {
            WeakReference<FlyMessageDetailActivity> weakReference = new WeakReference<FlyMessageDetailActivity>(activity);
            flyMessageDetailActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message message) {
            // 当activity未加载完成时,用户返回的情况
            if (flyMessageDetailActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (flyMessageDetailActivity.progressDialog != null) {
                flyMessageDetailActivity.progressDialog.dismiss();
                flyMessageDetailActivity.progressDialog = null;
            }
            if (message.what == 1) {
                if (flyMessageDetailActivity.flyMessageDetailList.size() != 0) {
                    flyMessageDetailActivity.oldestMessageID = flyMessageDetailActivity.flyMessageDetailList.get(0).getMessageID();
                    flyMessageDetailActivity.newestMessageID = flyMessageDetailActivity.flyMessageDetailList.get(flyMessageDetailActivity.flyMessageDetailList.size() - 1).getMessageID();
                    for (int i = 0; i < flyMessageDetailActivity.flyMessageDetailList.size(); i++) {
                        flyMessageDetailActivity.sendOrReceviceFlag.put(i, String.valueOf(flyMessageDetailActivity.flyMessageDetailList.get(i).getSendOrReceiveFlag()));
                    }
                    flyMessageDetailActivity.flyMessageDetailListAdapter = new FlyMessageDetailListAdapter(flyMessageDetailActivity, flyMessageDetailActivity.flyMessageDetailList, flyMessageDetailActivity.thereUserHeadImage, flyMessageDetailActivity.hereUserHeadImage, flyMessageDetailActivity.sendOrReceviceFlag);
                    flyMessageDetailActivity.flyMessageListView.setAdapter(flyMessageDetailActivity.flyMessageDetailListAdapter);
                    flyMessageDetailActivity.flyMessageListView.setSelection(flyMessageDetailActivity.flyMessageListView.getAdapter().getCount() - 1);
                }
            } else if (message.what == 3)
                DialogUtil.createShortDialog(flyMessageDetailActivity, "您的网络貌似不给力，请重试");
            else if (message.what == 4) {
                flyMessageDetailActivity.requestWebServiceThread = new GetNewMessageListThread(flyMessageDetailActivity);
                flyMessageDetailActivity.requestWebServiceThread.start();
            } else if (message.what == 8) {
                flyMessageDetailActivity.flyMessageDetailListAdapter.notifyDataSetChanged();
                flyMessageDetailActivity.flyMessageListView.setSelection(flyMessageDetailActivity.flyMessageListView.getAdapter().getCount() - 1);
                flyMessageDetailActivity.newestMessageID = flyMessageDetailActivity.flyMessageDetailList.get(flyMessageDetailActivity.flyMessageDetailList.size() - 1).getMessageID();
            } else if (message.what == 6) {
                if (message.obj.equals(0)) {
                    DialogUtil.createShortDialog(flyMessageDetailActivity, "没有更早的消息了");
                } else {
                    flyMessageDetailActivity.flyMessageDetailListAdapter.notifyDataSetChanged();
                }
            } else if (message.what == Constant.LOGIN_ERROR) {
                DialogUtil.createShortDialog(flyMessageDetailActivity, flyMessageDetailActivity.getString(R.string.login_error_message));
                UserInfoApplication.getInstance().exitForLogin(flyMessageDetailActivity);
            } else if (message.what == Constant.APP_VERSION_ERROR) {
                String downloadFileUrl = Constant.SERVER_URL + flyMessageDetailActivity.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(flyMessageDetailActivity);
                flyMessageDetailActivity.packageUpdateUtil = new PackageUpdateUtil(flyMessageDetailActivity, flyMessageDetailActivity.mHandler, fileCache, downloadFileUrl, false, flyMessageDetailActivity.userinfoApplication);
                flyMessageDetailActivity.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) message.obj);
                flyMessageDetailActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            //包进行下载安装升级
            else if (message.what == 5) {
                ((DownloadInfo) message.obj).getUpdateDialog().cancel();
                String filename = "cn.com.antika.business.apk";
                File file = flyMessageDetailActivity.getFileStreamPath(filename);
                file.getName();
                flyMessageDetailActivity.packageUpdateUtil.showInstallDialog();
            } else if (message.what == -5) {
                ((DownloadInfo) message.obj).getUpdateDialog().cancel();
            } else if (message.what == 7) {
                int downLoadFileSize = ((DownloadInfo) message.obj).getDownloadApkSize();
                ((DownloadInfo) message.obj).getUpdateDialog().setProgress(downLoadFileSize);
            }
            if (flyMessageDetailActivity.requestWebServiceThread != null) {
                flyMessageDetailActivity.requestWebServiceThread.interrupt();
                flyMessageDetailActivity.requestWebServiceThread = null;
            }
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_fly_message_detail);
        userinfoApplication = UserInfoApplication.getInstance();
        initView(olderThanMessageID);
        FaceConversionUtil.getInstace().getFileText(getApplication());
        emojis = FaceConversionUtil.getInstace().emojiLists;
        layoutPoint = (LinearLayout) findViewById(R.id.fly_message_expression_point);
        initExpressionViewPager();
        initPoint();
        initExpressionData();
    }

    protected void initView(int orderThanMessageID) {
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
        recevierText = (TextView) findViewById(R.id.receiver_text_view);
        sendFlyMessageBtn = (Button) findViewById(R.id.send_fly_message_button);
        sendFlyMessageBtn.setOnClickListener(this);
        chooseFlyMessageTemplateBtn = (ImageButton) findViewById(R.id.choose_fly_message_template_button);
        chooseFlyMessageTemplateBtn.setOnClickListener(this);
        flyMessageExpressionIcon = (ImageButton) findViewById(R.id.fly_message_expression_icon);
        flyMessageExpressionIcon.setOnClickListener(this);
        sendFlyMessageText = (EditText) findViewById(R.id.send_message_text);
        flyMessageListView = (RefreshListView) findViewById(R.id.fly_message_detail_listview);
        flyMessageDetailList = new ArrayList<FlymessageDetail>();
        flyMessageDetailListAdapter = new FlyMessageDetailListAdapter(this, flyMessageDetailList, thereUserHeadImage, hereUserHeadImage, sendOrReceviceFlag);
        expressionViewPager = (ViewPager) findViewById(R.id.fly_message_expression_viewpager);
        expressionRelativelayout = (RelativeLayout) findViewById(R.id.fly_message_expression_relativelayout);
        Intent intent = getIntent();
        flyMessage = (FlyMessage) intent.getSerializableExtra("flyMessage");
        des = intent.getStringExtra("Des");
        hereUserHeadImage = userinfoApplication.getAccountInfo().getHeadImage();
        //下拉刷新时使用
        refreshListViewWithWebservice = new RefreshListViewWithWebservice() {

            @Override
            public Object refreshing() {
                // TODO Auto-generated method stub
                if (requestWebServiceThread == null)
                    getHistoryMessage(String.valueOf(oldestMessageID));
                return null;
            }

            @Override
            public void refreshed(Object obj) {
                // TODO Auto-generated method stub

            }
        };
        flyMessageListView.setOnRefreshListener(refreshListViewWithWebservice);
        if (des.equals("Detail")) {
            source = getIntent().getStringExtra("Source");
            if (source != null && !source.equals("")) {
                if (source.equals("Customer"))
                    thereUserHeadImage = userinfoApplication.getSelectedCustomerHeadImageURL();
                else if (source.equals("List"))
                    thereUserHeadImage = flyMessage.getHeadImageUrl();
            }
            toUserIds = flyMessage.getCustomerID() + ",";
            final int orderMessageIDValue = orderThanMessageID;
            recevierText.setText(receiverTitleText + flyMessage.getCustomerName());
            progressDialog = new ProgressDialog(this, R.style.CustomerProgressDialog);
            progressDialog.setMessage(getString(R.string.please_wait));
            progressDialog.show();
            //获取老的飞语信息
            requestWebServiceThread = new Thread() {
                @Override
                public void run() {
                    String methodName = "getHistoryMessage";
                    String endPoint = "Message";
                    JSONObject historyMessageJsonParam = new JSONObject();
                    try {
                        historyMessageJsonParam.put("HereUserID", userinfoApplication.getAccountInfo().getAccountId());
                        historyMessageJsonParam.put("ThereUserID", flyMessage.getCustomerID());
                        historyMessageJsonParam.put("MessageID", orderMessageIDValue);
                    } catch (JSONException e) {

                    }
                    String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, historyMessageJsonParam.toString(), userinfoApplication);
                    if (serverRequestResult == null || serverRequestResult.equals(""))
                        mHandler.sendEmptyMessage(3);
                    else {
                        int code = 0;
                        JSONArray historyMessageArray = null;
                        try {
                            JSONObject newMessageResultJson = new JSONObject(serverRequestResult);
                            code = newMessageResultJson.getInt("Code");
                            historyMessageArray = newMessageResultJson.getJSONArray("Data");
                        } catch (JSONException e) {

                        }
                        if (code == 1 && historyMessageArray != null) {
                            for (int i = 0; i < historyMessageArray.length(); i++) {
                                int messageID = 0;
                                int messageType = 0;
                                boolean groupFlag = false;
                                String messageContent = "";
                                String sendTime = "";
                                int sendOrReceiveFlag = 1;
                                try {
                                    JSONObject historyMessageJson = historyMessageArray.getJSONObject(i);
                                    if (historyMessageJson.has("MessageID") && !historyMessageJson.isNull("MessageID"))
                                        messageID = historyMessageJson.getInt("MessageID");
                                    if (historyMessageJson.has("MessageType") && !historyMessageJson.isNull("MessageType"))
                                        messageType = historyMessageJson.getInt("MessageType");
                                    if (historyMessageJson.has("GroupFlag") && !historyMessageJson.isNull("GroupFlag"))
                                        groupFlag = historyMessageJson.getBoolean("GroupFlag");
                                    if (historyMessageJson.has("MessageContent") && !historyMessageJson.isNull("MessageContent"))
                                        messageContent = historyMessageJson.getString("MessageContent");
                                    if (historyMessageJson.has("SendTime") && !historyMessageJson.isNull("SendTime"))
                                        sendTime = historyMessageJson.getString("SendTime");
                                    if (historyMessageJson.has("SendOrReceiveFlag") && !historyMessageJson.isNull("SendOrReceiveFlag"))
                                        sendOrReceiveFlag = historyMessageJson.getInt("SendOrReceiveFlag");
                                } catch (JSONException e) {

                                }
                                FlymessageDetail flyMessageDetail = new FlymessageDetail();
                                flyMessageDetail.setMessageID(messageID);
                                flyMessageDetail.setMessageType(messageType);
                                flyMessageDetail.setGroupFlag(groupFlag);
                                flyMessageDetail.setMessageContent(messageContent);
                                flyMessageDetail.setSendTime(sendTime);
                                flyMessageDetail.setSendOrReceiveFlag(sendOrReceiveFlag);
                                flyMessageDetailList.add(flyMessageDetail);
                            }
                            mHandler.sendEmptyMessage(1);
                        } else
                            mHandler.sendEmptyMessage(code);
                    }
                }
            };
            requestWebServiceThread.start();
        } else if (des.equals("Send")) {
            toUserNames = intent.getStringExtra("toUsersName");
            if (toUserNames != null) {
                String[] userNameArray = toUserNames.split(",");
                int toUserNumber = userNameArray.length;
                if (toUserNumber > 1) {
                    String showUserNameText = userNameArray[0] + "," + userNameArray[1];
                    recevierText.setText(receiverTitleText + showUserNameText + "等" + toUserNumber + "人");
                } else if (toUserNumber == 1) {
                    String showUserNameText = userNameArray[0];
                    recevierText.setText(receiverTitleText + showUserNameText);
                }
                toUserIds = intent.getStringExtra("toUsersID");
            }
        }
        sendFlyMessageText.setText(getIntent().getStringExtra("templateContent"));
    }

    @Override
    protected void onResume() {
        // TODO Auto-generated method stub
        super.onResume();
        isForeground = true;
        // 监听新消息的广播
        if (messageRecevice == null) {
            messageRecevice = new MessageRecevice();
        }
        if (filter == null) {
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
            FaceAdapter adapter = new FaceAdapter(this, emojis.get(i));
            view.setAdapter(adapter);
            faceAdapters.add(adapter);
            view.setOnItemClickListener(this);
            view.setNumColumns(7);
            view.setBackgroundColor(Color.parseColor("#FAFAFA"));
            view.setHorizontalSpacing(1);
            view.setVerticalSpacing(1);
            view.setStretchMode(GridView.STRETCH_COLUMN_WIDTH);
            view.setCacheColorHint(0);
            view.setPadding(5, 0, 5, 0);
            view.setSelector(new ColorDrawable(Color.TRANSPARENT));
            view.setLayoutParams(new LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT));
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
            LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams(new ViewGroup.LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT));
            layoutParams.leftMargin = 10;
            layoutParams.rightMargin = 10;
            layoutParams.width = 8;
            layoutParams.height = 8;
            if (i == 0) {
                imageView.setBackgroundResource(R.drawable.d2);
            }
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

    @Override
    protected void onPause() {
        super.onPause();
        unregisterReceiver(messageRecevice);
        isForeground = false;
    }

    @Override
    protected void onNewIntent(Intent intent) {
        // TODO Auto-generated method stub
        super.onNewIntent(intent);
        String isExit = intent.getStringExtra("exit");
        if (isExit != null && isExit.equals("1")) {
            userinfoApplication.setAccountInfo(null);
            userinfoApplication.setSelectedCustomerID(0);
            userinfoApplication.setSelectedCustomerName("");
            userinfoApplication.setSelectedCustomerHeadImageURL("");
            userinfoApplication.setSelectedCustomerLoginMobile("");
            userinfoApplication.setAccountNewMessageCount(0);
            userinfoApplication.setAccountNewRemindCount(0);
            userinfoApplication.setOrderInfo(null);
            Constant.formalFlag = 0;
            finish();
        } else {
            if (des.equals("Send")) {
                toUserNames = intent.getStringExtra("toUsersName");
                if (toUserNames != null) {
                    String[] userNameArray = toUserNames.split(",");
                    int toUserNumber = userNameArray.length;
                    if (toUserNumber > 1) {
                        String showUserNameText = userNameArray[0] + "," + userNameArray[1];
                        recevierText.setText(receiverTitleText + showUserNameText + "等" + toUserNumber + "人");
                    } else if (toUserNumber == 1) {
                        String showUserNameText = userNameArray[0];
                        recevierText.setText(receiverTitleText + showUserNameText);
                    }
                    toUserIds = intent.getStringExtra("toUsersID");
                }
            }
            sendFlyMessageText.setText(getIntent().getStringExtra("templateContent"));
        }
    }

    @Override
    public void onClick(View view) {
        // TODO Auto-generated method stub
        Intent destIntent = null;
        switch (view.getId()) {
            case R.id.choose_fly_message_template_button:
                destIntent = new Intent(this, SendMarketingTemplateActivity.class);
                Bundle bundle = new Bundle();
                bundle.putSerializable("flyMessage", flyMessage);
                destIntent.putExtras(bundle);
                if (toUserNames != null) {
                    destIntent.putExtra("toUsersName", toUserNames);
                    destIntent.putExtra("toUsersID", toUserIds);
                }
                destIntent.putExtra("Des", des);
                destIntent.putExtra("FROMSOURCE", "FLYMESSAGE");
                startActivity(destIntent);
                this.finish();
                break;
            case R.id.send_fly_message_button:
                final String messageText = sendFlyMessageText.getText().toString();
                int customerAvailable = 1;
                if (flyMessage != null)
                    customerAvailable = flyMessage.getAvailable();
                if (messageText == null || ("").equals(messageText))
                    DialogUtil.createShortDialog(this, "发送信息不允许为空！");
                else if (customerAvailable == 0)
                    DialogUtil.createShortDialog(this, "该客户已被删除，不能发送飞语！");
                else {
                    FlymessageDetail newFlyMessage = new FlymessageDetail();
                    newFlyMessage.setMessageContent(messageText);
                    newFlyMessage.setSendOrReceiveFlag(1);
                    SimpleDateFormat sDateFormat = new SimpleDateFormat("yyyy-MM-dd   HH:mm");
                    newFlyMessage.setSendTime(sDateFormat.format(new java.util.Date()));
                    flyMessageDetailList.add(newFlyMessage);
                    flyMessageDetailListAdapter = new FlyMessageDetailListAdapter(
                            FlyMessageDetailActivity.this, flyMessageDetailList,
                            thereUserHeadImage, hereUserHeadImage,
                            sendOrReceviceFlag);
                    flyMessageListView.setAdapter(flyMessageDetailListAdapter);
                    flyMessageDetailListAdapter.notifyDataSetChanged();
                    flyMessageListView.setSelection(flyMessageListView.getAdapter().getCount() - 1);
                    sendFlyMessageText.setText("");
                    flyMessageDetailListAdapter.getSendOrReceiveFlag().put(flyMessageDetailList.size() - 1, "1");
                    progressDialog = new ProgressDialog(this, R.style.CustomerProgressDialog);
                    progressDialog.setMessage(getString(R.string.please_wait));
                    progressDialog.show();
                    requestWebServiceThread = new Thread() {
                        @Override
                        public void run() {
                            // TODO Auto-generated method stub
                            String methodName = "addMessage";
                            String endPoint = "Message";
                            JSONObject addMessageJsonParam = new JSONObject();
                            try {
                                addMessageJsonParam.put("FromUserID", userinfoApplication.getAccountInfo().getAccountId());
                                addMessageJsonParam.put("ToUserIDs", toUserIds);
                                addMessageJsonParam.put("MessageContent", messageText);
                                addMessageJsonParam.put("MessageType", 0);
                                if (toUserIds.split(",").length > 1)
                                    addMessageJsonParam.put("GroupFlag", 1);
                                else
                                    addMessageJsonParam.put("GroupFlag", 0);
                            } catch (JSONException e) {

                            }
                            String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, addMessageJsonParam.toString(), userinfoApplication);
                            if (serverRequestResult == null || serverRequestResult.equals(""))
                                mHandler.sendEmptyMessage(3);
                            else {
                                try {
                                    JSONObject result = new JSONObject(serverRequestResult);
                                    sendMessageResult = result.getString("Code");
                                } catch (JSONException e) {

                                }
                                if (Integer.parseInt(sendMessageResult) == 1)
                                    mHandler.sendEmptyMessage(2);
                                else if (Integer.parseInt(sendMessageResult) == Constant.LOGIN_ERROR || Integer.parseInt(sendMessageResult) == Constant.APP_VERSION_ERROR)
                                    mHandler.sendEmptyMessage(Integer.parseInt(sendMessageResult));
                            }
                        }
                    };
                    requestWebServiceThread.start();
                }
                break;
            case R.id.fly_message_expression_icon:
                if (expressionRelativelayout.getVisibility() == View.GONE)
                    expressionRelativelayout.setVisibility(View.VISIBLE);
                else if (expressionRelativelayout.getVisibility() == View.VISIBLE)
                    expressionRelativelayout.setVisibility(View.GONE);
                InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
                if (imm != null) {
                    imm.hideSoftInputFromWindow(view.getWindowToken(), 0);
                }
                break;
        }
    }

    //间隔去服务器上的数据线程
    private static class GetNewMessageListThread extends Thread {
        private FlyMessageDetailActivity flyMessageDetailActivity;

        public GetNewMessageListThread(FlyMessageDetailActivity flyMessageDetailActivity) {
            this.flyMessageDetailActivity = flyMessageDetailActivity;
        }

        @Override
        public void run() {
            // TODO Auto-generated method stub
            String methodName = "getNewMessage";
            String endPoint = "Message";
            JSONObject newMessageJsonParam = new JSONObject();
            try {
                newMessageJsonParam.put("HereUserID", String.valueOf(flyMessageDetailActivity.userinfoApplication.getAccountInfo().getAccountId()));
                newMessageJsonParam.put("ThereUserID", String.valueOf(flyMessageDetailActivity.flyMessage.getCustomerID()));
                newMessageJsonParam.put("MessageID", String.valueOf(flyMessageDetailActivity.newestMessageID));
            } catch (JSONException e) {

            }
            String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, newMessageJsonParam.toString(), flyMessageDetailActivity.userinfoApplication);
            int code = 0;
            if (serverRequestResult != null) {
                JSONArray newMessageArray = null;
                try {
                    JSONObject newMessageResultJson = new JSONObject(serverRequestResult);
                    code = newMessageResultJson.getInt("Code");
                    newMessageArray = newMessageResultJson.getJSONArray("Data");
                } catch (JSONException e) {

                }
                //记录当前的已显示的飞语信息条数
                int oldListSize = flyMessageDetailActivity.flyMessageDetailList.size();
                for (int i = 0; i < newMessageArray.length(); i++) {
                    int messageID = 0;
                    int messageType = 0;
                    boolean groupFlag = false;
                    String messageContent = "";
                    String sendTime = "";
                    int sendOrReceiveFlag = 1;
                    try {
                        JSONObject newMessageJson = newMessageArray.getJSONObject(i);
                        if (newMessageJson.has("MessageID") && !newMessageJson.isNull("MessageID"))
                            messageID = newMessageJson.getInt("MessageID");
                        if (newMessageJson.has("MessageType") && !newMessageJson.isNull("MessageType"))
                            messageType = newMessageJson.getInt("MessageType");
                        if (newMessageJson.has("GroupFlag") && !newMessageJson.isNull("GroupFlag"))
                            groupFlag = newMessageJson.getBoolean("GroupFlag");
                        if (newMessageJson.has("MessageContent") && !newMessageJson.isNull("MessageContent"))
                            messageContent = newMessageJson.getString("MessageContent");
                        if (newMessageJson.has("SendTime") && !newMessageJson.isNull("SendTime"))
                            sendTime = newMessageJson.getString("SendTime");
                        if (newMessageJson.has("SendOrReceiveFlag") && !newMessageJson.isNull("SendOrReceiveFlag"))
                            sendOrReceiveFlag = newMessageJson.getInt("SendOrReceiveFlag");
                    } catch (JSONException e) {

                    }
                    FlymessageDetail flyMessageDetail = new FlymessageDetail();
                    flyMessageDetail.setMessageID(messageID);
                    flyMessageDetail.setMessageType(messageType);
                    flyMessageDetail.setGroupFlag(groupFlag);
                    flyMessageDetail.setMessageContent(messageContent);
                    flyMessageDetail.setSendTime(sendTime);
                    flyMessageDetail.setSendOrReceiveFlag(sendOrReceiveFlag);
                    flyMessageDetailActivity.flyMessageDetailList.add(oldListSize + i, flyMessageDetail);
                }
                if (newMessageArray != null && newMessageArray.length() > 0)
                    flyMessageDetailActivity.mHandler.sendEmptyMessage(8);
                else
                    flyMessageDetailActivity.mHandler.sendEmptyMessage(-1);
            }
        }
    }

    // 取得ID小于oldThanMessageID的message信息
    protected void getHistoryMessage(String oldThanMessageID) {
        final String finalOldThanMessageID = oldThanMessageID;
        if (flyMessage != null) {
            requestWebServiceThread = new Thread() {
                @Override
                public void run() {
                    // TODO Auto-generated method stub
                    String methodName = "getHistoryMessage";
                    String endPoint = "Message";
                    JSONObject historyMessageJsonParam = new JSONObject();
                    try {
                        historyMessageJsonParam.put("HereUserID", userinfoApplication.getAccountInfo().getAccountId());
                        historyMessageJsonParam.put("ThereUserID", flyMessage.getCustomerID());
                        historyMessageJsonParam.put("MessageID", finalOldThanMessageID);
                    } catch (JSONException e) {

                    }
                    String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, historyMessageJsonParam.toString(), userinfoApplication);
                    if (serverRequestResult == null || serverRequestResult.equals(""))
                        mHandler.sendEmptyMessage(3);
                    else {
                        int code = 0;
                        JSONArray historyMessageArray = null;
                        try {
                            JSONObject newMessageResultJson = new JSONObject(serverRequestResult);
                            code = newMessageResultJson.getInt("Code");
                            historyMessageArray = newMessageResultJson.getJSONArray("Data");
                        } catch (JSONException e) {

                        }
                        if (code == 1 && historyMessageArray != null) {
                            for (int i = 0; i < historyMessageArray.length(); i++) {
                                int messageID = 0;
                                int messageType = 0;
                                boolean groupFlag = false;
                                String messageContent = "";
                                String sendTime = "";
                                int sendOrReceiveFlag = 1;
                                try {
                                    JSONObject historyMessageJson = historyMessageArray.getJSONObject(i);
                                    if (historyMessageJson.has("MessageID") && !historyMessageJson.isNull("MessageID"))
                                        messageID = historyMessageJson.getInt("MessageID");
                                    if (historyMessageJson.has("MessageType") && !historyMessageJson.isNull("MessageType"))
                                        messageType = historyMessageJson.getInt("MessageType");
                                    if (historyMessageJson.has("GroupFlag") && !historyMessageJson.isNull("GroupFlag"))
                                        groupFlag = historyMessageJson.getBoolean("GroupFlag");
                                    if (historyMessageJson.has("MessageContent") && !historyMessageJson.isNull("MessageContent"))
                                        messageContent = historyMessageJson.getString("MessageContent");
                                    if (historyMessageJson.has("SendTime") && !historyMessageJson.isNull("SendTime"))
                                        sendTime = historyMessageJson.getString("SendTime");
                                    if (historyMessageJson.has("SendOrReceiveFlag") && !historyMessageJson.isNull("SendOrReceiveFlag"))
                                        sendOrReceiveFlag = historyMessageJson.getInt("SendOrReceiveFlag");
                                } catch (JSONException e) {

                                }
                                FlymessageDetail flyMessageDetail = new FlymessageDetail();
                                flyMessageDetail.setMessageID(messageID);
                                flyMessageDetail.setMessageType(messageType);
                                flyMessageDetail.setGroupFlag(groupFlag);
                                flyMessageDetail.setMessageContent(messageContent);
                                flyMessageDetail.setSendTime(sendTime);
                                flyMessageDetail.setSendOrReceiveFlag(sendOrReceiveFlag);
                                flyMessageDetailList.add(i, flyMessageDetail);
                                oldestMessageID = flyMessageDetailList.get(0).getMessageID();
                                Message msg = new Message();
                                msg.obj = historyMessageArray.length();
                                msg.what = 6;
                                mHandler.sendMessage(msg);
                            }
                        } else
                            mHandler.sendEmptyMessage(code);
                    }
                }
            };
            requestWebServiceThread.start();
        }
    }

    // 接收推送消息
    public class MessageRecevice extends BroadcastReceiver {
        @Override
        public void onReceive(Context arg0, Intent arg1) {
            // TODO Auto-generated method stub
            mHandler.obtainMessage(4).sendToTarget();
        }
    }

    @Override
    protected void onDestroy() {
        // TODO Auto-generated method stub
        super.onDestroy();
        exit = true;
        if (progressDialog != null) {
            progressDialog.dismiss();
            progressDialog = null;
        }
        if (mHandler != null) {
            mHandler.removeCallbacksAndMessages(null);
            // mHandler = null;
        }
        if (requestWebServiceThread != null) {
            requestWebServiceThread.interrupt();
            requestWebServiceThread = null;
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
    public void onItemClick(AdapterView<?> arg0, View arg1, int position, long id) {
        // TODO Auto-generated method stub
        ChatEmoji emoji = (ChatEmoji) faceAdapters.get(current).getItem(position);
        if (emoji.getId() == R.drawable.face_del_icon) {
            int selection = sendFlyMessageText.getSelectionStart();
            String text = sendFlyMessageText.getText().toString();
            if (selection > 0) {
                String text2 = text.substring(selection - 1);
                if ("]".equals(text2)) {
                    int start = text.lastIndexOf("[");
                    int end = selection;
                    sendFlyMessageText.getText().delete(start, end);
                    return;
                }
                sendFlyMessageText.getText().delete(selection - 1, selection);
            }
        }
        if (!TextUtils.isEmpty(emoji.getCharacter())) {
            int selection = sendFlyMessageText.getSelectionStart();
            if (mListener != null)
                mListener.onCorpusSelected(emoji);
            SpannableString spannableString = FaceConversionUtil.getInstace().addFace(this, emoji.getId(), emoji.getCharacter());
            sendFlyMessageText.getEditableText().insert(selection, spannableString);
        }
    }
}
