class ErrorsSerializer
  def initialize(errors)
    @errors = errors
  end

  def serialize
     {
        errors: [
          {
            status: @errors.status_code.to_s,
            message: @errors.message
          }
        ]
      }
  end
end