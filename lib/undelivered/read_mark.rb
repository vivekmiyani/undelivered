module Undelivered
  class ReadMark < ActiveRecord::Base
    belongs_to :reader,   polymorphic: true
    belongs_to :readable, polymorphic: true
  
    enum status: { delivered: 0, read: 1 }
  
    validates :status, uniqueness: { scope: [ :reader, :readable ] }
  
    module InstanceMethods
  
      def mark_as_delivered_for!(reader)
        ReadMark.transaction do
          rm = find_or_build_read_mark(reader, :delivered)
          rm.timestamp = self.send(read_mark_options[:on])
          rm.save!
        end
      end
  
      def mark_as_read_for!(reader)
        ReadMark.transaction do
          delivered_rm = find_or_build_read_mark(reader, :delivered)
          delivered_rm.timestamp = self.send(read_mark_options[:on])
          delivered_rm.save!
          read_rm = find_or_build_read_mark(reader, :read)
          read_rm.timestamp = self.send(read_mark_options[:on])
          read_rm.save!
        end
      end
  
      private
  
      def find_or_build_read_mark(reader, status)
        read_marks.find_or_initialize_by(reader: reader, status: status)
      end
  
      def find_read_mark(reader, status)
        read_marks.find_by(reader: reader, status: status)
      end
    end
  
    module ClassMethods
  
      def acts_as_reader
        has_many :read_marks, class_name: 'Undelivered::ReadMark', as: :reader, dependent: :destroy
      end
  
      def acts_as_readable(options)
        raise Error, '`on` must be included in readable options' unless options.include?(:on)

        include ReadMark::InstanceMethods
  
        class_attribute :read_mark_options
        self.read_mark_options = options
  
        has_many :read_marks, class_name: 'Undelivered::ReadMark', as: :readable, dependent: :destroy
      end
    end
  end

  def self.table_name_prefix
    'undelivered_'
  end
end
