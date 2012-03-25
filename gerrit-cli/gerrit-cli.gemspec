# Copyright (C) 2012 VMware, Inc. All rights reserved.
require File.expand_path('../lib/gerrit/cli/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["mpage"]
  gem.email         = ["mpage@rbcon.com"]
  gem.description   = "This provides a tool for easing common interactions"   \
                      + " with Gerrit. It is mostly orthogonal to the `repo'" \
                      + " tool and tries not to interfere with your workflow."
  gem.summary       = "A simple cli for interacting with Gerrit."
  gem.homepage      = "http://www.cloudfoundry.org"

  gem.files         = Dir.glob("**/*")
  gem.executables   = ["gerrit"]
  gem.test_files    = Dir.glob("spec/**/*")
  gem.name          = "gerrit-cli"
  gem.require_paths = ["lib"]
  gem.version       = Gerrit::Cli::VERSION

  gem.add_development_dependency("rake")
  gem.add_development_dependency("rspec")
end
