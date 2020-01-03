require 'rails_erd/domain'

def entity_relationship_diagram
  if active_record_namespace? || active_record?
    generate_entity_relationship_diagram
    erb(:entity_relationship_diagram)
  end
end

def active_record?
  inheritance_tree = object.inheritance_tree
  inheritance_titles = inheritance_tree.map(&:title)

  inheritance_titles.include? 'ApplicationRecord'
end

def cluster_roots
  super + [object.title.constantize]
end
