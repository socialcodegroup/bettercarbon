module Facebook::CalculatorHelper
  def fb_render_field_for_module_input(form, module_name, input, value, params = {})
    case input[:type]
    when :text_field
      # text_field_tag("profile[#{module_name.to_s}][#{input[:name]}]", params[:show_value]==false ? nil : number_with_precision(value, :precision => 2))
      form.text_field "profile[#{module_name.to_s}][#{input[:name]}]", params[:show_value]==false ? nil : number_with_precision(value, :precision => 2), :label => input[:title]
    when :check_box
      check_box_tag("profile[#{module_name.to_s}][#{input[:name]}]", 1, (value + 0.5).to_i == 1)
    when :select
      select_tag("profile[#{module_name.to_s}][#{input[:name]}]", options_for_select(input[:options], params[:show_value]==false ? nil : value.round.to_s))
    else
      "Unknown"
    end
  end
end
