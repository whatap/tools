package simple.demo.service;

import java.io.IOException;
import java.util.concurrent.TimeoutException;

import redis.clients.jedis.Jedis;
import redis.clients.jedis.JedisPool;
import redis.clients.jedis.JedisPoolConfig;

public class SimpleCacheService {
	private static SimpleCacheService instance; 
	public static synchronized SimpleCacheService getInstance() throws IOException, TimeoutException {
		if (instance == null) {
			instance = new SimpleCacheService ();
			instance.init();
		}
		return instance;
	}
	JedisPoolConfig jedisPoolConfig ;
	JedisPool pool ;
	private void init() {
		jedisPoolConfig = new JedisPoolConfig();
        
        pool = new JedisPool(jedisPoolConfig, "192.168.1.92", 6379, 1000);
		
	}

	public void pushMessage(String key, String value) {
		Jedis jedis = pool.getResource();
		try {
			jedis.set(key, value);
		}finally {
			jedis.close();
		}

	}

}
