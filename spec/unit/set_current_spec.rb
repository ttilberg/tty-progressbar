# coding: utf-8

require 'spec_helper'

RSpec.describe TTY::ProgressBar, 'current=' do
  let(:output) { StringIO.new('', 'w+') }

  it "allows to go back" do
    progress = TTY::ProgressBar.new("[:bar]", output: output, total: 10)
    3.times { progress.advance }
    progress.current = 5
    expect(progress.current).to eq(5)
    progress.current = 0
    expect(progress.current).to eq(0)
  end

  it "doesn't allow to go over total" do
    progress = TTY::ProgressBar.new("[:bar]", output: output, total: 10)
    progress.current = 12
    expect(progress.current).to eq(10)
  end

  it "doesn't allow to go below 0" do
    progress = TTY::ProgressBar.new("[:bar]", output: output, total: 10)
    progress.current = -1
    expect(progress.current).to eq(0)
  end

  it "cannot backtrack on finished" do
    progress = TTY::ProgressBar.new("[:bar]", output: output, total: 10)
    progress.current = 10
    expect(progress.current).to eq(10)
    progress.current = 5
    expect(progress.current).to eq(10)
  end
end
