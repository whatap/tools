package simple.demo.service;

import java.io.IOException;
import java.util.concurrent.TimeoutException;

import com.rabbitmq.client.AMQP;
import com.rabbitmq.client.AMQP.BasicProperties;
import com.rabbitmq.client.Channel;
import com.rabbitmq.client.Connection;
import com.rabbitmq.client.ConnectionFactory;
import com.rabbitmq.client.Consumer;
import com.rabbitmq.client.DefaultConsumer;
import com.rabbitmq.client.Envelope;
import com.rabbitmq.client.ShutdownSignalException;

public class SimpleQueueConsumers {

	private final static String QUEUE_NAME = "hello";
	
	public SimpleQueueConsumers() {
		
	}

	private static SimpleQueueConsumers instance; 
	public static synchronized SimpleQueueConsumers getInstance() throws IOException, TimeoutException {
		if (instance == null) {
			instance = new SimpleQueueConsumers ();
			instance.init();
		}
		return instance;
	}

	ConnectionFactory factory ;
	Connection connection ;
	Channel channel ;
	private void init() throws IOException, TimeoutException {
		factory = new ConnectionFactory();
	    factory.setHost("192.168.1.92");
	    factory.setUsername("rabbitmq");
	    factory.setPassword("rabbitmq");
	    factory.setVirtualHost("/");
	    connection = factory.newConnection();
	    channel = connection.createChannel();
	    channel.queueDeclare(QUEUE_NAME, false, false, false, null);
	    
	    
		
	}

	public void consume() throws IOException {
		Consumer consumer = new Consumer() {
		  
	      @Override
	      public void handleDelivery(String consumerTag, Envelope envelope,
	          AMQP.BasicProperties properties, byte[] body) throws IOException {
	        String message = new String(body, "UTF-8");
	        System.out.println(" [x] Received '" + message + "'");
	      }

		@Override
		public void handleConsumeOk(String consumerTag) {
			// TODO Auto-generated method stub
			
		}

		@Override
		public void handleCancelOk(String consumerTag) {
			// TODO Auto-generated method stub
			
		}

		@Override
		public void handleCancel(String consumerTag) throws IOException {
			// TODO Auto-generated method stub
			
		}

		@Override
		public void handleShutdownSignal(String consumerTag, ShutdownSignalException sig) {
			// TODO Auto-generated method stub
			
		}

		@Override
		public void handleRecoverOk(String consumerTag) {
			// TODO Auto-generated method stub
			
		}
	    };
	    channel.basicConsume(QUEUE_NAME, true, consumer);
	}
}
