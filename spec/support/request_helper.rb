require 'devise/jwt/test_helpers'

module RequestHelpers
  def headers
    {
      'ACCEPT' => 'application/json',
      'CONTENT_TYPE' => 'application/json',
    }
  end

  def get_with_jwt_token(url, user)
    auth_headers = user ? Devise::JWT::TestHelpers.auth_headers(headers, user) : {}
    get(url, headers: headers.merge(auth_headers))
  end

  def post_with_jwt_token(url, user, params = {})
    auth_headers = user ? Devise::JWT::TestHelpers.auth_headers(headers, user) : {}
    post(url, params: params, headers: headers.merge(auth_headers))
  end

  def put_with_jwt_token(url, user, params = {})
    auth_headers = user ? Devise::JWT::TestHelpers.auth_headers(headers, user) : {}
    put(url, params: params, headers: headers.merge(auth_headers))
  end

  def delete_with_jwt_token(url, user)
    auth_headers = user ? Devise::JWT::TestHelpers.auth_headers(headers, user) : {}
    delete(url, headers: headers.merge(auth_headers))
  end
end
