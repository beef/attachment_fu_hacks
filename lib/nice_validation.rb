Technoweenie::AttachmentFu::InstanceMethods.module_eval do
  protected
    def attachment_attributes_valid?
      if self.filename.nil?
        errors.add_to_base attachment_validation_options[:empty]
        return
      end
      [:content_type, :size].each do |option|
        if attachment_validation_options[option] && attachment_options[option] && !attachment_options[option].include?(self.send(option))
          errors.add_to_base attachment_validation_options[option]
        end
      end
    end
end

Technoweenie::AttachmentFu::ClassMethods.module_eval do
  # Options: 
  # *  <tt>:empty</tt> - Base error message when no file is uploaded. Default is "No file uploaded" 
  # *  <tt>:content_type</tt> - Base error message when the uploaded file is not a valid content type.
  # *  <tt>:size</tt> - Base error message when the uploaded file is not a valid size.
  #
  # Example:
  #   validates_as_attachment :content_type => "The file you uploaded was not a JPEG, PNG or GIF",
  #                        :size         => "The image you uploaded was larger than the maximum size of 10MB" 
  def validates_as_attachment(options={})
    class_inheritable_accessor :attachment_validation_options
    if attachment_options[:content_type] == Technoweenie::AttachmentFu.content_types
      content_error = "an image."
    elsif self.attachment_options[:content_type]
      content_error = attachment_options[:content_type].map{|ct| ct.split('/').last }.join(', ')
    end
    self.attachment_validation_options = options.reverse_merge({
      :content_type => "The file you uploaded is not #{content_error}",
      :size         => "The image you uploaded is larger than the maximum size of #{self.attachment_options[:max_size]/(1024.0 * 1024.0)}mb",
      :empty        => "No file uploaded"
    })
    validate :attachment_attributes_valid? unless validate_callback_chain.find(:attachment_attributes_valid?) # Prevents this from being called twice
  end
end