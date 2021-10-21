# Methods to help with working with domains
class DomainHelper
  class << self
    def needs_api_subdomain?
      return false if Rails.env.in? %w[test development]
      return false if ENV['WITHOUT_API_SUBDOMAIN'].present?

      # Disable subdomain in review apps, as this would require DNS setup
      # for each app
      #
      # Review apps will start with 'almanac-read' and will have HEROKU_BRANCH
      # set aswell. HEROKU_BRANCH is nil in production
      return false if ENV['HEROKU_APP_NAME'].starts_with?('almanac-read') && ENV['HEROKU_BRANCH'].present?

      true
    end
  end
end
