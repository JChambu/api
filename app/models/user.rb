class User < ApplicationRecord
  acts_as_token_authenticatable
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable

  has_many :user_customers
  has_many :customers, through: :user_customers

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  before_create -> {self.token = generate_token}

  private

  def generate_token
    loop do
      token = SecureRandom.hex
      return token unless User.exists?({token: token})
    end
  end
end
