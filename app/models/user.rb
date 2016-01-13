class User < ActiveRecord::Base

	default_scope { order('id DESC')}
	has_many :friendships, dependent: :destroy
	has_many :inverse_friendships, class_name: "Friendship", foreign_key: "friend_id", dependent: :destroy

	has_attached_file :avatar,
					storage: :s3,
					styles: { medium: "370x370", thumb: "100x100"},
		validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/


	def self.sign_in_from_omniauth(auth)
		find_by(provider: auth['provider'], uid: auth['uid'] || create_user_from_omniauth(auth))
	end

	def self.create_user_from_omniauth(auth)
		create(
			avatar: process_uri(auth['info']['image'] + "?width=9999"),
			email: auth['info']['email'],
			provider: auth['provider'],
			uid: auth['uid'],
			name: auth['info']['name'],
			gender: auth['extra']['raw_info']['gender'],
			date_of_birth: auth['extra']['raw_info']['birthday'].present? ? Date.strptime(auth['extra']['raw_info']['birthday'], '%m/%d/%Y') :nil,
			location: auth['info']['location'],
			bio: auth['extra']['raw_info']['bio']
		)
	end

	def request_match(user_2)
		self.friendships.create(friend: user_2)
	end

	def accept_friendship
		self.update_attributes(state: "active", friended_at: Time.now)
	end

	def remove_match(user2)
		inverse_friendship = inverse_friendships.where(user_id: user2).first
		if inverse_friendship
			self.inverse_friendships.where(user_id: user2).first.destroy
		else
			self.friendships.where(friend_id: user2).first.destroy
		end
	end
	
	private
	def self.process_uri(uri)
		image_url = URI.parse(uri)
		image_url.scheme = 'https'
		image_url.to_s
	end
end
