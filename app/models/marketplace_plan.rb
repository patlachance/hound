# frozen_string_literal: true

class MarketplacePlan
  MARKETPLACE_UPGRADE_URL = "https://www.github.com/marketplace/hound"
  PLANS = [
    OpenStruct.new(id: "MDIyOk1hcmtldHBsYWNlTGlzdGluZ1BsYW4xMDYx", repos: 0),
    OpenStruct.new(id: "MDIyOk1hcmtldHBsYWNlTGlzdGluZ1BsYW4xMDYy", repos: 4),
    OpenStruct.new(id: "MDIyOk1hcmtldHBsYWNlTGlzdGluZ1BsYW4xMDYz", repos: 20),
  ].freeze

  def initialize(owner)
    @owner = owner
  end

  def upgrade?
    owner.active_private_repos_count >= current_plan.repos
  end

  def current_plan
    @_current_plan ||= PLANS.
      detect { |plan| marketplace_plan.id == plan.id } || PLANS.first
  end

  def next_plan
    @_next_plan ||= PLANS[
      PLANS.find_index { |plan| plan.id == current_plan.id } + 1
    ]
  end

  def previous_plan
    @_previous_plan ||= current_plan.repos.positive? &&
      PLANS[PLANS.find_index { |plan| plan.id == current_plan.id } - 1]
  end

  def upgrade_url
    "#{MARKETPLACE_UPGRADE_URL}/order/#{next_plan.id}?account=#{owner.name}"
  end

  def downgrade_url
    "#{MARKETPLACE_UPGRADE_URL}/order/#{previous_plan.id}?account=#{owner.name}"
  end

  private

  attr_reader :owner

  def marketplace_plan
    @_marketplace_plan ||= app.
      plan_for_account(owner.github_id) || OpenStruct.new(id: nil)
  end

  def app
    @_app ||= GitHubApi.new(AppToken.new.generate)
  end
end
