class ChartsController < ApplicationController
  def usa_map
    # url = Gchart.line(
    #   # :custom => 'chd=s:93zyvneTTOMJMLIJFHEAECFJGHDBFCFIERcgnpy45879,IJKNUWUWYdnswz047977315533zy1246872tnkgcaZQONHCECAAAAEII&chls=3,6,3|1,1,0'
    #   :custom => 'chd=s:_&cht=t&chtm=world'
    # )
    
    # url = Gchart.pie_3d(
    #   :title => 'ruby_fu',
    #   :size => '400x200',
    #   :data => [10, 45, 45],
    #   :labels => ["DHH", "Rob", "Matt"]
    # )
    
    
    map = "usa"
    #gradient = "FFFFFF,00ff00,ffea00,ff9000,f30000"
    gradient = "cccccc,00ff00,ffff00,ff0000" #These colors feel okay to me

    water_color = "3b4c74"
    other_params = "&chtm=#{map}&chco=#{gradient}&chf=bg,s,#{water_color}"
    
    type = "t"
    size = "350x175"
    
    selection_of_states_with_data = Constants::US_STATES.select { |state|
      Query.count(:all, :conditions => ['state = ?', state[1]]) > 0
    }
    
    
    countries = selection_of_states_with_data.collect { |state|
      state[1]
    }.join()
    
    data = "t:" + selection_of_states_with_data.collect { |state|
      average_footprint = (Query.sum('algorithmic_footprint', :conditions => ['state = ?', state[1]]) / Query.count(:all, :conditions => ['state = ?', state[1]])).round
      [(average_footprint / 36.0) * 100,100].min #compared to US average
    }.join(',')
    
    
    # data = "s:_"
    # data = "t:0,100,50,32,60,40,43,12,14,54,98,17,70,76,18,29"
    # countries = "DZEGMGAOBWNGCFKECGCVSNDJTZGHMZZM"
    
    url = "http://chart.apis.google.com/chart?chs=#{size}&chld=#{countries}&chd=#{data}&cht=#{type}#{other_params}"
    
    
    
    
    redirect_to(url)
  end
end
