module MetaTagsHelper
  def meta_title
    content_for?(:meta_title) ? content_for(:meta_title) : Current.store.meta_title
  end

  def meta_description
    content_for?(:meta_description) ? content_for(:meta_description) : Current.store.meta_description
  end

  def meta_image
    meta_image = (content_for?(:meta_image) ? content_for(:meta_image) : Current.store.meta_image)
    # little twist to make it work equally with an asset or a url
    meta_image.starts_with?("http") ? meta_image : image_url(meta_image)
  end
end
