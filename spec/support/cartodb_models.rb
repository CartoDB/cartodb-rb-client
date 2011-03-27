require 'cartodb-rb-client/cartodb/model'

class MotoGPCircuit < CartoDB::Model::Base
  field :length
  field :width
  field :longest_straight
  field :left_corners,  :type => Integer
  field :right_corners, :type => Integer
  field :constructed,   :type => Date
  field :modified,      :type => Date
end