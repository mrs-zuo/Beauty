package com.GlamourPromise.Beauty.Business;

import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.provider.MediaStore;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.View.OnTouchListener;
import android.view.Window;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemSelectedListener;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.Spinner;
import android.widget.SpinnerAdapter;
import android.widget.TableLayout;
import android.widget.TextView;

import com.GlamourPromise.Beauty.Thread.GetBackendServerDataByJsonThread;
import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.Customer;
import com.GlamourPromise.Beauty.bean.DiscountDetail;
import com.GlamourPromise.Beauty.bean.DownloadInfo;
import com.GlamourPromise.Beauty.bean.EcardInfo;
import com.GlamourPromise.Beauty.bean.ServerPackageVersion;
import com.GlamourPromise.Beauty.bean.SourceType;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlamourPromise.Beauty.implementation.AddNewCustomerTaskImpl;
import com.GlamourPromise.Beauty.util.Base64Util;
import com.GlamourPromise.Beauty.util.CropUtil;
import com.GlamourPromise.Beauty.util.DialogUtil;
import com.GlamourPromise.Beauty.util.FileCache;
import com.GlamourPromise.Beauty.util.GenerateMenu;
import com.GlamourPromise.Beauty.util.PackageUpdateUtil;
import com.GlamourPromise.Beauty.util.UploadImageUtil;
import com.GlamourPromise.Beauty.view.BusinessLeftImageButton;
import com.GlamourPromise.Beauty.view.BusinessRightImageButton;
import com.GlamourPromise.Beauty.webservice.WebServiceUtil;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

/*
 * 我的顾客--增加新的顾客
 * */
@SuppressLint("ResourceType")
public class AddNewCustomerActivity extends BaseActivity implements OnClickListener {
    private AddNewCustomerActivityHandler mHandler = new AddNewCustomerActivityHandler(this);
    private ImageView newCustomerHeadImage;
    private EditText newCustomerNameText;
    private EditText newCustomerTitleText;
    private TextView customerResponsiblePerson;
    private Button addNewCustomerMakeSureBtn;
    private Thread requestWebServiceThread;
    private ProgressDialog progressDialog;
    private String addNewCustomerHeadImageStr = "";
    private TableLayout newCustomerTelephoneTableLayout, customerIsImportTableLayout;
    ;
    private View finalTelephoneTableTitleView;
    private ImageButton addCustomerTelephoneRowBtn;
    private LayoutInflater layoutInflater;
    private UserInfoApplication userinfoApplication;
    private RelativeLayout customerResponsiblePersonRelativeLayout;
    private int selectedResponsiblePersonID;
    private Customer newCustomerForResult;
    private Spinner customerAuthorizeSpinner;
    private ArrayAdapter<String> customerAuthorizeAdapter;
    private List<String> customerAuthorizeSelectList;// 保存可选的授权手机号
    private String customerAuthorizeCurrentSelect;// 当前选择的授权手机号
    private HashMap<String, String> paramMap;
    private HashMap<String, JSONArray> paramJsonMap;
    private List<EcardInfo> ecardInfoList;
    private List<SourceType> sourceTypeList;
    private Spinner customerBasicEcardSpinner;
    private Spinner customerSourceTypeSpinner;
    private PackageUpdateUtil packageUpdateUtil;
    private boolean isImport;//标记顾客是否是导入顾客
    private ImageButton customerIsImportStatusIcon;
    private View customerSalesResponsibleDivideView;
    private RelativeLayout customerSalesPersonRelativelayout;
    private String customerSalesID;
    private TextView customerSalesNameText;
    private int customerSex;//0:女  1：男
    private int fromSource;//0:来自于顾客列表页  1:来自于顾客服务页
    private ImageView customerGenderFemaleSelectIcon, customerGenderMaleSelectIcon;
    private Uri imageUri;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_add_new_customer);
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
        userinfoApplication = UserInfoApplication.getInstance();
        customerBasicEcardSpinner = (Spinner) findViewById(R.id.customer_basic_ecard_spinner);
        customerSourceTypeSpinner = (Spinner) findViewById(R.id.customer_source_spinner);
        fromSource = getIntent().getIntExtra("fromSource", 0);
        customerGenderFemaleSelectIcon = (ImageView) findViewById(R.id.new_customer_gender_female_select_icon);
        customerGenderMaleSelectIcon = (ImageView) findViewById(R.id.new_customer_gender_male_select_icon);
        customerSex = 0;
        customerGenderFemaleSelectIcon.setBackgroundResource(R.drawable.customer_scan_record_status_blue_icon);
        customerGenderFemaleSelectIcon.setOnClickListener(this);
        customerGenderMaleSelectIcon.setOnClickListener(this);
        imageUri = Uri.parse(Constant.IMAGE_FILE_LOCATION);
        //获取会员等级列表
        getLevelList();

    }

    private static class AddNewCustomerActivityHandler extends Handler {
        private final AddNewCustomerActivity addNewCustomerActivity;

        private AddNewCustomerActivityHandler(AddNewCustomerActivity activity) {
            WeakReference<AddNewCustomerActivity> weakReference = new WeakReference<AddNewCustomerActivity>(activity);
            addNewCustomerActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message msg) {
            // 当activity未加载完成时,用户返回的情况
            if (addNewCustomerActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (addNewCustomerActivity.progressDialog != null) {
                addNewCustomerActivity.progressDialog.dismiss();
                addNewCustomerActivity.progressDialog = null;
            }
            if (addNewCustomerActivity.requestWebServiceThread != null) {
                addNewCustomerActivity.requestWebServiceThread.interrupt();
                addNewCustomerActivity.requestWebServiceThread = null;
            }
            if (msg.what == 1) {
                addNewCustomerActivity.newCustomerForResult = (Customer) msg.obj;
                Dialog dialog = new AlertDialog.Builder(addNewCustomerActivity, R.style.CustomerAlertDialog)
                        .setTitle(addNewCustomerActivity.getString(R.string.delete_dialog_title))
                        .setMessage(R.string.set_default_customer)
                        .setPositiveButton(addNewCustomerActivity.getString(R.string.delete_confirm),
                                new DialogInterface.OnClickListener() {
                                    @Override
                                    public void onClick(DialogInterface dialog,
                                                        int which) {
                                        dialog.dismiss();
                                        addNewCustomerActivity.userinfoApplication.setSelectedCustomerID(addNewCustomerActivity.newCustomerForResult.getCustomerId());
                                        addNewCustomerActivity.userinfoApplication.setSelectedCustomerName(addNewCustomerActivity.newCustomerForResult.getCustomerName());
                                        addNewCustomerActivity.userinfoApplication.setSelectedCustomerHeadImageURL(addNewCustomerActivity.newCustomerForResult.getHeadImageUrl());
                                        addNewCustomerActivity.userinfoApplication.setSelectedCustomerLoginMobile(addNewCustomerActivity.newCustomerForResult.getLoginMobile());
                                        addNewCustomerActivity.userinfoApplication.setSelectedIsMyCustomer(addNewCustomerActivity.newCustomerForResult.getIsMyCustomer());
                                        Intent destIntent = null;
                                        if (addNewCustomerActivity.fromSource == 0)
                                            destIntent = new Intent(addNewCustomerActivity, CustomerActivity.class);
                                        else if (addNewCustomerActivity.fromSource == 1)
                                            destIntent = new Intent(addNewCustomerActivity, CustomerServicingActivity.class);
                                        addNewCustomerActivity.startActivity(destIntent);
                                        addNewCustomerActivity.finish();
                                    }
                                })
                        .setNegativeButton(addNewCustomerActivity.getString(R.string.delete_cancel),
                                new DialogInterface.OnClickListener() {

                                    @Override
                                    public void onClick(DialogInterface dialog,
                                                        int which) {
                                        // TODO Auto-generated method stub
                                        dialog.dismiss();
                                        dialog = null;
                                        Intent destIntent = new Intent(addNewCustomerActivity, CustomerActivity.class);
                                        addNewCustomerActivity.startActivity(destIntent);
                                    }
                                }).create();
                dialog.show();
                dialog.setCancelable(false);
            } else if (msg.what == 0 || msg.what == -2 || msg.what == -3 || msg.what == -1) {
                String serverReturnMessage = (String) msg.obj;
                DialogUtil.createShortDialog(addNewCustomerActivity, serverReturnMessage);
            } else if (msg.what == 2)
                DialogUtil.createShortDialog(addNewCustomerActivity, "您的网络貌似不给力，请重试");
            else if (msg.what == 3) {
                String message = (String) msg.obj;
                // 重复数据
                Dialog dialog = new AlertDialog.Builder(addNewCustomerActivity, R.style.CustomerAlertDialog).setMessage(message + "是否继续提交？").setTitle("提示")
                        .setPositiveButton(addNewCustomerActivity.getString(R.string.delete_confirm), new DialogInterface.OnClickListener() {
                            @Override
                            public void onClick(DialogInterface dialog, int which) {
                                AddNewCustomerTaskImpl addNewCustomerTask = new AddNewCustomerTaskImpl(addNewCustomerActivity.paramMap, addNewCustomerActivity.paramJsonMap, addNewCustomerActivity.mHandler, 0, addNewCustomerActivity.userinfoApplication);
                                addNewCustomerActivity.requestWebServiceThread = new GetBackendServerDataByJsonThread(addNewCustomerTask);
                                addNewCustomerActivity.requestWebServiceThread.start();
                                dialog.dismiss();
                            }
                        })
                        .setNegativeButton(addNewCustomerActivity.getString(R.string.delete_cancel),
                                new DialogInterface.OnClickListener() {
                                    @Override
                                    public void onClick(DialogInterface dialog, int which) {
                                        // TODO Auto-generated method stub
                                        dialog.dismiss();
                                    }
                                }).create();
                dialog.show();
                dialog.setCancelable(false);
            }
            //获取会员等级列表成功
            else if (msg.what == 4) {
                if (addNewCustomerActivity.ecardInfoList.size() > 0) {
                    String[] ecardInfoNameArray = new String[addNewCustomerActivity.ecardInfoList.size()];
                    int ecardInfoNameSelection = 0;
                    for (int i = 0; i < addNewCustomerActivity.ecardInfoList.size(); i++) {
                        ecardInfoNameArray[i] = addNewCustomerActivity.ecardInfoList.get(i).getUserEcardName();
                        //设置默认选中的储值卡
                        if (addNewCustomerActivity.ecardInfoList.get(i).isDefault())
                            ecardInfoNameSelection = i;
                    }
                    ArrayAdapter<String> ecardInfoNameAdapter = null;
                    // 账户没有更改e卡等级时
                    if (addNewCustomerActivity.userinfoApplication.getAccountInfo().getAuthCustomerEcardWrite() == 0) {
                        ecardInfoNameAdapter = new ArrayAdapter<String>(addNewCustomerActivity, R.xml.spinner_checked_text_black, ecardInfoNameArray);
                        addNewCustomerActivity.customerBasicEcardSpinner.setEnabled(false);
                    } else if (addNewCustomerActivity.userinfoApplication.getAccountInfo().getAuthCustomerEcardWrite() == 1) {
                        ecardInfoNameAdapter = new ArrayAdapter<String>(addNewCustomerActivity, R.xml.spinner_checked_text, ecardInfoNameArray);
                    }
                    ecardInfoNameAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
                    addNewCustomerActivity.customerBasicEcardSpinner.setAdapter(ecardInfoNameAdapter);
                    addNewCustomerActivity.customerBasicEcardSpinner.setSelection(ecardInfoNameSelection);
                }
                //获取顾客来源
                addNewCustomerActivity.getSourceTypeList();
            } else if (msg.what == 8) {
                if (addNewCustomerActivity.sourceTypeList.size() > 0) {
                    String[] sourceTypeNameArray = new String[addNewCustomerActivity.sourceTypeList.size()];
                    for (int i = 0; i < addNewCustomerActivity.sourceTypeList.size(); i++) {
                        sourceTypeNameArray[i] = addNewCustomerActivity.sourceTypeList.get(i).getSourceTypeName();
                    }
                    ArrayAdapter<String> sourceTypeNameAdapter = new ArrayAdapter<String>(addNewCustomerActivity, R.xml.spinner_checked_text, sourceTypeNameArray);
                    ;
                    sourceTypeNameAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
                    addNewCustomerActivity.customerSourceTypeSpinner.setAdapter(sourceTypeNameAdapter);
                    addNewCustomerActivity.customerSourceTypeSpinner.setSelection(0);
                }
                addNewCustomerActivity.initView();
            }
            //获取会员等级列表失败
            else if (msg.what == 6) {
                DialogUtil.createShortDialog(addNewCustomerActivity, (String) msg.obj);
            } else if (msg.what == Constant.LOGIN_ERROR) {
                DialogUtil.createShortDialog(addNewCustomerActivity, addNewCustomerActivity.getString(R.string.login_error_message));
                addNewCustomerActivity.userinfoApplication.exitForLogin(addNewCustomerActivity);
            } else if (msg.what == Constant.APP_VERSION_ERROR) {
                String downloadFileUrl = Constant.SERVER_URL + addNewCustomerActivity.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(addNewCustomerActivity);
                addNewCustomerActivity.packageUpdateUtil = new PackageUpdateUtil(addNewCustomerActivity, addNewCustomerActivity.mHandler, fileCache, downloadFileUrl, false, addNewCustomerActivity.userinfoApplication);
                addNewCustomerActivity.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) msg.obj);
                addNewCustomerActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            //包进行下载安装升级
            else if (msg.what == 5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
                String filename = "com.glamourpromise.beauty.business.apk";
                File file = addNewCustomerActivity.getFileStreamPath(filename);
                file.getName();
                addNewCustomerActivity.packageUpdateUtil.showInstallDialog();
            } else if (msg.what == -5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
            } else if (msg.what == 7) {
                int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
                ((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
            }
        }
    }

    protected void getLevelList() {
        ecardInfoList = new ArrayList<EcardInfo>();
        requestWebServiceThread = new Thread() {
            public void run() {
                String methodName = "GetBranchCardList";
                String endPoint = "ECard";
                JSONObject getEcardListJsonParam = new JSONObject();
                try {
                    getEcardListJsonParam.put("isOnlyMoneyCard", true);
                    getEcardListJsonParam.put("isShowAll", false);
                    getEcardListJsonParam.put("BranchID", userinfoApplication.getAccountInfo().getBranchId());
                } catch (JSONException e) {
                }
                String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, getEcardListJsonParam.toString(), userinfoApplication);
                JSONObject resultJson = null;
                try {
                    resultJson = new JSONObject(serverRequestResult);
                } catch (JSONException e) {
                }
                if (serverRequestResult == null || serverRequestResult.equals(""))
                    mHandler.sendEmptyMessage(2);
                else {
                    int code = 0;
                    String message = "";
                    try {
                        code = resultJson.getInt("Code");
                        message = resultJson.getString("Message");
                    } catch (JSONException e) {
                        code = 0;
                    }
                    if (code == 1) {
                        JSONArray ecardJsonArray = null;
                        try {
                            ecardJsonArray = resultJson.getJSONArray("Data");
                        } catch (JSONException e) {
                        }
                        EcardInfo defaultEcardInfo = new EcardInfo();
                        defaultEcardInfo.setUserEcardID(0);
                        defaultEcardInfo.setUserEcardName("无");
                        defaultEcardInfo.setDefault(false);
                        ecardInfoList.add(defaultEcardInfo);
                        if (ecardJsonArray != null) {
                            for (int i = 0; i < ecardJsonArray.length(); i++) {
                                JSONObject ecardJson = null;
                                try {
                                    ecardJson = (JSONObject) ecardJsonArray.get(i);
                                } catch (JSONException e1) {
                                }
                                int cardID = 0;
                                String userEcardName = "";
                                String userEcardBalance = "";
                                String userEcardCreateDate = "";
                                String userEcardExpirationDate = "";
                                int userEcardType = 1;
                                String userEcardDescription = "";
                                JSONArray discountJsonArray = null;
                                List<DiscountDetail> discountDetailList = null;
                                boolean isDefault = false;
                                try {
                                    if (ecardJson.has("CardID") && !ecardJson.isNull("CardID"))
                                        cardID = ecardJson.getInt("CardID");
                                    if (ecardJson.has("CardName") && !ecardJson.isNull("CardName"))
                                        userEcardName = ecardJson.getString("CardName");
                                    if (ecardJson.has("Balance") && !ecardJson.isNull("Balance"))
                                        userEcardBalance = ecardJson.getString("Balance");
                                    if (ecardJson.has("CardCreatedDate") && !ecardJson.isNull("CardCreatedDate"))
                                        userEcardCreateDate = ecardJson.getString("CardCreatedDate");
                                    if (ecardJson.has("CardExpiredDate") && !ecardJson.isNull("CardExpiredDate"))
                                        userEcardExpirationDate = ecardJson.getString("CardExpiredDate");
                                    if (ecardJson.has("CardTypeID") && !ecardJson.isNull("CardTypeID"))
                                        userEcardType = ecardJson.getInt("CardTypeID");
                                    if (ecardJson.has("CardDescription") && !ecardJson.isNull("CardDescription"))
                                        userEcardDescription = ecardJson.getString("CardDescription");
                                    if (ecardJson.has("DiscountList") && !ecardJson.isNull("DiscountList"))
                                        discountJsonArray = ecardJson.getJSONArray("DiscountList");
                                    if (ecardJson.has("IsDefault") && !ecardJson.isNull("IsDefault"))
                                        isDefault = ecardJson.getBoolean("IsDefault");
                                    if (discountJsonArray != null) {
                                        discountDetailList = new ArrayList<DiscountDetail>();
                                        for (int j = 0; j < discountJsonArray.length(); j++) {
                                            JSONObject discountJson = discountJsonArray.getJSONObject(j);
                                            DiscountDetail discountDetail = new DiscountDetail();
                                            if (discountJson.has("DiscountName"))
                                                discountDetail.setDiscountDetailName(discountJson.getString("DiscountName"));
                                            if (discountJson.has("Discount"))
                                                discountDetail.setDiscountRate(discountJson.getString("Discount"));
                                            discountDetailList.add(discountDetail);
                                        }

                                    }
                                } catch (JSONException e) {
                                }
                                EcardInfo customerEcardInfo = new EcardInfo();
                                customerEcardInfo.setUserEcardID(cardID);
                                customerEcardInfo.setUserEcardName(userEcardName);
                                customerEcardInfo.setUserEcardBalance(userEcardBalance);
                                customerEcardInfo.setUserEcardCreateDate(userEcardCreateDate);
                                customerEcardInfo.setUserEcardExpirationDate(userEcardExpirationDate);
                                customerEcardInfo.setUserEcardType(userEcardType);
                                customerEcardInfo.setUserEcardDescription(userEcardDescription);
                                customerEcardInfo.setDiscountDetailList(discountDetailList);
                                customerEcardInfo.setDefault(isDefault);
                                ecardInfoList.add(customerEcardInfo);
                            }
                        }
                        mHandler.sendEmptyMessage(4);
                    } else if (code == Constant.LOGIN_ERROR || code == Constant.APP_VERSION_ERROR)
                        mHandler.sendEmptyMessage(code);
                    else {
                        Message msg = new Message();
                        msg.what = 6;
                        msg.obj = message;
                        mHandler.sendMessage(msg);
                    }
                }
            }
        };
        requestWebServiceThread.start();
    }

    protected void getSourceTypeList() {
        sourceTypeList = new ArrayList<SourceType>();
        requestWebServiceThread = new Thread() {
            public void run() {
                String methodName = "GetCustomerSourceType";
                String endPoint = "customer";
                JSONObject getSourceTypeJsonParam = new JSONObject();
                String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, getSourceTypeJsonParam.toString(), userinfoApplication);
                JSONObject resultJson = null;
                try {
                    resultJson = new JSONObject(serverRequestResult);
                } catch (JSONException e) {
                }
                if (serverRequestResult == null || serverRequestResult.equals(""))
                    mHandler.sendEmptyMessage(2);
                else {
                    int code = 0;
                    String message = "";
                    try {
                        code = resultJson.getInt("Code");
                        message = resultJson.getString("Message");
                    } catch (JSONException e) {
                        code = 0;
                    }
                    if (code == 1) {
                        JSONArray customerSourceTypeJsonArray = null;
                        try {
                            customerSourceTypeJsonArray = resultJson.getJSONArray("Data");
                        } catch (JSONException e) {
                        }
						/*SourceType  defaultSourceType=new SourceType();
						defaultSourceType.setSourceTypeID(0);
						defaultSourceType.setSourceTypeName("本店(默认)");
						sourceTypeList.add(defaultSourceType);*/
                        if (customerSourceTypeJsonArray != null) {
                            for (int i = 0; i < customerSourceTypeJsonArray.length(); i++) {
                                JSONObject sourceTypeJson = null;
                                try {
                                    sourceTypeJson = customerSourceTypeJsonArray.getJSONObject(i);
                                } catch (JSONException e) {

                                }
                                int sourceTypeID = 0;
                                String sourceTypeName = "";
                                try {
                                    if (sourceTypeJson.has("ID") && !sourceTypeJson.isNull("ID"))
                                        sourceTypeID = sourceTypeJson.getInt("ID");
                                    if (sourceTypeJson.has("Name") && !sourceTypeJson.isNull("Name"))
                                        sourceTypeName = sourceTypeJson.getString("Name");
                                } catch (JSONException e) {
                                }
                                SourceType customerSourceType = new SourceType();
                                customerSourceType.setSourceTypeID(sourceTypeID);
                                customerSourceType.setSourceTypeName(sourceTypeName);
                                sourceTypeList.add(customerSourceType);
                            }
                        }
                        mHandler.sendEmptyMessage(8);
                    } else if (code == Constant.LOGIN_ERROR || code == Constant.APP_VERSION_ERROR)
                        mHandler.sendEmptyMessage(code);
                    else {
                        Message msg = new Message();
                        msg.what = 6;
                        msg.obj = message;
                        mHandler.sendMessage(msg);
                    }
                }
            }
        };
        requestWebServiceThread.start();
    }

    protected void initView() {
        newCustomerHeadImage = (ImageView) findViewById(R.id.new_customer_head_image);
        newCustomerHeadImage.setBackgroundResource(R.drawable.head_image_null);
        customerResponsiblePersonRelativeLayout = (RelativeLayout) findViewById(R.id.customer_responsible_person_relativelayout);
        customerResponsiblePersonRelativeLayout.setOnClickListener(this);
        customerSalesResponsibleDivideView = findViewById(R.id.customer_responsible_sales_divide_view);
        customerSalesPersonRelativelayout = (RelativeLayout) findViewById(R.id.customer_sales_person_relativelayout);
        boolean hasSalesFunction = false;
        if (userinfoApplication.getAccountInfo().getModuleInUse().contains("|4|"))
            hasSalesFunction = true;
        if (hasSalesFunction)
            customerSalesPersonRelativelayout.setOnClickListener(this);
        else if (!hasSalesFunction) {
            customerSalesResponsibleDivideView.setVisibility(View.GONE);
            customerSalesPersonRelativelayout.setVisibility(View.GONE);
        }
        newCustomerTelephoneTableLayout = (TableLayout) findViewById(R.id.new_customer_telephone_tablelayout);
        customerIsImportTableLayout = (TableLayout) findViewById(R.id.customer_is_import_tablelayout);
        customerIsImportTableLayout.setOnClickListener(this);
        finalTelephoneTableTitleView = findViewById(R.id.new_customer_telephone_relativeLayout);
        addCustomerTelephoneRowBtn = (ImageButton) findViewById(R.id.plus_customer_telephone_tablerow);
        addCustomerTelephoneRowBtn.setOnClickListener(this);
        layoutInflater = LayoutInflater.from(this);
        isImport = false;
        customerIsImportStatusIcon = (ImageButton) findViewById(R.id.customer_is_import_status_icon);
        newCustomerHeadImage.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                // TODO Auto-generated method stub
                final CharSequence[] items = {"相册", "拍照"};

                AlertDialog dlg = new AlertDialog.Builder(AddNewCustomerActivity.this, R.style.CustomerAlertDialog).setTitle("选择照片")
                        .setItems(items, new DialogInterface.OnClickListener() {
                            @Override
                            public void onClick(DialogInterface dialog, int which) {
                                if (which == 1) {
                                    Intent getImageByCamera = new Intent("android.media.action.IMAGE_CAPTURE");
                                    getImageByCamera.putExtra(MediaStore.EXTRA_OUTPUT, imageUri);
                                    startActivityForResult(getImageByCamera, 1);
                                } else {
                                    Intent getImage = new Intent(Intent.ACTION_GET_CONTENT);
                                    getImage.addCategory(Intent.CATEGORY_OPENABLE);
                                    getImage.setType("image/jpeg");
                                    startActivityForResult(getImage, 0);
                                }
                            }
                        }).create();
                dlg.show();
            }
        });
        newCustomerNameText = (EditText) findViewById(R.id.new_customer_name);
        newCustomerTitleText = (EditText) findViewById(R.id.new_customer_title);
        addNewCustomerMakeSureBtn = (Button) findViewById(R.id.add_new_customer_make_sure_btn);
        addNewCustomerMakeSureBtn.setOnClickListener(this);
        customerResponsiblePerson = (TextView) findViewById(R.id.customer_responsible_person_text);
        customerResponsiblePerson.setText(userinfoApplication.getAccountInfo().getAccountName());
        selectedResponsiblePersonID = userinfoApplication.getAccountInfo().getAccountId();
        customerSalesNameText = (TextView) findViewById(R.id.customer_sales_person_text);
        customerSalesNameText.setText("");
        customerAuthorizeSpinner = (Spinner) findViewById(R.id.new_customer_authorize_content_text_spinner);
        customerAuthorizeSelectList = new ArrayList<String>();
        customerAuthorizeSelectList.add("无");
        customerAuthorizeCurrentSelect = customerAuthorizeSelectList.get(0);
        // 将可选内容与ArrayAdapter连接起来
        customerAuthorizeAdapter = new ArrayAdapter<String>(this, R.xml.spinner_checked_text, customerAuthorizeSelectList);
        // 设置下拉列表的风格
        customerAuthorizeAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        // 将adapter 添加到spinner中
        customerAuthorizeSpinner.setAdapter(customerAuthorizeAdapter);
        customerAuthorizeSpinner.setOnItemSelectedListener(new OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> arg0, View arg1, int arg2, long arg3) {
                customerAuthorizeCurrentSelect = customerAuthorizeSpinner.getSelectedItem().toString();
            }

            @Override
            public void onNothingSelected(AdapterView<?> arg0) {
            }
        });
        customerAuthorizeSpinner.setOnTouchListener(new OnTouchListener() {

            @Override
            public boolean onTouch(View v, MotionEvent event) {
                if (event.getAction() == MotionEvent.ACTION_UP) {
                    updateAuthorizePhoneList();
                }
                return false;
            }
        });
    }

    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        // TODO Auto-generated method stub
        super.onActivityResult(requestCode, resultCode, data);
        if (resultCode != RESULT_OK)
            return;
        Bitmap myBitmap = null;
        byte[] mContent = null;
        // 从相册中获取图片
        if (requestCode == 0) {
            try {
                if (data != null) {
                    Uri selectedImage = data.getData();
                    CropUtil.cropImageByPhoto(this, selectedImage, imageUri, Constant.CROPIMAGEWIDTH, Constant.CROPIMAGEHEIGHT, Constant.CROP_PICTURE);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        // 拍照获取图片
        else if (requestCode == 1 && resultCode != RESULT_CANCELED) {
            CropUtil.cropImageByCamera(this, imageUri, Constant.CROPIMAGEWIDTH, Constant.CROPIMAGEHEIGHT, Constant.CROP_PICTURE);
        } else if (requestCode == Constant.CROP_PICTURE) {
            if (imageUri != null) {
                myBitmap = CropUtil.decodeBitmapImageUri(this, imageUri);
                ByteArrayOutputStream baos = new ByteArrayOutputStream();
                myBitmap.compress(Bitmap.CompressFormat.JPEG, 100, baos);
                // 压缩图片
                myBitmap = UploadImageUtil.resizeBitmap(myBitmap, Constant.RESIZEBITMAPMAXWIDTH, Constant.RESIZEBITMAPMAXWIDTH);
                if (baos != null)
                    mContent = baos.toByteArray();
                newCustomerHeadImage.setImageBitmap(myBitmap);
            }
        } else if (resultCode == RESULT_OK) {
            if (requestCode == 300) {
                selectedResponsiblePersonID = data.getIntExtra("personId", 0);
                customerResponsiblePerson.setText(data.getStringExtra("personName"));
            } else if (requestCode == 400) {
                customerSalesID = data.getStringExtra("personId");
                customerSalesNameText.setText(data.getStringExtra("personName"));
            }
        }
        if (mContent != null)
            addNewCustomerHeadImageStr = new String(Base64Util.encode(mContent));
    }

    @Override
    public void onClick(View view) {
        // TODO Auto-generated method stub
        switch (view.getId()) {
            case R.id.plus_customer_telephone_tablerow:
                final View telephoneTableRowView = layoutInflater.inflate(R.xml.customer_basci_info_tablerow, null);
                int telephoneChildCount = newCustomerTelephoneTableLayout.getChildCount();
                if (telephoneChildCount == 1) {
                    newCustomerTelephoneTableLayout.removeViewAt(telephoneChildCount - 1);
                    View telephoneTableTitleView = layoutInflater.inflate(R.xml.customer_basci_info_table_title, null);
                    EditText customerTelephoneTitleEditText = (EditText) telephoneTableTitleView.findViewById(R.id.customer_basic_info_edit_text);
                    customerTelephoneTitleEditText.setHint(R.string.telephone_info);
                    ImageButton delTelaphoneTableRow = (ImageButton) telephoneTableTitleView.findViewById(R.id.del_customer_basic_info_table_row);
                    delTelaphoneTableRow.setOnClickListener(new OnClickListener() {
                        @Override
                        public void onClick(View arg0) {
                            // TODO Auto-generated method stub
                            if (newCustomerTelephoneTableLayout.getChildCount() == 2) {
                                newCustomerTelephoneTableLayout.removeAllViews();
                                newCustomerTelephoneTableLayout.addView(finalTelephoneTableTitleView);
                            } else if (newCustomerTelephoneTableLayout.getChildCount() > 2) {
                                View telephoneTableView = newCustomerTelephoneTableLayout.getChildAt(1);
                                View telephoneTableTitleView = newCustomerTelephoneTableLayout.getChildAt(0);
                                EditText customerTelephoneTitleEditText = (EditText) telephoneTableTitleView.findViewById(R.id.customer_basic_info_edit_text);
                                EditText customerTelephoneEditText = (EditText) telephoneTableView.findViewById(R.id.customer_basic_info_edit_text);
                                customerTelephoneTitleEditText.setText(customerTelephoneEditText.getText());
                                Spinner customerTelephoneTitleSpinner = (Spinner) telephoneTableTitleView.findViewById(R.id.customer_basic_telephone_spinner);
                                Spinner customerTelephoneSpinner = (Spinner) telephoneTableTitleView.findViewById(R.id.customer_basic_telephone_spinner);
                                customerTelephoneTitleSpinner.setSelection(customerTelephoneSpinner.getSelectedItemPosition(), true);
                                newCustomerTelephoneTableLayout.removeViewAt(1);
                            }
                            updatecustomerAuthorizeSpinnerSelectItem();
                        }
                    });
                    newCustomerTelephoneTableLayout.addView(telephoneTableTitleView);
                    View telephoneTableFootView = layoutInflater.inflate(R.xml.customer_basci_info_table_foot, null);
                    ImageButton telephoneFootAddBtn = (ImageButton) telephoneTableFootView.findViewById(R.id.plus_customer_telephone_tablerow);
                    telephoneFootAddBtn.setOnClickListener(this);
                    newCustomerTelephoneTableLayout.addView(telephoneTableFootView);
                } else
                    newCustomerTelephoneTableLayout.addView(telephoneTableRowView, telephoneChildCount - 1);
                ImageButton delTelaphoneTableRow = (ImageButton) telephoneTableRowView.findViewById(R.id.del_customer_basic_info_table_row);
                delTelaphoneTableRow.setOnClickListener(new OnClickListener() {
                    @Override
                    public void onClick(View view) {
                        // TODO Auto-generated method stub
                        newCustomerTelephoneTableLayout.removeView(telephoneTableRowView);
                        updatecustomerAuthorizeSpinnerSelectItem();
                    }
                });
                EditText customerTelephoneEditText = (EditText) telephoneTableRowView.findViewById(R.id.customer_basic_info_edit_text);
                customerTelephoneEditText.setHint(R.string.telephone_info);
                break;
            case R.id.add_new_customer_make_sure_btn:
                final JSONArray phoneJSONArray = new JSONArray();
                final JSONArray emailJSONArray = new JSONArray();
                final JSONArray addressJSONArray = new JSONArray();
                final String newCustomerName = newCustomerNameText.getText().toString().trim();
                final String newCustomerTitle = newCustomerTitleText.getText().toString();
                final String newCustomerAuthorize = customerAuthorizeCurrentSelect;
                if (newCustomerName == null || ("").equals(newCustomerName))
                    DialogUtil.createShortDialog(this, "客户姓名不允许为空！");
                else {
                    progressDialog = new ProgressDialog(this, R.style.CustomerProgressDialog);
                    progressDialog.setMessage(getString(R.string.please_wait));
                    progressDialog.show();
                    int telephoneSubmitChildCount = newCustomerTelephoneTableLayout.getChildCount();
                    if (telephoneSubmitChildCount > 1) {
                        JSONObject phoneJSONObject;
                        for (int i = 0; i < telephoneSubmitChildCount - 1; i++) {
                            View telephoneChildView = newCustomerTelephoneTableLayout.getChildAt(i);
                            String telephoneNumber = ((EditText) telephoneChildView.findViewById(R.id.customer_basic_info_edit_text)).getText().toString();
                            int telephoneType = ((Spinner) telephoneChildView.findViewById(R.id.customer_basic_telephone_spinner)).getSelectedItemPosition();
                            phoneJSONObject = new JSONObject();
                            try {
                                phoneJSONObject.put("PhoneType", telephoneType);
                                phoneJSONObject.put("PhoneContent", telephoneNumber);
                                phoneJSONArray.put(phoneJSONObject);
                            } catch (JSONException e) {
                            }
                        }
                    }
                    paramMap = new HashMap<String, String>();
                    paramMap.put("ResponsiblePersonID", String.valueOf(selectedResponsiblePersonID));
                    paramMap.put("Gender", String.valueOf(customerSex));
                    paramMap.put("SalesID", String.valueOf(customerSalesID));
                    paramMap.put("CustomerName", newCustomerName);
                    paramMap.put("CardID", String.valueOf(ecardInfoList.get(customerBasicEcardSpinner.getSelectedItemPosition()).getUserEcardID()));
                    paramMap.put("SourceType", String.valueOf(sourceTypeList.get(customerSourceTypeSpinner.getSelectedItemPosition()).getSourceTypeID()));
                    if (newCustomerTitle != null && !(("").equals(newCustomerTitle)))
                        paramMap.put("Title", newCustomerTitle);
                    else
                        paramMap.put("Title", "");
                    if (newCustomerAuthorize != null
                            && !("").equals(newCustomerAuthorize)
                            && !("无").equals(newCustomerAuthorize))
                        paramMap.put("LoginMobile", newCustomerAuthorize);
                    else
                        paramMap.put("LoginMobile", "");
                    if (addNewCustomerHeadImageStr != null
                            && !(("").equals(addNewCustomerHeadImageStr))) {
                        paramMap.put("HeadFlag", "1");
                        paramMap.put("ImageString", addNewCustomerHeadImageStr);
                        paramMap.put("ImageType", ".JPEG");
                    } else {
                        paramMap.put("HeadFlag", String.valueOf(0));
                        paramMap.put("ImageString", "");
                        paramMap.put("ImageType", "");
                    }
                    paramMap.put("IsPast", String.valueOf(isImport));
                    paramJsonMap = new HashMap<String, JSONArray>();
                    paramJsonMap.put("PhoneList", phoneJSONArray);
                    paramJsonMap.put("EmailList", emailJSONArray);
                    paramJsonMap.put("AddressList", addressJSONArray);
                    AddNewCustomerTaskImpl addNewCustomerTask = new AddNewCustomerTaskImpl(paramMap, paramJsonMap, mHandler, 1, userinfoApplication);
                    requestWebServiceThread = new GetBackendServerDataByJsonThread(addNewCustomerTask);
                    requestWebServiceThread.start();
                }
                break;
            //选择顾客的美丽顾问
            case R.id.customer_responsible_person_relativelayout:
                Intent intent = new Intent(this, ChoosePersonActivity.class);
                intent.putExtra("personRole", "Doctor");
                intent.putExtra("checkModel", "Single");
                intent.putExtra("mustSelectOne", true);
                JSONArray responsiblePersonArray = new JSONArray();
                responsiblePersonArray.put(selectedResponsiblePersonID);
                intent.putExtra("selectPersonIDs", responsiblePersonArray.toString());
                intent.putExtra("getCustomerResponsiblePerson", true);
                startActivityForResult(intent, 300);
                break;
            //选择顾客的销售顾问
            case R.id.customer_sales_person_relativelayout:
                Intent destintent = new Intent(this, ChoosePersonActivity.class);
                destintent.putExtra("personRole", "Doctor");
                destintent.putExtra("checkModel", "Multi");
                destintent.putExtra("mustSelectOne", false);
                JSONArray salesPersonArray = null;
                try {
                    if (customerSalesID != null && !"".equals(customerSalesID)) {
                        salesPersonArray = new JSONArray(customerSalesID);
                        destintent.putExtra("selectPersonIDs", salesPersonArray.toString());
                    }
                } catch (JSONException e) {
                }
                startActivityForResult(destintent, 400);
                break;
            //点击顾客导入的事件
            case R.id.customer_is_import_tablelayout:
                if (isImport) {
                    customerIsImportStatusIcon.setBackgroundResource(R.drawable.customer_scan_record_status_gray_icon);
                    isImport = false;
                } else if (!isImport) {
                    customerIsImportStatusIcon.setBackgroundResource(R.drawable.customer_scan_record_status_blue_icon);
                    isImport = true;
                }
                break;
            case R.id.new_customer_gender_female_select_icon:
                changeCustomerGender();
                break;
            case R.id.new_customer_gender_male_select_icon:
                changeCustomerGender();
                break;
        }
    }

    protected void changeCustomerGender() {
        if (customerSex == 0) {
            customerGenderFemaleSelectIcon.setBackgroundResource(R.drawable.customer_scan_record_status_gray_icon);
            customerGenderMaleSelectIcon.setBackgroundResource(R.drawable.customer_scan_record_status_blue_icon);
            customerSex = 1;
        } else if (customerSex == 1) {
            customerGenderFemaleSelectIcon.setBackgroundResource(R.drawable.customer_scan_record_status_blue_icon);
            customerGenderMaleSelectIcon.setBackgroundResource(R.drawable.customer_scan_record_status_gray_icon);
            customerSex = 0;
        }
    }

    @Override
    protected void onDestroy() {
        // TODO Auto-generated method stub
        super.onDestroy();
        exit = true;
        if (mHandler != null) {
            mHandler.removeCallbacksAndMessages(null);
            // mHandler = null;
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

    private void updateAuthorizePhoneList() {
        customerAuthorizeSelectList.clear();
        for (int j = 0; j < newCustomerTelephoneTableLayout.getChildCount() - 1; j++) {
            View telephoneChildView = newCustomerTelephoneTableLayout.getChildAt(j);
            String telephoneNumber = ((EditText) telephoneChildView.findViewById(R.id.customer_basic_info_edit_text)).getText().toString();
            int phoneType = ((Spinner) telephoneChildView.findViewById(R.id.customer_basic_telephone_spinner)).getSelectedItemPosition();
            if (!telephoneNumber.equals("") && phoneType == 0 && telephoneNumber.length() >= 8 && telephoneNumber.length() <= 13)
                customerAuthorizeSelectList.add(telephoneNumber);
        }
        customerAuthorizeSelectList.add("无");
        if (customerAuthorizeSelectList.size() == 1) {
            customerAuthorizeCurrentSelect = "无";
            customerAuthorizeSpinner.removeAllViewsInLayout();
            customerAuthorizeSpinner.setSelection(0, true);
        } else
            setSpinnerItemSelectedByValue(customerAuthorizeSpinner);
    }

    /**
     * 根据值, 设置spinner默认选中:
     *
     * @param spinner
     */
    public void setSpinnerItemSelectedByValue(Spinner spinner) {
        SpinnerAdapter apsAdapter = spinner.getAdapter(); // 得到SpinnerAdapter对象
        int k = apsAdapter.getCount();
        int i;
        for (i = 0; i < k; i++) {
            if (customerAuthorizeCurrentSelect.equals(apsAdapter.getItem(i)
                    .toString())) {
                spinner.setSelection(i, true);// 默认选中项
                break;
            }
        }
        // 如果customerAuthorizeCurrentSelect没有与List匹配的项（被删除的情况），则设置默认值
        if (i == k) {
            spinner.setSelection(0, true);
            customerAuthorizeCurrentSelect = apsAdapter.getItem(0).toString();
        }
    }

    @Override
    public boolean onKeyUp(int keyCode, KeyEvent event) {
        // TODO Auto-generated method stub
        if (keyCode == KeyEvent.KEYCODE_BACK) {
            Intent destIntent = new Intent(this, CustomerActivity.class);
            startActivity(destIntent);
            this.finish();
        }
        return super.onKeyUp(keyCode, event);
    }

    private void updatecustomerAuthorizeSpinnerSelectItem() {
        int customerTelephoneCount = 0;
        for (int j = 0; j < newCustomerTelephoneTableLayout.getChildCount() - 1; j++) {
            View telephoneChildView = newCustomerTelephoneTableLayout.getChildAt(j);
            String telephoneNumber = "";
            if (telephoneChildView.findViewById(R.id.customer_basic_info_edit_text) != null) {
                telephoneNumber = ((EditText) telephoneChildView.findViewById(R.id.customer_basic_info_edit_text)).getText().toString();
            }
            if (!telephoneNumber.equals(""))
                customerTelephoneCount++;
        }
        if (customerTelephoneCount == 0) {
            customerAuthorizeSelectList.clear();
            customerAuthorizeSelectList.add("无");
            customerAuthorizeCurrentSelect = "无";
            customerAuthorizeSpinner.removeAllViewsInLayout();
            customerAuthorizeSpinner.setSelection(0, true);
        }

    }
}
