require 'logger'
require 'rules/has_rules'
require 'rules/parameters/attribute'

module Rules
  class RuleSet < ActiveRecord::Base
    belongs_to :source, polymorphic: true

    has_many :rules, class_name: 'Rules::Rule'

    accepts_nested_attributes_for :rules, allow_destroy: true

    validates_inclusion_of :evaluation_logic, in: %w(all any), allow_nil: true, allow_blank: true

    @@attributes = Hash.new({})

    def self.set_attributes_for(klass, klass_attributes)
      @@attributes[klass] = @@attributes[klass].merge(attributize(klass_attributes))
    end

    def self.attributes
      @@attributes
    end

    def self.attributize(attributes_hash)
      mapped_hash = {}
      attributes_hash.each do |k, v|
        mapped_hash[k] = Rules::Parameters::Attribute.new(v.merge(key: k))
      end
      mapped_hash
    end

    def source_class
      source ? source.class : source_type.try(:constantize)
    end

    def attributes
      return {} unless source_class
      self.class.attributes[source_class]
    end

    def value_for_target(parameter, target)
      return nil unless target

      associated_attribute_name = parameter.associated_attribute_name
      if target.respond_to?(:map)
        target.map {|t| t.send(associated_attribute_name) }
      else
        target.send(associated_attribute_name)
      end
    end

    def value_for_parameter(parameter, association, options = {})
      target = if parameter.through
        association.send(parameter.association)
      else
        association
      end
      value_for_target(parameter, target)
    end

    def add_association_value_to_hash!(hash, parameter)
      key = parameter.key
      reflection_name = (parameter.through ? parameter.through : parameter.association).to_s

      association = source_class.reflections[reflection_name]
      return unless association

      if association.collection?
        associated_items = source.send(reflection_name)
        associated_items.each do |item|
          hash[key] ||= []
          value = value_for_parameter(parameter, item)
          if value.is_a?(Array)
            hash[key] = value
          else
            hash[key] << value
          end
        end
      else
        association = source.send(reflection_name)
        hash[key] ||= value_for_parameter(parameter, association)
      end
    end

    def add_local_value_to_hash!(hash, parameter)
      hash[parameter.key] = source.send(parameter.key)
    end

    def collected_attributes
      mapped_hash = {}
      attributes.each do |key, parameter|
        begin
          if parameter.association
            add_association_value_to_hash!(mapped_hash, parameter)
          else
            add_local_value_to_hash!(mapped_hash, parameter)
          end
        rescue Exception => e
          message = "rules gem: Parameter #{parameter.key} appears to be misconfigured."
          logger = Logger.new(STDOUT)
          logger.warn(message)
          logger.error(e)
        end
      end
      mapped_hash
    end

    # TODO: Arbitrary rule set logic (Treetop)
    def evaluate(attributes = {})
      return true unless rules.any?
      attributes_to_evaluate = collected_attributes.merge(attributes)
      if evaluation_logic == 'any'
        !!rules.detect { |rule| rule.evaluate(attributes_to_evaluate) }
      else
        rules.each do |rule|
          return false unless rule.evaluate(attributes_to_evaluate)
        end
        true
      end
    end
  end
end
