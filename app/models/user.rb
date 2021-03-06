class User < ApplicationRecord
  has_many :votes
  has_many :ranked_works, through: :votes, source: :work

  validates :username, :uid, :email, uniqueness: true, presence: true
  validates :name, :provider, presence: true

  def self.build_from_github(auth_hash)
    user = User.new(
      username: auth_hash[:info][:nickname], 
      uid: auth_hash[:uid], 
      provider: "github",
      email: auth_hash["info"]["email"],
      name: auth_hash[:info][:nickname]
    )
    return user
  end
end
