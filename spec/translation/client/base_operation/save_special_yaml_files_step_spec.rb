require 'spec_helper'

describe TranslationIO::Client::BaseOperation::SaveSpecialYamlFilesStep do

  it do
    yaml_locales_path = 'tmp/config/locales'
    FileUtils.mkdir_p(yaml_locales_path)

    File.open("#{yaml_locales_path}/en.yml", 'wb') do |file|
      file.write <<EOS
---
en:
  main:
    hello: Hello world
    female: false
  other:
    stuff: This is string stuff
  value: 42
  other_value: 78
EOS
    end

    File.open("#{yaml_locales_path}/fr.yml", 'wb') do |file|
      file.write <<EOS
---
fr:
  main:
    hello: Bonjour le monde
    female: true
  other:
    stuff: Ce truc est une chaine de caractères
  value: 43
EOS
    end

    yaml_file_paths = Dir["#{yaml_locales_path}/*.yml"]
    source_locale   = 'en'
    target_locales  = ['fr']

    operation_step = TranslationIO::Client::BaseOperation::SaveSpecialYamlFilesStep.new(source_locale, target_locales, yaml_locales_path, yaml_file_paths)
    operation_step.run

    expected_yaml_content_fr = <<EOS
#{TranslationIO::Client::BaseOperation::SaveSpecialYamlFilesStep.top_comment}---
fr:
  main:
    female: true
  value: 43
EOS

    File.read('tmp/config/locales/localization.fr.yml').strip.should == expected_yaml_content_fr.strip
  end

  it "doesn't write a localization.xx.yml file if it doesn't contain any value" do
    yaml_locales_path = 'tmp/config/locales'
    FileUtils.mkdir_p(yaml_locales_path)

    File.open("#{yaml_locales_path}/en.yml", 'wb') do |file|
      file.write <<EOS
---
en:
  value: 42
EOS
    end

    File.open("#{yaml_locales_path}/fr.yml", 'wb') do |file|
      file.write <<EOS
---
fr:
EOS
    end

    yaml_file_paths = Dir["#{yaml_locales_path}/*.yml"]
    source_locale   = 'en'
    target_locales  = ['fr']

    operation_step = TranslationIO::Client::BaseOperation::SaveSpecialYamlFilesStep.new(source_locale, target_locales, yaml_locales_path, yaml_file_paths)
    operation_step.run

    File.exist?('tmp/config/locales/localization.fr.yml').should be false
  end

end
