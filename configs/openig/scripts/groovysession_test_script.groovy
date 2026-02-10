// import org.forgerock.openig.session.Session // Removed import
// import org.forgerock.openig.services.context.Context // Removed import
// import org.forgerock.openig.core.Message // Removed import

def session = exchange.getProperty(org.forgerock.openig.session.Session.PROPERTY_NAME) // Use fully qualified name
def nodeName = System.getenv('OPENIG_NODE_ID') ?: 'unknown-node'
def sessionStatus = ""

if (session.getAttribute('failover_test_attribute') == null) {
    session.setAttribute('failover_test_attribute', 'created_on_' + nodeName)
    sessionStatus = 'NEW_SESSION_CREATED_ON_' + nodeName
} else {
    sessionStatus = 'EXISTING_SESSION_FROM_' + session.getAttribute('failover_test_attribute')
}

exchange.response.status = 200
exchange.response.headers.add('Content-Type', 'text/plain')
exchange.response.headers.add('X-Session-Status', sessionStatus)
exchange.response.headers.add('X-OpenIG-Node', nodeName)
exchange.response.entity = "Backend reached successfully.\nNode: ${nodeName}\nSession Status: ${sessionStatus}"

return exchange