module NodesHelper

  def embedded_json
    # returns json wrapped fields for generating the embedded tabs view
    response = Hash[
      embedded_node: render_to_string(:partial => 'nodes/show', :layout => false),
      perspective: (@node.perspective ? @node.perspective.id : nil),
      resources: []
    ]
    response[:wikipedia_uri] = @node.wikipedia_uri(true) if @node.wikipedia_uri
    response[:scholarpedia_uri] = @node.scholarpedia_uri(true) if @node.scholarpedia_uri
    response
  end

end
