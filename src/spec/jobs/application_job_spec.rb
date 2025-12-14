require 'rails_helper'

RSpec.describe ApplicationJob, type: :job do
  it "herda de ActiveJob::Base" do
    expect(ApplicationJob.superclass).to eq(ActiveJob::Base)
  end
end