package cn.com.antika.business;

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
import android.text.Editable;
import android.text.InputType;
import android.text.TextWatcher;
import android.util.Log;
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
import android.widget.Spinner;
import android.widget.SpinnerAdapter;
import android.widget.TableLayout;

import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;
import java.util.Timer;

import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.AddressInfo;
import cn.com.antika.bean.Customer;
import cn.com.antika.bean.DownloadInfo;
import cn.com.antika.bean.EmailInfo;
import cn.com.antika.bean.PhoneInfo;
import cn.com.antika.bean.ServerPackageVersion;
import cn.com.antika.bean.SourceType;
import cn.com.antika.constant.Constant;
import cn.com.antika.timer.DialogTimerTask;
import cn.com.antika.util.Base64Util;
import cn.com.antika.util.CropUtil;
import cn.com.antika.util.DialogUtil;
import cn.com.antika.util.FileCache;
import cn.com.antika.util.GenerateMenu;
import cn.com.antika.util.ImageLoaderUtil;
import cn.com.antika.util.PackageUpdateUtil;
import cn.com.antika.util.UploadImageUtil;
import cn.com.antika.view.BusinessLeftImageButton;
import cn.com.antika.view.BusinessRightImageButton;
import cn.com.antika.webservice.WebServiceUtil;

/*
 * 我的顾客--编辑基本信息
 * */
@SuppressLint({"NewApi", "ResourceType"})
public class EditCustomerBasicActivity extends BaseActivity implements OnClickListener {
    private EditCustomerBasicActivityHandler mHandler = new EditCustomerBasicActivityHandler(this);
    private ImageView customerHeadImageView;
    private ImageLoader imageLoader;
    private EditText customerBasicName, customerBasicSex;
    private TableLayout customerTelephonetableLayout, customerEmailtableLayout, customerAddresstableLayout;
    private ImageButton addCustomerAddressRowBtn;
    private Thread requestWebServiceThread;
    private Customer customer;
    private ProgressDialog progressDialog;
    private JSONArray phoneList = new JSONArray(), emailList = new JSONArray(), addressList = new JSONArray();
    private int deletePhoneListCount = 0, deleteEmailCount = 0, deleteAddressCount = 0;
    private String updateHeadImageStr = "";
    private UserInfoApplication userinfoApplication;
    private LayoutInflater layoutInflater;
    private Spinner customerAuthorizeSpinner;
    private ArrayAdapter<String> customerAuthorizeAdapter;
    private List<String> customerAuthorizeSelectList;// 保存可选的授权手机号
    private String customerAuthorizeCurrentSelect;// 当前选择的授权手机号
    private Timer dialogTimer;
    private PackageUpdateUtil packageUpdateUtil;
    private DisplayImageOptions displayImageOptions;
    private Button editCustomerBasicMakeSureBtn, deleteCustomerBasicBtn;
    private ImageView customerGenderFemaleSelectIcon, customerGenderMaleSelectIcon;
    private Uri imageUri;
    private List<SourceType> sourceTypeList;
    private Spinner customerSourceTypeSpinner;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_edit_customer_basic);
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
        addCustomerAddressRowBtn = (ImageButton) findViewById(R.id.plus_customer_address_tablerow);
        addCustomerAddressRowBtn.setOnClickListener(this);
        layoutInflater = LayoutInflater.from(this);
        customer = (Customer) getIntent().getSerializableExtra("customerInfo");
        customerHeadImageView = (ImageView) findViewById(R.id.cutomer_headimage_detail);
        customerBasicName = (EditText) findViewById(R.id.customer_basic_name);
        customerBasicSex = (EditText) findViewById(R.id.customer_basic_sex);
        customerAuthorizeSpinner = (Spinner) findViewById(R.id.authorize_select_spinner);
        editCustomerBasicMakeSureBtn = (Button) findViewById(R.id.edit_customer_basic_make_sure_btn);
        editCustomerBasicMakeSureBtn.setOnClickListener(this);
        deleteCustomerBasicBtn = (Button) findViewById(R.id.delete_customer_basic_btn);
        deleteCustomerBasicBtn.setOnClickListener(this);
        imageLoader = ImageLoader.getInstance();
        displayImageOptions = ImageLoaderUtil.getDisplayImageOptions(R.drawable.head_image_null);
        imageLoader.displayImage(customer.getHeadImageUrl(), customerHeadImageView, displayImageOptions);
        customerBasicName.setText(customer.getCustomerName());
        customerBasicSex.setText(customer.getTitle());

        customerTelephonetableLayout = (TableLayout) findViewById(R.id.customer_basic_telephone_tablelayout);
        customerEmailtableLayout = (TableLayout) findViewById(R.id.customer_basic_email_tablelayout);
        customerAddresstableLayout = (TableLayout) findViewById(R.id.customer_basic_address_tablelayout);
        List<PhoneInfo> phoneInfoList = customer.getPhoneInfoList();
        List<EmailInfo> emailInfoList = customer.getEmailInfoList();
        List<AddressInfo> addressInfoList = customer.getAddressInfoList();
        userinfoApplication = UserInfoApplication.getInstance();
        customerAuthorizeCurrentSelect = customer.getAuthorizeID();
        customerGenderFemaleSelectIcon = (ImageView) findViewById(R.id.new_customer_gender_female_select_icon);
        customerGenderMaleSelectIcon = (ImageView) findViewById(R.id.new_customer_gender_male_select_icon);
        customerGenderFemaleSelectIcon.setOnClickListener(this);
        customerGenderMaleSelectIcon.setOnClickListener(this);
        imageUri = Uri.parse(Constant.IMAGE_FILE_LOCATION);
        if (customer.getGender() == 0) {
            customerGenderFemaleSelectIcon.setBackgroundResource(R.drawable.customer_scan_record_status_blue_icon);
            customerGenderMaleSelectIcon.setBackgroundResource(R.drawable.customer_scan_record_status_gray_icon);
        } else if (customer.getGender() == 1) {
            customerGenderFemaleSelectIcon.setBackgroundResource(R.drawable.customer_scan_record_status_gray_icon);
            customerGenderMaleSelectIcon.setBackgroundResource(R.drawable.customer_scan_record_status_blue_icon);
        }
        customerAuthorizeSelectList = new ArrayList<String>();
        if (phoneInfoList != null) {
            for (int i = 0; i < phoneInfoList.size(); i++)
                customerAuthorizeSelectList.add(phoneInfoList.get(i).phoneContent);
        } else
            customerAuthorizeSelectList.add("无");
        // 将可选内容与ArrayAdapter连接起来
        customerAuthorizeAdapter = new ArrayAdapter<String>(this, R.xml.spinner_checked_text, customerAuthorizeSelectList);
        // 设置下拉列表的风格
        customerAuthorizeAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        // 将adapter 添加到spinner中
        customerAuthorizeSpinner.setAdapter(customerAuthorizeAdapter);
        customerSourceTypeSpinner = (Spinner) findViewById(R.id.customer_source_spinner);
        customerAuthorizeSpinner.setOnItemSelectedListener(new OnItemSelectedListener() {

            @Override
            public void onItemSelected(AdapterView<?> arg0, View arg1, int arg2, long arg3) {
                // TODO Auto-generated method stub
                customerAuthorizeCurrentSelect = customerAuthorizeSpinner.getSelectedItem().toString();
            }

            @Override
            public void onNothingSelected(AdapterView<?> arg0) {
                // TODO Auto-generated method stub

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
        customerHeadImageView.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                // TODO Auto-generated method stub
                final CharSequence[] items = {"相册", "拍照"};
                AlertDialog dlg = new AlertDialog.Builder(EditCustomerBasicActivity.this, R.style.CustomerAlertDialog).setTitle("选择照片").setItems(items, new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog,
                                        int which) {
                        // 在items数组里面定义了两种方式，拍照的下标为1所以就调用拍照方法
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
        //是否能编辑所有顾客的联系信息
        int authAllCustomerContactInfoWrite = userinfoApplication.getAccountInfo().getAuthAllCustomerContactInfoWrite();
        if (authAllCustomerContactInfoWrite == 1 || userinfoApplication.getSelectedCustomerResponsiblePersonID() == userinfoApplication.getAccountInfo().getAccountId()) {
            if (phoneInfoList != null && phoneInfoList.size() != 0) {
                for (int i = 0; i < phoneInfoList.size(); i++) {
                    final PhoneInfo phoneInfo = phoneInfoList.get(i);
                    if (i == 0) {
                        final View telephoneHeadView = layoutInflater.inflate(R.xml.customer_basci_info_tablerow, null);
                        final EditText telephoneHeadContent = (EditText) telephoneHeadView.findViewById(R.id.customer_basic_info_edit_text);
                        ImageButton delTelephoneContentBtn = (ImageButton) telephoneHeadView.findViewById(R.id.del_customer_basic_info_table_row);
                        final Spinner telephoneTypeSpinner = (Spinner) telephoneHeadView.findViewById(R.id.customer_basic_telephone_spinner);
                        telephoneHeadContent.setText(phoneInfoList.get(i).phoneContent);
                        telephoneHeadContent.addTextChangedListener(new TextWatcher() {
                            @Override
                            public void onTextChanged(CharSequence s, int start, int before, int count) {
                            }

                            @Override
                            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
                            }

                            @Override
                            public void afterTextChanged(Editable s) {
                                if (s != null) {
                                    if (!(s.toString().equals(phoneInfo.phoneContent))) {
                                        JSONObject phoneJson = new JSONObject();
                                        try {
                                            phoneJson.put("OperationFlag", 2);
                                            phoneJson.put("PhoneID", phoneInfo.phoneID);
                                            phoneJson.put("PhoneType", telephoneTypeSpinner.getSelectedItemPosition());
                                            phoneJson.put("PhoneContent", s.toString());
                                            phoneList.put(phoneJson);
                                        } catch (JSONException e) {
                                        }
                                    }
                                }
                            }
                        });
                        int telephoneType = phoneInfoList.get(i).phoneType;
                        telephoneTypeSpinner.setSelection(telephoneType);
                        telephoneTypeSpinner.setOnItemSelectedListener(new OnItemSelectedListener() {
                            @Override
                            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                                if (position != phoneInfo.phoneType) {
                                    JSONObject phoneJson = new JSONObject();
                                    try {
                                        phoneJson.put("OperationFlag", 2);
                                        phoneJson.put("PhoneID", phoneInfo.phoneID);
                                        phoneJson.put("PhoneType", position);
                                        phoneJson.put("PhoneContent", telephoneHeadContent.getText().toString());
                                        phoneList.put(phoneJson);
                                    } catch (JSONException e) {
                                    }
                                }
                            }

                            @Override
                            public void onNothingSelected(AdapterView<?> parent) {
                            }
                        });
                        delTelephoneContentBtn.setOnClickListener(new OnClickListener() {

                            @Override
                            public void onClick(View view) {
                                // TODO Auto-generated method stub
                                customerTelephonetableLayout.removeView(telephoneHeadView);
                                JSONObject phoneJson = new JSONObject();
                                try {
                                    phoneJson.put("OperationFlag", 3);
                                    phoneJson.put("PhoneID", phoneInfo.phoneID);
                                    phoneJson.put("PhoneType", phoneInfo.phoneType);
                                    phoneJson.put("PhoneContent", phoneInfo.phoneContent);
                                    phoneList.put(phoneJson);
                                } catch (JSONException e) {
                                }
                                deletePhoneListCount++;
                                updatecustomerAuthorizeSpinnerSelectItem();
                            }
                        });
                        customerTelephonetableLayout.addView(telephoneHeadView);
                    } else {
                        final View telephoneView = layoutInflater.inflate(R.xml.customer_basci_info_tablerow, null);
                        final EditText telephoneContent = (EditText) telephoneView.findViewById(R.id.customer_basic_info_edit_text);
                        ImageButton delTelephoneContentBtn = (ImageButton) telephoneView.findViewById(R.id.del_customer_basic_info_table_row);
                        final Spinner telephoneTypeSpinner = (Spinner) telephoneView.findViewById(R.id.customer_basic_telephone_spinner);
                        telephoneContent.setText(phoneInfoList.get(i).phoneContent);
                        telephoneContent.addTextChangedListener(new TextWatcher() {
                            @Override
                            public void onTextChanged(CharSequence s, int start, int before, int count) {
                            }

                            @Override
                            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
                            }

                            @Override
                            public void afterTextChanged(Editable s) {
                                if (s != null) {
                                    if (!(s.toString().equals(phoneInfo.phoneContent))) {
                                        JSONObject phoneJson = new JSONObject();
                                        try {
                                            phoneJson.put("OperationFlag", 2);
                                            phoneJson.put("PhoneID", phoneInfo.phoneID);
                                            phoneJson.put("PhoneType", telephoneTypeSpinner.getSelectedItemPosition());
                                            phoneJson.put("PhoneContent", s.toString());
                                            phoneList.put(phoneJson);
                                        } catch (JSONException e) {

                                        }
                                    }
                                }
                            }
                        });
                        int telephoneType = phoneInfoList.get(i).phoneType;
                        telephoneTypeSpinner.setSelection(telephoneType);
                        telephoneTypeSpinner.setOnItemSelectedListener(new OnItemSelectedListener() {
                            @Override
                            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                                if (position != phoneInfo.phoneType) {
                                    JSONObject phoneJson = new JSONObject();
                                    try {
                                        phoneJson.put("OperationFlag", 2);
                                        phoneJson.put("PhoneID", phoneInfo.phoneID);
                                        phoneJson.put("PhoneType", position);
                                        phoneJson.put("PhoneContent", telephoneContent.getText().toString());
                                        phoneList.put(phoneJson);
                                    } catch (JSONException e) {
                                    }
                                }
                            }

                            @Override
                            public void onNothingSelected(AdapterView<?> parent) {
                            }
                        });
                        delTelephoneContentBtn.setOnClickListener(new OnClickListener() {
                            @Override
                            public void onClick(View view) {
                                // TODO Auto-generated method stub
                                customerTelephonetableLayout.removeView(telephoneView);
                                JSONObject phoneJson = new JSONObject();
                                try {
                                    phoneJson.put("OperationFlag", 3);
                                    phoneJson.put("PhoneID", phoneInfo.phoneID);
                                    phoneJson.put("PhoneType", phoneInfo.phoneType);
                                    phoneJson.put("PhoneContent", phoneInfo.phoneContent);
                                    phoneList.put(phoneJson);
                                } catch (JSONException e) {
                                }
                                deletePhoneListCount++;// 删除Phone个数加1
                                updatecustomerAuthorizeSpinnerSelectItem();
                            }
                        });
                        customerTelephonetableLayout.addView(telephoneView);
                    }
                }
                View telephoneFootView = layoutInflater.inflate(R.xml.customer_basci_info_table_foot, null);
                ImageButton addTelephoneTableRow = (ImageButton) telephoneFootView.findViewById(R.id.plus_customer_telephone_tablerow);
                addTelephoneTableRow.setOnClickListener(new OnClickListener() {
                    @Override
                    public void onClick(View view) {
                        // TODO Auto-generated method stub
                        final View telephoneView = layoutInflater.inflate(R.xml.customer_basci_info_tablerow, null);
                        ImageButton delTelephoneContentBtn = (ImageButton) telephoneView.findViewById(R.id.del_customer_basic_info_table_row);
                        delTelephoneContentBtn.setOnClickListener(new OnClickListener() {
                            @Override
                            public void onClick(View view) {
                                customerTelephonetableLayout.removeView(telephoneView);
                            }
                        });
                        customerTelephonetableLayout.addView(telephoneView, customerTelephonetableLayout.getChildCount() - 1);
                    }
                });
                customerTelephonetableLayout.addView(telephoneFootView);
            } else {
                View telephoneFootView = layoutInflater.inflate(R.xml.customer_basci_info_table_foot, null);
                ImageButton addTelephoneTableRow = (ImageButton) telephoneFootView.findViewById(R.id.plus_customer_telephone_tablerow);
                addTelephoneTableRow.setOnClickListener(new OnClickListener() {
                    @Override
                    public void onClick(View view) {
                        // TODO Auto-generated method stub
                        final View telephoneView = layoutInflater.inflate(R.xml.customer_basci_info_tablerow, null);
                        ImageButton delTelephoneContentBtn = (ImageButton) telephoneView.findViewById(R.id.del_customer_basic_info_table_row);
                        delTelephoneContentBtn.setOnClickListener(new OnClickListener() {
                            @Override
                            public void onClick(View view) {
                                customerTelephonetableLayout.removeView(telephoneView);
                            }
                        });
                        customerTelephonetableLayout.addView(telephoneView, customerTelephonetableLayout.getChildCount() - 1);
                    }
                });
                customerTelephonetableLayout.addView(telephoneFootView);
            }
            if (emailInfoList != null && emailInfoList.size() != 0) {
                for (int i = 0; i < emailInfoList.size(); i++) {
                    final EmailInfo emailInfo = emailInfoList.get(i);
                    if (i == 0) {
                        final View emailHeadView = layoutInflater.inflate(R.xml.customer_basci_info_email_tablerow, null);
                        final EditText emailHeadContent = (EditText) emailHeadView.findViewById(R.id.customer_basic_info_edit_text);
                        ImageButton delEmailContentBtn = (ImageButton) emailHeadView.findViewById(R.id.del_customer_basic_info_table_row);
                        final Spinner emailTypeSpinner = (Spinner) emailHeadView.findViewById(R.id.customer_basic_telephone_spinner);
                        emailHeadContent.setText(emailInfoList.get(i).emailContent);
                        emailHeadContent.setInputType(InputType.TYPE_TEXT_VARIATION_EMAIL_ADDRESS);
                        emailHeadContent.addTextChangedListener(new TextWatcher() {
                            @Override
                            public void onTextChanged(CharSequence s, int start,
                                                      int before, int count) {
                            }

                            @Override
                            public void beforeTextChanged(CharSequence s,
                                                          int start, int count, int after) {
                            }

                            @Override
                            public void afterTextChanged(Editable s) {
                                // TODO Auto-generated method stub
                                if (s != null) {
                                    if (!(s.toString().equals(emailInfo.emailContent))) {
                                        JSONObject emailJson = new JSONObject();
                                        try {
                                            emailJson.put("OperationFlag", 2);
                                            emailJson.put("EmailID", emailInfo.emailID);
                                            emailJson.put("EmailType", emailTypeSpinner.getSelectedItemPosition());
                                            emailJson.put("EmailContent", s.toString());
                                            emailList.put(emailJson);
                                        } catch (JSONException e) {
                                        }
                                    }
                                }
                            }
                        });
                        int emailType = emailInfoList.get(i).emailType;
                        emailTypeSpinner.setSelection(emailType);
                        emailTypeSpinner.setOnItemSelectedListener(new OnItemSelectedListener() {
                            @Override
                            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                                if (position != emailInfo.emailType) {
                                    JSONObject emailJson = new JSONObject();
                                    try {
                                        emailJson.put("OperationFlag", 2);
                                        emailJson.put("EmailID", emailInfo.emailID);
                                        emailJson.put("EmailType", emailTypeSpinner.getSelectedItemPosition());
                                        emailJson.put("EmailContent", emailHeadContent.getText().toString());
                                        emailList.put(emailJson);
                                    } catch (JSONException e) {
                                    }
                                }
                            }

                            @Override
                            public void onNothingSelected(AdapterView<?> parent) {
                            }
                        });
                        delEmailContentBtn.setOnClickListener(new OnClickListener() {
                            @Override
                            public void onClick(View view) {
                                customerEmailtableLayout.removeView(emailHeadView);
                                JSONObject emailJson = new JSONObject();
                                try {
                                    emailJson.put("OperationFlag", 3);
                                    emailJson.put("EmailID", emailInfo.emailID);
                                    emailJson.put("EmailType", emailInfo.emailType);
                                    emailJson.put("EmailContent", emailInfo.emailContent);
                                    emailList.put(emailJson);
                                } catch (JSONException e) {
                                }
                                deleteEmailCount++;
                            }
                        });
                        customerEmailtableLayout.addView(emailHeadView);
                    } else {
                        final View emailView = layoutInflater.inflate(R.xml.customer_basci_info_email_tablerow, null);
                        final EditText emailContent = (EditText) emailView.findViewById(R.id.customer_basic_info_edit_text);
                        ImageButton delEmailContentBtn = (ImageButton) emailView.findViewById(R.id.del_customer_basic_info_table_row);
                        Spinner emailTypeSpinner = (Spinner) emailView.findViewById(R.id.customer_basic_telephone_spinner);
                        emailContent.setText(emailInfoList.get(i).emailContent);
                        emailContent.setInputType(InputType.TYPE_TEXT_VARIATION_EMAIL_ADDRESS);
                        emailContent.addTextChangedListener(new TextWatcher() {
                            @Override
                            public void onTextChanged(CharSequence s, int start,
                                                      int before, int count) {
                            }

                            @Override
                            public void beforeTextChanged(CharSequence s,
                                                          int start, int count, int after) {
                            }

                            @Override
                            public void afterTextChanged(Editable s) {
                                // TODO Auto-generated method stub
                                if (s != null) {
                                    if (!(s.toString().equals(emailInfo.emailContent))) {
                                        JSONObject emailJson = new JSONObject();
                                        try {
                                            emailJson.put("OperationFlag", 2);
                                            emailJson.put("EmailID", emailInfo.emailID);
                                            emailJson.put("EmailType", emailInfo.emailType);
                                            emailJson.put("EmailContent", s.toString());
                                            emailList.put(emailJson);
                                        } catch (JSONException e) {
                                        }
                                    }
                                }
                            }
                        });
                        int emailType = emailInfoList.get(i).emailType;
                        emailTypeSpinner.setSelection(emailType);
                        emailTypeSpinner.setOnItemSelectedListener(new OnItemSelectedListener() {
                            @Override
                            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                                if (position != emailInfo.emailType) {
                                    JSONObject emailJson = new JSONObject();
                                    try {
                                        emailJson.put("OperationFlag", 2);
                                        emailJson.put("EmailID", emailInfo.emailID);
                                        emailJson.put("EmailType", emailInfo.emailType);
                                        emailJson.put("EmailContent", emailContent.getText().toString());
                                        emailList.put(emailJson);
                                    } catch (JSONException e) {
                                    }
                                }
                            }

                            @Override
                            public void onNothingSelected(AdapterView<?> parent) {
                            }
                        });
                        delEmailContentBtn
                                .setOnClickListener(new OnClickListener() {

                                    @Override
                                    public void onClick(View view) {
                                        // TODO Auto-generated method stub
                                        customerEmailtableLayout.removeView(emailView);
                                        JSONObject emailJson = new JSONObject();
                                        try {
                                            emailJson.put("OperationFlag", 3);
                                            emailJson.put("EmailID", emailInfo.emailID);
                                            emailJson.put("EmailType", emailInfo.emailType);
                                            emailJson.put("EmailContent", emailInfo.emailContent);
                                            emailList.put(emailJson);
                                        } catch (JSONException e) {
                                        }
                                        deleteEmailCount++;
                                    }
                                });
                        customerEmailtableLayout.addView(emailView);
                    }
                }
                View emailFootlView = layoutInflater.inflate(R.xml.customer_basci_info_email_table_foot, null);
                ImageButton addEmailTableRow = (ImageButton) emailFootlView.findViewById(R.id.plus_customer_email_tablerow);
                addEmailTableRow.setOnClickListener(new OnClickListener() {
                    @Override
                    public void onClick(View view) {
                        // TODO Auto-generated method stub
                        final View emailView = layoutInflater.inflate(R.xml.customer_basci_info_email_tablerow, null);
                        ImageButton delEmailContentBtn = (ImageButton) emailView.findViewById(R.id.del_customer_basic_info_table_row);
                        EditText emailContent = (EditText) emailView.findViewById(R.id.customer_basic_info_edit_text);
                        emailContent.setInputType(InputType.TYPE_TEXT_VARIATION_EMAIL_ADDRESS);
                        delEmailContentBtn.setOnClickListener(new OnClickListener() {
                            @Override
                            public void onClick(View view) {
                                customerEmailtableLayout.removeView(emailView);
                            }
                        });
                        customerEmailtableLayout.addView(emailView, customerEmailtableLayout.getChildCount() - 1);
                    }
                });
                customerEmailtableLayout.addView(emailFootlView);
            } else {
                View emailFootlView = layoutInflater.inflate(R.xml.customer_basci_info_email_table_foot, null);
                ImageButton addEmailTableRow = (ImageButton) emailFootlView.findViewById(R.id.plus_customer_email_tablerow);
                addEmailTableRow.setOnClickListener(new OnClickListener() {
                    @Override
                    public void onClick(View view) {
                        // TODO Auto-generated method stub
                        final View emailView = layoutInflater.inflate(R.xml.customer_basci_info_email_tablerow, null);
                        ImageButton delEmailContentBtn = (ImageButton) emailView.findViewById(R.id.del_customer_basic_info_table_row);
                        EditText emailContent = (EditText) emailView.findViewById(R.id.customer_basic_info_edit_text);
                        emailContent.setInputType(InputType.TYPE_TEXT_VARIATION_EMAIL_ADDRESS);
                        delEmailContentBtn.setOnClickListener(new OnClickListener() {
                            @Override
                            public void onClick(View view) {
                                customerEmailtableLayout.removeView(emailView);
                            }
                        });
                        customerEmailtableLayout.addView(emailView, customerEmailtableLayout.getChildCount() - 1);
                    }
                });
                customerEmailtableLayout.addView(emailFootlView);
            }
            if (addressInfoList != null && addressInfoList.size() != 0) {
                for (int i = 0; i < addressInfoList.size(); i++) {
                    final AddressInfo addressInfo = addressInfoList.get(i);
                    final View addressView = layoutInflater.inflate(R.xml.customer_basci_info_address_tablerow, null);
                    final EditText addressContent = (EditText) addressView.findViewById(R.id.customer_basic_info_address_edit_text);
                    final EditText zipcodeContent = (EditText) addressView.findViewById(R.id.customer_basic_info_address_zip_code_edit_text);
                    addressContent.setText(addressInfoList.get(i).addressContent);
                    zipcodeContent.setText(addressInfoList.get(i).zipcode);
                    addressContent.addTextChangedListener(new TextWatcher() {
                        @Override
                        public void onTextChanged(CharSequence s, int start, int before, int count) {
                        }

                        @Override
                        public void beforeTextChanged(CharSequence s, int start, int count, int after) {
                        }

                        @Override
                        public void afterTextChanged(Editable s) {
                            // TODO Auto-generated method stub
                            if (s != null) {
                                if (!(s.toString().equals(addressInfo.addressContent))) {
                                    JSONObject addressJson = new JSONObject();
                                    try {
                                        addressJson.put("OperationFlag", 2);
                                        addressJson.put("AddressID", addressInfo.addressID);
                                        addressJson.put("AddressType", addressInfo.addressType);
                                        addressJson.put("AddressContent", s.toString());
                                        addressJson.put("ZipCode", zipcodeContent.getText().toString());
                                        addressList.put(addressJson);
                                    } catch (JSONException e) {
                                    }
                                }
                            }
                        }
                    });
                    zipcodeContent.addTextChangedListener(new TextWatcher() {
                        @Override
                        public void onTextChanged(CharSequence s, int start,
                                                  int before, int count) {
                        }

                        @Override
                        public void beforeTextChanged(CharSequence s, int start,
                                                      int count, int after) {
                        }

                        @Override
                        public void afterTextChanged(Editable s) {
                            // TODO Auto-generated method stub
                            if (s != null) {
                                if (!(s.toString().equals(addressInfo.zipcode))) {
                                    JSONObject addressJson = new JSONObject();
                                    try {
                                        addressJson.put("OperationFlag", 2);
                                        addressJson.put("AddressID", addressInfo.addressID);
                                        addressJson.put("AddressType", addressInfo.addressType);
                                        addressJson.put("AddressContent", addressContent.getText().toString());
                                        addressJson.put("ZipCode", s.toString());
                                        addressList.put(addressJson);
                                    } catch (JSONException e) {

                                    }
                                }
                            }
                        }
                    });
                    Spinner addressSpinner = (Spinner) addressView.findViewById(R.id.customer_basic_telephone_spinner);
                    int addressType = addressInfoList.get(i).addressType;
                    addressSpinner.setSelection(addressType);
                    addressSpinner.setOnItemSelectedListener(new OnItemSelectedListener() {
                        @Override
                        public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                            if (position != addressInfo.addressType) {
                                JSONObject addressJson = new JSONObject();
                                try {
                                    addressJson.put("OperationFlag", 2);
                                    addressJson.put("AddressID", addressInfo.addressID);
                                    addressJson.put("AddressType", position);
                                    addressJson.put("AddressContent", addressContent.getText().toString());
                                    addressJson.put("ZipCode", zipcodeContent.getText().toString());
                                    addressList.put(addressJson);
                                } catch (JSONException e) {

                                }
                            }
                        }

                        @Override
                        public void onNothingSelected(AdapterView<?> parent) {
                        }
                    });

                    ImageButton delAddressBtn = (ImageButton) addressView.findViewById(R.id.del_customer_basic_info_table_row);
                    delAddressBtn.setOnClickListener(new OnClickListener() {
                        @Override
                        public void onClick(View view) {
                            customerAddresstableLayout.removeView(addressView);
                            JSONObject addressJson = new JSONObject();
                            try {
                                addressJson.put("OperationFlag", 3);
                                addressJson.put("AddressID", addressInfo.addressID);
                                addressJson.put("AddressType", addressInfo.addressType);
                                addressJson.put("AddressContent", addressInfo.addressContent);
                                addressJson.put("ZipCode", addressInfo.zipcode);
                                addressList.put(addressJson);
                            } catch (JSONException e) {

                            }
                            deleteAddressCount++;
                        }
                    });
                    customerAddresstableLayout.addView(addressView, customerAddresstableLayout.getChildCount() - 1);
                }
            }
            updateAuthorizePhoneList();
        } else {
            customerTelephonetableLayout.setVisibility(View.GONE);
            customerEmailtableLayout.setVisibility(View.GONE);
            customerAddresstableLayout.setVisibility(View.GONE);
            findViewById(R.id.customer_basic_authorize_tablelayout).setVisibility(View.GONE);
        }
        //获取顾客来源
        getSourceTypeList();
    }

    private static class EditCustomerBasicActivityHandler extends Handler {
        private final EditCustomerBasicActivity editCustomerBasicActivity;

        private EditCustomerBasicActivityHandler(EditCustomerBasicActivity activity) {
            WeakReference<EditCustomerBasicActivity> weakReference = new WeakReference<EditCustomerBasicActivity>(activity);
            editCustomerBasicActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message msg) {
            // 当activity未加载完成时,用户返回的情况
            if (editCustomerBasicActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (editCustomerBasicActivity.progressDialog != null) {
                editCustomerBasicActivity.progressDialog.dismiss();
                editCustomerBasicActivity.progressDialog = null;
            }
            if (msg.what == 1) {

                AlertDialog alertDialog = null;
                Intent intent = null;
                if (msg.obj != null && (Integer) msg.obj == 2) {
                    alertDialog = DialogUtil.createShortShowDialog(editCustomerBasicActivity, "提示信息", "关闭顾客成功！");
                    // 更新右边菜单
                    editCustomerBasicActivity.userinfoApplication.setSelectedCustomerHeadImageURL("");
                    editCustomerBasicActivity.userinfoApplication.setSelectedCustomerName("");
                    editCustomerBasicActivity.userinfoApplication.setSelectedCustomerID(0);
                    intent = new Intent(editCustomerBasicActivity, CustomerActivity.class);
                } else {
                    alertDialog = DialogUtil.createShortShowDialog(editCustomerBasicActivity, "提示信息", "顾客基本信息编辑成功！");
                    intent = new Intent(editCustomerBasicActivity, CustomerInfoActivity.class);
                }
                alertDialog.show();
                intent.putExtra("current_tab", 0);
                editCustomerBasicActivity.dialogTimer = new Timer();
                DialogTimerTask dialogTimerTask = new DialogTimerTask(alertDialog, editCustomerBasicActivity.dialogTimer, editCustomerBasicActivity, intent);
                editCustomerBasicActivity.dialogTimer.schedule(dialogTimerTask, Constant.DIALOG_AUTO_DISMISS_TIME);

            } else if (msg.what == 8) {
                if (editCustomerBasicActivity.sourceTypeList.size() > 0) {
                    String[] sourceTypeNameArray = new String[editCustomerBasicActivity.sourceTypeList.size()];
                    int customerSourceTypeSelection = 0;
                    for (int i = 0; i < editCustomerBasicActivity.sourceTypeList.size(); i++) {
                        Log.v("i==customer==source", i + "==" + editCustomerBasicActivity.customer.getSourceType().getSourceTypeID() + "===" + editCustomerBasicActivity.sourceTypeList.get(i).getSourceTypeID());
                        sourceTypeNameArray[i] = editCustomerBasicActivity.sourceTypeList.get(i).getSourceTypeName();
                        if (editCustomerBasicActivity.customer.getSourceType().getSourceTypeID() == editCustomerBasicActivity.sourceTypeList.get(i).getSourceTypeID()) {
                            customerSourceTypeSelection = i;
                        }
                    }

                    ArrayAdapter<String> sourceTypeNameAdapter = new ArrayAdapter<String>(editCustomerBasicActivity, R.xml.spinner_checked_text, sourceTypeNameArray);
                    ;
                    sourceTypeNameAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
                    editCustomerBasicActivity.customerSourceTypeSpinner.setAdapter(sourceTypeNameAdapter);
                    editCustomerBasicActivity.customerSourceTypeSpinner.setSelection(customerSourceTypeSelection);
                }
            } else if (msg.what == 0) {
                DialogUtil.createShortDialog(editCustomerBasicActivity, (String) msg.obj);
            } else if (msg.what == 2)
                DialogUtil.createShortDialog(editCustomerBasicActivity, "您的网络貌似不给力，请重试");
            else if (msg.what == Constant.LOGIN_ERROR) {
                DialogUtil.createShortDialog(editCustomerBasicActivity, editCustomerBasicActivity.getString(R.string.login_error_message));
                UserInfoApplication.getInstance().exitForLogin(editCustomerBasicActivity);
            } else if (msg.what == Constant.APP_VERSION_ERROR) {
                String downloadFileUrl = Constant.SERVER_URL + editCustomerBasicActivity.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(editCustomerBasicActivity);
                editCustomerBasicActivity.packageUpdateUtil = new PackageUpdateUtil(editCustomerBasicActivity, editCustomerBasicActivity.mHandler, fileCache, downloadFileUrl, false, UserInfoApplication.getInstance());
                editCustomerBasicActivity.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) msg.obj);
                editCustomerBasicActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            //包进行下载安装升级
            else if (msg.what == 5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
                String filename = "cn.com.antika.business.apk";
                File file = editCustomerBasicActivity.getFileStreamPath(filename);
                file.getName();
                editCustomerBasicActivity.packageUpdateUtil.showInstallDialog();
            } else if (msg.what == -5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
            } else if (msg.what == 7) {
                int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
                ((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
            }
            if (editCustomerBasicActivity.requestWebServiceThread != null) {
                editCustomerBasicActivity.requestWebServiceThread.interrupt();
                editCustomerBasicActivity.requestWebServiceThread = null;
            }
        }
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

    protected void getCustomerInfo() {
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
                    customerBsaicJsonParam.put("CustomerID", String.valueOf(selectedCustomerID));
                } catch (JSONException e) {
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
                    }
                    if (code == 1) {
                        JSONObject customerBasicJson = null;
                        try {
                            customerBasicJson = customerBasicJsonObject.getJSONObject("Data");
                        } catch (JSONException e) {
                        }
                        String customerHeadImageURL = "";
                        String customerName = "";
                        try {
                            if (customerBasicJson.has("HeadImageURL") && !customerBasicJson.isNull("HeadImageURL"))
                                customerHeadImageURL = customerBasicJson.getString("HeadImageURL");
                            if (customerBasicJson.has("CustomerName") && !customerBasicJson.isNull("CustomerName"))
                                customerName = customerBasicJson.getString("CustomerName");
                        } catch (JSONException e) {
                        }
                        userinfoApplication.setSelectedCustomerName(customerName);
                        userinfoApplication.setSelectedCustomerHeadImageURL(customerHeadImageURL);
                        mHandler.sendEmptyMessage(1);
                    } else
                        mHandler.sendEmptyMessage(code);

                }
            }
        };
        requestWebServiceThread.start();
    }

    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        // TODO Auto-generated method stub
        super.onActivityResult(requestCode, resultCode, data);
        if (resultCode != RESULT_OK)
            return;
        Bitmap myBitmap = null;
        byte[] mContent = null;
        if (requestCode == 0 && resultCode == RESULT_OK) {
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
        else if (requestCode == 1 && resultCode == RESULT_OK) {
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
                customerHeadImageView.setImageBitmap(myBitmap);
            }
            if (mContent != null)
                updateHeadImageStr = new String(Base64Util.encode(mContent));
        }
    }

    // 图片裁剪
    public void cropImage(Uri uri, int outputX, int outputY, int requestCode) {
        // 裁剪图片意图
        Intent intent = new Intent("com.android.camera.action.CROP");
        intent.setDataAndType(uri, "image/*");
        intent.putExtra("crop", "true");
        // 裁剪框的比例，1：1
        intent.putExtra("aspectX", 1);
        intent.putExtra("aspectY", 1);
        // 裁剪后输出图片的尺寸大小
        intent.putExtra("outputX", outputX);
        intent.putExtra("outputY", outputY);
        // 图片格式
        intent.putExtra("outputFormat", "JPEG");
        intent.putExtra("noFaceDetection", true);
        intent.putExtra("return-data", true);
        startActivityForResult(intent, requestCode);
    }

    @Override
    public void onClick(View view) {
        // TODO Auto-generated method stub
        progressDialog = new ProgressDialog(this, R.style.CustomerProgressDialog);
        if (view.getId() == R.id.edit_customer_basic_make_sure_btn) {
            if (customerBasicName.getText().toString() == null
                    || customerBasicName.getText().toString().trim().equals(""))
                DialogUtil.createShortDialog(this, "用户名不允许为空");
            else {
                progressDialog.setMessage(getString(R.string.please_wait));
                progressDialog.show();
                requestWebServiceThread = new Thread() {
                    @Override
                    public void run() {
                        // TODO Auto-generated method stub
                        String methodName = "updateCustomerBasic";
                        String endPoint = "Customer";
                        JSONObject updateCustomerBasicJson = new JSONObject();
                        int customerId = customer.getCustomerId();
                        try {
                            updateCustomerBasicJson.put("CustomerID", customerId);
                            updateCustomerBasicJson.put("CustomerName", customerBasicName.getText().toString());
                            updateCustomerBasicJson.put("Title", customerBasicSex.getText().toString());
                            updateCustomerBasicJson.put("Gender", String.valueOf(customer.getGender()));
                            updateCustomerBasicJson.put("SourceType", sourceTypeList.get(customerSourceTypeSpinner.getSelectedItemPosition()).getSourceTypeID());
                            if (updateHeadImageStr != null && !(("").equals(updateHeadImageStr))) {
                                updateCustomerBasicJson.put("HeadFlag", "1");
                                updateCustomerBasicJson.put("ImageString", updateHeadImageStr);
                                updateCustomerBasicJson.put("ImageType", ".JPEG");
                            } else
                                updateCustomerBasicJson.put("HeadFlag", "0");
                            updateCustomerBasicJson.put("CompanyID", String.valueOf(userinfoApplication.getAccountInfo().getCompanyId()));
                            if (!customerAuthorizeCurrentSelect.equals("无"))
                                updateCustomerBasicJson.put("LoginMobile", customerAuthorizeCurrentSelect);
                        } catch (JSONException e) {
                        }
                        if (customer.getPhoneInfoList() != null && customer.getPhoneInfoList().size() != 0) {
                            int oldCustomerPhoneCount = customer.getPhoneInfoList().size() - deletePhoneListCount;
                            int newCustomerPhoneCount = customerTelephonetableLayout.getChildCount() - 2;
                            if (newCustomerPhoneCount > oldCustomerPhoneCount) {
                                for (int j = oldCustomerPhoneCount + 1; j < customerTelephonetableLayout.getChildCount() - 1; j++) {
                                    JSONObject phoneJson = new JSONObject();
                                    View telephoneChildView = customerTelephonetableLayout.getChildAt(j);
                                    String telephoneNumber = ((EditText) telephoneChildView.findViewById(R.id.customer_basic_info_edit_text)).getText().toString();
                                    int telephoneType = ((Spinner) telephoneChildView.findViewById(R.id.customer_basic_telephone_spinner)).getSelectedItemPosition();
                                    try {
                                        phoneJson.put("OperationFlag", 1);
                                        phoneJson.put("PhoneType", telephoneType);
                                        phoneJson.put("PhoneContent", telephoneNumber);
                                        phoneList.put(phoneJson);
                                    } catch (JSONException e) {

                                    }
                                }
                            }
                        } else {
                            int newCustomerPhoneCount = customerTelephonetableLayout.getChildCount() - 2;
                            if (newCustomerPhoneCount != 0) {
                                for (int j = 1; j < customerTelephonetableLayout.getChildCount() - 1; j++) {
                                    JSONObject phoneJson = new JSONObject();
                                    View telephoneChildView = customerTelephonetableLayout.getChildAt(j);
                                    String telephoneNumber = ((EditText) telephoneChildView.findViewById(R.id.customer_basic_info_edit_text)).getText().toString();
                                    int telephoneType = ((Spinner) telephoneChildView.findViewById(R.id.customer_basic_telephone_spinner)).getSelectedItemPosition();
                                    try {
                                        phoneJson.put("OperationFlag", 1);
                                        phoneJson.put("PhoneType", telephoneType);
                                        phoneJson.put("PhoneContent", telephoneNumber);
                                        phoneList.put(phoneJson);
                                    } catch (JSONException e) {
                                    }
                                }
                            }
                        }
                        if (customer.getEmailInfoList() != null && customer.getEmailInfoList().size() != 0) {
                            int oldCustomerEmailCount = customer.getEmailInfoList().size() - deleteEmailCount;
                            int newCustomerEmailCount = customerEmailtableLayout.getChildCount() - 2;
                            if (newCustomerEmailCount > oldCustomerEmailCount) {
                                for (int j = oldCustomerEmailCount + 1; j < customerEmailtableLayout.getChildCount() - 1; j++) {
                                    JSONObject emailJson = new JSONObject();
                                    View emailChildView = customerEmailtableLayout.getChildAt(j);
                                    String emailContent = ((EditText) emailChildView.findViewById(R.id.customer_basic_info_edit_text)).getText().toString();
                                    int emailType = ((Spinner) emailChildView.findViewById(R.id.customer_basic_telephone_spinner)).getSelectedItemPosition();
                                    try {
                                        emailJson.put("OperationFlag", 1);
                                        emailJson.put("EmailType", emailType);
                                        emailJson.put("EmailContent", emailContent);
                                        emailList.put(emailJson);
                                    } catch (JSONException e) {
                                    }
                                }
                            }
                        } else {
                            int newCustomerEmailCount = customerEmailtableLayout.getChildCount() - 2;
                            if (newCustomerEmailCount != 0) {
                                for (int j = 1; j < customerEmailtableLayout.getChildCount() - 1; j++) {
                                    JSONObject emailJson = new JSONObject();
                                    View emailChildView = customerEmailtableLayout.getChildAt(j);
                                    String emailContent = ((EditText) emailChildView.findViewById(R.id.customer_basic_info_edit_text)).getText().toString();
                                    int emailType = ((Spinner) emailChildView.findViewById(R.id.customer_basic_telephone_spinner)).getSelectedItemPosition();
                                    try {
                                        emailJson.put("OperationFlag", 1);
                                        emailJson.put("EmailType", emailType);
                                        emailJson.put("EmailContent", emailContent);
                                        emailList.put(emailJson);
                                    } catch (JSONException e) {

                                    }
                                }
                            }
                        }
                        if (customer.getAddressInfoList() != null && customer.getAddressInfoList().size() != 0) {
                            int oldCustomerAddressCount = customer.getAddressInfoList().size() - deleteAddressCount;
                            int newCustomerAddressCount = customerAddresstableLayout.getChildCount() - 2;
                            if (newCustomerAddressCount > oldCustomerAddressCount) {
                                for (int j = oldCustomerAddressCount + 2; j < customerAddresstableLayout.getChildCount() - 1; j++) {
                                    JSONObject addressJson = new JSONObject();
                                    View addressChildView = customerAddresstableLayout.getChildAt(j);
                                    String addressContent = ((EditText) addressChildView.findViewById(R.id.customer_basic_info_address_edit_text)).getText().toString();
                                    String addressZipCode = ((EditText) addressChildView.findViewById(R.id.customer_basic_info_address_zip_code_edit_text)).getText().toString();
                                    int addressType = ((Spinner) addressChildView.findViewById(R.id.customer_basic_telephone_spinner)).getSelectedItemPosition();
                                    try {
                                        addressJson.put("OperationFlag", 1);
                                        addressJson.put("AddressType", addressType);
                                        addressJson.put("AddressContent", addressContent);
                                        addressJson.put("ZipCode", addressZipCode);
                                        addressList.put(addressJson);
                                    } catch (JSONException e) {

                                    }
                                }
                            }
                        } else {
                            int newCustomerAddressCount = customerAddresstableLayout
                                    .getChildCount() - 2;
                            if (newCustomerAddressCount != 0) {
                                for (int j = 2; j < customerAddresstableLayout
                                        .getChildCount() - 1; j++) {
                                    JSONObject addressJson = new JSONObject();
                                    View addressChildView = customerAddresstableLayout.getChildAt(j);
                                    String addressContent = ((EditText) addressChildView.findViewById(R.id.customer_basic_info_address_edit_text)).getText().toString();
                                    String addressZipCode = ((EditText) addressChildView.findViewById(R.id.customer_basic_info_address_zip_code_edit_text)).getText().toString();
                                    int addressType = ((Spinner) addressChildView.findViewById(R.id.customer_basic_telephone_spinner)).getSelectedItemPosition();
                                    try {
                                        addressJson.put("OperationFlag", 1);
                                        addressJson.put("AddressType", addressType);
                                        addressJson.put("AddressContent", addressContent);
                                        addressJson.put("ZipCode", addressZipCode);
                                        addressList.put(addressJson);
                                    } catch (JSONException e) {
                                    }
                                }
                            }
                        }
                        try {
                            if (phoneList.toString() != null && !(("").equals(phoneList.toString())))
                                updateCustomerBasicJson.put("PhoneList", phoneList);
                            if (emailList.toString() != null && !(("").equals(emailList.toString())))
                                updateCustomerBasicJson.put("EmailList", emailList);
                            if (addressList.toString() != null && !(("").equals(addressList.toString())))
                                updateCustomerBasicJson.put("AddressList", addressList);
                        } catch (JSONException e) {
                        }
                        String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, updateCustomerBasicJson.toString(), userinfoApplication);
                        if (serverRequestResult == null || serverRequestResult.equals(""))
                            mHandler.sendEmptyMessage(2);
                        else {
                            JSONObject updateCustomerJson = null;
                            int code = 0;
                            try {
                                updateCustomerJson = new JSONObject(serverRequestResult);
                                code = updateCustomerJson.getInt("Code");
                            } catch (JSONException e) {
                            }
                            if (code == 1) {
                                getCustomerInfo();
                            } else if (code == Constant.LOGIN_ERROR || code == Constant.APP_VERSION_ERROR)
                                mHandler.sendEmptyMessage(code);
                            else {
                                String message = "";
                                if (updateCustomerJson.has("Message") && !updateCustomerJson.isNull("Message")) {
                                    try {
                                        message = updateCustomerJson.getString("Message");
                                    } catch (JSONException e) {
                                        message = "";
                                    }
                                }
                                Message msg = new Message();
                                msg.obj = message;
                                msg.what = 0;
                                mHandler.sendMessage(msg);
                            }

                        }
                    }
                };
                requestWebServiceThread.start();
            }
        } else if (view.getId() == R.id.delete_customer_basic_btn) {
            Dialog dialog = new AlertDialog.Builder(this, R.style.CustomerAlertDialog).setTitle(getString(R.string.delete_dialog_title))
                    .setMessage(R.string.delete_customer).setPositiveButton(getString(R.string.delete_confirm),
                            new DialogInterface.OnClickListener() {
                                @Override
                                public void onClick(DialogInterface dialog, int which) {
                                    dialog.dismiss();
                                    // TODO Auto-generated method stub
                                    progressDialog.setMessage(getString(R.string.please_wait));
                                    progressDialog.show();
                                    requestWebServiceThread = new Thread() {
                                        @Override
                                        public void run() {
                                            String methodName = "deleteCustomer";
                                            String endPoint = "customer";
                                            JSONObject deleteCustomerJson = new JSONObject();
                                            int customerId = customer.getCustomerId();
                                            try {
                                                deleteCustomerJson.put("CustomerID", customerId);
                                            } catch (JSONException e) {
                                            }
                                            String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, deleteCustomerJson.toString(), userinfoApplication);
                                            if (serverRequestResult == null || serverRequestResult.equals(""))
                                                mHandler.sendEmptyMessage(2);
                                            else {
                                                JSONObject resultJson = null;
                                                try {
                                                    resultJson = new JSONObject(serverRequestResult);
                                                } catch (JSONException e) {
                                                }
                                                int code = 0;
                                                try {
                                                    code = resultJson.getInt("Code");
                                                } catch (JSONException e) {
                                                    code = 0;
                                                }
                                                if (code == 1) {
                                                    Message messageObj = new Message();
                                                    messageObj.obj = 2;
                                                    messageObj.what = 1;
                                                    mHandler.sendMessage(messageObj);
                                                } else if (code == Constant.LOGIN_ERROR || code == Constant.APP_VERSION_ERROR)
                                                    mHandler.sendEmptyMessage(code);
                                                else {
                                                    String message = "";
                                                    try {
                                                        message = resultJson.getString("Message");
                                                    } catch (JSONException e) {
                                                    }
                                                    Message msg = new Message();
                                                    msg.obj = message;
                                                    msg.what = 0;
                                                    mHandler.sendMessage(msg);
                                                }

                                            }
                                        }
                                    };
                                    requestWebServiceThread.start();
                                }
                            })
                    .setNegativeButton(getString(R.string.delete_cancel),
                            new DialogInterface.OnClickListener() {

                                @Override
                                public void onClick(DialogInterface dialog, int which) {
                                    // TODO Auto-generated method stub
                                    dialog.dismiss();
                                    dialog = null;
                                }
                            }).create();
            dialog.show();
            dialog.setCancelable(false);
        } else if (view.getId() == R.id.plus_customer_address_tablerow) {
            final View addressTableRowView = layoutInflater.inflate(R.xml.customer_basci_info_address_tablerow, null);
            int addressChildCount = customerAddresstableLayout.getChildCount();
            customerAddresstableLayout.addView(addressTableRowView, addressChildCount - 1);
            ImageButton delAddressTableRow = (ImageButton) addressTableRowView.findViewById(R.id.del_customer_basic_info_table_row);
            delAddressTableRow.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View view) {
                    // TODO Auto-generated method stub
                    customerAddresstableLayout.removeView(addressTableRowView);
                }
            });
        } else if (view.getId() == R.id.new_customer_gender_female_select_icon) {
            changeCustomerGender();
        } else if (view.getId() == R.id.new_customer_gender_male_select_icon) {
            changeCustomerGender();
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

    private void updateAuthorizePhoneList() {
        customerAuthorizeSelectList.clear();
        for (int j = 1; j < customerTelephonetableLayout.getChildCount() - 1; j++) {
            View telephoneChildView = customerTelephonetableLayout.getChildAt(j);
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
            setSpinnerItemSelectedByValue(customerAuthorizeSpinner, customerAuthorizeCurrentSelect);
    }

    /**
     * 根据值, 设置spinner默认选中:
     *
     * @param spinner
     * @param value
     */
    public void setSpinnerItemSelectedByValue(Spinner spinner, String value) {
        SpinnerAdapter apsAdapter = spinner.getAdapter(); // 得到SpinnerAdapter对象
        int k = apsAdapter.getCount();
        int i;
        for (i = 0; i < k; i++) {
            if (value.equals(apsAdapter.getItem(i).toString())) {
                spinner.setSelection(i, true);// 默认选中项
                break;
            }
        }
        // 如果customerAuthorizeCurrentSelect没有与List匹配的项（被删除的情况），则设置默认值
        if (i == k) {
            spinner.setSelection(k - 1, true);
            customerAuthorizeCurrentSelect = "无";
        }
    }

    protected void changeCustomerGender() {
        if (customer.getGender() == 0) {
            customerGenderFemaleSelectIcon.setBackgroundResource(R.drawable.customer_scan_record_status_gray_icon);
            customerGenderMaleSelectIcon.setBackgroundResource(R.drawable.customer_scan_record_status_blue_icon);
            customer.setGender(1);
        } else if (customer.getGender() == 1) {
            customerGenderFemaleSelectIcon.setBackgroundResource(R.drawable.customer_scan_record_status_blue_icon);
            customerGenderMaleSelectIcon.setBackgroundResource(R.drawable.customer_scan_record_status_gray_icon);
            customer.setGender(0);
        }
    }

    private void updatecustomerAuthorizeSpinnerSelectItem() {
        int customerTelephoneCount = 0;
        for (int j = 1; j < customerTelephonetableLayout.getChildCount() - 1; j++) {
            View telephoneChildView = customerTelephonetableLayout.getChildAt(j);
            String telephoneNumber = ((EditText) telephoneChildView.findViewById(R.id.customer_basic_info_edit_text)).getText().toString();
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
