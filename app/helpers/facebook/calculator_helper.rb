module Facebook::CalculatorHelper
  def fb_render_field_for_module_input(form, module_name, input, value, params = {})
    case input[:type]
    when :text_field
      # text_field_tag("profile[#{module_name.to_s}][#{input[:name]}]", params[:show_value]==false ? nil : number_with_precision(value, :precision => 2))
      form.text_field "profile[#{module_name.to_s}][#{input[:name]}]", :value => params[:show_value]==false ? nil : number_with_precision(value, :precision => 2), :label => input[:title]
    when :check_box
      form.check_box "profile[#{module_name.to_s}][#{input[:name]}]", :label => input[:title], :value => (value + 0.5).to_i == 1
    when :select
      form.select "profile[#{module_name.to_s}][#{input[:name]}]", input[:options], :label => input[:title], :selected => params[:show_value]==false ? nil : value.round.to_s
      # select_tag("profile[#{module_name.to_s}][#{input[:name]}]", options_for_select(input[:options], params[:show_value]==false ? nil : value.round.to_s))
    else
      "Unknown"
    end
  end
end
