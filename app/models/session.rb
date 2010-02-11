class Session
  attr_accessor :email, :password, :remember_me
  
  # Author:: Nitin Shantharam (mailto:nitin@)
  def initialize(params = {})
    params.each{|k,v|send("#{k}=", v)} if params
  end
end