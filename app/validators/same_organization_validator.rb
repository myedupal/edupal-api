class SameOrganizationValidator < ActiveModel::EachValidator

  def validate_each(origin, attribute, parent)
    # Parent model is not present, skip checking
    # associations will only be present when non nil
    return if parent.nil?

    # Define the organization method names or default to :organization
    record_org_method = options[:record_organization] || :organization
    parent_org_method = options[:parent_organization] || :organization
    record = origin

    # allow overwriting own model for many to many records
    if options[:from].present?
      model_must_have_association!(origin, options[:from])
      record = origin.send(options[:from])

      # from model is not present, skip checking
      return if record.nil?
    end

    # Ensure both record and parent respond to the organization method
    # Otherwise consider it a usage error
    model_must_have_association!(record, record_org_method)

    model_must_have_association!(parent, parent_org_method)

    # Retrieve organizations
    record_organization = record.send(record_org_method)
    parent_organization = parent.send(parent_org_method)

    # Add error to the original model if organizations do not match
    if record_organization != parent_organization
      origin.errors.add(attribute, :same_organization, message: options[:message] || "does not belong to the same organization as #{record.class.to_s.constantize}")
    end
  end

  private

    def model_must_have_association!(model, method)
      unless model.respond_to?(method)
        raise ArgumentError, "#{model.class} must have an #{method} association for SameOrganizationValidator"
      end
    end
end
