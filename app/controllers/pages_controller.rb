class PagesController < ApplicationController
  include NodesHelper
  
  def home
    render :debug and return if params.has_key? "debug"
    @node = Node.default
    return access_node nil, @node
  end
  
  def about
    
  end
  
  def contact
    
  end
  
  def access_node shape_set = nil, node = nil
    node_name = (params[:node_name].split(':')[1] rescue node.name)
    if params[:node_name] and params[:node_name].end_with? ':embed'
      @node = Node.find_by_name(node_name) or return record_not_found(node_name) unless node
      return redirect_to :controller => '/nodes', :action => 'show', :id => "#{@node.id}"<<":embed"
    else
      @node = Node.find_by_name(node_name) or return record_not_found(node_name) unless node
      @node_data = embedded_json
      shape_set = (shape_set or ShapeSet.default)
      @perspective = ( @node.perspective or shape_set.default_perspective or nil )
      @shape_set = shape_set.hash_partial(@cascade)
      @shape_set = @shape_set.merge(@shape_set.delete(:attrs))
    
      # NOTE TO FUTURE SELF: will probably need some kind of check for perspective/shape_set compatibility here eventually
    
      render :action => :home
    end
  end

  def access_thing
    @thing = (Thing.find_by_name(params[:thing_name][1..-1]) or return record_not_found(params[:node_name][1..-1]))
    @node = @thing.node
    redirect_to "/node:#{@node.name}"
  end
  
end
