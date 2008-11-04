module Simplicity

  module SimpleFormHelper
    def simple_form_for(record_or_name_or_array, *args, &proc)
      options = args.extract_options!
      # Remove any nils if we received an array, this allows for common forms to be built
      # that can be used for both edit and new actions but that don't require the edit action
      # to be nested within a parent resource
      record_or_name_or_array.reject! {|a| a.nil? } if record_or_name_or_array.is_a? Array 
      # Now build the form
      form_for(record_or_name_or_array, *(args << options.merge(:builder => SimpleFormBuilder)), &proc)
    end
    
    def smart_fields_for(record_or_name_or_array, *args, &proc)
      options = args.extract_options!
      fields_for(record_or_name_or_array, *(args << options.merge(:builder => Simp;eFormBuilder)), &proc)
    end    
  end

  class SmartFormBuilder < ActionView::Helpers::FormBuilder

    def date_select(method, options={})
      labelled_field(method, options, super)
    end

    def time_select(method, options={})
      labelled_field(method, options, super)
    end

    def text_field(method, options={})
      labelled_field(method, options, super)
    end

    def password_field(method, options={})
      labelled_field(method, options, super)
    end

    def text_area(method, options={})
      labelled_field(method, options, super)
    end

    def check_box(field, options={}, checked_value="1", unchecked_value="0")
      labelled_field(method, options, super)
    end

    def radio_button(method, tag_value, options={})
      @template.content_tag :li, super + radio_label(method, tag_value, options)
    end

    def select(method, choices, options={}, html_options={})
      labelled_field(method, options, super)
    end

    def collection_select(method, collection, value_method=:id, text_method=:name, options={}, html_options={})
      field_group(label(method, options) + super)
    end

    def country_select(method, priority_countries=nil, options={}, html_options={})
      labelled_field(method, options, super)
    end

    def time_zone_select(method, priority_zones=nil, options={}, html_options={})
      labelled_field(method, options, super)
    end

    def file_field(method, options={})
      labelled_field(method, options, super)
    end

    def fieldset(legend=nil, &block)
      @template.concat @template.tag(:fieldset, :class => "set", true),     block.binding
      @template.concat @template.content_tag(:h3, legend),                  block.binding unless legend.nil?
      @template.concat @template.tag(:ol, nil, true),                       block.binding

      yield

      @template.concat "</ol></fieldset>", block.binding
    end

    def inner_fieldset(legend=nil, &block)
      @template.concat @template.tag(:li, nil, true),                 block.binding
      @template.concat @template.tag(:fieldset, nil, true),           block.binding
      @template.concat @template.content_tag(:h3, "#{legend}:"),      block.binding unless legend.nil?
      @template.concat @template.tag(:ol, nil, true),                 block.binding

      yield

      @template.concat "</ol></fieldset></li>", block.binding
    end

    def submit(value="Save Changes", options={})
      @template.content_tag(:fieldset, super, :class => "button")
    end

    def labelled_field(method, options, field_markup)
      field_group(label(method, options) + field_markup)
    end

    def field_group(options={})
      @template.content_tag(:li, markup, options)
    end

    private

    def label(method, options={})
      text = options.delete(:label) || method.to_s.titleize
      text += ":" unless options.delete(:no_colon)

      ActionView::Helpers::InstanceTag.new(
        object_name, method, self, nil, options.delete(:object)
      ).to_label_tag(text)
    end

    def radio_label(method, value, options={})
      @template.content_tag :label,
        value.humanize,
        options.merge(:for => radio_button_id(method, value, options))
    end

    def radio_button_id(method, value, options)
      pretty_value = value.to_s.gsub(/\s/, "_").gsub(/\W/, "").downcase

      options[:id] || defined?(@auto_index) ?
        "#{object_name}_#{@auto_index}_#{method}_#{pretty_value}" :
        "#{object_name}_#{method}_#{pretty_value}"
    end
    
    def cancel_link(options_or_url)
      if options_or_url.is_a? Hash
        cancel_url   = options_or_url.delete(:url)
        dom_class    = options_or_url.delete(:class)
        cancel_label = options_or_url.delete(:label)
      else
        cancel_url   = options_or_url 
        dom_class    = nil
        cancel_label = nil
      end
      @template.link_to cancel_label || "Cancel", cancel_url || :back, :class => "cancel #{dom_class}"
    end
  end
    
end