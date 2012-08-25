class Thing < ActiveRecord::Base
  belongs_to  :type
  has_one     :node
  has_one     :tag, :through => :node
  has_many    :regions
  has_many    :subject_facts, :class_name => 'Fact', :foreign_key => 'subject_id', :dependent => :destroy
  has_many    :object_facts, :class_name => 'Fact', :foreign_key => 'object_id', :dependent => :destroy
  validates_uniqueness_of :name
  validates_presence_of :name, :type
  
  def facts
    subject_facts + object_facts
  end
  
  def name
    attribute(:name).gsub(/_+/, " ")
  end
  
  def wikipedia_uri printable=false
    "http://en.wikipedia.org/wiki/#{wikipedia_title}#{"?printable=yes" if printable}" unless wikipedia_title.to_s.empty?
  end
  
  def dbpedia_uri mode = :page
    mode = :page unless [:ntriples,:json].include? mode
    "http://dbpedia.org/#{(mode==:page)?"page":"data"}/#{dbpedia_resource}#{(mode==:json ? ".json" : (mode==:ntriples ? ".ntriples" : ""))}" unless dbpedia_resource.to_s.empty?
  end

  def neurolex_uri rdf=false
    "http://neurolex.org/wiki#{"/Special:ExportRDF" if rdf}/Category:#{neurolex_category}" unless neurolex_category.to_s.empty?
  end

  def scholarpedia_uri printable=false
    return "http://www.scholarpedia.org/article/#{scholarpedia_article}#{"?printable=yes" if printable}" unless scholarpedia_article.to_s.empty?
    return nil
  end
  
end