def run-test \
  -override \
  -docstring "Run the current test file." \
%{
  set-register | %sh{ dip rspec spec/ecm/models/reason_spec.rb }
  edit -scratch *run-test-output*
  exec 'geA<ret><esc>"|p;'
}
