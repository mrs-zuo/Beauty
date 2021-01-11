package com.GlamourPromise.Beauty.Business;

import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.TableLayout;
import android.widget.TextView;

import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.AddressInfo;
import com.GlamourPromise.Beauty.bean.Customer;
import com.GlamourPromise.Beauty.bean.DownloadInfo;
import com.GlamourPromise.Beauty.bean.EmailInfo;
import com.GlamourPromise.Beauty.bean.FlyMessage;
import com.GlamourPromise.Beauty.bean.PhoneInfo;
import com.GlamourPromise.Beauty.bean.ServerPackageVersion;
import com.GlamourPromise.Beauty.bean.SourceType;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlamourPromise.Beauty.util.DialogUtil;
import com.GlamourPromise.Beauty.util.FileCache;
import com.GlamourPromise.Beauty.util.ImageLoaderUtil;
import com.GlamourPromise.Beauty.util.PackageUpdateUtil;
import com.GlamourPromise.Beauty.util.ProgressDialogUtil;
import com.GlamourPromise.Beauty.util.StringUtil;
import com.GlamourPromise.Beauty.webservice.WebServiceUtil;
import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;

/*
 *顾客基本信息
 * */
@SuppressLint("ResourceType")
public class CustomerBasicInfoActivity extends BaseActivity implements
        OnClickListener {
    private CustomerBasicInfoActivityHandler mHandler = new CustomerBasicInfoActivityHandler(this);
    private Thread requestWebServiceThread;
    private ProgressDialog progressDialog;
    private ImageView customerHeadImageView;
    private ImageLoader imageLoader;
    private TextView customerBasicNameText;
    private TextView customerBasicSex;
    private List<PhoneInfo> phoneInfoList;
    private List<EmailInfo> emailInfoList;
    private List<AddressInfo> addressInfoList;
    private ImageButton editCustomerBasicBtn;
    private ImageButton sendMessageToCustomerBtn;
    private Customer customer;
    private TableLayout customerTelephonetableLayout;
    private TableLayout customerEmailtableLayout;
    private TableLayout customerAddresstableLayout;
    private UserInfoApplication userinfoApplication;
    private LayoutInflater layoutInflater;
    // 顾客的美丽顾问或者销售顾问
    private RelativeLayout customerResponsiblePersonRelativelayout, customerSalesPersonRelativelayout;
    private TextView customerResponsibleNameText, customerSalesNameText;
    private PackageUpdateUtil packageUpdateUtil;
    private DisplayImageOptions displayImageOptions;
    private ImageView customerQRCodeBtn;
    private View originalImageView;
    private AlertDialog originalQRCodeViewDialog;
    private ProgressBar progressBar;
    private int screenWidth, screenHeight;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_customer_basic_info);
        customerHeadImageView = (ImageView) findViewById(R.id.cutomer_headimage_detail);
        customerBasicNameText = (TextView) findViewById(R.id.customer_basic_name);
        customerBasicSex = (TextView) findViewById(R.id.customer_basic_sex);
        editCustomerBasicBtn = (ImageButton) findViewById(R.id.cutomer_basic_edit);
        editCustomerBasicBtn.setOnClickListener(this);
        sendMessageToCustomerBtn = (ImageButton) findViewById(R.id.cutomer_basic_send_message);
        sendMessageToCustomerBtn.setOnClickListener(this);
        imageLoader = ImageLoader.getInstance();
        displayImageOptions = ImageLoaderUtil.getDisplayImageOptions(R.drawable.head_image_null);
        customerTelephonetableLayout = (TableLayout) findViewById(R.id.customer_basic_telephone_tablelayout);
        customerEmailtableLayout = (TableLayout) findViewById(R.id.customer_basic_email_tablelayout);
        customerAddresstableLayout = (TableLayout) findViewById(R.id.customer_basic_address_tablelayout);
        customerResponsiblePersonRelativelayout = (RelativeLayout) findViewById(R.id.customer_basic_responsible_person_relativelayout);
        customerSalesPersonRelativelayout = (RelativeLayout) findViewById(R.id.customer_sales_person_relativelayout);
        customerResponsibleNameText = (TextView) findViewById(R.id.customer_basic_responsible_person);
        customerSalesNameText = (TextView) findViewById(R.id.customer_sales_person_text);
        customerTelephonetableLayout.setVisibility(View.GONE);
        customerEmailtableLayout.setVisibility(View.GONE);
        customerAddresstableLayout.setVisibility(View.GONE);
        customerQRCodeBtn = (ImageView) findViewById(R.id.customer_qr_code_btn);
        customerQRCodeBtn.setOnClickListener(this);
        userinfoApplication = UserInfoApplication.getInstance();
        layoutInflater = LayoutInflater.from(this);
        screenWidth = userinfoApplication.getScreenWidth();
        screenHeight = userinfoApplication.getScreenHeight();
        if (userinfoApplication.getAccountInfo().getAuthChatUse() == 0)
            sendMessageToCustomerBtn.setVisibility(View.GONE);
        // 获取顾客的基本信息
        getCustomerBasicInfo();
    }

    private static class CustomerBasicInfoActivityHandler extends Handler {
        private final CustomerBasicInfoActivity customerBasicInfoActivity;

        private CustomerBasicInfoActivityHandler(CustomerBasicInfoActivity activity) {
            WeakReference<CustomerBasicInfoActivity> weakReference = new WeakReference<CustomerBasicInfoActivity>(activity);
            customerBasicInfoActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message msg) {
            // 当activity未加载完成时,用户返回的情况
            if (customerBasicInfoActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (customerBasicInfoActivity.progressDialog != null) {
                customerBasicInfoActivity.progressDialog.dismiss();
                customerBasicInfoActivity.progressDialog = null;
            }
            if (msg.what == 1) {
                customerBasicInfoActivity.imageLoader.displayImage(customerBasicInfoActivity.customer.getHeadImageUrl(), customerBasicInfoActivity.customerHeadImageView, customerBasicInfoActivity.displayImageOptions);
                customerBasicInfoActivity.customerBasicNameText.setText(customerBasicInfoActivity.customer.getCustomerName());
                customerBasicInfoActivity.customerBasicSex.setText(customerBasicInfoActivity.customer.getTitle());
                if (customerBasicInfoActivity.customer.getResponsiblePersonName() != null && !("").equals(customerBasicInfoActivity.customer.getResponsiblePersonName())) {
                    customerBasicInfoActivity.customerResponsiblePersonRelativelayout.setOnClickListener(null);
                    customerBasicInfoActivity.customerResponsibleNameText.setText(customerBasicInfoActivity.customer.getResponsiblePersonName());
                } else {
                    customerBasicInfoActivity.customerResponsiblePersonRelativelayout.setOnClickListener(customerBasicInfoActivity);
                    customerBasicInfoActivity.customerResponsibleNameText.setTextColor(customerBasicInfoActivity.getApplicationContext().getResources().getColor(R.color.gray));
                    customerBasicInfoActivity.customerResponsibleNameText.setText("无");
                }
                int authAllCustomerContactInfoWrite = customerBasicInfoActivity.userinfoApplication.getAccountInfo().getAuthAllCustomerContactInfoWrite();
                int authAllCustomerInfoWrite = customerBasicInfoActivity.userinfoApplication.getAccountInfo().getAuthAllCustomerInfoWrite();
                //如果有查看全部顾客的权限或者是当前账号是该顾客的专属顾问
                if (authAllCustomerContactInfoWrite == 1 || authAllCustomerInfoWrite == 1 || (customerBasicInfoActivity.userinfoApplication.getSelectedCustomerResponsiblePersonID() == customerBasicInfoActivity.userinfoApplication.getAccountInfo().getAccountId())) {
                    customerBasicInfoActivity.editCustomerBasicBtn.setVisibility(View.VISIBLE);
                } else {
                    customerBasicInfoActivity.editCustomerBasicBtn.setVisibility(View.GONE);
                }
                boolean hasSalesFunction = false;
                if (customerBasicInfoActivity.userinfoApplication.getAccountInfo().getModuleInUse().contains("|4|"))
                    hasSalesFunction = true;
                if (hasSalesFunction) {
                    if (customerBasicInfoActivity.customer.getSalesName() != null && !("").equals(customerBasicInfoActivity.customer.getSalesName())) {
                        customerBasicInfoActivity.customerSalesPersonRelativelayout.setOnClickListener(null);
                        customerBasicInfoActivity.customerSalesNameText.setText(customerBasicInfoActivity.customer.getSalesName());
                    } else {
                        customerBasicInfoActivity.customerSalesPersonRelativelayout.setOnClickListener(customerBasicInfoActivity);
                        customerBasicInfoActivity.customerSalesNameText.setTextColor(customerBasicInfoActivity.getApplicationContext().getResources().getColor(R.color.gray));
                    }
                } else if (!hasSalesFunction) {
                    customerBasicInfoActivity.findViewById(R.id.customer_responsible_sales_divide_view).setVisibility(View.GONE);
                    customerBasicInfoActivity.customerSalesPersonRelativelayout.setVisibility(View.GONE);
                }
                if (customerBasicInfoActivity.customer.getGender() == 0)
                    ((ImageView) customerBasicInfoActivity.findViewById(R.id.cutomer_basic_sex_icon)).setBackgroundResource(R.drawable.cutomer_basic_sex_girl);
                else if (customerBasicInfoActivity.customer.getGender() == 1)
                    ((ImageView) customerBasicInfoActivity.findViewById(R.id.cutomer_basic_sex_icon)).setBackgroundResource(R.drawable.cutomer_basic_sex_boy);
                //如果有编辑所有顾客的联系信息权限时，则显示顾客的电话号码  电子邮件  地址信息等
                if (authAllCustomerContactInfoWrite == 1 || customerBasicInfoActivity.userinfoApplication.getSelectedCustomerResponsiblePersonID() == customerBasicInfoActivity.userinfoApplication.getAccountInfo().getAccountId()) {
                    //如果有查看全部顾客的权限或者是当前账号是该顾客的专属顾问
                    ((TextView) customerBasicInfoActivity.findViewById(R.id.customer_basic_login_mobile_text)).setText(customerBasicInfoActivity.customer.getAuthorizeID());
                    if (customerBasicInfoActivity.phoneInfoList != null && customerBasicInfoActivity.phoneInfoList.size() != 0) {
                        customerBasicInfoActivity.customerTelephonetableLayout.setVisibility(View.VISIBLE);
                        customerBasicInfoActivity.customer.setPhoneInfoList(customerBasicInfoActivity.phoneInfoList);
                        for (int i = 0; i < customerBasicInfoActivity.phoneInfoList.size(); i++) {
                            PhoneInfo phoneInfo = customerBasicInfoActivity.phoneInfoList.get(i);
                            String phoneTypeStr = "";
                            switch (phoneInfo.phoneType) {
                                case 0:
                                    phoneTypeStr = "手机";
                                    break;
                                case 1:
                                    phoneTypeStr = "住宅";
                                    break;
                                case 2:
                                    phoneTypeStr = "工作";
                                    break;
                                case 3:
                                    phoneTypeStr = "其他";
                                    break;
                            }
                            View telephoneEmailView = customerBasicInfoActivity.layoutInflater.inflate(R.xml.customer_basci_info_telephone_email, null);
                            TextView telephoneEmailTitle = (TextView) telephoneEmailView.findViewById(R.id.telephone_email_title);
                            TextView telephoneEmailContent = (TextView) telephoneEmailView.findViewById(R.id.telephone_email_content);
                            TextView telephoneEmailType = (TextView) telephoneEmailView.findViewById(R.id.telephone_email_type);
                            View telephoneEmailDivideView = telephoneEmailView.findViewById(R.id.telephone_email_divide_view);
                            telephoneEmailTitle.setText(R.string.customer_basic_telephone_title);
                            telephoneEmailContent.setText(phoneInfo.phoneContent);
                            telephoneEmailType.setText(phoneTypeStr);
                            if (i == 0)
                                telephoneEmailDivideView.setVisibility(View.GONE);
                            else
                                telephoneEmailTitle.setVisibility(View.GONE);
                            customerBasicInfoActivity.customerTelephonetableLayout.addView(telephoneEmailView);
                        }
                    }
                    if (customerBasicInfoActivity.emailInfoList != null && customerBasicInfoActivity.emailInfoList.size() != 0) {
                        customerBasicInfoActivity.customerEmailtableLayout.setVisibility(View.VISIBLE);
                        customerBasicInfoActivity.customer.setEmailInfoList(customerBasicInfoActivity.emailInfoList);
                        for (int i = 0; i < customerBasicInfoActivity.emailInfoList.size(); i++) {
                            EmailInfo emailInfo = customerBasicInfoActivity.emailInfoList.get(i);
                            String emailTypeStr = "";
                            switch (emailInfo.emailType) {
                                case 0:
                                    emailTypeStr = "住宅";
                                    break;
                                case 1:
                                    emailTypeStr = "工作";
                                    break;
                                case 2:
                                    emailTypeStr = "其他";
                                    break;
                            }
                            View telephoneEmailView = customerBasicInfoActivity.layoutInflater.inflate(R.xml.customer_basci_info_telephone_email, null);
                            TextView telephoneEmailTitle = (TextView) telephoneEmailView.findViewById(R.id.telephone_email_title);
                            TextView telephoneEmailContent = (TextView) telephoneEmailView.findViewById(R.id.telephone_email_content);
                            TextView telephoneEmailType = (TextView) telephoneEmailView.findViewById(R.id.telephone_email_type);
                            View telephoneEmailDivideView = telephoneEmailView.findViewById(R.id.telephone_email_divide_view);
                            telephoneEmailTitle.setText(R.string.customer_basic_email_title);
                            telephoneEmailContent.setText(emailInfo.emailContent);
                            telephoneEmailType.setText(emailTypeStr);
                            if (i == 0)
                                telephoneEmailDivideView.setVisibility(View.GONE);
                            else
                                telephoneEmailTitle.setVisibility(View.GONE);
                            customerBasicInfoActivity.customerEmailtableLayout.addView(telephoneEmailView);
                        }
                    }
                    if (customerBasicInfoActivity.addressInfoList != null && customerBasicInfoActivity.addressInfoList.size() != 0) {
                        customerBasicInfoActivity.customerAddresstableLayout.setVisibility(View.VISIBLE);
                        customerBasicInfoActivity.customer.setAddressInfoList(customerBasicInfoActivity.addressInfoList);
                        for (int i = 0; i < customerBasicInfoActivity.addressInfoList.size(); i++) {
                            AddressInfo addressInfo = customerBasicInfoActivity.addressInfoList.get(i);
                            String addressTypeStr = "";
                            switch (addressInfo.addressType) {
                                case 0:
                                    addressTypeStr = "住宅";
                                    break;
                                case 1:
                                    addressTypeStr = "工作";
                                    break;
                                case 2:
                                    addressTypeStr = "其他";
                                    break;
                            }
                            View addressView = customerBasicInfoActivity.layoutInflater.inflate(R.xml.customer_basci_info_address, null);
                            TextView addressContent = (TextView) addressView.findViewById(R.id.address_content);
                            TextView addressType = (TextView) addressView.findViewById(R.id.address_type);
                            TextView zipcode = (TextView) addressView.findViewById(R.id.zip_code);
                            addressContent.setText(addressInfo.addressContent);
                            addressType.setText(addressTypeStr);
                            zipcode.setText(addressInfo.zipcode);
                            customerBasicInfoActivity.customerAddresstableLayout.addView(addressView);
                        }
                    }
                }
                //否则不显示联系信息 并且会员登录手机号后四位前面的都是*代替
                else {
                    ((TextView) customerBasicInfoActivity.findViewById(R.id.customer_basic_login_mobile_text)).setText(StringUtil.replaceCustomerLoginMobile(customerBasicInfoActivity.customer.getAuthorizeID()));
                }
                //注册方式
                TextView registFromText = (TextView) customerBasicInfoActivity.findViewById(R.id.customer_regist_from_text);
                if (customerBasicInfoActivity.customer.getRegistFrom() == 0)
                    registFromText.setText("商家注册");
                else if (customerBasicInfoActivity.customer.getRegistFrom() == 1)
                    registFromText.setText("顾客导入");
                else if (customerBasicInfoActivity.customer.getRegistFrom() == 2)
                    registFromText.setText("自助注册(T站)");
                //顾客来源
                TextView sourceText = (TextView) customerBasicInfoActivity.findViewById(R.id.customer_source_text);
                sourceText.setText(customerBasicInfoActivity.customer.getSourceType().getSourceTypeName());
            } else if (msg.what == 2)
                DialogUtil.createShortDialog(customerBasicInfoActivity, "您的网络貌似不给力，请重试");
            else if (msg.what == 3) {
                customerBasicInfoActivity.customerResponsiblePersonRelativelayout.setOnClickListener(null);
                String newResponsiblePersonName = (String) msg.obj;
                customerBasicInfoActivity.customer.setResponsiblePersonName(newResponsiblePersonName);
                customerBasicInfoActivity.customerResponsibleNameText.setTextColor(customerBasicInfoActivity.getApplicationContext().getResources().getColor(R.color.black));
                customerBasicInfoActivity.customerResponsibleNameText.setText(customerBasicInfoActivity.customer.getResponsiblePersonName());
            } else if (msg.what == 4) {
                DialogUtil.createShortDialog(customerBasicInfoActivity, (String) msg.obj);
            } else if (msg.what == Constant.LOGIN_ERROR) {
                DialogUtil.createShortDialog(customerBasicInfoActivity, customerBasicInfoActivity.getString(R.string.login_error_message));
                UserInfoApplication.getInstance().exitForLogin(customerBasicInfoActivity);
            } else if (msg.what == Constant.APP_VERSION_ERROR) {
                String downloadFileUrl = Constant.SERVER_URL + customerBasicInfoActivity.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(customerBasicInfoActivity);
                customerBasicInfoActivity.packageUpdateUtil = new PackageUpdateUtil(customerBasicInfoActivity, customerBasicInfoActivity.mHandler, fileCache, downloadFileUrl, false, customerBasicInfoActivity.userinfoApplication);
                customerBasicInfoActivity.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) msg.obj);
                customerBasicInfoActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            //包进行下载安装升级
            else if (msg.what == 5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
                String filename = "com.glamourpromise.beauty.business.apk";
                File file = customerBasicInfoActivity.getFileStreamPath(filename);
                file.getName();
                customerBasicInfoActivity.packageUpdateUtil.showInstallDialog();
            } else if (msg.what == -5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
            } else if (msg.what == 7) {
                int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
                ((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
            } else if (msg.what == 8) {
                customerBasicInfoActivity.customerSalesPersonRelativelayout.setOnClickListener(null);
                String newSalesPersonName = (String) msg.obj;
                customerBasicInfoActivity.customer.setSalesName(newSalesPersonName);
                customerBasicInfoActivity.customerSalesNameText.setTextColor(customerBasicInfoActivity.getApplicationContext().getResources().getColor(R.color.black));
                customerBasicInfoActivity.customerSalesNameText.setText(customerBasicInfoActivity.customer.getSalesName());
            } else if (msg.what == 9) {
                customerBasicInfoActivity.setOriginalQRcodeView((String) msg.obj);
                ImageView originalImage = (ImageView) customerBasicInfoActivity.originalImageView.findViewById(R.id.original_image);
                customerBasicInfoActivity.imageLoader.displayImage((String) msg.obj, originalImage);
                customerBasicInfoActivity.progressBar.setVisibility(View.GONE);
            } else if (msg.what == 99) {
                DialogUtil.createShortDialog(customerBasicInfoActivity, "服务器异常，请重试");
            }
            if (customerBasicInfoActivity.requestWebServiceThread != null) {
                customerBasicInfoActivity.requestWebServiceThread.interrupt();
                customerBasicInfoActivity.requestWebServiceThread = null;
            }
        }
    }

    @Override
    public void onClick(View view) {
        // TODO Auto-generated method stub
        //编辑顾客基本信息按钮
        if (view.getId() == R.id.cutomer_basic_edit) {
            Intent intent = new Intent(this, EditCustomerBasicActivity.class).addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
            Bundle mBundle = new Bundle();
            mBundle.putSerializable("customerInfo", customer);
            intent.putExtras(mBundle);
            startActivity(intent);
        }
        //点击发送发送飞语界面
        else if (view.getId() == R.id.cutomer_basic_send_message) {
            Intent sendIntent = new Intent(this, FlyMessageDetailActivity.class);
            FlyMessage flyMessage = new FlyMessage();
            flyMessage.setCustomerID(customer.getCustomerId());
            flyMessage.setCustomerName(customer.getCustomerName());
            flyMessage.setAvailable(1);
            Bundle bundle = new Bundle();
            bundle.putSerializable("flyMessage", flyMessage);
            sendIntent.putExtras(bundle);
            sendIntent.putExtra("Des", "Detail");
            sendIntent.putExtra("Source", "Customer");
            startActivity(sendIntent);
        }
        //点击更换美丽顾问
        else if (view.getId() == R.id.customer_basic_responsible_person_relativelayout) {
            Intent intent = new Intent(this, ChoosePersonActivity.class);
            intent.putExtra("personRole", "Doctor");
            intent.putExtra("checkModel", "Single");
            startActivityForResult(intent, 300);
        }
        //点击更换销售顾问
        else if (view.getId() == R.id.customer_sales_person_relativelayout) {
            Intent intent = new Intent(this, ChoosePersonActivity.class);
            intent.putExtra("personRole", "Doctor");
            intent.putExtra("checkModel", "Multi");
            intent.putExtra("setSales", true);
            startActivityForResult(intent, 400);
        } else if (view.getId() == R.id.customer_qr_code_btn) {
            getCustomerQRCode();
        }
    }

    //获取顾客的二维码
    private void getCustomerQRCode() {
        requestWebServiceThread = new Thread() {
            @Override
            public void run() {
                String methodName = "getQRCode";
                String endPoint = "WebUtility";
                JSONObject customerEcardJson = new JSONObject();
                try {
                    customerEcardJson.put("CompanyCode", userinfoApplication.getAccountInfo().getCompanyCode());
                    customerEcardJson.put("Code", userinfoApplication.getSelectedCustomerID());
                    customerEcardJson.put("Type", 0);
                    if (screenWidth == 720)
                        customerEcardJson.put("QRCodeSize", String.valueOf(10));
                    else if (screenWidth == 480)
                        customerEcardJson.put("QRCodeSize", String.valueOf(6));
                    else if (screenWidth == 1080)
                        customerEcardJson.put("QRCodeSize", String.valueOf(20));
                    else if (screenWidth == 1536)
                        customerEcardJson.put("QRCodeSize", String.valueOf(15));
                    else
                        customerEcardJson.put("QRCodeSize", String.valueOf(10));
                } catch (JSONException e) {

                }
                String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, customerEcardJson.toString(), userinfoApplication);
                if (serverRequestResult == null
                        || serverRequestResult.equals(""))
                    mHandler.sendEmptyMessage(2);
                else {

                    int code = 0;
                    String message = "";
                    JSONObject resultJson = null;
                    try {
                        resultJson = new JSONObject(serverRequestResult);
                        code = resultJson.getInt("Code");
                        message = resultJson.getString("Message");
                    } catch (JSONException e) {
                        code = 0;
                    }
                    if (code == 1) {
                        Message msg = new Message();
                        try {
                            msg.obj = resultJson.getString("Data");
                        } catch (JSONException e) {
                        }
                        msg.what = 9;
                        mHandler.sendMessage(msg);
                    } else if (code == Constant.APP_VERSION_ERROR || code == Constant.LOGIN_ERROR)
                        mHandler.sendEmptyMessage(code);
                    else {
                        mHandler.sendEmptyMessage(2);
                    }
                }
            }
        };
        requestWebServiceThread.start();
    }

    private void setOriginalQRcodeView(String originalQRcodeURL) {
        if (originalImageView == null) {
            LayoutInflater inflater = LayoutInflater.from(this);
            originalImageView = inflater.inflate(R.xml.qr_image_original_image, null);
        }

        if (originalQRCodeViewDialog == null)
            originalQRCodeViewDialog = new AlertDialog.Builder(this).create();

        originalQRCodeViewDialog.setView(originalImageView, 0, 0, 0, 0);
        progressBar = (ProgressBar) originalImageView.findViewById(R.id.pb);
        progressBar.setVisibility(View.VISIBLE);
        originalImageView.setOnClickListener(new OnClickListener() {
            public void onClick(View paramView) {
                originalQRCodeViewDialog.cancel();
            }
        });
        originalQRCodeViewDialog.show();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (resultCode == RESULT_OK) {
            // 顾客更改美丽顾问
            if (requestCode == 300) {
                int newResponsiblePersonID = data.getIntExtra("personId", 0);
                if (newResponsiblePersonID != 0) {
                    String newResponsiblePersonName = data.getStringExtra("personName");
                    addCustomerResponsiblePerson(newResponsiblePersonID, newResponsiblePersonName);
                }
            }
            //顾客更改销售顾问
            if (requestCode == 400) {
                String newSalesPersonID = data.getStringExtra("personId");
                if (newSalesPersonID != null && !"".equals(newSalesPersonID) && !"[0]".equals(newSalesPersonID)) {
                    String newSalesPersonName = data.getStringExtra("personName");
                    JSONArray newSalesJsonArray = null;
                    try {
                        newSalesJsonArray = new JSONArray(newSalesPersonID);
                    } catch (JSONException e) {
                    }
                    if (newSalesJsonArray != null)
                        addCustomerSalesPerson(newSalesJsonArray, newSalesPersonName);
                }
            }
        }
    }

    protected void addCustomerResponsiblePerson(final int newResponsiblePersonID, final String newResponsiblePersonName) {
        progressDialog = new ProgressDialog(this, R.style.CustomerProgressDialog);
        progressDialog.setMessage(getString(R.string.please_wait));
        progressDialog.show();
        progressDialog.setCancelable(false);
        requestWebServiceThread = new Thread() {
            @Override
            public void run() {
                String methodName = "addResponsiblePersonID";
                String endPoint = "customer";
                JSONObject newResponsiblePersonJson = new JSONObject();
                try {
                    newResponsiblePersonJson.put("CustomerID", userinfoApplication.getSelectedCustomerID());
                    newResponsiblePersonJson.put("AccountID", newResponsiblePersonID);
                } catch (JSONException e) {
                }
                String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, newResponsiblePersonJson.toString(), userinfoApplication);
                if (serverRequestResult == null || serverRequestResult.equals(""))
                    mHandler.sendEmptyMessage(2);
                else {
                    int code = 0;
                    String message = "";
                    try {
                        JSONObject resultJson = new JSONObject(serverRequestResult);
                        code = resultJson.getInt("Code");
                        message = resultJson.getString("Message");
                    } catch (JSONException e) {
                        code = 0;
                    }
                    Message msg = new Message();
                    if (code == 1) {
                        msg.what = 3;
                        msg.obj = newResponsiblePersonName;
                        mHandler.sendMessage(msg);
                    } else if (code == Constant.LOGIN_ERROR || code == Constant.APP_VERSION_ERROR)
                        mHandler.sendEmptyMessage(code);
                    else {
                        msg.what = 4;
                        msg.obj = message;
                        mHandler.sendMessage(msg);
                    }

                }
            }
        };
        requestWebServiceThread.start();
    }

    protected void addCustomerSalesPerson(final JSONArray newSalesPersonID, final String newSalesPersonName) {
        progressDialog = new ProgressDialog(this, R.style.CustomerProgressDialog);
        progressDialog.setMessage(getString(R.string.please_wait));
        progressDialog.show();
        progressDialog.setCancelable(false);
        requestWebServiceThread = new Thread() {
            @Override
            public void run() {
                String methodName = "updateSalesPersonID";
                String endPoint = "customer";
                JSONObject newResponsiblePersonJson = new JSONObject();
                try {
                    newResponsiblePersonJson.put("CustomerID", userinfoApplication.getSelectedCustomerID());
                    newResponsiblePersonJson.put("AccountIDList", newSalesPersonID);
                } catch (JSONException e) {
                }
                String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, newResponsiblePersonJson.toString(), userinfoApplication);
                if (serverRequestResult == null || serverRequestResult.equals(""))
                    mHandler.sendEmptyMessage(2);
                else {
                    int code = 0;
                    String message = "";
                    try {
                        JSONObject resultJson = new JSONObject(serverRequestResult);
                        code = resultJson.getInt("Code");
                        message = resultJson.getString("Message");
                    } catch (JSONException e) {
                        code = 0;
                    }
                    Message msg = new Message();
                    if (code == 1) {
                        msg.what = 8;
                        msg.obj = newSalesPersonName;
                        mHandler.sendMessage(msg);
                    } else if (code == Constant.LOGIN_ERROR || code == Constant.APP_VERSION_ERROR)
                        mHandler.sendEmptyMessage(code);
                    else {
                        msg.what = 4;
                        msg.obj = message;
                        mHandler.sendMessage(msg);
                    }
                }
            }
        };
        requestWebServiceThread.start();
    }

    @Override
    protected void onDestroy() {
        // TODO Auto-generated method stub
        super.onDestroy();
        exit = true;
        if (mHandler != null) {
            mHandler.removeCallbacksAndMessages(null);
            mHandler = null;
        }
        if (progressDialog != null) {
            progressDialog.dismiss();
            progressDialog = null;
        }
        if (requestWebServiceThread != null) {
            requestWebServiceThread.interrupt();
            requestWebServiceThread = null;
        }
    }

    private void getCustomerBasicInfo() {
        progressDialog = ProgressDialogUtil.createProgressDialog(this);
        requestWebServiceThread = new Thread() {
            @Override
            public void run() {
                String methodName = "getCustomerBasic";
                String endPoint = "customer";
                JSONObject customerBsaicJsonParam = new JSONObject();
                int selectedCustomerID = userinfoApplication.getSelectedCustomerID();
                customer = new Customer();
                customer.setCustomerId(selectedCustomerID);
                try {
                    customerBsaicJsonParam.put("CustomerID", selectedCustomerID);
                    if (screenWidth == 720 && screenHeight == 1280) {
                        customerBsaicJsonParam.put("ImageWidth", "100");
                        customerBsaicJsonParam.put("ImageHeight", "100");
                    }
                } catch (JSONException e) {
                    mHandler.sendEmptyMessage(99);
                    return;
                }
                String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, customerBsaicJsonParam.toString(), userinfoApplication);
                if (serverRequestResult == null || serverRequestResult.equals(""))
                    mHandler.sendEmptyMessage(2);
                else {
                    int code = 0;
                    JSONObject customerBasicJsonObject = null;
                    try {
                        customerBasicJsonObject = new JSONObject(serverRequestResult);
                        code = customerBasicJsonObject.getInt("Code");
                    } catch (JSONException e) {
                        mHandler.sendEmptyMessage(99);
                        return;
                    }
                    if (code == 1) {
                        JSONObject customerBasicJson = null;
                        try {
                            customerBasicJson = customerBasicJsonObject.getJSONObject("Data");
                        } catch (JSONException e) {
                            mHandler.sendEmptyMessage(99);
                            return;
                        }
                        String customerHeadImageURL = "";
                        String customerName = "";
                        String title = "";
                        String authorizeID = "";
                        String responsiblePersonName = "";
                        String salesName = "";
                        int registFrom = 0;
                        int gender = 0;
                        SourceType sourceType = new SourceType();
                        try {
                            if (customerBasicJson.has("HeadImageURL") && !customerBasicJson.isNull("HeadImageURL"))
                                customerHeadImageURL = customerBasicJson.getString("HeadImageURL");
                            if (customerBasicJson.has("CustomerName") && !customerBasicJson.isNull("CustomerName"))
                                customerName = customerBasicJson.getString("CustomerName");
                            if (customerBasicJson.has("Title") && !customerBasicJson.isNull("Title"))
                                title = customerBasicJson.getString("Title");
                            if (customerBasicJson.has("LoginMobile") && !customerBasicJson.isNull("LoginMobile"))
                                authorizeID = customerBasicJson.getString("LoginMobile");
                            if (customerBasicJson.has("ResponsiblePersonName") && !customerBasicJson.isNull("ResponsiblePersonName"))
                                responsiblePersonName = customerBasicJson.getString("ResponsiblePersonName");
                            if (customerBasicJson.has("SourceTypeID") && !customerBasicJson.isNull("SourceTypeID"))
                                sourceType.setSourceTypeID(customerBasicJson.getInt("SourceTypeID"));
                            if (customerBasicJson.has("SourceTypeName") && !customerBasicJson.isNull("SourceTypeName"))
                                sourceType.setSourceTypeName(customerBasicJson.getString("SourceTypeName"));
                            JSONArray salesJsonArray = null;
                            if (customerBasicJson.has("SalesList")) {
                                // 顾客没有销售顾问的问题对应
                                try {
                                    salesJsonArray = customerBasicJson.getJSONArray("SalesList");
                                } catch (Exception e) {
                                    // 顾客没有销售顾问
                                    salesJsonArray = null;
                                }
                            }
                            if (salesJsonArray != null) {
                                for (int j = 0; j < salesJsonArray.length(); j++) {
                                    if (j == salesJsonArray.length() - 1)
                                        salesName += salesJsonArray.getJSONObject(j).getString("SalesName");
                                    else
                                        salesName += salesJsonArray.getJSONObject(j).getString("SalesName") + "、";
                                }
                            }
                            if (customerBasicJson.has("RegistFrom") && !customerBasicJson.isNull("RegistFrom"))
                                registFrom = customerBasicJson.getInt("RegistFrom");
                            if (customerBasicJson.has("Gender") && !customerBasicJson.isNull("Gender"))
                                gender = customerBasicJson.getInt("Gender");
                            if (customerBasicJson.has("ResponsiblePersonID") && !customerBasicJson.isNull("ResponsiblePersonID"))
                                userinfoApplication.setSelectedCustomerResponsiblePersonID(customerBasicJson.getInt("ResponsiblePersonID"));
                        } catch (JSONException e) {
                            mHandler.sendEmptyMessage(99);
                            return;
                        }
                        customer.setAuthorizeID(authorizeID);
                        customer.setCustomerName(customerName);
                        customer.setHeadImageUrl(customerHeadImageURL);
                        customer.setTitle(title);
                        customer.setResponsiblePersonName(responsiblePersonName);
                        customer.setSalesName(salesName);
                        customer.setRegistFrom(registFrom);
                        customer.setGender(gender);
                        customer.setSourceType(sourceType);
                        phoneInfoList = new ArrayList<PhoneInfo>();
                        emailInfoList = new ArrayList<EmailInfo>();
                        addressInfoList = new ArrayList<AddressInfo>();
                        if (customerBasicJson.has("PhoneList") && !customerBasicJson.isNull("PhoneList")) {
                            JSONArray phoneInfoArray = null;
                            try {
                                phoneInfoArray = customerBasicJson.getJSONArray("PhoneList");
                            } catch (JSONException e) {
                                mHandler.sendEmptyMessage(99);
                                return;
                            }
                            for (int i = 0; i < phoneInfoArray.length(); i++) {
                                JSONObject phoneJson = null;
                                try {
                                    phoneJson = phoneInfoArray.getJSONObject(i);
                                } catch (JSONException e) {
                                    mHandler.sendEmptyMessage(99);
                                    return;
                                }
                                PhoneInfo phoneInfo = new PhoneInfo();
                                int phoneID = 0;
                                int phoneType = 0;
                                String phoneContent = "";
                                try {
                                    if (phoneJson.has("PhoneID") && !phoneJson.isNull("PhoneID"))
                                        phoneID = phoneJson.getInt("PhoneID");
                                    if (phoneJson.has("PhoneType") && !phoneJson.isNull("PhoneType"))
                                        phoneType = phoneJson.getInt("PhoneType");
                                    if (phoneJson.has("PhoneContent") && !phoneJson.isNull("PhoneContent"))
                                        phoneContent = phoneJson.getString("PhoneContent");
                                } catch (JSONException e) {
                                    mHandler.sendEmptyMessage(99);
                                    return;
                                }
                                phoneInfo.phoneID = phoneID;
                                phoneInfo.phoneType = phoneType;
                                phoneInfo.phoneContent = phoneContent;
                                phoneInfoList.add(phoneInfo);
                            }
                        }
                        if (customerBasicJson.has("EmailList") && !customerBasicJson.isNull("EmailList")) {
                            JSONArray emailInfoArray = null;
                            try {
                                emailInfoArray = customerBasicJson.getJSONArray("EmailList");
                            } catch (JSONException e) {
                                mHandler.sendEmptyMessage(99);
                                return;
                            }
                            for (int i = 0; i < emailInfoArray.length(); i++) {
                                JSONObject emailJson = null;
                                try {
                                    emailJson = emailInfoArray.getJSONObject(i);
                                } catch (JSONException e) {
                                    mHandler.sendEmptyMessage(99);
                                    return;
                                }
                                EmailInfo emailInfo = new EmailInfo();
                                int emailID = 0;
                                int emailType = 0;
                                String emailContent = "";
                                try {
                                    if (emailJson.has("EmailID") && !emailJson.isNull("EmailID"))
                                        emailID = emailJson.getInt("EmailID");
                                    if (emailJson.has("EmailType") && !emailJson.isNull("EmailType"))
                                        emailType = emailJson.getInt("EmailType");
                                    if (emailJson.has("EmailContent") && !emailJson.isNull("EmailContent"))
                                        emailContent = emailJson.getString("EmailContent");
                                } catch (JSONException e) {
                                    mHandler.sendEmptyMessage(99);
                                    return;
                                }
                                emailInfo.emailID = emailID;
                                emailInfo.emailType = emailType;
                                emailInfo.emailContent = emailContent;
                                emailInfoList.add(emailInfo);
                            }
                        }
                        if (customerBasicJson.has("AddressList") && !customerBasicJson.isNull("AddressList")) {
                            JSONArray addressInfoArray = null;
                            try {
                                addressInfoArray = customerBasicJson.getJSONArray("AddressList");
                            } catch (JSONException e) {
                                mHandler.sendEmptyMessage(99);
                                return;
                            }
                            for (int i = 0; i < addressInfoArray.length(); i++) {
                                JSONObject addressJson = null;
                                try {
                                    addressJson = addressInfoArray.getJSONObject(i);
                                } catch (JSONException e) {
                                    mHandler.sendEmptyMessage(99);
                                    return;
                                }
                                AddressInfo addressInfo = new AddressInfo();
                                int addressID = 0;
                                int addressType = 0;
                                String addressContent = "";
                                String zipCode = "";
                                try {
                                    if (addressJson.has("AddressID") && !addressJson.isNull("AddressID"))
                                        addressID = addressJson.getInt("AddressID");
                                    if (addressJson.has("AddressType") && !addressJson.isNull("AddressType"))
                                        addressType = addressJson.getInt("AddressType");
                                    if (addressJson.has("AddressContent") && !addressJson.isNull("AddressContent"))
                                        addressContent = addressJson.getString("AddressContent");
                                    if (addressJson.has("ZipCode") && !addressJson.isNull("ZipCode"))
                                        zipCode = addressJson.getString("ZipCode");
                                } catch (JSONException e) {
                                    mHandler.sendEmptyMessage(99);
                                    return;
                                }
                                addressInfo.addressID = addressID;
                                addressInfo.addressType = addressType;
                                addressInfo.addressContent = addressContent;
                                addressInfo.zipcode = zipCode;
                                addressInfoList.add(addressInfo);
                            }
                        }
                        mHandler.sendEmptyMessage(1);
                    } else
                        mHandler.sendEmptyMessage(code);
                }
            }
        };
        requestWebServiceThread.start();
    }
}
