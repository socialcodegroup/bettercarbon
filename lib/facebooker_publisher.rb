class FacebookerPublisher < Facebooker::Rails::Publisher
  def news_feed(recipients, title, body)
    send_as :story
    self.recipients(Array(recipients))
    title = title[0..60] if title.length > 60
    body = body[0..200] if body.length > 200
    self.body( body )
    self.title( title )
    # image_1(image_path("fbtt.png"))
    # image_1_link(outline_path(:only_path => false))
  end
end