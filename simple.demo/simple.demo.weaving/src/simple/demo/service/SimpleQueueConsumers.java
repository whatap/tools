package simple.demo.service;
import whatap.agent.api.weaving.OriginMethod;
import whatap.agent.api.weaving.Weaving;
import whatap.agent.trace.LocalContext;
import whatap.agent.trace.TraceContext;
import whatap.agent.trace.TraceContextManager;

import java.io.IOException;
import java.util.Map;
import java.util.concurrent.TimeoutException;

import com.rabbitmq.client.AMQP;
import com.rabbitmq.client.Envelope;
import com.rabbitmq.client.LongString;

import whatap.agent.Configure;
import whatap.agent.api.trace.TxMethod;

@Weaving(match="interface", name="com.rabbitmq.client.Consumer", prefix="simple.demo.service") 
public class SimpleQueueConsumers {
	
	public void handleDelivery(String consumerTag, Envelope envelope,
	          AMQP.BasicProperties properties, byte[] body) throws IOException {
		Object stat = null; 
		Throwable thr = null; 
		try { 
			try { 
				stat = TxMethod.start("SimpleQueueConsumers.handleDelivery");
				
				TraceContext ctx = ((LocalContext) stat).context;
				Map<String,Object> headers = properties.getHeaders();
				if(ctx != null && headers != null) {
					Configure conf = Configure.getInstance();     
					if (headers.containsKey(conf._trace_mtrace_spec_key)) { 
						ctx.setTransferSPEC_URL(new String(((LongString)headers.get(conf._trace_mtrace_spec_key)).getBytes())); 
					}
					if (headers.containsKey(conf._trace_mtrace_caller_key)) { 
						ctx.setTransferMTID_CALLERTX(new String(((LongString)headers.get(conf._trace_mtrace_caller_key)).getBytes())); 
					}
					if (headers.containsKey(conf._trace_mtrace_poid_key)) {
						ctx.setCallerPOID(new String(((LongString)headers.get(conf._trace_mtrace_poid_key)).getBytes())); 
					}
					if (headers.containsKey(conf._trace_mtrace_callee_key)) {
						ctx.setTxid(new String(((LongString)headers.get(conf._trace_mtrace_callee_key)).getBytes())); 
					}
				}
			} catch (Throwable t) {
				t.printStackTrace();
			} 
		 
			OriginMethod.call();
		} catch(Exception e){
			thr = e;
			throw e;
		}finally { 
			try { 
				TxMethod.end(stat, thr); 
			} catch (Throwable t) {
				t.printStackTrace();
			} 
		}
	}
}
