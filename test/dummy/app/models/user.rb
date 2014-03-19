class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :attributable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
end
