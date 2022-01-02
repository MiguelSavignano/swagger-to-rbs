# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name        = 'swagger-to-rbs'
  s.version     = '0.1.0'
  s.executables << 'swagger-to-rbs'
  s.date        = '2022-01-02'
  s.summary     = 'Swagger to rbs'
  s.description = 'Generate Http client and rbs files'
  s.authors     = ['Miguel Savignano']
  s.email       = 'migue.masx@gmail.com'
  s.files       = Dir.glob('{bin,lib}/**/{*,.?*}') + %w[README.md]
  s.homepage    = 'https://github.com/MiguelSavignano/swagger-to-rbs'
  s.license     = 'MIT'
  s.require_paths = ['lib']
  s.add_runtime_dependency 'thor', '~> 0'
  s.add_runtime_dependency 'slugify'
end
