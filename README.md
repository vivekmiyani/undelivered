# Undelivered

Ruby gem to manage undelivered/ read status of ActiveRecord objects

Most of the logic shamelessly stolen from `unread` gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'undelivered'
```

And then execute:

    $ bundle install

Install migration yourself (as of now):

```ruby
class CreateUndeliveredReadMarks < ActiveRecord::Migration[6.1]
  def change
    create_table :undelivered_read_marks do |t|
      t.references :reader,   polymorphic: { null: false }
      t.references :readable, polymorphic: { null: false }
      t.integer    :status,   index: true
      t.datetime   :timestamp

      t.timestamps
    end

    add_index :undelivered_read_marks, [:reader_id, :reader_type, :readable_type, :readable_id, :status], name: 'undelivered_read_marks_reader_readable_status_index', unique: true
  end
end
```

Run migration:

    $ rails db:migrate

## Usage

By following idea from [`this`](https://github.com/ledermann/unread/issues/99) issue of `unread` gem.

```ruby
class User < ApplicationRecord
  acts_as_reader
end

class Conversation < ApplicationRecord
  acts_as_readable on: :updated_at

  has_many :messages, dependent: :destroy
  
  def undelivered_messages(reader)
    chain = messages
    rm = find_read_mark(reader, :delivered) # this method comes from `undelivered` gem
    if rm.present?
      chain = chain.where('created_at > ?', rm.timestamp)
    end
    return chain
  end
  
  def unread_messages(reader)
    chain = messages
    rm = find_read_mark(reader, :read)
    if rm.present?
      chain = chain.where('created_at > ?', rm.timestamp)
    end
    return chain
  end
end

class Message < ApplicationRecord
  belongs_to :conversation, touch: true
end
```

```ruby
# Suppose we got 1 users and 1 conversation
current_user = User.find(1)

conversation = Conversation.find(1)

message1 = conversation.messages.create
message2 = conversation.messages.create

# Get undelivered messages for current_user, using method of conversation class
conversation.undelivered_messages(current_user)
# => [ message1, message2 ]

# Mark them as delivered for current_user
conversation.mark_as_delivered_for!(current_user)


# Get unread messages for current_user
conversation.unread_messages(current_user)
# => [ message1, message2 ]

# Mark them as read for current_user
conversation.mark_as_read_for!(current_user)
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/vivekmiyani/undelivered. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/vivekmiyani/undelivered/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Undelivered project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/vivekmiyani/undelivered/blob/master/CODE_OF_CONDUCT.md).
