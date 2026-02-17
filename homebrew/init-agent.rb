# frozen_string_literal: true

# Homebrew formula for init-agent
# A Zig CLI tool for scaffolding AI-agent projects
#
# To install:
#   brew tap leebase/init-agent
#   brew install init-agent
#
# To update:
#   brew update
#   brew upgrade init-agent

class InitAgent < Formula
  desc "CLI tool for scaffolding AI-agent projects"
  homepage "https://github.com/leebase/init-agent"
  version "0.4.0"
  license "MIT"

  # macOS builds
  on_macos do
    on_arm do
      url "https://github.com/leebase/init-agent/releases/download/v0.4.0/init-agent-aarch64-macos.tar.gz"
      sha256 "TODO: Update with actual SHA256"
    end
    on_intel do
      url "https://github.com/leebase/init-agent/releases/download/v0.4.0/init-agent-x86_64-macos.tar.gz"
      sha256 "TODO: Update with actual SHA256"
    end
  end

  # Linux builds
  on_linux do
    on_arm do
      url "https://github.com/leebase/init-agent/releases/download/v0.4.0/init-agent-aarch64-linux.tar.gz"
      sha256 "TODO: Update with actual SHA256"
    end
    on_intel do
      url "https://github.com/leebase/init-agent/releases/download/v0.4.0/init-agent-x86_64-linux.tar.gz"
      sha256 "TODO: Update with actual SHA256"
    end
  end

  def install
    bin.install "init-agent"
  end

  test do
    # Test that the binary exists and runs
    system "#{bin}/init-agent", "--version"
    
    # Test that help works
    output = shell_output("#{bin}/init-agent --help")
    assert_match "init-agent", output
  end
end
