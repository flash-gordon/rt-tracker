# auto_register: false

require 'dry/types'

Types = Dry.Types()

Types::NonEmptyString = Types::String.constructor do
  if _1.empty?
    nil
  else
    _1
  end
end
