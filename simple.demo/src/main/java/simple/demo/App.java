package simple.demo;

import java.io.IOException;
import java.util.concurrent.TimeoutException;

import org.springframework.boot.SpringApplication;

import simple.demo.batch.SimpleBatchService;

public class App {
	public static void main(String[] args) throws IOException, TimeoutException, InterruptedException {
		if (args != null && args.length > 0) {
			if ("batch".equals(args[0])) {
				SimpleBatchService.printMessages();
			}
		}else {
			SpringApplication app = new SpringApplication(Config.class);
			app.run(args);
		}
	}
}
