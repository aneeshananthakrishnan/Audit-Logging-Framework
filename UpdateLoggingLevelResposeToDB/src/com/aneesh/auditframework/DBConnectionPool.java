package com.aneesh.auditframework;

import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.util.Properties;

import javax.naming.Context;
import javax.naming.InitialContext;

import oracle.ucp.jdbc.PoolDataSourceFactory;
import oracle.ucp.jdbc.PoolDataSource;

public class DBConnectionPool {

	protected DBConnectionPool() {
	}

	private static PoolDataSource dbConnectionPool = null;

	public static synchronized PoolDataSource getDBConnection() {
		try {
			if (dbConnectionPool == null) {
				Properties properties = new Properties();

				InputStream fin = new FileInputStream(new File(System.getProperty("dbconn.properties")));
				properties.load(fin);
				
				String dbUrl = (String) properties.getProperty("dbUrl");
				String dbUser = (String) properties.getProperty("dbUser");
				String dbPassword = (String) properties.getProperty("dbPassword");
				int dbMaxPoolSize = Integer.parseInt((String)properties.getProperty("dbMaxPoolSize"));
				int dbMinPoolSize = Integer.parseInt((String)properties.getProperty("dbMinPoolSize"));
				
				dbConnectionPool = PoolDataSourceFactory.getPoolDataSource();
				dbConnectionPool.setConnectionFactoryClassName("oracle.jdbc.pool.OracleDataSource");
				dbConnectionPool.setURL(dbUrl);
				dbConnectionPool.setUser(dbUser);
				dbConnectionPool.setPassword(dbPassword);
				dbConnectionPool.setInitialPoolSize(dbMinPoolSize);
				dbConnectionPool.setMaxPoolSize(dbMaxPoolSize);
				dbConnectionPool.setMinPoolSize(dbMinPoolSize);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return dbConnectionPool;
	}
}
