package com.glamourpromise.beauty.customer.net;

import java.security.KeyManagementException;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.security.cert.CertificateException;
import java.security.cert.X509Certificate;

import javax.net.ssl.HostnameVerifier;
import javax.net.ssl.SSLSession;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;

import android.util.Log;

public class FakeX509TrustManager implements X509TrustManager {
	private static TrustManager[] trustManagers;

	@Override
	public void checkClientTrusted(X509Certificate[] arg0, String arg1)
			throws CertificateException {
	}

	@Override
	public void checkServerTrusted(X509Certificate[] chain, String authType)
			throws CertificateException {
	}

	@Override
	public X509Certificate[] getAcceptedIssuers() {
		return null;
	}

	public static void allowAllSSL() {

		javax.net.ssl.HttpsURLConnection
				.setDefaultHostnameVerifier(new HostnameVerifier() {

					@Override
					public boolean verify(String arg0, SSLSession arg1) {
						// TODO Auto-generated method stub
						return true;
					}
				});

		javax.net.ssl.SSLContext context = null;

		if (trustManagers == null) {
			trustManagers = new javax.net.ssl.TrustManager[] { new FakeX509TrustManager() };
		}

		try {
			context = javax.net.ssl.SSLContext.getInstance("TLS");
			context.init(null, trustManagers, new SecureRandom());
		} catch (NoSuchAlgorithmException e) {
			Log.e("allowAllSSL", e.toString());
		} catch (KeyManagementException e) {
			Log.e("allowAllSSL", e.toString());
		}
		javax.net.ssl.HttpsURLConnection.setDefaultSSLSocketFactory(context
				.getSocketFactory());
	}
}
