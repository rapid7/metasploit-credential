require 'rails_erd/domain'

def init
  super
  sections.place(:entity_relationship_diagram).before(:subclasses)
end

def entity_relationship_diagram
  if active_record?
    generate_entity_relationship_diagram
    erb(:entity_relationship_diagram)
  end
end

def active_record?
  inheritance_tree = object.inheritance_tree
  inheritance_titles = inheritance_tree.map(&:title)

  inheritance_titles.include? 'ActiveRecord::Base'
end

#
# Generates a file to the output with the specified contents.
#
# @example saving a custom html file to the documenation root
#
#   asset('my_custom.html','<html><body>Custom File</body></html>')
#
# @param [String] path relative to the document output where the file will be
#   created.
# @param [String] content the contents that are saved to the file.
def asset(path, content)
  if options.serializer
    log.capture("Generating asset #{path}") do
      options.serializer.serialize(path, content)
    end
  end
end

def domain
  RailsERD::Domain.new(
      domain_models,
      # don't warn about missing entities in domain since has_many associations outside of the domain are
      # purposefully not included in the domain.
      :warn => false
  )
end

def domain_models
  Metasploit::Credential::Engine.instance.eager_load!

  # domain needs to include the superclasses for Single-Table Inheritance classes
  cluster = Metasploit::Credential::EntityRelationshipDiagram.cluster(object.title.constantize)
  subclass_queue = cluster.to_a

  until subclass_queue.empty?
    subclass = subclass_queue.pop
    superclass = subclass.superclass

    unless superclass == ActiveRecord::Base || cluster.include?(superclass)
      cluster.add superclass
      subclass_queue << superclass
    end
  end

  cluster
end

def generate_entity_relationship_diagram
  asset_path_without_extension = File.join('images', "#{object.title.underscore}.erd")
  docs_pathname_without_extension = Metasploit::Credential::Engine.root.join('docs', asset_path_without_extension)
  docs_pathname_without_extension.parent.mkpath

  Metasploit::Credential::EntityRelationshipDiagram.create(
      domain: domain,
      filename: docs_pathname_without_extension.to_path,
      filetype: :png,
      title: "#{object.title} Entity-Relation Diagram"
  )

  extension = '.png'
  docs_path = "#{docs_pathname_without_extension}#{extension}"
  content = File.read docs_path
  asset_path = "#{asset_path_without_extension}#{extension}"
  asset(asset_path, content)
end