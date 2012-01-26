module Swiftype
  class Engine < BaseModel
    property 'name'
    property 'slug', :required => true
  end
end
