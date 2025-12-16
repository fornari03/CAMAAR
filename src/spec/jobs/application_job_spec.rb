require 'rails_helper'

# Testes par ApplicationJob.
#
# Garante que a classe base herda corretamente de ActiveJob::Base.
RSpec.describe ApplicationJob, type: :job do
  it "herda de ActiveJob::Base" do
    expect(ApplicationJob.superclass).to eq(ActiveJob::Base)
  end
end