class Customer < ApplicationRecord
  has_many :user_customers
  has_many :users, through: :user_customers
end
