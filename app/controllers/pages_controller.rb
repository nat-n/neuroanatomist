class PagesController < ApplicationController
  include NodesHelper
  
  def home
    render :debug and return if params.has_key? "debug"
    return explore
  end
  
  def explore
    @jax = Hash[
      controller: 'explore'
    ]
    @node = Node.default
    return access_node nil, @node
  end
  
  def quiz
    @shape_set = ShapeSet.default
    @perspective = ( @shape_set.default_perspective or nil )
    @jax = Hash[
      controller: 'quiz'
    ]
    
    accessible = Quiz.accessible_regions.select{|r| r.definition_for @shape_set}
    viewable   = Quiz.viewable_regions.select{|r| r.definition_for @shape_set}
    
    @quiz_list = Hash[accessible.map{|r| [r.id, {name:r.name, a:true}]}]
    viewable.each { |r| @quiz_list[r.id] = {name:r.name, a:(@quiz_list[r.id] ? true : false), p:r.default_perspective_id} }
  end
  
  def about
    
  end
  
  def contact
    DataMailer.feedback(params[:subject],params[:message],current_user).deliver if params[:subject] and params[:message]
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
      @jax = Hash[
        controller: 'explore'
      ]
      
      render :action => :explore
    end
  end

  def access_thing
    @thing = (Thing.find_by_name(params[:thing_name][1..-1]) or return record_not_found(params[:node_name][1..-1]))
    @node = @thing.node
    redirect_to "/node:#{@node.name}"
  end
  
end
