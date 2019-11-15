package simple.demo.rest;

import java.io.IOException;
import java.util.concurrent.TimeoutException;

import javax.servlet.http.HttpServletResponse;

import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;

import simple.demo.service.SimpleCacheService;
import simple.demo.service.SimpleQueueService;


@RestController
public class SimpleWeb {

	@ResponseBody
	@RequestMapping(value = "/load/rabbitmq", produces = "application/json; charset=utf8", method = RequestMethod.GET)
	public String rabbitMQTraffic(HttpServletResponse response) throws IOException, TimeoutException {
		
		SimpleQueueService.getInstance().pushMessage("hello world");
		return "/load/rabbitmq success";
	}
	
	@ResponseBody
	@RequestMapping(value = "/load/redis", produces = "application/json; charset=utf8", method = RequestMethod.GET)
	public String redisTraffic(HttpServletResponse response) throws IOException, TimeoutException {
		
		SimpleCacheService.getInstance().pushMessage("now","unix epoch time mills: "+System.currentTimeMillis());
		return "/load/redis success";
	}
}
