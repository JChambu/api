class User < ApplicationRecord
  acts_as_token_authenticatable
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable

  has_many :user_customers
  has_many :customers, through: :user_customers

  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable
  before_create -> {self.token = generate_token}
  before_create -> {self.password = generate_password}


  def generate_password_token!
   self.reset_password_token = generate_token
   self.reset_password_sent_at = Time.now.utc
   save!
  end


  def password_token_valid?
   (self.reset_password_sent_at + 4.hours) > Time.now.utc
  end


  def reset_password!
   self.reset_password_token = nil
   self.password = generate_password
   save!
  end


  private

  def generate_password
    self.password = Devise.friendly_token.first(8)
  end

  def generate_token
   SecureRandom.hex(10)
  end

  # def generate_token
  #   loop do
  #     token = SecureRandom.hex
  #     return token unless User.exists?({token: token})
  #   end
  # end
end
