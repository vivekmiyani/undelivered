# frozen_string_literal: true

require_relative "undelivered/version"
require_relative "undelivered/read_mark"

module Undelivered
  class Error < StandardError; end
end

ActiveSupport.on_load(:active_record) do
  extend Undelivered::ReadMark::ClassMethods
end
