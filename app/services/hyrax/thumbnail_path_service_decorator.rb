# frozen_string_literal: true

# OVERRIDE Hyrax v5.0.0rc2 - index using site defaults instead of app wide defaults

module Hyrax
  module ThumbnailPathServiceDecorator
    def call(object)
      return super unless object.try(:collection?)

      collection_thumbnail = CollectionBrandingInfo.where(collection_id: object.id.to_s, role: "thumbnail").first
      return collection_thumbnail.local_path.gsub(Rails.public_path.to_s, '') if collection_thumbnail

      default_collection_image
    end

    def default_collection_image
      Site.instance.default_collection_image&.url || ActionController::Base.helpers.image_path('default.png')
    end

    def default_image
      Site.instance.default_work_image&.url || super
    end
  end
end

Hyrax::ThumbnailPathService.singleton_class.send(:prepend, Hyrax::ThumbnailPathServiceDecorator)
