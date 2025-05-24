# api/app/lib/json_web_token.rb
class JsonWebToken
  # Use an environment variable (or fall back to Rails secret_key_base)
  SECRET_KEY = ENV['JWT_SECRET'] || Rails.application.secrets.secret_key_base

  # Encode a payload (e.g. user_id), with an expiration time
  def self.encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY)
  end

  # Decode returns a Hash (or nil if invalid/expired)
  def self.decode(token)
    body = JWT.decode(token, SECRET_KEY)[0]
    HashWithIndifferentAccess.new(body)
  rescue JWT::DecodeError, JWT::ExpiredSignature
    nil
  end
end
