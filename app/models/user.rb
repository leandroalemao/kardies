class User < ApplicationRecord
  update_index 'users#user', :self
  after_create :send_admin_mail

  acts_as_votable
  acts_as_voter
  acts_as_messageable
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :timeoutable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, omniauth_providers: [:facebook]

  scope :all_except, ->(user) { where.not(id: user) }
  scope :not_blocked, -> { where(deleted_at: nil) }

  # Relations
  has_one :about, dependent: :destroy
  has_one :user_detail, dependent: :destroy
  has_many :galleries, dependent: :destroy
  has_many :reports
  has_many :search_criteria
  has_many :vote_notifications, dependent: :destroy
  has_one :email_preference, dependent: :destroy
  has_many :conversation_notifications
  accepts_nested_attributes_for :user_detail

  # Validations
  validates :username, presence: true, uniqueness: true
  validates :username,
            format: { with: /\A[a-z0-9A-Z\_]*\Z/ }
  validates :username, length: { in: 3..40 }
  validates_email_format_of :email, message: 'Λάθος email'

  def self.find_for_oauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.username = create_username(auth.info.email)
    end
  end

  def self.search(query)
    scope = UsersIndex::User.filter do
      (state == query.state) &
        (city == query.city) &
        (is_signed_in == query.is_signed_in) &
        (gender == query.gender) &
        (age >= query.age_from) & (age <= query.age_to)
    end.order(created: :desc)
    scope.only(:id).load
  end

  def soft_delete
    update!(:deleted_at, Time.current)
  end

  # ensure user account is active
  def active_for_authentication?
    super && !deleted_at
  end

  # provide a custom message for a deleted account
  def inactive_message
    !deleted_at ? super : :deleted_account
  end

  delegate :city, to: :user_detail

  delegate :state, to: :user_detail

  delegate :gender, to: :user_detail

  def job
    return unless about && about.job.present?
    Rails.cache.fetch([:about, about.id, :job], expires_in: 1.day) do
      about.job
    end
  end

  def hobby
    return unless about && about.hobby.present?
    Rails.cache.fetch([:about, about.id, :hobby], expires_in: 1.day) do
      about.hobby
    end
  end

  def relationship_status
    return unless about && about.relationship_status.present?
    Rails.cache.fetch([:about, about.id, :relationship_status], expires_in: 1.day) do
      about.relationship_status
    end
  end

  def looking_for
    return unless about && about.looking_for.present?
    Rails.cache.fetch([:about, about.id, :looking_for], expires_in: 1.day) do
      about.looking_for
    end
  end

  def description
    return unless about && about.description.present?
    Rails.cache.fetch([:about, about.id, :description], expires_in: 1.day) do
      about.description
    end
  end

  def age
    Rails.cache.fetch([:user_detail, user_detail.id, :age], expires_in: 1.day) do
      user_detail.age
    end
  end

  def profile_picture(size = :thumb)
    user_detail.profile_picture.url(size)
  end

  def youtube_url
    about.youtube_url if about && about.youtube_url.present?
  end

  def to_param
    username
  end

  def mailboxer_email(_object)
    email
  end

  private

  def create_username(email)
    email.scan(/\A(.+?)@/).join.tr('.', '_')
  end

  def send_admin_mail
    UserMailer.welcome_email(self).deliver_later
  end
end
