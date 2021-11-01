module RequestHelpers
  def headers
    {
      'ACCEPT' => 'application/json',
      'CONTENT_TYPE' => 'application/json',
    }
  end
end
