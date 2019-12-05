package simple.demo.service;
import whatap.agent.api.weaving.OriginMethod;
import whatap.agent.api.weaving.Weaving;
import whatap.agent.trace.TraceContext;
import whatap.agent.trace.TraceContextManager;

import java.io.IOException;
import java.util.concurrent.TimeoutException;

import whatap.agent.api.trace.TxMethod;

@Weaving
public class SimpleQueueService {
	
	public String pushMessage(String message) throws IOException, TimeoutException {
		Object stat = null; 
		Throwable thr = null; 
		try {
//			TraceContext ctx = TraceContextManager.getLocalContext();
//			TraceContextManager.end(TraceContextManager.getCurrentTraceId());
			try { 
//				System.out.println("Starting SimpleCacheService.pushMessage");
				stat = TxMethod.start("SimpleQueueService.pushMessage");
			} catch (Throwable t) {
				t.printStackTrace();
			} 
		 
			return OriginMethod.call();
		} catch(Exception e){
			thr = e;
			throw e;
		}finally { 
			try { 
//				System.out.println("Ending SimpleCacheService.pushMessage");
				TxMethod.end(stat, thr); 
			} catch (Throwable t) {
				t.printStackTrace();
			} 
		}
	}
}
