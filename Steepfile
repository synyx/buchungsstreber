D = Steep::Diagnostic

target :lib do
  check 'lib'
  ignore 'lib/buchungsstreber/cli/*.rb'
  ignore 'lib/buchungsstreber/resolver/regexp.rb'
  signature 'sig'

  configure_code_diagnostics(D::Ruby.strict)
  collection_config "rbs_collection.yaml"
end
