require 'rails_erd/domain'

def init
  super
  sections.place(:entity_relationship_diagram).before(:children)
end

def entity_relationship_diagram
  if active_record_namespace?
    generate_entity_relationship_diagram
    erb(:entity_relationship_diagram)
  end
end

def active_record_namespace?
  !namespace_domain_models.empty?
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

# The root classes from which to generate the cluster
#
# @return [Array<Class<ActiveRecord::Base>>]
def cluster_roots
  namespace_domain_models
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
  # domain needs to include the superclasses for Single-Table Inheritance classes
  cluster = Metasploit::Credential::EntityRelationshipDiagram.cluster(*cluster_roots)
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
  doc_pathname_without_extension = Metasploit::Credential::Engine.root.join('doc', asset_path_without_extension)
  doc_pathname_without_extension.parent.mkpath

  Metasploit::Credential::EntityRelationshipDiagram.create(
      domain: domain,
      filename: doc_pathname_without_extension.to_path,
      filetype: :png,
      title: "#{object.title} Entity-Relation Diagram"
  )

  extension = '.png'
  doc_path = "#{doc_pathname_without_extension}#{extension}"
  content = File.read doc_path
  asset_path = "#{asset_path_without_extension}#{extension}"
  asset(asset_path, content)
end

def namespace_domain_models
  Metasploit::Credential::Engine.instance.eager_load!

  ActiveRecord::Base.descendants.select { |klass|
    klass.parents.any? { |parent|
      parent.name == object.title
    }
  }
end