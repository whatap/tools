package simple.demo.service;
import whatap.agent.api.weaving.OriginMethod;
import whatap.agent.api.weaving.Weaving;
import whatap.agent.trace.TraceContext;
import whatap.agent.trace.TraceContextManager;
import whatap.agent.api.trace.TxMethod;

@Weaving
public class SimpleCacheService {
	
	public void pushMessage(String key, String value) {

		Object stat = null; 
		Throwable thr = null; 
		try { 
			try { 
//				System.out.println("Starting SimpleCacheService.pushMessage");
				stat = TxMethod.start("SimpleCacheService.pushMessage");
			} catch (Throwable t) {
				t.printStackTrace();
			} 
		 
			OriginMethod.call(); 
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
