package cn.com.antika.webservice;

import java.util.concurrent.TimeUnit;

import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLSocketFactory;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;

import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.AccountInfo;
import cn.com.antika.constant.Constant;
import cn.com.antika.util.DateUtil;
import cn.com.antika.util.MD5Encrypt;
import okhttp3.MediaType;
import okhttp3.MultipartBody;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;

public class WebServiceUtil {
    private static final String TAG = WebServiceUtil.class.getSimpleName();

    /*
     * WebApi HTTPS协议访问 Json数据格式
     */
    public static String requestWebServiceWithSSLUseJson(String endPoint, String methodName, String jsonStrParam,
                                                         UserInfoApplication userInfoApplication) {
        String serverURL = "";
        //正式域名
        if (Constant.formalFlag == 0) {
            serverURL = "https://api.beauty.glamise.com/" + endPoint + "/" + methodName;
            //serverURL = "http://10.0.0.112:3324/" + endPoint + "/"+ methodName;
        }
        // demo用户
        else if (Constant.formalFlag == 1) {
            serverURL = "https://api.beauty.glamourpromise.com/" + endPoint + "/" + methodName;
            Constant.formalFlag = 1;
        }
        // 测试账户
        else if (Constant.formalFlag == 2) {
            serverURL = "https://api.test.beauty.glamise.com/" + endPoint + "/" + methodName;
            Constant.formalFlag = 2;
        }

        //需要发送请求就需要创建空的Request对象,在这里面添加方法来丰富这个内容
        Request.Builder builder = new Request.Builder();
        builder.url(serverURL);
        builder.header("Accept", "application/json");
        builder.header("Content-type", "application/json");
        builder.addHeader("CT", String.valueOf(Constant.CLIENT_TYPE_BUSINESS));
        builder.addHeader("DT", String.valueOf(Constant.DEVICE_ANDROID));
        // 头部可选参数
        builder.addHeader("AV", userInfoApplication.getAppVersion());
        builder.addHeader("ME", methodName);// .header("Accept-Encoding", "gzip")

        StringBuilder md5EncryptString = new StringBuilder();
        md5EncryptString.append(methodName + jsonStrParam);
        if (!methodName.equals("getServerVersion")) {
            if (userInfoApplication.getAccountInfo() != null) {
                AccountInfo accountInfo = userInfoApplication.getAccountInfo();
                builder.addHeader("CO", String.valueOf(accountInfo.getCompanyId()));
                builder.addHeader("BR", String.valueOf(accountInfo.getBranchId()));
                builder.addHeader("US", String.valueOf(accountInfo.getAccountId()));
                //CompanyId为了防止其他公司的数据被查看
                md5EncryptString.append(accountInfo.getCompanyId());
            }
            String GUID = userInfoApplication.getGUID();
            if (GUID != null && !("").equals(GUID)) {
                md5EncryptString.append(GUID);
                builder.addHeader("GU", GUID);
            }
        }
        //年月日 时分秒 毫秒
        String nowFormateDate = DateUtil.getNowFormateDate();
        builder.addHeader("TI", nowFormateDate);
        String md5Encrypt = MD5Encrypt.md5Encrypt((md5EncryptString.toString() + Constant.MD5_ENCRYPT_SUFFIX).toUpperCase());
        builder.addHeader("Authorization", md5Encrypt);
        builder.addHeader("Connection", "close");

        MultipartBody.Builder bodyBuilder = new MultipartBody.Builder().setType(MultipartBody.ALTERNATIVE);
        Request request = null;

        if (jsonStrParam != null && !"".equals(jsonStrParam.trim())) {
            MediaType JSON = MediaType.parse("application/json; charset=utf-8");//数据类型为json格式，
            // String jsonStr = "{\"username\":\"lisi\",\"nickname\":\"李四\"}";//json数据.
            RequestBody requestBody = RequestBody.create(JSON, jsonStrParam);
            request = builder.post(requestBody).build();
        } else {
            request = builder.build();
        }

        String resultString = "";
        //发出请求之后还需要获取返回的数据
        try {
            TrustManager[] trustAllCerts = buildTrustManagers();
            final SSLContext sslContext = SSLContext.getInstance("SSL");
            sslContext.init(null, trustAllCerts, new java.security.SecureRandom());

            final SSLSocketFactory sslSocketFactory = sslContext.getSocketFactory();

            //创建一个OkHttpClient实例
            OkHttpClient client = new OkHttpClient.Builder()
                    .addNetworkInterceptor(new NetInterceptor())
                    .connectTimeout(15, TimeUnit.SECONDS)
                    .readTimeout(15, TimeUnit.SECONDS)
                    .writeTimeout(15, TimeUnit.SECONDS)
                    .sslSocketFactory(sslSocketFactory, (X509TrustManager) trustAllCerts[0])
                    .hostnameVerifier(new TrustAllHostnameVerifier())
                    .build();
            Response response = client.newCall(request).execute();
            //这个就是得到的返回数据
            resultString = response.body().string();
            response.close();
        } catch (Exception e) {
            e.printStackTrace();
            resultString = "";
        }

        /*// 头部信息 需要验证的
        HttpPost httpPost = new HttpPost(serverURL);
        httpPost.setHeader("Accept", "application/json");
        httpPost.setHeader("Content-type", "application/json");
        httpPost.setHeader("Accept-Encoding", "gzip");
        httpPost.addHeader("CT", String.valueOf(Constant.CLIENT_TYPE_BUSINESS));
        httpPost.addHeader("DT", String.valueOf(Constant.DEVICE_ANDROID));
        // 头部可选参数
        httpPost.addHeader("AV", userInfoApplication.getAppVersion());
        httpPost.addHeader("ME", methodName);
        StringBuilder md5EncryptString = new StringBuilder();
        md5EncryptString.append(methodName + jsonStrParam);
        if (!methodName.equals("getServerVersion")) {
            if (userInfoApplication.getAccountInfo() != null) {
                AccountInfo accountInfo = userInfoApplication.getAccountInfo();
                httpPost.addHeader("CO", String.valueOf(accountInfo.getCompanyId()));
                httpPost.addHeader("BR", String.valueOf(accountInfo.getBranchId()));
                httpPost.addHeader("US", String.valueOf(accountInfo.getAccountId()));
                //CompanyId为了防止其他公司的数据被查看
                md5EncryptString.append(accountInfo.getCompanyId());
            }
            String GUID = userInfoApplication.getGUID();
            if (GUID != null && !("").equals(GUID)) {
                md5EncryptString.append(GUID);
                httpPost.addHeader("GU", GUID);
            }
        }
        //年月日 时分秒 毫秒
        String nowFormateDate = DateUtil.getNowFormateDate();
        httpPost.addHeader("TI", nowFormateDate);
        String md5Encrypt = MD5Encrypt.md5Encrypt((md5EncryptString.toString() + Constant.MD5_ENCRYPT_SUFFIX).toUpperCase());
        httpPost.addHeader("Authorization", md5Encrypt);
        StringEntity stringEntity = null;
        try {
            stringEntity = new StringEntity(jsonStrParam, HTTP.UTF_8);
        } catch (UnsupportedEncodingException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        httpPost.setEntity(stringEntity);
        HttpClient httpClient = ConnectionManager.getNewHttpClient();
        final HttpParams httpParameters = httpClient.getParams();
        int timeoutConnection = 15 * 1000;
        HttpConnectionParams.setConnectionTimeout(httpParameters, timeoutConnection);//连接超时
        int timeoutSocket = 15 * 1000;
        HttpConnectionParams.setSoTimeout(httpParameters, timeoutSocket);//请求超时
        HttpResponse httpResponse = null;
        // 发送请求并获取反馈
        String resultString = "";
        try {
            httpResponse = httpClient.execute(httpPost);
            // 解析返回的内容
            if (httpResponse != null) {
                int statusCode = httpResponse.getStatusLine().getStatusCode();
                if (statusCode == HttpStatus.SC_OK) // SC_OK为200表示与服务端连接成功
                {
                    // StringBuilder builder = new StringBuilder();
                    // BufferedReader bufferedReader2;
                    try {
                        // bufferedReader2 = new BufferedReader(new
                        // InputStreamReader(httpResponse.getEntity().getContent(), "utf-8"));
                        // String s = null;
                        *//*
         * for (String s = bufferedReader2.readLine(); s != null; s =
         * bufferedReader2.readLine()) { builder.append(s); }
         *//*
                        // while((s=bufferedReader2.readLine()) !=null) {
                        // builder.append(s);
                        // }
                        resultString = EntityUtils.toString(httpResponse.getEntity(), "UTF-8");
                    } catch (IllegalStateException e) {
                        e.printStackTrace();
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                    // resultString = builder.toString();
                } else if (statusCode == HttpStatus.SC_UNAUTHORIZED)// SC_UNAUTHORIZED 401
                {
                    Header responseHeader = httpResponse.getFirstHeader("errorMessage");
                    String errorCode = responseHeader.getValue();
                    String errorMessage = "";
                    JSONObject errorJson = new JSONObject();
                    switch (Integer.parseInt(errorCode)) {
                        case 10001:
                            errorMessage = "陈伟林!";
                            break;
                        case 10002:
                            errorMessage = "陈伟林!";
                            break;
                        case 10003:
                            errorMessage = "陈伟林!";
                            break;
                        case 10004:
                            errorMessage = "陈伟林!";
                            break;
                        case 10005:
                            errorMessage = "陈伟林!";
                            break;
                        case 10006:
                            errorMessage = "陈伟林!";
                            break;
                        case 10007:
                            errorMessage = "陈伟林!";
                            break;
                        case 10008:
                            errorMessage = "陈伟林!";
                            break;
                        case 10009:
                            errorMessage = "陈伟林!";
                            break;
                        case 10010:
                            errorMessage = "请升级至最新版！";
                            break;
                        case 10011:
                            errorMessage = "陈伟林!";
                            break;
                        case 10012:
                            errorMessage = "陈伟林!";
                            break;
                        case 10013:
                            break;
                    }
                    try {
                        errorJson.put("Code", errorCode);
                        errorJson.put("Message", errorMessage);
                    } catch (JSONException e) {
                    }
                    resultString = errorJson.toString();
                }
            }
        } catch (ClientProtocolException e) {
            e.printStackTrace();
            Log.e(TAG, Log.getStackTraceString(e));
        } catch (IOException e) {
            e.printStackTrace();
            Log.e(TAG, Log.getStackTraceString(e));
        } finally {
            httpClient.getConnectionManager().closeExpiredConnections();
            httpClient.getConnectionManager().closeIdleConnections(60, TimeUnit.SECONDS);
            httpClient.getConnectionManager().shutdown();
        }*/
        return resultString;
    }

    private static TrustManager[] buildTrustManagers() {
        return new TrustManager[]{
                new X509TrustManager() {
                    @Override
                    public void checkClientTrusted(java.security.cert.X509Certificate[] chain, String authType) {
                    }

                    @Override
                    public void checkServerTrusted(java.security.cert.X509Certificate[] chain, String authType) {
                    }

                    @Override
                    public java.security.cert.X509Certificate[] getAcceptedIssuers() {
                        return new java.security.cert.X509Certificate[]{};
                    }
                }
        };
    }
}

