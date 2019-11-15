package simple.demo.service;

import java.io.IOException;
import java.util.concurrent.TimeoutException;

import com.rabbitmq.client.AMQP;
import com.rabbitmq.client.Channel;
import com.rabbitmq.client.Connection;
import com.rabbitmq.client.ConnectionFactory;
import com.rabbitmq.client.Consumer;
import com.rabbitmq.client.DefaultConsumer;
import com.rabbitmq.client.Envelope;

public class SimpleQueueService {

	private final static String QUEUE_NAME = "hello";
	
	
	public String pushMessage(String message) throws IOException, TimeoutException {
		
		
	    channel.basicPublish("", QUEUE_NAME, null, message.getBytes());
	    
	    return " [x] Sent '" + message + "'";
		
	}
	
	public SimpleQueueService() {
		
	}

	private static SimpleQueueService instance; 
	public static synchronized SimpleQueueService getInstance() throws IOException, TimeoutException {
		if (instance == null) {
			instance = new SimpleQueueService ();
			instance.init();
		}
		return instance;
	}

	ConnectionFactory factory ;
	Connection connection ;
	Channel channel ;
	private void init() throws IOException, TimeoutException {
		factory = new ConnectionFactory();
	    factory.setHost("192.168.1.37");
	    factory.setUsername("rabbitmq");
	    factory.setPassword("rabbitmq");
	    factory.setVirtualHost("/");
	    connection = factory.newConnection();
	    channel = connection.createChannel();
	    channel.queueDeclare(QUEUE_NAME, false, false, false, null);
	    
	    
		
	}

	

	public void consume() throws IOException {
		Consumer consumer = new DefaultConsumer(channel) {
	      @Override
	      public void handleDelivery(String consumerTag, Envelope envelope,
	          AMQP.BasicProperties properties, byte[] body) throws IOException {
	        String message = new String(body, "UTF-8");
	        System.out.println(" [x] Received '" + message + "'");
	      }
	    };
	    channel.basicConsume(QUEUE_NAME, true, consumer);
	}

}
