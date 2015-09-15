package com.aneesh.auditframework;

import java.security.MessageDigest;

public class EncryptPassword {
	public String getEncryptedPassword(String password) {
		StringBuffer stringBuffer = null;
		try {
			MessageDigest messageDigest = MessageDigest.getInstance("SHA-256");
			messageDigest.update(password.getBytes());
			byte byteArray[] = messageDigest.digest();
			stringBuffer = new StringBuffer();
			for (int i = 0; i < byteArray.length; i++) {
				String hexValue = Integer.toHexString(byteArray[i] & 0xff);
				if (hexValue.length() == 1) {
					stringBuffer.append('0');
				}
				stringBuffer.append(hexValue);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return stringBuffer.toString();
	}
}
