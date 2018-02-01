# Recommended path for this file is 'spec/support/split_helper.rb', and you will need to ensure it
# is `require`-d by rails_helper.rb or spec_helper.rb
module SplitHelper

  # Usage:
  #
  # Force a specific experiment alternative to always be returned:
  #   use_ab_test(signup_form: "single_page")
  #
  # Force alternatives for multiple experiments:
  #   use_ab_test(signup_form: "single_page", pricing: "show_enterprise_prices")
  #
  def use_ab_test(alternatives_by_experiment)
    allow_any_instance_of(Split::Helper).to receive(:ab_test) do |_receiver, experiment|
      alternative =
        alternatives_by_experiment.fetch(experiment) { |key| raise "Unknown experiment '#{key}'" }
    end
  end
end

RSpec.configure do |config|
  # Make the `use_ab_test` method available to all specs:
  config.include SplitHelper
end