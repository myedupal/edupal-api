module OrganizationScopedPolicy
  extend ActiveSupport::Concern

  # Defines a reusable scope method for policies that need organization-based restrictions
  def scope_by_organization(scope_overwrite: nil)
    active_scope = scope_overwrite || scope
    # Apply the organization scoping if user has a selected organization
    if user.selected_organization.present?
      active_scope.where(organization: user.selected_organization)
    else
      active_scope.where(organization: nil)
    end
  end
end
