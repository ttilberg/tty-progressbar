# frozen_string_literal: true

RSpec.describe TTY::ProgressBar, ":elapsed token" do
  let(:output) { StringIO.new }

  before { Timecop.safe_mode = false }

  after { Timecop.return }

  it "displays elapsed time" do
    Timecop.freeze(Time.local(2014, 10, 5, 12, 0, 0))
    progress = TTY::ProgressBar.new(":elapsed", output: output, total: 10)

    5.times do |sec|
      Timecop.freeze(Time.local(2014, 10, 5, 12, 0, sec))
      progress.advance
    end

    output.rewind
    expect(output.read).to eq([
      "\e[1G 0s",
      "\e[1G 1s",
      "\e[1G 2s",
      "\e[1G 3s",
      "\e[1G 4s"
    ].join)
  end

  it "resets elapsed time" do
    Timecop.freeze(Time.local(2014, 10, 5, 12, 0, 0))
    progress = TTY::ProgressBar.new(":elapsed", output: output, total: 5)

    5.times do |sec|
      Timecop.freeze(Time.local(2014, 10, 5, 12, 0, sec))
      progress.advance
    end
    expect(progress.complete?).to be(true)
    progress.reset
    2.times do |sec|
      Timecop.freeze(Time.local(2014, 10, 5, 13, 0, sec))
      progress.advance
    end

    output.rewind
    expect(output.read).to eq([
      "\e[1G 0s",
      "\e[1G 1s",
      "\e[1G 2s",
      "\e[1G 3s",
      "\e[1G 4s\n",
      "\e[1G 0s",
      "\e[1G 1s"
    ].join)
  end

  it "resumes elapsed time measurement when stopped or finished" do
    Timecop.freeze(Time.local(2021, 1, 10, 12, 0, 0))
    progress = TTY::ProgressBar.new(":elapsed", output: output, total: 10)

    5.times do |sec|
      Timecop.freeze(Time.local(2021, 1, 10, 12, 0, 1 + sec))
      progress.advance
    end

    progress.stop
    progress.resume

    3.times do |sec| # resume progression after 5 seconds
      Timecop.freeze(Time.local(2021, 1, 10, 12, 0, 10 + sec))
      progress.advance
    end

    progress.finish
    progress.update(total: 12)
    progress.resume

    2.times do |sec| # resume progression after 2 seconds
      Timecop.freeze(Time.local(2021, 1, 10, 12, 0, 15 + sec))
      progress.advance
    end

    output.rewind
    expect(output.read).to eq([
      "\e[1G 0s",
      "\e[1G 1s",
      "\e[1G 2s",
      "\e[1G 3s",
      "\e[1G 4s",
      "\e[1G 4s\n", # stopped
      "\e[1G 4s",
      "\e[1G 5s",
      "\e[1G 6s",
      "\e[1G 6s\n", # finished
      "\e[1G 6s",
      "\e[1G 7s\n"
    ].join)
  end
end
