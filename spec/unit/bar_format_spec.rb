RSpec.describe TTY::ProgressBar, ":bar_format" do
  let(:output) { StringIO.new("", "w+") }
  let(:formats) { TTY::ProgressBar::Formats::FORMATS }

  TTY::ProgressBar::Formats::FORMATS.keys.each do |format|
    it "displays progress with #{format.inspect} format characters" do
      complete = formats[format][:complete]
      incomplete = formats[format][:incomplete]
      progress = TTY::ProgressBar.new("[:bar]", output: output, total: 10,
                                      bar_format: format)
      5.times { progress.advance(2) }
      output.rewind
      expect(output.read).to eq([
        "\e[1G[#{complete * 2}#{incomplete * 8}]",
        "\e[1G[#{complete * 4}#{incomplete * 6}]",
        "\e[1G[#{complete * 6}#{incomplete * 4}]",
        "\e[1G[#{complete * 8}#{incomplete * 2}]",
        "\e[1G[#{complete * 10}#{incomplete * 0}]\n"
      ].join)
    end
  end
end
