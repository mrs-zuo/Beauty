package com.GlamourPromise.Beauty.util;
import java.math.BigInteger;
import java.security.KeyFactory;
import java.security.PrivateKey;
import java.security.PublicKey;
import java.security.spec.RSAPrivateKeySpec;
import java.security.spec.RSAPublicKeySpec;
import javax.crypto.Cipher;
public class RSAUtil {   
  
    private static String module = "vKqJ3dR19ufPB28RDCVzwTSA+fbCrgjEQJOyvz3XEw0YRS2m7zp8qqeQwCrUPqrybV2AeCbvJGCF2eCxK/1mGK0IlkR8MZbOE1skPa5EXdjDgZ8LRzo0boQBXANeLpzR4y3286BjuteSDPcL1VkH7MdHcleEdz3Okm3OSXwc+/c=";   
    private static String exponentString = "AQAB";   
    private static String delement = "hVYNe45FFIt9oGZZaPkrFtexc3d23SJq+KypvkjJMLind3StLxNpuf4U6gsa13NfQ/W57rCtgEsLLhGDhXBf70Z2bFTSPAfWKer1dn3fjKpDbd7E0OyVZYaD15auPdJzyzoAS2YLoph/Fsvmxc4y6UGNlKmIfYP5Il0i6Cxni/k=";   
    private static String encryptString = "Vx/dGjS1YWKRubsoDgiShiwLgqyNE2z/eM65U7HZx+RogwaiZimNBxjuOS6acEhKZx66cMYEAd1fc6oewbEvDIfP44GaN9dCjKE/BkkQlwEg6aTO5q+yqy+nEGe1kvLY9EyXS/Kv1LDh3e/2xAk5FNj8Zp6oU2kq4ewL8kK/ai4=";   
    /**   
     * @param args   
     */   
    public static void main(String[] args) {  
        String result = encrypt("123456");  
        System.out.println(result);
        System.out.println(dencrypt(result));
        /*byte[] enTest = null;   
        enTest = Base64.decode(encryptString);  
        System.out.println(enTest.length);   
        System.out.println(en.length);   
        System.out.println(new String(Dencrypt(en)));   
        System.out.println(new String(Dencrypt(enTest)));*/  
    }   
  
    public static String encrypt(String source) { 
        try {   
            byte[] modulusBytes = Base64Util.decode(module);   
            byte[] exponentBytes = Base64Util.decode(exponentString);   
            BigInteger modulus = new BigInteger(1, modulusBytes);   
            BigInteger exponent = new BigInteger(1, exponentBytes);   
            RSAPublicKeySpec rsaPubKey = new RSAPublicKeySpec(modulus, exponent);   
            KeyFactory fact = KeyFactory.getInstance("RSA");   
            PublicKey pubKey = fact.generatePublic(rsaPubKey);  
            Cipher cipher = Cipher.getInstance("RSA/ECB/PKCS1Padding");   
            cipher.init(Cipher.ENCRYPT_MODE,pubKey);   
            byte[] cipherData = cipher.doFinal(new String(source).getBytes());
            String encryptResult=new String(Base64Util.encode(cipherData));
            return encryptResult;   
        } catch (Exception e) {   
            e.printStackTrace();   
        }   
        return null;   
  
    }   
  
    public static String dencrypt(String encryptedResult) {   
    	byte[] encrypted=encryptedResult.getBytes();
        try {   
            byte[] expBytes = Base64Util.decode(delement);   
            byte[] modBytes = Base64Util.decode(module);   
  
            BigInteger modules = new BigInteger(1, modBytes);   
            BigInteger exponent = new BigInteger(1, expBytes);   
  
            KeyFactory factory = KeyFactory.getInstance("RSA");   
            Cipher cipher = Cipher.getInstance("RSA/ECB/PKCS1Padding");   
  
            RSAPrivateKeySpec privSpec = new RSAPrivateKeySpec(modules, exponent);   
            PrivateKey privKey = factory.generatePrivate(privSpec);   
            cipher.init(Cipher.DECRYPT_MODE, privKey);   
            byte[] decrypted = cipher.doFinal(encrypted);   
            return new String(decrypted);  
        } catch (Exception e) {   
            e.printStackTrace();   
        }   
        return null;   
    } 
}  