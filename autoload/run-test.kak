def run-test \
  -override \
  -docstring "Run the current test file." \
%{
  info -title "Test output" %sh{
    dip rspec spec/ecm/models/reason_spec.rb
  }
}
