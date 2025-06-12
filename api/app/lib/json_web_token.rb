# Provides JWT encode/decode helpers
class JsonWebToken
  SECRET_KEY = ENV['JWT_SECRET'] || Rails.application.secrets.secret_key_base

  # Encodes a payload with an expiration time (default: 24 hours)
  def self.encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY)
  end

  # Decodes a JWT token and returns a Hash, or nil if invalid/expired
  def self.decode(token)
    body = JWT.decode(token, SECRET_KEY)[0]
    HashWithIndifferentAccess.new(body)
  rescue JWT::DecodeError, JWT::ExpiredSignature
    nil
  end
end
