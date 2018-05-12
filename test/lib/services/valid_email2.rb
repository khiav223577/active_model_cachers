# Test ValidEmail2 gem: https://github.com/lisinge/valid_email2
module ValidEmail2
  class Address
    def initialize(email)
      @email = email
    end

    def valid_mx?
      ActiveSupport::Notifications.instrument('sql.active_record', sql: "ValidEmail2::Address#valid_mx? is called with email: #{@email}.") do
        @email.end_with?('@example.com') # just for testing
      end
    end
  end
end

