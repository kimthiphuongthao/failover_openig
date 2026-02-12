// Minimalist Failover Script with Logging
import org.forgerock.http.protocol.Response

System.out.println("DEBUG: ScriptableFilter loaded/compiled.")
if (session != null) {
    System.out.println("DEBUG: Session type: " + session.getClass().getName())
    System.out.println("DEBUG: Session content before put: " + session.entrySet())
} else {
    System.out.println("DEBUG: Session is NULL")
}

return next.handle(context, request).then { response ->
    def nodeName = System.getenv('OPENIG_NODE_ID') ?: 'unknown'
    System.out.println("DEBUG: Filter running on node: " + nodeName)
    
    response.headers.add('X-OpenIG-Node', nodeName)
    
    // Simple logic: get value 'test', if missing set it.
    def val = session.get('test_attr')
    if (val == null) {
        System.out.println("DEBUG: Creating new session on " + nodeName)
        session.put('test_attr', 'initial-' + nodeName)
        response.headers.add('X-Session-Status', 'NEW_SESSION_ON_' + nodeName)
    } else {
        System.out.println("DEBUG: Resuming session from " + val + " on " + nodeName)
        response.headers.add('X-Session-Status', 'RESUMED_FROM_' + val)
    }
    return response
}