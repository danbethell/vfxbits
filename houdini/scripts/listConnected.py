import hou

# return all connections up & downstream
def listConnected( node, visited=None ):
    if visited is None:
        visited = []
    connected = []
    visited.append( node )
    for n in node.inputs() + node.outputs():
        if not n in visited:
            connected.append( n )
            connected += listConnected( n, visited )
    return connected
