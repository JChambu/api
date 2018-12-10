class UserCustomer < ApplicationRecord
  belongs_to :user
  belongs_to :customer
end
