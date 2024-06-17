# frozen_string_literal: true

module ApplicationHelper
  # Yep, we're ignoring the advice; because the translations are safe as is the markdown converter.
  # rubocop:disable Rails/OutputSafety
  include ::HyraxHelper
  include SharedSearchHelper
  include Bulkrax::ApplicationHelper
  include HykuKnapsack::ApplicationHelper

  def group_navigation_presenter
    @group_navigation_presenter ||= Hyku::Admin::Group::NavigationPresenter.new(params:)
  end

  # Return collection thumbnail formatted for display:
  #  - use collection's branding thumbnail if it exists
  #  - use site's default collection image if one exists
  #  - fallback to Hyrax's default image
  def collection_thumbnail(document, _image_options = {}, url_options = {})
    view_class = url_options[:class]
    # The correct thumbnail SHOULD be indexed on the object
    return image_tag(document['thumbnail_path_ss'], class: view_class, alt: alttext_for(document)) if document['thumbnail_path_ss'].present?

    # If nothing is indexed, we just fall back to site default
    return image_tag(Site.instance.default_collection_image&.url, alt: alttext_for(document), class: view_class) if Site.instance.default_collection_image.present?

    # fall back to Hyrax default if no site default
    tag.span("", class: [Hyrax::ModelIcon.css_class_for(::Collection), view_class],
                 alt: alttext_for(document))
  end

  def label_for(term:, record_class: nil)
    locale_for(type: 'labels', term:, record_class:)
  end

  def alttext_for(collection)
    thumbnail = CollectionBrandingInfo.where(collection_id: collection.id, role: "thumbnail")&.first
    return thumbnail.alt_text if thumbnail
    block_for(name: 'default_collection_image_text') || "#{collection.title_or_label} #{t('hyrax.dashboard.my.sr.thumbnail')}"
  end

  def hint_for(term:, record_class: nil)
    hint = locale_for(type: 'hints', term:, record_class:)

    return hint unless missing_translation(hint)
  end

  def locale_for(type:, term:, record_class:)
    term              = term.to_s
    record_class      = record_class.to_s.downcase
    work_or_collection = record_class == 'collection' ? 'collection' : 'defaults'
    locale             = t("hyrax.#{record_class}.#{type}.#{term}")

    if missing_translation(locale)
      (t("simple_form.#{type}.#{work_or_collection}.#{term}") || term.titleize) .html_safe
    else
      locale.html_safe
    end
  end

  def missing_translation(value, _options = {})
    return true if value == false
    return true if value.try(:false?)
    false
  end

  def markdown(text)
    return text unless Flipflop.treat_some_user_inputs_as_markdown?

    # Consider extracting these options to a Hyku::Application
    # configuration/class attribute.
    options = %i[
      hard_wrap autolink no_intra_emphasis tables fenced_code_blocks
      disable_indented_code_blocks strikethrough lax_spacing space_after_headers
      quote footnotes highlight underline
    ]
    text ||= ""
    Markdown.new(text, *options).to_html.html_safe
  end
  # rubocop:enable Rails/OutputSafety
end
