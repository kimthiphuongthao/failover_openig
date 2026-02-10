// Minimalist Failover Script
import org.forgerock.http.protocol.Response

return next.handle(context, request).then { response ->
    def nodeName = System.getenv('OPENIG_NODE_ID') ?: 'unknown'
    response.headers.add('X-OpenIG-Node', nodeName)
    
    // Simple logic: get value 'test', if missing set it.
    def val = session.get('test_attr')
    if (val == null) {
        session.put('test_attr', 'initial-' + nodeName)
        response.headers.add('X-Session-Status', 'NEW_SESSION_ON_' + nodeName)
    } else {
        response.headers.add('X-Session-Status', 'RESUMED_FROM_' + val)
    }
    return response
}