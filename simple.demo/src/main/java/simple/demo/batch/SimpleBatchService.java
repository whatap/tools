package simple.demo.batch;

import java.io.IOException;
import java.util.concurrent.TimeoutException;

import simple.demo.service.SimpleQueueService;

public class SimpleBatchService {

	public static void printMessages() throws IOException, TimeoutException, InterruptedException {
		SimpleQueueService.getInstance().consume();
		while(true) {
			Thread.sleep(1000);			
		}		
	}

}
