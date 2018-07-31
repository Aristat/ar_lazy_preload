# frozen_string_literal: true

module ArLazyPreload
  # ActiveRecord::Base patch with lazy preloading support
  module Base
    def self.included(base)
      base.class.delegate :lazy_preload, to: :all
    end

    attr_accessor :lazy_preload_context

    # When context has been set, this method would cause preloading association with a given name
    def preload_association_for_context(association_name)
      lazy_preload_context.preload_association(association_name) if lazy_preload_context.present?
    end
  end
end