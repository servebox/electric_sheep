require File.join(File.dirname(__FILE__), '../build')
require 'git_rev'

name "electric_sheep"

default_version ElectricSheep::VERSION

dependency "ruby"
dependency "rubygems"
dependency "bundler"

source path: packaging_directories[:root]

relative_path "electric_sheep"

build do
  revision = GitRev::Sha.new(repository: packaging_directories[:root]).full
  env = with_standard_compiler_flags(with_embedded_path)
  gem "build electric_sheep.gemspec", env: env
  gem "install electric_sheep-#{ElectricSheep::VERSION}.gem \
    -n #{install_dir}/bin --no-ri --no-rdoc", env: env
  erb source: 'ruby_wrapper.erb',
    dest: "#{install_dir}/bin/ruby_wrapper",
    vars: {install_dir: install_dir, revision: revision},
    mode: 0755
end
