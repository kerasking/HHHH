package org.DeNA.DHLJ;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Random;
import java.util.SortedMap;
import java.util.TreeMap;

import javax.crypto.Mac;
import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;

import android.util.Log;
import org.cocos2dx.lib.Cocos2dxActivity;

public class OAuthSupport {
	private final static String TAG = OAuthSupport.class.getSimpleName();

	// hash algorithm
	private static final String SIGNATURE_METHOD = "HMAC-SHA1";
	private static final String SIGNATURE_METHOD_JAVA = "HmacSHA1";

	// properties
	private String consumerKey;
	private String consumerKeySecret;
	private String requestToken;
	private String requestTokenSecret;
	private String callBackConfirmed;
	private String requestVerifier;
	private String accessToken;
	private String accessTokenSecret;
	private String version;
	private String callabck;
	private String signature;
	private String oauthHeader;

	/**
	 * Null Consturctor. read properties from defined tsupport.file property.
	 */
	public OAuthSupport() {
		this.callabck = "oob";
		this.version = "1.0";
		this.loadProperties();
	}

	/**
	 * Step1. Constructor for getting Request Token.
	 * 
	 * @param consumerKey
	 * @param consumerKeySecret
	 */
	public OAuthSupport(String consumerKey, String consumerKeySecret) {
		this();
		this.consumerKey = consumerKey;
		this.consumerKeySecret = consumerKeySecret;
	}

	/**
	 * Step 2. Consturctor for getting Access Token. requestVerifire(PIN) need
	 * to get from web interface.
	 * 
	 * @param consumerKey
	 * @param consumerKeySecret
	 * @param requestToken
	 * @param requestTokenSecret
	 * @param requestVerifier
	 */
	public OAuthSupport(String consumerKey, String consumerKeySecret,
			String requestToken, String requestTokenSecret,
			String requestVerifier) {
		this(consumerKey, consumerKeySecret);
		this.requestToken = requestToken;
		this.requestTokenSecret = requestTokenSecret;
		this.requestVerifier = requestVerifier;
	}

	/**
	 * Step 3. Constructor for access to protected resource using Web API.
	 * 
	 * @param consumerKey
	 * @param consumerKeySecret
	 * @param accessToken
	 * @param accessTokenSecret
	 */
	public OAuthSupport(String consumerKey, String consumerKeySecret,
			String accessToken, String accessTokenSecret) {
		this(consumerKey, consumerKeySecret);
		this.accessToken = accessToken;
		this.accessTokenSecret = accessTokenSecret;
	}

	/**
	 * get OAuth header String. require properties are consumerKey,
	 * consumerKeySecret, accessToken, accessTokenSecret.
	 * 
	 * @param httpMethod
	 * @param requestURL
	 * @param requestBody
	 * @return OAuthHeader
	 */
	public String getOAuthHeader(String httpMethod, String requestURL,
			String requestBody) {

		assert this.consumerKey != null : "consumerKey is require.";
		assert this.consumerKeySecret != null : "consumerKeySecret is require";
		//assert this.accessToken != null : "accessToken is require.";
		//assert this.accessTokenSecret != null : "accessTokenSecret is require.";

		String nonce = getNonce();
		String timeStamp = getUnixEpoc();
		Log.d(TAG, "timeStamp:" + timeStamp);
		
		SortedMap<String, String> baseParams = new TreeMap<String, String>();
		baseParams.put("oauth_callback", this.callabck);
		baseParams.put("oauth_consumer_key", this.getConsumerKey());
		baseParams.put("oauth_signature_method", SIGNATURE_METHOD);
		baseParams.put("oauth_version", this.version);
		baseParams.put("oauth_nonce", nonce);
		baseParams.put("oauth_timestamp", timeStamp);
		if(this.accessToken != null){
			baseParams.put("oauth_token", this.accessToken);
		}
		if (requestBody != null) {
			Map<String, String> map = stringToMap(requestBody);
			baseParams.putAll(map);
		}
		String baseString = makeBaseString(httpMethod, requestURL, baseParams);
		this.signature = makeSignature(baseString, this.consumerKeySecret,
				this.accessTokenSecret);

		Map<String, String> authParams = new LinkedHashMap<String, String>();
		authParams.put("realm", "");
		authParams.put("oauth_version", this.version);
		authParams.put("oauth_nonce", nonce);
		authParams.put("oauth_timestamp", timeStamp);
		authParams.put("oauth_consumer_key", this.getConsumerKey());
		authParams.put("oauth_callback", this.callabck);
		authParams.put("oauth_signature_method", SIGNATURE_METHOD);
		authParams.put("oauth_signature", this.signature);
		if(this.accessToken != null){
			authParams.put("oauth_token", this.accessToken);
		}

		this.oauthHeader = makeOAuthHeader(authParams);

		return this.oauthHeader;
	}

	// Generic Methods.
	/**
	 * print current parameters for test and confirmation.
	 * 
	 */
	public void printParams() {
		System.out.printf("%-30s %s\n", "CONSUMER KEY:", this.consumerKey);
		System.out.printf("%-30s %s\n", "CONSUMER KEY SECRET:",
				this.consumerKeySecret);
		System.out.printf("%-30s %s\n", "REQUEST TOKEN:", this.requestToken);
		System.out.printf("%-30s %s\n", "REQUEST TOKEN SECRET:",
				this.requestTokenSecret);
		System.out.printf("%-30s %s\n", "REQUEST TOKEN VERIFIER(PIN):",
				this.requestVerifier);
		System.out.printf("%-30s %s\n", "ACCESS TOKEN:", this.accessToken);
		System.out.printf("%-30s %s\n", "ACCESS TOKEN SECRET:",
				this.accessTokenSecret);

	}

	private void loadProperties() {
	}

	// Generic Static Methods.
	/**
	 * URL String to Map. values are url encode.
	 * 
	 * @param string
	 *            e.g. x=1&y=2&z=3
	 * @return map converted from string.
	 */
	private static Map<String, String> stringToMap(String string) {
		if (string == null || "".equals(string)) {
			return null;
		}
		Map<String, String> map = new LinkedHashMap<String, String>();
		String[] params = string.split("&");
		for (String param : params) {
			String[] kv = param.split("=");
			map.put(kv[0], urlEncode(kv[1]));
		}
		return map;
	}

	/**
	 * make OAuth header from parameter map. key and value are url encode.
	 * 
	 * @param params
	 * @return OAuth header string.
	 */
	public static String makeOAuthHeader(Map<String, String> params) {
		String header = "OAuth ";
		int i = 1;
		for (String key : params.keySet()) {
			String value = params.get(key);
			header += urlEncode(key) + "=\"" + urlEncode(value) + "\"";
			if (i < params.size()) {
				header += ", ";
			}
			i++;
		}
		return header;
	}

	/**
	 * make signature for basestring by provided keys.
	 * 
	 * @param basestring
	 * @param seckey1
	 *            consumerKey.
	 * @param seckey2
	 *            null or consumerKeySecret or accessTokenSecret.
	 * @return signature.
	 */
	static public String makeSignature(String basestring, String seckey1,
			String seckey2) {
		String signature = "";
		if (seckey2 == null) {
			seckey2 = "";
		}
		String secret = seckey1 + "&" + seckey2;
		try {
			SecretKey key = new SecretKeySpec(secret.getBytes(),
					SIGNATURE_METHOD_JAVA);
			Mac mac = Mac.getInstance(key.getAlgorithm());
			mac.init(key);
			byte[] res = mac.doFinal(basestring.getBytes());
			signature = encB64(res);
		} catch (InvalidKeyException ex) {
			Log.e(TAG, "makeSignature error", ex);
		} catch (NoSuchAlgorithmException ex) {
			Log.e(TAG, "makeSignature error", ex);

		}
		return signature;
	}

	/**
	 * make base string form some parameters for making signature.
	 * 
	 * @param httpMethod
	 * @param url
	 * @param params
	 * @return base string.
	 */
	public static String makeBaseString(String httpMethod, String url,
			SortedMap<String, String> params) {
		String[] urls = url.split("\\?");
		url = urls[0];
		if (urls.length > 1) {
			params.putAll(stringToMap(urls[1]));
		}
		String basestring = httpMethod + "&" + urlEncode(url) + "&";
		int c = 1;
		for (String key : params.keySet()) {
			String value = params.get(key);
			basestring += urlEncode(key) + "%3D" + urlEncode(value);
			if (c < params.size()) {
				basestring += "%26";
			}
			c++;
		}
		return basestring;
	}

	/**
	 * URL Encoding.
	 * 
	 * @param string
	 * @return encoded string
	 */
	public static String urlEncode(String s) {
		if (s == null) {
			return s;
		}
		try {
			s = URLEncoder.encode(s, "UTF-8").replace("+", "%20");
		} catch (UnsupportedEncodingException ex) {
			Log.e(TAG, "error", ex);

		}
		return s;
	}

	/**
	 * get nonce value.
	 * 
	 * @return nonce.
	 */
	public static String getNonce() {
		int waitMilliSec = 6;
		int r = new Random().nextInt(6);
		try {
			Thread.sleep(waitMilliSec + r);
		} catch (InterruptedException ex) {
			Log.e(TAG, "error", ex);
		}
		return Long.toString(System.currentTimeMillis(), Character.MAX_RADIX);
		// return String.valueOf(System.currentTimeMillis());
	}

	/**
	 * get timestamp.
	 * 
	 * @return timestamp.
	 */
	public static String getUnixEpoc() {
		return String.valueOf(System.currentTimeMillis() / 1000L);
	}

	/**
	 * encode BASE64
	 * 
	 * @param string
	 * @return base64ed string.
	 */
	public static String encB64(String s) {
		return encB64(s.getBytes());
	}

	/**
	 * encode BASE64
	 * 
	 * @param s
	 * @return base64ed string.
	 */
	public static String encB64(byte[] s) {
		if (s == null) {
			return null;
		}
		char[] ab = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
				.toCharArray();
		StringBuilder binString = new StringBuilder();
		for (int c : s) {
			c = c & 0xFF;
			binString.append(String.format("%8s", Integer.toString(c, 2))
					.replace(' ', '0'));
		}

		if (binString.length() % 6 != 0) {
			int pad = 6 - binString.length() % 6;
			for (int i = 0; i < pad; i++) {
				binString.append('0');
			}
		}

		StringBuilder sb = new StringBuilder();
		for (int start = 0; start < binString.length(); start += 6) {
			String sn = binString.substring(start, start + 6);
			int cn = Integer.parseInt(sn, 2);

			sb.append(ab[cn]);

		}

		if (sb.length() % 4 != 0) {
			int pad2 = 4 - sb.length() % 4;
			for (int i = 0; i < pad2; i++) {
				sb.append('=');
			}
		}
		return sb.toString();
	}

	public static String trunc140(String word) {
		if (word == null || "".equals(word)) {
			return null;
		}
		if (word.length() > 137) {
			return word.substring(0, 138) + "...";
		}
		return word;
	}

	// Accessor methods.
	public void setConsumerKey(String consumerKey) {
		this.consumerKey = consumerKey;
	}

	public void setConsumerKeySecret(String consumerKeySecret) {
		this.consumerKeySecret = consumerKeySecret;
	}

	public void setAccessToken(String accessToken) {
		this.accessToken = accessToken;
	}

	public void setAccessTokenSecret(String accessTokenSecret) {
		this.accessTokenSecret = accessTokenSecret;
	}

	public String getConsumerKey() {
		return consumerKey;
	}

	public String getConsumerKeySecret() {
		return consumerKeySecret;
	}

	public String getAccessToken() {
		return accessToken;
	}

	public String getAccessTokenSecret() {
		return accessTokenSecret;
	}

	public String getRequestToken() {
		return requestToken;
	}

	public String getRequestTokenSecret() {
		return requestTokenSecret;
	}

	public String getCallBackConfirmed() {
		return callBackConfirmed;
	}

	public String getCallabck() {
		return callabck;
	}

	public void setCallabck(String callabck) {
		this.callabck = callabck;
	}
}
