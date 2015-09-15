package com.aneesh.auditframework;

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
				Context context = new InitialContext();
				String dbUrl = (String) context.lookup("java:comp/env/dbUrl");
				String dbUser = (String) context.lookup("java:comp/env/dbUser");
				String dbPassword = (String) context.lookup("java:comp/env/dbPassword");
				int dbMaxPoolSize = Integer.parseInt((String) context.lookup("java:comp/env/dbMaxPoolSize"));
				int dbMinPoolSize = Integer.parseInt((String) context.lookup("java:comp/env/dbMinPoolSize"));
				//int dbInactiveConnTimeout = Integer.parseInt((String) context.lookup("java:comp/env/dbInactiveConnTimeout"));
				dbConnectionPool = PoolDataSourceFactory.getPoolDataSource();
				dbConnectionPool.setConnectionFactoryClassName("oracle.jdbc.pool.OracleDataSource");
				dbConnectionPool.setURL(dbUrl);
				dbConnectionPool.setUser(dbUser);
				dbConnectionPool.setPassword(dbPassword);
				dbConnectionPool.setInitialPoolSize(dbMinPoolSize);
				dbConnectionPool.setMaxPoolSize(dbMaxPoolSize);
				dbConnectionPool.setMinPoolSize(dbMinPoolSize);
				//dbConnectionPool.setInactiveConnectionTimeout(dbInactiveConnTimeout);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return dbConnectionPool;
	}
}
