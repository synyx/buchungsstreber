D = Steep::Diagnostic

target :lib do
  check 'lib'
  signature 'sig'

  configure_code_diagnostics(D::Ruby.strict)
  collection_config "rbs_collection.yaml"
end
