from treelib import Tree, Node
 
 
tree = Tree()
tree.show()
tree.create_node(tag='Node-5', identifier='node-5', data=5)
tree.create_node(tag='Node-10', identifier='node-10', parent='node-5', data=10)
tree.create_node('Node-15', 'node-15', 'node-10', 15)
tree.show()

node = Node(data=50)
tree.add_node(node, parent='node-5')
node_a = Node(tag='Node-A', identifier='node-A', data='A')
tree.add_node(node_a, parent='node-5')
tree.show()
print(tree.identifier)

