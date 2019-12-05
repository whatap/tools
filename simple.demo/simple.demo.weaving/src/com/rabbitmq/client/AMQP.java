package com.rabbitmq.client;

import java.io.DataInputStream;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import whatap.agent.api.trace.TxMethod;
import whatap.agent.api.weaving.OriginMethod;
import whatap.agent.api.weaving.Weaving;
import whatap.agent.trace.LocalContext;
import whatap.agent.trace.TraceContext;
import whatap.agent.trace.TraceContextManager;
import whatap.agent.api.weaving.SkipLoad;
import whatap.agent.Configure;
import whatap.util.KeyGen;
import whatap.util.Hexa32;

@SkipLoad 
public interface AMQP {
	@Weaving 
	public static class BasicProperties {
		
		@Weaving
		public static final class Builder {
			private Map<String,Object> headers;
			public BasicProperties build() {
				Object stat = null; 
				Throwable thr = null; 
				 try{
					if(headers ==  null) {
						headers = new HashMap<String,Object>();
					}
					Configure conf = Configure.getInstance();         
					if (conf.mtrace_enabled && headers != null) {              
						TraceContext ctx = TraceContextManager.getLocalContext();
						
						if (ctx != null) {
							if(!ctx.mtid_build_checked) {
								ctx.mtid = KeyGen.next();
								ctx.mtid_build_checked = true;
							}
							headers.put(conf._trace_mtrace_poid_key, TraceContext.transferPOID());     
							if (conf.stat_mtrace_enabled) { 
								 headers.put(conf._trace_mtrace_spec_key, ctx.transferSPEC_URL());      
							}      
							if (ctx.mtid != 0) {                    
								headers.put(conf._trace_mtrace_caller_key, ctx.transferMTID_CALLERTX());            
								if (conf.mtrace_callee_txid_enabled) { 
									ctx.mcallee = KeyGen.next(); 
									headers.put(conf._trace_mtrace_callee_key,                              
										 Hexa32.toString32(ctx.mcallee));          
								 }       
							 }  
						 }
					}
				 } catch (Throwable e) {  
					 e.printStackTrace();
				 }				
				
				try { 
					try { 
						stat = TxMethod.start("AMQP.BasicProperties.Builder.build");
					} catch (Throwable t) {
						t.printStackTrace();
					} 
				 
					return OriginMethod.call();
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

		public Map<String, Object> getHeaders() {
			
			return OriginMethod.call();
		}
	}
}
