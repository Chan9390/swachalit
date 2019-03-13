class Chapter < ActiveRecord::Base
  audited
  
  attr_accessible :name, :description, :birthday, :code, :active
  attr_accessible :country, :city, :state
  attr_accessible :chapter_email, :image
  attr_accessible :twitter_handle, :facebook_profile, :github_profile, :linkedin_profile, :slideshare_profile

  validates :name, :presence => true, :uniqueness => true
  validates :description, :presence => true

  mount_uploader :image, ChapterImageUploader

  scope :active_chapters, lambda { where(:active => true) }

  has_many :events, :dependent => :restrict
  has_many :chapter_leads, :dependent => :destroy

  def has_twitter_handle?
    !self.twitter_handle.to_s.empty?
  end

  def twitter_handle_name
    h = nil
    if self.twitter_handle.to_s.strip =~ /https?:\/\/(www\.)?twitter\.com\/(.*)/
      h = $2.to_s
    elsif self.twitter_handle.to_s.strip =~ /twitter\.com\/([a-zA-Z0-9_]+)/
      h = $1.to_s
    elsif self.twitter_handle.to_s.strip =~ /^@(.*)/
      h = $1.to_s
    else
      h = self.twitter_handle.to_s.strip
    end
    return h
  end

  def has_facebook_profile?
    !self.facebook_profile.to_s.empty?
  end

  def has_github_profile?
    !self.github_profile.to_s.empty?
  end

  def has_homepage?
    !self.homepage.to_s.empty?
  end


  def leads
    self.chapter_leads.active.includes(:user).map {|cv| cv.user }
  end

  def next_upcoming_event
    upcoming_events.order('start_time ASC').first()
  end

  def past_events
    Event.archives.where(:chapter_id => self.id)
  end

  def upcoming_events
    Event.future_public_events.where(:chapter_id => self.id)
  end

  def to_param
    "#{self.id} #{self.name}".parameterize
  end

end
