Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*'
    resource '*',
      headers: :any,
      methods: [:get, :post, :patch, :put],
      expose: %w(Authorization)
  end
  # allow do
  #   origins 'http://localhost:3001'
  #   resource '/api/*',
  #     headers: %w(Authorization),
  #     methods: :any,
  #     expose: %w(Authorization),
  #     max_age: 600
  # end
end