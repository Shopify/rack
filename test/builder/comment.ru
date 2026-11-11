# frozen_string_literal: true

=begin

=end
run lambda { |env| [200, { 'content-type' => 'text/plain' }, ['OK']] }
