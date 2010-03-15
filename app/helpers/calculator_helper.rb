module CalculatorHelper
  def largest_footprint_contributor(calculator_result)
    max = calculator_result.per_module_results.first
    calculator_result.per_module_results.each do |result|
      if result[1][:footprint] > max[1][:footprint]
        max = result
      end
    end
    
    max[0].pretty_module_name
  end
  
  def suggestions_by_proximity(lat, lng)
    Query.find(:all, :origin=> [lat, lng], :conditions => ['suggestion is not null and suggestion != ?', ''], :limit => 10, :order => 'distance asc')
  end
  
  def user_has_claimed_address(user_input)
    logged_in? && !ClaimedAddress.find(:first, :conditions => ['query_id = ?', user_input.id]).blank?
  end
  
  def random_city
    top_100_cities = [
      "New York, New York",
      "Los Angeles, California",
      "Chicago, Illinois",
      "Houston, Texas",
      "Phoenix, Arizona",
      "Philadelphia, Pennsylvania",
      "San Antonio, Texas",
      "San Diego, California",
      "Dallas, Texas",
      "Detroit, Michigan",
      "San Jose, California",
      "Indianapolis, Indiana",
      "Jacksonville, Florida",
      "San Francisco, California",
      "Hempstead, New York",
      "Columbus, Ohio",
      "Austin, Texas",
      "Memphis, Tennessee",
      "Baltimore, Maryland",
      "Charlotte, North Carolina",
      "Fort Worth, Texas",
      "Milwaukee, Wisconsin",
      "Boston, Massachusetts",
      "El Paso, Texas",
      "Washington, District of Columbia",
      "Nashville-Davidson, Tennessee",
      "Seattle, Washington",
      "Denver, Colorado",
      "Las Vegas, Nevada",
      "Portland, Oregon",
      "Oklahoma City, Oklahoma",
      "Tucson, Arizona",
      "Albuquerque, New Mexico",
      "Atlanta, Georgia",
      "Long Beach, California",
      "Brookhaven, New York",
      "Fresno, California",
      "New Orleans, Louisiana",
      "Sacramento, California",
      "Cleveland, Ohio",
      "Mesa, Arizona",
      "Kansas City, Missouri",
      "Virginia Beach, Virginia",
      "Omaha, Nebraska",
      "Oakland, California",
      "Miami, Florida",
      "Tulsa, Oklahoma",
      "Honolulu, Hawaii",
      "Minneapolis, Minnesota",
      "Colorado Springs, Colorado",
      "Arlington, Texas",
      "Wichita, Kansas",
      "St. Louis, Missouri",
      "Raleigh, North Carolina",
      "Santa Ana, California",
      "Anaheim, California",
      "Cincinnati, Ohio",
      "Tampa, Florida",
      "Islip, New York",
      "Pittsburgh, Pennsylvania",
      "Toledo, Ohio",
      "Aurora, Colorado",
      "Oyster Bay, New York",
      "Bakersfield, California",
      "Riverside, California",
      "Stockton, California",
      "Corpus Christi, Texas",
      "Buffalo, New York",
      "Newark, New Jersey",
      "St. Paul, Minnesota",
      "Anchorage, Alaska",
      "Lexington-Fayette, Kentucky",
      "Plano, Texas",
      "St. Petersburg, Florida",
      "Fort Wayne, Indiana",
      "Glendale, Arizona",
      "Lincoln, Nebraska",
      "Jersey City, New Jersey",
      "Greensboro, North Carolina",
      "Norfolk, Virginia",
      "Chandler, Arizona",
      "Henderson, Nevada",
      "Birmingham, Alabama",
      "Scottsdale, Arizona",
      "Madison, Wisconsin",
      "Baton Rouge, Louisiana",
      "North Hempstead, New York",
      "Hialeah, Florida",
      "Chesapeake, Virginia",
      "Garland, Texas",
      "Orlando, Florida",
      "Babylon, New York",
      "Lubbock, Texas",
      "Chula Vista, California",
      "Akron, Ohio",
      "Rochester, New York",
      "Winston-Salem, North Carolina",
      "Durham, North Carolina",
      "Reno, Nevada",
      "Laredo, Texas"
    ]
    
    top_100_cities[rand(top_100_cities.size)]
  end
  
  def render_field_for_module_input(module_name, input, value, params = {})
    case input[:type]
    when :text_field
      text_field_tag("profile[#{module_name.to_s}][#{input[:name]}]", params[:show_value]==false ? nil : number_with_precision(value, :precision => 2))
    when :check_box
      check_box_tag("profile[#{module_name.to_s}][#{input[:name]}]", 1, (value + 0.5).to_i == 1)
    when :select
      select_tag("profile[#{module_name.to_s}][#{input[:name]}]", options_for_select(input[:options], params[:show_value]==false ? nil : value.round.to_s))
    else
      "Unknown"
    end
  end
  
  def single_line_geolocated_address(calculator_input)
    case calculator_input.user_input.percision
    when "address"
      "#{calculator_input.user_input.street_address}, #{calculator_input.user_input.city}, #{calculator_input.user_input.state} #{calculator_input.user_input.zip}"
    when "zip+4"
      "#{calculator_input.user_input.street_address}, #{calculator_input.user_input.city}, #{calculator_input.user_input.state} #{calculator_input.user_input.zip}"
    when "state"
      "#{calculator_input.user_input.state}, #{calculator_input.user_input.country}"
    when "zip"
      "#{calculator_input.user_input.city}, #{calculator_input.user_input.state}, #{calculator_input.user_input.country}"
    else
      "Unknown Address"
      calculator_input.user_input.percision
    end
  end
  
  def tag_suggestion_dropdown_init_js(text_field_html_id, dropdown_html_id)
    init_js =<<EOF
    $('##{dropdown_html_id}').hide();

    $('body').click(function(e) {
      if ($(e.target).parents('#calculator_input_tags-dropdown-options').size() == 0) {
        $('##{dropdown_html_id}').hide();
      }
    });

    $('##{text_field_html_id}').delayedObserver(0.3, function(element, value) {
      if (value !== '') {
        if(value.lastIndexOf(', ') > 0){
          value = value.substring(value.lastIndexOf(',')+2, 255);
        }
        $.ajax({
          data:'element_id=#{text_field_html_id}&q=' + value, 
          success:function(request){
            if (request){
              $('##{dropdown_html_id}').html(request).show();
            }else{
              $('##{dropdown_html_id}').html('').hide();
            }
          }, 
          type:'get', url:'/calculator/tags_dropdown'});
        } else {
          $('##{dropdown_html_id}').html('').hide();
        }
      }
    );

    function tag_dropdown_click(name, text_field_html_id, dropdown_html_id){
      var text_field_element = $('#' + text_field_html_id);
      var dropdown_html_element = $('#' + dropdown_html_id);

      if(text_field_element.val().match(',')){
        var new_value = text_field_element.val().substring(0, text_field_element.val().lastIndexOf(',')) + ', ' + name + ", ";
        text_field_element.val(new_value);
      }else{
        text_field_element.val(name + ', ');
      }
      text_field_element.focus();
      dropdown_html_element.hide();
    }
EOF
  end
  
  def pie_chart_js(calculator_result)
    init_js =<<EOF
    // Make a graph object with canvas id and width
    var g = new Bluff.Pie('pie-chart', 400);

    // Set theme and options
    g.theme_pastel();
    g.title = 'Your Footprint Breakdown';
    g.title_font_size = 32; //default 36
    g.hide_line_markers = true;
    g.zero_degree = -90;
    //g.replace_colors(['#90DADA','#99DA90','#DA9990','#DADA90']);
    g.replace_colors(['#6CDADA','#79DA6C','#DA796C','#DADA6C','#6C6CDA']);

    // Add data and labels
    #{calculator_result.per_module_results.collect { |k, v| "g.data('#{k.pretty_module_name}', [#{number_with_delimiter(number_with_precision(v[:footprint], :precision => 2))}]);" }.join('')}
    //g.labels = {0: '2003', 2: '2004', 4: '2005'};

    // Render the graph
    g.draw();
EOF
  end
  
  def bar_chart_js(calculator_result)
    init_js =<<EOF
    // Make a graph object with canvas id and width
    var g = new Bluff.Bar('bar-chart', 400);

    // Set theme and options
    g.theme_pastel();
    //g.set_theme({
    //  colors: ['#202020', 'white', '#a21764', '#8ab438',
    //           '#999999', '#3a5b87', 'black'],
    //  marker_color: '#aea9a9',
    //  font_color: 'black',
    //  background_colors: ['#ff47a4', '#ff1f81']
    //});

    g.title = "How Your Footprint Compares to Others'";
    g.title_font_size = 32; //default 36
    g.minimum_value = 0;
    g.sort = false;
    //g.replace_colors(['#90DADA','#99DA90','#DA9990','#DADA90', '#9090DA']);
    g.replace_colors(['#6CDADA','#79DA6C','#DA796C','#DADA6C','#6C6CDA']);


    // Add data and labels
    //g.labels = {0: 'You', 1: '#{@calculator_input.user_input.city}', 2: '#{@calculator_input.user_input.state}', 3: 'United States'};
    
    g.data('Your footprint', [#{number_with_delimiter(number_with_precision(calculator_result.total_footprint, :precision => 2))}]);
    g.data('#{@calculator_input.user_input.city}', [#{number_with_precision(Query.sum(:algorithmic_footprint, :conditions => ['country = ? and state = ? and city = ?', 'US', @calculator_input.user_input.state, @calculator_input.user_input.city]).to_f / Query.count(:conditions => ['country = ? and state = ? and city = ?', 'US', @calculator_input.user_input.state, @calculator_input.user_input.city]).to_f, :precision => 2)}]);
    g.data('#{@calculator_input.user_input.state}', [#{number_with_precision(Query.sum(:algorithmic_footprint, :conditions => ['country = ? and state = ?', 'US', @calculator_input.user_input.state]) / Query.count(:conditions => ['country = ? and state = ?', 'US', @calculator_input.user_input.state]), :precision => 2)}]);
    //g.data('United States', [#{number_with_delimiter(number_with_precision(Query.sum(:algorithmic_footprint, :conditions => ['country = ?', 'US']) / Query.count(:conditions => ['country = ?', 'US']), :precision => 2))}]);
    //these numbers are hard-coded to provide a stable comparison
    g.data('United States', [24.5]);
    g.data('World', [5]);
    
    // Render the graph
    g.draw();
EOF
  end
end
