#
# Be sure to run `pod lib lint RFIBAN-Helper.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "RFIBAN-Helper"
  s.version          = "1.0.0"
  s.summary          = "A short description of RFIBAN-Helper."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
                       With this library you can validate IBAN accounts. 
                       
                       DESC

  s.homepage         = "https://github.com/readefries/RFIBAN-Helper"
  s.license          = 'MIT'
  s.author           = { "Hindrik Bruinsma" => "de@readefries.nl" }
  s.source           = { :git => "https://github.com/readefries/RFIBAN-Helper.git", :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'RFIBAN-Helper/Classes/**/*'
end
