require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "react-native-zoom-us-sdk"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.description  = package["description"]
  s.homepage     = "https://github.com/EslamElMeniawy/react-native-zoom-us-sdk"
  s.license      = package['license']
  s.authors      = { "Eslam El-Meniawy" => "eslam.elmeniawy@gmail.com" }
  s.platforms    = { :ios => "10.0" }
  s.source       = { :git => "https://github.com/EslamElMeniawy/react-native-zoom-us-sdk.git", :tag => "#{s.version}" }

  s.source_files = "ios/**/*.{h,m,swift}"
  s.requires_arc = true

  s.dependency "React"
end

